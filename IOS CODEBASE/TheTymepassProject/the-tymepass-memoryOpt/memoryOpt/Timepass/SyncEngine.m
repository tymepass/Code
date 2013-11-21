//
//  SyncEngine.m
//  Timepass
//
//  Created by mac book pro on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncEngine.h"
#import "SBJson.h"

@implementation SyncEngine

-(MKNetworkOperation*) jsonObject:(NSMutableDictionary *) jsonObject
                     onCompletion:(SyncResponseBlock) completionBlock
                          onError:(MKNKErrorBlock) errorBlock {
    
    MKNetworkOperation *op = [self operationWithPath:@"syncShort"
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
         // the completionBlock will be called twice. 
         // if you are interested only in new values, move that code within the else block
         NSString *valueString = [[NSString alloc] initWithData:[completedOperation responseData] encoding:NSUTF8StringEncoding];

         //DLog(@"response %@", valueString);
         
         /*
         if([completedOperation isCachedResponse]) {
             DLog(@"Data from cache %@", [completedOperation responseJSON]);
         }
         else {
             DLog(@"Data from server %@", [completedOperation responseString]);
         }
         */
         
         completionBlock(valueString);
         
     } onError:^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
}

@end
