//
//  myUAirship.h
//  Timepass
//
//  Created by Mahmood1 on 14/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myUAirship : NSObject {
    NSString *server;
    NSString *appId;
    NSString *appSecret;
    
    NSString *deviceToken;
    NSString *deviceAlias;
    BOOL deviceTokenHasChanged;
    BOOL ready;
}

@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;
@property (retain) NSString *server;
@property (retain) NSString *appId;
@property (retain) NSString *appSecret;
@property (assign) BOOL deviceTokenHasChanged;
@property (assign) BOOL ready;

+ (myUAirship *)sharedUAirship;
@end
