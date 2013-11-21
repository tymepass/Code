//
//  FriendsFriendsProfileViewController.m
//  Timepass
//
//  Created by mac book pro on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsFriendsProfileViewController.h"
#import "Location.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendsFriendsViewController.h"
#import "GoldEventsViewController.h"
#import "InvitationEngine.h"
#import "Utils.h"
#import "EventViewController.h"
#import "Event+GAE.h"
#import "NSDataAdditions.h"
#import "CalendarViewController.h"
#import "Utils.h"

@implementation FriendsFriendsProfileViewController
@synthesize profileImageView,profileNameLabel,locationLabel,tableView,sendFriendRequestBtn;
@synthesize friendsOperation, goldStarredOperation;
@synthesize lblFriends;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *) user
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        aFriend = user;
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
	
    sendFriendRequestBtn = [ApplicationDelegate.uiSettings createButton:@"Send Friend Request"];
    [sendFriendRequestBtn setFrame:CGRectMake(self.view.frame.size.width - 200.0, 25.0, 190.0, 44.0)];
    sendFriendRequestBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:[ApplicationDelegate.uiSettings buttonFontSize]];
    [sendFriendRequestBtn addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    if (aFriend.homeLocationId && [[aFriend.homeLocationId name] length] > 0)
        locationLabel.text = aFriend.homeLocationId.name;
    else
        locationLabel.text = @"-";
	
	[self loadImages];
}

- (void)viewDidUnload
{
    [self setProfileNameLabel:nil];
    [self setLocationLabel:nil];
    [self setTableView:nil];
    [self setProfileImageView:nil];
    [self setSendFriendRequestBtn:nil];
	[self setLblFriends:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
		
		lblFriends.text =  [NSString stringWithFormat:@"FRIENDS (%d)", [friendsArray count]];
		
	} onError:^(NSError* error) {
	}];
    
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Profile", @"Profile");
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.title = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.friendsOperation) {
        
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
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
- (IBAction)sendFriendRequest:(id)sender {
    //Send invitations to GAE
    [ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:aFriend.serverId forKey:@"key"]] OfType:@"TymepassUser" stealthMode:nil forEvent:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnGoldStarredPressed:(id)sender {
	GoldEventsViewController *goldEventsViewController = [[GoldEventsViewController alloc] initWithNibName:@"GoldEventsViewController" bundle:nil forFriend:aFriend];
	
	[self.navigationController pushViewController:goldEventsViewController animated:YES];
}

- (IBAction)btnFriendsPressed:(id)sender {
	
	FriendsFriendsViewController *friendsFriendsViewController = [[FriendsFriendsViewController alloc] initWithNibName:@"FriendsFriendsViewController" bundle:nil user:aFriend friends:friendsArray];
    
    [self.navigationController pushViewController:friendsFriendsViewController animated:YES];
}

-(IBAction)btnEvenViewPressed:(id)sender {
	
	Event *invitationEvent = [[Event getGAEEventWithIds:[NSArray arrayWithObject:[NSString stringWithFormat:@"%d", [sender tag]]] inContext:[[Utils sharedUtilsInstance] scratchPad]] objectAtIndex:0];
	
	UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:invitationEvent];
	[self.navigationController pushViewController:eventViewController animated:YES];
}

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
			
			UIImage* thumbImage;
			if ([[data objectForKey:@"photo"] isEqualToString:@""] == FALSE) {
				thumbImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[NSString stringWithFormat:@"%@",[data objectForKey:@"photo"]]]];
				thumbImage = [Utils resizedFromImage:thumbImage inPixes:88];
				
			} else {
				thumbImage = [UIImage imageNamed:@"camera_img.png"];
				thumbImage = [Utils resizedFromImage:thumbImage inPixes:88];
			}
			
			UIButton *btnImage;
			if (total == 0) {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth, OriginY, imgViewWidth, imgViewHeight)];
			} else {
				btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth + j, OriginY, imgViewWidth, imgViewHeight)];
			}
			btnImage.tag = [[dict valueForKey:@"id"] intValue];
			
			[btnImage setImage:thumbImage forState:UIControlStateNormal];
			[btnImage addTarget:self action:@selector(btnEvenViewPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btnImage];
			
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
			[self.view addSubview:btnImage];
			
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

@end
