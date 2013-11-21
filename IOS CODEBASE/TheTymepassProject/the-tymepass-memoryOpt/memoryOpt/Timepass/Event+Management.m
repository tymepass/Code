//
//  Event+Management.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event+Management.h"
#import "Event+GAE.h"
#import "Utils.h"
#import "Invitation+GAE.h"
#import "CalSync.h"
#import "NSManagedObject+DeepCopying.h"

static NSString *entityName = @"Event";

@implementation Event (Management)

+ (Event *)createEventWithTitle:(NSString *) title
                           info:(NSString *) info
                      startTime:(NSDate *) startTime
                        endTime:(NSDate *)endTime
                         isGold:(NSNumber *) isGold
                         iCalId:(NSString *) iCalId
                      recurring:(NSNumber *) recurring
			   recurringEndDate:(NSDate *) recurringEndDate
                       serverId:(NSString *) serverId
                          photo:(NSString *) photo
                     isEditable:(NSNumber *) isEditable
                       isAllDay:(NSNumber *) isAllDay
                      attending:(NSNumber *) attending
                      isPrivate:(NSNumber *) isPrivate
                         isOpen:(NSNumber *) isOpen
				isTymePassEvent:(NSNumber *)isTymePassEvent
                      messageId:(EventMessage *)messageId
                     locationId:(Location *)locationId
                        creator:(User *)creatorId
                           user:(User *)userId
                       reminder:(NSNumber *) reminder
				   reminderTime:(float) reminderTime
				   reminderDate:(NSDate *) reminderDate
                   dateModified:(NSDate *) dateModified
                    dateCreated:(NSDate *) dateCreated
                    invitations:(NSMutableArray *) invitations
                  eventMessages:(NSMutableArray *) eventMessages
                    privateFrom:(NSMutableArray *) privateFromFriendsArray
{
    Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    
    [event setTitle:title];
    [event setInfo:info];
    [event setStartTime:startTime];
    [event setEndTime:endTime];
    [event setDateCreated:[NSDate date]];
    [event setDateModified:[NSDate date]];
    
    [event setIsGold:isGold];
    
    [event setRecurring:recurring];
	
	// add recurring end date
	if ([recurring intValue] > 0) {
		[event setRecurranceEndTime:recurringEndDate];
	}
	
	[event setReminder:reminder];
	
    [event setPhoto: photo];
    [event setIsEditable:isEditable];
    [event setIsAllDay:isAllDay];
    [event setAttending:attending];
    [event setIsPrivate:isPrivate];
	[event setIsTymePassEvent:isTymePassEvent];
    [event setIsOpen:isOpen];
	
	if (locationId) {
		[event setLocationId:locationId];
	}
    
    [event setCreatorId:creatorId];
    [event setUserId:userId];
    
    if (!iCalId)  {
		
		if (reminderTime != -1) {
			[event setICalId:[CalSync saveToICal:event reminder:reminderTime]];
		} else {
			[event setICalId:[CalSync saveToICal:event reminderDate:reminderDate]];
			[event setReminderDate:reminderDate];
		}
    }
    else  {
        [event setICalId:iCalId];
        
        /*
		 EKEvent *ekEvent = [CalSync getIcalEvent:event];
		 
		 if (!ekEvent)
		 [event setICalId:[CalSync saveToICal:event reminder:reminderTime]];
		 */
    }
    
    if(messageId)
        [event setMessageId:[NSSet setWithObject:messageId]];
    
    //debugLog(@"Creating event from create event : %@", title);
    
    //synchronize with server
    //send to GAE and receive answer
    //[Event insertGAEEventWithEvent:event invitations:invitations eventMessages:eventMessages privateFrom:privateFromFriendsArray];
	
    return event;
}

