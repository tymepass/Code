

//
//  CalSync.m
//  Timepass
//
//  Created by Christos Skevis on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalSync.h"
#import "Location+Management.h"
#import "Event+GAE.h"

@implementation CalSync

+ (void) syncWithICal:(User *) user {
	
	NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 1 return
    if ([[settingsDictionary objectForKey:@"iCal_sync"] boolValue]) {
		//get default event store
		//TODO according to apple this should be initialized only once
		EKEventStore *eventStore = [[EKEventStore alloc] init];
		NSDate *startDate = [NSDate date];
		//ending date should be one month ahead (do we need greater period or better precision?)
		NSDate *endDate = [startDate dateByAddingTimeInterval:(365 * 24 * 60 * 60)];
		
		NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:endDate];
		
		[components setHour:23];
		[components setMinute:59];
		[components setSecond:59];
		
		endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
		//fetch all ical events
		// Create the predicate.
		NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]; // eventStore is an instance variable.
		
		// Fetch all events that match the predicate.
		NSArray *EKEventsArray = [eventStore eventsMatchingPredicate:predicate];
		//iterate them
		Event *tpEvent;
		
		NSMutableArray *eventIdentifiers = [[NSMutableArray alloc] init];
		
		for (EKEvent *event in EKEventsArray) {
			
			//						debugLog(@"Event ical id: %@", event.title);
			//						debugLog(@"Event UUID id: %@", event.UUID);
			//						debugLog(@"Event %@", event.description);
			
			
			if ([eventIdentifiers containsObject:[NSString stringWithFormat:@"%@", event.UUID]]) {
				continue;
			}
			[eventIdentifiers addObject:[NSString stringWithFormat:@"%@", event.UUID]];
			
			NSRange ridRange = [event.eventIdentifier rangeOfString:@"/RID"];
			NSDate *recurringEndTime = [NSDate date];
			int recur = 0;
			if ([[event recurrenceRules] count] || ridRange.length > 0) {
				
				for (EKRecurrenceRule *rule in [event recurrenceRules]) {
					
					recurringEndTime = rule.recurrenceEnd.endDate;
					
					// set recurring end to be 2 months later if its set to never
					if (recurringEndTime == nil) {
						NSDate *today = [[NSDate alloc] init];
						NSCalendar *gregorian = [NSCalendar currentCalendar];
						NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
						[offsetComponents setYear:2];
						recurringEndTime = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
					}
					
					switch (rule.frequency) {
							
						case EKRecurrenceFrequencyDaily: {
							recur = 1;
							if ([rule.daysOfTheWeek count] == 5) {
								recur = 2;
							}
							break;
						}
							
						case EKRecurrenceFrequencyWeekly: {
							recur = 3;
							if (rule.interval == 2) {
								recur = 4;
							}
							break;
						}
							
						case EKRecurrenceFrequencyMonthly: {
							recur = 5;
							break;
						}
							
						case EKRecurrenceFrequencyYearly: {
							recur = 6;
							break;
						}
							
						default:
							recur = 0;
							break;
					}
				}
			}
			
			// Check Core Data if ical event exists (using iCalId)
			tpEvent = [CalSync getTPEvent:event];
			
			// If exists in CD, update if newer
			if (tpEvent) {
				if (![tpEvent.iCalId isEqualToString:event.eventIdentifier]) {
					[tpEvent setRecurranceEndTime:recurringEndTime];
					[tpEvent setICalId:event.eventIdentifier];
					[modelUtils commitDefaultMOC];
					
					//Update server event with new iCalId
					[ApplicationDelegate.eventEngine changeICalEvent:tpEvent ofUser:[[[SingletonUser sharedUserInstance] user] serverId]];
				}
				
				//Update iCal Event URL
				[CalSync updateToICal:tpEvent];
				//debugLog(@"event with title %@ existed skipping", tpEvent.title);
			}
			//else save it to CD
			else {
				//if ios5 we have date created and date modified and location
				NSDate *createdAt;
				NSDate *modifiedAt;
				//create location
				Location *newLocation;
				BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
				if (isIOS5){
					createdAt = event.creationDate;
					modifiedAt = event.lastModifiedDate;
					
					if (!event.location) {
						event.location = @"";
					}
					newLocation = [Location getLocationWithName:event.location inContext:[modelUtils defaultManagedObjectContext]];
					if (!newLocation) {
						newLocation = (Location *)[Location insertLocationWithName:event.location inContext:[modelUtils defaultManagedObjectContext]];
					}
				} else {
					createdAt = [NSDate date];
					modifiedAt = [NSDate date];
					newLocation = nil;
				}
				
				int selectedEventReminderIndex = 0;
				float reminderTime = 0.0f;
				if ([event alarms]) {
					
					EKAlarm *alarm = [[event alarms] objectAtIndex:0];
					float reminderTime = [alarm relativeOffset];
					debugLog(@"Reminder : %d", (int) reminderTime);
					
					switch ((int)reminderTime * -1) {
						case 0:
							selectedEventReminderIndex = 0;
							break;
						case 60 * 5:
							selectedEventReminderIndex = 2;
							break;
						case 60 * 15:
							selectedEventReminderIndex = 3;
							break;
						case 60 * 30:
							selectedEventReminderIndex = 4;
							break;
						case 60 * 60:
							selectedEventReminderIndex = 5;
							break;
						case 60 * 120:
							selectedEventReminderIndex = 6;
							break;
						case 24 * 60 * 60:
							selectedEventReminderIndex = 7;
							break;
						case 48 * 60 * 60:
							selectedEventReminderIndex = 8;
							break;
						case 7 * 24 * 60 * 60:
							selectedEventReminderIndex = 9;
							break;
						default:
							selectedEventReminderIndex = 10;
							break;
							
					}
					
				} else {
					selectedEventReminderIndex = 0;
				}
				
				//debugLog(@"Cretaing event with title %@ ", event.title);
				tpEvent = [Event createEventWithTitle:event.title
												 info:event.notes
											startTime:event.startDate
											  endTime:event.endDate
											   isGold:[NSNumber numberWithInt:0]
											   iCalId:event.eventIdentifier
											recurring:[NSNumber numberWithInt:recur]
									 recurringEndDate:recurringEndTime
											 serverId:tpEvent.serverId
												photo:nil
										   isEditable:[NSNumber numberWithInt:0]
											 isAllDay:[NSNumber numberWithBool:event.isAllDay]
											attending:[NSNumber numberWithInt:1]
											isPrivate:[NSNumber numberWithInt:1]
											   isOpen:[NSNumber numberWithInt:0]
									  isTymePassEvent:[NSNumber numberWithInt:0]
											messageId:nil
										   locationId:newLocation
											  creator:[[SingletonUser sharedUserInstance] user]
												 user:[[SingletonUser sharedUserInstance] user]
											 reminder:[NSNumber numberWithInt:selectedEventReminderIndex]
										 reminderTime:reminderTime
										 reminderDate:nil
										 dateModified:modifiedAt
										  dateCreated:createdAt
										  invitations:nil
										eventMessages:nil
										  privateFrom:nil];
				
				//after event is saved save in GAE
				[ApplicationDelegate.eventEngine insertGAEEventWithEvent:tpEvent onCompletion:^(NSString *serverId) {
					if (![serverId isEqualToString:@"-1"]) {
						[tpEvent setServerId:serverId];
						[modelUtils commitDefaultMOC];
						
						//Update iCal Event URL
						[CalSync updateToICal:tpEvent];
						
						//NSLog(@"currentEvent %@",[newEvent serverId]);
						
					}
				} onError:^(NSError* error) {
				}];
				
			}
		}
		
		// code to delete local entries
		
		NSArray *events = [Event getAllEvents];
		if ([events count] > 0) {
			NSMutableArray *filteredEventIdsArray = [[NSMutableArray alloc] init];
			for (Event *event in events) {
				[filteredEventIdsArray addObject:event.serverId];
			}
			
			[Event checkGAEEventWithIds:filteredEventIdsArray];
		}
	}
	
    if (ApplicationDelegate.loadingView) {
        [ApplicationDelegate.loadingView removeFromSuperview];
        ApplicationDelegate.loadingView = nil;
    }
}

