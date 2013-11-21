//
//  CalendarMonthViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarMonthView.h"
#import "User+Management.h"

@interface CalendarMonthViewController : UIViewController <UIApplicationDelegate, CalendarMonthViewDelegate> {
    User *aFriend;

    NSManagedObjectContext *scratchContext;
    NSString *tableTitleText;
}

@property (nonatomic, strong) IBOutlet TdCalendarMonthView *tdCalendarView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet UILabel *monthTitle;

-(IBAction)movePrevMonth:(id)sender;
-(IBAction)moveNextMonth:(id)sender;
//- (NSArray *)calendarMonthEventsForDate:(NSDate *)date;
-(void)changeHeaderTitle;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil 
                friend:(User *) afriendId 
            inContext:(NSManagedObjectContext *) context;

@end