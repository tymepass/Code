//
//  SearchFbFriendsViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchFbFriendsViewController.h"
#import "Invitation+GAE.h"
#import "Utils.h"
#import "TileScreenController.h"
#import "GlobalData.h"
#import "NSDataAdditions.h"

@implementation SearchFbFriendsViewController
@synthesize tableView;
@synthesize segmentControl;
@synthesize sendRequestsBtn;
@synthesize peopleMutable, peopleArray, facebook, activityIndicator, facebook_response, peopleUsingArray, peopleNotUsingArray;
@synthesize footerView;
@synthesize HUD;
@synthesize userOperation;

/*
 * API: Legacy REST for getting the friends using the app. This is a helper method
 * being used to target app requests in follow-on examples.
 */
- (void) apiRESTGetAppUsers {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    
    [facebook requestWithGraphPath:@"me/friends?fields=name,email,picture,installed" andDelegate:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Initialize mutable arrays
        peopleUsingArray = [[NSMutableArray alloc] init];
        peopleNotUsingArray = [[NSMutableArray alloc] init];
        ApplicationDelegate.isFBpost=FALSE;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadFBfriendforSearch) name:@"reloadtable" object:nil];
		
        /*currentAPICall = fbAPIGetAppUsersFriendsUsing; */
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
        
        facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
		fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InitFacebook" object:nil];
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
	//    TimepassAppDelegate *appdeleagte=(TimepassAppDelegate *)[[UIApplication sharedApplication] delegate];
	//    appdeleagte.SearchFBFriend=self;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Facebook", @"Facebook");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [tableView setEditing:NO animated:YES];
    
    sendRequestsBtn = [ApplicationDelegate.uiSettings createButton:@"Send Friend Requests"];
    [sendRequestsBtn setFrame:CGRectMake(10.0, 10.0, 300.0, 30.0)];
    [sendRequestsBtn addTarget:self action:@selector(sendRequestsBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:sendRequestsBtn];
    
    [segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
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
    
    if (segmentControl)
        [self setSegmentControl:nil];
    
    if (sendRequestsBtn)
        [self setSendRequestsBtn:nil];
    
	[self setFooterView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods
-(void)LoadFBfriendforSearch {
    [HUD setHidden:YES];
	
	NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
																 ascending:YES];
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
	[arrFacebookFriend sortUsingDescriptors:sortDescriptors];
	
	[arrNonFacebookFriends sortUsingDescriptors:sortDescriptors];
	
    peopleUsingArray=arrFacebookFriend;
    peopleNotUsingArray=arrNonFacebookFriends;
	
    [self segmentControlChanged:self];
    [tableView reloadData];
}

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
			[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:emails OfType:@"FacebookUser" stealthMode:nil forEvent:nil];
			
			//TODO uncheck users that got invites (maybe remove them from the arrays??
			[emails removeAllObjects];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
															message: nil
														   delegate: nil
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil,nil];
			[alert show];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	} else {
		
		NSMutableArray * facebookIds = [[NSMutableArray alloc] init];
		
		//from the currently selected table get the email list
		for (NSMutableDictionary *item in peopleMutable){
			
			if ([[item valueForKey:@"isFriend"] isEqualToString:@"YES"])
				continue;
			
			if ([[item valueForKey:@"checked"] isEqualToString:@"NO"])
				continue;
			
			[facebookIds addObject:[item valueForKey:@"id"]];
		}
		
		if ([facebookIds count] > 0) {
			
			NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
			NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
			
			NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
			
			SBJsonWriter *jsonWriter = [SBJsonWriter new];
			NSString *actionLinksStr = [jsonWriter stringWithObject:facebookIds];
			
			NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   kAppId, @"app_id",
										   shareMessageForAll,  @"message",
										   actionLinksStr, @"to",
										   nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DialogForRequest" object:params];
		}
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
    
    //cell.imageView.layer.cornerRadius = 4;
    //[cell.imageView setClipsToBounds: YES];
	
	[cell.imageView setFrame:CGRectMake(0, 0, 44, 44)];
	[cell.imageView setImage:[UIImage imageNamed:@"default_facebook_photo.png"]];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[dict objectForKey:@"photo"]]];
	AFImageRequestOperation *operation;
	operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
		[cell.imageView setImage:image];
	}];
	
	[operation start];
	
    cell.textLabel.text = [dict objectForKey:@"name"];
    
    if ([Utils isFriendOfByFacebookId:[dict valueForKey:@"id"]] || [[[[SingletonUser sharedUserInstance] user] facebookId] isEqualToString:[dict valueForKey:@"id"]]) {
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

#pragma mark - FBSessionDelegate Methods
// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    [self apiRESTGetAppUsers];
    
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
	NSLog(@"Failed login");
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
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
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
    
    //check if the call is about frineds using the app
    if(currentAPICall == fbAPIGetAppUsersFriendsUsing){
        //NSMutableArray *friendsWithApp = [[NSMutableArray alloc] initWithCapacity:1];
        // Many results
        
        // //debugLog(@"%@", [result JSONRepresentation]);
        
        //parse result to array
        NSDictionary *resultDict = [(NSDictionary *) result valueForKey:@"data"];
        
        if ([resultDict count] > 0) {
            NSMutableArray *theKeys = [[NSMutableArray alloc] init];
            NSMutableArray *theObjects = [[NSMutableArray alloc] init];
            NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
            
            
			NSInteger indexPathPeopleRow = 0;
			/*NSInteger indexPathPeopleUsingRow = 0;
			 NSInteger indexPathNotPeopleUsingRow = 0;*/
            
            //TODO check if array can be passed at once without iteration
            for (NSDictionary* user in resultDict) {
                
                UIImage *profileImage =  [UIImage imageNamed:@"default_facebook_photo.png"];
                
                theKeys = [NSMutableArray arrayWithObjects:@"name",@"id",@"photo",@"checked",@"isFriend", nil];
                theObjects = [NSMutableArray arrayWithObjects:[user valueForKey:@"name"],[user valueForKey:@"id"], profileImage, @"NO", @"NO", nil];
                
                theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                
				[[self peopleArray] addObject:theDict];
				
                /*if ([user valueForKey:@"installed"])
				 [[self peopleUsingArray] addObject:theDict];
				 else
				 [[self peopleNotUsingArray] addObject:theDict];*/
                
                NSString *url_image_string = [NSString stringWithFormat:@"%@", [user valueForKey:@"picture"]];
                NSURL* imageURL = [NSURL URLWithString:url_image_string];
                
                //download the image
                [ApplicationDelegate.facebookEngine imageAtURL:imageURL onCompletion:^(UIImage *fetchedImage, NSURL *url, BOOL isInCache) {
					NSMutableDictionary *dict;
					
					dict = [peopleUsingArray objectAtIndex:indexPathPeopleRow];
					
					/*if ([user valueForKey:@"installed"])
					 dict = [peopleUsingArray objectAtIndex:indexPathPeopleUsingRow];
					 else
					 dict = [peopleNotUsingArray objectAtIndex:indexPathNotPeopleUsingRow];
					 
					 UITableViewCell *cell = [dict objectForKey:@"cell"];
					 
					 [cell.imageView setImage:fetchedImage];*/
					
					[dict setObject:fetchedImage forKey:@"photo"];
					
					[peopleArray replaceObjectAtIndex:indexPathPeopleRow withObject:dict];
					
					/*if ([user valueForKey:@"installed"])
					 [peopleUsingArray replaceObjectAtIndex:indexPathPeopleUsingRow withObject:dict];
					 else
					 [peopleNotUsingArray replaceObjectAtIndex:indexPathPeopleUsingRow withObject:dict];*/
					
				}];
                
				indexPathPeopleRow++;
                
                /*if ([user valueForKey:@"installed"])
				 indexPathPeopleUsingRow++;
				 else
				 indexPathNotPeopleUsingRow++;*/
                
            }
            
			NSMutableArray *data = [[NSMutableArray alloc] init];
			for (NSDictionary *people in peopleArray) {
				[data addObject:[people valueForKey:@"id"]];
			}
			
			NSLog(@"%@", data);
			
			NSDictionary *facebookIdsDictionary = [[NSDictionary alloc] initWithObjects:data forKeys:data];
			
			userOperation = [ApplicationDelegate.userEngine checkFacebookIds:facebookIdsDictionary onCompletion:^(NSArray *response) {
				
				NSLog(@"%@", response);
				
				NSArray *list = [response valueForKey:@"emails"];
				
				for (NSArray *user in list) {
					for (int i =0; i < [user count]; i++) {
						NSString *fullname = [NSString stringWithFormat:@"%@ %@", [[user valueForKey:@"name"] objectAtIndex:i], [[user valueForKey:@"surname"] objectAtIndex:i]];
						
						NSString *email = [NSString stringWithFormat:@"%@", [[user valueForKey:@"email"] objectAtIndex:i]];
						NSString *key = [NSString stringWithFormat:@"%@", [[user valueForKey:@"key"] objectAtIndex:i]];
						NSString *facebookId = [NSString stringWithFormat:@"%@", [[user valueForKey:@"facebookId"] objectAtIndex:i]];
						
						UIImage* thumbImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[NSString stringWithFormat:@"%@",
																										  [[user valueForKey:@"photo"] objectAtIndex:i]]]];
						thumbImage = [Utils resizedFromImage:thumbImage inPixes:[ApplicationDelegate.uiSettings profileThumbImagePixels]];
						
						NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name",@"email",@"key",@"checked",@"isFriend", @"id", @"photo", nil];
						NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname,email,key,@"NO",@"NO", facebookId, thumbImage, nil];
						
						NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
						[peopleMutable addObject:theDict];
						
						for (NSDictionary *data in peopleArray) {
							if ([[data valueForKey:@"id"] isEqualToString:facebookId]) {
								[peopleArray removeObject:data];
								break;
							}
						}
					}
				}
				
				peopleNotUsingArray = [peopleArray mutableCopy];
				
			} onError:^(NSError* error) {
			}];
			
            
            //update the table source array peopleMutable by faking index changed
            [self segmentControlChanged:self];
            
            //Reload table data
            [tableView reloadData];
            
            //[self apiDialogRequestsSendToUsers:friendsWithApp];
            //TODO group friends using in table
        } else {
            //debugLog(@"None of your friends are using the app.");
        }
        
		[HUD hide:YES];
        return;
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
    NSLog(@"Err code: %@", [error localizedDescription]);
}

@end
