//
//  FriendsViewForCalendarController.m
//  Timepass
//
//  Created by jason on 16/10/12.
//
//

#import "FriendsViewForCalendarController.h"
#import "User+GAEUser.h"
#import "CalendarMonthViewController.h"
#import "CalendarViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation FriendsViewForCalendarController

@synthesize tableView, HUD, friendsArray, friendsOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
	
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"middle_shadow2.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"My Friends", @"My Friends");
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [HUD hide:YES];
	self.title = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.friendsOperation) {
        
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
    }
    
    if (HUD)
        [self setHUD:nil];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"friends" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
		
		if (friendsArray.count == 0) {
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"No friends yet!", nil);
			
			[footerTableView addSubview:label];
			
			tableView.tableFooterView = footerTableView;
		}
		else {
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
			sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
			NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			
			NSArray *sortedArray,*arrfrnds;
			arrfrnds=[NSArray arrayWithArray:friendsArray];
			sortedArray =[arrfrnds sortedArrayUsingDescriptors:sortDescriptors];
			NSLog(@"sorted array : %@",sortedArray);
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

#pragma mark -
#pragma mark button actions

-(IBAction)loadCalendar:(id)sender {
	User *friend = [self.friendsArray objectAtIndex:[sender tag]];
	
	CalendarMonthViewController *calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil friend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
	
	CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarMonthViewController showToolBar:YES aFriend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
	
	[calendarMonthViewController.tdCalendarView setViewController:calendarViewController];
	[calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
	
	[self.navigationController pushViewController:calendarViewController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
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
	
	UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_line.png"]];
	[lineView setFrame:CGRectMake(0.0, 48.0, 320.0, 2.0)];
    [cell.contentView addSubview:lineView];
	
	UIButton *viewCal = [ApplicationDelegate.uiSettings createButton:@"View Cal"];
	[viewCal setFrame:CGRectMake(0, 0, 86, 34)];
	viewCal.tag = indexPath.row;
	[viewCal addTarget:self action:@selector(loadCalendar:) forControlEvents:UIControlEventTouchUpInside];
    [viewCal setBackgroundImage:[UIImage imageNamed:@"view_cal.png"] forState:UIControlStateNormal];
	[viewCal setBackgroundImage:[UIImage imageNamed:@"view_cal_pressed.png"] forState:UIControlStateHighlighted];
	
	cell.accessoryView = viewCal;
	
    return cell;
}

-(void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self tableView:aTableView didDeselectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	User *friend = [self.friendsArray objectAtIndex:indexPath.row];
	
	CalendarMonthViewController *calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil friend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
	
	CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarMonthViewController showToolBar:YES aFriend:friend inContext:[[Utils sharedUtilsInstance] scratchPad]];
	
	[calendarMonthViewController.tdCalendarView setViewController:calendarViewController];
	[calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
	
	[self.navigationController pushViewController:calendarViewController animated:YES];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end
