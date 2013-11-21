//
//  SearchForFriendsViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchForFriendsViewController.h"
#import "TileScreenController.h"
#import "SearchFbFriendsViewController.h"
#import "SearchPbFriendsViewController.h"
#import "SearchEmailFriendsViewController.h"
#import "SearchTWFriendsViewController.h"
#import "SignUpViewController.h"
#import "GlobalData.h"

enum {
    SectionSearchFromFB             = 0,
    SectionSearchByTwitter          = 1,
    SectionSearchInContacts         = 2,
    SectionSearchByEmail            = 3,
    SectionInviteBySMS              = 4,
    SectionsCount                   = 5
    
};

enum {
    EmailSectionRowsCount           = 1
};

enum {
    FBSectionRowsCount              = 1
};

enum {
    TWSectionRowsCount              = 1
};

enum {
    ContactSectionRowsCount         = 1
};

enum {
    InviteBySMSSectionRowsCount     = 1
};

@implementation SearchForFriendsViewController
@synthesize tableView;
@synthesize invniteBySMSContactsCell,searchByEmailCell,searchFromFBCell,invniteByContactsCell, searchFromTWCell;
@synthesize laterBtn;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil settingsViewMode:(BOOL) _settingsMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        settingsMode = _settingsMode;
        
        // Custom initialization
        
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

- (void)iCalAlert {
    UIAlertView *iCalAlert = [[UIAlertView alloc] initWithTitle:@"Sync with iPhone Calendar" message:@"Do you want to sync Tymepass with your iPhone Calendar?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Do it!", nil];
    iCalAlert.tag = 1000;
    [iCalAlert show];
}

