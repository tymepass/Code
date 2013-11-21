//
//  FriendsProfileViewController.h
//  Timepass
//
//  Created by mac book pro on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TTTAttributedLabel.h"
#import "Utils.h"

@interface FriendsProfileViewController : UIViewController <UITableViewDelegate> {    
    User *aFriend;
    NSString *invitationId;
    
	NSArray *newsReelArray;
    NSArray* friendsArray;

    float scrollViewHeight;
	
    //Below line are added by krunal on 4th Oct.'12
    IBOutlet UIButton *btnYouAreFriends;
    IBOutlet UIButton *btnSendMessage;
    IBOutlet UIButton *btnGoldStarred;
    IBOutlet UIButton *btnFriends;
    IBOutlet UIButton *btnCalendar;
    IBOutlet UIView *customFriendView;
    IBOutlet UILabel *lblFriendsForDays;
    IBOutlet UILabel *lblNumberOfEvents;
    IBOutlet UILabel *lblNumberOfEventsGoldstarred;
    IBOutlet UIButton *btnUnfriend;
    IBOutlet UIButton *btnDone;
    
    IBOutlet UIImageView *imgViewHorizontalLine1;
    IBOutlet UIImageView *imgViewHorizontalLine2;
    IBOutlet UILabel *lblGoldStarred;
    IBOutlet UILabel *lblFriends;
    IBOutlet UILabel *lblCalendar;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *profileImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *sexLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *createEventAndInviteBtn;
@property (nonatomic, strong) IBOutlet UIButton *unFriendBtn;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) MKNetworkOperation *infoOperation;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MKNetworkOperation *newsReelOperation;
@property (nonatomic, strong) MKNetworkOperation *goldStarredOperation;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user invitationId:(NSString *) invId;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil afriend:(User *) afriend;
-(TTTAttributedLabel *) setEvent:(Event *)event intoFrame:(CGRect)frame;

-(void) cancelOperations;

//Below line are added by krunal on 4th Oct.'12
-(IBAction)btnYouAreFriendsClicked:(id)sender;
-(IBAction)btnSendMessage:(id)sender;
-(IBAction)btnGoldStarredClicked:(id)sender;
-(IBAction)btnFriendsClicked:(id)sender;
-(IBAction)btnCalendarClicked:(id)sender;
-(void)loadImages;
-(IBAction)btnUnfriendClicked:(id)sender;
-(IBAction)btnDoneClicked:(id)sender;

@end
