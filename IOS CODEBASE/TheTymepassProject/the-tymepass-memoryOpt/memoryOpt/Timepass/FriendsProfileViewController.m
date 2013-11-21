//
//  FriendsProfileViewController.m
//  Timepass
//
//  Created by mac book pro on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsProfileViewController.h"
#import "CalendarMonthViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendsFriendsViewController.h"
#import "MessageWallTableViewController.h"
#import "EventViewController.h"
#import "Event+GAE.h"
#import "NSDataAdditions.h"
#import "CalendarViewController.h"
#import "Utils.h"
#import "CreateEventViewController.h"
#import "GoldEventsViewController.h"
#import "AFImageRequestOperation.h"

enum {
    SectionCalendar               = 0,
    SectionUpcomingEvents         = 1,
    SectionFriends                = 2,
    SectionButtons                = 3,
    SectionsCount                 = 4
};

enum {
    CalendarSectionRowsCount           = 1
};

enum {
    NewsreelSectionRowsCount		   = 4
};

enum {
    FriendsSectionRowsCount            = 1
};

enum {
    ButtonsSectionRowsCount            = 0
};

@implementation FriendsProfileViewController
@synthesize scrollView;
@synthesize profileImageView;
@synthesize profileNameLabel;
@synthesize birthdayLabel;
@synthesize sexLabel;
@synthesize locationLabel;
@synthesize tableView;
@synthesize createEventAndInviteBtn;
@synthesize unFriendBtn;

@synthesize HUD;

@synthesize infoOperation;
@synthesize friendsOperation;
@synthesize newsReelOperation;
@synthesize goldStarredOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user invitationId:(NSString *) invId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        invitationId = invId;
        aFriend = user;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil afriend:(User *) afriend
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        aFriend = afriend;
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
    
    [scrollView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    
	//Below line is commented by krunal on 4th Oct.'12
    //[scrollView setContentSize:CGSizeMake(self.view.frame.size.width,560)];
    scrollViewHeight = 600;
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewHeight)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.profileImageView.backgroundColor = [UIColor clearColor];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.opaque = NO;
	
    createEventAndInviteBtn = [ApplicationDelegate.uiSettings createButton:@"Create Event & Invite"];
    createEventAndInviteBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:[ApplicationDelegate.uiSettings buttonFontSize]];
    [createEventAndInviteBtn addTarget:self action:@selector(createEventAndInvite:) forControlEvents:UIControlEventTouchUpInside];
    
    unFriendBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [unFriendBtn setBackgroundImage:[UIImage imageNamed:@"unfriend_btn.png"] forState:UIControlStateNormal];
    [unFriendBtn setBackgroundImage:[UIImage imageNamed:@"unfriend_btn_pressed.png"] forState:UIControlStateHighlighted];
    [unFriendBtn addTarget:self action:@selector(unFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",aFriend.name,aFriend.surname];
    profileNameLabel.text = fullName;
    
	[profileImageView setImageWithURL:[NSURL URLWithString:aFriend.photo]
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
	    
    if (aFriend.dateOfBirth) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"d MMM"];
        
        birthdayLabel.text = [df stringFromDate:aFriend.dateOfBirth];
    }
    else {
        birthdayLabel.text = @"";
	}
    
    NSArray *listOfSexes = [[NSArray alloc] initWithObjects:@"Male",@"Female",@"",nil];
    sexLabel.text = [listOfSexes objectAtIndex:[aFriend.gender intValue]];
    
    //get the user's location
    if (aFriend.homeLocationId && [[aFriend.homeLocationId name] length] > 0)
        locationLabel.text = aFriend.homeLocationId.name;
    else {
        locationLabel.text = @"";
	}
	
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    
    //Below line is added by krunal
    [self loadImages];
}

