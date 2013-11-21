//
//  EditMyProfileViewController.m
//  Timepass
//
//  Created by mac book pro on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditMyProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewFirstResponder.h"
#import "User+Management.h"
#import "Utils.h"
#import "Validation.h"
#import "GAEUtils.h"

enum {
    SectionProfilePhoto         = 0,
    SectionBasicInfo            = 1,
    SectionAdditionalInfo       = 2,
    SectionPasswordChange       = 3,
    SectionsCount               = 4
};

enum {
    ProfilePhotoSectionRowsCount        = 0
};

enum {
    BasicInfoSectionFirstNameCell       = 0,
    BasicInfoSectionLastNameCell        = 1,
    BasicInfoSectionEmailCell           = 2,
    BasicInfoSectionEmailConfirmCell    = 3,
    BasicInfoSectionRowsCount           = 4
};

enum {
    AdditionalInfoSectionDateOfBirthCell       = 0,
    AdditionalInfoSectionSexCell               = 1,
    AdditionalInfoSectionOccupationCell        = 2,
    AdditionalInfoSectionHomeLocationCell      = 3,
    AdditionalInfoSectionRowsCount             = 4
};

enum {
    PasswordChangeSectionRowsCount             = 1
};

@implementation EditMyProfileViewController;

@synthesize tableView;
@synthesize changePasswordViewController;
@synthesize userOperation;

