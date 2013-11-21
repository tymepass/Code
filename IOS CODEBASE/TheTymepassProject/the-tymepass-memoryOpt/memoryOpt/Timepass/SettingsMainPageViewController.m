//
//  SettingsMainPageViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsMainPageViewController.h"
#import "Utils.h"
#import "User+Management.h"
#import <CoreText/CoreText.h>
#import "CalSync.h"
#import "GlobalData.h"
#import "TTTAttributedLabel.h"

//static NSString* kAppId = @"210849718975311";

enum {
    SectionSync                    = 0,
    SectionFaq                     = 1,
    SectionTellAFriend             = 2,
    SectionReview                  = 3,
    SectionAboutUs                 = 4,
    SectionSignOut                 = 5,
    SectionsCount                  = 6,
    SectionFacebook                = 7
};

enum {
    SyncSectioniCalCell            = 0,
    SyncSectionGoogleCalCell       = -1,
    SyncSectionFacebookCalCell     = 1,
    SyncSectionRowsCount           = 2
};

enum {
    HelpSectionRowsCount            = 0
};

enum {
    FaqSectionRowsCount             = 1
};

enum {
    ContactUsSectionRowsCount       = 0
};

enum {
    TellAFriendSectionRowsCount     = 1
};

enum {
    ReviewSectionRowsCount          = 1
};

enum {
    AboutUsSectionRowsCount         = 1
};

enum {
    SignOutSectionRowsCount         = 0
};

@implementation SettingsMainPageViewController
@synthesize scrollView;
@synthesize tableView;
@synthesize signOutBtn;
@synthesize syncBtn;
@synthesize synciCalSegmentControl;
@synthesize syncGoogleCalSegmentControl;
@synthesize syncFacebookCalSegmentControl;