+ (void) syncWithICalOnOneCall:(User *) user {
	
	NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	NSMutableArray *updateEvents = [[NSMutableArray alloc] init];
	NSMutableArray *insertEvents = [[NSMutableArray alloc] init];
    
    //if sync set to 1 return
    if ([[settingsDictionary objectForKey:@"iCal_sync"] boolValue]) {
		//get default event store
		//TODO according to apple this should be initialized only once
		EKEventStore *eventStore = [[EKEventStore alloc] init];
		NSDate *startDate = [NSDate date];
		//ending date should be one month ahead (do we need greater period or better precision?)
		NSDate *endDate = [startDate dateByAddingTimeInterval:(365 * 24 * 60 * 60)];
		
		NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:endDate];
		
		[components setHour:23];
		[components setMinute:59];
		[components setSecond:59];
		
		endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
		//fetch all ical events
		// Create the predicate.
		NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]; // eventStore is an instance variable.
		
		// Fetch all events that match the predicate.
		NSArray *EKEventsArray = [eventStore eventsMatchingPredicate:predicate];
		//iterate them
		
		NSMutableArray *eventIdentifiers = [[NSMutableArray alloc] init];
		
		for (EKEvent *event in EKEventsArray) {
			
			Event *tpEvent;
			
			if ([eventIdentifiers containsObject:[NSString stringWithFormat:@"%@", event.UUID]]) {
				continue;
			}
			
			[eventIdentifiers addObject:[NSString stringWithFormat:@"%@", event.UUID]];
			
			NSRange ridRange = [event.eventIdentifier rangeOfString:@"/RID"];
			NSDate *recurringEndTime = [NSDate date];
			int recur = 0;
			if ([[event recurrenceRules] count] || ridRange.length > 0) {
				
				for (EKRecurrenceRule *rule in [event recurrenceRules]) {
					
					recurringEndTime = rule.recurrenceEnd.endDate;
					
					// set recurring end to be 2 months later if its set to never
					if (recurringEndTime == nil) {
						NSDate *today = [[NSDate alloc] init];
						NSCalendar *gregorian = [NSCalendar currentCalendar];
						NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
						[offsetComponents setYear:2];
						recurringEndTime = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
					}
					
					switch (rule.frequency) {
							
						case EKRecurrenceFrequencyDaily: {
							recur = 1;
							if ([rule.daysOfTheWeek count] == 5) {
								recur = 2;
							}
							break;
						}
							
						case EKRecurrenceFrequencyWeekly: {
							recur = 3;
							if (rule.interval == 2) {
								recur = 4;
							}
							break;
						}
							
						case EKRecurrenceFrequencyMonthly: {
							recur = 5;
							break;
						}
							
						case EKRecurrenceFrequencyYearly: {
							recur = 6;
							break;
						}
							
						default:
							recur = 0;
							break;
					}
				}
			}
			
			// Check Core Data if ical event exists (using iCalId)
			tpEvent = [CalSync getTPEvent:event];
			
			// If exists in CD, update if newer
			if (tpEvent) {
				if (![tpEvent.iCalId isEqualToString:event.eventIdentifier]) {
					[tpEvent setRecurranceEndTime:recurringEndTime];
					[tpEvent setICalId:event.eventIdentifier];
					[modelUtils commitDefaultMOC];
					
					[updateEvents addObject:tpEvent];
				}
			}
			//else save it to CD
			else {
				//if ios5 we have date created and date modified and location
				NSDate *createdAt;
				NSDate *modifiedAt;
				//create location
				Location *newLocation;
				BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
				if (isIOS5){
					createdAt = event.creationDate;
					modifiedAt = event.lastModifiedDate;
					
					if (!event.location) {
						event.location = @"";
					}
					newLocation = [Location getLocationWithName:event.location inContext:[modelUtils defaultManagedObjectContext]];
					if (!newLocation) {
						newLocation = (Location *)[Location insertLocationWithName:event.location inContext:[modelUtils defaultManagedObjectContext]];
					}
				} else {
					createdAt = [NSDate date];
					modifiedAt = [NSDate date];
					newLocation = nil;
				}
				
				int selectedEventReminderIndex = 0;
				float reminderTime = 0.0f;
				if ([event alarms]) {
					
					EKAlarm *alarm = [[event alarms] objectAtIndex:0];
					float reminderTime = [alarm relativeOffset];
					//debugLog(@"Reminder : %d", (int) reminderTime);
					
					switch ((int)reminderTime * -1) {
						case 0:
							selectedEventReminderIndex = 0;
							break;
						case 60 * 5:
							selectedEventReminderIndex = 2;
							break;
						case 60 * 15:
							selectedEventReminderIndex = 3;
							break;
						case 60 * 30:
							selectedEventReminderIndex = 4;
							break;
						case 60 * 60:
							selectedEventReminderIndex = 5;
							break;
						case 60 * 120:
							selectedEventReminderIndex = 6;
							break;
						case 24 * 60 * 60:
							selectedEventReminderIndex = 7;
							break;
						case 48 * 60 * 60:
							selectedEventReminderIndex = 8;
							break;
						case 7 * 24 * 60 * 60:
							selectedEventReminderIndex = 9;
							break;
						default:
							selectedEventReminderIndex = 10;
							break;
							
					}
					
				} else {
					selectedEventReminderIndex = 0;
				}
				
				//debugLog(@"Cretaing event with title %@ ", event.title);
				tpEvent = [Event createEventWithTitle:event.title
												 info:event.notes
											startTime:event.startDate
											  endTime:event.endDate
											   isGold:[NSNumber numberWithInt:0]
											   iCalId:event.eventIdentifier
											recurring:[NSNumber numberWithInt:recur]
									 recurringEndDate:recurringEndTime
											 serverId:tpEvent.serverId
												photo:nil
										   isEditable:[NSNumber numberWithInt:0]
											 isAllDay:[NSNumber numberWithBool:event.isAllDay]
											attending:[NSNumber numberWithInt:1]
											isPrivate:[NSNumber numberWithInt:1]
											   isOpen:[NSNumber numberWithInt:0]
									  isTymePassEvent:[NSNumber numberWithInt:0]
											messageId:nil
										   locationId:newLocation
											  creator:[[SingletonUser sharedUserInstance] user]
												 user:[[SingletonUser sharedUserInstance] user]
											 reminder:[NSNumber numberWithInt:selectedEventReminderIndex]
										 reminderTime:reminderTime
										 reminderDate:nil
										 dateModified:modifiedAt
										  dateCreated:createdAt
										  invitations:nil
										eventMessages:nil
										  privateFrom:nil];
				
				[insertEvents addObject:tpEvent];
			}
		}
		
		// code to update events on server
		if ([updateEvents count] > 0) {
			[ApplicationDelegate.eventEngine changeICalEvents:updateEvents ofUser:[[[SingletonUser sharedUserInstance] user] serverId]];
		}
		
		// code to insert events on server
		if ([insertEvents count] > 0) {
			[ApplicationDelegate.eventEngine insertGAEEventWithEvents:insertEvents onCompletion:^(NSArray *events) {
				
				for (NSMutableDictionary *data in events) {
					
					NSString *icalId = [[NSString alloc] initWithFormat:@"%@",[data objectForKey:@"iCalId"]];
					
					NSString *serverId = [[NSString alloc] initWithFormat:@"%@",[[data objectForKey:@"Response"] valueForKey:@"id"]];
					
					Event *event = [Event getEventWithICalId:icalId];
					[event setServerId:serverId];
					[modelUtils commitDefaultMOC];
					
					NSArray *childIds = [[data objectForKey:@"Response"] valueForKey:@"chield"];
					
					if ([event.recurring intValue] > 0 && [childIds count] > 0) {
						[Event addRecurringEvent:event serverIds:childIds];
					}
					
					[CalSync updateToICal:event];
				}
				
				if (ApplicationDelegate.loadingView) {
					[ApplicationDelegate.loadingView removeFromSuperview];
					ApplicationDelegate.loadingView = nil;
				}
				
				
			} onError:^(NSError* error) {
			}];
		} else {
			
			// code to delete local entries
			NSArray *events = [Event getAllEvents];
			if ([events count] > 0) {
				NSMutableArray *filteredEventIdsArray = [[NSMutableArray alloc] init];
				for (Event *event in events) {
					[filteredEventIdsArray addObject:event.serverId];
				}
				
				[Event checkGAEEventWithIds:filteredEventIdsArray];
			}
			if (ApplicationDelegate.loadingView) {
				[ApplicationDelegate.loadingView removeFromSuperview];
				ApplicationDelegate.loadingView = nil;
			}
		}
	}
}

