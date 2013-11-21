//
//  MessageFriendListController.m
//  Timepass
//
//  Created by jasoh on 15/10/12.
//
//

#import "MessageFriendListController.h"
#import "User+GAEUser.h"
#import "UserMessage.h"
#import "UserMessage+GAE.h"
#import "UserMessage+Management.h"
#import <QuartzCore/QuartzCore.h>

@implementation MessageFriendListController

@synthesize tableView;
@synthesize friendsArray;
@synthesize friendsOperation;
@synthesize HUD;

@synthesize messageWallTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"middle_shadow2.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Messages", @"Messages");
	[super viewWillAppear:animated];
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [HUD hide:YES];
    [super viewWillDisappear:animated];
	self.title = Nil;
	
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
	
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"friendsForMessage" onCompletion:^(NSArray *responseData) {
		friendsArray = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
		
		if (friendsArray.count == 0) {
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"You have no messages", nil);
			
			[footerTableView addSubview:label];
			
			tableView.tableFooterView = footerTableView;
			[self.tableView reloadData];
			[HUD hide:YES];
		}
		else {

			for (User *friendObj in friendsArray) {
				friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:friendObj objectType:@"messages" onCompletion:^(NSArray *responseData) {
					
					[UserMessage getMessages:responseData forUser:friendObj];
					
					User *lastFriend = [friendsArray lastObject];
					
					if ([lastFriend isEqual:friendObj]) {
						[self.tableView reloadData];
						[HUD hide:YES];
					}
					
				} onError:^(NSError* error) {
					
				}];
			}			
		}
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
    
    [super viewDidAppear:animated];
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
	
	[imageView setImageWithURL:[NSURL URLWithString:[dict photo]]
			  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    [imageView setFrame:CGRectMake(8.0, 6.0, 31.0, 30.0)];
    imageView.layer.cornerRadius = 4;
    [imageView setClipsToBounds: YES];
    
    [cell.contentView addSubview:imageView];
    
    CGRect frame = CGRectMake(47.0, 3.0, 219.0, 25.0);
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    
    lbl.backgroundColor = [UIColor clearColor];
    lbl.opaque = NO;
    lbl.clearsContextBeforeDrawing = YES;
    lbl.textColor = [UIColor blackColor];
    lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:16.0];
    lbl.text = [NSString stringWithFormat:@"%@ %@",[dict name], [dict surname]];
    
    [cell.contentView addSubview:lbl];
	
	frame = CGRectMake(47.0, 25.0, 219.0, 22.0);
    UILabel *lbld = [[UILabel alloc] initWithFrame:frame];
    
    lbld.backgroundColor = [UIColor clearColor];
    lbld.opaque = NO;
    lbld.clearsContextBeforeDrawing = YES;
    lbld.textColor = [UIColor grayColor];
    lbld.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
	
	NSArray *messages = [UserMessage getMessages:dict];
	if ([messages count] > 0) {
		UserMessage *message = [messages lastObject];
		NSString *decodedString = (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapes(NULL,  (__bridge CFStringRef)message.text, CFSTR(""));
		lbld.text = decodedString;
	}
	
    //lbld.text = @"Not Implement Yet";
    
    [cell.contentView addSubview:lbld];
	
	UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_line.png"]];
	[lineView setFrame:CGRectMake(0.0, 48.0, 320.0, 2.0)];
    [cell.contentView addSubview:lineView];
	
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	User *friend = [self.friendsArray objectAtIndex:indexPath.row];
	messageWallTableViewController = [[MessageWallTableViewController alloc] initWithMessages:Nil forUser:friend];
    [self.navigationController pushViewController:messageWallTableViewController animated:YES];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

@end