+ (void)updateEvent:(Event *)currentEvent
		  withTitle:(NSString *)title
			   info:(NSString *)info
		  startTime:(NSDate *) startTime
			endTime:(NSDate *) endTime
			 isGold:(NSNumber *) isGold
			  photo:(NSString *) photo
		  recurring:(NSNumber *) recurring
   recurringEndDate:(NSDate *) recurringEndDate
		   location:(Location *)location
		   isAllDay:(NSNumber *)isAllDay
		 isEditable:(NSNumber *)isEditable
		  isPrivate:(NSNumber *) isPrivate
			 isOpen:(NSNumber *) isOpen
		   reminder:(NSNumber *) reminder
	   reminderTime:(float) reminderTime
	   reminderDate:(NSDate *) reminderDate {
    
    [currentEvent setTitle:title];
    [currentEvent setInfo:info];
    [currentEvent setStartTime:startTime];
    [currentEvent setEndTime:endTime];
    [currentEvent setIsGold:isGold];
    [currentEvent setPhoto:photo];
	
    [currentEvent setRecurring:recurring];
	// add recurring end date
	if ([recurring intValue] > 0) {
		[currentEvent setRecurranceEndTime:recurringEndDate];
	} else {
		[currentEvent setRecurranceEndTime:Nil];
	}
    
    if (location)
        [currentEvent setLocationId:location];
    
    [currentEvent setIsAllDay:isAllDay];
    [currentEvent setIsEditable:isEditable];
    
    [currentEvent setIsPrivate:isPrivate];
    [currentEvent setIsOpen:isOpen];
    //update reminder
	
	[currentEvent setReminder:reminder];
	
	EKEventStore* eventStore = [[EKEventStore alloc] init];
	EKEvent *event = [eventStore eventWithIdentifier:currentEvent.iCalId];
	if (event != nil) {
		if (reminderTime != -1) {
			[CalSync updateToICal:currentEvent reminder:reminderTime recurring:YES];
		} else {
			[CalSync updateToICal:currentEvent reminderDate:reminderDate recurring:YES];
			[currentEvent setReminderDate:reminderDate];
		}
	} else {
		if (reminderTime != -1) {
			[currentEvent setICalId:[CalSync saveToICal:currentEvent reminder:reminderTime]];
		} else {
			[currentEvent setICalId:[CalSync saveToICal:currentEvent reminderDate:reminderDate]];
			[currentEvent setReminderDate:reminderDate];
		}
	}
	
    [currentEvent setDateModified:[NSDate date]];
    [modelUtils commitDefaultMOC];
    //send updated event to GAE with server id and timestamp
    //[Event updateGAEEventWithEvent:currentEvent];
}

