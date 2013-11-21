//
//  CreateEventViewController.h
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "EventRecurringPickerViewController.h"
#import "EventReminderPickerViewController.h"
#import "EventSetStartEndTimeViewController.h"
#import "CalendarViewController.h"
#import "MessageWallTableViewController.h"
#import "EventPrivateViewController.h"
#import "Location+Management.h"
#import "EventMessage+Management.h"
#import "InviteFriendsForEventViewController.h"
#import "FriendsEventInvitationViewController.h"
#import "Facebook.h"
#import <Twitter/Twitter.h>

@interface CreateEventViewController : TPScrollableViewController <UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, EventRecurringPickerDelegate, EventReminderPickerDelegate, EventSetStartEndTimeDelegate, EventPrivacyDelegate, InviteFriendsForEventDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate, FriendsEventInvitationDelegate> {
	
	NSString *filepath;
    // Build the array from the plist
    NSMutableDictionary *settingsDictionary;
	
    NSNumber *allDayValue;
    NSNumber *isPrivate;
    NSNumber *isOpen;
    //NSNumber *postToFB;

    NSDate *eventDate;
    NSDate *startTime;
    NSDate *endTime;

    NSArray *listOfRecurrences;
    NSMutableArray *listOfReminders;
    
    NSMutableArray *eventMessages;
    NSMutableArray *peopleInvited;
    
    UILabel *placeholderLabel;
    
    NSNumber *isGoldenEvent;
    int isGolden;
    
    UIButton *BtnEventImg;
    UIButton *btnEventBgImg;
    UIButton *goldenBtn;
    UIButton *setTimeBtn;
    UIButton *setPrivacyBtn;
	UIButton *doneBtn;
    
    UIImage *ImgEventBG;
    
    BOOL isEventImageSelection;
    
    Facebook *facebook;
    NSArray *fbsession;
    apiCall *currentAPICall;
    NSString *strFBpost;
    int sectionForDetails;
	
	BOOL saveCurrentEventOnly;
	BOOL imageChanged;
	
}
@property (nonatomic, strong)NSString *strFBpost;
@property (nonatomic, strong)NSString *eventTitle;
@property (nonatomic, strong)NSString *description;
@property (nonatomic, strong)NSString *location_name;
@property (nonatomic) BOOL isEventImageSelection;
@property (nonatomic, strong) UIImage *ImgEventBG;
@property (nonatomic, strong) UIButton *btnEventBgImg;
@property (nonatomic, strong) IBOutlet UIButton *BtnEventImg;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *eventTitleField;
@property (nonatomic, strong) IBOutlet UITextView *eventDescriptionField;
@property (nonatomic, strong) IBOutlet UIButton *doneBtn;
@property (nonatomic, strong) IBOutlet UITextField *eventLocationField;
@property (nonatomic, strong) IBOutlet UILabel *eventStartTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventEndTimeLabel;
@property (nonatomic, strong) IBOutlet UITextField *eventRecurringField;
@property (nonatomic, strong) IBOutlet UITextField *eventReminderField;
@property (nonatomic, strong) IBOutlet UISegmentedControl *allDayEventSegmentControl;
@property (nonatomic, strong) IBOutlet UIButton *viewCalendarBtn;
@property (nonatomic, strong) IBOutlet UIButton *advancedPrivacyBtn;
@property (nonatomic, strong) IBOutlet UIButton *viewAllMessagesBtn;
@property (nonatomic, strong) IBOutlet UIButton *saveEventBtn;
@property (nonatomic, strong) IBOutlet UIView *privacySliderView;
@property (nonatomic, strong) IBOutlet UISlider *privacySlider;
@property (nonatomic, strong) IBOutlet UILabel *stealthModeLabel;
@property (nonatomic, strong) IBOutlet UILabel *stealthModeDetailLabel;
@property (nonatomic, strong) IBOutlet UILabel *standardModeLabel;
@property (nonatomic, strong) IBOutlet UILabel *standardModeDetailLabel;
@property (nonatomic, strong) IBOutlet UILabel *viralModeLabel;
@property (nonatomic, strong) IBOutlet UILabel *viralModeDetailLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) IBOutlet UIButton *goldenBtn;
@property (nonatomic, strong) IBOutlet UIButton *setTimeBtn;
@property (nonatomic, strong) IBOutlet UIButton *setPrivacyBtn;
@property (nonatomic, strong) IBOutlet UIButton *sendInvitationBtn;
@property (nonatomic, strong) IBOutlet UIButton *descriptionBtn;
@property (nonatomic, strong) IBOutlet UIButton *locationBtn;
@property (nonatomic, strong) IBOutlet UIButton *reccuranceBtn;
@property (nonatomic, strong) IBOutlet UIButton *reminderBtn;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *reccuranceLabel;
@property (nonatomic, strong) IBOutlet UILabel *reminderLabel;
@property (nonatomic, strong) IBOutlet UILabel *privacyStatusLabel;


@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) EventRecurringPickerViewController *eventRecurringPickerViewController;
@property (copy) NSNumber *passedEventRecurringSelectedIndex;
@property (nonatomic, retain) EventReminderPickerViewController *eventReminderPickerViewController;
@property (copy) NSNumber *passedEventReminderSelectedIndex;
@property (copy) NSDate *reminderCustomDate;
@property (copy) NSDate *recurranceEndDate;
@property (nonatomic, retain) EventSetStartEndTimeViewController *eventSetStartEndTimeViewController;
@property (copy) NSDate *passedEventStartTime;
@property (copy) NSDate *passedEventEndTime;
@property (nonatomic, retain) CalendarViewController *calendarViewController;
@property (copy) NSDate *passedEventDate;
@property (nonatomic, retain) MessageWallTableViewController *viewWallTableViewController;
@property (nonatomic, retain) MessageWallTableViewController *messageWallTableViewController;
@property (nonatomic, retain) EventPrivateViewController *eventPrivacyViewController;
@property (nonatomic, retain) NSMutableArray *friendsArray;
@property (nonatomic, retain) NSMutableArray *fbFriendsArray;
@property (nonatomic, retain) NSMutableArray *privateFromFriendsArray;
@property (nonatomic, retain) Event *currentEvent;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *eventOperation;
@property (nonatomic, strong) MKNetworkOperation *messagesOperation;

-(void)DoFbPost:(NSString *)post;
-(void)DoTweet:(NSString *)post;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil invitee:(User *) aFriend;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *) event;
- (Location *) updateLocation:(NSString *) location;
-(IBAction) privacySliderValueChanged:(id) sender;
-(IBAction)GoldenEventSegmentChange:(id)sender;
-(IBAction)AddEventImage:(id)sender;

-(void)AddEventBackgroundImage;

-(IBAction)setEventStartEndDate:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;

@end
