//
//  FriendsEventInvitationViewController.h
//  Timepass
//
//  Created by mac book pro on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchForFriendsViewController.h"
#import "Event.h"

@protocol FriendsEventInvitationDelegate;

@protocol FriendsEventInvitationDelegate<NSObject>
@optional
- (void)setFriends:(NSMutableArray *)friends areFBFriends:(BOOL) areFB;
@end

@interface FriendsEventInvitationViewController : UIViewController<UITableViewDelegate> {   
    UITableView *tableView;
    UIButton *sendInvitationsBtn;
    Event *currentEvent;
    BOOL fetchFBFriends;
    BOOL checkAll;
    
    SearchForFriendsViewController *searchForFriendsViewController;
    
    id<FriendsEventInvitationDelegate> friendsEventInvitationDelegate;
    NSMutableArray *friendsArray;
    NSMutableArray *peopleAlreadyInvited;
    NSMutableArray *peopleToInvite;

    MBProgressHUD *HUD;
}

@property (nonatomic, readwrite) BOOL sendInvite;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *sendInvitationsBtn;

@property (nonatomic, retain) id<FriendsEventInvitationDelegate> friendsEventInvitationDelegate;
@property (copy) NSMutableArray *friendsToInviteArray;
@property (copy) NSMutableArray *fbFriendsToInviteArray;

@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MKNetworkOperation *inviteesOperation;

-(IBAction)sendInvitationsBtnPressed:(id) sender;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fetchFBFriends:(BOOL)fbMode event:(Event *)event;
@end
