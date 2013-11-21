//
//  GlobalData.h
//  Timepass
//
//  Created by Mahmood1 on 16/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface GlobalData : NSObject {
    NSDate *currentDate;
    NSDate *today;
    BOOL eventFlag;
    
    Event *event;
    
    BOOL sync;
    BOOL getGAEFriends;
}

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *today;
@property (nonatomic) BOOL eventFlag;
@property (nonatomic, retain) Event *event;
@property (nonatomic) BOOL sync;
@property (nonatomic) BOOL getGAEFriends;

+(GlobalData*)sharedGlobalData;

@end
