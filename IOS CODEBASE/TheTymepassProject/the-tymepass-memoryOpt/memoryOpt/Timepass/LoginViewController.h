//
//  LoginViewController1.h
//  Timepass
//
//  Created by Mahmood1 on 27/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController<UITableViewDelegate,UITextFieldDelegate> {
    UITableView *tableView;
    
    UITableViewCell *emailCell;
    UITableViewCell *passwordCell;
    
    UITextField *emailField;
    UITextField *passwordField;
    
    UIButton *forgotYourPwdBtn;
    UIButton *facebookSignInBtn;
    UIButton *logintBtn;
    
    NSManagedObjectContext *managedObjectContext;
    
    Facebook *facebook;
    NSArray *fbPermissions;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(IBAction) loginBtnPressed:(id) sender;
- (void) loginUserWithEmail:(NSString *) email;
- (void) doLogin:(User *) loggedUser;

@end
