//
//  RegistrationViewController.m
//  Registration
//
//  Created by Mac on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved./Users/mahmood1/Documents/tymepass/Timepass.xcodeproj
//

#import "SignUpViewController.h"
#import "UIViewFirstResponder.h"
#import "User+Management.h"
#import "SearchForFriendsViewController.h"
#import "Utils.h"
#import "Validation.h"
#import "GAEUtils.h"
#import "Location+Management.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>
#import"TimepassAppDelegate.h"

//static NSString* kAppId = @"210849718975311";

enum {
    SectionName                 = 0,
    SectionEmail                = 1,
    SectionPersonalDetails      = 2,
    SectionPassword             = 3,
    SectionsCount               = 4
};

enum {
    NameSectionFirstNameCell    = 0,
    NameSectionLastNameCell     = 1,
    NameSectionRowsCount        = 2
};

enum {
    EmailSectionEmailCell           = 0,
    EmailSectionEmailConfirmCell    = 1,
    EmailSectionRowsCount           = 2
};

enum {
    PersonalDetailsSectionDateOfBirthCell       = 0,
    PersonalDetailsSectionSexCell               = 1,
    PersonalDetailsSectionOccupationCell        = 2,
    PersonalDetailsSectionHomeLocationCell      = 3,
    PersonalDetailsSectionRowsCount             = 4
};

enum {
    PasswordSectionPasswordCell             = 0,
    PasswordSectionPasswordConfirmCell      = 1,
    PasswordSectionRowsCount                = 2
};

@implementation SignUpViewController;

@synthesize tableView;
@synthesize firstNameField,lastNameField,emailField,emailConfirmField,dateOfBirthField,sexField,occupationField,homeLocationField,passwordField,passwordConfirmField,addProfilePhotoBtn,createAccountBtn,popover,datePicker,sexPickerView;

@synthesize userOperation;
@synthesize HUD;
#pragma mark - Facebook API Calls

