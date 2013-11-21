//
//  TdCalendarDayPopup.h
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import "User.h"

@interface TdCalendarDayPopup : UIView {
    UIView* bgView;
    UIView* bigPanelView;
    
    NSDate *currentSelectDate;
    User *aFriend;
}

@property (nonatomic, retain) NSDate *currentSelectDate;
@property (nonatomic, retain) User *aFriend;
@property (nonatomic, retain) NSArray *events;

- (id)initWithSuperview:(UIView*)sView events:(NSArray *)evts;
-(void)closePopupWindow;

@end
