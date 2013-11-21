//
//  EventAttendeesViewController.m
//  Timepass
//
//  Created by John P on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventAttendeesViewController.h"
#import "User+GAEUser.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@implementation EventAttendeesViewController
@synthesize tableView;
@synthesize peopleArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil attendees:(NSArray *) attendees{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		isAttending = YES;
        peopleArray = [[NSArray alloc] initWithArray:attendees];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil maybe:(NSArray *) maybe {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		isAttending = NO;
        peopleArray = [[NSArray alloc] initWithArray:maybe];
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
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (isAttending) {
		self.title = NSLocalizedString(@"People Attending", @"People Attending");
	} else {
		self.title = NSLocalizedString(@"People Maybe", @"People Maybe");
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.title = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//Send Requests button pressed
- (void) sendRequestsBtnPressed:(id) sender{
    NSMutableArray * emails = [[NSMutableArray alloc] init];
    //from the currently selected table get the email list
    for (NSMutableDictionary *item in peopleArray){
        if ([[item valueForKey:@"checked"] boolValue]){
            [item setObject:[item valueForKey:@"id"] forKey:@"key"];
            [emails addObject:item];
        }
    }
    //Send invitations to GAE
    [ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:emails OfType:@"TymepassUser" stealthMode:nil forEvent:nil];
    //TODO uncheck users that got invites (maybe remove them from the arrays??
    [emails removeAllObjects];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [peopleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"]; 
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSMutableDictionary *dict = [peopleArray objectAtIndex:indexPath.row]; 
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
	[imageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]
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
    lbl.text = [dict objectForKey:@"name"];
    
    [cell.contentView addSubview:lbl];
	
	UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"horizontal_line.png"]];
	[separator setFrame:CGRectMake(0.0, 42, 320, 2)];
	[cell addSubview:separator];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *invitee = [peopleArray objectAtIndex:indexPath.row];
    //TODO change controller to include context
    User *friend = [User getUserWithId:[invitee valueForKey:@"id"] inContext:[modelUtils defaultManagedObjectContext]];
    
    profileViewController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:friend];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    //BOOL result = [User unfriend:[friend serverId] with:[[[SingletonUser sharedUserInstance] user] serverId]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