+ (Event *) getTPEvent:(EKEvent *) ekevent {
    // Check Core Data if ical event exists (using iCalId)
    Event *tpEvent = [Event getEventWithICalId:ekevent.eventIdentifier];
    //DLog(@"event:%@ iCalId:%@ ",ekevent.title,ekevent.eventIdentifier);
    
    //If not exists check again Core Data if ical event exists (using serverId from URL)
    if (!tpEvent) {
        if (ekevent.URL) {
            NSString *URLString = [ekevent.URL absoluteString];
            NSRange start = [URLString rangeOfString:@"?"];
            if (start.length > 0){
                NSString *parametersString = [URLString substringWithRange:NSMakeRange(start.location + 1, [URLString length] - start.location - 1)];
                NSArray *parameters = [NSArray arrayWithArray:[parametersString componentsSeparatedByString:@"&"]];
                if (parameters && [parameters count] > 0) {
                    NSString *eventServerId = [[NSArray arrayWithArray:[[parameters objectAtIndex:0] componentsSeparatedByString:@"="]] objectAtIndex:1];
                    tpEvent = [Event getEventWithId:eventServerId];
                }
            }
        }
    }
    return tpEvent;
}

+ (NSString *) saveToICal:(Event *) tpEvent reminder:(float) reminderTime {
    //if I am not attending the event dont save it in iCal
    if(tpEvent.attending && ([tpEvent.attending intValue] == 0 || [tpEvent.attending intValue] == 3))
        return nil;
    
    //check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return nil;
    
    //else
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = tpEvent.title;
    event.notes = tpEvent.info;
    event.Location = [[tpEvent locationId] name];
    event.AllDay = [tpEvent.isAllDay boolValue];
    event.startDate = tpEvent.startTime;
    event.endDate = tpEvent.endTime;
	
	if ([[tpEvent recurring] intValue] > 0) {
		NSArray *daysOfWeek;
		//NSArray *daysOfMonth;
		
		int recurrence = 0;
		int interval = 1;
		switch ([[tpEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 2:
				daysOfWeek = [NSArray arrayWithObjects:
							  [EKRecurrenceDayOfWeek dayOfWeek:2],
							  [EKRecurrenceDayOfWeek dayOfWeek:3],
							  [EKRecurrenceDayOfWeek dayOfWeek:4],
							  [EKRecurrenceDayOfWeek dayOfWeek:5],
							  [EKRecurrenceDayOfWeek dayOfWeek:6],
							  nil];
				
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 3:
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 4:
				interval = 2;
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 5:
				recurrence = EKRecurrenceFrequencyMonthly;
				break;
				
			case 6:
				recurrence = EKRecurrenceFrequencyYearly;
				break;
				
			default:
				break;
		}
		
		EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:recurrence
																			  interval:interval
																		 daysOfTheWeek:daysOfWeek
																		daysOfTheMonth:nil
																	   monthsOfTheYear:nil
																		weeksOfTheYear:nil
																		 daysOfTheYear:nil
																		  setPositions:nil
																				   end:[EKRecurrenceEnd recurrenceEndWithEndDate:[tpEvent recurranceEndTime]]];
		
		[event setRecurrenceRules:[NSArray arrayWithObject:rule]];
	}
	
    //event.calendar = [eventStore defaultCalendarForNewEvents];
    event.URL = [NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]];
    
    EKCalendar *localCalendar = nil;
    for (EKCalendar *calendar in eventStore.calendars) {
        if ([calendar.title rangeOfString:@"@"].location == NSNotFound) {
            localCalendar = calendar;
            break;
        }
	}
	
    event.calendar = localCalendar;
    
    if (reminderTime > 0.0f) {
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-reminderTime];
        [event addAlarm:alarm];
    }
	
    //set calendar function works in ios 5 only
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    NSError *err;
    BOOL isSuceess = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    
    if (isSuceess) {
        return event.eventIdentifier;
    }
    else {
        debugLog(@"Could not save in iCal error : %@", [err description]);
        return nil;
    }
    
}

