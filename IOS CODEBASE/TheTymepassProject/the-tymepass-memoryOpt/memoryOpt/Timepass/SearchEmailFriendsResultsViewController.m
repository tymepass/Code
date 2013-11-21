//
//  SearchEmailFriendsResultsViewController.m
//  Timepass
//
//  Created by Mahmood1 on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchEmailFriendsResultsViewController.h"
#import "Invitation+GAE.h"
#import "Utils.h"
#import "TileScreenController.h"
#import "GlobalData.h"

@implementation SearchEmailFriendsResultsViewController
@synthesize tableView;
@synthesize segmentControl;
@synthesize sendRequestsBtn;
@synthesize friendsUsingTymepassArray;
@synthesize friendsNotUsingTymepassArray;

@synthesize footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentFriendsArray = friendsUsingTymepassArray;
        //debugLog(@"%@", [friendsUsingTymepassArray JSONRepresentation]);
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friendsUsingArray:(NSMutableArray *)friendsUsingArray friendsNotUsingArray:(NSMutableArray* ) friendsNotUsingArray
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        friendsUsingTymepassArray = friendsUsingArray;
        friendsNotUsingTymepassArray = friendsNotUsingArray;
        currentFriendsArray = friendsUsingTymepassArray;
        //debugLog(@"%@", [friendsUsingTymepassArray JSONRepresentation]);
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
	
    self.title = NSLocalizedString(@"Email Results", @"Email Results");
    
    //self.navigationController.navigationBar.backItem.title = NSLocalizedString(@"Back", @"Back");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    sendRequestsBtn = [ApplicationDelegate.uiSettings createButton:@"Send Friend Requests"];
    [sendRequestsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
	
    [sendRequestsBtn addTarget:self action:@selector(sendRequestsBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:sendRequestsBtn];
    
    [segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSegmentControl:nil];
    [self setSendRequestsBtn:nil];
    [self setFriendsUsingTymepassArray:nil];
    [self setFriendsNotUsingTymepassArray:nil];
	[self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setFriendsUsingTymepassArray:nil];
    [self setFriendsNotUsingTymepassArray:nil];
    
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void)sendRequestsBtnPressed:(id) sender {
    NSMutableArray * selectedfriendsArray = [[NSMutableArray alloc] init];
    
    for (NSArray *object in currentFriendsArray) {
        if ([[object valueForKey:@"isFriend"] isEqualToString:@"YES"])
            continue;
        
        if ([[object valueForKey:@"checked"] isEqualToString:@"NO"])
            continue;
        
        [selectedfriendsArray addObject:object];
    }
	
    if ([selectedfriendsArray count] > 0) {
        //see which tab is selected
        switch (segmentControl.selectedSegmentIndex) {
            case 0: {
                //Send invitations to GAE
                [ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:selectedfriendsArray OfType:@"TymepassUser" stealthMode:nil forEvent:nil];
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
																message: nil
															   delegate: self
													  cancelButtonTitle: @"OK"
													  otherButtonTitles: nil,nil];
				[alert show];
				
                break;
			}
            case 1: {
                //Send invitations to GAE
				
				Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
				if (mailClass != nil) {
					// We must always check whether the current device is configured for sending emails
					if ([mailClass canSendMail]) {
						[self performSelector:@selector(sendMail:) withObject:selectedfriendsArray afterDelay:0.1];
					}
					else {
						[self performSelector:@selector(sendMailManual:) withObject:selectedfriendsArray afterDelay:0.1];
					}
				}
				else {
					[self performSelector:@selector(sendMailManual:) withObject:selectedfriendsArray afterDelay:0.1];
				}
				
                break;
			}
            default:
                break;
        }

    }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentFriendsArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dict = [currentFriendsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict valueForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.detailTextLabel.text = [dict valueForKey:@"email"];
    cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:15.0];
    cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed]
															green:[ApplicationDelegate.uiSettings cellColorGreen]
															 blue:[ApplicationDelegate.uiSettings cellColorBlue]
															alpha:1.0];
	
    if ([Utils isFriendOfByKey:[dict valueForKey:@"key"]] ||
		[[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:[dict valueForKey:@"key"]]) {
        [dict setObject:@"NO" forKey:@"checked"];
        [dict setObject:@"YES" forKey:@"isFriend"];
		
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setEditing:FALSE];
        [cell setSelected:YES];
		
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50.0, 16.0)];
        
        lbl.backgroundColor = [UIColor clearColor];
        lbl.opaque = NO;
        lbl.clearsContextBeforeDrawing = YES;
        lbl.textColor = [UIColor darkGrayColor];
        lbl.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
        lbl.textAlignment = UITextAlignmentCenter;
        
        if ([[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:[dict valueForKey:@"key"]])
            lbl.text = @"You";
        else
            lbl.text = @"Friend";
        
        cell.accessoryView = lbl;
		
        return cell;
    }
    
    [dict setObject:cell forKey:@"cell"];
	
    BOOL checked = [[dict objectForKey:@"checked"] boolValue];
    UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;	// match the button's size with the image size
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *dict = [currentFriendsArray objectAtIndex:indexPath.row];
	
	BOOL checked = [[dict objectForKey:@"checked"] boolValue];
	
	[dict setObject:!checked?@"YES":@"NO" forKey:@"checked"];
	
	UITableViewCell *cell = [dict objectForKey:@"cell"];
	UIButton *button = (UIButton *)cell.accessoryView;
	
	UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
}

