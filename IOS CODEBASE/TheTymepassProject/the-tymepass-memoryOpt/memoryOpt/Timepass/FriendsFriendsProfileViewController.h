//
//  FriendsFriendsProfileViewController.h
//  Timepass
//
//  Created by mac book pro on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+GAEUser.h"

@interface FriendsFriendsProfileViewController : UIViewController <UITableViewDelegate> {
    User *aFriend;
    NSString *invitationId;
    
    NSArray* friendsArray;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *profileImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *locationLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *sendFriendRequestBtn;
@property (strong, nonatomic) IBOutlet UILabel *lblFriends;

@property (nonatomic, strong) MKNetworkOperation *friendsOperation;

@property (nonatomic, strong) MKNetworkOperation *goldStarredOperation;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user invitationId:(NSString *) invId;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;

- (IBAction)btnGoldStarredPressed:(id)sender;
- (IBAction)btnFriendsPressed:(id)sender;

@end
