//
//  MembersLoginViewController.m
//  Registration
//
//  Created by Mac on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MembersLoginViewController.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "UIViewFirstResponder.h"
#import "User+Management.h"
#import "User+GAEUser.h"
#import "SearchForFriendsViewController.h"
#import "Utils.h"
#import "Validation.h"
#import "GAEUtils.h"
#import "Location+Management.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "GlobalData.h"
#import "TileScreenController.h"

enum {
    SectionSignUp                       = 0,
    SectionLogIn                        = 1,
    //SectionStartWithoutSigningUp        = 2,
    SectionsCount                       = 2
};

enum {
	SignUpInSectionSignUpCell                   = 0,
	LogInSectionLoginCell                   = 1,
	SignUpSectionRowsCount                  = 2
};

enum {
    LogInSectionLoginWithFacebookCell       = 0,
    LogInSectionLoginWithTwitterCell        = 1,
    LogInSectionRowsCount                   = 2
};

enum {
    //StartWithoutSigningUpSectionRowsCount = 1
    StartWithoutSigningUpSectionRowsCount = 0
};

TileScreenController *tileScreenController;

@implementation MembersLoginViewController
@synthesize scrollView;
@synthesize tableView;
@synthesize facebook;
@synthesize fbData;
@synthesize facebookId;
@synthesize twitterId;
@synthesize fbPermissions;
@synthesize userOperation;
@synthesize HUD;
@synthesize responseData;
@synthesize results;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [scrollView setFrame:[UIScreen mainScreen].applicationFrame];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 480)];
    
    [self initCells];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"Sign Up", @"Sign Up");
    
    twitterId = @"-1";
    facebookId = @"-1";
    email = @"-1";
    
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [tableView flashScrollIndicators];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = nil;
}

- (void)viewDidUnload {

    [self setTableView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (void)initCells {
    signUpCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    signUpCell.textLabel.text = @"Sign Up";
    signUpCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    signUpCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    signUpCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    loginWithFacebookCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    loginWithFacebookCell.textLabel.text = @"Sign Up / Login with Facebook";
    loginWithFacebookCell.textLabel.font= [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];;
    loginWithFacebookCell.textLabel.textColor  = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    loginWithFacebookCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    loginWithTwitterCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    loginWithTwitterCell.textLabel.text = @"Sign Up / Login with Twitter";
    loginWithTwitterCell.textLabel.font= [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];;
    loginWithTwitterCell.textLabel.textColor  = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    loginWithTwitterCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    logInCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    logInCell.textLabel.text = @"Log in";
    logInCell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    logInCell.textLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellColorRed] green:[ApplicationDelegate.uiSettings cellColorGreen] blue:[ApplicationDelegate.uiSettings cellColorBlue] alpha:1.0];
    logInCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)doLoginWithTwitter {
    
	ACAccountStore *account;
	
	if ([TWTweetComposeViewController canSendTweet])
	{
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.labelText = @"Login...";
		HUD.dimBackground = YES;
		
		// Create account store, followed by a twitter account identifer
		account = [[ACAccountStore alloc] init];
		ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		
		// Request access from the user to use their Twitter accounts.
		[account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error)
		 {
			 // Did user allow us access?
			 if (granted == YES)
			 {
				 // Populate array with all available Twitter accounts
				 __block NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
				 
				 // Populate the tableview
				 if ([arrayOfAccounts count] > 0) {
					 ACAccount *twitterAccount = [arrayOfAccounts objectAtIndex:0];
					 
					 TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@&include_entities=true", twitterAccount.username]]
																  parameters:nil
															   requestMethod:TWRequestMethodGET];
					 
					 [postRequest setAccount:twitterAccount];
					 [postRequest performRequestWithHandler:^(NSData *responseData1,
															  NSHTTPURLResponse *urlResponse,
															  NSError *error) {
						 if ([urlResponse statusCode] == 200) {
							 
							 NSString *responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
							 results = [responseString JSONValue];
							 
							 NSLog(@"user info : %@",results);
							 
							 NSArray *name = [[results objectForKey:@"name"] componentsSeparatedByString:@" "];
							 
							 firstName = [name objectAtIndex:0];
							 lastName = [name count] > 1? [name objectAtIndex:1] : @"";
							 
							 twitterId = [[results objectForKey:@"id"] stringValue];
							 selectedSexIndex = 2;
							 
							 NSString *imageURL = [[results objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
							 
							 UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
							 profilePhoto = [Utils resizedFromImage:image inPixes:[ApplicationDelegate.uiSettings profileImagePixels]];
							 
							 if ([twitterId length] > 3) {
								 
								 dispatch_sync(dispatch_get_main_queue(), ^{
									 [self performSelector:@selector(registerUser) withObject:nil afterDelay:0.1];
								 });

							 } else {
								 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
																				 message:@"A connection error occured. Please try again later." delegate:self
																	   cancelButtonTitle:nil
																	   otherButtonTitles:@"OK", nil];
								 [alert show];
								 [modelUtils rollbackDefaultMOC];
							 }
						 }
					 }];
				 }
			 }
		 }];
	} else {
		
		NSString *message = @"The application cannot send a tweet at the moment. This is because it cannot reach Twitter or you don't have a Twitter account associated with this device.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alertView show];
	}
}