- (void)checkButtonTapped:(id)sender event:(id)event {
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}

-(void)segmentControlChanged:(id) sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
            currentFriendsArray = friendsUsingTymepassArray;
            [tableView reloadData];
            
            [sendRequestsBtn setTitle:@"Send Friend Requests" forState:UIControlStateNormal];
            break;
        case 1:
            currentFriendsArray = friendsNotUsingTymepassArray;
            [tableView reloadData];
            
            [sendRequestsBtn setTitle:@"Send Invitations" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - mail compose delegate

-(void) sendMail:(NSArray *)friendsNotUsingTymepassArrayWithEmail {
	if ([friendsNotUsingTymepassArrayWithEmail count] > 0) {
		MFMailComposeViewController *controllerMail = [[MFMailComposeViewController alloc] init];
		controllerMail.mailComposeDelegate = self;
		
        [controllerMail setSubject:@"Join me on Tymepass"];
		
        // Set up recipients
		NSMutableArray *emails = [[NSMutableArray alloc] init];
		for (NSDictionary *data in friendsNotUsingTymepassArrayWithEmail) {
			[emails addObject:[data valueForKey:@"email"]];
		}
		
        [controllerMail setToRecipients:emails];
		[controllerMail setMessageBody:shareMessageForAll isHTML:YES];
		[self presentModalViewController:controllerMail animated:YES];
	}
}

-(void)sendMailManual:(NSArray *)friendsNotUsingTymepassArrayWithEmail {
	if ([friendsNotUsingTymepassArrayWithEmail count] > 0) {
		
		NSMutableArray *emails = [[NSMutableArray alloc] init];
		for (NSDictionary *data in friendsNotUsingTymepassArrayWithEmail) {
			[emails addObject:[data valueForKey:@"email"]];
		}
		
		NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=Join me on Tymepass", [emails componentsJoinedByString:@","]];
		NSString *body = [NSString stringWithFormat:@"&body=%@",shareMessageForAll];
		
		NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
	}
	
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
	
	if (result == MFMailComposeResultSent){
		for (NSDictionary *item in currentFriendsArray){
            if ([[item objectForKey:@"checked"] boolValue]){
                [item setValue:@"NO" forKey:@"checked"];
            }
        }
        [tableView reloadData];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
														message: nil
													   delegate: self
											  cancelButtonTitle: @"OK"
											  otherButtonTitles: nil,nil];
		[alert show];
    }
}

@end