-(void)initView {
    listOfSexes = [[NSArray alloc] initWithObjects:@"Male",@"Female",@"I'd rather not say",nil];
    selectedSexIndex = 2;
    birthdateChanged = FALSE;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 840)];
    self.title = NSLocalizedString(@"Registration", @"Registration");
	
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    addProfilePhotoBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [addProfilePhotoBtn setFrame:CGRectMake(12.0, 35.0, 85.0, 85.0)];
    addProfilePhotoBtn.layer.cornerRadius = 5;
    [addProfilePhotoBtn setClipsToBounds: YES];
    [addProfilePhotoBtn setBackgroundImage:[UIImage imageNamed:@"default_profilepic.png"] forState:UIControlStateNormal];
    [addProfilePhotoBtn addTarget:self action:@selector(addProfilePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    createAccountBtn = [ApplicationDelegate.uiSettings createButton:@"Take the ride"];
    [createAccountBtn setFrame:CGRectMake(12.0, 15.0, 300.0, 30.0)];
    [createAccountBtn addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateComponents *nowComps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:1992];
    [comps setMonth:[nowComps month]];
    [comps setDay:[nowComps day]];
    
    birthdate = [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (void)viewDidUnload
{
    if (tableView)
        [self setTableView:nil];
    
    if (scrollView)
        [self setScrollView:nil];
    
    if (firstNameField)
        [self setFirstNameField:nil];
    
    if (lastNameField)
        [self setLastNameField:nil];
    
    if (emailField)
        [self setEmailField:nil];
    
    if (emailConfirmField)
        [self setEmailConfirmField:nil];
    
    if (dateOfBirthField)
        [self setDateOfBirthField:nil];
    
    if (sexField)
        [self setSexField:nil];
    
    if (occupationField)
        [self setOccupationField:nil];
    
    if (homeLocationField)
        [self setHomeLocationField:nil];
    
    if (passwordField)
        [self setPasswordField:nil];
    
    if (passwordConfirmField)
        [self setPasswordConfirmField:nil];
    
    if (addProfilePhotoBtn)
        [self setAddProfilePhotoBtn:nil];
    
    if (createAccountBtn)
        [self setCreateAccountBtn:nil];
    
    if (popover)
        [self setPopover:nil];
    
    if (datePicker)
        [self setDatePicker:nil];
    
    if (sexPickerView)
        [self setSexPickerView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [tableView flashScrollIndicators];
	
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.userOperation) {
        [self.userOperation cancel];
        self.userOperation = nil;
    }
    
    if (HUD)
        [self setHUD:nil];
	
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void) registerUser:(id) sender {
    if ([[firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0
        && [[lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You have to give a Name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1004;
        
		[alert show];
        
        return;
        
    }
    
    if(![Validation validateEmail:emailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You Entered Incorrect Email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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
    
    if(![passwordField.text isEqualToString:passwordConfirmField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Passwords do not match." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1002;
		
		[alert show];
        return;
    }
	
    User *newUser = [User checkExistsByEmailInCD:emailField.text  inContext:[modelUtils defaultManagedObjectContext]];
    
    if (newUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Registration Failed"
														message: [NSString stringWithFormat:@"User with email address %@ already exists!", emailField.text]
													   delegate: self
											  cancelButtonTitle: nil
											  otherButtonTitles: @"OK",nil];
        alert.tag = 1003;
        
        [alert show];
        
        return;
    }
    
	Location *newLocation;
    
    if ([[homeLocationField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        newLocation = [Location getLocationWithName:homeLocationField.text inContext:[modelUtils defaultManagedObjectContext]];
        
        if (!newLocation) {
            newLocation = (Location *)[Location insertLocationWithName:homeLocationField.text inContext:[modelUtils defaultManagedObjectContext]];
            
        }
    }
    
    //Encrypt password
    NSString* encryptedPass;
    
	encryptedPass = [Utils sha1:passwordField.text];
	
    //Save new user entity to core data
	
    newUser = [User insertUserWithEmail:emailField.text
								   name:firstNameField.text
								surname:lastNameField.text
							   password:encryptedPass
							 datOfBirth:birthdateChanged ? birthdate : nil
							 occupation:occupationField.text
								 gender:[NSNumber numberWithInt:selectedSexIndex]
								  photo:@""
						 homeLocationId:newLocation
							 facebookId:@"-1"];
	
	NSData *imageData = nil;
	if (imageChanged) {
		imageData = [NSData dataWithData:UIImagePNGRepresentation([addProfilePhotoBtn backgroundImageForState:UIControlStateNormal])];
		newUser.photoData = imageData;
	}
    
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Registering...";
    HUD.dimBackground = YES;
    
    NSLog(@"new user :%@",newUser);
    userOperation = [ApplicationDelegate.userEngine checkGAEUserWithEmail:emailField.text onCompletion:^(NSString *status) {
		if ([status isEqualToString:@"0"]) {
			userOperation = [ApplicationDelegate.userEngine insertGAEUserWithUser:newUser onCompletion:^(NSString *result) {
				[HUD setHidden:YES];
				
				if ([result intValue] > 0) {
					newUser.serverId = result;
					
					//succesful registration
					[[SingletonUser sharedUserInstance] setUser:newUser];
					
					[newUser setDateCreated:[NSDate date]];
					[newUser setIsLoggedIn:[NSNumber numberWithBool:YES]];
					[modelUtils commitDefaultMOC];
					
					NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
					[cacheStorage setObject:[newUser email] forKey:@"LastLoginEmail"];
					[cacheStorage synchronize];
					
					UIViewController *searchForFriendsViewController = [[SearchForFriendsViewController alloc] initWithNibName:@"SearchForFriendsViewController" bundle:nil settingsViewMode:NO];
					
					[self.navigationController pushViewController:searchForFriendsViewController animated:YES];
				} else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
																	message:@"A connection error occured. Please try again later." delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:@"OK", nil];
					[alert show];
					[modelUtils rollbackDefaultMOC];
				}
			} onError:^(NSError* error) {
				[HUD setHidden:YES];
				[modelUtils rollbackDefaultMOC];
			}];
		}
		else {
			[HUD setHidden:YES];
			
			UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle: @"Registration Failed"
									   message: [NSString stringWithFormat:@"User with email address %@ already exists!", emailField.text]
									  delegate: self
							 cancelButtonTitle: nil
							 otherButtonTitles: @"OK",nil];
			
			alert.tag = 1003;
			
			[alert show];
			
			[modelUtils rollbackDefaultMOC];
		}
	} onError:^(NSError* error) {
		[HUD setHidden:YES];
		[modelUtils rollbackDefaultMOC];
	}];
    
	
    //debugLog(@"Gae user inserted with id: %@", [newUser serverId]);
}

- (void) addProfilePhoto:(id) sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add a profile photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 || buttonIndex == 1) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Camera Not Available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    
    profilePhoto = image;
    
    //UIImage * resizedImage = [Utils imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(320.0, 320.0)];
    UIImage * resizedImage = [Utils resizedFromImage:image inPixes:[ApplicationDelegate.uiSettings profileImagePixels]];
    [addProfilePhotoBtn setBackgroundImage:resizedImage forState:UIControlStateNormal];
	
	imageChanged = TRUE;
	
    [picker dismissModalViewControllerAnimated:YES];
}

- (void) selectDateOfBirth:(id)sender
{
    birthdateChanged = TRUE;
	
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,250,0,0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDate:birthdate animated:NO];
    
    dateOfBirthField.inputView = datePicker;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    dateOfBirthField.text = [GAEUtils formatDateForGAE:birthdate];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails]];
    
    cell.detailTextLabel.text = [df stringFromDate:birthdate];
}

- (void) changeDate:(id) sender
{
    birthdateChanged = TRUE;
    birthdate = datePicker.date;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    dateOfBirthField.text = [GAEUtils formatDateForGAE:birthdate];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails]];
    cell.detailTextLabel.text = [df stringFromDate:birthdate];
}

- (void) selectSex:(id) sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    sexPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,250,0,0)];
    sexPickerView.delegate = self;
    sexPickerView.showsSelectionIndicator = YES;
    [sexPickerView selectRow:selectedSexIndex inComponent:0 animated:NO];
	
    sexField.inputView = sexPickerView;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails]];
    
    cell.detailTextLabel.text = [listOfSexes objectAtIndex:selectedSexIndex];
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

