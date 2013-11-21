//
//  SearchTWFriendsViewController.m
//  Timepass
//
//  Created by jason on 02/10/12.
//
//

#import "SearchTWFriendsViewController.h"
#import "Invitation+GAE.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "NSDataAdditions.h"
#import "TileScreenController.h"
#import "GlobalData.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@implementation SearchTWFriendsViewController

@synthesize tableView;
@synthesize sendRequestsBtn;
@synthesize peopleMutable, peopleArray, peopleNotUsingArray, peopleUsingArray;
@synthesize responseData;
@synthesize userOperation;

@synthesize footerView;
@synthesize HUD;
@synthesize segmentControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        peopleMutable = [[NSMutableArray alloc] init];
		peopleNotUsingArray = [[NSMutableArray alloc] init];
		peopleUsingArray = [[NSMutableArray alloc] init];
		peopleArray = [[NSMutableArray alloc] init];
		nextCursor = @"-1";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Twitter", @"Twitter");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    sendRequestsBtn = [ApplicationDelegate.uiSettings createButton:@"Send Requests"];
    [sendRequestsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [sendRequestsBtn addTarget:self action:@selector(sendRequestsBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:sendRequestsBtn];
    
	[segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
	
	[self performSelector:@selector(getTymepassTwitterFriends) withObject:nil afterDelay:0.01];
	//[self performSelector:@selector(sendRequestofTwitter) withObject:nil afterDelay:0.01];
	
	self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"shadow.png"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    if (tableView)
        [self setTableView:nil];
    
    if (sendRequestsBtn)
        [self setSendRequestsBtn:nil];
    
	[self setFooterView:nil];
    [super viewDidUnload];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [HUD hide:YES];
	self.title = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (HUD)
        [self setHUD:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Action Methods

//Send Requests button pressed
- (void) sendRequestsBtnPressed:(id) sender{
	
	if (segmentControl.selectedSegmentIndex == 0) {
		
		NSMutableArray * emails = [[NSMutableArray alloc] init];
		
		//from the currently selected table get the email list
		for (NSMutableDictionary *item in peopleMutable){
			
			if ([[item valueForKey:@"isFriend"] isEqualToString:@"YES"])
				continue;
			
			if ([[item valueForKey:@"checked"] isEqualToString:@"NO"])
				continue;
			
			[item setObject:[item valueForKey:@"id"] forKey:@"key"];
			[emails addObject:item];
		}
		
		//debugLog(@"Emails: %@", [emails JSONRepresentation]);
		//Send invitations to GAE
		
		if ([emails count] > 0) {
			[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:emails OfType:@"TwitterUser" stealthMode:nil forEvent:nil];
			
			//TODO uncheck users that got invites (maybe remove them from the arrays??
			[emails removeAllObjects];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
															message: nil
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil,nil];
			[alert show];
			
			[self.navigationController popViewControllerAnimated:YES];
			
		}
	} else {
		
		__block bool sent = false;
		NSMutableArray * twitterUsers = [[NSMutableArray alloc] init];
		
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		
		// Create an account type that ensures Twitter accounts are retrieved.
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		
		// Request access from the user to use their Twitter accounts.
		[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
			if(granted) {
				// Get the list of Twitter accounts.
				NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
				
				if ([accountsArray count] > 0) {
					// Grab the initial Twitter account to tweet from.
					ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
					
					int total = 0;
					for (NSMutableDictionary *item in peopleMutable) {
						
						if ([[item valueForKey:@"isFriend"] isEqualToString:@"YES"])
							continue;
						
						if ([[item valueForKey:@"checked"] isEqualToString:@"NO"])
							continue;
						
						total++;
						
						[item setObject:[item valueForKey:@"id"] forKey:@"key"];
						[twitterUsers addObject:[NSString stringWithFormat:@"@%@", [item valueForKey:@"screen_name"]]];
						
						if (total == 5) {
							NSString *update = [NSString stringWithFormat:@"%@ %@", [twitterUsers componentsJoinedByString:@" "], shareMessageForTwitter];
							
							TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
																		 parameters:[NSDictionary dictionaryWithObject:update forKey:@"status"]
																	  requestMethod:TWRequestMethodPOST];
							
							// Set the account used to post the tweet.
							[postRequest setAccount:twitterAccount];
							
							[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
								dispatch_async(dispatch_get_main_queue(), ^(void) {
									
								});
							}];
							
							total = 0;
							[twitterUsers removeAllObjects];
							sent = true;
						}
						
					}
					
					if ([twitterUsers count] > 0) {
						
						sent = true;
						NSString *update = [NSString stringWithFormat:@"%@ %@", [twitterUsers componentsJoinedByString:@" "], shareMessageForTwitter];
						
						TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
																	 parameters:[NSDictionary dictionaryWithObject:update forKey:@"status"]
																  requestMethod:TWRequestMethodPOST];
						
						// Set the account used to post the tweet.
						[postRequest setAccount:twitterAccount];
						
						[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
							dispatch_async(dispatch_get_main_queue(), ^(void) {
								if (sent) {
									UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
																					message: nil
																				   delegate: self
																		  cancelButtonTitle: @"OK"
																		  otherButtonTitles: nil,nil];
									[alert show];
									[self.navigationController popViewControllerAnimated:YES];
								}
							});
						}];
					}
					
				}
				else {
					[HUD hide:YES];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
				}
			} else {
				[HUD hide:YES];
			}
		}];
	}
    
}

