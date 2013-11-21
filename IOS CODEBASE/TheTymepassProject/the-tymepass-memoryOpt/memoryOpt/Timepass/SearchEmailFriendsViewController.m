//
//  SearchEmailFriendsViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchEmailFriendsViewController.h"
#import "Validation.h"
#import "Utils.h"
#import "User+GAEUser.h"
#import "ContactViewController.h"

@implementation SearchEmailFriendsViewController
@synthesize tableView;
@synthesize emailTextField,actionBtn,addBtn;
@synthesize HUD;
@synthesize userOperation;
@synthesize footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendEmailsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil sendInvitation:(BOOL) invite
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendEmailsArray = [[NSMutableArray alloc] init];
        inviteFriends = invite;
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
    
    //self.navigationController.navigationBar.backItem.title = NSLocalizedString(@"Back", @"Back");
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(btnEditPressed:)];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setBounces:NO];
    //[tableView setEditing:YES animated:YES];
    [tableView setDelaysContentTouches:NO];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [tableView addGestureRecognizer:tapGestureRecognizer];
    
    emailTextField = [ApplicationDelegate.uiSettings createBorderedTextField];
    emailTextField.placeholder = @"Friend's email";
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [emailTextField addTarget:self action:@selector(addFriendsEmailToList:)  forControlEvents:UIControlEventEditingDidEndOnExit];
    
    addBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [addBtn setFrame:CGRectMake(self.view.frame.size.width - 50.0, 80.0, 45.0, 44.0)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_btn.png"] forState:UIControlStateNormal];
	[addBtn setBackgroundImage:[UIImage imageNamed:@"add_btn_pressed.png"] forState:UIControlStateHighlighted];
	
    [addBtn addTarget:self action:@selector(addFriendsEmailToList:)  forControlEvents:UIControlEventTouchUpInside];
    
    if (inviteFriends) {
        [emailTextField setFrame:CGRectMake(12.0, 60.0, 249.0, 43.0)];
        [addBtn setFrame:CGRectMake(self.view.frame.size.width - 50.0, 60.0, 45.0, 44.0)];
    }
    
    if (inviteFriends)
        actionBtn = [ApplicationDelegate.uiSettings createButton:@"Send Invitations"];
    else
        actionBtn = [ApplicationDelegate.uiSettings createButton:@"Check Emails"];
    
    [actionBtn setFrame:CGRectMake(12.0, 20.0, 300.0, 30.0)];
    [actionBtn addTarget:self action:@selector(actionBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:actionBtn];
    
    UIImageView *shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_shadow.png"]];
    [shadowImage setFrame:CGRectMake(0.0, 0.0, 320, 10)];
    
    [footerView addSubview:shadowImage];
}

- (void)viewDidUnload
{
    if (tableView)
        [self setTableView:nil];
    
    if (emailTextField)
        [self setEmailTextField:nil];
    
    if (actionBtn)
        [self setActionBtn:nil];
    
    if (addBtn)
        [self setAddBtn:nil];
    
    [self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    if (inviteFriends)
        self.title = NSLocalizedString(@"By emails", @"By emails");
    else
        self.title = NSLocalizedString(@"Search By Email", @"Search By Email");
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = Nil;
}

- (void)viewDidDisappear:(BOOL)animated
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

-(IBAction)btnEditPressed:(id)sender {
    if(self.editing) {
        [super setEditing:NO animated:YES];
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                  target:self action:@selector(btnEditPressed:)];
        
    }
    else {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(btnEditPressed:)];
    }
    
}

