//
//  MyEventViewController.h
//  Timepass
//
//  Created by mac book pro on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "MessageWallTableViewController.h"
#import "EventMessage+GAE.h"
#import "CalendarViewController.h"
#import "InviteFriendsForEventViewController.h"
#import "FriendsEventInvitationViewController.h"
#import "EventAttendeesViewController.h"
#import "EventReminderPickerViewController.h"
#import "TTTAttributedLabel.h"

@interface MyEventViewController : TPScrollableViewController <UITableViewDelegate,InviteFriendsForEventDelegate,UINavigationBarDelegate, FriendsEventInvitationDelegate, EventReminderPickerDelegate> {
    NSArray *switchArray;
    NSString * invitationId;
	
    User* creator;
    Event *currentEvent;
    NSMutableArray *eventMessages;
    NSMutableArray *eventInvitees;
    NSArray *peopleAttending;
    NSMutableArray *peopleInvited;
	
	int selectedEventReminderIndex;
    
    NSMutableArray *friends;
    NSMutableArray *friendsArray;
    NSMutableArray *fbFriendsArray;
    
    NSMutableArray *pendingChanges;
    BOOL viewWholeTitle;
    BOOL canInvitePeople;
    
    float scrollViewContentHeight;
	MBProgressHUD *HUD;
	
	NSNumber *isGoldenEvent;
    int isGolden;
	
	NSMutableArray *listOfReminders;
}

@property (nonatomic, strong) IBOutlet UIImageView *EventImg;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, strong) IBOutlet UIButton *viewCalendarBtn;
@property (nonatomic, strong) IBOutlet UIButton *viewAllMessagesBtn;
@property (nonatomic, strong) IBOutlet UIView *peopleAttendingHeaderView;

@property (nonatomic, retain) MessageWallTableViewController *viewWallTableViewController;
@property (nonatomic, retain) MessageWallTableViewController *messageWallTableViewController;
@property (nonatomic, retain) CalendarViewController *calendarViewController;

@property (nonatomic, retain) Event *currentEvent;

@property (nonatomic, strong) MKNetworkOperation *attendeesOperation;
@property (nonatomic, strong) MKNetworkOperation *attendeesImagesOperation;
@property (nonatomic, strong) MKNetworkOperation *messagesOperation;

@property (nonatomic, strong) IBOutlet UIButton *goldenBtn;

@property (nonatomic, strong) IBOutlet UIButton *attendingBtn;
@property (nonatomic, strong) IBOutlet UIButton *maybeBtn;
@property (nonatomic, strong) IBOutlet UIButton *reminderBtn;
@property (nonatomic, strong) IBOutlet UIButton *inviteFriendBtn;

@property (nonatomic, strong) IBOutlet TTTAttributedLabel *attendingLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *maybeLabel;
@property (nonatomic, strong) IBOutlet UILabel *reminderLabel;

@property (nonatomic, retain) EventReminderPickerViewController *eventReminderPickerViewController;
@property (copy) NSDate *reminderCustomDate;
@property (copy) NSNumber *passedEventReminderSelectedIndex;
@property (strong, nonatomic) IBOutlet UIImageView *openImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event;

-(void)loadImages;

/* extended actions */

-(IBAction)attendingBtnPressed:(id)sender;
-(IBAction)maybeBtnPressed:(id)sender;
-(IBAction)reminderBtnPressed:(id)sender;
-(IBAction)inviteFriendBtnPressed:(id)sender;

@end
