//
//  UserEngine.h
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "UserMessage.h"

@interface UserEngine : MKNetworkEngine

typedef void (^UserResponseBlock)(NSArray *responseJSON);
typedef void (^UserManagementResponseBlock)(NSString *status);
typedef void (^UserMessageResponseBlock)(NSString *serverId);

-(MKNetworkOperation*) requestObjectOfUser:(User *) user
                                objectType:(NSString *) type
                              onCompletion:(UserResponseBlock) completion
                                   onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) requestObjectOfUser:(User *) user
                                objectType:(NSString *) type
									offset:(NSInteger)offset
                              onCompletion:(UserResponseBlock) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) requestUpcomingEventsOfUser:(NSString *) userId
                                            seeker:(NSString *) seekerId
                                      onCompletion:(UserResponseBlock) completion
                                           onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) updateGAEUserWithUser:(User *) user
                                onCompletion:(UserManagementResponseBlock) completion
                                     onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) checkGAEUserWithEmail:(NSString *)email
								onCompletion:(UserManagementResponseBlock) completion
									 onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) checkGAEUserWithTwitterId:(NSString *)twitterId
                                    onCompletion:(UserManagementResponseBlock) completionBlock
                                         onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) insertGAEUserWithUser:(User *) user
                                onCompletion:(UserManagementResponseBlock) completion
                                     onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) checkEmails:(NSDictionary *) emailDictionary
                      onCompletion:(UserResponseBlock) completion
                           onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) checkTwitterIds:(NSDictionary *) twitterIdDictionry
                          onCompletion:(UserResponseBlock) completionBlock
                               onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) checkFacebookIds:(NSDictionary *) facebookIdDictionry
						   onCompletion:(UserResponseBlock) completionBlock
								onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) sendPasswordRecoveryRequest:(NSString *)email
									  onCompletion:(UserManagementResponseBlock) completion
										   onError:(MKNKErrorBlock) error;

-(void) getGAEFriendKeysOfUser:(User* ) user;

-(MKNetworkOperation*) sendMessageToGAE:(UserMessage *) message
						   onCompletion:(UserMessageResponseBlock) completionBlock
								onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) updateNotifications:(NSDictionary *) dict
							  onCompletion:(UserManagementResponseBlock) completionBlock
								   onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) deleteNewsReelOfUser:(User *) user
									  event:(NSString *) eventId
							   onCompletion:(UserManagementResponseBlock) completion
									onError:(MKNKErrorBlock) error;

@end
