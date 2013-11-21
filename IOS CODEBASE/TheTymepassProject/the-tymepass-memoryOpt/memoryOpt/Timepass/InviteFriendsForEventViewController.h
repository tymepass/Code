//
//  InviteFriendsForEventViewController.h
//  Timepass
//
//  Created by mac book pro on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsEventInvitationViewController.h"
#import "SearchEmailFriendsViewController.h"
#import "SearchPbFriendsViewController.h"
#import "Event.h"

@protocol InviteFriendsForEventDelegate;

@protocol InviteFriendsForEventDelegate<NSObject>
@optional
- (void) setFriends:(NSMutableArray *)friends;
- (void) setFBFriends:(NSMutableArray *)fbFriends;
@end

@interface InviteFriendsForEventViewController : UIViewController<UITableViewDelegate,FriendsEventInvitationDelegate>{
    UITableView *tableView;
    
    UITableViewCell *searchYourContactsCell;
    UITableViewCell *searchByEmailCell;
    UITableViewCell *searchFromFBCell;
    
    IBOutlet UIButton *laterBtn;
    
    Event *currentEvent;
    
    FriendsEventInvitationViewController *friendsEventInvitationViewController;
    
    SearchEmailFriendsViewController *searchEmailFriendsViewController;
    id<InviteFriendsForEventDelegate> inviteFriendsForEventDelegate;
    
    SearchPbFriendsViewController *searchPbFriendsViewController;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id<InviteFriendsForEventDelegate> inviteFriendsForEventDelegate;
@property (copy) NSMutableArray *friendsToInviteArray;
@property (copy) NSMutableArray *fbFriendsToInviteArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event;
@end
