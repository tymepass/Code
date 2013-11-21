//
//  SingletonUser.m
//  Timepass
//
//  Created by Mahmood1 on 16/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingletonUser.h"

@implementation SingletonUser
@synthesize user;
@synthesize gaeFriends;

+(SingletonUser*)sharedUserInstance {
    static dispatch_once_t pred;
    static SingletonUser *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SingletonUser alloc] init];
    });
        
    return shared;
}

@end

