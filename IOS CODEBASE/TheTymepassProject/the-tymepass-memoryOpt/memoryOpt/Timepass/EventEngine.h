//
//  EventEngine.h
//  Timepass
//
//  Created by mac book pro on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "EventMessage.h"

@interface EventEngine : MKNetworkEngine

typedef void (^EventResponseBlock)(NSArray *responseJSON);
typedef void (^EventResponseDataBlock)(NSData *responseData);
typedef void (^EventResponseArrayBlock)(NSMutableArray *responseArray);
typedef void (^EventManagementResponseBlock)(NSString *status);
typedef void (^EventChangeResponseBlock)(NSDictionary *result);

-(MKNetworkOperation*) requestObjectOfEvent:(Event *) event 
                                 objectType:(NSString *) type
                               onCompletion:(EventResponseBlock) completion
                                    onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) requestStealthFromForEvent:(Event *) event 
                               onCompletion:(EventResponseBlock) completion
                                    onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) insertGAEEventWithEvent:(Event *) event 
                                  onCompletion:(EventManagementResponseBlock) completion
                                       onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) insertGAEEventWithEvents:(NSMutableArray *) insertEvents
								   onCompletion:(EventResponseBlock) completionBlock
										onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) updateGAEEventWithEvent:(Event *) event
                                  onCompletion:(EventManagementResponseBlock) completion
                                       onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) changeEvent:(Event *) event 
                            ofUser:(NSString *) userToId 
                   attendingStatus:(NSNumber *) status 
                       stealthMode:(NSNumber *) stealthMode
                      onCompletion:(EventChangeResponseBlock) completion
                           onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) changeEvent:(Event *) event
                            ofUser:(NSString *) userToId
                   attendingStatus:(NSNumber *) status
                       stealthMode:(NSNumber *) stealthMode
							isGold:(NSNumber *) isGold
                      onCompletion:(EventChangeResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) changeEvent:(Event *) event
                            ofUser:(NSString *) userToId
                   attendingStatus:(NSNumber *) status
							isGold:(NSNumber *) isGold
                      onCompletion:(EventChangeResponseBlock) completionBlock
                           onError:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) changeICalEvent:(Event *) event 
                                ofUser:(NSString *) userToId;

-(MKNetworkOperation*) changeICalEvents:(NSMutableArray *) updateEvents
								 ofUser:(NSString *) userToId;

-(MKNetworkOperation*) getEventsByDate:(NSString *) seekerId 
                                  user:(NSString *) userId 
                              dateFrom:(NSDate *) dateFrom 
                                dateTo:(NSDate *) dateTo
                          onCompletion:(EventResponseArrayBlock) completion
                               onError:(MKNKErrorBlock) error;

-(MKNetworkOperation*) sendMessageToGAE:(EventMessage *) message;
-(MKNetworkOperation*) setEvent:(Event *) event PrivateFrom:(NSArray *) ids;

-(MKNetworkOperation*) changeEventStatus:(NSMutableArray *) evertIds
						 attendingStatus:(NSNumber *) status
                      onCompletion:(EventManagementResponseBlock) completion
                           onError:(MKNKErrorBlock) error;

@end