+ (Event *)parseGAEEventInviteWithTitle:(NSString *)title
                                   info:(NSString *)info
                              startTime:(NSString *)startTime
                                endTime:(NSString *) endTime
                                 isGold:(NSNumber *) isGold
                                  photo:(NSString *) photo
							   reminder:(NSNumber *) reminder
						   reminderDate:(NSString *) reminderDate
                              recurring:(NSNumber *) recurring
					   recurringEndDate:(NSString *) recurringEndDate
                               serverId:(NSString *) serverId
						 parentServerId:(NSString *)parentServerId
                               messages:(NSArray *) messages
                                 allDay:(NSNumber *)isAllDay
                              attending:(NSNumber *) attending
                              isPrivate:(NSNumber *) isPrivate
                                 isOpen:(NSNumber *) isOpen
						isTymepassEvent:(NSNumber *) isTymepassEvent
                              isStealth:(NSNumber *) isStealth
                             locationId:(Location *)locationId
                                creator:(User *)creatorId
                                   user:(User *)userId
                                 iCalId:(NSString *) iCalId
                                   busy:(NSNumber *) busy
                           dateModified:(NSString *) dateModified
                            dateCreated:(NSString *) dateCreated
                              invitedBy:(User *)invitedByUser
                                context:(NSManagedObjectContext *) context
{
	
	Event *event = Nil;
	
	if (context == [modelUtils defaultManagedObjectContext]) {
		
		event = [Event getEventWithId:serverId];
		
		//check if already exists in core data
		if (event){
			//debugLog(@"fetched from core data");
			return event;
		}
	}
    
    //debugLog(@"creating event from parse : %@",title);
    if(context == nil)
        context = [modelUtils defaultManagedObjectContext];
	
    event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	
    NSDate *startDate = [GAEUtils parseDateFromGAE:startTime];
    NSDate *endDate = [GAEUtils parseDateFromGAE:endTime];
    
    debugLog(@"event busyness : %@ of event : %@",busy, title);
    [event setServerId:serverId];
    [event setTitle:title];
    [event setInfo:info];
    [event setStartTime:startDate];
    [event setEndTime:endDate];
    [event setDateCreated:[GAEUtils parseDateFromGAE:dateCreated]];
    [event setDateModified:[GAEUtils parseDateFromGAE:dateModified]];
    [event setIsGold:isGold];
	[event setIsTymePassEvent:isTymepassEvent];
	
    [event setRecurring:recurring];
	if ([recurring intValue] > 0) {
		[event setRecurranceEndTime:[GAEUtils parseDateFromGAE:recurringEndDate]];
	} else {
		[event setRecurranceEndTime:Nil];
	}
	
	float reminderTime;
    switch ([reminder intValue]) {
        case 0:
            reminderTime = 0.0f;
            break;
		case 1:
			reminderTime = -1.0f;
			break;
        case 2:
            reminderTime = 60.0 * 5.0f;
            break;
        case 3:
            reminderTime = 60.0f * 15.0f;
            break;
        case 4:
            reminderTime = 60.0f * 30.0f;
            break;
        case 5:
            reminderTime = 60.0f * 60.0f;
            break;
        case 6:
            reminderTime = 60.0f * 120.0f;
            break;
        case 7:
            reminderTime = 24.0f * 60.0f * 60.0f;
            break;
        case 8:
            reminderTime = 48.0f * 60.0f * 60.0f;
            break;
        case 9:
            reminderTime = 7.0f * 24.0f * 60.0f * 60.0f;
            break;
        default:
			reminderTime = 900.0f;
            break;
    }
	
	[event setReminder:reminder];
	if ([reminder intValue] == 1) {
		[event setReminderDate:[GAEUtils parseDateFromGAE:reminderDate]];
	} else {
		[event setReminderDate:nil];
	}
	
    [event setPhoto: photo];
    [event setIsAllDay:isAllDay];
    [event setIsPrivate:isPrivate];
    [event setIsOpen:isOpen];
    [event setIsStealth:isStealth];
    [event setLocationId:locationId];
    [event setCreatorId:creatorId];
    [event setInvitedBy:invitedByUser];
	[event setParentServerId:parentServerId];
    
    if (busy)
        [event setBusy:busy];
    
    [event setAttending:attending];
    
    if (context == [modelUtils defaultManagedObjectContext]) {
        
        if (!iCalId)  {
            if ([attending intValue] == 1 || [attending intValue] == 2) {
                //Default reminder (15 minutes before)
				
				if ([reminder intValue] == 1) {
					[event setICalId:[CalSync saveToICal:event reminderDate:[GAEUtils parseDateFromGAE:reminderDate]]];
				} else {
					[event setICalId:[CalSync saveToICal:event reminder:reminderTime]];
				}
				
                //Update server event with new iCalId
                [ApplicationDelegate.eventEngine changeICalEvent:event ofUser:[[[SingletonUser sharedUserInstance] user] serverId]];
            }
        }
        else {
            [event setICalId:iCalId];
		}
        
        [event setUserId:[[SingletonUser sharedUserInstance] user]];
    }
	
    return event;
}


+ (int) getGoogleCalendarFromStore:(EKEventStore *) eventStore{
    EKCalendar *calendar = [[EKCalendar alloc] init];
    for (calendar in [eventStore calendars]){
        if ([calendar title]) {
            NSRange range = [[calendar title] rangeOfString : @"google"];
            
            if (range.location != NSNotFound) {
                //debugLog(@"I found Google calendar!.");
                return [[eventStore calendars] indexOfObject:calendar];
            }
        }
    }
    return  [[eventStore calendars] indexOfObject:[eventStore defaultCalendarForNewEvents]];
}

+ (NSArray *) getMonthEventsForPeriod:(NSDate *) startDate endDate:(NSDate *) endDate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
																   fromDate:startDate];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    components = [[NSCalendar currentCalendar] components:units
                                                 fromDate:endDate];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (attending == 1 OR attending == 2) AND ((startTime >= %@ AND startTime <= %@) OR (endTime >= %@ AND endTime <= %@))",[[SingletonUser sharedUserInstance] user], startDate, endDate, startDate, endDate];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByStartTime]];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return result;
}