-(void)initView {
    if (!profileUser)
        profileUser = [[SingletonUser sharedUserInstance] user];
	
    listOfSexes = [[NSArray alloc] initWithObjects:@"Male",@"Female",@"I'd rather not say",nil];
    selectedSexIndex = 0;
    
    userPropertiesChanged = FALSE;
    birthdateChanged = FALSE;
    password = profileUser.password;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        profileUser = user;
        isFB = FALSE;
        if (profileUser.facebookId != nil && [profileUser.facebookId isEqualToString:@"-1"] == FALSE) {
            isFB = TRUE;
        }
        
        isTW = FALSE;
        if (profileUser.twitterId != nil && [profileUser.twitterId isEqualToString:@"-1"] == FALSE) {
            isTW = TRUE;
        }
        
        [self initView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL) validateEmail:(NSString *) candidate{
    //TODO check why this function existed in .h and never implemented
    return true;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view from its nib.
    
    //[scrollView setFrame:[UIScreen mainScreen].applicationFrame];
    if (!isFB)
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 720)];
    else
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 580)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(updateUser:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    changeProfilePhotoBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [changeProfilePhotoBtn setFrame:CGRectMake(12.0, 0.0, 85.0, 85.0)];
    changeProfilePhotoBtn.layer.cornerRadius = 5;
    [changeProfilePhotoBtn setClipsToBounds: YES];
    
	[changeProfilePhotoBtn setBackgroundImage:[UIImage imageNamed:@"default_profilepic.png"] forState:UIControlStateNormal];
    if (profileUser.photo) {
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:profileUser.photo]];
		AFImageRequestOperation *operation;
		operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
			[changeProfilePhotoBtn setBackgroundImage:image forState:UIControlStateNormal];
		}];
		
		[operation start];
	}
	
    [changeProfilePhotoBtn addTarget:self action:@selector(changeProfilePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    saveBtn = [ApplicationDelegate.uiSettings createButton:@"Save Changes"];
    [saveBtn setFrame:CGRectMake(12.0, 20.0, 300., 30.0)];
    [saveBtn addTarget:self action:@selector(updateUser:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateComponents *nowComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:1992];
    [comps setMonth:[nowComps month]];
    [comps setDay:[nowComps day]];
    
    birthdate = [[NSCalendar currentCalendar] dateFromComponents:comps];
	
    if (profileUser.dateOfBirth)
        birthdate = profileUser.dateOfBirth;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"My Profile", @"My Profile");
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [tableView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = Nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.userOperation) {
        [self.userOperation cancel];
        self.userOperation = nil;
    }
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void) updateUser:(id) sender {
    if ([[firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0
        && [[lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You have to give a Name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1002;
        
		[alert show];
        
        return;
        
    }
    
    
    if (!isFB) {
        if (![emailField.text isEqualToString:profileUser.email]) {
            if(![Validation validateEmail:emailField.text]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You Enter Incorrect Email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = 1000;
				
                [alert show];
                
                return;
            }
            
            if(![emailField.text isEqualToString:emailConfirmField.text]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"E-mails do not match." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = 1001;
				
                [alert show];
                
                return;
            }
        }
    }
    
    //Update User
    if (profileUser) {
        Location *location = profileUser.homeLocationId;
        
        if (location && ![homeLocationField.text isEqualToString:location.name]) {
            //check location
            location = [self updateLocation:homeLocationField.text];
            
            userPropertiesChanged = TRUE;
        }
        
        if (!location && [[homeLocationField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            location = [self updateLocation:homeLocationField.text];
			userPropertiesChanged = TRUE;
        }
        
        if (![firstNameField.text isEqualToString:profileUser.name] || ![lastNameField.text isEqualToString:profileUser.surname] || ![birthdate isEqualToDate:profileUser.dateOfBirth] || ![[NSNumber numberWithInt:selectedSexIndex] isEqualToNumber:profileUser.gender] || ![occupationField.text isEqualToString:profileUser.occupation]) {
            
            userPropertiesChanged = TRUE;
        }
		
		BOOL emailchanged = false;
		if (!isFB) {
			if (![emailField.text isEqualToString:profileUser.email]) {
				userPropertiesChanged = TRUE;
				emailchanged = TRUE;
				
			}
		}
        
        if (userPropertiesChanged) {
			
			if (imageChanged) {
				NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([changeProfilePhotoBtn backgroundImageForState:UIControlStateNormal])];
				
				profileUser.photoData = imageData;
			}
            
			if (emailchanged) {
				[User updateUser:profileUser
						withName:firstNameField.text
						 surname:lastNameField.text
						   email:emailField.text
						password:password
					 dateOfBirth:birthdateChanged ? birthdate : nil
					  occupation:occupationField.text
						  gender:[NSNumber numberWithInt:selectedSexIndex]
						   photo:profileUser.photo
				  homeLocationId:location
					  facebookId:profileUser.facebookId
					   twitterId:profileUser.twitterId
					dateModified:[NSDate date]
					   updateGAE:TRUE];
			} else {
				[User updateUser:profileUser
						withName:firstNameField.text
						 surname:lastNameField.text
						password:password
					 dateOfBirth:birthdateChanged ? birthdate : nil
					  occupation:occupationField.text
						  gender:[NSNumber numberWithInt:selectedSexIndex]
						   photo:profileUser.photo
				  homeLocationId:location
					  facebookId:profileUser.facebookId
					   twitterId:profileUser.twitterId
					dateModified:[NSDate date]
					   updateGAE:TRUE];
			}
            
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
            HUD.labelText = @"Saving changes...";
            HUD.dimBackground = YES;
            
            userOperation = [ApplicationDelegate.userEngine updateGAEUserWithUser:profileUser onCompletion:^(NSString *result) {
				if ([result intValue] != 400) {
					[modelUtils commitDefaultMOC];
					
					if (emailchanged) {
						NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
						[cacheStorage setObject:[profileUser email] forKey:@"LastLoginEmail"];
						[cacheStorage synchronize];
					}
				}
				
				[HUD setHidden:YES];
				[self.navigationController popViewControllerAnimated:YES];
			} onError:^(NSError* error) {
				[modelUtils rollbackDefaultMOC];
				
				[HUD setHidden:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
		}
    }
}

- (void) changeProfilePhoto:(id) sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add a profile photo"
															delegate:self
												   cancelButtonTitle:@"Cancel"
											  destructiveButtonTitle:nil
												   otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 || buttonIndex == 1) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
	
	imageChanged = TRUE;
    
    profilePhoto = image;
    UIImage * resizedImage = [Utils resizedFromImage:image inPixes:[ApplicationDelegate.uiSettings profileImagePixels]];
    
    [changeProfilePhotoBtn setBackgroundImage:resizedImage forState:UIControlStateNormal];
    [picker dismissModalViewControllerAnimated:YES];
    
    userPropertiesChanged = TRUE;
}

- (void) selectDateOfBirth:(id)sender
{
    birthdateChanged = TRUE;
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionAdditionalInfo] animated:NO];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionAdditionalInfo] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,250,0,0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDate:birthdate animated:NO];
    
    dateOfBirthField.inputView = datePicker;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    dateOfBirthField.text = [GAEUtils formatDateForGAE:birthdate];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionAdditionalInfo]];
    
    cell.detailTextLabel.text = [df stringFromDate:birthdate];
}

- (void) changeDate:(id) sender
{
    birthdateChanged = TRUE;
    birthdate = datePicker.date;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionAdditionalInfo]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    cell.detailTextLabel.text = [df stringFromDate:birthdate];
    
    birthdate = datePicker.date;
}

