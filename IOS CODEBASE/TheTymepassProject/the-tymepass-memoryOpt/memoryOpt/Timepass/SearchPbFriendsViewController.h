//
//  SearchPbFriendsViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Utils.h"

@interface SearchPbFriendsViewController : UIViewController <MFMessageComposeViewControllerDelegate, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {

    UITableView *tableView;
    IBOutlet UIButton *smsBtn;

    CFArrayRef people;
    NSMutableArray* peopleMutable;
	NSMutableArray *currentFriendsArray;
	NSMutableArray *currentFriendsArray1;
	BOOL flag;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

@property (nonatomic, retain) NSMutableArray *peopleMutable;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) IBOutlet UIButton *sendRequestsBtn;
@property (nonatomic, retain) NSMutableArray *friendsUsingTymepassArray;
@property (nonatomic, retain) NSMutableArray *friendsNotUsingTymepassArray;
@property (nonatomic, retain) NSMutableArray *friendsNotUsingTymepassArrayWithEmail;
@property (strong, nonatomic) IBOutlet UIView *footerView;

-(IBAction) sendRequestsBtnPressed:(id) sender;
-(IBAction) segmentControlChanged:(id) sender;

@end