- (void)getTymepassTwitterFriends {
	
	if ([TWTweetComposeViewController canSendTweet]) {
		
		ACAccountStore *accountStore = [[ACAccountStore alloc] init];
		
		// Create an account type that ensures Twitter accounts are retrieved.
		ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		
		// Request access from the user to use their Twitter accounts.
		[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
			if(granted) {
				// Get the list of Twitter accounts.
				NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
				
				if ([accountsArray count] > 0) {
					// Grab the initial Twitter account to tweet from.
					ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
					
					TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/followers/ids.json?cursor=-1&screen_name=%@", twitterAccount.username]]
																 parameters:nil
															  requestMethod:TWRequestMethodGET];
					
					[postRequest setAccount:twitterAccount];
					[postRequest performRequestWithHandler:^(NSData *responseData1,
															 NSHTTPURLResponse *urlResponse,
															 NSError *error) {
						if ([urlResponse statusCode] == 200) {
							
							TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/following/ids.json?cursor=-1&screen_name=%@", twitterAccount.username]]
																		 parameters:nil
																	  requestMethod:TWRequestMethodGET];
							
							[postRequest setAccount:twitterAccount];
							[postRequest performRequestWithHandler:^(NSData *responseData2,
																	 NSHTTPURLResponse *urlResponse,
																	 NSError *error) {
								if ([urlResponse statusCode] == 200) {
									
									dispatch_sync(dispatch_get_main_queue(), ^{
										
										// followers
										NSString *responseString = [[NSString alloc] initWithData:responseData1
																						 encoding:NSUTF8StringEncoding];
										NSMutableArray *results1 = [[responseString JSONValue] valueForKey:@"ids"];
										
										// friends
										NSString *responseString1 = [[NSString alloc] initWithData:responseData2
																						  encoding:NSUTF8StringEncoding];
										NSMutableArray *results2 = [[responseString1 JSONValue] valueForKey:@"ids"];
										
										// combine list
										NSMutableArray *results = [[results1 arrayByAddingObjectsFromArray:results2] mutableCopy];
										
										NSMutableArray *data = [[NSMutableArray alloc] init];
										
										for (NSNumber *twData in results) {
											[data addObject:[NSString stringWithFormat:@"%d", [twData intValue]]];
										}
										
										NSDictionary *twitterIdsDictionary = [[NSDictionary alloc] initWithObjects:data forKeys:data];
										
										userOperation = [ApplicationDelegate.userEngine checkTwitterIds:twitterIdsDictionary onCompletion:^(NSArray *response) {
											
											NSArray *list = [response valueForKey:@"emails"];
											
											for (NSArray *user in list) {
												for (int i =0; i < [user count]; i++) {
													NSString *fullname = [NSString stringWithFormat:@"%@ %@", [[user valueForKey:@"name"] objectAtIndex:i], [[user valueForKey:@"surname"] objectAtIndex:i]];
													
													NSString *email = [NSString stringWithFormat:@"%@", [[user valueForKey:@"email"] objectAtIndex:i]];
													NSString *key = [NSString stringWithFormat:@"%@", [[user valueForKey:@"key"] objectAtIndex:i]];
													NSString *twitterId = [NSString stringWithFormat:@"%@", [[user valueForKey:@"twitterId"] objectAtIndex:i]];
													
													NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name", @"small_name",@"email",@"key",@"checked",@"isFriend", @"id", @"photo" ,nil];
													NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname, [fullname lowercaseString],email,key,@"NO",@"NO", twitterId, [[user valueForKey:@"photo"] objectAtIndex:i], nil];
													
													NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
													[peopleUsingArray addObject:theDict];
												}
											}
											
											NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"small_name" ascending:YES];
											NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
											[peopleUsingArray sortUsingDescriptors:sortDescriptors];

											
											[self performSelector:@selector(sendRequestofTwitter) withObject:nil afterDelay:0.01];
											
										} onError:^(NSError* error) {
											[HUD hide:YES];
											[self.navigationController popViewControllerAnimated:YES];
										}];
									});
								}
							}];
						}
					}];
				}
				else {
					[HUD hide:YES];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
				}
			} else {
				[HUD hide:YES];
			}
		}];
	} else {
		
		NSString *message = @"The application cannot find friends at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alertView show];
		
		[HUD hide:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}

- (void) sendRequestofTwitter {
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			// Get the list of Twitter accounts.
			NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/followers/%@.json?cursor=%@", twitterAccount.username, nextCursor]]
															 parameters:nil
														  requestMethod:TWRequestMethodGET];
				
				[postRequest setAccount:twitterAccount];
				[postRequest performRequestWithHandler:^(NSData *responseData1,
														 NSHTTPURLResponse *urlResponse,
														 NSError *error) {
					if ([urlResponse statusCode] == 200) {
						
						TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/friends/%@.json?cursor=-1", twitterAccount.username]]
																	 parameters:nil
																  requestMethod:TWRequestMethodGET];
						
						[postRequest setAccount:twitterAccount];
						[postRequest performRequestWithHandler:^(NSData *responseData2,
																 NSHTTPURLResponse *urlResponse,
																 NSError *error) {
							if ([urlResponse statusCode] == 200) {
								
								dispatch_sync(dispatch_get_main_queue(), ^{
									
									// followers
									NSString *responseString = [[NSString alloc] initWithData:responseData1
																					 encoding:NSUTF8StringEncoding];
									NSMutableArray *results1 = [[responseString JSONValue] valueForKey:@"users"];
									nextCursor = [[responseString JSONValue] valueForKey:@"next_cursor_str"];
									
									// friends
									NSString *responseString1 = [[NSString alloc] initWithData:responseData2
																					  encoding:NSUTF8StringEncoding];
									NSMutableArray *results2 = [[responseString1 JSONValue] valueForKey:@"users"];
									
									// combine list
									NSMutableArray *results = [[results1 arrayByAddingObjectsFromArray:results2] mutableCopy];
									
									NSMutableArray *data = [[NSMutableArray alloc] init];
									
									for (NSDictionary *twData in results) {
										[data addObject:[NSString stringWithFormat:@"%@", [twData valueForKey:@"id"]]];
										
										NSString *imageURL = [[twData objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"" withString:@""];
										
										NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name", @"small_name", @"email",  @"key", @"checked" , @"isFriend", @"id", @"photo" ,@"screen_name", nil];
										NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:[twData valueForKey:@"name"], [[twData valueForKey:@"name"] lowercaseString], @"", @"", @"NO", @"NO", [NSString stringWithFormat:@"%@", [twData valueForKey:@"id"]], imageURL, [twData valueForKey:@"screen_name"], nil];
										
										NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
										
										if (![peopleNotUsingArray containsObject:theDict]) {
											[peopleNotUsingArray addObject:theDict];
										}
									}
									
									NSDictionary *twitterIdsDictionary = [[NSDictionary alloc] initWithObjects:data forKeys:data];
									
									userOperation = [ApplicationDelegate.userEngine checkTwitterIds:twitterIdsDictionary onCompletion:^(NSArray *response) {
										
										NSArray *list = [response valueForKey:@"emails"];
										
										for (NSArray *user in list) {
											for (int i =0; i < [user count]; i++) {
												
												NSString *twitterId = [NSString stringWithFormat:@"%@", [[user valueForKey:@"twitterId"] objectAtIndex:i]];
												
												for (NSMutableDictionary *data in peopleNotUsingArray) {
													if ([[data valueForKey:@"id"] isEqualToString:twitterId]) {
														[peopleNotUsingArray removeObject:data];
														break;
													}
												}
											}
										}
										
										NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"small_name" ascending:YES];
										NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
										[peopleNotUsingArray sortUsingDescriptors:sortDescriptors];
										
										[HUD hide:YES];
										[self segmentControlChanged:nil];
										
									} onError:^(NSError* error) {
										[HUD hide:YES];
										[self.navigationController popViewControllerAnimated:YES];
									}];
								});
							}
						}];
					}
				}];
			}
			else {
				[HUD hide:YES];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
			}
		} else {
			[HUD hide:YES];
		}
	}];
}

