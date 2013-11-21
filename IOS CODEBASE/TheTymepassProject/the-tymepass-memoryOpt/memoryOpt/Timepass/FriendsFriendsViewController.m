//
//  FriendsFriendsViewController.m
//  Timepass
//
//  Created by mac book pro on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendsFriendsViewController.h"
#import "FriendsFriendsProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@implementation FriendsFriendsViewController
@synthesize tableView, friendsArray;
@synthesize HUD, friendsOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *)aUser friends:(NSArray *)aFriends
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        user = aUser;
        friendsArray = [NSMutableArray arrayWithArray:aFriends];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"]; 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    //debugLog(@"%@", [self.friendsArray objectAtIndex:0]);
    
    User *dict = [self.friendsArray objectAtIndex:indexPath.row];
    
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
    lbl.text = [NSString stringWithFormat:@"%@ %@",[dict name], [dict surname]];
    
    [cell.contentView addSubview:lbl];
    
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *friend = [self.friendsArray objectAtIndex:indexPath.row];
    
    UIViewController *profileViewController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:friend];
    
    //open friend's profile page
    //friendsFriendsProfileViewController = [[FriendsFriendsProfileViewController alloc] initWithNibName:@"FriendsFriendsProfileViewController" bundle:nil user:friend];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)returnBtn:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
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
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, [ApplicationDelegate navigationController].view.frame.size.width, [ApplicationDelegate navigationController].view.frame.size.height);
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
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

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Friends", @"Friends");
}

-(void)viewWillDisappear:(BOOL)animated {
	self.title = nil;
	[HUD hide:YES];
}

-(void)viewDidAppear:(BOOL)animated {
	
	friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:user objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
		
		[tableView reloadData];
		[HUD hide:YES];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
}

@end
