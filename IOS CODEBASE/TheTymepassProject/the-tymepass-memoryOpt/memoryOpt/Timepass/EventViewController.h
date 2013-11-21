//
//  EventViewController.h
//  Timepass
//
//  Created by Takis Sotiriadis on 21/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "MessageWallTableViewController.h"
#import "EventMessage+GAE.h"
#import "EventReminderPickerViewController.h"
#import "CalendarViewController.h"
#import "InviteFriendsForEventViewController.h"
#import "FriendsEventInvitationViewController.h"
#import "EventAttendeesViewController.h"
#import "TTTAttributedLabel.h"

#import "Facebook.h"
#import <Twitter/Twitter.h>

@interface EventViewController : TPScrollableViewController <UITableViewDelegate,InviteFriendsForEventDelegate,UINavigationBarDelegate, EventReminderPickerDelegate, FriendsEventInvitationDelegate,FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
    NSArray *attendanceArray;
    NSArray *attendanceValuesArray;
    NSNumber *attendingOption;
    
    NSArray *switchArray;
    NSNumber *isInStealthMode;
    NSString * invitationId;
    NSMutableArray *listOfReminders;
    NSNumber *passedEventReminderSelectedIndex;
    int selectedEventReminderIndex;

    User* creator;
    Event *currentEvent;
    NSMutableArray *eventMessages;
    NSMutableArray *eventInvitees;
    NSArray *peopleAttending;
    NSMutableArray *peopleInvited;
   
    NSMutableArray *friends;
    NSMutableArray *friendsArray;
    NSMutableArray *fbFriendsArray;
    
    NSMutableArray *pendingChanges;
    MBProgressHUD *HUD;
    BOOL viewWholeTitle;
    BOOL canInvitePeople;
	
	NSNumber *isGoldenEvent;
    int isGolden;
    
    float scrollViewContentHeight;
    
    IBOutlet UIImageView *EventImg;
	
	NSString *filepath;
    // Build the array from the plist
    NSMutableDictionary *settingsDictionary;
	
	NSNumber *isPrivate;
    NSNumber *isOpen;
	Facebook *facebook;
    NSArray *fbsession;
    apiCall *currentAPICall;
    NSString *strFBpost;
}
@property (nonatomic, strong) IBOutlet UIImageView *EventImg;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventLocationLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *attendingSegmentControl;
@property (nonatomic, strong) IBOutlet UIButton *viewAllMessagesBtn;
@property (nonatomic, strong) IBOutlet UIView *peopleAttendingHeaderView;

@property (nonatomic, retain) EventReminderPickerViewController *eventReminderPickerViewController;
@property (copy) NSNumber *passedEventReminderSelectedIndex;
@property (copy) NSDate *reminderCustomDate;
@property (nonatomic, retain) MessageWallTableViewController *viewWallTableViewController;
@property (nonatomic, retain) MessageWallTableViewController *messageWallTableViewController;
@property (nonatomic, retain) CalendarViewController *calendarViewController;

@property (nonatomic, retain) Event *currentEvent;

@property (nonatomic, strong) MKNetworkOperation *eventOperation;
@property (nonatomic, strong) MKNetworkOperation *attendeesOperation;
@property (nonatomic, strong) MKNetworkOperation *attendeesImagesOperation;
@property (nonatomic, strong) MKNetworkOperation *messagesOperation;

@property (nonatomic, strong) IBOutlet UIButton *stealthBtn;
@property (nonatomic, strong) IBOutlet UIButton *postMessageBtn;
@property (nonatomic, strong) IBOutlet UIButton *attendingBtn;
@property (nonatomic, strong) IBOutlet UIButton *maybeBtn;
@property (nonatomic, strong) IBOutlet UIButton *reminderBtn;
@property (nonatomic, strong) IBOutlet UIButton *goldenBtn;
@property (nonatomic, strong) IBOutlet UIButton *inviteFriendBtn;

@property (nonatomic, strong) IBOutlet TTTAttributedLabel *attendingLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *maybeLabel;
@property (nonatomic, strong) IBOutlet UILabel *reminderLabel;
@property (strong, nonatomic) IBOutlet UIImageView *openImageView;

@property (nonatomic, strong)NSString *strFBpost;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event;
-(void) cancelOperations;
-(void)loadImages;

/* extended actions */

-(IBAction)attendingBtnPressed:(id)sender;
-(IBAction)maybeBtnPressed:(id)sender;
-(IBAction)reminderBtnPressed:(id)sender;
-(IBAction)inviteFriendBtnPressed:(id)sender;


-(void)DoFbPost:(NSString *)post;
-(void)DoTweet:(NSString *)post;

@end