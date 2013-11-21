//
//  NewsfeedViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsfeedViewController.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "FriendsProfileViewController.h"
#import "NotificationsViewController.h"
#import "CreateEventViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Event+GAE.h"
#import "TTTAttributedLabel.h"

@implementation NewsfeedViewController
@synthesize newsreelItems, tableView;
@synthesize eventPageViewController;
@synthesize HUD;
@synthesize newsReelOperation;
@synthesize notificationsOperation;
@synthesize headerDetailLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        user = [[SingletonUser sharedUserInstance] user];
        
        //fetch the pending events
        //newsreelItems = [User getNewsreelOfUser:[user serverId]];
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0, 65.0, 32.0)];
	
	//CalendarView not being initialized by CreateEventView
	UIButton *addEventBtn = [ApplicationDelegate.uiSettings createButton:@""];
	[addEventBtn setFrame:CGRectMake(0.0, -1.0, 65.0, 32.0)];
	[addEventBtn setBackgroundImage:[UIImage imageNamed:@"add_event_navbar_btn.png"] forState:UIControlStateNormal];
	[addEventBtn setBackgroundImage:[UIImage imageNamed:@"add_event_navbar_btn_pressed.png"] forState:UIControlStateHighlighted];
	[addEventBtn addTarget:self action:@selector(addEvent:)  forControlEvents:UIControlEventTouchUpInside];
	
	[view addSubview:addEventBtn];
	
	UIBarButtonItem *btn =[[UIBarButtonItem alloc] initWithCustomView:view];
	self.navigationItem.rightBarButtonItem = btn;
    
	UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 46.0)];
    
	UIImage *icon = [UIImage imageNamed:@"afrtm_icon.png"];
	UIImageView *infoIconView = [[UIImageView alloc] initWithImage:icon];
	infoIconView.frame = CGRectMake(20.0, 10.0, 24.0, 23.0);
	
	headerDetailLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(60.0, 10.0, 200.0, 23.0)];
	headerDetailLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont]
											 size:[ApplicationDelegate.uiSettings cellFontSize]];
	
	headerDetailLabel.textColor = [UIColor grayColor];
	
	headerDetailLabel.backgroundColor = [UIColor clearColor];
	headerDetailLabel.textAlignment = UITextAlignmentLeft;
	
	UIButton *notificationBtn = [ApplicationDelegate.uiSettings createButton:@""];
	[notificationBtn setBackgroundImage:[UIImage imageNamed:@"more-arrow.png"] forState:UIControlStateNormal];
	notificationBtn.frame = CGRectMake(300.0, 15.0, 9.0, 13.0);
	
	UIButton *notificationBtnFull = [ApplicationDelegate.uiSettings createButton:@""];
	[notificationBtnFull setBackgroundImage:nil forState:UIControlStateNormal];
	notificationBtnFull.frame = CGRectMake(0.0, 0.0, 320.0, 46.0);
	[notificationBtnFull addTarget:self action:@selector(notificationsBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	[headerView addSubview:infoIconView];
	[headerView addSubview:headerDetailLabel];
	[headerView addSubview:notificationBtn];
	[headerView addSubview:notificationBtnFull];
	
	[self.view addSubview:headerView];
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
}

- (void)viewDidUnload
{
    if (tableView)
        [self setTableView:nil];
    
    if (eventPageViewController)
        [self setEventPageViewController:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Newsreel", @"Newsreel");
}

- (void)viewDidAppear:(BOOL)animated {
    newsReelOperation = [ApplicationDelegate.userEngine requestObjectOfUser:user objectType:@"newsReelPage" onCompletion:^(NSArray *responseData) {
		newsreelItems = [NSMutableArray arrayWithArray:[User getNewsreelPage:responseData]];
		NSLog(@"%@",newsreelItems);
		if (newsreelItems.count == 0) {
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"No news yet!", nil);
			
			[footerTableView addSubview:label];
			
			tableView.tableFooterView = footerTableView;
		}
		else {
			[self.tableView reloadData];
		}
		
		[HUD hide:YES];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
	
	notificationsOperation = [ApplicationDelegate.invitationEngine requestInvitationsCountOfUser:user onCompletion:^(NSArray *responseData) {
		BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
		if (!isIOS5){
			// Create new SBJSON parser object
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			responseData = [parser objectWithString:(NSString *) responseData];
		}
		
		int total = [[[responseData objectAtIndex:0] valueForKey:@"Count"] intValue];
		NSString *totalString = [NSString stringWithFormat:@"(%d)", total];
		
		[headerDetailLabel setText:[NSString stringWithFormat:@"Notifications %@", totalString] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
			NSRange range = [[mutableAttributedString string] rangeOfString:totalString options:NSCaseInsensitiveSearch];
			
			UIColor *color = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerColorRed
													green:ApplicationDelegate.uiSettings.headerColorGreen
													 blue:ApplicationDelegate.uiSettings.headerColorBlue
													alpha:1.0];
			
			[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
			
			UIFont *boldSystemFont =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:[ApplicationDelegate.uiSettings cellFontSize]];
			CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
			if (font) {
				[mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
				CFRelease(font);
			}
			
			return mutableAttributedString;
		}];
		
		
	} onError:^(NSError* error) {
		
	}];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.title = nil;
    [HUD hide:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.newsReelOperation) {
        [self.newsReelOperation cancel];
        self.newsReelOperation = nil;
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
#pragma mark Button Actions

-(IBAction)notificationsBtnPressed:(id)sender {
	NotificationsViewController *controller = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
	
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction) addEvent:(id)sender {	
	CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil];
	[self.navigationController pushViewController:createEventViewController animated:YES];
}

-(void)deleteNewsReel:(NSMutableDictionary *)dict {
	
	// delete news reel
	newsReelOperation = [ApplicationDelegate.userEngine deleteNewsReelOfUser:[[SingletonUser sharedUserInstance] user] event:[dict valueForKey:@"eventId"] onCompletion:^(NSString *response) {
		
		// reload news reel
		newsReelOperation = [ApplicationDelegate.userEngine requestObjectOfUser:user objectType:@"newsReel" onCompletion:^(NSArray *responseData) {
			newsreelItems = [NSMutableArray arrayWithArray:[User getNewsreel:responseData]];
			
			if (newsreelItems.count == 0) {
				UIView *footerTableView = [[UIView alloc] init];
				
				UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
				[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
				label.textAlignment = UITextAlignmentCenter;
				label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
				label.text = NSLocalizedString(@"No news yet!", nil);
				
				[footerTableView addSubview:label];
				
				tableView.tableFooterView = footerTableView;
			}
			else {
				[self.tableView reloadData];
			}
			
			[HUD hide:YES];
			
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [newsreelItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	NSMutableDictionary *dict = [newsreelItems objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] init];
	
	[imageView setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
			  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    [imageView setFrame:CGRectMake(8.0, 16.0, 31.0, 30.0)];
    imageView.layer.cornerRadius = 4;
    [imageView setClipsToBounds: YES];
    
    [cell.contentView addSubview:imageView];
    
    CGRect frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, 8.0f, cell.frame.size.width - imageView.frame.size.width - 35.0f, cell.frame.size.height + 15.0f);
    
    [cell.contentView addSubview:[self setObject:dict setType:[dict objectForKey:@"type"] intoFrame:frame]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
	
	NSMutableDictionary *dict = [newsreelItems objectAtIndex:indexPath.row];
	
	NSLog(@"%@", [dict valueForKey:@"attending"]);
	
	if ([dict objectForKey:@"attending"] != nil && [[dict objectForKey:@"attending"] intValue] == 1) {
		return YES;
	}
	
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
		
		[self performSelector:@selector(deleteNewsReel:) withObject:[newsreelItems objectAtIndex:indexPath.row] afterDelay:0.1];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger count = [newsreelItems count];
	
	if (row < count) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [newsreelItems objectAtIndex:indexPath.row];
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
			   [type isEqualToString:@"EventRequestMayBe"] ||
			   [type isEqualToString:@"EventMessage"] ||
			   [type isEqualToString:@"CommentEvent"] ||
			   [type isEqualToString:@"GoldEvent"] ||
			   [type isEqualToString:@"EventPicture"] ||
			   [type isEqualToString:@"friendTofriendOpenEventNotification"]) {
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

-(TTTAttributedLabel *) setObject:(NSMutableDictionary *) dict setType:(NSString *) type intoFrame:(CGRect)frame {
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
		
		text = [NSString stringWithFormat:@"%@ %@ may be attending %@ on %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"],[df stringFromDate:[dict valueForKey:@"startTime"]]];
	}
	
	else if([type isEqualToString:@"GoldEvent"]) {
	
		text = [NSString stringWithFormat:@"%@ %@ has goldstarred %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
	else if([type isEqualToString:@"EventMessage"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ has commented in %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
	else if([type isEqualToString:@"EventPicture"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ as changed the picture for the event %@", [dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
		
	}else if([type isEqualToString:@"friendTofriendOpenEventNotification"]) {
		
		text = [NSString stringWithFormat:@"%@ %@ is attending %@",[dict valueForKey:@"name"],[dict valueForKey:@"surname"], [dict valueForKey:@"title"]];
	}
	
	
		
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                       constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    
    float originY = frame.origin.y;
    
    if ([text length] <= 76)
        originY += 8.0f;
    
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

@end