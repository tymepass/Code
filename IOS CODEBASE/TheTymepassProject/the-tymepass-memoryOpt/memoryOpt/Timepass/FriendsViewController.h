//
//  FriendsViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"

@interface FriendsViewController : UIViewController<UITableViewDelegate> {
	bool isFriendCal;
}

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (unsafe_unretained, nonatomic) IBOutlet ShadowedTableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *searchForFriendsBtn;
@property (nonatomic, strong) NSMutableArray * friendsArray;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friendCal:(bool)isFriendCalender;

@end
	