	//
//  UserEngine.m
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserEngine.h"
#import "SBJson.h"
#import "GAEUtils.h"
#import "Utils.h"
#import "UAirship.h"
#import "NSDataAdditions.h"
#import "User+Management.h"

@implementation UserEngine

-(MKNetworkOperation*) requestObjectOfUser:(User *) user
                                objectType:(NSString *) type
                              onCompletion:(UserResponseBlock) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
	
    NSString *path;
    
    if ([type isEqualToString:@"friends"]) {
        
		path = @"getfriends";
		
	} else if ([type isEqualToString:@"friendsForMessage"]) {
     
		path = @"getFriendsForMessage";
		
    } else if ([type isEqualToString:@"newsReel"]) {
        
		//path = @"getNewsreelNew";
		path = @"getUserNotifications";
		if (![[user serverId] isEqualToString:[[[SingletonUser sharedUserInstance] user] serverId]]) {
			path = @"getUserNotifications";
		}
		
	} else if ([type isEqualToString:@"newsReelPage"]) {
		
		path = @"getNewsreelNew";
		
	} else if([type isEqualToString:@"messages"]) {
		
		path = @"get-chat";
		[jsonObject setObject:[user serverId] forKey:@"toUser"];
		[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"fromUser"];
		
	} else if([type isEqualToString:@"goldEvents"]) {
		
		path = @"getGoldEvents";
		[jsonObject setObject:[user serverId] forKey:@"userId"];
		
	} else if([type isEqualToString:@"unreadMessageCount"]) {
		
		path = @"chat-count";
		
	} else if([type isEqualToString:@"getFriendship"]) {
		
		path = @"getFriendship";
		[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"userId"];
		[jsonObject setObject:[user serverId] forKey:@"FriendId"];
		
	} else if([type isEqualToString:@"pendingEventCount"]) {
		
		path = @"pendingEventCount";
		
	}
    
    MKNetworkOperation *op = [self operationWithPath:path
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
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) requestObjectOfUser:(User *) user
                                objectType:(NSString *) type
									offset:(NSInteger)offset
                              onCompletion:(UserResponseBlock) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock {
	NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
	
    NSString *path;
    
    if ([type isEqualToString:@"friends"])
        path = @"getfriends";
    else if ([type isEqualToString:@"newsReel"]) {
        path = @"getNewsreel";
		
		if (![[user serverId] isEqualToString:[[[SingletonUser sharedUserInstance] user] serverId]]) {
			path = @"getUserNotifications";
		}
		
	} else if([type isEqualToString:@"messages"]) {
		path = @"get-chat";
		
		[jsonObject setObject:[user serverId] forKey:@"toUser"];
		[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"fromUser"];
	} else if([type isEqualToString:@"goldEvents"]) {
		
		path = @"getGoldEvents";
		[jsonObject setObject:[user serverId] forKey:@"userId"];
		[jsonObject setObject:[NSNumber numberWithInteger:offset] forKey:@"startwith"];
		[jsonObject setObject:[NSNumber numberWithInt:50] forKey:@"limit"];
		
	} else if([type isEqualToString:@"unreadMessageCount"]) {
		path = @"chat-count";
	} else if ([type isEqualToString:@"getEventsByDate"]) {
		
		path = @"getEventsByDate";
		[jsonObject setObject:[user serverId] forKey:@"userId"];
		[jsonObject setObject:[NSNumber numberWithInteger:offset] forKey:@"startwith"];
		[jsonObject setObject:[NSNumber numberWithInt:50] forKey:@"limit"];
	}
    
    MKNetworkOperation *op = [self operationWithPath:path
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
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) requestUpcomingEventsOfUser:(NSString *) userId
                                            seeker:(NSString *) seekerId
                                      onCompletion:(UserResponseBlock) completionBlock
                                           onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:userId forKey:@"userId"];
    [jsonObject setObject:seekerId forKey:@"seekerId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getFutureEvents"
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

-(MKNetworkOperation*) updateGAEUserWithUser:(User *) user
								onCompletion:(UserManagementResponseBlock) completionBlock
									 onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:user.serverId forKey:@"serverId"];
    [jsonObject setObject:user.name forKey:@"name"];
    [jsonObject setObject:user.email forKey:@"email"];
    
    NSString *sSex = [NSString stringWithFormat:@"%d", [user.gender intValue]];
    [jsonObject setObject:sSex forKey:@"gender"];
    
    if (user.occupation)
        [jsonObject setObject:user.occupation forKey:@"occupation"];
    else
        [jsonObject setObject:@"" forKey:@"occupation"];
    
    //[jsonObject setObject:user.facebookId forKey:@"facebookId"];
    
    if ([user.facebookId isEqualToString:@"-1"])
        [jsonObject setObject:user.password forKey:@"password"];
    
    if (user.surname)
        [jsonObject setObject:user.surname forKey:@"surname"];
    else
        [jsonObject setObject:@"" forKey:@"surname"];
    
    if (user.homeLocationId)
        [jsonObject setObject:user.homeLocationId.name forKey:@"location"];
    else
        [jsonObject setObject:@"" forKey:@"location"];
    
    if ([[UAirship shared] deviceToken])
        [jsonObject setObject:[[UAirship shared] deviceToken] forKey:@"deviceId"];
    else
        [jsonObject setObject:@"00000000" forKey:@"deviceId"];
    
    if(user.photoData)
        [jsonObject setObject:[user.photoData base64Encoding] forKey:@"photo"];
    
    if (user.dateOfBirth)
        [jsonObject setObject:[GAEUtils formatDateForGAE:user.dateOfBirth] forKey:@"dateOfBirth"];
    else
        [jsonObject setObject:@"" forKey:@"dateOfBirth"];
    
    [jsonObject setObject:[GAEUtils formatDateForGAE:[NSDate date]] forKey:@"dateModified"];
    
    MKNetworkOperation *op = [self operationWithPath:@"editUser"
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
         NSString *result = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"id"]];
		 NSString *photo = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"photo"]];
		 
		 user.photo = photo;
		 [modelUtils commitDefaultMOC];
		 
         completionBlock(result);
         
     } onError:^(NSError* error) {
         errorBlock(error);
         [modelUtils rollbackDefaultMOC];
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) checkGAEUserWithEmail:(NSString *)email
                                onCompletion:(UserManagementResponseBlock) completionBlock
                                     onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:email forKey:@"email"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getuser"
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
         NSDictionary *responseDict = [[completedOperation responseJSON] objectAtIndex:0];
         NSArray *userList = [responseDict objectForKey:@"user"];
         
         NSString *result = @"0";
         
         if ([userList count] > 0)
             result = @"1";
		 
         completionBlock(result);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) sendPasswordRecoveryRequest:(NSString *)email
									  onCompletion:(UserManagementResponseBlock) completionBlock
										   onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:email forKey:@"email"];
    
    MKNetworkOperation *op = [self operationWithPath:@"sendPasswordrecovery"
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
         NSDictionary *responseDict = [[completedOperation responseJSON] objectAtIndex:0];
         NSDictionary *userList = [responseDict objectForKey:@"user"];
         
         NSString *result = @"0";
         
         if ([userList valueForKey:@"success"] != nil)
             result = @"1";
		 
         completionBlock(result);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) checkGAEUserWithTwitterId:(NSString *)twitterId
									onCompletion:(UserManagementResponseBlock) completionBlock
										 onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:twitterId forKey:@"twitterId"];
    
    MKNetworkOperation *op = [self operationWithPath:@"getUserByTwitter"
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
         NSDictionary *responseDict = [[completedOperation responseJSON] objectAtIndex:0];
         NSArray *userList = [responseDict objectForKey:@"user"];
         
         NSString *result = @"0";
         
         if ([userList count] > 0)
             result = @"1";
         
         completionBlock(result);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) insertGAEUserWithUser:(User *) user
                                onCompletion:(UserManagementResponseBlock) completionBlock
                                     onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:user.name forKey:@"name"];
    
    if (user.surname)
        [jsonObject setObject:user.surname forKey:@"surname"];
    else
        [jsonObject setObject:@"" forKey:@"surname"];
    
    [jsonObject setObject:user.email forKey:@"email"];
    
    if (user.dateOfBirth)
        [jsonObject setObject:[GAEUtils formatDateForGAE:user.dateOfBirth] forKey:@"dateOfBirth"];
    else
        [jsonObject setObject:@"" forKey:@"dateOfBirth"];
	
    NSString *sSex = [NSString stringWithFormat:@"%d", [user.gender intValue]];
    [jsonObject setObject:sSex forKey:@"gender"];
    
    if (user.occupation)
        [jsonObject setObject:user.occupation forKey:@"occupation"];
    else
        [jsonObject setObject:@"" forKey:@"occupation"];
    
    if (user.homeLocationId)
        [jsonObject setObject:user.homeLocationId.name forKey:@"location"];
    else
        [jsonObject setObject:@"" forKey:@"location"];
    
    if (user.facebookId)
        [jsonObject setObject:user.facebookId forKey:@"facebookId"];
    else
        [jsonObject setObject:@"-1" forKey:@"facebookId"];
    
    if (user.twitterId)
        [jsonObject setObject:user.twitterId forKey:@"twitterId"];
    else
        [jsonObject setObject:@"-1" forKey:@"twitterId"];
    
    if(user.password)
        [jsonObject setObject:user.password forKey:@"password"];
    else
        [jsonObject setValue:@"-1" forKey:@"password"];
    
    if ([[UAirship shared] deviceToken])
        [jsonObject setObject:[[UAirship shared] deviceToken] forKey:@"deviceId"];
    else
        [jsonObject setObject:@"00000000" forKey:@"deviceId"];
    
    if(user.photoData)
        [jsonObject setObject:[user.photoData base64Encoding] forKey:@"photo"];
	
	[jsonObject setObject:[NSNumber numberWithInt:1] forKey:@"iCallSync"];
    
    [jsonObject setObject:[GAEUtils formatDateForGAE:[NSDate date]] forKey:@"dateCreated"];
    [jsonObject setObject:[GAEUtils formatDateForGAE:[NSDate date]] forKey:@"dateModified"];
    
    MKNetworkOperation *op = [self operationWithPath:@"newuser"
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
         NSString *result = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"id"]];
         
         completionBlock(result);
         
     } onError:^(NSError* error) {
         errorBlock(error);
         [modelUtils rollbackDefaultMOC];
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) checkEmails:(NSDictionary *) emailDictionary
                      onCompletion:(UserResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:emailDictionary forKey:@"emails"];
    
    MKNetworkOperation *op = [self operationWithPath:@"emails"
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

-(MKNetworkOperation*) checkFacebookIds:(NSDictionary *) facebookIdDictionry
						  onCompletion:(UserResponseBlock) completionBlock
							   onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:facebookIdDictionry forKey:@"facebookIds"];
    
    MKNetworkOperation *op = [self operationWithPath:@"checkFacebookIds"
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

-(MKNetworkOperation*) checkTwitterIds:(NSDictionary *) twitterIdDictionry
						  onCompletion:(UserResponseBlock) completionBlock
							   onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:twitterIdDictionry forKey:@"twitterIds"];
    
    MKNetworkOperation *op = [self operationWithPath:@"twitters"
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

-(MKNetworkOperation*) updateNotifications:(NSDictionary *) dict
							  onCompletion:(UserManagementResponseBlock) completionBlock
								   onError:(MKNKErrorBlock) errorBlock {
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"serverId"];
	[jsonObject setObject:[dict objectForKey:@"iCal_sync"] forKey:@"iCallSync"];
    
    MKNetworkOperation *op = [self operationWithPath:@"userSettings"
                                              params:nil
                                          httpMethod:@"POST"];
    
    [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        NSError *error;
        NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
        return jsonString;
    } forType:@"application/json"];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
		completionBlock([completedOperation responseJSON]);
	} onError:^(NSError* error) {
		errorBlock(error);
	}];
    
    [self enqueueOperation:op];
    return op;
}

