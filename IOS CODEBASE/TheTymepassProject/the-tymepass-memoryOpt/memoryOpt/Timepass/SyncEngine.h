//
//  SyncEngine.h
//  Timepass
//
//  Created by mac book pro on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface SyncEngine : MKNetworkEngine

typedef void (^SyncResponseBlock)(NSString *responseString);

-(MKNetworkOperation*) jsonObject:(NSMutableDictionary *) jsonObject
                     onCompletion:(SyncResponseBlock) completion
                          onError:(MKNKErrorBlock) error;

@end
