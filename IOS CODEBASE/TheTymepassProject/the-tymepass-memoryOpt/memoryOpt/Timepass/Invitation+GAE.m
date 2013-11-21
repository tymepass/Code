//
//  Invitation+GAE.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "User+Management.h"
#import "Invitation+GAE.h"
#import "NSDataAdditions.h"
#import "EventMessage+GAE.h"
#import "Location+Management.h"
#import "Utils.h"

// Create the NSURL for the request
static NSString * invitationConfirmURL = @"https://tymepass.com/api/?action=confirmInvitation";

@implementation Invitation (GAE)

+ (NSArray *) getInvitations:(NSArray *)response {
    return [Invitation parseGAEInvitations:response];
}

+ (NSArray *) parseGAEInvitations:(NSArray *)response {
    NSArray *list;
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
    if (!isIOS5){
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonObject = [parser objectWithString:(NSString *)response];
        NSDictionary *responseDict;
        if ([jsonObject isKindOfClass:[NSArray class]]){
            debugLog(@"Array");
            responseDict = [[NSDictionary alloc] initWithDictionary:[jsonObject objectAtIndex:0]];
            list = [responseDict objectForKey:@"invitations"];
        }
    } else {
        list = [[response objectAtIndex:0] objectForKey:@"invitations"];
    }
    
    if ([list count] < 1)
        return nil;
	
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSDictionary * invitation in list) {
        //debugLog(@"%@", [invitation description]);
        //Check invitation type
        NSString* invitationType = [NSString stringWithFormat:@"%@",[invitation objectForKey:@"invitationType"]];
        NSString* messagesCount = [NSString stringWithFormat:@"%@",[invitation objectForKey:@"count"]];
        
        if ([invitationType isEqualToString:[NSString stringWithFormat:@"EditEvent"]] ||
			[invitationType isEqualToString:[NSString stringWithFormat:@"event"]] ||
			[invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestAccepted"]] ||
			[invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestAcceptedGold"]] ||
			[invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestMayBe"]] ||
			[invitationType isEqualToString:[NSString stringWithFormat:@"message"]]) {
            //get Event
			
            NSDictionary * eventObject = [invitation objectForKey:@"event"];
            
            //check if event exists else continue
            if([eventObject count] == 0)
                continue;
            
            Location *newLocation;
            if ([[eventObject objectForKey:@"locations"] count] > 0) {
                NSString *locationText = [NSString stringWithFormat:@"%@",[[[eventObject valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
                
                newLocation = [Location getLocationWithName:locationText inContext:[modelUtils defaultManagedObjectContext]];
                
                if (!newLocation)
                    newLocation = (Location *)[Location insertLocationWithName:locationText inContext:[modelUtils defaultManagedObjectContext]];
            }
            
            User *invitationUser = [User getUserWithId:[invitation objectForKey:@"userKey"] inContext:[modelUtils defaultManagedObjectContext]];
            User *creatorUser = [User getUserWithId:[eventObject objectForKey:@"creator"] inContext:[modelUtils defaultManagedObjectContext]];
			
            NSString *attendingStatus = [invitation objectForKey:@"InvitationStatus"];
            
            //debugLog(@"Event : %@  creator : %@", [eventObject objectForKey:@"title"],[eventObject objectForKey:@"creator"]);
            
            Event *invitationEvent = [Event getEventWithId:[NSString stringWithFormat:@"%@",[eventObject valueForKey:@"key"]]];
			
            if (!invitationEvent) {
                invitationEvent = [Event parseGAEEventInviteWithTitle:[eventObject objectForKey:@"title"]
																 info:[eventObject objectForKey:@"info"]
															startTime:[eventObject objectForKey:@"startTime"]
															  endTime:[eventObject objectForKey:@"endTime"]
															   isGold:[NSNumber numberWithInt:0]
																photo:[eventObject objectForKey:@"photo"]
															 reminder:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"reminder"]] intValue]]
														 reminderDate:[eventObject objectForKey:@"reminderDate"]
															recurring:[NSNumber numberWithInt:0]
													 recurringEndDate:[eventObject objectForKey:@"recurringEndTime"]
															 serverId:[NSString stringWithFormat:@"%@",[eventObject valueForKey:@"key"]]
													   parentServerId:[NSString stringWithFormat:@"%@",[eventObject valueForKey:@"parentServerId"]]
															 messages:nil
															   allDay:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isAllDay"]] intValue]]
															attending:[NSNumber numberWithInt:[Utils getStatusOf:attendingStatus]]
															isPrivate:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isPrivate"]] intValue]]
															   isOpen:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isOpen"]] intValue]]
													  isTymepassEvent:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isTymePassEvent"]] intValue]]
															isStealth:[NSNumber numberWithInt:0]
														   locationId:newLocation
															  creator:creatorUser
																 user:nil
															   iCalId:[eventObject objectForKey:@"iCalId"]
																 busy:[NSNumber numberWithInt:[[eventObject objectForKey:@"isPrivate"] intValue]]
														 dateModified:[eventObject objectForKey:@"dateModified"]
														  dateCreated:[eventObject objectForKey:@"dateCreated"]
															invitedBy:invitationUser
															  context:[modelUtils defaultManagedObjectContext]];
				
                //save the event
                [modelUtils commitDefaultMOC];
            } else {
				
				if ([invitationType isEqualToString:[NSString stringWithFormat:@"EditEvent"]]) {
					float reminderTime;
					switch ([[eventObject objectForKey:@"reminder"] intValue]) {
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
					
					[Event updateEvent:invitationEvent
							 withTitle:[eventObject objectForKey:@"title"]
								  info:[eventObject objectForKey:@"info"]
							 startTime:[GAEUtils parseDateFromGAE:[eventObject objectForKey:@"startTime"]]
							   endTime:[GAEUtils parseDateFromGAE:[eventObject objectForKey:@"endTime"]]
								isGold:[NSNumber numberWithInt:[[eventObject objectForKey:@"isGold"] intValue]]
								 photo:[eventObject objectForKey:@"photo"]
							 recurring:[NSNumber numberWithInt:0]
					  recurringEndDate:[eventObject objectForKey:@"recurringEndTime"]
							  location:newLocation
							  isAllDay:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isAllDay"]] intValue]]
							isEditable:[NSNumber numberWithInt:1]
							 isPrivate:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isPrivate"]] intValue]]
								isOpen:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"isOpen"]] intValue]]
							  reminder:[NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[eventObject objectForKey:@"reminder"]] intValue]]
						  reminderTime:reminderTime
						  reminderDate:[eventObject objectForKey:@"recurringEndTime"]];
					
				} else if([invitationType isEqualToString:[NSString stringWithFormat:@"event"]] ||
						  [invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestAccepted"]] ||
						  [invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestAcceptedGold"]] ||
						  [invitationType isEqualToString:[NSString stringWithFormat:@"EventRequestMayBe"]] ||
						  [invitationType isEqualToString:[NSString stringWithFormat:@"message"]]) {
					[invitationEvent setInvitedBy:invitationUser];
				}
			}
                        
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEEE, d MMM"];
            
            NSString *invitationText = [NSString stringWithFormat:@"%@ %@ has invited you to %@ event on %@", [invitationUser name], [invitationUser surname], [invitationEvent title], [df stringFromDate:[invitationEvent startTime]]];
            
            [result addObject: [GAEUtils addToDictWith:invitationText
                                              andPhoto:[eventObject objectForKey:@"photo"]
                                                status:[NSString stringWithFormat:@"%@",[invitation valueForKey:@"InvitationStatus"]]
										  invitationId:[NSString stringWithFormat:@"%@",[invitation valueForKey:@"InvitationId"]]
                                                object:invitationEvent
                                                  type:invitationType
                                         messagesCount:messagesCount]];
        }
        else {
            //We have a user invite situation
            User * invitationUser = [User getUserWithId:[invitation objectForKey:@"userKey"]
											  inContext:[modelUtils defaultManagedObjectContext]];
			
            //TODO implement user parsing and set invitation text
            if(invitationUser) {
				
				[result addObject: [GAEUtils addToDictWith:[NSString stringWithFormat:@"%@ %@ wants to be your Tymepass friend",[invitationUser surname], [invitationUser name]]
                                                  andPhoto:[invitationUser photo]
                                                    status:[NSString stringWithFormat:@"%@",[invitation valueForKey:@"InvitationStatus"]]
                                              invitationId:[NSString stringWithFormat:@"%@",[invitation valueForKey:@"InvitationId"]]
                                                    object:invitationUser
                                                      type:invitationType
                                             messagesCount:messagesCount]];
			}
        }
    }
    
    return result;
}