@synthesize HUD;
@synthesize userOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        path = [Utils userSettingsPath];
		
        // Build the array from the plist
        settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
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
    
	[scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleBordered target:self action:@selector(doneBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:@"On",@"Off", nil];
    
    synciCalSegmentControl = [[UISegmentedControl alloc] initWithItems:itemsArray];
    [synciCalSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 121.0, 2.0, 100.0, 29.0)];
    
    synciCalSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    synciCalSegmentControl.selectedSegmentIndex = 1;
    
    [synciCalSegmentControl addTarget:self action:@selector(synciCalSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	if ([[settingsDictionary valueForKey:@"iCal_sync"] intValue] == 1) {
		synciCalSegmentControl.selectedSegmentIndex = 0;
	}
	
    syncGoogleCalSegmentControl = [[UISegmentedControl alloc] initWithItems:itemsArray];
    [syncGoogleCalSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 121.0, 0.0, 100.0, 29.0)];
    
    syncGoogleCalSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    syncGoogleCalSegmentControl.selectedSegmentIndex = 1;
    
    [syncGoogleCalSegmentControl addTarget:self action:@selector(syncGoogleCalSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	if ([[settingsDictionary valueForKey:@"gCal_sync"] intValue] == 1) {
		syncGoogleCalSegmentControl.selectedSegmentIndex = 0;
	}
    
    //[syncGoogleCalSegmentControl setEnabled:FALSE];
    
    NSArray *itemsArray1 = [NSArray arrayWithObjects:@"Yes",@"No", nil];
    syncFacebookCalSegmentControl = [[UISegmentedControl alloc] initWithItems:itemsArray1];
    [syncFacebookCalSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 121.0, 50.0, 100.0, 29.0)];
    
    syncFacebookCalSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    syncFacebookCalSegmentControl.selectedSegmentIndex = 1;
    
    [syncFacebookCalSegmentControl addTarget:self action:@selector(syncFacebookCalSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	if ([[settingsDictionary valueForKey:@"fCal_sync"] intValue] == 1) {
		syncFacebookCalSegmentControl.selectedSegmentIndex = 0;
	}
	
    signOutBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [signOutBtn setFrame:CGRectMake(self.view.frame.size.width - 55.0, 0.0, 45.0, 44.0)];
    [signOutBtn setBackgroundImage:[UIImage imageNamed:@"sign_out_btn.png"] forState:UIControlStateNormal];
    [signOutBtn setBackgroundImage:[UIImage imageNamed:@"sign_out_btn_pressed.png"] forState:UIControlStateHighlighted];
    [signOutBtn addTarget:self action:@selector(signOutBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	syncBtn = [ApplicationDelegate.uiSettings createButton:@"Synchronize"];
    [syncBtn setFrame:CGRectMake(10.0, 0.0, 100.0, 30.0)];
    [syncBtn addTarget:self action:@selector(syncBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTableView:nil];
    [self setSignOutBtn:nil];
    [self setSynciCalSegmentControl:nil];
    [self setSyncGoogleCalSegmentControl:nil];
    [self setSyncFacebookCalSegmentControl:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title = NSLocalizedString(@"Settings", @"Settings");
}


- (void)viewWillDisappear:(BOOL)animated {
    [HUD hide:YES];
	self.title = nil;
    [super viewWillDisappear:animated];
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
        case SectionSync:
            return SyncSectionRowsCount;
        case SectionFaq:
            return FaqSectionRowsCount;
        case SectionTellAFriend:
            return TellAFriendSectionRowsCount;
        case SectionReview:
            return ReviewSectionRowsCount;
        case SectionAboutUs:
            return AboutUsSectionRowsCount;
        case SectionSignOut:
            return SignOutSectionRowsCount;
        case SectionFacebook:
            return SyncSectionFacebookCalCell;
        default:
            break;
            
    }
    return 0;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    
    if (section == SectionTellAFriend) {
        UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 185.0)];
		
		UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
    
		[imageSeparator setFrame:CGRectMake(10.0, 0.0, 300.0, 2.0)];
		[headerView addSubview:imageSeparator];
		return headerView;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    
    if (section == SectionSignOut) {
        UILabel *lbl1 = [ApplicationDelegate.uiSettings createTableViewFooterLabel];
        [lbl1 setFrame:CGRectMake(80.0, 5.0, 70.0, 20.0)];
        lbl1.text =  @"Sign out";
        
        UILabel *lbl2 = [ApplicationDelegate.uiSettings createTableViewFooterDetailLabel];
        [lbl2 setFrame:CGRectMake(135.0, 4.0, 200.0, 40.0)];
        lbl2.numberOfLines = 2;
        lbl2.text =  @"(But why would\nyou want to do that?!)";
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(120.0, 5.0, 150.0, 40.0)];
        label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:12.0];
        label.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 2;
        label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        label.backgroundColor = [UIColor clearColor];
        
        [label setText:@"Sign out (But why would\nyou want to do that?!)" afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange range = [[mutableAttributedString string] rangeOfString:@"Sign out" options:NSCaseInsensitiveSearch];
            
            UIColor *color = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
            return mutableAttributedString;
        }];
        
        UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(10.0, -10.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        [footerView addSubview:signOutBtn];
		[footerView addSubview:syncBtn];
        [footerView addSubview:label];
        
        return footerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionSync) {
        switch (indexPath.row) {
            case SyncSectioniCalCell: {
				
				UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = backView;
				
                UILabel *textLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
                [textLabel setFrame:CGRectMake(15.0, 5.0, 180.0, 20.0)];
                textLabel.text = @"Sync with iPhone Calendar?";
                
                [cell.contentView addSubview:textLabel];
                [cell.contentView addSubview:synciCalSegmentControl];
				
				UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
                [imageSeparator setFrame:CGRectMake(0.0, 40.0, 300, 2.0)];
                [backView addSubview:imageSeparator];
            }
                break;
            case SyncSectionGoogleCalCell: {
                UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = backView;
                
                UILabel *textLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
                [textLabel setFrame:CGRectMake(15.0, 3.0, 180.0, 20.0)];
                textLabel.text = @"Sync with Google Calendar?";
                
                [cell.contentView addSubview:textLabel];
                [cell.contentView addSubview:syncGoogleCalSegmentControl];
                
                UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
                [imageSeparator setFrame:CGRectMake(0.0, 40.0, 300.0, 2.0)];
                [backView addSubview:imageSeparator];
            }
                break;
            case SyncSectionFacebookCalCell: {
                UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
                cell.backgroundColor = [UIColor clearColor];
                cell.backgroundView = backView;
				
				UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
				UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
				UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
				
				headerLabel.text =  @"FACEBOOK & TWITTER CONNECT";
				headerDetailLabel.text =  @"Tymepass can post messages on your behalf.";
				
				[headerLabel setFrame:CGRectMake(0.0, 10.0, 300.0, 20.0)];
				[headerDetailLabel setFrame:CGRectMake(0.0, 30.0, 300.0, 10.0)];
				
				[cell.contentView addSubview:headerLabel];
				[cell.contentView addSubview:headerDetailLabel];
				
				[imageSeparator setFrame:CGRectMake(0.0, 85.0, 300.0, 2.0)];
				[cell.contentView addSubview:imageSeparator];
                
                UILabel *textLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
                [textLabel setFrame:CGRectMake(15.0, 55.0, 180.0, 20.0)];
                textLabel.text = @"Allow connection?";
                
                [cell.contentView addSubview:textLabel];
                [cell.contentView addSubview:syncFacebookCalSegmentControl];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == SectionFaq) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"FAQ";
        
    } else if (indexPath.section == SectionTellAFriend) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"Tell a Friend";
        
    } else if (indexPath.section == SectionReview) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"Write a review";
        
    } else if (indexPath.section == SectionAboutUs) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"About Us";
        
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case SectionSync:
        case SectionAboutUs:
        case SectionReview:
        case SectionFacebook:
            return 0.0;
            break;
            
        case SectionFaq:
            return 0.0;
            break;
            
        case SectionSignOut:
            return 0.0;
            break;
            
        default:
            return 0.0;
            break;
    }
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SectionSync)
        return 5.0;
    if (section == SectionSignOut)
        return 90.0;
    else
        return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionSync) {
		if (indexPath.row == SyncSectionFacebookCalCell) {
			return  90.0;
		}
	}
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == SectionFaq) {
		//faqViewController = [[FaqViewController alloc] initWithNibName:@"FaqViewController" bundle:nil];
		//[self.navigationController pushViewController:faqViewController animated:YES];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tymepass.com/faq"]];
		
	} else if (indexPath.section == SectionTellAFriend) {
        searchForFriendsViewController = [[SearchForFriendsViewController alloc] initWithNibName:@"SearchForFriendsViewController" bundle:nil settingsViewMode:YES];
        [self.navigationController pushViewController:searchForFriendsViewController animated:YES];
        
	} else if (indexPath.section == SectionReview) {
		UIAlertView *reviewAlert = [[UIAlertView alloc] initWithTitle:@"Write a review?" message:@"You are going to be redirected to iTunes Store to leave a review." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do it!", nil];
		reviewAlert.tag = 1003;
		[reviewAlert show];
		
		/*if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			mailer.mailComposeDelegate = self;
			
			NSArray *toRecipients = [NSArray arrayWithObjects:@"info@tymepass.com", nil];
			[mailer setToRecipients:toRecipients];
			
			// only for iPad
			// mailer.modalPresentationStyle = UIModalPresentationPageSheet;
			
			[self presentModalViewController:mailer animated:YES];
			
			mailer.navigationBar.tintColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings navigationBarTintColorRed] green:[ApplicationDelegate.uiSettings navigationBarTintColorGreen] blue:[ApplicationDelegate.uiSettings navigationBarTintColorBlue] alpha:1.0];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
															message:@"Your device doesn't support the composer sheet"
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK",nil];
			[alert show];
		}*/
		
	} else if (indexPath.section == SectionAboutUs) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tymepass.com/about"]];
		
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MFMailComposeController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)doneBtnPressed:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)signOutBtnPressed:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign out?" message:@"Was it something we said?\nAnyway, have a nice one!\nTill next time we meet..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Bye bye!", nil];
    alert.tag = 1002;
    [alert show];
}

