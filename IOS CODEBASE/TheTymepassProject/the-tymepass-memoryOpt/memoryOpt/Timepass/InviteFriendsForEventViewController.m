//
//  InviteFriendsForEventViewController.m
//  Timepass
//
//  Created by mac book pro on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InviteFriendsForEventViewController.h"

enum {
    SectionInviteTymepassFriends    = 0,
    SectionInviteFBFriends          = 1,
    SectionInviteByEmail            = 2,
    SectionInviteBySMS              = 3,
    SectionsCount                   = 4
};

enum {
    TymepassFriendsSectionRowsCount     = 1
};

enum {
    FBFriendsSectionRowsCount           = 1
};

enum {
    EmailSectionRowsCount               = 1
};

enum {
    SMSSectionRowsCount                 = 1
};

@implementation InviteFriendsForEventViewController
@synthesize tableView;
@synthesize inviteFriendsForEventDelegate;
@synthesize friendsToInviteArray,fbFriendsToInviteArray;

NSMutableDictionary *settingsDictionary;
NSString* settingsPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        settingsPath = [Utils userSettingsPath];
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *) event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentEvent = event;
        settingsPath = [Utils userSettingsPath];
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
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
    
    self.title = NSLocalizedString(@"Invite Friends", @"Invite Friends");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[[self inviteFriendsForEventDelegate] setFriends:friendsToInviteArray];
    [[self inviteFriendsForEventDelegate] setFBFriends:fbFriendsToInviteArray];
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

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionInviteTymepassFriends:
            return TymepassFriendsSectionRowsCount;
        case SectionInviteFBFriends:
            return FBFriendsSectionRowsCount;
        case SectionInviteByEmail:
            return EmailSectionRowsCount;
        case SectionInviteBySMS:
            return SMSSectionRowsCount;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 20.0)];
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    [headerLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 20.0)];
    
    if (section == SectionInviteTymepassFriends) {
        headerLabel.text =  @"INVITE YOUR FRIENDS TO THE EVENT";
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor lightGrayColor];
	
    if (indexPath.section == SectionInviteTymepassFriends) {
        cell.textLabel.text = @"Tymepass Friends";
        
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [[UIColor alloc] initWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    [cell setSelected:NO];
    
    if (indexPath.section == SectionInviteFBFriends) {
        cell.textLabel.text = @"Facebook Friends";
        
        cell.backgroundColor = [[UIColor alloc] initWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [cell setSelected:NO];
        
    } else if (indexPath.section == SectionInviteByEmail) {
        cell.textLabel.text = @"Invite by email";
    } else  {
        cell.textLabel.text = @"Invite by SMS";
    }
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionInviteTymepassFriends)
        return 40.0;
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.section == SectionInviteTymepassFriends) {
        friendsEventInvitationViewController = [[FriendsEventInvitationViewController alloc] initWithNibName:@"FriendsEventInvitationViewController" bundle:nil fetchFBFriends:NO event:currentEvent];
        
        friendsEventInvitationViewController.friendsToInviteArray = friendsToInviteArray;
        [friendsEventInvitationViewController setFriendsEventInvitationDelegate:self];
        
        [self.navigationController pushViewController:friendsEventInvitationViewController animated:YES];
    } /*else if (indexPath.section == SectionInviteFBFriends) {
	   friendsEventInvitationViewController = [[FriendsEventInvitationViewController alloc] initWithNibName:@"FriendsEventInvitationViewController" bundle:nil fetchFBFriends:YES event:currentEvent];
	   
	   friendsEventInvitationViewController.fbFriendsToInviteArray = fbFriendsToInviteArray;
	   [friendsEventInvitationViewController setFriendsEventInvitationDelegate:self];
	   
	   [self.navigationController pushViewController:friendsEventInvitationViewController animated:YES];
	   } else {
	   searchPbFriendsViewController = [[SearchPbFriendsViewController alloc] initWithNibName:@"SearchPbFriendsViewController" bundle:nil];
	   
	   [self.navigationController pushViewController:searchPbFriendsViewController animated:YES];
	   }
	   */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) setFriends:(NSMutableArray *)friends areFBFriends:(BOOL)areFB {
    if (areFB)
        fbFriendsToInviteArray = [NSMutableArray arrayWithArray:friends];
    else
        friendsToInviteArray = [NSMutableArray arrayWithArray:friends];
}

@end