//
//  UAirship.m
//  Timepass
//
//  Created by Mahmood1 on 14/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "myUAirship.h"

@implementation myUAirship
@synthesize deviceToken,deviceAlias,server,appId,appSecret,deviceTokenHasChanged,ready;

static myUAirship *sharedUAirship;

+(myUAirship*)sharedUAirship {
    @synchronized(self) {
        if (!sharedUAirship)
            sharedUAirship = [[myUAirship alloc] init];
    }
    
    return sharedUAirship;
}

@end