+ (NSArray *) getAttendees:(NSArray *)response {
    return [Invitation parseGAEAttendees:response];
}

+ (NSArray *) parseGAEAttendees:(NSArray *)response{
    NSArray *list = [[response objectAtIndex:0] valueForKey:@"users"];
    
    if ([list count] < 1) {
        return nil;
    }
    
    NSString *userKey;
    User *invitee;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSDictionary * invitation in list){
        //check key for my key
        userKey = [invitation objectForKey:@"key"];
        /*if ([userKey isEqualToString:[[[SingletonUser sharedUserInstance] user] serverId]]) {
		 continue;
		 } */
        
        //get user from key
        invitee = [User getUserWithId:userKey inContext:[modelUtils defaultManagedObjectContext]];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //debugLog(@"%@", userKey);
        [dict setObject:[NSString stringWithFormat:@"%@ %@",[invitee name], [invitee surname]]  forKey:@"name"];
        
        if ([invitee photo] && [[invitee photo] length] > 0)
            [dict setObject:[invitee photo] forKey:@"photo"];
        
        [dict setObject:@"NO" forKey:@"checked"];
        [dict setObject:[invitation objectForKey:@"key"] forKey:@"id"];
        
        [result addObject: dict];
        
    }
    
    return result;
}

+ (NSArray *) getInvitees:(NSArray *)response {
    return [Invitation parseGAEInvitees:response];
}

+ (NSArray *) parseGAEInvitees:(NSArray *)response{
    NSArray *result = [[response objectAtIndex:0] valueForKey:@"entities"];
    
    if ([result count] < 1)
        return nil;
    
    return result;
}

+ (BOOL) setInvitation:(NSString *) invitationId toStatus:(NSString *) status{
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:invitationId forKey:@"id"];
    [jsonObject setObject:status forKey:@"status"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:invitationConfirmURL];
    NSArray *list = [response valueForKey:@"status"];
    //debugLog(@"%@",[response JSONRepresentation]);
    
    if ([list count] > 0) {
        //confirmation of friendship succeeded
        //add the friend to core data friends
        return TRUE;
    }
    return FALSE;
}

@end