//alert delegate method
- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //check which alertview sent the message
    if(buttonIndex == 1){
        //ical alert
        //write ical in plist file
        [settingsDictionary setValue:@"1" forKey:@"iCal_sync"];
        [settingsDictionary writeToFile:settingsPath atomically: YES];
        //confirm change in status
        //TODO do we need confirmation?
        return;
    }
    else {
        //write ical in plist file
        [settingsDictionary setValue:@"0" forKey:@"iCal_sync"];
        [settingsDictionary writeToFile:settingsPath atomically: YES];
        //confirm change in status
        //TODO do we need confirmation?
        return;
    }
    return;
} // clickedButtonAtIndex

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (!settingsMode) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Later"
                                                  style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(laterBtnPressed:)];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    if (!settingsMode)  {
        laterBtn = [ApplicationDelegate.uiSettings createButton:@"Thanx, I'll do it later"];
        [laterBtn setFrame:CGRectMake(12.0, 55.0, 300.0, 30.0)];
        [laterBtn addTarget:self action:@selector(laterBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self initCells];
    //Sync with iCal alert
    if ([self.parentViewController isKindOfClass:[SignUpViewController class]]) {
        [self iCalAlert];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"Find Friends", @"Find Friends");
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [tableView flashScrollIndicators];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = Nil;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setInvniteBySMSContactsCell:nil];
    [self setSearchByEmailCell:nil];
    [self setSearchFromFBCell:nil];
    [self setLaterBtn:nil];
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

- (void)initCells {
    
    searchByEmailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    searchByEmailCell.textLabel.text = @"Search by email";
    searchByEmailCell.textLabel.font= [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];;
    searchByEmailCell.textLabel.textColor  = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    searchByEmailCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    searchFromFBCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    searchFromFBCell.textLabel.text = @"Search from facebook friends";
    searchFromFBCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    searchFromFBCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    searchFromFBCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    invniteBySMSContactsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    invniteBySMSContactsCell.textLabel.text = @"Invite by SMS";
    invniteBySMSContactsCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    invniteBySMSContactsCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    invniteBySMSContactsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    invniteByContactsCell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    invniteByContactsCell.textLabel.text = @"Search your contacts";
    invniteByContactsCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    invniteByContactsCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    invniteByContactsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    searchFromTWCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    searchFromTWCell.textLabel.text = @"Search from twitter friends";
    searchFromTWCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    searchFromTWCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    searchFromTWCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (IBAction)laterBtnPressed:(id)sender{
    //Sync after register
    [[GlobalData sharedGlobalData] setSync:TRUE];
    
    //TODO Check the way the view loaded and dismiss accordingly
    UIViewController *tileScreenController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
    
    //remove all screens from navigation array
    
    //change root controller
    [ApplicationDelegate changeNavigationRoot:tileScreenController];
    
    if (!ApplicationDelegate.loadingView) {
        ApplicationDelegate.loadingView = [[UIImageView alloc] initWithFrame:ApplicationDelegate.navigationController.self.view.bounds];
        [ApplicationDelegate.loadingView setImage:[UIImage imageNamed:@"AppLoading_Screen.jpg"]];
        
        [ApplicationDelegate.navigationController.view addSubview:ApplicationDelegate.loadingView];
    }
    
    //[[super.view superview] addSubview:tileScreenController.view];
    //[self.view removeFromSuperview];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionSearchByEmail:
            return EmailSectionRowsCount;
        case SectionSearchFromFB:
            return FBSectionRowsCount;
        case SectionSearchByTwitter:
            return TWSectionRowsCount;
        case SectionInviteBySMS:
            return InviteBySMSSectionRowsCount;
        case SectionSearchInContacts:
            return ContactSectionRowsCount;
        default:
            break;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailBlueLabel];
    
    switch (section) {
        case SectionSearchFromFB:
            
            headerLabel.text =  @"FIND FRIENDS TO CONNECT WITH";
            [headerView addSubview:headerLabel];
            
            if (!settingsMode) {
                [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 60.0)];
                headerDetailLabel.numberOfLines = 2;
                headerDetailLabel.text =  @"(Find all your friends that are using Tymepass\nor invite them to join Tymepass)";
                [headerView addSubview:headerDetailLabel];
            }
            
            return headerView;
        case SectionInviteBySMS:
            headerLabel.text =  @"INVITE BY SMS";
            
            if (!settingsMode) {
                [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 40.0)];
                headerDetailLabel.numberOfLines = 2;
                headerDetailLabel.text =  @"(Invite your friends to join Tymepass -\nstandard SMS charges may apply)";
            } else {
                [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 20.0)];
                headerDetailLabel.textColor = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerDetailColorRed
																	 green:ApplicationDelegate.uiSettings.headerDetailColorGreen
																	  blue:ApplicationDelegate.uiSettings.headerDetailColorBlue
																	 alpha:1.0];
                headerDetailLabel.numberOfLines = 1;
                headerDetailLabel.text =  @"(standard SMS charges may apply)";
            }
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    if (!settingsMode) {
        UIView *footerView = [[UIView alloc] init];
        if (section == SectionInviteBySMS) {
            UILabel *lbl = [ApplicationDelegate.uiSettings createTableViewFooterDetailLabel];
            [lbl setFrame:CGRectMake(12.0, 0.0, 300.0, 40.0)];
            lbl.text =  @"";
            lbl.lineBreakMode = UILineBreakModeWordWrap;
            lbl.numberOfLines = 2;
            
            [footerView addSubview:lbl];
            
            UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
            [imageSeparator setFrame:CGRectMake(12.0, 40.0, 300.0, 2.0)];
            [footerView addSubview:imageSeparator];
            
            [footerView addSubview:laterBtn];
            
            return footerView;
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case SectionSearchFromFB:
            cell = searchFromFBCell;
            break;
            
        case SectionSearchByTwitter:
            cell = searchFromTWCell;
            break;
            
        case SectionSearchByEmail:
            cell = searchByEmailCell;
            break;
            
        case SectionInviteBySMS:
            cell = invniteBySMSContactsCell;
            break;
            
        case SectionSearchInContacts:
            cell = invniteByContactsCell;
            break;
			
        default:
            break;
    }
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionSearchFromFB){
        if (settingsMode)
            return 20.0;
        else
            return 80.0;
    }
    
    if (section == SectionInviteBySMS){
        if (settingsMode)
            return 40.0;
        else
            return 60.0;
    }
    
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!settingsMode)
        if (section == SectionInviteBySMS)
            return 130.0;
    
    if (section == SectionSearchByEmail)
        return -5.0;
    
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionSearchByEmail) {
        
        UIViewController *searchEmailFriendsViewController = [[SearchEmailFriendsViewController alloc] initWithNibName:@"SearchEmailFriendsViewController" bundle:nil sendInvitation:NO];
        [self.navigationController pushViewController:searchEmailFriendsViewController animated:YES];
        
    } else if (indexPath.section == SectionSearchFromFB) {
        
        UIViewController *searchFbFriendsViewController = [[SearchFbFriendsViewController alloc] initWithNibName:@"SearchFbFriendsViewController" bundle:Nil];
        [self.navigationController pushViewController:searchFbFriendsViewController animated:YES];
        
    } else if (indexPath.section == SectionSearchByTwitter) {
        
        UIViewController *searchTWFriendsViewController = [[SearchTWFriendsViewController alloc] initWithNibName:@"SearchTWFriendsViewController" bundle:Nil];
        [self.navigationController pushViewController:searchTWFriendsViewController animated:YES];
        
    } else if (indexPath.section == SectionSearchInContacts) {
		
		UIViewController *searchPbFriendsViewController = [[SearchPbFriendsViewController alloc] initWithNibName:@"SearchPbFriendsViewController" bundle:nil];
		[self.navigationController pushViewController:searchPbFriendsViewController animated:YES];
		
	} else if (indexPath.section == SectionInviteBySMS) {
		
		
		MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
		if([MFMessageComposeViewController canSendText])
		{
			
			NSString *messageBody = @"I would really like to invite you to a Tymepass event. We can share our calendars and share our events, parties, & meet-ups! Join me on Tymepass! http://tymepass.com/download";
			
			controller.body = messageBody;
			
			controller.messageComposeDelegate = self;
			[self presentModalViewController:controller animated:YES];
		}
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma  mark - Mail

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMS cancelled" message:@"Text message invite not sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
			break;
			
		case MessageComposeResultFailed: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMS Failed" message:@"Text message invite not sent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
			break;
			
		case MessageComposeResultSent: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMS Sent" message:@"Text message invite sent successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
			
			break;
			
		default:
			break;
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}

@end

