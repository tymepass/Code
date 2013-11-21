//
//  EventViewController.h
//  Timepass
//
//  Created by Takis Sotiriadis on 21/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "CalendarViewController.h"
#import "EventAttendeesViewController.h"

@interface EventNotInvitedViewController : TPScrollableViewController < UITableViewDelegate> {
    UILabel *eventTitleLabel;
    UILabel *eventDescriptionLabel;
    UILabel *eventLocationLabel;
    
    UIButton *viewCalendarBtn;
    User* creator;
    Event *currentEvent;
    NSMutableArray *eventInvitees;
    NSArray *peopleAttending;
    
    CalendarViewController *calendarViewController;
    EventAttendeesViewController *eventAttendeesViewController;
    
    NSMutableArray *friends;
    BOOL viewWholeTitle;
    
    float scrollViewContentHeight;
    IBOutlet UIImageView *EventImg;
}

@property (nonatomic, strong) IBOutlet UIImageView *EventImg;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) Event *currentEvent;

@property (nonatomic, strong) IBOutlet UIButton *attendingBtn;
@property (nonatomic, strong) IBOutlet UIButton *maybeBtn;
@property (nonatomic, strong) IBOutlet UIButton *reminderBtn;
@property (nonatomic, strong) IBOutlet UILabel *attendingLabel;
@property (nonatomic, strong) IBOutlet UILabel *maybeLabel;
@property (nonatomic, strong) IBOutlet UILabel *reminderLabel;

@property (nonatomic, strong) MKNetworkOperation *attendeesOperation;
@property (nonatomic, strong) MKNetworkOperation *attendeesImagesOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event;
-(void)loadImages;
@end
