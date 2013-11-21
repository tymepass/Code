//
//  CalendarWeekViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarWeekView.h"
#import "User+Management.h"
#import "TTTAttributedLabel.h"

@interface CalendarWeekViewController : UIViewController <UIApplicationDelegate, CalendarWeekViewDelegate> {
    User *aFriend;
	
    NSManagedObjectContext *scratchContext;
    NSString *tableTitleText;
}

@property (nonatomic, strong) IBOutlet TdCalendarWeekView *tdCalendarView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *weekTitle;

-(IBAction)movePrevWeek:(id)sender;
-(IBAction)moveNextWeek:(id)sender;
//- (NSArray *)calendarMonthEventsForDate:(NSDate *)date;
-(void)changeHeaderTitle;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context;

@end