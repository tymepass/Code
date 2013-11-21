//
//  LoginViewController1.m
//  Timepass
//
//  Created by Mahmood1 on 27/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "TileScreenController.h"
#import "PasswordRecoveryViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "UIViewFirstResponder.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "GlobalData.h"
#import "Validation.h"

enum {
    SectionCredentials          = 0,
    //SectionFBCredentials        = 1,
    SectionsCount               = 2
};

enum {
    CredentialsSectionEmailCell         = 0,
    CredentialsSectionPasswordCell      = 1,
    CredentialsSectionRowsCount         = 2
};

TileScreenController *tileScreenController;

@implementation LoginViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Initialize permissions
    fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", @"status_update", @"publish_stream", @"email", nil];
    
    [emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    forgotYourPwdBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [forgotYourPwdBtn setFrame:CGRectMake(self.view.frame.size.width - 55.0, 10.0, 45.0, 44.0)];
    forgotYourPwdBtn.layer.cornerRadius = 6;
    [forgotYourPwdBtn setClipsToBounds: YES];
    [forgotYourPwdBtn setBackgroundImage:[UIImage imageNamed:@"email.png"] forState:UIControlStateNormal];
    [forgotYourPwdBtn setBackgroundImage:[UIImage imageNamed:@"email_pressed.png"] forState:UIControlStateHighlighted];
    [forgotYourPwdBtn addTarget:self action:@selector(forgotPassword:)  forControlEvents:UIControlEventTouchUpInside];
    
    logintBtn = [ApplicationDelegate.uiSettings createButton:@"Login"];
    [logintBtn addTarget:self action:@selector(loginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Log In", @"Log In");
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	self.title = nil;
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Action Methods

- (void) forgotPassword:(id)sender {
    PasswordRecoveryViewController *controller = [[PasswordRecoveryViewController alloc] initWithNibName:@"PasswordRecoveryViewController" bundle:nil];
	
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginBtnPressed:(id) sender {
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    if(![Validation validateEmail:emailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You Entered Incorrect Email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1000;
        
		[alert show];
        [emailField becomeFirstResponder];
        return;
    }
    
    if ([passwordField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You have to give password." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1002;
        
		[alert show];
        [passwordField becomeFirstResponder];
        return;
    }
    
    NSString* encryptedPass = [Utils sha1:passwordField.text];
    User * loggedUser = [User loginUser:emailField.text password:encryptedPass];
    
    if (loggedUser == nil)
        return;
    
    [self doLogin:loggedUser];
}

- (void) loginUserWithEmail:(NSString *) email{
    User *loggedUser = (User *)[User getUserWithEmail:email];
    
    if (loggedUser)
        [self doLogin:loggedUser];
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oooops!"
                                                        message:@"The login info you gave\n is not quite right.\n Please, give it another go!"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Try again",nil];
		[alert show];
    }
}


- (void) doLogin:(User *) loggedUser{
    //Get the user from core data
    [[SingletonUser sharedUserInstance] setUser:loggedUser];
    //debugLog(@"%@",[loggedUser name]);
    
    [loggedUser setIsLoggedIn:[NSNumber numberWithBool:YES]];
    [modelUtils commitDefaultMOC];
    
    NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
    [cacheStorage setObject:[loggedUser email] forKey:@"LastLoginEmail"];
    [cacheStorage synchronize];
    
    [[SingletonUser sharedUserInstance] setGaeFriends:nil];
    
    if (loggedUser && [loggedUser serverId])
        [ApplicationDelegate.userEngine getGAEFriendKeysOfUser:loggedUser];
    
    //Sync after login
    [[GlobalData sharedGlobalData] setSync:TRUE];
    [[GlobalData sharedGlobalData] setGetGAEFriends:FALSE];
    
    //TODO consider asking from the server the user details if they are not in core data
    tileScreenController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
    
    //remove all screens from navigation array
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //change root controller
    [ApplicationDelegate changeNavigationRoot:tileScreenController];
    
    if (!ApplicationDelegate.loadingView) {
        ApplicationDelegate.loadingView = [[UIImageView alloc] initWithFrame:ApplicationDelegate.navigationController.self.view.bounds];
		
		UIImage* myImage;
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
			myImage = [UIImage imageNamed:@"Default-568h@2x.png"];
		} else {
			myImage = [UIImage imageNamed:@"Default.png"];
		}
		
		[ApplicationDelegate.loadingView setImage:myImage];
        
        [ApplicationDelegate.navigationController.view addSubview:ApplicationDelegate.loadingView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (alertView.tag == 1000){
        if (buttonIndex == 0) {
            [passwordField becomeFirstResponder];
            return;
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CredentialsSectionRowsCount;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case SectionCredentials:
            return @"LOGIN";
        /*case SectionFBCredentials:
            return @"LOGIN USING FACEBOOK";*/
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
        case SectionCredentials:    {
            headerLabel.text =  @"LOGIN";
            headerDetailLabel.text =  @"(We are always happy to see you)";
			
			headerDetailLabel.font = [UIFont boldSystemFontOfSize:11.0];
			headerDetailLabel.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        }
            /*case SectionFBCredentials:
             headerLabel.text =  @"LOGIN USING FACEBOOK";
             headerDetailLabel.text =  @"(and experience Tymepass jacked to the max!)";
             
             [headerView addSubview:headerLabel];
             [headerView addSubview:headerDetailLabel];
             [headerView addSubview:facebookSignInBtn];
             return headerView;*/
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    if (section == SectionCredentials) {
        UILabel *lbl1 = [ApplicationDelegate.uiSettings createTableViewFooterLabel];
        [lbl1 setFrame:CGRectMake(self.view.frame.size.width - 55.0 - [@"Forgot your password?" length] - 135, 15.0, 200.0, 20.0)];
        lbl1.text =  @"Forgot your password?";
        
        UILabel *lbl2 = [ApplicationDelegate.uiSettings createTableViewFooterDetailLabel];
        [lbl2 setFrame:CGRectMake(self.view.frame.size.width - 55.0 - [@"Forgot your password?" length] - 135, 30.0, 200.0, 20.0)];
        lbl2.text =  @"We'll send you an email";
        
        [footerView addSubview:forgotYourPwdBtn];
        [footerView addSubview:lbl1];
        [footerView addSubview:lbl2];
        
        UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(12.0, 65.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        [logintBtn setFrame:CGRectMake(12.0, 80.0, 300.0, 30.0)];
        [footerView addSubview:logintBtn];
        [footerView bringSubviewToFront:logintBtn];
        
        return footerView;
    }
    /*else if(section == SectionFBCredentials){
        
    }*/
    
    return nil;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionCredentials) {
        switch (indexPath.row) {
            case CredentialsSectionEmailCell:
                emailField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width
                                                                      textHeight:cell.frame.size.height
                                                                     placeholder:@"E-mail"
                                                              inputAccessoryView:nil];
                emailField.tag = 1;
                emailField.keyboardType = UIKeyboardTypeEmailAddress;
                emailField.returnKeyType = UIReturnKeyNext;
                
                [emailField setDelegate:self];
                [emailField addTarget:self
                               action:@selector(changeEmailField:)
                     forControlEvents:UIControlEventEditingDidBegin];
                [emailField addTarget:self
                               action:@selector(changeEmailField:)
                     forControlEvents:UIControlEventEditingDidEnd];
                [emailField addTarget:self
                               action:@selector(moveNext:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
                
                [cell.contentView addSubview:emailField];
                break;
            case CredentialsSectionPasswordCell:
                passwordField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width
                                                                         textHeight:cell.frame.size.height
                                                                        placeholder:@"Password"
                                                                 inputAccessoryView:nil];
                passwordField.tag = 2;
                passwordField.secureTextEntry = YES;
                passwordField.returnKeyType = UIReturnKeyDone;
                
                [passwordField setDelegate:self];
                [passwordField addTarget:self
                                  action:@selector(changePasswordField:)
                        forControlEvents:UIControlEventEditingDidBegin];
                [passwordField addTarget:self
                                  action:@selector(changePasswordField:)
                        forControlEvents:UIControlEventEditingDidEnd];
                [passwordField addTarget:self
                                  action:@selector(moveNext:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
                
                [cell.contentView addSubview:passwordField];
                break;
        }
    }
    else
        cell.hidden = YES;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    /*if (section == SectionFBCredentials)
        return 130.0;*/
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SectionCredentials)
        return 130.0;
    
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark -
#pragma mark UITextField Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView *responder = [self.view findFirstResponder];
    
    if (responder == emailField) {
		return YES;
	} else {
        if ([passwordField.text length] == 0) {
            return NO;
        } else {
            if ([emailField.text length] == 0) {
                [emailField becomeFirstResponder];
                return NO;
            } else {
                //[self loginBtn];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                return YES;
            }
        }
    }
    
	return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == passwordField) {
        if ([emailField.text length] == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}


- (void) changeEmailField:(id) sender
{
    if ([@"\n" isEqualToString:passwordField.text]) {
        [passwordField becomeFirstResponder];
        return;
    }
    
    if ([emailField.text length] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void) changePasswordField:(id) sender
{
    if ([@"\n" isEqualToString:passwordField.text]) {
        if ([emailField.text length] == 0) {
            [emailField becomeFirstResponder];
        }
        
        return;
    }
    
    if ([passwordField.text length] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (IBAction)moveNext:(id)sender
{
	UIView *responder = [self.view findFirstResponder];
    
    if (responder == emailField) {
		[passwordField becomeFirstResponder];
	} else if (responder == passwordField) {
        if ([emailField.text length] == 0) {
            [emailField becomeFirstResponder];
        } else {
            [responder resignFirstResponder];
        }
	}
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
}

- (void) hideKeyboard {
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
}

@end
