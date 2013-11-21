//
//  CalendarAgendaPopup.h
//  Timepass
//
//  Created by Christos Skevis on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileScreenController.h"
@interface CalendarAgendaPopup : UIViewController<UITableViewDelegate>{
    NSInteger sectionToVisible;
    NSInteger rowToVisible;
    
	NSDate *currentDate;
    NSDate *selectedDate;
    NSDate *selectedDateEnd;
    NSMutableArray *fetchedEvents;
    NSMutableArray *allDayEvents;
    NSMutableArray *otherEvents;
    NSMutableArray *sectionsArray;
    NSInteger totalCurrentDayEvents;
    bool popup;
    UIViewController *eventViewController;
    User *aFriend;
    NSManagedObjectContext *scratchContext;
}

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *dayTitle;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *fetchedEvents;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *selectedDate;

-(IBAction)movePrevDay:(id)sender;
-(IBAction)moveNextDay:(id)sender;
-(void)setToday;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isPopup:(BOOL) isPopup currentDay:(NSDate *)currentSelectDate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context isPopup:(BOOL) isPopup currentDay:(NSDate *)currentSelectDate;
-(void)changeHeaderTitle;
-(NSMutableArray *)calendarEventsForDate:(NSDate *)date;
-(NSMutableArray *)calendarAgendaEvents;
@end