-(IBAction)syncBtnPressed:(id)sender {
	[[GlobalData sharedGlobalData] setSync:TRUE];
	[[GlobalData sharedGlobalData] setGetGAEFriends:FALSE];
	
	if (!ApplicationDelegate.loadingView) {
		ApplicationDelegate.loadingView = [[UIImageView alloc] initWithFrame:ApplicationDelegate.navigationController.self.view.bounds];
		ApplicationDelegate.loadingView.userInteractionEnabled = YES;
		
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
	
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)synciCalSegmentControlChanged:(id)sender {
	
	NSString *message = @"Are you sure you want your iCal to no longer sync with Tymepass?";
	if ([[settingsDictionary valueForKey:@"iCal_sync"] intValue] == 0) {
		message = @"Are you sure you want Tymepass synchronized with your iPhone Calendar?";
	}
	
    UIAlertView *iCalAlert = [[UIAlertView alloc] initWithTitle:@"Sync with iPhone Calendar"
														message:message
													   delegate:self
											  cancelButtonTitle:@"Cancel"
											  otherButtonTitles:@"Do it!", nil];
    iCalAlert.tag = 1000;
    [iCalAlert show];
}

- (IBAction)syncGoogleCalSegmentControlChanged:(id)sender {
    UIAlertView *gCalAlert = [[UIAlertView alloc] initWithTitle:@"Sync with Google Calendar"
														message:@"Please navigate to 'Settings->Mail, Contacts, Calendars->Add Account' to add your Gmail Calendar"
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Do it!", nil];
    [gCalAlert show];
}
- (IBAction)syncFacebookCalSegmentControlChanged:(id)sender {
   
	UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
	switch ([segmentedControl selectedSegmentIndex]) {
	
	case 0: {
		
		
		UIAlertView *fCalAlert = [[UIAlertView alloc] initWithTitle:@"Connect with Facebook & Twitter?"
															message:@"Your Tymepass will now connect to the Facebook or Twitter account you authorise or have authorised previously"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Ok!", nil];
		fCalAlert.tag = 1004;
		[fCalAlert show];
	}
			break;

	
	case 1: {
		UIAlertView *fCalAlert = [[UIAlertView alloc] initWithTitle:@"Disconnect Facebook & Twitter?"
															message:@"Tymepass only posts to Facebook & Twitter when you attend an open event or invite someone to join Tymepass through those social networks"
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Disconnect", nil];
		fCalAlert.tag = 1004;
		[fCalAlert show];
	}
		break;
	
		case UISegmentedControlNoSegment:
			// do something
			break;
		
		default:
			break;
	}
	   
}

//alert delegate method
- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //check which alertview sent the message
    if (alertView.tag == 1000) {
        if(buttonIndex == 1) {
            //ical alert
            //write ical in plist file
			
			if ([[settingsDictionary valueForKey:@"iCal_sync"] intValue] == 1) {
				[settingsDictionary setValue:@"0" forKey:@"iCal_sync"];
			} else {
				[settingsDictionary setValue:@"1" forKey:@"iCal_sync"];
			}
			
			[settingsDictionary writeToFile:path atomically: YES];
			
			HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
			HUD.labelText = @"Updating...";
			HUD.dimBackground = YES;
			
			[self performSelector:@selector(callApi) withObject:nil afterDelay:0.1];
            
            //confirm change in status
            //TODO do we need confirmation?
            return;
        }
        else {
			
			synciCalSegmentControl.selectedSegmentIndex = 1;
			if ([[settingsDictionary valueForKey:@"iCal_sync"] intValue] == 1) {
				synciCalSegmentControl.selectedSegmentIndex = 0;
			}
			
            return;
        }
        
    }
    
    if (alertView.tag == 1001) {
        if(buttonIndex == 1){
            //write ical in plist file
			
			if ([[settingsDictionary valueForKey:@"gCal_sync"] intValue] == 1) {
				[settingsDictionary setValue:@"0" forKey:@"gCal_sync"];
			} else {
				[settingsDictionary setValue:@"1" forKey:@"gCal_sync"];
			}
			
			[settingsDictionary writeToFile:path atomically: YES];
            return;
        }
        else {
			
			syncGoogleCalSegmentControl.selectedSegmentIndex = 1;
			if ([[settingsDictionary valueForKey:@"gCal_sync"] intValue] == 1) {
				syncGoogleCalSegmentControl.selectedSegmentIndex = 0;
			}
			
			
            return;
        }
    }
	
    if (alertView.tag == 1004) {
        if(buttonIndex == 1){
			
			if ([[settingsDictionary valueForKey:@"fCal_sync"] intValue] == 1) {
				[settingsDictionary setValue:@"0" forKey:@"fCal_sync"];
			} else {
				[settingsDictionary setValue:@"1" forKey:@"fCal_sync"];
			}
			
			[settingsDictionary writeToFile:path atomically: YES];
			return;
        }
        else {
			
			syncFacebookCalSegmentControl.selectedSegmentIndex = 1;
			if ([[settingsDictionary valueForKey:@"fCal_sync"] intValue] == 1) {
				syncFacebookCalSegmentControl.selectedSegmentIndex = 0;
			}
			
            return;
        }
    }
    
    if (alertView.tag == 1002) {
        if(buttonIndex == 1){
            [[[SingletonUser sharedUserInstance] user] setIsLoggedIn:[NSNumber numberWithBool:NO]];
            [modelUtils commitDefaultMOC];
            
            [[SingletonUser sharedUserInstance] setUser:nil];
            [[SingletonUser sharedUserInstance] setGaeFriends:nil];
            
            NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:infoPath];
			
			NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
			[cacheStorage removeObjectForKey:@"LastLoginEmail"];
			[cacheStorage removeObjectForKey:@"LastLoginFacebookId"];
			[cacheStorage removeObjectForKey:@"LastLoginTwitterId"];
			[cacheStorage synchronize];
            
            NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
            
            Facebook *facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
            
            [facebook logout:self];
            facebook.accessToken = nil;
            facebook.expirationDate = nil;
            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray* facebookCookies = [cookies cookiesForURL:
                                        [NSURL URLWithString:@"http://login.facebook.com"]];
            
            for (NSHTTPCookie* cookie in facebookCookies) {
                [cookies deleteCookie:cookie];
            }
            
            return;
        }
    }
    
    if (alertView.tag == 1003) {
        if(buttonIndex == 1){
            //else it is the review alert so send user to itunes store
            //TODO replace link with app's itunes page when we have one
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://tymepass.com/review"]];
			
           // [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com"]];
            return;
        }
    }
    
    return;
}

-(void)callApi {
	
	userOperation = [ApplicationDelegate.userEngine updateNotifications:settingsDictionary onCompletion:^(NSString *status) {
		
		[HUD setHidden:YES];
		if ([[settingsDictionary valueForKey:@"iCal_sync"] intValue] == 1) {
			
			[[GlobalData sharedGlobalData] setSync:TRUE];
			[[GlobalData sharedGlobalData] setGetGAEFriends:FALSE];
			
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
			
			[self.navigationController popToRootViewControllerAnimated:NO];
		}
		
		
		
	} onError:^(NSError* error) {
		[HUD setHidden:YES];
	}];
}

- (void)fbDidLogin {
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [Utils storeFBAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle: nil
                              otherButtonTitles: @"OK",nil];
    [alertView show];
    [self fbDidLogout];
}

- (void)fbDidLogout{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    membersLoginViewController = [[MembersLoginViewController alloc] initWithNibName:@"MembersLoginViewController" bundle:nil];
    
    //remove all screens from navigation array
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //change root controller
    [ApplicationDelegate changeNavigationRoot:membersLoginViewController];
    
}
- (IBAction)timezoneBtnPressed:(id)sender {
    timezoneViewController = [[TimezoneViewController alloc] initWithNibName:@"TimezoneViewController" bundle:nil];
    [self.navigationController pushViewController:timezoneViewController animated:YES];
}

@end