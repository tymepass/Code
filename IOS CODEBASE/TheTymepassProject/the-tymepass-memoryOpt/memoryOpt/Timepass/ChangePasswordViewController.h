//
//  ChangePasswordViewController.h
//  Timepass
//
//  Created by mac book pro on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "User.h"

@protocol ChangePasswordDelegate;

@protocol ChangePasswordDelegate<NSObject>
@required
- (void)setNewPassword:(NSString *) newPassword;
@end

@interface ChangePasswordViewController : TPScrollableViewController<UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    UITableView *tableView;
    
    UITextField *oldPasswordField;
    UITextField *passwordField;
    UITextField *passwordConfirmField; 
    
    UIButton *saveBtn;
    User *profileUser;
    
    id<ChangePasswordDelegate> changePasswordDelegate;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id<ChangePasswordDelegate> changePasswordDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
-(IBAction) changePassword:(id) sender;

@end
