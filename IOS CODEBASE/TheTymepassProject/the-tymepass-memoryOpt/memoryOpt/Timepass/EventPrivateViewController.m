//
//  EventPrivateViewController.m
//  Timepass
//
//  Created by mac book pro on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventPrivateViewController.h"
#import "Event+GAE.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventPrivateViewController
@synthesize tableView;
@synthesize makePrivateBtn;
@synthesize currentEvent, eventPrivacyDelegate;
@synthesize toStealthFromArray;
@synthesize friendsOperation;
@synthesize stealthFromOperation;

-(void)initView {
    friendsArray = [[NSMutableArray alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *) event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentEvent = event;
        [self initView];
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
    
    self.title = NSLocalizedString(@"Event Privacy", @"Event Privacy");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Done" 
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(makePrivateBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    makePrivateBtn = [ApplicationDelegate.uiSettings createButton:@"Done"];
    [makePrivateBtn setFrame:CGRectMake(self.view.frame.size.width - 111.0, self.view.frame.size.height - 95.0, 101, 44.0)];
    [makePrivateBtn addTarget:self action:@selector(makePrivateBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:makePrivateBtn];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    [headerLabel setFrame:CGRectMake(8.0, 10.0, 320.0, 20.0)];
    
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    [headerDetailLabel setFrame:CGRectMake(8.0, 25.0, 320.0, 20.0)];
    
    headerLabel.text =  @"WANNA BE MORE SPECIFIC?";
    headerDetailLabel.text = @"(Choose one by one who this event will be invisible to)";
    
    [self.view addSubview:headerLabel];
    [self.view addSubview:headerDetailLabel];
    
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setMakePrivateBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    friendsOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"friends"
          onCompletion:^(NSArray *responseData) {
              
              NSMutableArray *fetchedFriends = [NSMutableArray arrayWithArray:[User getFriends:responseData]];
              
              for (User *user in fetchedFriends) {
                  if ([user serverId]) {
                      NSString *fullname = [NSString stringWithFormat:@"%@ %@",[user name] ? [user name] : @"", [user surname] ? [user surname] : @""];
                      
                      UIImage *profileImage = [UIImage imageNamed:@"default_profilepic.png"];
                      if ([user valueForKey:@"photo"])
                          profileImage = [UIImage imageWithData:[user valueForKey:@"photo"]];
                      
                      NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name",@"key",@"photo",@"checked",@"isStealthFrom", nil];
                      NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname,[user serverId],profileImage, @"NO", @"NO", nil];
                                        
                      NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                      
                      [friendsArray addObject:theDict];
                  }
              }
              
              if (currentEvent) {
                  stealthFromOperation = [ApplicationDelegate.eventEngine requestStealthFromForEvent:currentEvent
                    onCompletion:^(NSArray *responseData) {
                        isStealthFromArray = [NSMutableArray arrayWithArray:[Event getStealthFrom:responseData]];
                        
                        [self.tableView reloadData];
                        [HUD hide:YES];
                    } 
                     onError:^(NSError* error) {
                         [HUD hide:YES];
                     }];
              }
              else {
                  [self.tableView reloadData];
                  [HUD hide:YES];
              }
          } 
          onError:^(NSError* error) {
               [HUD hide:YES];
          }];

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HUD hide:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.friendsOperation) {
        
        [self.friendsOperation cancel];
        self.friendsOperation = nil;
    }
    
    if (self.stealthFromOperation) {
        
        [self.stealthFromOperation cancel];
        self.stealthFromOperation = nil;
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

- (void)makePrivateBtnPressed:(id) sender { 
    //we are editing an existing event
    NSMutableArray * ids = [[NSMutableArray alloc] init];
    
    //from the currently selected table get the email list
    for (NSMutableDictionary *user in friendsArray){
        //if ([[user valueForKey:@"isStealthFrom"] isEqualToString:@"YES"]) 
        //    continue;
        
        if ([[user valueForKey:@"checked"] isEqualToString:@"NO"]) 
            continue;
        
        [ids addObject:[user valueForKey:@"key"]];
    }
    
    if (currentEvent) {
        if (ids && [ids count] > 0)
            [ApplicationDelegate.eventEngine setEvent:currentEvent PrivateFrom:ids];
    }
    else
        [[self eventPrivacyDelegate] setPrivacy:ids];
    
    //TODO uncheck users that got invites (maybe remove them from the arrays??
    [ids removeAllObjects];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friendsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"]; 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSMutableDictionary *dict = [friendsArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    if ([dict objectForKey:@"photo"])
        imageView.image = (UIImage *)[dict objectForKey:@"photo"]; 
    
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
    lbl.text = [dict objectForKey:@"name"];
    
    
    for (NSObject *stealthFrom in toStealthFromArray) {
        if ([[NSString stringWithFormat:@"%@",stealthFrom] isEqualToString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"NO" forKey:@"isStealthFrom"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:YES];
            [cell setSelected:NO];
        } 
    }
    
    BOOL exists = FALSE;
    for (NSObject *stealthFrom in isStealthFromArray) {
        if ([[NSString stringWithFormat:@"%@",stealthFrom] isEqualToString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]]]) {
            exists = TRUE;
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isStealthFrom"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelected:YES];
            
            UIImageView *selectedBackground = [[UIImageView alloc] initWithFrame:cell.frame];
            selectedBackground.backgroundColor = [UIColor lightGrayColor];
            
            [cell setSelectedBackgroundView:selectedBackground];
        } 
    }

    [cell.contentView addSubview:lbl];
    
    if (!exists)
        [dict setObject:cell forKey:@"cell"];
    
    BOOL checked = [[dict objectForKey:@"checked"] boolValue];
    UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;	// match the button's size with the image size
	
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    
    if (exists)
        [button setEnabled:FALSE];
    
	cell.accessoryView = button;
    
    if (currentEvent) {
        if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]] isEqualToString:[NSString stringWithFormat:@"%@",[[currentEvent invitedBy] serverId]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelectedBackgroundView:nil];
            
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            cell.detailTextLabel.textColor  = [UIColor darkGrayColor];
            cell.detailTextLabel.text = @"Invited You";             
        } else if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"key"]] isEqualToString:[NSString stringWithFormat:@"%@",[[currentEvent creatorId] serverId]]]) {
            [dict setObject:@"YES" forKey:@"checked"];
            [dict setObject:@"YES" forKey:@"isInvited"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setEditing:FALSE];
            [cell setSelectedBackgroundView:nil];
            
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            cell.detailTextLabel.textColor  = [UIColor darkGrayColor];
            cell.detailTextLabel.text = @"Creator";   
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
    NSMutableDictionary *dict = [friendsArray objectAtIndex:indexPath.row];
    
    BOOL checked = [[dict objectForKey:@"checked"] boolValue];
    
    [dict setObject:!checked?@"YES":@"NO" forKey:@"checked"];
    
    UITableViewCell *cell = [dict objectForKey:@"cell"];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
	if (indexPath != nil)
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

@end