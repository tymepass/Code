//
//  InvitationEngine.h
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Event.h"

@interface InvitationEngine : MKNetworkEngine

typedef void (^InvitationResponseBlock)(NSArray *responseJSON);

-(MKNetworkOperation*) requestInvitationsCountOfUser:(User *) user
										onCompletion:(InvitationResponseBlock) completionBlock
											 onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) requestInvitationsOfUser:(User *) user
								   onCompletion:(InvitationResponseBlock) completion
										onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) readInvitationsOfUser:(User *) user
								invitationId:(NSString *) invitationId
								onCompletion:(InvitationResponseBlock) completion
									 onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) requestObjectOfEvent:(Event *) event
                                 objectType:(NSString *) type
                               onCompletion:(InvitationResponseBlock) completion
                                    onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) sendUserInvitesFrom:(User* ) fromUser
                                   ToUsers:(NSArray *) usersToArray
                                    OfType:(NSString *) invitationType
                               stealthMode:(NSNumber *) stealthMode
                                  forEvent:(NSString *) eventId;

-(MKNetworkOperation*) sendUserInvitesFrom:(User* ) fromUser
                                   ToUsers:(NSArray *) usersToArray
                                    OfType:(NSString *) invitationType
                               stealthMode:(NSNumber *) stealthMode
							  forEventDict:(NSMutableDictionary *) eventDict;

@end