+ (NSArray *) getEventsForYear:(NSDate *) selectedDay{
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:nil];
    
    return [NSArray arrayWithArray:result];
}

+ (NSArray *) getAllEvents {
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId.length > 0"];
	
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPropertyValues:NO];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"serverId", nil]];
	
	NSError *error;
	NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	return  result;
}

+ (NSArray *) getChildEvents:(Event *)event {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentServerId == %@", event.serverId];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"serverId" ascending:YES]];
	
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPropertyValues:NO];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"serverId", nil]];
	
	NSError *error;
	NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
	
	return  result;
}

+ (Event *)getEventWithId:(NSString *)eventId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId == %@", eventId];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"serverId" ascending:YES]];
    
    Event *event = (Event *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:sortDescriptors moc:[modelUtils defaultManagedObjectContext]];
    
    if (event)
        return event;
    else
        return nil;
}

+ (Event *) getEventWithICalId:(NSString *) eventIdentifier{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iCalId == %@", eventIdentifier];
    
    Event *event = (Event *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (event)
        return event;
    else
        return nil;
}

/**
 *
 *
 */
+ (NSMutableArray *) getPendingEvents: (User *) user {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@", [[SingletonUser sharedUserInstance] user], [NSDate date]];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] moc:[modelUtils defaultManagedObjectContext]]];
	
    //debugLog(@"result : %@" , [result JSONRepresentation]);
	
    return result;
}

+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@", [[SingletonUser sharedUserInstance] user], [NSDate date]];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] offset:offset moc:[modelUtils defaultManagedObjectContext]]];
	
    //debugLog(@"result : %@" , [result JSONRepresentation]);
	
    return result;
}

+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset condition:(NSString *)conditions {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@", [[SingletonUser sharedUserInstance] user], [NSDate date], [NSString stringWithFormat:@"%@", conditions]];
	
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] offset:offset moc:[modelUtils defaultManagedObjectContext]]];
	
    return result;
}

+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset index:(NSNumber *)index {
	NSPredicate *predicate;
	
	switch ([index intValue]) {
		case 0:
			predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@ AND (attending == 3 OR attending == 2)", [[SingletonUser sharedUserInstance] user], [NSDate date]];
			break;
			
		case 1:
			predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@ AND attending == 1", [[SingletonUser sharedUserInstance] user], [NSDate date]];
			break;
			
		case 2:
			predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@ AND attending == 0", [[SingletonUser sharedUserInstance] user], [NSDate date]];
			break;
			
		default:
			break;
	}
	
	NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] offset:offset moc:[modelUtils defaultManagedObjectContext]]];
	
    return result;
}

+ (NSMutableArray *) getPendingEventsForPending: (User *) user offset:(NSInteger)offset {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@ AND (attending == 3 OR attending == 2)", [[SingletonUser sharedUserInstance] user], [NSDate date]];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] offset:offset moc:[modelUtils defaultManagedObjectContext]]];
	
    //debugLog(@"result : %@" , [result JSONRepresentation]);
	
    return result;
}

+ (NSNumber *) getPendingEventsCount: (User *) user {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND endTime >= %@ AND (attending == 3 OR attending == 2)", user, [NSDate date]];
    
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]]];
	
    return [NSNumber numberWithInt:[result count]];
}

+ (NSMutableArray *) getGoldStarredEvents: (User *) user {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND isGold == 1", [[SingletonUser sharedUserInstance] user]];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] moc:[modelUtils defaultManagedObjectContext]]];
	
    return result;
}

+ (NSMutableArray *) getGoldStarredEvents: (User *) user offset:(NSInteger)offset {
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(attending = %@)  AND (userId = %@)", @"3", user];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@ AND isGold == 1", [[SingletonUser sharedUserInstance] user]];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
    NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:NO];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:[NSMutableArray arrayWithObjects:descriptor1,descriptor2, nil] offset:offset moc:[modelUtils defaultManagedObjectContext]]];
	
    return result;
}

+ (void) deleteAllEvents{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *event in result) {
        [[modelUtils defaultManagedObjectContext] deleteObject:event];
    }
}

