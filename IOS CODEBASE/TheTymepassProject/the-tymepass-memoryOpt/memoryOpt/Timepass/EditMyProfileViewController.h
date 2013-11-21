//
//  EditMyProfileViewController.h
//  Timepass
//
//  Created by mac book pro on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
#import "Location+Management.h"
#import "ChangePasswordViewController.h"

@interface EditMyProfileViewController : TPScrollableViewController <UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIAlertViewDelegate, UITableViewDelegate,ChangePasswordDelegate> {
    UITableView *tableView;
    
    UITextField *firstNameField;
    UITextField *lastNameField;
    UITextField *emailField;
    UITextField *emailConfirmField;
    UITextField *dateOfBirthField;
    UITextField *sexField;
    UITextField *occupationField;
    UITextField *homeLocationField;
    NSString *password;

    UIImage *profilePhoto;
    UIButton *changeProfilePhotoBtn;
    UIButton *saveBtn;
    
    UIPopoverController *popover;
    UIDatePicker *datePicker;
    UIPickerView *sexPickerView;
    
    NSArray *listOfSexes;
    
    User *profileUser;
    BOOL isFB;
    BOOL isTW;
    
    ChangePasswordViewController *changePasswordViewController;
    
    int selectedSexIndex;
    BOOL birthdateChanged;
    NSDate *birthdate;
        
    BOOL userPropertiesChanged;
	BOOL imageChanged;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) ChangePasswordViewController *changePasswordViewController;

@property (nonatomic, strong) MKNetworkOperation *userOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
-(void) updateUser:(id) sender;
-(IBAction) changeProfilePhoto:(id) sender;
-(IBAction) cancelUpdate:(id) sender;
-(IBAction) nextPrevious:(id)sender;
-(IBAction) selectDateOfBirth:(id) sender;
-(IBAction) selectSex:(id) sender;
-(IBAction) selectHomeLocation:(id) sender;

-(BOOL) validateEmail:(NSString *) candidate;
- (Location *) updateLocation:(NSString *) location;
@end