- (void) cancelRegistration:(id) sender
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
        case SectionName:
            return NameSectionRowsCount;
        case SectionEmail:
            return EmailSectionRowsCount;
        case SectionPersonalDetails:
            return PersonalDetailsSectionRowsCount;
        case SectionPassword:
            return PasswordSectionRowsCount;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case SectionName:
            return @"LET'S GET TO KNOW YOU, SHALL WE?";
        case SectionEmail:
            return @"DO YOU... ER... HAVE AN EMAIL?";
        case SectionPersonalDetails:
            return @"MAYBE THROW IN A LITTLE EXTRA?";
        case SectionPassword:
            //if we have facebook login no password shoulb be entered
            return @"ONE LAST THING... (YOU KNOW THE STORY)";
        default:
            break;
    }
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    
    switch (section) {
        case SectionName:
            headerLabel.text =  @"LET'S GET TO KNOW YOU, SHALL WE?";
            
            [headerView addSubview:headerLabel];
            
            return headerView;
        case SectionEmail:
            headerLabel.text =  @"DO YOU... ER... HAVE AN EMAIL?";
            
            [headerView addSubview:headerLabel];
            
            return headerView;
        case SectionPersonalDetails:  {
            headerLabel.text =  @"MAYBE THROW IN A LITTLE EXTRA?";
            headerDetailLabel.text =  @"(You can always add or edit these details later)";
            
            UILabel *lbl = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [lbl setFrame:CGRectMake(110.0, 65.0, 200.0, 20.0)];
            lbl.textColor = [[UIColor alloc] initWithRed:147.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0];
            lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerDetailFont] size:17.0];
            lbl.text =  @"Account Photo";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            [headerView addSubview:addProfilePhotoBtn];
            [headerView addSubview:lbl];
            
            return headerView;
        }
        case SectionPassword:
            headerLabel.text =  @"ONE LAST THING... (YOU KNOW THE STORY)";
            
            [headerView addSubview:headerLabel];
            
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
    [imageSeparator setFrame:CGRectMake(12.0, 5.0, 300.0, 2.0)];
    [footerView addSubview:imageSeparator];
    
    if (section == SectionPassword) {
        [footerView addSubview:createAccountBtn];
		
        return footerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionName) {
        switch (indexPath.row) {
            case NameSectionFirstNameCell:
                firstNameField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"First Name" inputAccessoryView:keyboardToolbar];
                [firstNameField setDelegate:self];
				firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
				
                firstNameField.text = firstName ? firstName : @"";
                
                [cell.contentView addSubview:firstNameField];
                break;
            case NameSectionLastNameCell:
                lastNameField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Last Name" inputAccessoryView:keyboardToolbar];
                [lastNameField setDelegate:self];
				lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                
                lastNameField.text = lastName ? lastName : @"";
                
                [cell.contentView addSubview:lastNameField];
                break;
            default:
                break;
        }
        
    } else if (indexPath.section == SectionEmail) {
        switch (indexPath.row) {
            case EmailSectionEmailCell:
                emailField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"email" inputAccessoryView:keyboardToolbar];
                emailField.keyboardType = UIKeyboardTypeEmailAddress;
                [emailField setDelegate:self];
                
                emailField.text = email ? email : @"";
                
                [cell.contentView addSubview:emailField];
                break;
            case EmailSectionEmailConfirmCell:
                emailConfirmField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"email confirm" inputAccessoryView:keyboardToolbar];
                emailConfirmField.keyboardType = UIKeyboardTypeEmailAddress;
                [emailConfirmField setDelegate:self];
                
                emailConfirmField.text = emailConfirm ? emailConfirm : @"";
                
                [cell.contentView addSubview:emailConfirmField];
                break;
            default:
                break;
        }
    } else if (indexPath.section == SectionPersonalDetails) {
        switch (indexPath.row) {
            case PersonalDetailsSectionDateOfBirthCell:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.text = @"Date of Birth";
                
                cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerDetailColorRed green:ApplicationDelegate.uiSettings.headerDetailColorGreen blue:ApplicationDelegate.uiSettings.headerDetailColorBlue alpha:1.0];
				
                if (birthdateChanged) {
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setDateFormat:@"dd-MM-yyyy"];
                    cell.detailTextLabel.text = [df stringFromDate:birthdate];
                } else {
                    cell.detailTextLabel.text = @"";
                }
                
                dateOfBirthField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"" inputAccessoryView:keyboardToolbar];
                [dateOfBirthField setDelegate:self];
                [dateOfBirthField setHidden:YES];
                [dateOfBirthField addTarget:self
                                     action:@selector(selectDateOfBirth:)
                           forControlEvents:UIControlEventEditingDidBegin];
                
                [cell.contentView addSubview:dateOfBirthField];
                break;
            case PersonalDetailsSectionSexCell:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                
                cell.textLabel.text = @"Sex";
                
                cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                cell.detailTextLabel.textColor  = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerDetailColorRed green:ApplicationDelegate.uiSettings.headerDetailColorGreen blue:ApplicationDelegate.uiSettings.headerDetailColorBlue alpha:1.0];//[UIColor darkGrayColor];
                cell.detailTextLabel.text = @"";
                
                sexField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"" inputAccessoryView:keyboardToolbar];
                [sexField setDelegate:self];
                [sexField setHidden:YES];
                [sexField addTarget:self
                             action:@selector(selectSex:)
                   forControlEvents:UIControlEventEditingDidBegin];
                
                [cell.contentView addSubview:sexField];
                break;
            case PersonalDetailsSectionOccupationCell:
                occupationField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Occupation" inputAccessoryView:keyboardToolbar];
                [occupationField setDelegate:self];
				occupationField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                
                [cell.contentView addSubview:occupationField];
                break;
            case PersonalDetailsSectionHomeLocationCell:
                homeLocationField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Home Location" inputAccessoryView:keyboardToolbar];
                [homeLocationField setDelegate:self];
				homeLocationField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                
                [cell.contentView addSubview:homeLocationField];
                break;
            default:
                break;
        }
    } else  {
        //if we have facebook login no password shoulb be entered
        switch (indexPath.row) {
            case PasswordSectionPasswordCell:
                passwordField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"password" inputAccessoryView:keyboardToolbar];
                passwordField.secureTextEntry = YES;
                [passwordField setDelegate:self];
                
                [cell.contentView addSubview:passwordField];
                break;
            case PasswordSectionPasswordConfirmCell:
                passwordConfirmField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"password confirm" inputAccessoryView:keyboardToolbar];
                passwordConfirmField.secureTextEntry = YES;
                [passwordConfirmField setDelegate:self];
                
                [cell.contentView addSubview:passwordConfirmField];
                break;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case SectionName:
            return 30.0;
            
        case SectionEmail:
            return 30.0;
            
        case SectionPersonalDetails:
            return 130.0;
            
        case SectionPassword:
            return 30.0;
            
        default:
            return 40.0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SectionPassword)
        return 60.0;
    
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionPersonalDetails) {
        if (indexPath.row == PersonalDetailsSectionSexCell) {
            [sexField becomeFirstResponder];
        } else if (indexPath.row == PersonalDetailsSectionDateOfBirthCell) {
            [dateOfBirthField becomeFirstResponder];
        }
    }
	
	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Button Actions