+ (NSArray *) getAgendaEvents {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (attending != 0)", [[SingletonUser sharedUserInstance] user]];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByStartTime]];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return [NSArray arrayWithArray:result];
}

+ (NSArray *) getAgendaEvents:(NSInteger)offset {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
	
	//update for the start date
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	NSDate *sDate = [calendar dateFromComponents:comps];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (attending != 0) AND endTime >= %@", [[SingletonUser sharedUserInstance] user], sDate];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByStartTime]];
	
	[fetchRequest setFetchOffset:offset];
	[fetchRequest setFetchLimit:50];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return [NSArray arrayWithArray:result];
}

+ (NSArray *) getAgendaEventsForDay:(NSDate *) selectedDay{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
									(NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
																   fromDate:selectedDay];
    
	[components setHour:0];
	[components setMinute:0];
	[components setSecond:0];
	
	NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];
	
	[components setHour:23];
	[components setMinute:59];
	[components setSecond:59];
	
	NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
    
	//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startTime >= %@) AND (startTime <= %@)", dayStart, dayEnd];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (attending != 0 AND startTime <= %@ AND endTime > %@) OR (attending != 0 AND startTime > %@ AND startTime < %@)",[[SingletonUser sharedUserInstance] user],dayStart, dayStart, dayStart, dayEnd];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByStartTime]];
	
    NSError *error;
    
    return [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
}

+ (NSUInteger) getTotalNumberAgendaEventsForDay:(NSDate *) selectedDay{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                    (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                   fromDate:selectedDay];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (attending != 0) AND (startTime >= %@) AND (startTime <= %@)",[[SingletonUser sharedUserInstance] user], dayStart, dayEnd];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSUInteger count = [[modelUtils defaultManagedObjectContext] countForFetchRequest:fetchRequest error:&error];
    
    return count;
}

+ (NSArray *) getDayEventsForDay:(NSDate *) selectedDay{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                    (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                   fromDate:selectedDay];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND ((attending != 0) AND (startTime >= %@) AND (startTime <= %@)) OR ((attending != 0) AND (startTime < %@) AND (endTime > %@))",[[SingletonUser sharedUserInstance] user], dayStart, dayEnd, dayStart, dayStart];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startTime >= %@) AND (startTime <= %@)", dayStart, dayEnd];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByStartTime]];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return [NSArray arrayWithArray:result];
}

+ (NSArray *)getEventIdsOfUser:(User *)user {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", user];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return result;
}

