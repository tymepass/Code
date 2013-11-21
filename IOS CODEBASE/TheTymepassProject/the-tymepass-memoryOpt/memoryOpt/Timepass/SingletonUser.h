//
//  SingletonUser.h
//  Timepass
//
//  Created by Mahmood1 on 16/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SingletonUser : NSObject {
    User *user;
    NSMutableArray *gaeFriends;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSMutableArray *gaeFriends;


+(SingletonUser*)sharedUserInstance;

@end
