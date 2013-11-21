//
//  MyProfileViewController.m
//  Timepass
//
//  Created by Mahmood1 on 19/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyProfileViewController.h"
#import "CalendarAgendaViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "User+GAEUser.h"
#import "Event+GAE.h"
#import "Invitation+GAE.h"
#import "NSDataAdditions.h"
#import "MyGoldEventsViewController.h"
#import "NotificationsViewController.h"
#import "NewsfeedViewController.h"
#import "FriendsViewController.h"
#import "Utils.h"

enum {
    SectionCalendar               = 0,
    SectionInvitations            = 1,
    SectionNewsreel               = 2,
    SectionFriends                = 3,
    SectionsCount                 = 4
};

enum {
    CalendarSectionRowsCount           = 1
};

enum {
    InvitationsSectionRowsCount        = 4
};

enum {
    NewsreelSectionRowsCount           = 4
};

enum {
    FriendsSectionRowsCount            = 1
};

FriendsViewController *friendsViewController;

@implementation MyProfileViewController
@synthesize scrollView;
@synthesize profileImageView;
@synthesize profileNameLabel;
@synthesize birthdayLabel;
@synthesize professionLabel;
@synthesize sexLabel;
@synthesize locationLabel;
@synthesize tableView;
@synthesize viewAllInvitationsBtn;
@synthesize viewAllNewsBtn;

@synthesize invitationsOperation;
@synthesize newsReelOperation;
@synthesize friendsOperation;
@synthesize goldStarredOperation;

@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        profileUser = [[SingletonUser sharedUserInstance] user];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user invitationId:(NSString *) invId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        invitationId = invId;
        profileUser = user;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        profileUser = user;
        
        
        //newsReelArray = [User getNewsreelOfUser:[user serverId]];
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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"My Profile", @"My Profile");
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
	
    // Do any additional setup after loading the view from its nib.
    
    [scrollView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
    //Below line is commented by krunal on 4th Oct.'12
    //scrollViewHeight = 600;
    scrollViewHeight = 600;
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewHeight)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Edit"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(editProfile:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.profileImageView.backgroundColor = [UIColor clearColor];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.opaque = NO;
    
    viewAllInvitationsBtn = [ApplicationDelegate.uiSettings createButton:@"View All Invitations"];
    [viewAllInvitationsBtn setFrame:CGRectMake(self.view.frame.size.width - 180.0, 27.0, 170.0, 44.0)];
    viewAllInvitationsBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:[ApplicationDelegate.uiSettings buttonFontSize]];
    [viewAllInvitationsBtn addTarget:self action:@selector(viewAllInvitations:) forControlEvents:UIControlEventTouchUpInside];
    
    viewAllNewsBtn = [ApplicationDelegate.uiSettings createButton:@"View All News"];
    [viewAllNewsBtn setFrame:CGRectMake(self.view.frame.size.width - 180.0, 8.0, 170.0, 44.0)];
    viewAllNewsBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:[ApplicationDelegate.uiSettings buttonFontSize]];
    [viewAllNewsBtn addTarget:self action:@selector(viewAllNews:) forControlEvents:UIControlEventTouchUpInside];
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, [ApplicationDelegate navigationController].view.frame.size.width, [ApplicationDelegate navigationController].view.frame.size.height);
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    
    //Below line is added by krunal
    [self loadImages];
}

