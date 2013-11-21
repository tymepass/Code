//
//  FriendsEventInvitationViewController.m
//  Timepass
//
//  Created by mac book pro on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsEventInvitationViewController.h"
#import "User+GAEUser.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>

@implementation FriendsEventInvitationViewController
@synthesize tableView;
@synthesize sendInvitationsBtn;
@synthesize friendsEventInvitationDelegate;
@synthesize friendsToInviteArray,fbFriendsToInviteArray;
@synthesize friendsOperation;
@synthesize inviteesOperation;
@synthesize footerView;
@synthesize sendInvite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        peopleToInvite = [NSMutableArray arrayWithArray:friendsToInviteArray];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fetchFBFriends:(BOOL)fbMode event:(Event *)event {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fetchFBFriends = fbMode;
        currentEvent = event;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Search" 
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(searchBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    sendInvitationsBtn = [ApplicationDelegate.uiSettings createButton:@"Send Invitations"];
    [sendInvitationsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [sendInvitationsBtn addTarget:self action:@selector(sendInvitationsBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:sendInvitationsBtn];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSendInvitationsBtn:nil];
	[self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	
	friendsArray = [[NSMutableArray alloc] init];
	
    if (!fetchFBFriends)
        peopleToInvite = [NSMutableArray arrayWithArray:friendsToInviteArray];
    else 
        peopleToInvite = [NSMutableArray arrayWithArray:fbFriendsToInviteArray];
    
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"friends"
          onCompletion:^(NSArray *responseData) {
              
              NSMutableArray *fetchedFriends = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
              
              for (User *user in fetchedFriends) {
                  if ([user serverId]) {
                      NSString *fullname = [NSString stringWithFormat:@"%@ %@",[user name] ? [user name] : @"", [user surname] ? [user surname] : @""];
                      
                      NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name",@"key",@"photo",@"checked",@"isInvited", nil];
                      NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname,[user serverId],[NSString stringWithFormat:@"%@", [user photo]], @"NO", @"NO", nil];
                      
                      NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                      
                      [friendsArray addObject:theDict];
                  }
              }     
              
              if (currentEvent) {
                  inviteesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"invitees"
                        onCompletion:^(NSArray *responseData) {
                            peopleAlreadyInvited = [NSMutableArray arrayWithArray:[Invitation getInvitees:responseData]];
                            
                            [self.tableView reloadData];
                            [HUD hide:YES];
                        } 
                        onError:^(NSError* error) {
                            [HUD hide:YES];
                        }];
              }
              else {
                  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                                 ascending:NO];
                  
                  sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                  
                  NSArray *sortedArray,*arrfrnds;
                  arrfrnds=[NSArray arrayWithArray:friendsArray];
                  sortedArray =[arrfrnds sortedArrayUsingDescriptors:sortDescriptors];
                  NSLog(@"sorted array : %@",sortedArray);
                  //   sortedArray = [arrfrnds sortedArrayUsingDescriptor:sortDescriptors];
                  [friendsArray removeAllObjects];
                  [friendsArray addObjectsFromArray:sortedArray];

                  [self.tableView reloadData];
                  [HUD hide:YES];
              }
          } 
          onError:^(NSError* error) {
              [HUD hide:YES];
          }];
    
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	if (!fetchFBFriends)
        self.title = NSLocalizedString(@"Tymepass Friends", @"Tymepass Friends");
    else
        self.title = NSLocalizedString(@"Facebook Friends", @"Facebook Friends");
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HUD hide:YES];
	self.title = Nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.friendsOperation) {
        
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
    }
    
    if (self.inviteesOperation) {
        
        [self.inviteesOperation cancel];
        self.inviteesOperation = nil;
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

- (void)sendInvitationsBtnPressed:(id) sender { 
    NSMutableArray * selectedfriendsArray = [[NSMutableArray alloc] init];

    for (NSDictionary *user in friendsArray)
    {
        if ([[user valueForKey:@"isInvited"] isEqualToString:@"YES"]) 
            continue;
        
        if ([[user valueForKey:@"checked"] isEqualToString:@"NO"]) 
            continue;
        
        [selectedfriendsArray addObject:user];
    }
    
    //debugLog(@"%@",[selectedfriendsArray JSONRepresentation]);
	if (sendInvite) {
		if (currentEvent) {
				
			if (selectedfriendsArray && [selectedfriendsArray count] > 0)
				[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:selectedfriendsArray OfType:@"TymepassEvent" stealthMode:[currentEvent isPrivate] forEvent:[currentEvent serverId]];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		[[self friendsEventInvitationDelegate] setFriends:selectedfriendsArray areFBFriends:fetchFBFriends];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Friend invites will be sent once you have saved the event." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}

- (IBAction)searchBtnPressed:(id)sender{
    searchForFriendsViewController = [[SearchForFriendsViewController alloc] initWithNibName:@"SearchForFriendsViewController" bundle:nil settingsViewMode:YES];
    
    [self.navigationController pushViewController:searchForFriendsViewController animated:YES]; 
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([friendsArray count] > 0)
        return [friendsArray count] + 1;
    
    return [friendsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"]; 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor blackColor];
    
    int index = indexPath.row;
    
    if (index == 0 && [friendsArray count] > 0) {
        cell.textLabel.text = @"All of them!";
        
        UIImage *image = (checkAll) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;	// match the button's size with the image size
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        return cell;
    }
    else 
        index -= 1;
    
    NSMutableDictionary *dict = [friendsArray objectAtIndex:index];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
			  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    [imageView setFrame:CGRectMake(8.0, 6.0, 31.0, 30.0)];
    imageView.layer.cornerRadius = 4;
    [imageView setClipsToBounds: YES];
    
    [cell.contentView addSubview:imageView];
    
    CGRect frame = CGRectOffset(CGRectInset(CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width - imageView.frame.size.width - 20.0f, cell.frame.size.height - 7.0f), 25.0f, 0.0f), imageView.frame.origin.x + imageView.frame.size.width - 17.0f, 3.0f);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [UIColor blackColor];
    lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:16.0];
    lbl.text = [dict objectForKey:@"name"];
        
    for (NSMutableDictionary *invited in peopleToInvite) {
        if ([[NSString stringWithFormat:@"%@",[invited objectForKey:@"key"]] isEqualToString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"NO" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:YES];
            [cell setSelected:NO]; 
        } 
    }
    
    BOOL exists = FALSE;
    for (NSObject *invited in peopleAlreadyInvited) {
        if ([[NSString stringWithFormat:@"%@",invited] isEqualToString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]]]) {
            exists = TRUE;
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelected:YES];
            
            UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:cell.frame];
            selectedBackground.backgroundColor = [UIColor lightGrayColor];
            
            [cell setSelectedBackgroundView:selectedBackground];
        } 
    }
    
    [cell.contentView addSubview:lbl];
    
    if (!exists)
        [dict setObject:cell forKey:@"cell"];
    
    BOOL checked = [[dict objectForKey:@"checked"] boolValue];
    UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;	// match the button's size with the image size
	
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    
    if (exists)
        [button setEnabled:FALSE];
    
	cell.accessoryView = button;

    if (currentEvent) {
        if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]] isEqualToString:[NSString stringWithFormat:@"%@",[[currentEvent invitedBy] serverId]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelectedBackgroundView:nil];

            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            cell.detailTextLabel.textColor  = [UIColor darkGrayColor];
            cell.detailTextLabel.text = @"Attending";             
        } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]] isEqualToString:[NSString stringWithFormat:@"%@",[[currentEvent creatorId] serverId]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelectedBackgroundView:nil];
            
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            cell.detailTextLabel.textColor  = [UIColor darkGrayColor];
            cell.detailTextLabel.text = @"Creator";   
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
    if (indexPath.row == 0 && [friendsArray count] > 0) {
        if (checkAll)
            checkAll = FALSE;
        else
            checkAll = TRUE;
        
        for (int i=0; i < [friendsArray count]; i++) {
            NSMutableDictionary *dict = [friendsArray objectAtIndex:i];
                        
            [dict setObject:checkAll ? @"YES":@"NO" forKey:@"checked"];
            
            UITableViewCell *cell = [dict objectForKey:@"cell"];
            UIButton *button = (UIButton *)cell.accessoryView;
            
            UIImage *newImage = (checkAll) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
            [button setBackgroundImage:newImage forState:UIControlStateNormal];
        }
        
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexP];
        
        UIButton *button = (UIButton *)cell.accessoryView;
        
        UIImage *newImage = (!checkAll) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal];
    } else {
        NSMutableDictionary *dict = [friendsArray objectAtIndex:indexPath.row-1];
	
        BOOL checked = [[dict objectForKey:@"checked"] boolValue];
	
        [dict setObject:!checked?@"YES":@"NO" forKey:@"checked"];
	
        UITableViewCell *cell = [dict objectForKey:@"cell"];
        UIButton *button = (UIButton *)cell.accessoryView;
	
        UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal];
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
	if (indexPath != nil)
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

@end