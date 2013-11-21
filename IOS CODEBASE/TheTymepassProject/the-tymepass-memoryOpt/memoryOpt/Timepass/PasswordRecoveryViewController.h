//
//  PasswordRecoveryViewController.h
//  Timepass
//
//  Created by jason on 10/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "MBProgressHUD.h"

@interface PasswordRecoveryViewController:TPScrollableViewController <UITextFieldDelegate, UIAlertViewDelegate, UITableViewDelegate> {
    NSString *email;
	
	UIButton *passwordRecovertBtn;
	
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *emailField;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

-(IBAction) passwordRecoveryBtnPressed:(id) sender;
-(void)sendPasswordRecoveryRequest;

@end