- (void)viewDidUnload
{
    [self setProfileNameLabel:nil];
    [self setBirthdayLabel:nil];
    [self setProfessionLabel:nil];
    [self setSexLabel:nil];
    [self setLocationLabel:nil];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setProfileImageView:nil];
    [self setViewAllInvitationsBtn:nil];
    [self setViewAllNewsBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    
    if (profileUser) {
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",profileUser.name,profileUser.surname];
        profileNameLabel.text = fullName;
        
        [profileImageView setImageWithURL:[NSURL URLWithString:profileUser.photo]
						 placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
		
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:profileImageView.bounds
													   byRoundingCorners:UIRectCornerBottomRight
															 cornerRadii:CGSizeMake(5.0, 5.0)];
		
		// Create the shape layer and set its path
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		maskLayer.frame = profileImageView.bounds;
		maskLayer.path = maskPath.CGPath;
		
		// Set the newly created shape layer as the mask for the image view's layer
		profileImageView.layer.mask = maskLayer;
		
        if (profileUser.dateOfBirth) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"d MMM yyyy"];
            
            birthdayLabel.text = [df stringFromDate:profileUser.dateOfBirth];
        }
        else
            birthdayLabel.text = @"-";
        
        NSArray *listOfSexes = [[NSArray alloc] initWithObjects:@"Male",@"Female",@"-",nil];
        sexLabel.text = [listOfSexes objectAtIndex:[profileUser.gender intValue]];
        
        //get the user's location
        if (profileUser.homeLocationId && [[profileUser.homeLocationId name] length] > 0)
            locationLabel.text = profileUser.homeLocationId.name;
        else
            locationLabel.text = @"-";
        
        //set profession
        if (profileUser.occupation && [profileUser.occupation length] > 0)
            professionLabel.text = profileUser.occupation;
        else
            professionLabel.text = @"-";
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	
    newsReelOperation = [ApplicationDelegate.userEngine requestObjectOfUser:profileUser objectType:@"newsReel" onCompletion:^(NSArray *responseData) {
		newsReelArray = [NSMutableArray arrayWithArray:[User getNewsreel:responseData]];
		
		if ([newsReelArray count] > 0) {
			if ([newsReelArray count] < 4)
				scrollViewHeight += 192;
			else
				scrollViewHeight += [newsReelArray count] * 48;
		}
		
		[scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewHeight)];
		
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
		[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	} onError:^(NSError* error) {
	}];
	
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:profileUser objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];		
	} onError:^(NSError* error) {
	}];
	
	[HUD hide:YES];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self cancelOperations];
    [super viewDidDisappear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
	self.title = @"";
	[HUD hide:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods
- (void)editProfile:(id)sender {
	editMyProfileViewController = [[EditMyProfileViewController alloc] initWithNibName:@"EditMyProfileViewController" bundle:nil user:profileUser];
    
    [self.navigationController pushViewController:editMyProfileViewController animated:YES];
}

- (void)viewAllInvitations:(id) sender {
    NotificationsViewController *notificationsViewController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
    
    [self.navigationController pushViewController:notificationsViewController animated:YES];
}

- (void)viewAllNews:(id) sender {
    NewsfeedViewController *newsfeedViewController = [[NewsfeedViewController alloc] initWithNibName:@"NewsfeedViewController" bundle:nil];
    [self.navigationController pushViewController:newsfeedViewController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return SectionsCount;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (!newsReelArray) {
        return 1;
    } else {
        if ([newsReelArray count] == 0) {
            return 1;
        } else {
            return newsReelArray.count;// > NewsreelSectionRowsCount ? newsReelArray.count : NewsreelSectionRowsCount ;
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 30.0)];
    headerView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    headerLabel.text =  @"RECENT NEWS";
    
    [headerView addSubview:headerLabel];
	
	UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_panel.png"]];
	[shadow setFrame:CGRectMake(0.0, 25.0, 320.0, 5.0)];
	[headerView addSubview:shadow];
	
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    if (!newsReelArray) {
        UIView *spinnerView = [[UIView alloc] initWithFrame:CGRectMake(15.0, 12.0, 31.0, 30.0)];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinnerView addSubview:spinner];
        
        [cell.contentView addSubview:spinnerView];
        
        [spinner startAnimating];
    } else {
        if ([newsReelArray count] == 0) {
            cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"No news";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setSelected:FALSE];
            [cell setEditing:FALSE];
            
        } else {
            NSDictionary *dict = [newsReelArray objectAtIndex:indexPath.row];
            UIImageView *imageView = [[UIImageView alloc] init];
			
			[imageView setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
					  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
            
            [imageView setFrame:CGRectMake(8.0, 8.0, 31.0, 30.0)];
			imageView.layer.cornerRadius = 4;
			[imageView setClipsToBounds: YES];
            [cell.contentView addSubview:imageView];
            
            CGRect frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, 8.0f, cell.frame.size.width - imageView.frame.size.width - 8.0f, cell.frame.size.height);
            
            [cell.contentView addSubview:[self setNewsreelObject:dict setType:[dict objectForKey:@"type"] intoFrame:frame]];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cancelOperations];
    if ([newsReelArray count] == 0)
        return;
    
    NSDictionary *dict = [newsReelArray objectAtIndex:indexPath.row];
    NSString *type = [dict valueForKey:@"type"];
	
	if ([type isEqualToString:@"FriendRequestAccepted"] ||
		[type isEqualToString:@"UserPicture"] ||
		[type isEqualToString:@"UserFriends"]) {
        User* pressedUser = [User getUserWithId:[dict valueForKey:@"friendId"] inContext:[[Utils sharedUtilsInstance] scratchPad]];
        UIViewController *profileController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:pressedUser];
        
        [self.navigationController pushViewController:profileController animated:YES];
        //text = [NSString stringWithFormat:@"%@ %@ is now friend with %@ %@", [dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"friendName"], [dict valueForKey:@"friendSurname"]];
        
    } else if ([type isEqualToString:@"EventRequestAccepted"] ||
			   [type isEqualToString:@"EventRequestAcceptedGold"] ||
			   [type isEqualToString:@"OpenEvent"] ||
			   [type isEqualToString:@"EventMessage"] ||
			   [type isEqualToString:@"CommentEvent"] ||
			   [type isEqualToString:@"GoldEvent"] ||
			   [type isEqualToString:@"EventPicture"]) {
        //get event from eventId
        Event* pressedEvent = [Event getEventWithId:[dict valueForKey:@"eventId"]];
        
        if (!pressedEvent) {
            //pressedEvent = [Event getGAEEventWithIds:notExistingEventIdsArray attendingEventStatus:eventAttendingArray inContext:[modelUtils defaultManagedObjectContext]];
            pressedEvent = [[Event getGAEEventWithIds:[NSArray arrayWithObject:[dict valueForKey:@"eventId"]] inContext:[[Utils sharedUtilsInstance] scratchPad]] objectAtIndex:0];
            
        }
        
        UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:pressedEvent];
        
        [self.navigationController pushViewController:eventViewController animated:YES];
    }
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(TTTAttributedLabel *) setInvitationObject:(id)obj setType:(NSString *) type intoFrame:(CGRect)frame {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
    label.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 2;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    label.backgroundColor = [UIColor clearColor];
    label.frame = frame;
    
    NSString *text = @"";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy"];
    
    if ([type isEqualToString:@"event"]) {
        text = [NSString stringWithFormat:@"%@ %@ would like to Tymepass you to %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
    }
    else
        text = [NSString stringWithFormat:@"%@ %@ wants to be your Tymepass friend",[(User *)obj name],[(User *)obj surname]];
    
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                       constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    
    float originY = frame.origin.y;
    
    if (textSize.width < 210.0f)
        originY += 8.0f;
    
    [label setFrame:CGRectMake(frame.origin.x, originY, label.frame.size.width - 30.0f, label.frame.size.height)];
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:text];
    
    __block NSMutableAttributedString *maString;
	
    [label setText:string afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        if ([type isEqualToString:@"event"]) {
            NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[(Event *)obj title]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange3 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[df stringFromDate:[(Event *)obj startTime]]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange3];
                
                CFRelease(font);
            }
        } else {
            NSRange boldRange = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[(User *)obj name],[(User *)obj surname]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                
                CFRelease(font);
            }
        }
        
        maString = mutableAttributedString;
        
        return mutableAttributedString;
    }];
    
    NSMutableAttributedString *dots = [[NSMutableAttributedString alloc] initWithString:@"..."];
    
    if ([maString length] > 71) {
        [maString appendAttributedString:dots];
        
        while ([maString length] > 67) {
            [maString deleteCharactersInRange:NSMakeRange ([maString length] - 4,1)];
            
            textSize = [maString.string sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                                   constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                                       lineBreakMode:UILineBreakModeWordWrap];
        }
    }
    
    [label setText:maString];
    
    return label;
}

