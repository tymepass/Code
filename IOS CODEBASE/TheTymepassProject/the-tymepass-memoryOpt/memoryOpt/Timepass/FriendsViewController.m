//
//  FriendsViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "User+GAEUser.h"
#import "FriendsProfileViewController.h"
#import "SearchForFriendsViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FriendsViewController
@synthesize tableView, searchForFriendsBtn, friendsArray,friendsOperation,HUD;
@synthesize footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friendCal:(bool)isFriendCalender {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isFriendCal = isFriendCalender;
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
    cell.accessoryType = UITableViewCellAccessoryNone;
    //debugLog(@"%@", [self.friendsArray objectAtIndex:0]);
	
    User *dict = [self.friendsArray objectAtIndex:indexPath.row];
	UIImageView *imageView = [[UIImageView alloc] init];
	
	[imageView setImageWithURL:[NSURL URLWithString:[dict photo]]
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
    
	UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizontal_line.png"]];
	[separator setFrame:CGRectMake(0.0, 42, 320, 2)];
	[cell addSubview:separator];
	
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	User *friend = [self.friendsArray objectAtIndex:indexPath.row];
	
	if (isFriendCal) {
		CalendarMonthViewController *calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil friend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
		
		CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarMonthViewController showToolBar:YES aFriend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
		
		[calendarMonthViewController.tdCalendarView setViewController:calendarViewController];
		[calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
		
		[self.navigationController pushViewController:calendarViewController animated:YES];
	} else {
		
		//open profile page
		FriendsProfileViewController *friendsProfileViewController = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:friend];
		
		[self.navigationController pushViewController:friendsProfileViewController animated:YES];
		//BOOL result = [User unfriend:[friend serverId] with:[[[SingletonUser sharedUserInstance] user] serverId]];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
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

- (void)viewDidLoad {	
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    searchForFriendsBtn = [ApplicationDelegate.uiSettings createButton:@"Search for friends"];
    [searchForFriendsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [searchForFriendsBtn addTarget:self action:@selector(searchBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:searchForFriendsBtn];
    
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    if (tableView)
        [self setTableView:nil];
    
    if (searchForFriendsBtn)
        [self setSearchForFriendsBtn:nil];
    
    [self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title = NSLocalizedString(@"My Friends", @"My Friends");
}

- (void)viewDidAppear:(BOOL)animated {
	
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
		
		if (friendsArray.count == 0)
		{
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"No friends yet!", nil);
			
			[footerTableView addSubview:label];
			
			tableView.tableFooterView = footerTableView;
			[self.tableView reloadData];
		}
		else{
			
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
		}
		[HUD hide:YES];
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HUD hide:YES];
	self.title = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.friendsOperation) {
        
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
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

- (IBAction)searchBtnPressed:(id)sender{
    SearchForFriendsViewController *searchForFriendsViewController = [[SearchForFriendsViewController alloc] initWithNibName:@"SearchForFriendsViewController" bundle:nil settingsViewMode:YES];
    
    [self.navigationController pushViewController:searchForFriendsViewController animated:YES];
}

@end