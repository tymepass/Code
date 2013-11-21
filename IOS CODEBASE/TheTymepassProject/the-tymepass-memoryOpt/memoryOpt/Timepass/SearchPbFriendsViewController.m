//
//  SearchPbFriendsViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchPbFriendsViewController.h"

@implementation SearchPbFriendsViewController

@synthesize tableView;
@synthesize segmentControl;
@synthesize sendRequestsBtn;
@synthesize friendsUsingTymepassArray;
@synthesize friendsNotUsingTymepassArray;
@synthesize friendsNotUsingTymepassArrayWithEmail;

@synthesize footerView;
@synthesize HUD;
@synthesize userOperation;
@synthesize peopleMutable;

ABAddressBookRef aB;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.peopleMutable = [[NSMutableArray alloc] initWithArray:[Utils scanAddressBook]];
		friendsNotUsingTymepassArrayWithEmail = [[NSMutableArray alloc] init];
		flag = false;
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
	// Do any additional setup after loading the view, typically from a nib.
    // Custom initialization
	
    self.title = NSLocalizedString(@"Contacts", @"Contacts");
    
    //self.navigationController.navigationBar.backItem.title = NSLocalizedString(@"Back", @"Back");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    sendRequestsBtn = [ApplicationDelegate.uiSettings createButton:@"Send Friend Requests"];
    [sendRequestsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
	
    [sendRequestsBtn addTarget:self action:@selector(sendRequestsBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:sendRequestsBtn];
    
    [segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
	HUD.labelText = @"Checking...";
	HUD.dimBackground = YES;
	
	if ([self.peopleMutable count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"There is no email to check." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alert show];
		[HUD hide:YES];
        return;
    }
	
	if (!flag) {
		friendsUsingTymepassArray = [[NSMutableArray alloc] init];
		friendsNotUsingTymepassArray = [[NSMutableArray alloc] init];
		
		NSMutableArray *friendEmailsArray = [[NSMutableArray alloc] init];
		for (NSDictionary *data in self.peopleMutable) {
			if (![[data objectForKey:@"email"] isEqualToString:@""]) {
				[friendEmailsArray addObject:[[data objectForKey:@"email"] copy]];
			}
		}
		
		NSDictionary *emailDictionary = [[NSDictionary alloc] initWithObjects:friendEmailsArray forKeys:friendEmailsArray];
		
		userOperation = [ApplicationDelegate.userEngine checkEmails:emailDictionary onCompletion:^(NSArray *responseData) {
			NSArray *list = [responseData valueForKey:@"emails"];
			
			NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:friendEmailsArray];
			
			for (NSArray *user in list) {
				for (int i =0; i < [user count]; i++) {
					
					NSString *email = [NSString stringWithFormat:@"%@", [[user valueForKey:@"email"] objectAtIndex:i]];
					for (NSMutableDictionary *theDictArr in self.peopleMutable) {
						if ([[theDictArr valueForKey:@"email"] isEqualToString:email]) {
							[theDictArr setObject:[[user valueForKey:@"key"] objectAtIndex:i] forKey:@"key"];
							[friendsUsingTymepassArray addObject:theDictArr];
							break;
						}
					}
					
					[temp removeObjectAtIndex:[temp indexOfObject:[[user valueForKey:@"email"] objectAtIndex:i]]];
				}
			}
			
			currentFriendsArray = friendsUsingTymepassArray;
			
			for (NSString * email in temp) {
				for (NSMutableDictionary *theDictArr in self.peopleMutable) {
					
					if ([[theDictArr valueForKey:@"email"] isEqualToString:email]) {
						[theDictArr setObject:@"" forKey:@"key"];
						[friendsNotUsingTymepassArray addObject:theDictArr];
						break;
					}
				}
			}
			
			for (NSMutableDictionary *data in self.peopleMutable) {
				if ([[data objectForKey:@"email"] isEqualToString:@""]) {
					[data setObject:@"" forKey:@"key"];
					[friendsNotUsingTymepassArray addObject:data];
				}
			}
			
			NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"small_name" ascending:YES];
			[friendsNotUsingTymepassArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
			
			[tableView reloadData];
			[HUD hide:YES];
			
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
	}
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if(alertView.tag == 1000) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        else {
			
			if (segmentControl.selectedSegmentIndex == 0) {
				[friendsUsingTymepassArray removeAllObjects];
				currentFriendsArray = friendsUsingTymepassArray;
			} else {
				[friendsNotUsingTymepassArray removeAllObjects];
				currentFriendsArray = friendsNotUsingTymepassArray;
			}
			
			[tableView reloadData];
        }
		
        return;
    }
}

- (NSArray *) getSelectedItemsFromTable{
    //allocate the mutable array else no items will be added
	
	[friendsNotUsingTymepassArrayWithEmail removeAllObjects];
	
    NSMutableArray *selectedPeopleMutable = [[NSMutableArray alloc] initWithObjects:nil];
    for (NSDictionary *item in currentFriendsArray){
        if ([[item objectForKey:@"checked"] boolValue]){
            //debugLog(@"%@ value %@ object %@", [item description], [item valueForKey:@"phone"], [item objectForKey:@"phone"]);
			if ([[item valueForKey:@"phone"] isEqualToString:@""] == FALSE) {
				[selectedPeopleMutable addObject:[item valueForKey:@"phone"]];
			} else {
				[friendsNotUsingTymepassArrayWithEmail addObject:[item valueForKey:@"email"]];
			}
        }
    }
    return selectedPeopleMutable;
}


- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients {
	if ([recipients count] > 0) {
		MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
		if([MFMessageComposeViewController canSendText]) {
			flag = TRUE;
			controller.body = bodyOfMessage;
			controller.recipients = recipients;
			controller.messageComposeDelegate = self;
			[self presentModalViewController:controller animated:YES];
		}
		
	} else {
		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		if (mailClass != nil) {
			// We must always check whether the current device is configured for sending emails
			if ([mailClass canSendMail]) {
				[self performSelector:@selector(sendMail) withObject:nil afterDelay:0.1];
			}
			else {
				[self performSelector:@selector(sendMailManual) withObject:nil afterDelay:0.1];
			}
		} else {
			[self performSelector:@selector(sendMailManual) withObject:nil afterDelay:0.1];
		}
		
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
    
	/*if (result == MessageComposeResultSent){
		for (NSDictionary *item in self.peopleMutable){
            if ([[item objectForKey:@"checked"] boolValue] && [[item valueForKey:@"phone"] isEqualToString:@""] == FALSE){
                [item setValue:@"NO" forKey:@"checked"];
            }
        }
    }*/
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			[self performSelector:@selector(sendMail) withObject:nil afterDelay:0.1];
		}
		else {
			[self performSelector:@selector(sendMailManual) withObject:nil afterDelay:0.1];
		}
	}
	else {
		[self performSelector:@selector(sendMailManual) withObject:nil afterDelay:0.1];
	}
	
	[tableView reloadData];
}

-(void) sendMail {
	if ([friendsNotUsingTymepassArrayWithEmail count] > 0) {
		MFMailComposeViewController *controllerMail = [[MFMailComposeViewController alloc] init];
		controllerMail.mailComposeDelegate = self;
		
        [controllerMail setSubject:@"Join me on Tymepass"];
		
        // Set up recipients
        NSArray *toRecipients = friendsNotUsingTymepassArrayWithEmail;
		
        [controllerMail setToRecipients:toRecipients];
		[controllerMail setMessageBody:shareMessageForAll isHTML:YES];
		[self presentModalViewController:controllerMail animated:YES];
	}
}

-(void)sendMailManual {
	if ([friendsNotUsingTymepassArrayWithEmail count] > 0) {
		NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=Join me on Tymepass", [friendsNotUsingTymepassArrayWithEmail componentsJoinedByString:@","]];
		NSString *body = [NSString stringWithFormat:@"&body=%@",shareMessageForAll];
		
		NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
		email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
	}
	
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
	
	if (result == MFMailComposeResultSent){
		for (NSDictionary *item in self.peopleMutable){
            if ([[item objectForKey:@"checked"] boolValue]){
                [item setValue:@"NO" forKey:@"checked"];
            }
        }
        [tableView reloadData];
    }
	
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
                [self sendSMS:shareMessageForAll recipientList:[NSArray arrayWithArray:[self getSelectedItemsFromTable]]];
				break;
			}
            default:
                break;
        }
        
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentFriendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	dict = [currentFriendsArray objectAtIndex:indexPath.row];
    
	NSString *name = [dict objectForKey:@"name"];
	
	name = [name stringByReplacingOccurrencesOfString:@"Zzzzz No Name" withString:@""];
	
    cell.textLabel.text = name;
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor blackColor];
	
	if ([[dict valueForKey:@"phone"] isEqualToString:@""] == FALSE) {
		cell.detailTextLabel.text = [dict valueForKey:@"phone"];
	} else {
		cell.detailTextLabel.text = [dict valueForKey:@"email"];
	}
	
    cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:15.0];
    cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
	
	if ([Utils isFriendOfByKey:[dict valueForKey:@"key"]] || [[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:[dict valueForKey:@"key"]]) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
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

@end