//
//  MembersLoginViewController.h
//  Registration
//
//  Created by Mac on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "MBProgressHUD.h"

@interface MembersLoginViewController : UIViewController<UITableViewDelegate, FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
    UIScrollView *scrollView;
    UITableView *tableView;
    
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *emailConfirm;
    NSString *dateOfBirth;
    NSString *sex;
    NSString *occupation;
    NSString *homeLocation;
    NSString *facebookId;
    UIImage *profilePhoto;
    
    NSString *twitterId;
    
    int selectedSexIndex;
    NSDate *birthdate;
        
    UITableViewCell *signUpCell;
    
    UITableViewCell *logInCell;
    
    UITableViewCell *loginWithFacebookCell;
    UITableViewCell *loginWithTwitterCell;
    
    UITableViewCell *startWithoutSignUpCell;

    UIViewController *signUpViewController;
    UIViewController *logInViewController;
    
    apiCall currentAPICall;
    
    NSMutableData *responseData;
    NSDictionary *results;
}

@property (nonatomic, strong) NSDictionary *results;
@property (nonatomic,retain)  NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, retain) NSMutableArray *fbData;
@property (nonatomic, retain) NSString *facebookId;
@property (nonatomic, retain) NSString *twitterId;
@property (nonatomic, retain) NSArray *fbPermissions;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

- (void) initCells;
- (void)apiFQLIMe;

- (void)doLoginWithFacebook;
- (void)doLoginWithTwitter;

- (void) registerUser;
- (void) doRegister:(User *) loggedUser;
- (void) doLogin:(User *) loggedUser;
- (void) loginUserWithEmail:(NSString *) email;

@end
