//
//  MyProfileViewController.h
//  Timepass
//
//  Created by Mahmood1 on 19/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ShadowedTableView.h"
#import "CalendarViewController.h"
#import "TTTAttributedLabel.h"
#import "EditMyProfileViewController.h"

@interface MyProfileViewController : UIViewController <UITableViewDelegate> {
    User *profileUser;
    
    NSString *invitationId;
    NSArray *invitationsArray;
    NSArray *newsReelArray;
    NSArray *friendsArray;
    
    CalendarViewController *calendarViewController;
    EditMyProfileViewController *editMyProfileViewController;

    float scrollViewHeight;
    
    //Below line are added by krunal on 4th Oct.'12
    IBOutlet UIButton *btnGoldStarred;
    IBOutlet UIButton *btnFriends;
    IBOutlet UIButton *btnCalendar;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UILabel *profileNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *birthdayLabel;
@property (nonatomic, strong) IBOutlet UILabel *professionLabel;
@property (nonatomic, strong) IBOutlet UILabel *sexLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *viewAllInvitationsBtn;
@property (nonatomic, strong) IBOutlet UIButton *viewAllNewsBtn;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) MKNetworkOperation *invitationsOperation;
@property (nonatomic, strong) MKNetworkOperation *newsReelOperation;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MKNetworkOperation *goldStarredOperation;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user invitationId:(NSString *) invId;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
-(TTTAttributedLabel *) setInvitationObject:(id)obj setType:(NSString *) type intoFrame:(CGRect)frame;
-(TTTAttributedLabel *) setNewsreelObject:(id)obj setType:(NSString *) type intoFrame:(CGRect)frame;
-(void) cancelOperations;

//Below line are added by krunal on 4th Oct.'12
-(IBAction)btnGoldStarredClicked:(id)sender;
-(IBAction)btnFriendsClicked:(id)sender;
-(IBAction)btnCalendarClicked:(id)sender;
-(void)loadImages;
@end
