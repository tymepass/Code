//
//  CalendarViewController.h
//  Timepass
//
//  Created by Mahmood1 on 28/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarToolbar.h"
#import "User.h"
#import "CalendarAgendaViewController.h"
#import "CalendarDayViewController.h"
#import "CalendarWeekViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarYearViewController.h"

/*
@protocol PassEventDateDelegate;

@protocol PassEventDateDelegate<NSObject>
@optional
- (void)setEventDate:(NSDate *) date;
@end
 */

@interface CalendarViewController : UIViewController {
    BOOL toolBarWillBeShown;
    NSManagedObjectContext *scratchContext;
    
    User *profileUser;
	UIImageView *shadowImage;
}
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *calendarView;
@property (nonatomic, strong) IBOutlet TdCalendarToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIViewController *initViewController;
@property (copy) NSDate *eventDate;
//@property (nonatomic, strong) id<PassEventDateDelegate> passEventDateDelegate;

@property (nonatomic, retain) CalendarAgendaViewController *calendarAgendaViewController;
@property (nonatomic, retain) CalendarDayViewController *calendarDayViewController;
@property (nonatomic, retain) CalendarWeekViewController *calendarWeekViewController;
@property (nonatomic, retain) CalendarMonthViewController *calendarMonthViewController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil initViewController:(UIViewController *)initView showToolBar:(BOOL) showToolBar;
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil 
   initViewController:(UIViewController *)initView 
          showToolBar:(BOOL) showToolBar  
              aFriend:(User *)localFriend
            inContext:(NSManagedObjectContext *) context;
-(void)removeCalendarViewSubviews;
-(IBAction)todayBtn:(id)sender;

@end