+(void)updateRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds {
	
	// remove all the child ids and then delete the new one
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
	NSString *parentServerId;
	
	/*
	 if parent id = 0 we can delete all entries as this is the master entry
	 if parent id != 0 change the recurring time for old entries and delete the future entries and add new entries
	 all the conditions applicatable for only save future events only
	 */
	
	if (currentEvent.parentServerId == nil || [currentEvent.parentServerId intValue] == 0) {
		
		parentServerId = currentEvent.serverId;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentServerId == %@", currentEvent.serverId];
		
		[fetchRequest setPredicate:predicate];
		[fetchRequest setIncludesPropertyValues:NO];
		
		NSError *error;
		NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
		
		for (NSManagedObject *event in result) {
			[[modelUtils defaultManagedObjectContext] deleteObject:event];
		}
		
		[modelUtils commitDefaultMOC];
		
	} else {
		
		parentServerId = currentEvent.parentServerId;
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentServerId == %@ AND startTime <= %@", currentEvent.parentServerId, currentEvent.startTime];
		
		[fetchRequest setPredicate:predicate];
		[fetchRequest setIncludesPropertyValues:NO];
		
		NSError *error;
		NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
		
		for (Event *event in result) {
			[event setRecurranceEndTime:currentEvent.startTime];
		}
		
		[modelUtils commitDefaultMOC];
	}
	
	// delete all future entries
	fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentServerId == %@ AND startTime > %@", parentServerId, currentEvent.startTime];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPropertyValues:NO];
    
	NSArray *result = nil;
	NSError *error;
	result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *event in result) {
        [[modelUtils defaultManagedObjectContext] deleteObject:event];
    }
	
	[modelUtils commitDefaultMOC];
	
	int totalRowsToAdd = [serverIds count];
	NSDate *startDate = currentEvent.startTime;
	NSDate *endDate = currentEvent.endTime;
	
	unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *components;
	
	for (int i = 0; i < totalRowsToAdd; i++) {
		
		Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:entityName
															  inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
		
		switch ([[currentEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 2: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 6) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 2)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 2)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 7) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 1)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 1)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				// start date
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day] + 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				// end date
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day] + 1)];
				
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				break;
			}
				
			case 3: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day] + 7)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day] + 7)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 4: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 14)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 14)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 5: {
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setMonth:([components month]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setMonth:([components month]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 6:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setYear:([components year]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setYear:([components year]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
		}
		
		event = [currentEvent copy];
		[event setServerId:[[serverIds objectAtIndex:i] valueForKey:@"id"]];
		[event setParentServerId:currentEvent.serverId];
		[event setStartTime:startDate];
		[event setEndTime:endDate];
		[event setIsGold:[NSNumber numberWithInt:0]];
		
		[modelUtils commitDefaultMOC];
	}
}

+(NSArray *)addRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds inContext:(NSManagedObjectContext *) context {
	
	NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
	
	int totalRowsToAdd = [serverIds count];
	
	NSDate *startDate = currentEvent.startTime;
	NSDate *endDate = currentEvent.endTime;
	
	unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *components;
	
	for (int i = 0; i < totalRowsToAdd; i++) {
		
		Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:entityName
															  inManagedObjectContext:context];
		
		switch ([[currentEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 2: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 6) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 2)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 2)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 7) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 1)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 1)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				// start date
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day] + 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				// end date
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day] + 1)];
				
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				break;
			}
				
			case 3: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 7)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 7)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 4: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 14)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 14)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 5: {
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setMonth:([components month]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setMonth:([components month]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 6:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setYear:([components year]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setYear:([components year]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
		}
		
		event = [currentEvent copy];
		[event setServerId:[[serverIds objectAtIndex:i] valueForKey:@"id"]];
		[event setParentServerId:currentEvent.serverId];
		
		[event setStartTime:startDate];
		[event setEndTime:endDate];
		[event setIsGold:[NSNumber numberWithInt:0]];
		[eventsArray addObject:event];
	}
	
	if (totalRowsToAdd > 0 && context == [modelUtils defaultManagedObjectContext])
		[modelUtils commitDefaultMOC];
	
	return eventsArray;
}

+(void)addRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds {
	
	int totalRowsToAdd = [serverIds count];
	
	NSDate *startDate = currentEvent.startTime;
	NSDate *endDate = currentEvent.endTime;
	
	unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *components;
	
	for (int i = 0; i < totalRowsToAdd; i++) {
		
		Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:entityName
															  inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
		
		switch ([[currentEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 2: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 6) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 2)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 2)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				
				if ([components weekday] == 7) {
					
					// start date
					components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
					[components setDay:([components day] + 1)];
					startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
					
					// end date
					components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
					[components setDay:([components day] + 1)];
					endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				}
				
				// start date
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day] + 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				// end date
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day] + 1)];
				
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				break;
			}
				
			case 3: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 7)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 7)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 4: {
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setDay:([components day]+ 14)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setDay:([components day]+ 14)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 5: {
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setMonth:([components month]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setMonth:([components month]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
				
			case 6:{
				
				components = [[NSCalendar currentCalendar] components:units fromDate:startDate];
				[components setYear:([components year]+ 1)];
				startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				components = [[NSCalendar currentCalendar] components:units fromDate:endDate];
				[components setYear:([components year]+ 1)];
				endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
				
				break;
			}
		}
		
		event = [currentEvent copy];
		
		[event setServerId:[[serverIds objectAtIndex:i] valueForKey:@"id"]];
		[event setParentServerId:currentEvent.serverId];
		[event setIsGold:[NSNumber numberWithInt:0]];
		[event setStartTime:startDate];
		[event setEndTime:endDate];
	}
	
	if (totalRowsToAdd > 0) {
		[modelUtils commitDefaultMOC];
	}
	
}

@end