-(void)doLoginWithFacebook {
    
    fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", @"user_birthday", @"status_update", @"publish_stream" ,@"email", nil];
    currentAPICall = kAPIGraphMe;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
    
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    
    if ([Utils FBAuthorization:facebook AppId:kAppId]){
        if (![facebook isSessionValid]) {
            [facebook authorize:fbPermissions];
        } else {
            [self apiFQLIMe];
        }
    }
}

- (void) loginUserWithEmail:(NSString *) emailAddress {
    
    User *loggedUser = nil;
    if (![emailAddress isEqualToString:@"-1"]) {
        loggedUser = (User *)[User getUserWithEmail:emailAddress];
        
        if (![loggedUser serverId]) {
            loggedUser = (User *)[User getGAEUserWithEmail:emailAddress];
        }
        
    } else {
        loggedUser = (User *)[User getUserWithTwitterId:twitterId];
        if (![loggedUser serverId]) {
            loggedUser = (User *)[User getGAEUserWithTwitterId:twitterId];
        }
    }
    
    if (loggedUser) {
        [self doLogin:loggedUser];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed!"
                                                        message:[NSString stringWithFormat:@"The email address %@ is not registered with Tymepass", emailAddress ? emailAddress :
                                                                 [NSString stringWithFormat:@"%@ %@",firstName, lastName]]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK",nil];
		[alert show];
        [HUD setHidden:YES];
    }
}

- (void) doLogin:(User *) loggedUser {
    //Get the user from core data
    [[SingletonUser sharedUserInstance] setUser:loggedUser];
    //debugLog(@"%@",[loggedUser name]);
    
    [loggedUser setIsLoggedIn:[NSNumber numberWithBool:YES]];
    [modelUtils commitDefaultMOC];
    
    NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
    [cacheStorage setObject:[loggedUser email] forKey:@"LastLoginEmail"];
	[cacheStorage setObject:[loggedUser facebookId] forKey:@"LastLoginFacebookId"];
	[cacheStorage setObject:[loggedUser twitterId] forKey:@"LastLoginTwitterId"];
    [cacheStorage synchronize];
    
    [[SingletonUser sharedUserInstance] setGaeFriends:nil];
    
    if (loggedUser && [loggedUser serverId])
        [ApplicationDelegate.userEngine getGAEFriendKeysOfUser:loggedUser];
    
    //Sync after login
    [[GlobalData sharedGlobalData] setSync:TRUE];
    [[GlobalData sharedGlobalData] setGetGAEFriends:FALSE];
    
    //TODO consider asking from the server the user details if they are not in core data
    tileScreenController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
    
    //remove all screens from navigation array
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    //change root controller
    [ApplicationDelegate changeNavigationRoot:tileScreenController];
    
    if (!ApplicationDelegate.loadingView) {
        ApplicationDelegate.loadingView = [[UIImageView alloc] initWithFrame:ApplicationDelegate.navigationController.self.view.bounds];
        
		UIImage* myImage;
		CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
		if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
			myImage = [UIImage imageNamed:@"Default-568h@2x.png"];
		} else {
			myImage = [UIImage imageNamed:@"Default.png"];
		}
		
		[ApplicationDelegate.loadingView setImage:myImage];
        
        [ApplicationDelegate.navigationController.view addSubview:ApplicationDelegate.loadingView];
    }
}

