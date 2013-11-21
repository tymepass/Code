//
//  SearchEmailFriendsViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchEmailFriendsResultsViewController.h"

@interface SearchEmailFriendsViewController : UIViewController<UITableViewDelegate, UITextFieldDelegate> {    
    NSMutableArray *friendEmailsArray;
    BOOL inviteFriends;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UIButton *actionBtn;
@property (nonatomic, strong) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil sendInvitation:(BOOL) invite;
-(IBAction)actionBtnPressed:(id) sender;
-(void)OpenPhoneBookContact;

-(IBAction)btnEditPressed:(id)sender;

@end