+ (NSString *) saveToICal:(Event *) tpEvent reminderDate:(NSDate *)reminderDate {
	
    //if I am not attending the event dont save it in iCal
    if(tpEvent.attending && ([tpEvent.attending intValue] == 0 || [tpEvent.attending intValue] == 3))
        return nil;
    
    //check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return nil;
    
    //else
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = tpEvent.title;
    event.notes = tpEvent.info;
    event.Location = [[tpEvent locationId] name];
    event.AllDay = [tpEvent.isAllDay boolValue];
    event.startDate = tpEvent.startTime;
    event.endDate = tpEvent.endTime;
    //event.calendar = [eventStore defaultCalendarForNewEvents];
	
	if ([[tpEvent recurring] intValue] > 0) {
		NSArray *daysOfWeek;
		//NSArray *daysOfMonth;
		
		int recurrence = 0;
		int interval = 1;
		switch ([[tpEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 2:
				daysOfWeek = [NSArray arrayWithObjects:
							  [EKRecurrenceDayOfWeek dayOfWeek:2],
							  [EKRecurrenceDayOfWeek dayOfWeek:3],
							  [EKRecurrenceDayOfWeek dayOfWeek:4],
							  [EKRecurrenceDayOfWeek dayOfWeek:5],
							  [EKRecurrenceDayOfWeek dayOfWeek:6],
							  nil];
				
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 3:
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 4:
				interval = 2;
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 5:
				recurrence = EKRecurrenceFrequencyMonthly;
				break;
				
			case 6:
				recurrence = EKRecurrenceFrequencyYearly;
				break;
				
			default:
				break;
		}
		
		EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:recurrence
																			  interval:interval
																		 daysOfTheWeek:daysOfWeek
																		daysOfTheMonth:nil
																	   monthsOfTheYear:nil
																		weeksOfTheYear:nil
																		 daysOfTheYear:nil
																		  setPositions:nil
																				   end:[EKRecurrenceEnd recurrenceEndWithEndDate:[tpEvent recurranceEndTime]]];
		
		[event setRecurrenceRules:[NSArray arrayWithObject:rule]];
	}
	
    event.URL = [NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]];
    
    EKCalendar *localCalendar = nil;
    for (EKCalendar *calendar in eventStore.calendars) {
        if ([calendar.title rangeOfString:@"@"].location == NSNotFound) {
            localCalendar = calendar;
            break;
        }
	}
	
    event.calendar = localCalendar;
    
	EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
	[event addAlarm:alarm];
	
    //set calendar function works in ios 5 only
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    NSError *err;
    BOOL isSuceess = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    
    if (isSuceess) {
        return event.eventIdentifier;
    }
    else {
        debugLog(@"Could not save in iCal error : %@", [err description]);
        return nil;
    }
    
}

