//
//  NotificationsViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invitation+GAE.h"
#import "TTTAttributedLabel.h"
#import "EventViewController.h"
#import "MyProfileViewController.h"

@interface NotificationsViewController : UIViewController<UITableViewDelegate> {
    UITableView *notificationTable;
    NSMutableArray *notifications;
    NSMutableArray *pendingNotifications;
    UIBarButtonItem *editBtn;
    UIBarButtonItem *doneBtn;
	   
    User *user;
    
    UIViewController *eventViewController;
    MyProfileViewController *myProfileViewController;
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *pendingNotifications;

@property (nonatomic, strong) MKNetworkOperation *notificationsOperation;

-(IBAction) editClicked:(id)sender;
-(IBAction) doneClicked:(id)sender;
-(TTTAttributedLabel *) setObject:(id)obj setType:(NSString *) type setMessagesCount:(NSString *) messagesCount intoFrame:(CGRect)frame;

@end
