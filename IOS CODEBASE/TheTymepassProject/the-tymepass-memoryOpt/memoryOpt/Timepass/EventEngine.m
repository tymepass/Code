	//
//  EventEngine.m
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventEngine.h"
#import "SBJson.h"
#import "GAEUtils.h"
#import "NSDataAdditions.h"
#import "Utils.h"
#import "Location+Management.h"
#import "Event+GAE.h"
#import "JSONKit.h"

@implementation EventEngine

-(MKNetworkOperation*) requestObjectOfEvent:(Event *) event
                                 objectType:(NSString *) type
                               onCompletion:(EventResponseBlock) completionBlock
                                    onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[event serverId] forKey:@"id"];
    
    NSString *path;
    
    if ([type isEqualToString:@"messages"]) {
        path = @"getMessagesForEvent";
        
        [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    }
    
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         //completionBlock([completedOperation responseJSON];];
         completionBlock([[completedOperation responseData] objectFromJSONData]);
         //debugLog(@"event message answer : %@", [completedOperation responseData]);
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) requestStealthFromForEvent:(Event *) event
									 onCompletion:(EventResponseBlock) completionBlock
										  onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    [jsonObject setObject:[event serverId] forKey:@"eventId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getStealthFrom"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) insertGAEEventWithEvents:(NSMutableArray *) insertEvents
								   onCompletion:(EventResponseBlock) completionBlock
										onError:(MKNKErrorBlock) errorBlock {
	
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	
	for (Event *event in insertEvents) {
		
		NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
		
		NSString *startTime = [GAEUtils formatDateForGAE:event.startTime];
		NSString *endTime = [GAEUtils formatDateForGAE:event.endTime];
		NSString *dateModified = [GAEUtils formatDateForGAE:event.dateModified];
		NSString *createTime = [GAEUtils formatDateForGAE:[NSDate date]];
		[jsonObject setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"stealth"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"attending"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isAllDay intValue]] forKey:@"isAllDay"];
		
		if (event.locationId)
			[jsonObject setObject:[event.locationId name] forKey:@"location"];
		else
			[jsonObject setObject:@"" forKey:@"location"];
		
		[jsonObject setObject:[event.creatorId serverId] forKey:@"creatorId"];
		
		if ([event.messageId anyObject])
			[jsonObject setObject:[(EventMessage *)[event.messageId anyObject] text] forKey:@"message"];
		else
			[jsonObject setObject:@"" forKey:@"message"];
		
		[jsonObject setObject:event.title forKey:@"title"];
		
		if(event.info)
			[jsonObject setObject:event.info forKey:@"info"];
		else
			[jsonObject setObject:@"..." forKey:@"info"];
		
		[jsonObject setObject:[NSString stringWithFormat:@"%d", [event.recurring intValue]] forKey:@"recurring"];
		
		if ([event.recurring intValue] > 0) {
			if (event.recurranceEndTime != nil) {
				NSString *recurringEndTime = [GAEUtils formatDateForGAE:event.recurranceEndTime];
				[jsonObject setObject:recurringEndTime forKey:@"recurringEndTime"];
			}
		}
		
		NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
		NSDate* sourceDate = [NSDate date];
		NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
		[jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timezone"];
		
		[jsonObject setObject:event.reminder forKey:@"reminder"];
		
		if ([event.reminder intValue] == 1 && event.reminderDate != nil) {
			[jsonObject setObject:[GAEUtils formatDateForGAE:event.reminderDate] forKey:@"reminderDate"];
		}
		
		float reminderTime;
		switch ([event.reminder intValue]) {
			case 0:
				reminderTime = 0.0f;
				break;
			case 1: {
				NSTimeInterval t1 = [event.startTime timeIntervalSince1970];
				NSTimeInterval t2 = [event.reminderDate timeIntervalSince1970];
				reminderTime = (float)t1 - t2;
				break;
			}
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
		
		[jsonObject setObject:[NSNumber numberWithFloat:reminderTime] forKey:@"reminderTime"];
		
		[jsonObject setObject:endTime forKey:@"endTime"];
		[jsonObject setObject:startTime forKey:@"startTime"];
		[jsonObject setObject:dateModified forKey:@"dateModified"];
		[jsonObject setObject:createTime forKey:@"dateCreated"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isPrivate intValue]] forKey:@"isPrivate"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isTymePassEvent intValue]] forKey:@"isTymePassEvent"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isOpen intValue]] forKey:@"isOpen"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isGold intValue]] forKey:@"isGold"];
		[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isEditable intValue]] forKey:@"isEditable"];
		[jsonObject setObject:[NSString stringWithFormat:@"%@",event.iCalId] forKey:@"iCalId"];
		
		if (event.photo) {
			[jsonObject setObject:event.photo forKey:@"photo"];
		}
		
		[finalArray addObject:jsonObject];
	}
	
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	[request setObject:finalArray forKey:@"syncData"];
    
    MKNetworkOperation *op = [self operationWithPath:@"syncNewEvent"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:request error:&error];
        
		return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
	 {
         NSArray *events = [[completedOperation responseJSON] objectAtIndex:0];
		 completionBlock(events);
		 
     } onError:^(NSError* error) {
         errorBlock(error);
         [modelUtils rollbackDefaultMOC];
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) insertGAEEventWithEvent:(Event *) event
                                  onCompletion:(EventManagementResponseBlock) completionBlock
                                       onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    NSString *startTime = [GAEUtils formatDateForGAE:event.startTime];
    NSString *endTime = [GAEUtils formatDateForGAE:event.endTime];
    NSString *dateModified = [GAEUtils formatDateForGAE:event.dateModified];
    NSString *createTime = [GAEUtils formatDateForGAE:[NSDate date]];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isPrivate intValue]] forKey:@"stealth"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"attending"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isAllDay intValue]] forKey:@"isAllDay"];
    
    if (event.locationId)
        [jsonObject setObject:[event.locationId name] forKey:@"location"];
    else
        [jsonObject setObject:@"" forKey:@"location"];
    
    [jsonObject setObject:[event.creatorId serverId] forKey:@"creatorId"];
    
    if ([event.messageId anyObject])
        [jsonObject setObject:[(EventMessage *)[event.messageId anyObject] text] forKey:@"message"];
    else
        [jsonObject setObject:@"" forKey:@"message"];
    
    [jsonObject setObject:event.title forKey:@"title"];
    
    if(event.info)
        [jsonObject setObject:event.info forKey:@"info"];
    else
        [jsonObject setObject:@"..." forKey:@"info"];
    
    [jsonObject setObject:[NSString stringWithFormat:@"%d", [event.recurring intValue]] forKey:@"recurring"];
	
	if ([event.recurring intValue] > 0) {
		if (event.recurranceEndTime != nil) {
			NSString *recurringEndTime = [GAEUtils formatDateForGAE:event.recurranceEndTime];
			[jsonObject setObject:recurringEndTime forKey:@"recurringEndTime"];
		}
	}
	
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSDate* sourceDate = [NSDate date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    [jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timezone"];
	
	[jsonObject setObject:event.reminder forKey:@"reminder"];
	
	if ([event.reminder intValue] == 1 && event.reminderDate != nil) {
		[jsonObject setObject:[GAEUtils formatDateForGAE:event.reminderDate] forKey:@"reminderDate"];
	}
	
	float reminderTime;
    switch ([event.reminder intValue]) {
        case 0:
            reminderTime = 0.0f;
            break;
		case 1: {
			NSTimeInterval t1 = [event.startTime timeIntervalSince1970];
			NSTimeInterval t2 = [event.reminderDate timeIntervalSince1970];
			reminderTime = (float)t1 - t2;
			break;
		}
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
	
	[jsonObject setObject:[NSNumber numberWithFloat:reminderTime] forKey:@"reminderTime"];
	
    [jsonObject setObject:endTime forKey:@"endTime"];
    [jsonObject setObject:startTime forKey:@"startTime"];
    [jsonObject setObject:dateModified forKey:@"dateModified"];
    [jsonObject setObject:createTime forKey:@"dateCreated"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isPrivate intValue]] forKey:@"isPrivate"];
	[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isTymePassEvent intValue]] forKey:@"isTymePassEvent"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isOpen intValue]] forKey:@"isOpen"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isGold intValue]] forKey:@"isGold"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isEditable intValue]] forKey:@"isEditable"];
    [jsonObject setObject:[NSString stringWithFormat:@"%@",event.iCalId] forKey:@"iCalId"];
	
    //debugLog(@"%@", [jsonObject objectForKey:@"iCalId"]);
    
    if (event.photoData) {
        [jsonObject setObject:[event.photoData base64Encoding] forKey:@"photo"];
    }
    
    MKNetworkOperation *op = [self operationWithPath:@"newEvent"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
	 {
         NSDictionary *status = [[completedOperation responseJSON] objectAtIndex:0];
         NSString *serverId = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"id"]];
		 NSString *photo = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"photo"]];
		 
		 [event setServerId:serverId];
		 [event setPhoto:photo];
		 
		 NSArray *childIds = [status objectForKey:@"chield"];
		 
		 //DLog(@"%@", [completedOperation responseString]);
		 
		 if ([event.recurring intValue] > 0 && [childIds count] > 0) {
			 [Event addRecurringEvent:event serverIds:childIds];
		 }
		 
		 completionBlock(serverId);
     } onError:^(NSError* error) {
         errorBlock(error);
         [modelUtils rollbackDefaultMOC];
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) updateGAEEventWithEvent:(Event *) event
                                  onCompletion:(EventManagementResponseBlock) completionBlock
                                       onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *startTime = [df stringFromDate:event.startTime];
    NSString *endTime = [df stringFromDate:event.endTime];
    NSString *dateModified = [df stringFromDate:event.dateModified];
    
    [jsonObject setObject:startTime forKey:@"startTime"];
    [jsonObject setObject:endTime forKey:@"endTime"];
    [jsonObject setObject:event.title forKey:@"title"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d", [event.recurring intValue]] forKey:@"recurring"];
	
	[jsonObject setObject:event.reminder forKey:@"reminder"];
	
	if ([event.reminder intValue] == 1 && event.reminderDate != nil) {
		[jsonObject setObject:[GAEUtils formatDateForGAE:event.reminderDate] forKey:@"reminderDate"];
	}
	
	float reminderTime = 0.0;
    switch ([event.reminder intValue]) {
        case 0:
            reminderTime = 0.0f;
            break;
		case 1: {
			NSTimeInterval t1 = [event.startTime timeIntervalSince1970];
			NSTimeInterval t2 = [event.reminderDate timeIntervalSince1970];
			reminderTime = t1 - t2;
		}
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
            break;
    }
	
	[jsonObject setObject:[NSNumber numberWithFloat:reminderTime] forKey:@"reminderTime"];
	
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSDate* sourceDate = [NSDate date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    [jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timezone"];
	
	if ([event.recurring intValue] > 0) {
		NSString *recurringEndTime = [df stringFromDate:event.recurranceEndTime];
		[jsonObject setObject:recurringEndTime forKey:@"recurringEndTime"];
	}
	
	[jsonObject setObject:[NSString stringWithFormat:@"%d", [event.saveCurrentEvent intValue]] forKey:@"saveCurrentEventOnly"];
    
    if(event.info)
        [jsonObject setObject:event.info forKey:@"info"];
    else
        [jsonObject setObject:@"..." forKey:@"info"];
    
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"id"];
    [jsonObject setObject:dateModified forKey:@"dateModified"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isAllDay intValue]] forKey:@"isAllDay"];
    
	if (event.parentServerId) {
		[jsonObject setObject:event.parentServerId forKey:@"parentServerId"];
	} else {
		[jsonObject setObject:@"0" forKey:@"parentServerId"];
	}
	
    //[jsonObject setObject:[NSString stringWithFormat:@"%d",event.isEditable] forKey:@"isEditable"];
    
    if (event.locationId)
        [jsonObject setObject:[event.locationId name] forKey:@"location"];
    else
        [jsonObject setObject:@"" forKey:@"location"];
    
    [jsonObject setObject:event.serverId forKey:@"serverId"];
	[jsonObject setObject:[NSString stringWithFormat:@"%d", [event.attending intValue]] forKey:@"attending"];
	[jsonObject setObject:[NSString stringWithFormat:@"%d", [event.isPrivate intValue]] forKey:@"isPrivate"];
	[jsonObject setObject:[NSString stringWithFormat:@"%d", [event.isOpen intValue]] forKey:@"isOpen"];
	[jsonObject setObject:[NSString stringWithFormat:@"%d",[event.isGold intValue]] forKey:@"isGold"];
	
    if (event.photoData && [event.photoChange intValue] > 0)
        [jsonObject setObject:[event.photoData base64Encoding] forKey:@"photo"];
    
    MKNetworkOperation *op = [self operationWithPath:@"editEvent"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
		
		NSDictionary *status = [[completedOperation responseJSON] objectAtIndex:0];
		NSString *result = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"id"]];
		
		NSString *photo = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"photo"]];
		[event setPhoto:photo];
		[modelUtils commitDefaultMOC];
		
		if ([event.saveCurrentEvent intValue] == 0) {
			NSArray *childIds = [status objectForKey:@"chield"];
			[Event updateRecurringEvent:event serverIds:childIds];
		}
		
		completionBlock(result);
		
	} onError:^(NSError* error) {
		errorBlock(error);
		[modelUtils rollbackDefaultMOC];
	}];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeEvent:(Event *) event
                            ofUser:(NSString *) userToId
                   attendingStatus:(NSNumber *) status
                       stealthMode:(NSNumber *) stealthMode
                      onCompletion:(EventChangeResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    if(event.invitedBy)
        [jsonObject setObject:[event.invitedBy serverId] forKey:@"userFromId"];
    else {
        //event that the user has created has nil invitedBy value
        [jsonObject setObject:userToId forKey:@"userFromId"];
    }
    [jsonObject setObject:userToId forKey:@"userToId"];
	[jsonObject setObject:event.serverId forKey:@"eventId"];
	
    [jsonObject setObject:status forKey:@"status"];
    [jsonObject setObject:stealthMode forKey:@"stealth"];
    //[jsonObject setObject:event.iCalId forKey:@"iCalId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"editEventView"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *status = [[completedOperation responseJSON] objectAtIndex:0];
         completionBlock(status);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeEvent:(Event *) event
                            ofUser:(NSString *) userToId
                   attendingStatus:(NSNumber *) status
                       stealthMode:(NSNumber *) stealthMode
							isGold:(NSNumber *) isGold
                      onCompletion:(EventChangeResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    if(event.invitedBy)
        [jsonObject setObject:[event.invitedBy serverId] forKey:@"userFromId"];
    else {
        //event that the user has created has nil invitedBy value
        [jsonObject setObject:userToId forKey:@"userFromId"];
    }
    
	[jsonObject setObject:userToId forKey:@"userToId"];
	[jsonObject setObject:event.serverId forKey:@"eventId"];
	
	[event setAttending:status];
	[event setIsPrivate:stealthMode];
	[event setIsGold:isGold];
	
    [jsonObject setObject:status forKey:@"status"];
    [jsonObject setObject:stealthMode forKey:@"stealth"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[isGold intValue]] forKey:@"isGold"];
    
    MKNetworkOperation *op = [self operationWithPath:@"editEventView"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *status = [[completedOperation responseJSON] objectAtIndex:0];         
         completionBlock(status);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeEvent:(Event *) event
                            ofUser:(NSString *) userToId
                   attendingStatus:(NSNumber *) status
							isGold:(NSNumber *) isGold
                      onCompletion:(EventChangeResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    if(event.invitedBy)
        [jsonObject setObject:[event.invitedBy serverId] forKey:@"userFromId"];
    else {
        //event that the user has created has nil invitedBy value
        [jsonObject setObject:userToId forKey:@"userFromId"];
    }
    
	[jsonObject setObject:userToId forKey:@"userToId"];
	[jsonObject setObject:event.serverId forKey:@"eventId"];
	
    [jsonObject setObject:status forKey:@"status"];
    [jsonObject setObject:[NSString stringWithFormat:@"%d",[isGold intValue]] forKey:@"isGold"];
    
    MKNetworkOperation *op = [self operationWithPath:@"changeEventParams"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *status = [[completedOperation responseJSON] objectAtIndex:0];
         completionBlock(status);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeICalEvent:(Event *) event
                                ofUser:(NSString *) userToId {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    if(event.invitedBy)
        [jsonObject setObject:[event.invitedBy serverId] forKey:@"userFromId"];
    else {
        //event that the user has created has nil invitedBy value
        [jsonObject setObject:userToId forKey:@"userFromId"];
    }
    [jsonObject setObject:userToId forKey:@"userToId"];
    [jsonObject setObject:event.serverId forKey:@"eventId"];
    
    if (event.iCalId)
        [jsonObject setObject:event.iCalId forKey:@"iCalId"];
    else
        [jsonObject setObject:@"" forKey:@"iCalId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"editEventICalId"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
		 DLog(@"%@", completedOperation);
         
     } onError:^(NSError* error) {
		 DLog(@"%@", error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeICalEvents:(NSMutableArray *) updateEvents
								 ofUser:(NSString *) userToId {
	
	NSMutableArray *finalArray = [[NSMutableArray alloc] init];
	
	for (Event *event in updateEvents) {
		NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
		if(event.invitedBy)
			[jsonObject setObject:[event.invitedBy serverId] forKey:@"userFromId"];
		else {
			//event that the user has created has nil invitedBy value
			[jsonObject setObject:userToId forKey:@"userFromId"];
		}
		[jsonObject setObject:userToId forKey:@"userToId"];
		[jsonObject setObject:event.serverId forKey:@"eventId"];
		
		if (event.iCalId)
			[jsonObject setObject:event.iCalId forKey:@"iCalId"];
		else
			[jsonObject setObject:@"" forKey:@"iCalId"];

		[finalArray addObject:jsonObject];
	}
	
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	[request setObject:finalArray forKey:@"syncData"];
    
    MKNetworkOperation *op = [self operationWithPath:@"syncEditEventICalId"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:request error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
		 DLog(@"%@", completedOperation);
         
     } onError:^(NSError* error) {
		 DLog(@"%@", error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) getEventsByDate:(NSString *) seekerId
                                  user:(NSString *) userId
                              dateFrom:(NSDate *) dateFrom
                                dateTo:(NSDate *) dateTo
                          onCompletion:(EventResponseArrayBlock) completionBlock
                               onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"seekerId"];
    [jsonObject setObject:userId forKey:@"userId"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:dateFrom] forKey:@"dateFrom"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:dateTo] forKey:@"dateTo"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getEventsByDate"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         NSString *responseString = [[NSString alloc] initWithData:[completedOperation responseData] encoding:NSUTF8StringEncoding];
         
         SBJsonParser *parser = [[SBJsonParser alloc] init];
         
         NSArray *responseData = [parser objectWithString:responseString error:nil];
         NSArray *listItems = [[responseData objectAtIndex:0] valueForKey:@"entities"];
         
         //parse to array of dictionarys
         NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
         NSManagedObjectContext *context = [[Utils sharedUtilsInstance] scratchPad];
         
         for (NSMutableDictionary *dict in listItems) {
             Location *newLocation;
             
             if ([[dict objectForKey:@"locations"] count] > 0) {
                 NSString *locationText = [NSString stringWithFormat:@"%@",[[[dict valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
                 
                 newLocation = [Location getLocationWithName:locationText inContext:context];
                 
                 if (!newLocation) {
                     newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
                 }
             }
             
             //[dict setObject:newLocation forKey:@"location"];
             [dict setValue:newLocation forKey:@"location"];
             
             User *creatorUser = [User getUserWithId:[dict valueForKey:@"creator"] inContext:context];
             [dict setValue:creatorUser forKey:@"creator"];
             
             NSString *attendingStatus;
             if ([dict objectForKey:@"attending"])
                 attendingStatus = [dict objectForKey:@"attending"];
             else
                 attendingStatus = @"confirmed";
             [dict setValue:[NSString stringWithFormat:@"%d",[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
			 
			 NSLog(@"event %@ attending %d", [dict valueForKey:@"title"], [[dict objectForKey:@"attending"] intValue]);
             
             Event *eventObj = [Event createEventFromDictionary:dict inContext:context];
             [eventsArray addObject:eventObj];
         }
         
         completionBlock(eventsArray);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) sendMessageToGAE:(EventMessage *) message {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *encodedMessageString = [Utils urlEncodedAndEmojiConverion:[message text]];
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:encodedMessageString forKey:@"message"];
    [jsonObject setObject:[[message userId] serverId] forKey:@"creatorId"];
    [jsonObject setObject:[[message eventId] serverId] forKey:@"eventId"];
    [jsonObject setObject:[df stringFromDate:message.dateCreated] forKey:@"dateCreated"];
	
    MKNetworkOperation *op = [self operationWithPath:@"newMessageForEvent"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         DLog(@"%@", completedOperation);
         
     } onError:^(NSError* error) {
         DLog(@"%@", error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) setEvent:(Event *) event PrivateFrom:(NSArray *) ids {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    [jsonObject setObject:event.serverId forKey:@"eventId"];
    
    NSDictionary *idsDict = [NSDictionary dictionaryWithObjects:ids forKeys:ids];
    [jsonObject setObject:idsDict forKey:@"users"];
    
    MKNetworkOperation *op = [self operationWithPath:@"privateFrom"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         DLog(@"%@", completedOperation);
         
     } onError:^(NSError* error) {
         DLog(@"%@", error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) changeEventStatus:(NSMutableArray *) evertIds
						 attendingStatus:(NSNumber *) status
							onCompletion:(EventManagementResponseBlock) completionBlock
								 onError:(MKNKErrorBlock) errorBlock {
	
	NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
	
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    
    NSDictionary *idsDict = [NSDictionary dictionaryWithObjects:evertIds forKeys:evertIds];
    [jsonObject setObject:idsDict forKey:@"ids"];
	
	[jsonObject setObject:status forKey:@"attending"];
    
    MKNetworkOperation *op = [self operationWithPath:@"setInvitationRSVP"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        
        //DLog(@"jsonString %@", jsonString);
        
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
     {
         completionBlock(completedOperation);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;

}

@end