- (void)viewDidUnload
{
    [self setProfileNameLabel:nil];
    [self setBirthdayLabel:nil];
    [self setSexLabel:nil];
    [self setLocationLabel:nil];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setProfileImageView:nil];
    [self setCreateEventAndInviteBtn:nil];
    [self setUnFriendBtn:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    newsReelOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"newsReel" onCompletion:^(NSArray *responseData) {
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
    
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
	} onError:^(NSError* error) {
	}];
	
	infoOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"getFriendship" onCompletion:^(NSArray *responseData) {
		
		NSDictionary *responseDict;
		BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
		if (!isIOS5){
			// Create new SBJSON parser object
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			id jsonObject = [parser objectWithString:(NSString *)responseData];
			
			if ([jsonObject isKindOfClass:[NSDictionary class]]){
				// treat as a dictionary, or reassign to a dictionary ivar
				debugLog(@"Dictionary");
				responseDict = [[NSDictionary alloc] initWithDictionary:jsonObject];
			}
			else if ([jsonObject isKindOfClass:[NSArray class]]){
				debugLog(@"Array");
				responseDict = [[NSDictionary alloc] initWithObjects:jsonObject forKeys:jsonObject];
			}
		} else {
			responseDict = [[NSDictionary alloc] initWithDictionary:[responseData objectAtIndex:0]];
		}
		
		lblNumberOfEventsGoldstarred.text = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"totalGoldStarEvents"]];
		lblNumberOfEvents.text = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"commonEvent"]];
		lblFriendsForDays.text = [NSString stringWithFormat:@"%@", [responseDict valueForKey:@"timeStamp"]];
		
	} onError:^(NSError* error) {
	}];
	
	[HUD hide:YES];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Profile", @"Profile");
}

- (void)viewWillDisappear:(BOOL)animated
{
	[HUD hide:YES];
	self.title = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self cancelOperations];
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods
- (void)createEventAndInvite:(id)sender {
    CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil invitee:aFriend];
    
    [self.navigationController pushViewController:createEventViewController animated:YES];
}

- (void)unFriend:(id) sender {
    [User unfriendGAEUser:[aFriend serverId] with:[[[SingletonUser sharedUserInstance] user] serverId]];
    [HUD hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
            return newsReelArray.count;// < NewsreelSectionRowsCount ? newsReelArray.count : NewsreelSectionRowsCount ;
		}
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
	headerView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
	
    [headerLabel setFrame:CGRectMake(12.0, -5.0, 300.0, 20.0)];
    headerLabel.text =  @"RECENT NEWS";
    [headerView addSubview:headerLabel];
	
	UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_panel.png"]];
	[shadow setFrame:CGRectMake(0.0, 20.0, 320.0, 5.0)];
	[headerView addSubview:shadow];
    
    return headerView;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
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
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profilepic.png"]];
            
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
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
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

-(TTTAttributedLabel *) setNewsreelObject:(NSDictionary *) dict setType:(NSString *) type intoFrame:(CGRect)frame {
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

-(TTTAttributedLabel *) setEvent:(Event *)event intoFrame:(CGRect)frame {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
    label.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 2;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    label.backgroundColor = [UIColor clearColor];
    
    label.frame = frame;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy"];
    
    NSString *text = [NSString stringWithFormat:@"%@ on %@",[event title], [df stringFromDate:event.startDate]];
    
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
        
        NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[event title]] options:NSCaseInsensitiveSearch];
        
        NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[df stringFromDate:event.startDate]] options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
            
            CFRelease(font);
        }
        
        maString = mutableAttributedString;
        
        return mutableAttributedString;
    }];
    
    NSMutableAttributedString *dots = [[NSMutableAttributedString alloc] initWithString:@"..."];
    
    if ([maString length] > 71) {
        [maString appendAttributedString:dots];
        
        while ([maString length] > 71) {
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
    }
    
    /*
	 else {
	 if (maString.length > 105) {
	 NSUInteger lengthDif = [maString length] - 105;
	 [maString deleteCharactersInRange:NSMakeRange ([maString length] - lengthDif,lengthDif)];
	 [maString deleteCharactersInRange:NSMakeRange ([maString length] - 3,3)];
	 
	 [maString appendAttributedString:dots];
	 }
	 }
	 */
    
    [label setText:maString];
    
    return label;
}

-(void) cancelOperations {
    if (self.friendsOperation) {
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
    }
	
	if (self.newsReelOperation) {
		[self.newsReelOperation cancel];
        self.newsReelOperation = nil;
	}
	
	if (self.goldStarredOperation) {
		[self.goldStarredOperation cancel];
		self.goldStarredOperation = nil;
	}
}
#pragma Mark Button and custom Methods
//Below line are added by krunal on 4th Oct.'12

-(void)loadImages {
	
	goldStarredOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"goldEvents" onCompletion:^(NSArray *responseData) {
		
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
			
			if ([[data objectForKey:@"photo"] isEqualToString:@""] == FALSE) {
				
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[data objectForKey:@"photo"]]];
				AFImageRequestOperation *operation;
				operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
					image = [Utils resizedFromImage:image inPixes:88];
					[btnImage setImage:image forState:UIControlStateNormal];
				}];
				
				[operation start];
			}
			
			[btnImage setImage:thumbImage forState:UIControlStateNormal];
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

