//
//  SearchFbFriendsViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface SearchFbFriendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{
    UITableView *tableView;
    UISegmentedControl *segmentControl;
    UIButton *sendRequestsBtn;
    
    NSMutableArray* peopleMutable;
    NSMutableArray *peopleArray;
    NSMutableArray *peopleUsingArray;
    NSMutableArray *peopleNotUsingArray;
    Facebook *facebook;
    NSArray *fbPermissions;
    apiCall currentAPICall;

    NSMutableDictionary *facebook_response;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) IBOutlet UIButton *sendRequestsBtn;
@property (nonatomic, retain) NSMutableArray *peopleMutable;
@property (nonatomic, retain) NSMutableArray *peopleArray;
@property (nonatomic, retain) NSMutableArray *peopleUsingArray;
@property (nonatomic, retain) NSMutableArray *peopleNotUsingArray;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSMutableDictionary *facebook_response;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) MKNetworkOperation *userOperation;

-(void)LoadFBfriendforSearch;
-(void) sendRequestsBtnPressed:(id) sender;
-(IBAction) segmentControlChanged:(id) sender;
@end