- (void) registerUser {
    
    User *newUser = nil;
    
    if (![twitterId isEqualToString:@"-1"]) {
        newUser = [User checkExistsByTwitterIdInCD:twitterId inContext:[modelUtils defaultManagedObjectContext]];
    } else {
        newUser = [User checkExistsByEmailInCD:email inContext:[modelUtils defaultManagedObjectContext]];
    }
    
    if (newUser) {
        // lgoin user
        [self loginUserWithEmail:email];
    } else {
        
        if ([twitterId isEqualToString:@"-1"]) {
            newUser = [User insertUserWithEmail:email
                                           name:firstName
                                        surname:lastName
                                       password:@""
                                     datOfBirth:birthdate ? birthdate : nil
                                     occupation:@""
                                         gender:[NSNumber numberWithInt:selectedSexIndex]
                                          photo:@""
                                 homeLocationId:nil
                                     facebookId:facebookId];
            
            userOperation = [ApplicationDelegate.userEngine checkGAEUserWithEmail:email onCompletion:^(NSString *status) {
				if ([status isEqualToString:@"1"]) {
					[self loginUserWithEmail:email];
					[HUD setHidden:YES];
				} else {
					[self doRegister:newUser];
				}
			} onError:^(NSError* error) {
				[HUD setHidden:YES];
				[modelUtils rollbackDefaultMOC];
			}];
            
        } else {
            newUser = [User insertUserWithEmail:@"-1"
                                           name:firstName
                                        surname:lastName
                                       password:@"-1"
                                     datOfBirth:birthdate ? birthdate : nil
                                     occupation:@""
                                         gender:[NSNumber numberWithInt:selectedSexIndex]
                                          photo:@""
                                 homeLocationId:nil
                                      TwitterId:twitterId];
            
            userOperation = [ApplicationDelegate.userEngine checkGAEUserWithTwitterId:twitterId onCompletion:^(NSString *status) {
				if ([status isEqualToString:@"1"]) {
					[self loginUserWithEmail:email];
					[HUD setHidden:YES];
				} else {
					[self doRegister:newUser];
				}
			} onError:^(NSError* error) {
				[HUD setHidden:YES];
				[modelUtils rollbackDefaultMOC];
			}];
        }
    }
}