+ (void) updateToICal:(Event *) tpEvent {
	
	//check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return;
	
	bool recurringEvent = FALSE;
	
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[event recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
	
    [event setURL:[NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]]];
    
    if(tpEvent.locationId)
        [event setLocation:[[tpEvent locationId] name]];
    
    if(tpEvent.info)
        [event setNotes:[tpEvent info]];
    
    NSError *err;
	
	if (recurringEvent) {
		[eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
	} else {
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	}
}

+ (void) updateToICal:(Event *) tpEvent reminder:(float) reminderTime {
    
	//check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return;
	
	bool recurringEvent = FALSE;
	
	EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[event recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
	
    [event setTitle:[tpEvent title]];
    [event setAllDay:[tpEvent.isAllDay boolValue]];
    [event setEndDate:[tpEvent endTime]];
    [event setStartDate:[tpEvent startTime]];
    [event setURL:[NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]]];
	
    if(tpEvent.locationId)
        [event setLocation:[[tpEvent locationId] name]];
	
    if(tpEvent.info)
        [event setNotes:[tpEvent info]];
    
    for (EKAlarm *alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
    if (reminderTime > 0.0f) {
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-reminderTime];
        [event addAlarm:alarm];
    }
    
    NSError *err;
    
	if (recurringEvent) {
		[eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
	} else {
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	}
	
}

+ (void) updateToICal:(Event *) tpEvent reminderDate:(NSDate *)reminderDate{
	
	//check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return;
	
	bool recurringEvent = FALSE;
	
	EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[event recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
	
    [event setURL:[NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]]];
	
    if(tpEvent.locationId)
        [event setLocation:[[tpEvent locationId] name]];
    
    if(tpEvent.info)
        [event setNotes:[tpEvent info]];
    
    for (EKAlarm *alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
	EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
	[event addAlarm:alarm];
    
    NSError *err;
    
	if (recurringEvent) {
		[eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
	} else {
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	}
	
}

+ (void) updateToICal:(Event *) tpEvent reminder:(float) reminderTime recurring:(BOOL)isRecur {
	
	//check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return;
	
	bool recurringEvent = FALSE;
	
	EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[event recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
	
    [event setTitle:[tpEvent title]];
    [event setAllDay:[tpEvent.isAllDay boolValue]];
    [event setEndDate:[tpEvent endTime]];
    [event setStartDate:[tpEvent startTime]];
	
	if ([[tpEvent recurring] intValue] > 0) {
		NSArray *daysOfWeek;
		//NSArray *daysOfMonth;
		
		int recurrence = 0;
		int interval = 1;
		switch ([[tpEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 2:
				daysOfWeek = [NSArray arrayWithObjects:
							  [EKRecurrenceDayOfWeek dayOfWeek:2],
							  [EKRecurrenceDayOfWeek dayOfWeek:3],
							  [EKRecurrenceDayOfWeek dayOfWeek:4],
							  [EKRecurrenceDayOfWeek dayOfWeek:5],
							  [EKRecurrenceDayOfWeek dayOfWeek:6],
							  nil];
				
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 3:
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 4:
				interval = 2;
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 5:
				recurrence = EKRecurrenceFrequencyMonthly;
				break;
				
			case 6:
				recurrence = EKRecurrenceFrequencyYearly;
				break;
				
			default:
				break;
		}
		
		EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:recurrence
																			  interval:interval
																		 daysOfTheWeek:daysOfWeek
																		daysOfTheMonth:nil
																	   monthsOfTheYear:nil
																		weeksOfTheYear:nil
																		 daysOfTheYear:nil
																		  setPositions:nil
																				   end:[EKRecurrenceEnd recurrenceEndWithEndDate:[tpEvent recurranceEndTime]]];
		
		[event setRecurrenceRules:[NSArray arrayWithObject:rule]];
	}
	
    [event setURL:[NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]]];
	
    if(tpEvent.locationId)
        [event setLocation:[[tpEvent locationId] name]];
	
    if(tpEvent.info)
        [event setNotes:[tpEvent info]];
    
    for (EKAlarm *alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
    if (reminderTime > 0.0f) {
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-reminderTime];
        [event addAlarm:alarm];
    }
    
    NSError *err;
    
	if (recurringEvent) {
		[eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
	} else {
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	}
}

+ (void) updateToICal:(Event *) tpEvent reminderDate:(NSDate *) reminderDate recurring:(BOOL)isRecur {
	
	//check settings
    NSString *path = [Utils userSettingsPath];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //if sync set to 0 return
    if (![[settingsDictionary objectForKey:@"iCal_sync"] boolValue])
        return;
	
	bool recurringEvent = FALSE;
	
	EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *event = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[event recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
	
	if ([[tpEvent recurring] intValue] > 0) {
		NSArray *daysOfWeek;
		//NSArray *daysOfMonth;
		
		int recurrence = 0;
		int interval = 1;
		switch ([[tpEvent recurring] intValue]) {
			case 0:
				break;
				
			case 1:
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 2:
				daysOfWeek = [NSArray arrayWithObjects:
							  [EKRecurrenceDayOfWeek dayOfWeek:2],
							  [EKRecurrenceDayOfWeek dayOfWeek:3],
							  [EKRecurrenceDayOfWeek dayOfWeek:4],
							  [EKRecurrenceDayOfWeek dayOfWeek:5],
							  [EKRecurrenceDayOfWeek dayOfWeek:6],
							  nil];
				
				recurrence = EKRecurrenceFrequencyDaily;
				break;
				
			case 3:
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 4:
				interval = 2;
				recurrence = EKRecurrenceFrequencyWeekly;
				break;
				
			case 5:
				recurrence = EKRecurrenceFrequencyMonthly;
				break;
				
			case 6:
				recurrence = EKRecurrenceFrequencyYearly;
				break;
				
			default:
				break;
		}
		
		EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:recurrence
																			  interval:interval
																		 daysOfTheWeek:daysOfWeek
																		daysOfTheMonth:nil
																	   monthsOfTheYear:nil
																		weeksOfTheYear:nil
																		 daysOfTheYear:nil
																		  setPositions:nil
																				   end:[EKRecurrenceEnd recurrenceEndWithEndDate:[tpEvent recurranceEndTime]]];
		
		[event setRecurrenceRules:[NSArray arrayWithObject:rule]];
	}
	
    [event setURL:[NSURL URLWithString:[NSString stringWithFormat:@"tymepass://?event-id=%@",tpEvent.serverId]]];
	
    if(tpEvent.locationId)
        [event setLocation:[[tpEvent locationId] name]];
    
    if(tpEvent.info)
        [event setNotes:[tpEvent info]];
    
    for (EKAlarm *alarm in event.alarms) {
        [event removeAlarm:alarm];
    }
    
	EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:reminderDate];
	[event addAlarm:alarm];
    
    NSError *err;
    
	if (recurringEvent) {
		[eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
	} else {
		[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
	}
	
}

+ (EKEvent *) getIcalEvent:(Event *)tpEvent {
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *ekEvent = [eventStore eventWithIdentifier:[tpEvent iCalId]];
    
    debugLog(@"Event %@", ekEvent.description);
	
    return ekEvent;
}

+ (BOOL) removeIcalEvent:(Event *)tpEvent{
	
	bool recurringEvent = FALSE;
	
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    EKEvent *ekEvent = [eventStore eventWithIdentifier:[tpEvent iCalId]];
	
	if ([[ekEvent recurrenceRules] count]) {
		recurringEvent = TRUE;
	}
    
    debugLog(@"Event %@", ekEvent.description);
	
    NSError *err;
    BOOL success;
    
	if (recurringEvent) {
		success = [eventStore removeEvent:ekEvent span:EKSpanFutureEvents commit:YES error:&err];
	} else {
		success = [eventStore removeEvent:ekEvent span:EKSpanThisEvent commit:YES error:&err];
	}
	
    return success;
}

@end