- (void) getNonTymepassFollowers {
	
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
	[accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
		if(granted) {
			// Get the list of Twitter accounts.
			NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitter.com/1/statuses/followers/%@.json?cursor=%@", twitterAccount.username, nextCursor]]
															 parameters:nil
														  requestMethod:TWRequestMethodGET];
				
				[postRequest setAccount:twitterAccount];
				[postRequest performRequestWithHandler:^(NSData *responseData1,
														 NSHTTPURLResponse *urlResponse,
														 NSError *error) {
					if ([urlResponse statusCode] == 200) {
						
						dispatch_sync(dispatch_get_main_queue(), ^{
							
							// followers
							NSString *responseString = [[NSString alloc] initWithData:responseData1
																			 encoding:NSUTF8StringEncoding];
							NSMutableArray *results = [[responseString JSONValue] valueForKey:@"users"];
							nextCursor = [[responseString JSONValue] valueForKey:@"next_cursor_str"];
							
							for (NSDictionary *twData in results) {
								
								bool found = false;
								
								for (NSMutableDictionary *data in peopleUsingArray) {
									if ([[data valueForKey:@"id"] isEqualToString:[twData valueForKey:@"id"]]) {
										found = true;
										break;
									}
								}
								
								if (!found) {
									NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name", @"small_name", @"email",  @"key", @"checked" , @"isFriend", @"id", @"photo" ,@"screen_name", nil];
									NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:[twData valueForKey:@"name"], [[twData valueForKey:@"name"] lowercaseString], @"", @"", @"NO", @"NO", [NSString stringWithFormat:@"%@", [twData valueForKey:@"id"]], @"", [twData valueForKey:@"screen_name"], nil];
									
									NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
									[peopleNotUsingArray addObject:theDict];
								}
							}
							
							NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"small_name" ascending:YES];
							NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
							[peopleUsingArray sortUsingDescriptors:sortDescriptors];
							[peopleNotUsingArray sortUsingDescriptors:sortDescriptors];
							
							[HUD hide:YES];
							[self segmentControlChanged:nil];
						});
					}
				}];
			}
			else {
				[HUD hide:YES];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
			}
		} else {
			[HUD hide:YES];
		}
	}];
}