- (void) doRegister:(User *) newUser {
	
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(profilePhoto)];
	newUser.photoData = imageData;
	
    userOperation = [ApplicationDelegate.userEngine insertGAEUserWithUser:newUser onCompletion:^(NSString *result) {
		[HUD setHidden:YES];
		
		if ([result intValue] > 0) {
			newUser.serverId = result;
			
			//succesful registration
			[[SingletonUser sharedUserInstance] setUser:newUser];
			
			[newUser setDateCreated:[NSDate date]];
			[newUser setIsLoggedIn:[NSNumber numberWithBool:YES]];
			[modelUtils commitDefaultMOC];
			
			NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
			[cacheStorage setObject:[newUser email] forKey:@"LastLoginEmail"];
			[cacheStorage synchronize];
			
			UIViewController *searchForFriendsViewController = [[SearchForFriendsViewController alloc] initWithNibName:@"SearchForFriendsViewController" bundle:nil settingsViewMode:NO];
			
			[self.navigationController pushViewController:searchForFriendsViewController animated:YES];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
															message:@"A connection error occured. Please try again later." delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[modelUtils rollbackDefaultMOC];
		}
	} onError:^(NSError* error) {
		[HUD setHidden:YES];
		[modelUtils rollbackDefaultMOC];
	}];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionSignUp:
            return SignUpSectionRowsCount;
        case SectionLogIn:
            return LogInSectionRowsCount;
            //case SectionStartWithoutSigningUp:
            //    return StartWithoutSigningUpSectionRowsCount;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
	
    switch (section) {
        case SectionSignUp: {
            headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
            
            UILabel *headerLabel1 = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
            headerLabel1.text =  @"WELCOME TO TYMEPASS";
            
            UILabel *headerDetailLabel1 = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [headerDetailLabel1 setFrame:CGRectMake(12.0, 5.0, 520.0, 140.0)];
            headerDetailLabel1.numberOfLines = 7;
            headerDetailLabel1.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
            headerDetailLabel1.text =  @"Tymepass is your hook up to a more easy and\nstreamlined way of arranging and sharing your time.\nSee what your friends are up to, invite them,\njoin them, or even avoid them!\n\nPure magic lives inside Tymepass.\nTo experience it fully, you need to sign up.";
            
            [headerLabel setFrame:CGRectMake(12.0, 130.0, 300.0, 40.0)];
            headerLabel.text =  @"EMAIL";
            
            [headerView addSubview:headerLabel1];
            [headerView addSubview:headerDetailLabel1];
            [headerView addSubview:headerLabel];
            
        }
            return headerView;
        case SectionLogIn:
            [imageSeparator setFrame:CGRectMake(12.0, 0.0, 300.0, 2.0)];
            [headerLabel setFrame:CGRectMake(12.0, 10.0, 300.0, 20.0)];
            headerLabel.text =  @"SOCIAL";
            [headerView addSubview:imageSeparator];
            [headerView addSubview:headerLabel];
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == SectionSignUp) {
        cell = signUpCell;
		
		switch (indexPath.row) {
            case LogInSectionLoginCell:
                cell = logInCell;
                break;
            case SignUpInSectionSignUpCell:
                cell = signUpCell;
                break;
            default:
                break;
        }
		
		
    } else if (indexPath.section == SectionLogIn) {
        switch (indexPath.row) {
            
            case LogInSectionLoginWithFacebookCell:
                cell = loginWithFacebookCell;
                break;
            case LogInSectionLoginWithTwitterCell:
                cell = loginWithTwitterCell;
                break;
            default:
                break;
        }
    }
    /*
     else {
     cell = startWithoutSignUpCell;
     }
     */
    
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SectionSignUp)
        return 165.0;
    
    //if (section == SectionStartWithoutSigningUp)
    //    return 75.0;
    
    if (section == SectionLogIn)
        return 40.0;
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionSignUp) {
        
		if (indexPath.row == LogInSectionLoginCell) {
            
            logInViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [self.navigationController pushViewController:logInViewController animated:YES];
        } else if (indexPath.row == SignUpInSectionSignUpCell) { signUpViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
        [self.navigationController pushViewController:signUpViewController animated:YES];
		}
		else {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
    } else if (indexPath.section == SectionLogIn) {
        
        
         if (indexPath.row == LogInSectionLoginWithFacebookCell) {
            
            /* login with facebook code */
            [self doLoginWithFacebook];
        }
        else if(indexPath.row==LogInSectionLoginWithTwitterCell) {
            
            /* login with twitter code */
            [self doLoginWithTwitter];
        }else {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    /*
     else if (indexPath.section == SectionStartWithoutSigningUp) {
     signUpViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
     [self.navigationController pushViewController:signUpViewController animated:YES];
     }
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    [self apiFQLIMe];
    
    [Utils storeFBAuthData:[facebook accessToken] expiresAt:[facebook expirationDate]];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [Utils storeFBAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the session has expired.
 */
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle: nil
                              otherButtonTitles: @"OK",nil];
    [alertView show];
    [self fbDidLogout];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    
    switch (currentAPICall) {
        case kAPIGraphMe:
        {
            debugLog(@"%@",[(NSArray *)result JSONRepresentation]);
            
            firstName = [result objectForKey:@"first_name"];
            lastName = [result objectForKey:@"last_name"];
            
            if ([result objectForKey:@"birthday"] != [NSNull null]) {
                email = [result objectForKey:@"email"];
                emailConfirm = [result objectForKey:@"email"];
            }
            facebookId = [[result objectForKey:@"uid"] stringValue];
            
            if ([result objectForKey:@"birthday"] != [NSNull null]) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"MMM dd, yyyy"];
                [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                NSDate *date = [df dateFromString:[result objectForKey:@"birthday"]];
                
                [df setDateFormat:@"dd-MM-yyyy"];
                NSString *dateStr = [df stringFromDate:date];
                
                birthdate = [df dateFromString:dateStr];
            }
            
            if ([[result objectForKey:@"sex"] isEqualToString:@"male"]) {
                selectedSexIndex = 0;
            } else  if ([[result objectForKey:@"sex"] isEqualToString:@"female"]) {
                selectedSexIndex = 1;
            } else {
                selectedSexIndex = 2;
            }
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[result objectForKey:@"pic_big"]]]];
            profilePhoto = [Utils resizedFromImage:image inPixes:[ApplicationDelegate.uiSettings profileImagePixels]];
			
			if ([facebookId length] > 3) {
				[self performSelector:@selector(registerUser) withObject:nil afterDelay:0.1];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed"
																message:@"A connection error occured. Please try again later." delegate:self
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
				[modelUtils rollbackDefaultMOC];
			}
			
            break;
        }
        default:
            break;
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}

#pragma mark - Facebook API Calls
/**
 * Make a Graph API Call to get information about the current logged in user.
 */
- (void)apiFQLIMe {
    
    HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
    HUD.labelText = @"Login...";
    HUD.dimBackground = YES;
    
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, first_name, last_name, email, birthday, pic_big, sex FROM user WHERE uid=me()", @"query",
                                   nil];
    
    [facebook requestWithMethodName:@"fql.query"
                          andParams:params
                      andHttpMethod:@"POST"
                        andDelegate:self];
}

@end