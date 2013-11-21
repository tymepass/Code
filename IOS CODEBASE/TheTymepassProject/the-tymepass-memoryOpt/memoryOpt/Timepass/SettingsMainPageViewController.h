//
//  SettingsMainPageViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchForFriendsViewController.h"
#import "HelpViewController.h"
#import "TimezoneViewController.h"
#import "FaqViewController.h"
#import "FeedbackViewController.h"
#import "MembersLoginViewController.h"
#import "Facebook.h"

@interface SettingsMainPageViewController : UIViewController <FBSessionDelegate,MFMailComposeViewControllerDelegate>{
    // Path to the plist (in the application bundle)
    NSString *path;
    // Build the array from the plist  
    NSMutableDictionary *settingsDictionary;
    
    SearchForFriendsViewController *searchForFriendsViewController;
    HelpViewController *helpViewController;
    TimezoneViewController *timezoneViewController;
    FaqViewController* faqViewController;
    FeedbackViewController *feedbackViewController;
    MembersLoginViewController *membersLoginViewController;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *signOutBtn;
@property (nonatomic, strong) IBOutlet UIButton *syncBtn;
@property (nonatomic, strong) IBOutlet UISegmentedControl *synciCalSegmentControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *syncGoogleCalSegmentControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *syncFacebookCalSegmentControl;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

- (IBAction)doneBtnPressed:(id)sender;
- (IBAction)signOutBtnPressed:(id)sender;
@end
