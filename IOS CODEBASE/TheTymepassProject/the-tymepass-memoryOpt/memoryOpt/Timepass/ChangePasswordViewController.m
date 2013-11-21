//
//  ChangePasswordViewController.m
//  Timepass
//
//  Created by mac book pro on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Utils.h"

enum {
    SectionOldPawssword    = 0,
    SectionNewPassword     = 1,
    SectionsCount          = 2
};

enum {
    OldPawsswordSectionRowsCount     = 1
};

enum {
    NewPasswordSectionPasswordCell              = 0,
    NewPasswordSectionPasswordConfirmCell       = 1,
    NewPasswordSectionRowsCount                 = 2
};

@implementation ChangePasswordViewController
@synthesize tableView;
@synthesize changePasswordDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        profileUser = user;
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
    
    self.title = NSLocalizedString(@"New Password", @"New Password");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    saveBtn = [ApplicationDelegate.uiSettings createButton:@"Save New Password"];
    [saveBtn setFrame:CGRectMake(12.0, 25.0, 300.0, 30.0)];
    [saveBtn addTarget:self action:@selector(changePassword:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setScrollView:nil];  
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void) changePassword:(id) sender {  
    if (oldPasswordField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oooops!" message:@"The password you gave\nis not quite right.\nPlease, give it another go!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try again", nil];
        alert.tag = 1000;

        [alert show];
        
        return;
    } else {
        if (![[Utils sha1:oldPasswordField.text] isEqualToString:profileUser.password]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Old Password is Incorrect" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alert.tag = 1000;

            [alert show];
            
            return;
        }
    }
        
    if(![passwordField.text isEqualToString:passwordConfirmField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Passwords do not match." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 1001;

		[alert show];
        return;
    }
    
    [[self changePasswordDelegate] setNewPassword:passwordField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionOldPawssword:
            return OldPawsswordSectionRowsCount;
        case SectionNewPassword:
            return NewPasswordSectionRowsCount;
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
        case SectionOldPawssword:        
            headerLabel.text =  @"OLD PASSWORD";
            [headerView addSubview:headerLabel];
            
            return headerView;
        case SectionNewPassword: {                        
            headerLabel.text =  @"NEW PASSWORD";    
            
            [headerView addSubview:headerLabel];
            return headerView;
        }
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {  
    UIView *footerView = [[UIView alloc] init];
    if (section == SectionNewPassword) {
        
        UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(12.0, 10.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        [footerView addSubview:saveBtn];     
        
        return footerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionOldPawssword) {
        oldPasswordField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Old Password" inputAccessoryView:nil];
        oldPasswordField.secureTextEntry = YES;

        [cell.contentView addSubview:oldPasswordField];  
    } else if (indexPath.section == SectionNewPassword) {
        switch (indexPath.row) {
            case NewPasswordSectionPasswordCell:
                passwordField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"New Password" inputAccessoryView:nil];
                passwordField.secureTextEntry = YES;

                [cell.contentView addSubview:passwordField];  
                break;
            case NewPasswordSectionPasswordConfirmCell:
                passwordConfirmField = [ApplicationDelegate.uiSettings createCellTextField:cell.frame.size.width textHeight:cell.frame.size.height placeholder:@"Confrim New Password" inputAccessoryView:nil];
                passwordConfirmField.secureTextEntry = YES;

                [cell.contentView addSubview:passwordConfirmField];    
                break;
            default:
                break;
        }    
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {    
    if (section == SectionNewPassword)
        return 60.0;
    
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void) hideKeyboard {
    [oldPasswordField resignFirstResponder];
    [passwordField resignFirstResponder];
    [passwordConfirmField resignFirstResponder];
}

@end