-(TTTAttributedLabel *) setNewsreelObject:(NSMutableDictionary *) dict setType:(NSString *) type intoFrame:(CGRect)frame {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
    label.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 3;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    label.backgroundColor = [UIColor clearColor];
    
    label.frame = frame;
    
    NSString *text = @"";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy"];
	
	if ([type isEqualToString:@"FriendRequestAccepted"]) {
        
		text = [NSString stringWithFormat:@"%@ %@ is now friends with %@ %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"friendName"], [dict valueForKey:@"friendSurname"]];
	}
	
	if ([type isEqualToString:@"UserFriends"]) {
        
		text = [NSString stringWithFormat:@"%@ %@ is now friends with %@ %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"friendName"], [dict valueForKey:@"friendSurname"]];
	}
	
	else if([type isEqualToString:@"UserPicture"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has changed his profile picture", [dict valueForKey:@"name"],[dict valueForKey:@"surname"]];
	}
	
	else if([type isEqualToString:@"EventRequestAccepted"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ is attending %@ on %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"],[df stringFromDate:[dict valueForKey:@"startTime"]]];
	}
	
	else if([type isEqualToString:@"EventRequestAcceptedGold"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ is attending %@ on %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"],[df stringFromDate:[dict valueForKey:@"startTime"]]];
	}
	
	else if([type isEqualToString:@"OpenEvent"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has created an open event %@ on %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"],[df stringFromDate:[dict valueForKey:@"startTime"]]];
	}
	
	
	else if([type isEqualToString:@"EventRequestMayBe"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ might be attending %@ on %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"],[df stringFromDate:[dict valueForKey:@"startTime"]]];
	}
	
	else if([type isEqualToString:@"GoldEvent"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has goldstarred %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
	else if([type isEqualToString:@"EventMessage"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has commented in %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
	else if([type isEqualToString:@"EventPicture"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has changed  the picture for %@", [dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                       constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    
    float originY = frame.origin.y;
    
    [label setFrame:CGRectMake(frame.origin.x, originY, label.frame.size.width - 20.0f, label.frame.size.height)];
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:text];
    
    __block NSMutableAttributedString *maString;
    
    [label setText:string afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        if ([type isEqualToString:@"FriendRequestAccepted"] ||
			[type isEqualToString:@"UserPicture"] ||
			[type isEqualToString:@"UserFriends"]) {
            NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"friendName"], [dict valueForKey:@"friendSurname"]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
                
                CFRelease(font);
            }
        } else {
            NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@", [dict valueForKey:@"title"]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange3 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@", [df stringFromDate:[dict valueForKey:@"startTime"]]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange3];
                
                CFRelease(font);
            }
        }
        
        maString = mutableAttributedString;
        
        return mutableAttributedString;
    }];
    
    NSMutableAttributedString *dots = [[NSMutableAttributedString alloc] initWithString:@"..."];
    
    if ((textSize.height - label.frame.size.height) > 13.0f) {
        [maString appendAttributedString:dots];
        
        while (textSize.height > label.frame.size.height + 13.0f) {
            [maString deleteCharactersInRange:NSMakeRange ([maString length] - 4,1)];
            
            textSize = [maString.string sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                                   constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                                       lineBreakMode:UILineBreakModeWordWrap];
        }
        
        /*
		 [string replaceOccurrencesOfString:@" ..."
		 withString:@"..."
		 options:0
		 range:NSMakeRange(0, [string length])];
         */
    } else {
        if (maString.length > 105) {
            NSUInteger lengthDif = [maString length] - 105;
            [maString deleteCharactersInRange:NSMakeRange ([maString length] - lengthDif,lengthDif)];
            [maString deleteCharactersInRange:NSMakeRange ([maString length] - 3,3)];
            
            [maString appendAttributedString:dots];
        }
    }
    
    [label setText:maString];
    
    return label;
}

-(void) cancelOperations {
    if (self.invitationsOperation) {
        [self.invitationsOperation cancel];
        self.invitationsOperation = nil;
    }
    
    if (self.newsReelOperation) {
        [self.newsReelOperation cancel];
        self.newsReelOperation = nil;
    }
    
    if (self.friendsOperation) {
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
    }
}

#pragma Mark Button and custom Methods
//Below line are added by krunal on 4th Oct.'12

-(void)loadImages {
    goldStarredOperation = [ApplicationDelegate.userEngine requestObjectOfUser:profileUser objectType:@"goldEvents" onCompletion:^(NSArray *responseData) {
		
		NSArray *listItems = [[responseData objectAtIndex:0] objectForKey:@"entities"];
		
		int OriginX = 4;
		int OriginY = 4;
		int imgViewHeight = 44;
		int imgViewWidth = 44;
		
		int i = 0;
		int j = 0;
		int total = 0;
		
		for (NSMutableDictionary *dict in listItems) {
			
			NSMutableDictionary *data = [dict mutableCopy];
			
			UIButton *btnImage;
			if (total == 0) {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth, OriginY, imgViewWidth, imgViewHeight)];
			} else {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth + j, OriginY, imgViewWidth, imgViewHeight)];
			}
			
			btnImage.tag = [[dict valueForKey:@"id"] intValue];
			
			UIImage* thumbImage;
			thumbImage = [UIImage imageNamed:@"camera_img.png"];
			thumbImage = [Utils resizedFromImage:thumbImage inPixes:88];
			[btnImage setImage:thumbImage forState:UIControlStateNormal];
			
			if ([[data objectForKey:@"photo"] isEqualToString:@""] == FALSE) {
				
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[data objectForKey:@"photo"]]];
				AFImageRequestOperation *operation;
				operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
					image = [Utils resizedFromImage:image inPixes:88];
					[btnImage setImage:image forState:UIControlStateNormal];
				}];
				
				[operation start];
			}
			
			[btnImage addTarget:self action:@selector(btnEvenViewPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:btnImage];
			
			j++;
			
			if (j >= 7 && i == 0) {
				i++;
				j = 0;
				OriginX = 139;
				OriginY += imgViewHeight+2;
			} else if(j >= 4 && i > 0) {
				i++;
				j = 0;
				OriginY += imgViewHeight+2;
			}
			
			total++;
			if (total >= 15) {
				break;
			}
			
		}
		
		while (true) {
			
			if (total >= 15) {
				break;
			}
			
			UIImage* thumbImage = [UIImage imageNamed:@"star_box.png"];
			
			UIButton *btnImage;
			if (total == 0) {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth, OriginY, imgViewWidth, imgViewHeight)];
			} else {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth + j, OriginY, imgViewWidth, imgViewHeight)];
			}
			
			[btnImage setImage:thumbImage forState:UIControlStateNormal];
			[self.scrollView addSubview:btnImage];
			
			j++;
			
			if (j >= 7 && i == 0) {
				i++;
				j = 0;
				OriginX = 139;
				OriginY += imgViewHeight+2;
			} else if(j >= 4 && i > 0) {
				i++;
				j = 0;
				OriginY += imgViewHeight+2;
			}
			
			total++;
		}
		
	} onError:^(NSError* error) {
	}];

}

-(IBAction)btnEvenViewPressed:(id)sender {
	Event *invitationEvent = [[Event getGAEEventWithIds:[NSArray arrayWithObject:[NSString stringWithFormat:@"%d", [sender tag]]] inContext:[[Utils sharedUtilsInstance] scratchPad]] objectAtIndex:0];
	
	UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:invitationEvent];
	[self.navigationController pushViewController:eventViewController animated:YES];
}

-(IBAction)btnGoldStarredClicked:(id)sender {
    MyGoldEventsViewController *controller = [[MyGoldEventsViewController alloc] initWithNibName:@"MyGoldEventsViewController" bundle:nil];
	[self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)btnFriendsClicked:(id)sender {
    if (!friendsViewController)
        friendsViewController = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil];
    
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

-(IBAction)btnCalendarClicked:(id)sender {
    if (!calendarViewController) {
        CalendarAgendaViewController *calendarAgendaViewController = [[CalendarAgendaViewController alloc] initWithNibName:@"CalendarAgendaViewController" bundle:nil];
        
        calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarAgendaViewController showToolBar:YES];
    }
    
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

@end