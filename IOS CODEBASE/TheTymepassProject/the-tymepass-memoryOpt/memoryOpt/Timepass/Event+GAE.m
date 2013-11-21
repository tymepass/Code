//
//  Event+GAE.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event+GAE.h"
#import "NSDataAdditions.h"
#import "Utils.h"
#import "Location+Management.h"
#import "MBProgressHUD.h"
#import "EventMessage+GAE.h"
#import "Invitation+GAE.h"
#import "CalSync.h"

// Create the NSURL for the request
static NSString * deleteEventsURL = @"https://tymepass.com/api/?action=deleteEvent";
static NSString * checkEventsURL = @"https://tymepass.com/api/?action=checkEvents";
static NSString * getEventsURL = @"https://tymepass.com/api/?action=getEvents";
static NSString * getMonthEventsURL = @"https://tymepass.com/api/?action=getEventsByDate";

@implementation Event (GAE)

+ (Event *) getGAEEventWithId:(NSString *)serverId CDEvent:(Event *) CDEvent inContext:(NSManagedObjectContext *) context {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    NSArray *eventId = [NSArray arrayWithObject:serverId];
    [jsonObject setObject:[NSDictionary dictionaryWithObjects:eventId forKeys:eventId] forKey:@"ids"];
	[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
	[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"CURRENTUSERID"];
	
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSDate* sourceDate = [NSDate date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    [jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timeZone"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:getEventsURL];
    
    return [Event parseGAEEventFromJSON:response CDEvent:CDEvent inContext:context];
}

+ (Event *) parseGAEEventFromJSON:(NSArray *) response CDEvent:(Event *) CDEvent inContext:(NSManagedObjectContext *) context{
    NSArray *eventList = [[response objectAtIndex:0] objectForKey:@"entities"];
    
    if (!(eventList.count > 0))
        return nil;
    
    NSDictionary *eventDict = [eventList objectAtIndex:0];
    Event *event;
    
    //check server Id for nil value to eliminate error on request (timeout and stuff)
    if ([eventDict objectForKey:@"key"] == nil)
        return nil;
    
    Location *newLocation;
    if ([[eventDict objectForKey:@"locations"] count] > 0) {
        NSString *locationText = [NSString stringWithFormat:@"%@",[[[eventDict valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
        newLocation = [Location getLocationWithName:locationText inContext:context];
        
        if (!newLocation) {
            newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
        }
    }
    
    [eventDict setValue:newLocation forKey:@"location"];
    
    User *creatorUser = [User getUserWithId:[eventDict valueForKey:@"creator"] inContext:context];
    [eventDict setValue:creatorUser forKey:@"creator"];
    
    NSString *attendingStatus;
    
    if ([eventDict objectForKey:@"attending"])
        attendingStatus = [eventDict objectForKey:@"attending"];
    else
        attendingStatus = @"confirmed";
    
    [eventDict setValue:[NSNumber numberWithInt:[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
    
    if (!CDEvent) {
        event = [Event createEventFromDictionary:eventDict inContext:context];
		
		NSArray *childIds = [eventDict objectForKey:@"chield"];
		if ([event.recurring intValue] > 0 && [childIds count] > 0) {
			[Event addRecurringEvent:event serverIds:childIds];
		}
	
    } else {
		
        [Event updateEvent:CDEvent
                 withTitle:[eventDict objectForKey:@"title"]
                      info:[eventDict objectForKey:@"info"]
                 startTime:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[eventDict objectForKey:@"startTime"]]]
                   endTime:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[eventDict objectForKey:@"endTime"]]]
                    isGold:[NSNumber numberWithInt:[[eventDict objectForKey:@"isGold"] intValue]]
                     photo:[eventDict objectForKey:@"photo"]
                 recurring:[NSNumber numberWithInt:[[eventDict objectForKey:@"recurring"] intValue]]
		  recurringEndDate:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[eventDict objectForKey:@"recurringEndTime"]]]
                  location:[eventDict objectForKey:@"location"]
                  isAllDay:[NSNumber numberWithInt:[[eventDict objectForKey:@"isAllDay"] intValue]]
                isEditable:nil
                 isPrivate:[NSNumber numberWithInt:[[eventDict objectForKey:@"isPrivate"] intValue]]
                    isOpen:[NSNumber numberWithInt:[[eventDict objectForKey:@"isOpen"] intValue]]
                  reminder:[NSNumber numberWithInt:[[eventDict objectForKey:@"reminder"] intValue]]
			  reminderTime:0.0f
			  reminderDate:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[eventDict objectForKey:@"reminderDate"]]]];
        event = CDEvent;
		
		//MOBI 9-8-13 commented below
//		User *creatorUser = [User getUserWithId:[eventDict valueForKey:@"creatorId"] inContext:context];
//		[eventDict setValue:creatorUser forKey:@"creator"];
		
		NSString *attendingStatus;
		
		if ([eventDict objectForKey:@"attending"])
			attendingStatus = [eventDict objectForKey:@"attending"];
		else
			attendingStatus = @"confirmed";
		
		[eventDict setValue:[NSNumber numberWithInt:[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
		
		[event setAttending:[NSNumber numberWithInt:[[eventDict objectForKey:@"attending"] intValue]]];
		[event setCreatorId:creatorUser];
		[event setUserId:[[SingletonUser sharedUserInstance] user]];
		
		if (context == [modelUtils defaultManagedObjectContext])
            [modelUtils commitDefaultMOC];
		
		NSArray *childIds = [eventDict objectForKey:@"chield"];
		[Event updateRecurringEvent:event serverIds:childIds];
    }
    
    return event;
}


+ (NSArray *) getGAEEventWithIds:(NSArray *) eventId inContext:(NSManagedObjectContext *) context{
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[NSDictionary dictionaryWithObjects:eventId forKeys:eventId] forKey:@"ids"];
	[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
	
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:getEventsURL];
    NSArray *listItems = [[response objectAtIndex:0] objectForKey:@"entities"];
    //create the nsarray with the response
    return [Event parseEventsDictsFromArray:listItems inContext:context];
}

+ (NSArray *)getGAEMonthEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate andUser:(NSString *)friendId inContext:(NSManagedObjectContext *) context{
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"seekerId"];
    [jsonObject setObject:friendId forKey:@"userId"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:startDate] forKey:@"dateFrom"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:endDate] forKey:@"dateTo"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:getMonthEventsURL];
    
    //debugLog(@"response %@", [response description]);
    
    NSArray *listItems = [[response objectAtIndex:0] valueForKey:@"entities"];
    //create the nsarray with the response
    return [Event parseEventsDictsFromArray:listItems inContext:context];
}

+ (NSArray *) parseEventsDictsFromArray:(NSArray *) listItems inContext:(NSManagedObjectContext *) context{
    //parse to array of dictionarys
    NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
    Event *eventObj;
	
    for (NSDictionary *event in listItems){
        Location *newLocation;
        if ([[event objectForKey:@"locations"] count] > 0) {
            NSString *locationText = [NSString stringWithFormat:@"%@",[[[event valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
            newLocation = [Location getLocationWithName:locationText inContext:context];
            
            if (!newLocation) {
                newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
            }
        }
        
        [event setValue:newLocation forKey:@"location"];
        
        User *creatorUser = [User getUserWithId:[event valueForKey:@"creator"] inContext:context];
        [event setValue:creatorUser forKey:@"creator"];
		
        NSString *attendingStatus;
        
        if ([event objectForKey:@"attending"])
            attendingStatus = [event objectForKey:@"attending"];
        else
            attendingStatus = @"confirmed";
        
        [event setValue:[NSNumber numberWithInt:[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
        eventObj = [Event createEventFromDictionary:event inContext:context];
        
        if (context == [modelUtils defaultManagedObjectContext])
            [modelUtils commitDefaultMOC];
        
        [eventsArray addObject:eventObj];
    }
    
    return eventsArray;
}

+ (NSArray *) getGAEEventWithIds:(NSArray *) eventId attendingEventStatus:(NSArray *)eventAttendingArray inContext:(NSManagedObjectContext *) context{
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[NSDictionary dictionaryWithObjects:eventId forKeys:eventId] forKey:@"ids"];
	[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:getEventsURL];
    NSArray *listItems = [[response objectAtIndex:0] objectForKey:@"entities"];
    //create the nsarray with the response
    return [Event parseEventsDictsFromArray:listItems attendingEventStatus:eventAttendingArray inContext:context];
}

+ (NSArray *) deleteGAEEventWithIds:(NSArray *) eventId {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[NSDictionary dictionaryWithObjects:eventId forKeys:eventId] forKey:@"ids"];
    [GAEUtils sendRequest:jsonObject toURL:deleteEventsURL];
	
	return nil;
}

+ (NSArray *) checkGAEEventWithIds:(NSArray *) eventId {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[NSDictionary dictionaryWithObjects:eventId forKeys:eventId] forKey:@"ids"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:checkEventsURL];
    NSArray *listItems = [[response objectAtIndex:0] objectForKey:@"entities"];

	// delete all those events which don't exists on server
    [Event deleteEventsDictsFromArray:listItems];
	return nil;
}

// delete those entries which are returned from response
+ (void) deleteEventsDictsFromArray:(NSArray *) listItems {
    for (NSDictionary *event in listItems){
		Event *eventOb = [Event getEventWithId:[event valueForKey:@"key"]];
		[[modelUtils defaultManagedObjectContext] deleteObject:eventOb];
		[modelUtils commitDefaultMOC];
	}
}

+ (NSArray *) parseEventsDictsFromArray:(NSArray *) listItems attendingEventStatus:(NSArray *)eventAttendingArray inContext:(NSManagedObjectContext *) context{
    //parse to array of dictionarys
    NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
    Event *eventObj;
    
    for (NSDictionary *event in listItems){
        Location *newLocation;
        if ([[event objectForKey:@"locations"] count] > 0) {
            NSString *locationText = [NSString stringWithFormat:@"%@",[[[event valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
            newLocation = [Location getLocationWithName:locationText inContext:context];
            
            if (!newLocation) {
                newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
            }
        }
        
        [event setValue:newLocation forKey:@"location"];
		
        User *creatorUser = [User getUserWithId:[event valueForKey:@"creator"] inContext:context];
        [event setValue:creatorUser forKey:@"creator"];
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventId == %@", [event valueForKey:@"key"]];
        
        NSString *invitedBy = [[[eventAttendingArray filteredArrayUsingPredicate:pred] objectAtIndex:0] objectForKey:@"invitedBy"];
        
        User *invitedByUser = [User getUserWithId:invitedBy inContext:context];
        [event setValue:invitedByUser forKey:@"invitedBy"];
        
        NSString *iCalId = [[[eventAttendingArray filteredArrayUsingPredicate:pred] objectAtIndex:0] objectForKey:@"iCalId"];
        [event setValue:iCalId forKey:@"iCalId"];
				
        [event setValue:[NSNumber numberWithInt:[[[[eventAttendingArray filteredArrayUsingPredicate:pred] objectAtIndex:0] objectForKey:@"attending"] intValue]] forKey:@"attendingStatus"];
        
        eventObj = [Event createEventFromDictionary:event inContext:context];
		
		
        if (context == [modelUtils defaultManagedObjectContext])
            [modelUtils commitDefaultMOC];
		
		if ([eventObj.recurring intValue] > 0) {
			// put conditions for the other child events
			NSArray *childIds = [event objectForKey:@"chield"];
			if ([childIds count] > 0) {
				[eventsArray addObjectsFromArray:[Event addRecurringEvent:eventObj serverIds:childIds inContext:context]];
			}
		}
		
        [eventsArray addObject:eventObj];
    }
    
    return eventsArray;
}

+ (Event *) createEventFromDictionary:(NSDictionary *) event inContext:(NSManagedObjectContext *) context {
    return  [Event parseGAEEventInviteWithTitle:[event objectForKey:@"title"]
                                           info:[event objectForKey:@"info"]
                                      startTime:[event objectForKey:@"startTime"]
                                        endTime:[event objectForKey:@"endTime"]
                                         isGold:[NSNumber numberWithInt:[[event objectForKey:@"isGold"] intValue]]
                                          photo:[event objectForKey:@"photo"]
									   reminder:[NSNumber numberWithInt:[[event objectForKey:@"reminder"] intValue]]
								   reminderDate:[event objectForKey:@"reminderDate"]
                                      recurring:[NSNumber numberWithInt:[[event objectForKey:@"recurring"] intValue]]
							   recurringEndDate:[event objectForKey:@"recurringEndTime"]
									   serverId:[event valueForKey:@"key"]
								 parentServerId:[event objectForKey:@"parentServerId"]
                                       messages:nil
                                         allDay:[NSNumber numberWithInt:[[event objectForKey:@"isAllDay"] intValue]]
                                      attending:[NSNumber numberWithInt:[[event objectForKey:@"attending"] intValue]]
                                      isPrivate:[NSNumber numberWithInt:[[event objectForKey:@"isPrivate"] intValue]]
                                         isOpen:[NSNumber numberWithInt:[[event objectForKey:@"isOpen"] intValue]]
								isTymepassEvent:[NSNumber numberWithInt:[[event valueForKey:@"isTymePassEvent"] intValue]]
                                      isStealth:[NSNumber numberWithInt:[[event objectForKey:@"isPrivate"] intValue]]
                                     locationId:[event objectForKey:@"location"]
                                        creator:[event objectForKey:@"creator"]
                                           user:nil
                                         iCalId:[event objectForKey:@"iCalId"]
                                           busy:[NSNumber numberWithInt:[[event objectForKey:@"isPrivate"] intValue]]
                                   dateModified:[event objectForKey:@"dateModified"]
                                    dateCreated:[event objectForKey:@"dateCreated"]
                                      invitedBy:[event objectForKey:@"invitedBy"]
                                        context:context
             ];
}

+ (NSArray *) getStealthFrom:(NSArray *)response {
    return [Invitation parseGAEInvitees:response];
}

+ (NSArray *) parseGAEStealthFrom:(NSArray *)response{
    NSArray *result = [[response objectAtIndex:0] valueForKey:@"entities"];
    
    if ([result count] < 1)
        return nil;
    
    return result;
}

@end