-(void) getGAEFriendKeysOfUser:(User* ) user {
    if (![user serverId])
        return;
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
	
    MKNetworkOperation *op = [self operationWithPath:@"getGAEFriends"
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
         NSDictionary *responseDict;
         //NSMutableArray *cdFriends = [User getFriendsOfUser:[[SingletonUser sharedUserInstance] user]];
         BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
         if (!isIOS5){
             // Create new SBJSON parser object
             SBJsonParser *parser = [[SBJsonParser alloc] init];
             id jsonObject = [parser objectWithString:[completedOperation responseString]];
             
             if ([jsonObject isKindOfClass:[NSDictionary class]]){
                 // treat as a dictionary, or reassign to a dictionary ivar
                 debugLog(@"Dictionary");
                 responseDict = [[NSDictionary alloc] initWithDictionary:jsonObject];
             }
             else if ([jsonObject isKindOfClass:[NSArray class]]){
                 debugLog(@"Array");
                 responseDict = [[NSDictionary alloc] initWithObjects:jsonObject forKeys:jsonObject];
             }
         }else {
             responseDict = [[NSDictionary alloc] initWithDictionary:[[completedOperation responseJSON] objectAtIndex:0]];
         }
		 
         NSMutableArray *gaeFriends = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"friends"]];
         
         /*
		  for (User *cdUser in cdFriends)
		  {
		  NSMutableArray *theKey = [NSMutableArray arrayWithObject:@"key"];
		  NSMutableArray *theObject = [NSMutableArray arrayWithObject:[cdUser serverId]];
		  NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObject forKeys:theKey];
		  
		  if (![gaeFriends containsObject:theDict]){
		  
		  DLog(@"%@ is not friend",[cdUser serverId]);
		  
		  User *friend = [User checkExistsInCD:[cdUser serverId] inContext:[modelUtils defaultManagedObjectContext]];
		  
		  if (friend) {
		  [modelUtils deleteManagedObjectFromDefaultMOC:friend];
		  [modelUtils commitDefaultMOC];
		  }
		  }
		  else
		  DLog(@"%@ is friend",[cdUser serverId]);
		  }
          */
		 
         [[SingletonUser sharedUserInstance] setGaeFriends:gaeFriends];
         
         if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
             if (ApplicationDelegate.loadingView) {
                 [ApplicationDelegate.loadingView removeFromSuperview];
                 ApplicationDelegate.loadingView = nil;
             }
         }
     } onError:^(NSError* error) {
         DLog(@"%@", error);
     }];
    
    [self enqueueOperation:op];
}

