//
//  InvitationEngine.m
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvitationEngine.h"
#import "SBJson.h"
#import "GAEUtils.h"

@implementation InvitationEngine

-(MKNetworkOperation*) requestInvitationsCountOfUser:(User *) user
										onCompletion:(InvitationResponseBlock) completionBlock
											 onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getNotificationsCount"
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
         //debugLog(@"notifications string %@", [completedOperation responseString] );
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}


-(MKNetworkOperation*) requestInvitationsOfUser:(User *) user
								   onCompletion:(InvitationResponseBlock) completionBlock
										onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getNotifications"
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
         //debugLog(@"notifications string %@", [completedOperation responseString] );
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) readInvitationsOfUser:(User *) user
								invitationId:(NSString *) invitationId
								onCompletion:(InvitationResponseBlock) completionBlock
									 onError:(MKNKErrorBlock) errorBlock {
	
	NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
	[jsonObject setObject:invitationId forKey:@"invitationId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"readNotifications"
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
         //debugLog(@"notifications string %@", [completedOperation responseString] );
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) requestObjectOfEvent:(Event *) event
                                 objectType:(NSString *) type
                               onCompletion:(InvitationResponseBlock) completionBlock
                                    onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[event serverId] forKey:@"id"];
	[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
    
    NSString *path;
	
    if ([type isEqualToString:@"attendees"]) {
        path = @"getAttendees";
    } else if ([type isEqualToString:@"invitees"])
        path = @"getInvitees";
	else if ([type isEqualToString:@"attendeesCount"])
        path = @"eventAttendeesCount";
	else if ([type isEqualToString:@"maybe"])
        path = @"getMaybe";
	else if ([type isEqualToString:@"attendeesLimited"]) {
        path = @"getAttendees";
		[jsonObject setObject:[NSNumber numberWithInt:15] forKey:@"limit"];
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
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) sendUserInvitesFrom:(User* ) fromUser
                                   ToUsers:(NSArray *) usersToArray
                                    OfType:(NSString *) invitationType
                               stealthMode:(NSNumber *) stealthMode
                                  forEvent:(NSString *) eventId {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *toUsers = [NSMutableDictionary dictionary];
    for(NSArray * object in usersToArray){
        [toUsers setValue:[object valueForKey:@"key"] forKey:[object valueForKey:@"key"]];
    }
    
    [jsonObject setObject:toUsers forKey:@"toUsers"];
    [jsonObject setObject:[fromUser serverId] forKey:@"fromUser"];
    [jsonObject setObject:invitationType forKey:@"type"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:[NSDate date]] forKey:@"dateCreated"];
	
    if (eventId) {
        [jsonObject setObject:eventId forKey:@"eventId"];
        [jsonObject setObject:stealthMode forKey:@"stealth"];
    }
    
    MKNetworkOperation *op = [self operationWithPath:@"invitation"
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

// send invitations to the multiple events at the same time
-(MKNetworkOperation*) sendUserInvitesFrom:(User* ) fromUser
                                   ToUsers:(NSArray *) usersToArray
                                    OfType:(NSString *) invitationType
                               stealthMode:(NSNumber *) stealthMode
							  forEventDict:(NSMutableDictionary *) eventDict {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *toUsers = [NSMutableDictionary dictionary];
    for(NSArray * object in usersToArray) {
        [toUsers setValue:[object valueForKey:@"key"] forKey:[object valueForKey:@"key"]];
    }
    
    [jsonObject setObject:toUsers forKey:@"toUsers"];
    [jsonObject setObject:[fromUser serverId] forKey:@"fromUser"];
    [jsonObject setObject:invitationType forKey:@"type"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:[NSDate date]] forKey:@"dateCreated"];
	
	[jsonObject setObject:eventDict forKey:@"eventIds"];
	[jsonObject setObject:stealthMode forKey:@"stealth"];
    
    MKNetworkOperation *op = [self operationWithPath:@"invitation"
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

@end