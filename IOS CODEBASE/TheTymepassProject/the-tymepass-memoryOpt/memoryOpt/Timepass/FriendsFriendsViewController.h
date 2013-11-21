//
//  FriendsFriendsViewController.h
//  Timepass
//
//  Created by mac book pro on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+GAEUser.h"

@interface FriendsFriendsViewController : UIViewController<UITableViewDelegate> {
    UITableView *tableView;
    NSMutableArray * friendsArray;
    User *user;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * friendsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *)aUser friends:(NSArray *)aFriends;
@end
