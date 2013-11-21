//
//  CalSync.h
//  Timepass
//
//  Created by Christos Skevis on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event+Management.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "Utils.h"

@interface CalSync : NSObject

+ (NSString *) saveToICal:(Event *) tpEvent reminder:(float) reminderTime;
+ (NSString *) saveToICal:(Event *) tpEvent reminderDate:(NSDate *) reminderDate;

+ (void) updateToICal:(Event *) tpEvent;
+ (void) updateToICal:(Event *) tpEvent reminder:(float) reminderTime;
+ (void) updateToICal:(Event *) tpEvent reminderDate:(NSDate *) reminderDate;

+ (void) updateToICal:(Event *) tpEvent reminder:(float) reminderTime recurring:(BOOL)isRecur;
+ (void) updateToICal:(Event *) tpEvent reminderDate:(NSDate *) reminderDate recurring:(BOOL)isRecur;

+ (void) syncWithICal:(User *) user;
+ (void) syncWithICalOnOneCall:(User *) user;

+ (EKEvent *) getIcalEvent:(Event *)tpEvent;
+ (Event *) getTPEvent:(EKEvent *) ekevent;

+ (BOOL) removeIcalEvent:(Event *)tpEvent;

@end