//
//  TdCalendarToolbar.h
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Management.h"
#import "CalendarAgendaViewController.h"
#import "CalendarDayViewController.h"
#import "CalendarWeekViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarYearViewController.h"

@interface TdCalendarToolbar : UIToolbar <UIApplicationDelegate,UINavigationControllerDelegate> {
    BOOL showSegmentedControl;
    User *aFriend;
    
    NSManagedObjectContext *scratchContext;
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UISegmentedControl *todayControl;

-(id)initWithViewController:(UIViewController*)aViewController showSegmentedControl:(BOOL) show;
-(id)initWithViewController:(UIViewController*)aViewController 
        showSegmentedControl:(BOOL) show 
                     aFriend:(User *) localFriend
                   inContext:(NSManagedObjectContext *) context;
-(void)loadView;
@end