- (IBAction)nextPrevious:(id)sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
    
	UIView *responder = [self.view findFirstResponder];
	switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
		case 0:
			// previous
			if (responder == firstNameField) {
				[passwordConfirmField becomeFirstResponder];
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
                
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
                
			} else if (responder == occupationField) {
				[sexField becomeFirstResponder];
                
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
			} else if (responder == homeLocationField) {
				[occupationField becomeFirstResponder];
			} else if (responder == passwordField) {
				[homeLocationField becomeFirstResponder];
			} else if (responder == passwordConfirmField) {
				[passwordField becomeFirstResponder];
			} else {
                [responder resignFirstResponder];
            }
			break;
		case 1:
			// next
			if (responder == firstNameField) {
				[lastNameField becomeFirstResponder];
			} else if (responder == lastNameField) {
				[emailField becomeFirstResponder];
			} else if (responder == emailField) {
				[emailConfirmField becomeFirstResponder];
			} else if (responder == emailConfirmField) {
				[dateOfBirthField becomeFirstResponder];
                
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
			} else if (responder == dateOfBirthField) {
				[sexField becomeFirstResponder];
                
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO scrollPosition:UITableViewScrollPositionNone];
			} else if (responder == sexField) {
				[occupationField becomeFirstResponder];
			} else if (responder == occupationField) {
				[homeLocationField becomeFirstResponder];
			} else if (responder == homeLocationField) {
				[passwordField becomeFirstResponder];
			} else if (responder == passwordField) {
				[passwordConfirmField becomeFirstResponder];
			} else if (responder == passwordConfirmField) {
				[firstNameField becomeFirstResponder];
			} else {
                [responder resignFirstResponder];
            }
			break;
	}
}
#pragma mark - picker view delegate methods

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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails]];
    
    cell.detailTextLabel.text = [listOfSexes objectAtIndex:row];
    
    selectedSexIndex = row;
}

#pragma mark -  textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == dateOfBirthField)
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
    else if (textField == sexField)
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
    else {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
        
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
    }
    
    [scrollView adjustOffsetToIdealIfNeeded];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
    
    return YES;
}

- (void)dismissKeyboard:(id)sender
{
	[[self.view findFirstResponder] resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionDateOfBirthCell inSection:SectionPersonalDetails] animated:NO];
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:PersonalDetailsSectionSexCell inSection:SectionPersonalDetails] animated:NO];
	
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        if(alertView.tag == 1000 || alertView.tag == 1003) {
            if (alertView.tag == 1003)
                [emailConfirmField setText:@""];
            
            [emailField becomeFirstResponder];
            return;
        }
        
        if(alertView.tag == 1001) {
            [emailConfirmField becomeFirstResponder];
            return;
        }
        
        if(alertView.tag == 1002) {
            [passwordConfirmField becomeFirstResponder];
            return;
        }
        
        if(alertView.tag == 1004) {
            [firstNameField becomeFirstResponder];
            return;
        }
    }
}

@end
