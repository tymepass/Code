//
//  MyEventsViewController.h
//  Timepass
//
//  Created by Takis Sotiriadis on 22/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MyEventsViewController : UIViewController {
    User *user;
    
    NSMutableArray *events;
    NSMutableArray *fetchedEvents;
    NSMutableArray *GoldenEvents;
    
    UISegmentedControl *control;
    
    UIViewController *eventViewController;
	
	NSMutableArray *attendingArray;
	NSMutableArray *nonAttendingArray;
	NSMutableArray *nonGoldArray;
	
	int offset;
	BOOL isGoldenEvents;
	BOOL allLoad;
	
	BOOL isLoaded;
	
	MBProgressHUD *HUD;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *toolBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *goldenBtn;
@property (nonatomic, strong) NSMutableArray *fetchedEvents;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *GoldenEvents;
@property (nonatomic, strong) NSMutableArray *attendingArray;
@property (nonatomic, strong) NSMutableArray *nonAttendingArray;
@property (nonatomic, strong) NSMutableArray *nonGoldArray;

@property (nonatomic, strong) MKNetworkOperation *eventOperation;

-(TTTAttributedLabel *) setEvent:(Event *)event intoFrame:(CGRect)frame;

-(void)getPagedEvents;

-(IBAction)markToNotAttendingEvent:(id)sender;
-(IBAction)markToAttendingEvent:(id)sender;
-(IBAction)markToNotGoldEvent:(id)sender;
-(IBAction)goldenBtnPressed:(id)sender;

@end