-(IBAction)btnYouAreFriendsClicked:(id)sender {
	
	[btnYouAreFriends setEnabled:false];
	
    [customFriendView setFrame:CGRectMake(0, 300, 320, 130)];
    
    [self.scrollView addSubview:customFriendView];
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width,900)];
    
    CGRect frame = imgViewHorizontalLine1.frame;
    frame.origin.y += 140;
    imgViewHorizontalLine1.frame = frame;
    
	frame = imgViewHorizontalLine2.frame;
    frame.origin.y += 140;
    imgViewHorizontalLine2.frame = frame;
    
	frame = btnGoldStarred.frame;
    frame.origin.y += 140;
    btnGoldStarred.frame = frame;
    
	frame = btnFriends.frame;
    frame.origin.y += 140;
    btnFriends.frame = frame;
    
	frame = btnCalendar.frame;
    frame.origin.y += 140;
    btnCalendar.frame = frame;
    
	frame = lblCalendar.frame;
    frame.origin.y += 140;
    lblCalendar.frame = frame;
    
	frame = lblFriends.frame;
    frame.origin.y += 140;
    lblFriends.frame = frame;
    
	frame = lblGoldStarred.frame;
    frame.origin.y += 140;
    lblGoldStarred.frame = frame;
    
	frame = self.tableView.frame;
    frame.origin.y += 140;
    self.tableView.frame = frame;
}

-(IBAction)btnSendMessage:(id)sender {
    MessageWallTableViewController *controller = [[MessageWallTableViewController alloc] initWithMessages:nil forUser:aFriend];
	[self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)btnGoldStarredClicked:(id)sender {
    GoldEventsViewController *controller = [[GoldEventsViewController alloc] initWithNibName:@"GoldEventsViewController" bundle:nil forFriend:aFriend];
	[self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)btnFriendsClicked:(id)sender
{
    FriendsFriendsViewController *friendsFriendsViewController = [[FriendsFriendsViewController alloc] initWithNibName:@"FriendsFriendsViewController" bundle:nil user:aFriend friends:friendsArray];
    
    [self.navigationController pushViewController:friendsFriendsViewController animated:YES];
}
-(IBAction)btnCalendarClicked:(id)sender
{
    CalendarMonthViewController *calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil friend:aFriend inContext:[[Utils sharedUtilsInstance] scratchPad]];
    
    CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarMonthViewController showToolBar:YES aFriend:aFriend inContext:[[Utils sharedUtilsInstance] scratchPad]];
    
    [calendarMonthViewController.tdCalendarView setViewController:calendarViewController];
    [calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
    
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

-(IBAction)btnUnfriendClicked:(id)sender {
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Updating...";
    HUD.dimBackground = YES;
	
    [self performSelector:@selector(unFriend:) withObject:nil afterDelay:0.1];
}
-(IBAction)btnDoneClicked:(id)sender {
	
	[btnYouAreFriends setEnabled:TRUE];
    [customFriendView removeFromSuperview];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width,760)];
    CGRect frame = imgViewHorizontalLine1.frame;
    frame.origin.y -= 140;
    imgViewHorizontalLine1.frame = frame;
    
	frame = imgViewHorizontalLine2.frame;
    frame.origin.y -= 140;
    imgViewHorizontalLine2.frame = frame;
    
	frame = btnGoldStarred.frame;
    frame.origin.y -= 140;
    btnGoldStarred.frame = frame;
    
	frame = btnFriends.frame;
    frame.origin.y -= 140;
    btnFriends.frame = frame;
    
	frame = btnCalendar.frame;
    frame.origin.y -= 140;
    btnCalendar.frame = frame;
    
	frame = lblCalendar.frame;
    frame.origin.y -= 140;
    lblCalendar.frame = frame;
    
	frame = lblFriends.frame;
    frame.origin.y -= 140;
    lblFriends.frame = frame;
    
	frame = lblGoldStarred.frame;
    frame.origin.y -= 140;
    lblGoldStarred.frame = frame;
    
	frame = self.tableView.frame;
    frame.origin.y -= 140;
    self.tableView.frame = frame;
}
@end
