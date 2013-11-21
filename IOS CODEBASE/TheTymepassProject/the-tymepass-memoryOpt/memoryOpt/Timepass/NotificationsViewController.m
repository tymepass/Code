//
//  NotificationsViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendsProfileViewController.h"
#import "SBJson.h"

@implementation NotificationsViewController
@synthesize tableView, notifications, pendingNotifications;
@synthesize notificationsOperation;

int selectedRow = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        user = [[SingletonUser sharedUserInstance] user];
        pendingNotifications = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //if (indexPath.row < [pendingEvents count] -1) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dict = [notifications objectAtIndex:indexPath.row];
    
    //debugLog(@"%@",[dict description]);
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    if ([dict valueForKey:@"photo"]) {
		[imageView setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"photo"]]
				  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
	}
    
    if ([[dict objectForKey:@"type"] isEqualToString:@"message"]) {
		[imageView setImageWithURL:[NSURL URLWithString:[[[SingletonUser sharedUserInstance] user] photo]]
				  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
	}
    
    [imageView setFrame:CGRectMake(8.0, 16.0, 31.0, 30.0)];
    imageView.layer.cornerRadius = 4;
    [imageView setClipsToBounds: YES];
    
    [cell.contentView addSubview:imageView];
    
    //CGRect frame = CGRectOffset(CGRectInset(CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width - imageView.frame.size.width - 20.0f, cell.frame.size.height), 25.0f, 5.0f), imageView.frame.origin.x + imageView.frame.size.width - 17.0f, 3.0f);
    
    CGRect frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, 8.0f, cell.frame.size.width - imageView.frame.size.width - 35.0f, cell.frame.size.height + 15.0f);
    
    [cell.contentView addSubview:[self setObject:[dict objectForKey:@"object"] setType:[dict objectForKey:@"type"] setMessagesCount:[dict objectForKey:@"messagesCount"] intoFrame:frame]];
    
    [dict setObject:cell forKey:@"cell"];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    
    NSMutableDictionary *dict = [notifications objectAtIndex:indexPath.row];
    //check invitation type
    if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"event"] ||
		[[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"message"]) {
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			eventViewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil event:[dict objectForKey:@"object"]];
			//debugLog(@"object: %@", [[dict objectForKey:@"object"] description]);
			
			[self.navigationController pushViewController:eventViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
        
    } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"user"]) {
        
        User *friend = [dict objectForKey:@"object"];
        
        UIAlertView *reviewAlert = [[UIAlertView alloc] initWithTitle:@"Friend Request!" message:[NSString stringWithFormat:@"Do you wanna be Tymepass friends with %@ %@?",[friend name], [friend surname]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        [reviewAlert show];
        
        // profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:[dict objectForKey:@"object"] invitationId:[dict objectForKey:@"invitationId"]];
        // [self.navigationController pushViewController:profileViewController animated:YES];
    } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"UserRequestAccepted"]){
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
        User *friend = [dict objectForKey:@"object"];
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			FriendsProfileViewController *friendsProfileViewController = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:friend];
			
			[self.navigationController pushViewController:friendsProfileViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
		
    } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"EventRequestAccepted"]){
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user]
													   forEvent:[dict objectForKey:@"object"]];
			
			[self.navigationController pushViewController:eventViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
    }
	else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"EventRequestAcceptedGold"]){
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user]
													   forEvent:[dict objectForKey:@"object"]];
			
			[self.navigationController pushViewController:eventViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
    }
	else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"EventRequestMayBe"]){
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user]
													   forEvent:[dict objectForKey:@"object"]];
			
			[self.navigationController pushViewController:eventViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
    } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] isEqualToString:@"EditEvent"]){
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
        
		NSString *invitationId = [dict objectForKey:@"invitationId"];
		
		notificationsOperation = [ApplicationDelegate.invitationEngine readInvitationsOfUser:user invitationId:invitationId onCompletion:^(NSArray *responseData) {
			
			eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user]
													   forEvent:[dict objectForKey:@"object"]];
			
			[self.navigationController pushViewController:eventViewController animated:YES];
			
			[HUD hide:YES];
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
    }
	
	//else debugLog(@"Unknown invitation type");
    //send confirmation request to GAE
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSUInteger count = [notifications count];
	
	if (row < count) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUInteger row = [indexPath row];
	NSUInteger count = [notifications count];
    
	if (row < count)
		[notifications removeObjectAtIndex:row];
    
    [tableView reloadData];
}*/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
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

    notifications = [[NSMutableArray alloc] init];
    
    [self.tableView clearsContextBeforeDrawing];
    [self.tableView reloadData];
    
    [editBtn setEnabled:FALSE];
	
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
	
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    //self.tableView.backgroundColor = [UIColor clearColor];
    [tableView setEditing:NO animated:YES];
    
    editBtn = [[UIBarButtonItem alloc]
               initWithTitle:@"Edit"
               style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(editClicked:)];
	
	doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done"
											   style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(doneClicked:)];
    
    //self.navigationItem.rightBarButtonItem = editBtn;
	
	notificationsOperation = [ApplicationDelegate.invitationEngine requestInvitationsOfUser:user onCompletion:^(NSArray *responseData) {
		BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
		if (!isIOS5){
			// Create new SBJSON parser object
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			responseData = [parser objectWithString:(NSString *) responseData];
		}
		NSArray *result  = [NSMutableArray arrayWithArray:[Invitation getInvitations:responseData]];
		
		pendingNotifications = [[NSMutableArray alloc] init];
		
		for (NSDictionary *notification in result)
			[pendingNotifications addObject:notification];
		
		notifications = pendingNotifications;
		
		if (notifications.count == 0)
		{
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"No notifications yet!", nil);
			
			[footerTableView addSubview:label];
			
			tableView.tableFooterView = footerTableView;
			
		}
		else {
			[self.tableView reloadData];
			[editBtn setEnabled:YES];
		}
		
		[HUD hide:YES];
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HUD hide:YES];
    [super viewWillDisappear:animated];
	self.title = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Notifications", @"Notifications");
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.notificationsOperation) {
        
        [self.notificationsOperation cancel];
        self.notificationsOperation = nil;
    }
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) editClicked:(id)sender {
	[tableView setEditing:YES animated:YES];
	self.navigationItem.rightBarButtonItem = doneBtn;
}

