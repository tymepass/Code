//
//  GlobalData.m
//  Timepass
//
//  Created by Mahmood1 on 16/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData
@synthesize currentDate,today;
@synthesize eventFlag;
@synthesize event;
@synthesize sync;
@synthesize getGAEFriends;

+(GlobalData*)sharedGlobalData {    
    static dispatch_once_t pred;
    static GlobalData *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GlobalData alloc] init];
    });
    
    return shared;
}

@end
