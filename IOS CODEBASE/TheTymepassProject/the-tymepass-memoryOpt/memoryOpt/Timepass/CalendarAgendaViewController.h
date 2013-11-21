//
//  CalendarAgendaViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileScreenController.h"

@interface CalendarAgendaViewController : UIViewController<UITableViewDelegate>{
	
	User *aFriend;
    NSManagedObjectContext *scratchContext;
	
    NSInteger sectionToVisible;
    NSInteger rowToVisible;
    
	NSDate *currentDate;
    NSMutableArray *fetchedEvents;
    NSMutableArray *distinctDays;
    NSInteger totalCurrentDayEvents;
    
    UIViewController *eventViewController;
	
	int loading;
	int offset;
	
	BOOL allLoad;
}

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *dayTitle;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MKNetworkOperation *eventOperation;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, retain) NSDate *currentDate;

- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
			  afriend:(User *)afriendId
			inContext:(NSManagedObjectContext *) context;

-(IBAction)movePrevDay:(id)sender;
-(IBAction)moveNextDay:(id)sender;
-(void)setToday;

-(void)changeHeaderTitle;
-(NSMutableArray *)calendarEventsForDate:(NSDate *)date;
-(NSMutableArray *)calendarAgendaEvents;
- (NSMutableArray *)calendarAgendaEvents:(NSInteger)offset;
@end