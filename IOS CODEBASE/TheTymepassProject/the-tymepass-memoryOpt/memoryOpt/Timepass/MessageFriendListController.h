//
//  MessageFriendListController.h
//  Timepass
//
//  Created by jason on 15/10/12.
//
//

#import <UIKit/UIKit.h>
#import "MessageWallTableViewController.h"

@interface MessageFriendListController : UIViewController <UITableViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * friendsArray;

@property (nonatomic, retain) MessageWallTableViewController *messageWallTableViewController;

@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end