-(IBAction) doneClicked:(id)sender {
	[tableView setEditing:NO animated:YES];
	self.navigationItem.rightBarButtonItem  = editBtn;
}

-(TTTAttributedLabel *) setObject:(id)obj setType:(NSString *) type setMessagesCount:(NSString *) messagesCount intoFrame:(CGRect)frame {
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
	
    if ([type isEqualToString:@"event"]) {
        Location *eventLocation = [(Event *)obj locationId];
		
		if ([[(Event *)obj isOpen] intValue] == 1) {
			
			if (eventLocation && [[eventLocation name] length] > 0)
				text = [NSString stringWithFormat:@"%@ %@ has created an open event %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
			else
				text = [NSString stringWithFormat:@"%@ %@ has created an open event %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
			
		} else {
			if (eventLocation && [[eventLocation name] length] > 0)
				text = [NSString stringWithFormat:@"%@ %@ would like to Tymepass you to %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
			else
				text = [NSString stringWithFormat:@"%@ %@ would like to Tymepass you to %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
		}
    }
	
	else if ([type isEqualToString:@"EditEvent"]) {
        Location *eventLocation = [(Event *)obj locationId];
		
		if (eventLocation && [[eventLocation name] length] > 0)
			text = [NSString stringWithFormat:@"%@ %@ has changed an event %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
		else
			text = [NSString stringWithFormat:@"%@ %@ has changed an event %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
    }
	
	else if ([type isEqualToString:@"EventRequestAccepted"]) {
        Location *eventLocation = [(Event *)obj locationId];
		
		if (eventLocation && [[eventLocation name] length] > 0)
			text = [NSString stringWithFormat:@"%@ %@ has accepted event %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
		else
			text = [NSString stringWithFormat:@"%@ %@ has accepted event %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
    }
	
	else if ([type isEqualToString:@"EventRequestAcceptedGold"]) {
        Location *eventLocation = [(Event *)obj locationId];
		
		if (eventLocation && [[eventLocation name] length] > 0)
			text = [NSString stringWithFormat:@"%@ %@ has accepted and goldstarred event %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
		else
			text = [NSString stringWithFormat:@"%@ %@ has accepted and goldstarred event %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
    }
	
	else if ([type isEqualToString:@"EventRequestMayBe"]) {
        Location *eventLocation = [(Event *)obj locationId];
		
		if (eventLocation && [[eventLocation name] length] > 0)
			text = [NSString stringWithFormat:@"%@ %@ might be attending the event %@ on %@ in %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]],[[(Event *)obj locationId] name]];
		else
			text = [NSString stringWithFormat:@"%@ %@ might be attending the event %@ on %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname],[(Event *)obj title], [df stringFromDate:[(Event *)obj startTime]]];
    }
	
	else if ([type isEqualToString:@"user"]) {
        text = [NSString stringWithFormat:@"Friend Request! Do you wanna be Tymepass friends with %@ %@?",[(User *)obj name],[(User *)obj surname]];
    }
	else if ([type isEqualToString:@"UserRequestAccepted"]) {
		text = [NSString stringWithFormat:@"You are now Tymepass friends with %@ %@.",[(User *)obj name],[(User *)obj surname]];
	}
	else {
        
        NSString *msgLabel = @"messages";
        
        if (messagesCount) {
            if  ([messagesCount isEqualToString:@"1"])
                msgLabel = @"message";
            
            messagesCount = [NSString stringWithFormat:@"(%@)",messagesCount];
        }
        else
            messagesCount = @"(0)";
		
        text = [NSString stringWithFormat:@"You have %@ unread %@ for the event %@", messagesCount, msgLabel, [(Event *)obj title]];
    }
	
    NSLog(@"notification text  : %@ ",text);
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                       constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    
    float originY = frame.origin.y;
    
    if ([text length] <= 70)
        originY += 8.0f;
    
    [label setFrame:CGRectMake(frame.origin.x, originY, label.frame.size.width - 30.0f, label.frame.size.height)];
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:text];
    
    __block NSMutableAttributedString *maString;
	
    [label setText:string afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        if ([type isEqualToString:@"event"] ||
			[type isEqualToString:@"EventRequestAccepted"] ||
			[type isEqualToString:@"EventRequestMayBe"]) {
            NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[[(Event *)obj invitedBy] name],[[(Event *)obj invitedBy] surname]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[(Event *)obj title]] options:NSCaseInsensitiveSearch];
			
            NSRange boldRange3 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[df stringFromDate:[(Event *)obj startTime]]] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange4;
            Location *eventLocation = [(Event *)obj locationId];
            if (eventLocation && [[eventLocation name] length] > 0)
                boldRange4 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[[(Event *)obj locationId] name]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange3];
                
                if (eventLocation && [[eventLocation name] length] > 0)
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange4];
				
                CFRelease(font);
            }
        } else if ([type isEqualToString:@"user"] || [type isEqualToString:@"UserRequestAccepted"]) {
            NSRange boldRange = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[(User *)obj name],[(User *)obj surname]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                
                CFRelease(font);
            }
        } else {
            NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",messagesCount] options:NSCaseInsensitiveSearch];
            
            NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[(Event *)obj title]] options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
				
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

- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSMutableDictionary *dict = [notifications objectAtIndex:selectedRow];
        
        BOOL result = [Invitation setInvitation:[dict objectForKey:@"invitationId"] toStatus: [NSString stringWithFormat:@"%d", 1]];
        User *friend = [dict objectForKey:@"object"];
		
        //Update gaeFriends singleton array
        if (result) {
            if (![Utils isFriendOfByKey:[friend serverId]]) {
                NSMutableArray *theKey = [NSMutableArray arrayWithObject:@"key"];
                NSMutableArray *theObject = [NSMutableArray arrayWithObject:[friend serverId]];
                NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObject forKeys:theKey];
                
                [[[SingletonUser sharedUserInstance] gaeFriends] addObject:theDict];
            }
        }
        
        //open profile page
        FriendsProfileViewController *friendsProfileViewController = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:friend];
        
        [self.navigationController pushViewController:friendsProfileViewController animated:YES];
        
        [notifications removeObjectAtIndex:selectedRow];
        [tableView reloadData];
        
		// myProfileViewController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
        //[self.navigationController pushViewController:myProfileViewController animated:YES];
    }
}

@end