-(void)OpenPhoneBookContact
{
    ContactViewController *contactview=[[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    [self.navigationController pushViewController:contactview animated:YES];
}

- (void)actionBtnPressed:(id) sender {
    if ([friendEmailsArray count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is no email to check." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
        return;
    }
    
    if (!inviteFriends) {
        NSDictionary *emailDictionary = [[NSDictionary alloc] initWithObjects:friendEmailsArray forKeys:friendEmailsArray];
        
        HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
        HUD.labelText = @"Checking...";
        HUD.dimBackground = YES;
        
        userOperation = [ApplicationDelegate.userEngine checkEmails:emailDictionary onCompletion:^(NSArray *responseData) {
            NSArray *list = [responseData valueForKey:@"emails"];
            
            NSMutableArray *friendsUsingTymepassArray = [[NSMutableArray alloc] init];
            NSMutableArray *friendsNotUsingTymepassArray = [[NSMutableArray alloc] init];
            
            NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"email",@"checked", nil];
            NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:emailDictionary,@"NO", nil];
            NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:friendEmailsArray];
            
            for (NSArray *user in list)
            {
                for (int i =0; i < [user count]; i++) {
                    NSString *fullname = [NSString stringWithFormat:@"%@ %@", [[user valueForKey:@"name"] objectAtIndex:i], [[user valueForKey:@"surname"] objectAtIndex:i]];
                    NSString *email = [NSString stringWithFormat:@"%@", [[user valueForKey:@"email"] objectAtIndex:i]];
                    NSString *key = [NSString stringWithFormat:@"%@", [[user valueForKey:@"key"] objectAtIndex:i]];
                    theKeys = [NSMutableArray arrayWithObjects:@"name",@"email",@"key",@"checked",@"isFriend", nil];
                    theObjects = [NSMutableArray arrayWithObjects:fullname,email,key,@"NO",@"NO",nil];
                    
                    theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                    
                    //add the user to the using array
                    [friendsUsingTymepassArray addObject:theDict];
                    
                    //remove him from the not using
                    [temp removeObjectAtIndex:[temp indexOfObject:[[user valueForKey:@"email"] objectAtIndex:i]]];
                }
            }
            
            //add the not using
            //We send emails as 'key' to be consistent wiht the other requests
            theKeys = [NSMutableArray arrayWithObjects:@"email",@"key",@"checked", nil];
            
            for (NSString * email in temp) {
                theObjects = [NSMutableArray arrayWithObjects:email,email,@"NO", nil];
                theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                
                //add the user to the not using array
                [friendsNotUsingTymepassArray addObject:theDict];
            }
            
            [HUD hide:YES];
            
            SearchEmailFriendsResultsViewController *searchEmailFriendsResultsViewController = [[SearchEmailFriendsResultsViewController alloc] initWithNibName:@"SearchEmailFriendsResultsViewController" bundle:nil friendsUsingArray:friendsUsingTymepassArray friendsNotUsingArray:friendsNotUsingTymepassArray];
            
            [self.navigationController pushViewController:searchEmailFriendsResultsViewController animated:YES];
        } onError:^(NSError* error) {
            [HUD hide:YES];
        }];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friendEmailsArray count];
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 40.0)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    UIImageView *shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_shadow.png"]];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    [headerLabel setFrame:CGRectMake(12.0, -3.0, 300.0, 40.0)];
    
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailBlueLabel];
    headerLabel.text =  @"FRIEND’S EMAIL";
    
    if (inviteFriends) {
        [headerDetailLabel setFrame:CGRectMake(12.0, 20.0, 300.0, 40.0)];
        headerDetailLabel.numberOfLines = 2;
        headerDetailLabel.text =  @"(Input the email addresses of the people\nyou want to invite to your event)";
        [shadowImage setFrame:CGRectMake(10.0, 110.0, 320.0, 10.0)];
    } else {
        [headerDetailLabel setFrame:CGRectMake(12.0, 20.0, 300.0, 60.0)];
        headerDetailLabel.numberOfLines = 3;
        headerDetailLabel.text =  @"(Input the email addresses of the friends\nyou want to connect with, and we'll check\nif they are Tymepassers)";
        [shadowImage setFrame:CGRectMake(0.0, 130.0, 330.0, 10.0)];
    }
    
    [headerView addSubview:headerLabel];
    [headerView addSubview:headerDetailLabel];
    [headerView addSubview:emailTextField];
    [headerView addSubview:addBtn];
    [headerView addSubview:shadowImage];
    
    return headerView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    if (indexPath.row <= [friendEmailsArray count] - 1){
        cell.textLabel.text = [friendEmailsArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont]
											  size:[ApplicationDelegate.uiSettings cellFontSize]];
		
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:102.0/255.0
														  green:102.0/255.0
														   blue:102.0/255.0
														  alpha:1.0];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.highlighted = NO;
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (inviteFriends)
        return 110.0;
    
    return 130.0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSUInteger count = [friendEmailsArray count];
	
	if (row < count) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUInteger row = [indexPath row];
	NSUInteger count = [friendEmailsArray count];
    
	if (row < count)
		[friendEmailsArray removeObjectAtIndex:row];
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark UITextField Methods

-(CGRect)textRectForBounds:(CGRect) bounds {
    return CGRectInset(bounds, 20, 10);
}

-(CGRect)editingRectForBounds:(CGRect) bounds {
    return CGRectInset(bounds, 20, 10);
}

- (void)addFriendsEmailToList:(id) sender
{
    if ([emailTextField.text length] == 0) {
        [emailTextField becomeFirstResponder];
        return;
    }
    
    if(![Validation validateEmail:emailTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You entered incorrect email." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@",emailTextField.text];
    NSArray *filteredArray = [friendEmailsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"The email you have entered already exists.\nPlease give a different one." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
        return;
        
    }
    
    [friendEmailsArray addObject:emailTextField.text];
    [tableView reloadData];
    
    emailTextField.text = @"";
}

- (void)alertView:(UIAlertView *)UIAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        if ([friendEmailsArray count] == 0)
            return;
        
        [emailTextField becomeFirstResponder];
    }
}


- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void) hideKeyboard {
    [emailTextField resignFirstResponder];
}

/*-(void)setFriendUsingTymepass:(NSMutableArray *)friendUsingTymepass {
 friendUsingTymepassArray = friendUsingTymepass;
 }
 
 -(void)setFriendNotUsingTymepass:(NSMutableArray *)friendNotUsingTymepass {
 friendNotUsingTymepassArray = friendNotUsingTymepass;
 }*/
@end