-(void)segmentControlChanged:(id) sender {
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
            peopleMutable = peopleUsingArray;
            [tableView reloadData];
            
            [sendRequestsBtn setTitle:@"Send Friend Requests" forState:UIControlStateNormal];
            break;
            
        case 1:
            peopleMutable = peopleNotUsingArray;
            [tableView reloadData];
            
            [sendRequestsBtn setTitle:@"Send Invitations" forState:UIControlStateNormal];
            break;
			
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [peopleMutable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *dict = [peopleMutable objectAtIndex:indexPath.row];
	
	[cell.imageView setFrame:CGRectMake(0, 0, 44, 44)];
	
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]];
	AFImageRequestOperation *operation;
	operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
		[cell.imageView setImage:image];
	}];
	
	[operation start];
    
	[cell.imageView setImage:[UIImage imageNamed:@"default_facebook_photo.png"]];
	
    cell.textLabel.text = [dict objectForKey:@"name"];
    
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

/*-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (segmentControl.selectedSegmentIndex == 1) {
		if ([nextCursor intValue] > 0) {
			NSInteger sectionsAmount = [self.tableView numberOfSections];
			NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
			
			if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1)
				[self performSelector:@selector(getNonTymepassFollowers) withObject:nil afterDelay:0.1];
		}
	}
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *dict = [peopleMutable objectAtIndex:indexPath.row];
	
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
	{
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}

@end