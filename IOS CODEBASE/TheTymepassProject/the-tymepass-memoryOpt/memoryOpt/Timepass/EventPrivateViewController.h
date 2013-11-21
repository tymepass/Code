//
//  EventPrivateViewController.h
//  Timepass
//
//  Created by mac book pro on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+GAEUser.h"

@protocol EventPrivacyDelegate;

@protocol EventPrivacyDelegate <NSObject>
- (void) setPrivacy:(NSMutableArray *) privateFromFriends;
@end

@interface EventPrivateViewController : UIViewController<UITableViewDelegate> {   
    UITableView *tableView;
    UIButton *makePrivateBtn;
    
    NSMutableArray *friendsArray;
    NSMutableArray *toStealthFromArray;
    NSMutableArray *isStealthFromArray;
    
    Event *currentEvent;
    id<EventPrivacyDelegate> eventPrivacyDelegate;

    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *makePrivateBtn;
@property (nonatomic, retain) Event *currentEvent;
@property (nonatomic, retain) id<EventPrivacyDelegate> eventPrivacyDelegate;

@property (copy) NSMutableArray *toStealthFromArray;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MKNetworkOperation *stealthFromOperation;

-(IBAction)makePrivateBtnPressed:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *) event;

@end
