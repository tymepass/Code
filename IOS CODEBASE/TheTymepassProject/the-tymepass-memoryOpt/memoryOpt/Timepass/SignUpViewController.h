//
//  RegistrationViewController.h
//  Registration
//
//  Created by Mac on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollableViewController.h"
//#import "MapKit/MapKit.h"
#import "MBProgressHUD.h"

@class SA_OAuthTwitterEngine;
@interface SignUpViewController : TPScrollableViewController <UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIAlertViewDelegate, UITableViewDelegate> {
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *emailConfirm;
    NSString *dateOfBirth;
    NSString *sex;
    NSString *occupation;
    NSString *homeLocation;
    UIImage *profilePhoto;
    NSMutableData *responseData;
    //MKMapView *mapView;
    
    NSArray *listOfSexes;
    NSManagedObjectContext *managedObjectContext;
    
    int selectedSexIndex;
    BOOL birthdateChanged;
    NSDate *birthdate;
	BOOL imageChanged;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *firstNameField;
@property (nonatomic, strong) IBOutlet UITextField *lastNameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *emailConfirmField;
@property (nonatomic, strong) IBOutlet UITextField *dateOfBirthField;
@property (nonatomic, strong) IBOutlet UITextField *sexField;
@property (nonatomic, strong) IBOutlet UITextField *occupationField;
@property (nonatomic, strong) IBOutlet UITextField *homeLocationField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *passwordConfirmField;
@property (nonatomic, strong) IBOutlet UIButton *addProfilePhotoBtn;
@property (nonatomic, strong) IBOutlet UIButton *createAccountBtn;
@property (nonatomic, strong) IBOutlet UIPopoverController *popover;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIPickerView *sexPickerView;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *userOperation;

//constructor for facebook login
-(void) registerUser:(id) sender;
-(IBAction) addProfilePhoto:(id) sender;
-(IBAction) cancelRegistration:(id) sender;
-(IBAction) nextPrevious:(id)sender;
-(IBAction) selectDateOfBirth:(id) sender;
-(IBAction) selectSex:(id) sender;
-(IBAction) selectHomeLocation:(id) sender;

-(BOOL) validateEmail:(NSString *) candidate;
@end