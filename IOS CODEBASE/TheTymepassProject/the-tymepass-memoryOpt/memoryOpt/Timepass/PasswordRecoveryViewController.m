//
//  PasswordRecoveryViewController.m
//  Timepass
//
//  Created by jason on 10/10/12.
//
//

#import "PasswordRecoveryViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "UIViewFirstResponder.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "GlobalData.h"
#import "Validation.h"

enum {
    SectionCredentials          = 0,
    SectionsCount               = 1
};

enum {
    CredentialsSectionEmailCell         = 0,
    CredentialsSectionRowsCount         = 1
};

@implementation PasswordRecoveryViewController

@synthesize tableView;
@synthesize emailField;
@synthesize userOperation;
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Recovery", @"Recovery");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
	self.scrollView.backgroundColor = [UIColor clearColor];
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
	
	passwordRecovertBtn = [ApplicationDelegate.uiSettings createButton:@"Send email"];
    [passwordRecovertBtn addTarget:self action:@selector(passwordRecoveryBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.userOperation) {
        [self.userOperation cancel];
        self.userOperation = nil;
    }
    
    if (HUD)
        [self setHUD:nil];
	
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Action Methods

-(IBAction) passwordRecoveryBtnPressed:(id) sender {
	[emailField resignFirstResponder];
    
    if(![Validation validateEmail:emailField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You Entered Incorrect Email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1000;
        
		[alert show];
        [emailField becomeFirstResponder];
        return;
    }
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Processing...";
    HUD.dimBackground = YES;
	
	[self sendPasswordRecoveryRequest];
}

-(void)sendPasswordRecoveryRequest {
	userOperation = [ApplicationDelegate.userEngine sendPasswordRecoveryRequest:emailField.text onCompletion:^(NSString *status) {
		
		[HUD setHidden:YES];
		if ([status isEqualToString:@"1"]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"w00t!"
															message: [NSString stringWithFormat:@"An email has been sent to \"%@\" with instructions", emailField.text]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			
			alert.tag = 1001;
			[alert show];
		}
		else {
			[HUD setHidden:YES];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Uh-oh!"
															message: @"Something's wrong with the email. It doesn't match with the account on this device. May be a misspelling?"
														   delegate: self
												  cancelButtonTitle: @"Cancel"
												  otherButtonTitles: @"Try again",nil];
			
			alert.tag = 1002;
			[alert show];
		}
	} onError:^(NSError* error) {
		[HUD setHidden:YES];
		[modelUtils rollbackDefaultMOC];
	}];
	
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
            return @"PASSWORD RECOVERY";
        default:
            break;
    }
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 10.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    
    switch (section) {
        case SectionCredentials:    {
            headerLabel.text =  @"PASSWORD RECOVERY";
			[headerLabel setFrame:CGRectMake(12.0, 20.0, 300.0, 20.0)];
			[headerDetailLabel setFrame:CGRectMake(12.0, 40.0, 300.0, 50.0)];
			headerDetailLabel.font = [UIFont boldSystemFontOfSize:11.0];
			
            headerDetailLabel.numberOfLines = 3;
            headerDetailLabel.text =  @"(You forgot, but it doesn't matter. Give us your email\n and we'll send you instructions on how to reset\n your password)";
            
			headerDetailLabel.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
			
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        }
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    if (section == SectionCredentials) {
        
        UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(12.0, 10.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        [passwordRecovertBtn setFrame:CGRectMake(12.0, 20.0, 300.0, 30.0)];
        [footerView addSubview:passwordRecovertBtn];
        [footerView bringSubviewToFront:passwordRecovertBtn];
        
        return footerView;
    }
	
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
                                                                     placeholder:@"email"
                                                              inputAccessoryView:nil];
                emailField.tag = 1;
                emailField.keyboardType = UIKeyboardTypeEmailAddress;
                emailField.returnKeyType = UIReturnKeyDone;
                
                [emailField setDelegate:self];
                [cell.contentView addSubview:emailField];
                break;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionCredentials)
		return 100.0;
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

#pragma mark -
#pragma mark UITextField Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[emailField resignFirstResponder];
	return YES;
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
    [emailField resignFirstResponder];
}

- (void) hideKeyboard {
    [emailField resignFirstResponder];
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(alertView.tag == 1000 || alertView.tag == 1002) {
		if (alertView.tag == 1002 && buttonIndex != alertView.cancelButtonIndex) {
			[emailField setText:@""];
		} else {
			[self.navigationController popViewControllerAnimated:YES];
			return;
		}
		
		[emailField becomeFirstResponder];
		return;
	}
	
	if(alertView.tag == 1001) {
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
}

@end