- (void) selectSex:(id) sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionAdditionalInfo] animated:NO];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionAdditionalInfo] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    sexPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,250,0,0)];
    sexPickerView.delegate = self;
    sexPickerView.showsSelectionIndicator = YES;
    [sexPickerView selectRow:selectedSexIndex inComponent:0 animated:NO];
	
    sexField.inputView = sexPickerView;
}

- (void) selectHomeLocation:(id)sender
{
    /*datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,250,0,0)];
     mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 250, datePicker.frame.size.width,datePicker.frame.size.height)];
     mapView.showsUserLocation = YES;
     
     homeLocationField.inputView = mapView;*/
}

- (void) selectCurrentLocation:(id)sender
{
    /* datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,250,0,0)];
     mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 250, datePicker.frame.size.width,datePicker.frame.size.height)];
     mapView.showsUserLocation = YES;
     
     currentLocationField.inputView = mapView;*/
}

- (void) cancelUpdate:(id) sender
{
    //[self dismissModalViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionProfilePhoto:
            return ProfilePhotoSectionRowsCount;
        case SectionBasicInfo:
            if (!isFB)
                return BasicInfoSectionRowsCount;
            else
                return 2;
        case SectionAdditionalInfo:
            return AdditionalInfoSectionRowsCount;
        case SectionPasswordChange:
            if (!isFB && !isTW)
                return PasswordChangeSectionRowsCount;
            else
                return 0;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    switch (section) {
        case SectionProfilePhoto: {
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",profileUser.name,profileUser.surname];
            
            UILabel *lbl = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [lbl setFrame:CGRectMake(110.0, 30.0, 200.0, 20.0)];
            lbl.textColor = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerColorRed
												   green:ApplicationDelegate.uiSettings.headerColorGreen
													blue:ApplicationDelegate.uiSettings.headerColorBlue alpha:1.0];
			
            lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:17.0];
            lbl.text = fullName;
            
            [headerView addSubview:changeProfilePhotoBtn];
            [headerView addSubview:lbl];
            
            return headerView;
        }
        case SectionBasicInfo: {
            headerLabel.text = @"BASIC INFO";
            [headerView addSubview:headerLabel];
            
            return headerView;
        }
        case SectionAdditionalInfo:
            headerLabel.text = @"ADDITIONAL INFO";
            [headerView addSubview:headerLabel];
            
            return headerView;
        case SectionPasswordChange:  {
            if (!isFB) {
                headerLabel.text = @"PASSWORD CHANGE";
                [headerView addSubview:headerLabel];
				
                return headerView;
            } else
                return nil;
        }
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    if (!isFB) {
        if (section == SectionPasswordChange) {
            
            UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
            [imageSeparator setFrame:CGRectMake(12.0, 10.0, 300.0, 2.0)];
            [footerView addSubview:imageSeparator];
            
            [footerView addSubview:saveBtn];
            
            return footerView;
        }
    }
    else {
        if (section == SectionAdditionalInfo) {
            
            UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
            [imageSeparator setFrame:CGRectMake(12.0, 12.0, 300.0, 2.0)];
            [footerView addSubview:imageSeparator];
            
            [footerView addSubview:saveBtn];
            
            return footerView;
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionBasicInfo) {
        switch (indexPath.row) {
            case BasicInfoSectionFirstNameCell:
                firstNameField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"First Name" inputAccessoryView:keyboardToolbar];
                [firstNameField setDelegate:self];
                
                firstNameField.text = profileUser.name;
                
                [cell.contentView addSubview:firstNameField];
                break;
            case BasicInfoSectionLastNameCell:
                lastNameField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Last Name" inputAccessoryView:keyboardToolbar];
                [lastNameField setDelegate:self];
                
                lastNameField.text = profileUser.surname;
                
                [cell.contentView addSubview:lastNameField];
                break;
            case BasicInfoSectionEmailCell:
                emailField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"email" inputAccessoryView:keyboardToolbar];
                emailField.keyboardType = UIKeyboardTypeEmailAddress;
                [emailField setDelegate:self];
                
                emailField.text = profileUser.email;
				
                [cell.contentView addSubview:emailField];
                break;
            case BasicInfoSectionEmailConfirmCell:
                emailConfirmField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"email confirmation" inputAccessoryView:keyboardToolbar];
                emailConfirmField.keyboardType = UIKeyboardTypeEmailAddress;
                [emailConfirmField setDelegate:self];
                
                [cell.contentView addSubview:emailConfirmField];
                break;
            default:
                break;
        }
    } else if (indexPath.section == SectionAdditionalInfo) {
        switch (indexPath.row) {
            case AdditionalInfoSectionDateOfBirthCell: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.text = @"Date of Birth";
                
                cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"dd-MM-yyyy"];
                
                cell.detailTextLabel.text = [df stringFromDate:profileUser.dateOfBirth];
                
                dateOfBirthField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"" inputAccessoryView:keyboardToolbar];
                [dateOfBirthField setDelegate:self];
                [dateOfBirthField setHidden:YES];
                [dateOfBirthField addTarget:self
                                     action:@selector(selectDateOfBirth:)
                           forControlEvents:UIControlEventEditingDidBegin];
				
                dateOfBirthField.text = [GAEUtils formatDateForGAE:profileUser.dateOfBirth];
                birthdate = profileUser.dateOfBirth;
                
                [cell.contentView addSubview:dateOfBirthField];
                break;
            }
            case AdditionalInfoSectionSexCell:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                
                cell.textLabel.text = @"Sex";
                
                cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.detailTextLabel.textColor  = [UIColor darkGrayColor];
                cell.detailTextLabel.text = @"";
                
                cell.detailTextLabel.text = [listOfSexes objectAtIndex:[profileUser.gender intValue]];
				
                sexField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"" inputAccessoryView:keyboardToolbar];
                [sexField setDelegate:self];
                [sexField setHidden:YES];
                [sexField addTarget:self
                             action:@selector(selectSex:)
                   forControlEvents:UIControlEventEditingDidBegin];
                
                [cell.contentView addSubview:sexField];
                break;
            case AdditionalInfoSectionOccupationCell:
                occupationField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Occupation" inputAccessoryView:keyboardToolbar];
                [occupationField setDelegate:self];
                
                occupationField.text = profileUser.occupation;
                
                [cell.contentView addSubview:occupationField];
                break;
            case AdditionalInfoSectionHomeLocationCell:
                homeLocationField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Home Location" inputAccessoryView:keyboardToolbar];
                [homeLocationField setDelegate:self];
                
                homeLocationField.text = profileUser.homeLocationId.name;
                
                [cell.contentView addSubview:homeLocationField];
                break;
            default:
                break;
        }
    } else  {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        cell.textLabel.text = @"Change Password";
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionProfilePhoto)
        return 90.0;
    
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SectionProfilePhoto)
        return 0.0;
    
    if (!isFB) {
        if (section == SectionPasswordChange)
            return 60.0;
    }
    else {
        if (section == SectionAdditionalInfo)
            return 60.0;
    }
	
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionAdditionalInfo) {
        if (indexPath.row == AdditionalInfoSectionSexCell) {
            [sexField becomeFirstResponder];
        } else if (indexPath.row == AdditionalInfoSectionDateOfBirthCell) {
            [dateOfBirthField becomeFirstResponder];
        }
    } else if (indexPath.section == SectionPasswordChange) {
		changePasswordViewController = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil user:profileUser];
        
        [changePasswordViewController setChangePasswordDelegate:self];
        
        [self.navigationController pushViewController:changePasswordViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Button Actions
- (IBAction)nextPrevious:(id)sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO];
    
	UIView *responder = [self.view findFirstResponder];
	switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
		case 0:
			// previous
            if (!isFB) {
                if (responder == firstNameField) {
                    [occupationField becomeFirstResponder];
                } else if (responder == lastNameField) {
                    [firstNameField becomeFirstResponder];
                } else if (responder == emailField) {
                    [lastNameField becomeFirstResponder];
                } else if (responder == emailConfirmField) {
                    [emailField becomeFirstResponder];
                } else if (responder == dateOfBirthField) {
                    [emailConfirmField becomeFirstResponder];
                } else if (responder == sexField) {
                    [dateOfBirthField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    
                } else if (responder == occupationField) {
                    [sexField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == homeLocationField) {
                    [occupationField becomeFirstResponder];
                } else {
                    [responder resignFirstResponder];
                }
            } else {
                if (responder == firstNameField) {
                    [occupationField becomeFirstResponder];
                } else if (responder == lastNameField) {
                    [firstNameField becomeFirstResponder];
                } else if (responder == dateOfBirthField) {
                    [lastNameField becomeFirstResponder];
                } else if (responder == sexField) {
                    [dateOfBirthField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    
                } else if (responder == occupationField) {
                    [sexField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == homeLocationField) {
                    [occupationField becomeFirstResponder];
                } else {
                    [responder resignFirstResponder];
                }
            }
			break;
		case 1:
			// next
            if (!isFB) {
                if (responder == firstNameField) {
                    [lastNameField becomeFirstResponder];
                } else if (responder == lastNameField) {
                    [emailField becomeFirstResponder];
                } else if (responder == emailField) {
                    [emailConfirmField becomeFirstResponder];
                } else if (responder == emailConfirmField) {
                    [dateOfBirthField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == dateOfBirthField) {
                    [sexField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == sexField) {
                    [occupationField becomeFirstResponder];
                } else if (responder == occupationField) {
                    [homeLocationField becomeFirstResponder];
                } else if (responder == homeLocationField) {
                    [firstNameField becomeFirstResponder];
                } else {
                    [responder resignFirstResponder];
                }
            } else {
                if (responder == firstNameField) {
                    [lastNameField becomeFirstResponder];
                } else if (responder == lastNameField) {
                    [dateOfBirthField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == dateOfBirthField) {
                    [sexField becomeFirstResponder];
                    
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO scrollPosition:UITableViewScrollPositionNone];
                } else if (responder == sexField) {
                    [occupationField becomeFirstResponder];
                } else if (responder == occupationField) {
                    [homeLocationField becomeFirstResponder];
                } else if (responder == homeLocationField) {
                    [firstNameField becomeFirstResponder];
                } else {
                    [responder resignFirstResponder];
                }
            }
			break;
	}
}
#pragma mark

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [listOfSexes count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [listOfSexes objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionAdditionalInfo]];
    cell.detailTextLabel.text = [listOfSexes objectAtIndex:row];
    
    selectedSexIndex = row;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == dateOfBirthField)
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO];
    else if (textField == sexField)
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO];
    else {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO];
        
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO];
    }
    
    [scrollView adjustOffsetToIdealIfNeeded];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO];
    
    return YES;
}

- (void)dismissKeyboard:(id)sender
{
	[[self.view findFirstResponder] resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionDateOfBirthCell inSection:SectionPasswordChange] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:AdditionalInfoSectionSexCell inSection:SectionPasswordChange] animated:NO];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        if (alertView.tag == 1000) {
            [emailField becomeFirstResponder];
            return;
        }
        
        if (alertView.tag == 1001) {
            [emailConfirmField becomeFirstResponder];
            return;
        }
        
        if (alertView.tag == 1002) {
            [firstNameField becomeFirstResponder];
            return;
        }
    }
}

- (Location *) updateLocation:(NSString *) location{
    Location *newLocation = [Location getLocationWithName:location inContext:[modelUtils defaultManagedObjectContext]];
    
    if (newLocation) {
        //debugLog(@"Location :%@", [newLocation name]);
        return newLocation;
        
    }
    
    newLocation = (Location *)[Location insertLocationWithName:location inContext:[modelUtils defaultManagedObjectContext]];
    //debugLog(@"Location :%@", [newLocation name]);
    
    return newLocation;
}

- (void) setNewPassword:(NSString *)newPassword {
	password = [Utils sha1:newPassword];
    userPropertiesChanged = TRUE;
}

@end