-(MKNetworkOperation*) sendMessageToGAE:(UserMessage *) message
						   onCompletion:(UserMessageResponseBlock) completionBlock
								onError:(MKNKErrorBlock) errorBlock {
    
	
	NSTimeInterval ti = [GAEUtils formatTimeStampForGAE:[message dateCreated]];
    NSString *encodedMessageString = [Utils urlEncodedAndEmojiConverion:[message text]];
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:encodedMessageString forKey:@"message"];
    [jsonObject setObject:[[message fromUserId] serverId] forKey:@"fromUser"];
    [jsonObject setObject:[[message toUserId] serverId] forKey:@"toUser"];
    [jsonObject setObject:[NSNumber numberWithDouble:ti] forKey:@"dateCreated"];
	
    MKNetworkOperation *op = [self operationWithPath:@"newMessageForUser"
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
         NSString *serverId = [[NSString alloc] initWithFormat:@"%@",[status objectForKey:@"id"]];
         
         completionBlock(serverId);
         
     } onError:^(NSError* error) {
         DLog(@"%@", error);
		 
		 errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

-(MKNetworkOperation*) deleteNewsReelOfUser:(User *) user
									  event:(NSString *) eventId
							   onCompletion:(UserManagementResponseBlock) completionBlock
									onError:(MKNKErrorBlock) errorBlock {
	NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];

    [jsonObject setObject:[user serverId] forKey:@"toUser"];
    [jsonObject setObject:eventId forKey:@"eventIds"];
	
    MKNetworkOperation *op = [self operationWithPath:@"hideFromNewsReal"
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
         completionBlock([completedOperation responseJSON]);
         
     } onError:^(NSError* error) {
         DLog(@"%@", error);
		 
		 errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

@end