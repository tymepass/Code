//
//  TimePassAppDelegate.m
//  TimePass
//
//  Created by Christos Skevis on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimepassAppDelegate.h"
#import "User.h"
#import "User+Management.h"
#import "MembersLoginViewController.h"
#import "TileScreenController.h"
#import "Utils.h"
#import "Event+Management.h"

#import "CreateEventViewController.h"
#import "EventViewController.h"
#import "NotificationsViewController.h"
#import "FriendsProfileViewController.h"
#import "MessageWallTableViewController.h"

#import "GlobalData.h"
#import "UAirship.h"
#import "UAPush.h"
#import "FBConnect.h"
#import "NSDataAdditions.h"

apiCall currentAPICall;
//static NSString* kAppId = @"210849718975311";

static NSString * updateDeviceTokenURL = @"https://tymepass.com/api/?action=updateDeviceToken";
static NSString* hostName = @"tymepass.com/api";

@implementation TimepassAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize rootViewController = _rootViewController;
@synthesize loadingView = _loadingView;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize receivedData;

@synthesize gaeEngine = _gaeEngine;
@synthesize syncEngine = _syncEngine;
@synthesize userEngine = _userEngine;
@synthesize invitationEngine = _invitationEngine;
@synthesize eventEngine = _eventEngine;
@synthesize facebookEngine = _facebookEngine;
@synthesize arrTwitterData;
@synthesize HUD;
@synthesize facebook;
@synthesize uiSettings = _uiSettings;
@synthesize isFBpost;
@synthesize userOperation;

//@synthesize SearchFBFriend;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //load the home view when app initializes
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window.rootViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    arrTwitterData = [[NSMutableArray alloc] init];
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    [headerFields setValue:@"MKNetworkKit" forKey:@"User-Agent"];
    [headerFields setValue:@"application/json" forKey:@"Content-Type"];
    
    self.gaeEngine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:headerFields];
    [self.gaeEngine useCache];
    
    self.syncEngine = [[SyncEngine alloc] initWithHostName:hostName customHeaderFields:headerFields];
    [self.syncEngine useCache];
    
    self.userEngine = [[UserEngine alloc] initWithHostName:hostName customHeaderFields:headerFields];
    [self.userEngine useCache];
    
    self.invitationEngine = [[InvitationEngine alloc] initWithHostName:hostName customHeaderFields:headerFields];
    [self.invitationEngine useCache];
    
    self.eventEngine = [[EventEngine alloc] initWithHostName:hostName customHeaderFields:headerFields];
    [self.eventEngine useCache];
    
    self.facebookEngine = [[MKNetworkEngine alloc] initWithHostName:@"api.facebook.com" customHeaderFields:nil];
    [self.facebookEngine useCache];
    
    _uiSettings = [[UISettings alloc] init];
    
    NSUserDefaults *cacheStorage = [NSUserDefaults standardUserDefaults];
    NSString *lastLoginEmail = [cacheStorage objectForKey:@"LastLoginEmail"];
	NSString *lastLoginFacebookId = [cacheStorage objectForKey:@"LastLoginFacebookId"];
	NSString *lastLoginTwitterId = [cacheStorage objectForKey:@"LastLoginTwitterId"];
	
	NSPredicate *predicate;
	
	if (lastLoginFacebookId != nil && [lastLoginFacebookId isEqualToString:@"-1"] == FALSE) {
		
		predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", lastLoginFacebookId];
		
	} else if (lastLoginTwitterId != nil && [lastLoginTwitterId isEqualToString:@"-1"] == FALSE) {
		
		predicate = [NSPredicate predicateWithFormat:@"twitterId == %@", lastLoginTwitterId];
		
	} else {
		
		predicate = [NSPredicate predicateWithFormat:@"email == %@", lastLoginEmail];
		
	}
	
    User *user = (User *)[modelUtils fetchManagedObject:@"User"
											  predicate:predicate
										sortDescriptors:nil
													moc:[modelUtils defaultManagedObjectContext]];
    
    _rootViewController = [[MembersLoginViewController alloc] initWithNibName:@"MembersLoginViewController" bundle:nil];
    
    if (user) {
        SingletonUser *singletonUser = [SingletonUser sharedUserInstance];
		
		if (![user serverId]) {
			user = (User *)[User getGAEUserWithEmail:[user valueForKey:@"email"]];
		}
		
        [singletonUser setUser:user];
        
        if (user.isLoggedIn.boolValue) {
            _rootViewController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
        }
    } else {
        /*
         NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
         NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
         
         NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
         
         Facebook *facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
         
         if ([Utils FBAuthorization:facebook AppId:kAppId]){
         if ([facebook isSessionValid]) {
         _rootViewController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
         }
         else
         _rootViewController = [[MembersLoginViewController alloc] initWithNibName:@"MembersLoginViewController" bundle:nil];
         
         }
         */
        // _rootViewController = [[MembersLoginViewController alloc] initWithNibName:@"MembersLoginViewController" bundle:nil];
    }
    
    //_rootViewController = [[TileScreenController alloc] initWithNibName:@"TileScreenController" bundle:nil];
    /*
     self.navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
     [navigationController setNavigationBarHidden:YES animated:NO];
     
     self.window.rootViewController = self.navigationController;
     */
    
    //self.navigationController = navController;
    
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
    [_navigationController setDelegate:self];
    
    self.window.rootViewController = _navigationController;
    
    [_window addSubview:_navigationController.view];
    [self.window makeKeyAndVisible];
    
    [self failIfSimulator];
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    [UAirship takeOff:takeOffOptions];
    [[UAPush shared] enableAutobadge:YES];
    [[UAPush shared] resetBadge];
    
    // Register for notifications through UAPush for notification type tracking
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //Global Slider Appearance
    UIImage *minImage = [UIImage imageNamed:@"slider-fill.png"];
    UIImage *maxImage = [UIImage imageNamed:@"slider-fill.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"slider-handle.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateHighlighted];
    
    
    //Global SegmentedControl Appearance
    UIImage *segmentSelected = [UIImage imageNamed:@"segmentSelected.png"];
    UIImage *segmentUnSelected = [UIImage imageNamed:@"segmentUnSelected.png"];
    
    [[UISegmentedControl appearance] setBackgroundImage:segmentUnSelected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    [[UISegmentedControl appearance] setDividerImage:segmentUnselectedUnselected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    UIImage *segmentUnSelectedSelected = [UIImage imageNamed:@"segcontrol_uns-uns.png"];
    [[UISegmentedControl appearance] setDividerImage:segmentUnSelectedSelected
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
	
    [[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
	
	
	BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0;
	if (isIOS5){
		
		// access to ical permission
		EKEventStore *eventStore = [[EKEventStore alloc] init];
		if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
			// iOS 6 and later
			[eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
				
			}];
			
		}
		
		// contact related permission
		CFErrorRef myError = NULL;
		ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
		ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool granted, CFErrorRef error) {
			if (granted) {
				
			} else {
				
			}
		});
		//CFRelease(myAddressBook);
	}
    
    arrFriend=[[NSMutableArray alloc] init];
	arrFacebookFriend=[[NSMutableArray alloc] init];
    arrNonFacebookFriends=[[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetFacebookFriends) name:@"GetFacebookFriends" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(InitfacebookForGetFriends) name:@"InitFacebook" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DialogForRequest:) name:@"DialogForRequest" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoFbPost:) name:@"DoPost" object:nil];
	
	UILocalNotification *launchNote = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (launchNote){
		[self handleNotificationsWithDictionary:launchNote.userInfo];
    }
	
	firstLoad = TRUE;
    
    return YES;
}

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[TileScreenController class]])
		[navController setNavigationBarHidden:YES animated:NO];
	else
		[navController setNavigationBarHidden:NO animated:YES];
    
    navController.navigationBar.tintColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings navigationBarTintColorRed] green:[ApplicationDelegate.uiSettings navigationBarTintColorGreen] blue:[ApplicationDelegate.uiSettings navigationBarTintColorBlue] alpha:1.0];
    
    //navController.navigationBar.backItem.title = @"Back";
}

- (void) changeNavigationRoot:(UIViewController *) newRoot{
    _navigationController = [[UINavigationController alloc] initWithRootViewController:newRoot];
    [_navigationController setDelegate:self];
    
    self.window.rootViewController = _navigationController;
    
    [_window addSubview:_navigationController.view];
    [_window makeKeyAndVisible];
    
    //debugLog (@"Root controller is : %@", [self navigationController]);
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //[[UAPush shared] setBadgeNumber:1];
    
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    UIViewController *topViewController = [_navigationController topViewController];
    
    if ([topViewController isKindOfClass:[TileScreenController class]]) {
        if (!_loadingView) {
            _loadingView = [[UIImageView alloc] initWithFrame:_navigationController.self.view.bounds];
			_loadingView.userInteractionEnabled = YES;
            
			UIImage* myImage;
			CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
			if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
				myImage = [UIImage imageNamed:@"Default-568h@2x.png"];
			} else {
				myImage = [UIImage imageNamed:@"Default.png"];
			}
			
			[_loadingView setImage:myImage];
			
            //_loadingView.contentMode = UIViewContentModeScaleToFill;
            [_navigationController.view addSubview:_loadingView];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UALOG(@"Application did become active.");
    
	bool sync = false;
	
	if (firstLoad) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		double timeInterval = [[NSDate date] timeIntervalSince1970];
		[defaults setDouble:timeInterval forKey:@"firstSync"];
		[defaults synchronize];
		sync = TRUE;
		firstLoad = false;
		
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		double timeInterval = [[defaults valueForKey:@"firstSync"] doubleValue];
		
		NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:timeInterval];
		NSDate *date2 = [NSDate date];
		//NSLog(@"%@f is the time difference",[date2 timeIntervalSinceDate:date1]);
		if ([date2 timeIntervalSinceDate:date1] > 3600) {
		//	sync = TRUE;
			//Client asked to stop the automatic refresh so we are disabling it.
		}
	}
    
    [[UAPush shared] resetBadge]; //zero badge when resuming from background (iOS 4+)
    
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    UIViewController *topViewController = [_navigationController topViewController];
    
    if ([topViewController isKindOfClass:[TileScreenController class]] && sync) {
        [[GlobalData sharedGlobalData] setSync:FALSE];
        [[GlobalData sharedGlobalData] setGetGAEFriends:TRUE];
        
        if ([[SingletonUser sharedUserInstance] user]) {
            
			if (!_loadingView) {
                _loadingView = [[UIImageView alloc] initWithFrame:_navigationController.self.view.bounds];
				_loadingView.userInteractionEnabled = YES;
				
				UIImage* myImage;
				CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
				if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
					myImage = [UIImage imageNamed:@"Default-568h@2x.png"];
				} else {
					myImage = [UIImage imageNamed:@"Default.png"];
				}
				
                [_loadingView setImage:myImage];
				//_loadingView.contentMode = UIViewContentModeScaleToFill;
                
                [_navigationController.view addSubview:_loadingView];
            }
            
            //sync with server
            [GAEUtils getSyncDataFromGAEFor:[[SingletonUser sharedUserInstance] user]];
        }
        else
            [[GlobalData sharedGlobalData] setSync:TRUE];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
	
	if ([[SingletonUser sharedUserInstance] user] && [[[SingletonUser sharedUserInstance] user] serverId]) {
		
		NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
		NSString *str2 = [str substringWithRange:NSMakeRange(1, 71)];
		NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@" " withString:@""];
		
		NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
		
		[jsonObject setObject:[[NSString alloc] initWithFormat:@"%@", str3] forKey:@"deviceId"];
		[jsonObject setObject:[[[SingletonUser sharedUserInstance] user] serverId] forKey:@"id"];
		
		[GAEUtils sendRequest:jsonObject toURL:updateDeviceTokenURL];
	}
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UALOG(@"Received remote notification: %@", userInfo);
    
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
    [[UAPush shared] resetBadge]; // zero badge after push received
    
    /*
     NSString *alertMessage = [[userInfo objectForKey:@"aps"] valueForKey:@"alert"];
     //debugLog(@"alertMsg: %@",alertMessage);
     */
    
    NSLog(@"alertMsg: %@",userInfo);
    
    if (appState != UIApplicationStateActive) {
		[self handleNotificationsWithDictionary:userInfo];
    } else {

		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notification"
															message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]]
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		
		UIViewController *topViewController = [_navigationController topViewController];
		
		if ([topViewController isKindOfClass:[TileScreenController class]]) {
			[topViewController viewDidAppear:YES];
		}
		
		NSString *messageType = [[userInfo objectForKey:@"aps"] valueForKey:@"messageType"];
		if([messageType isEqualToString:@"PersonalMessage"]) {
			
			if([topViewController isKindOfClass:[MessageWallTableViewController class]]) {
				[topViewController viewWillAppear:YES];
			}
		}
	}
}

- (void)handleNotificationsWithDictionary:(NSDictionary *)userInfo {
	
	[_navigationController popToRootViewControllerAnimated:NO];
	NSString *messageType = [[userInfo objectForKey:@"aps"] valueForKey:@"messageType"];
	
	/*
	 Message = send message
	 EventInvitation = send invitation for event
	 EventInvitationConfirm = confirm invitation of event
	 EventInvitationMaybe = may be invitation of event
	 Event = event created or edited
	 FriendRequest = accept or reject friend request
	 FriendRequestConfirm = friend request accepted
	 */
	
	if ([messageType isEqualToString:@"Message"] ||
		[messageType isEqualToString:@"EventInvitation"] ||
		[messageType isEqualToString:@"EventInvitationConfirm"] ||
		[messageType isEqualToString:@"EventInvitationMaybe"] ||
		[messageType isEqualToString:@"Event"]) {
		NSString *eventId = [[userInfo objectForKey:@"aps"] valueForKey:@"serverId"];
		
		[self.invitationEngine requestInvitationsOfUser:[[SingletonUser sharedUserInstance] user] onCompletion:^(NSArray *responseData) {
			BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
			if (!isIOS5){
				// Create new SBJSON parser object
				SBJsonParser *parser = [[SBJsonParser alloc] init];
				responseData = [parser objectWithString:(NSString *) responseData];
			}
			[Invitation getInvitations:responseData];
			
			Event *event = [Event getEventWithId:eventId];
			if (event) {
				if([event.isOpen intValue] == 1){
					UIViewController *eventViewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil event:event];
					//debugLog(@"object: %@", [[dict objectForKey:@"object"] description]);
					
					[self.navigationController pushViewController:eventViewController animated:YES];
				}else{
					UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:event];
					[_navigationController pushViewController:eventViewController animated:NO];
				}
			}
			
		} onError:^(NSError* error) {
			
		}];
	}
	
	else if([messageType isEqualToString:@"FriendRequest"]) {
		
		NotificationsViewController *notificationViewController = [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:Nil];
		[_navigationController pushViewController:notificationViewController animated:NO];
		
	}
	
	else if([messageType isEqualToString:@"FriendRequestConfirm"]) {
		
		NSString *serverId = [[userInfo objectForKey:@"aps"] valueForKey:@"serverId"];
		User *friend = [User getUserWithId:serverId inContext:[modelUtils defaultManagedObjectContext]];
		
		FriendsProfileViewController *controller = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:friend];
		
		[_navigationController pushViewController:controller animated:NO];
	}
	
	else if([messageType isEqualToString:@"PersonalMessage"]) {
		NSString *serverId = [[userInfo objectForKey:@"aps"] valueForKey:@"serverId"];
		User *friend = [User getUserWithId:serverId inContext:[modelUtils defaultManagedObjectContext]];
		
		MessageWallTableViewController *controller = [[MessageWallTableViewController alloc] initWithMessages:nil forUser:friend];
		[_navigationController pushViewController:controller animated:YES];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [UAirship land];
    [self saveContext];
}

/**
 * Facebook login callback
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    if (!url)
        return NO;
    
    //Example 1 - tymepass://
    //Example 2 (with params) - tymepass://?event-id=123&type=...
    
    NSString *URLString = [url absoluteString];
    
    //FB URL Schemme
    NSRange fbRange = [URLString rangeOfString:@"fb134410616740515://"];
    if (fbRange.length > 0) {
        UIViewController *topViewController = [_navigationController topViewController];
        
        if([topViewController isKindOfClass:[MembersLoginViewController class]])
            return [[(MembersLoginViewController *)topViewController facebook] handleOpenURL:url];
        
        if([topViewController isKindOfClass:[CreateEventViewController class]])
            return [[(CreateEventViewController *)topViewController facebook] handleOpenURL:url];
    }
    
    //Custom URL Schemme
    NSRange start = [URLString rangeOfString:@"?"];
    if (start.length > 0) {
        NSString *parametersString = [URLString substringWithRange:NSMakeRange(start.location + 1, [URLString length] - start.location - 1)];
        NSArray *parameters = [NSArray arrayWithArray:[parametersString componentsSeparatedByString:@"&"]];
        
        if (parameters && [parameters count] > 0) {
            NSString *eventServerId = [[NSArray arrayWithArray:[[parameters objectAtIndex:0] componentsSeparatedByString:@"="]] objectAtIndex:1];
            
            Event *event = [Event getEventWithId:eventServerId];
            
            if (event) {
                UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:event];
                
                [_navigationController pushViewController:eventViewController animated:NO];
            }
        }
    } else {
        [facebook handleOpenURL:url];
    }
    
    return YES;
}

/*
 - (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
 {
 // TODO: Pass the token to our server
 
 // Convert the token to a hex string and make sure it's all caps
 NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
 [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
 [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
 [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
 
 [[myUAirship sharedUAirship] setDeviceToken:tokenString];
 [[myUAirship sharedUAirship] setAppId:@"aamrT_x4SXexwsrd8AvzaA"];
 [[myUAirship sharedUAirship] setAppSecret:@"DtpKdF4GSRyhx2_v2pdafg"];
 
 // Create the NSURL for the request
 NSString *urlFormat = @"https://go.urbanairship.com/api/device_tokens/%@";
 NSURL *registrationURL = [NSURL URLWithString:[NSString stringWithFormat:
 urlFormat, tokenString]];
 
 // Create the registration request
 NSMutableURLRequest *registrationRequest = [[NSMutableURLRequest alloc]
 initWithURL:registrationURL];
 [registrationRequest setHTTPMethod:@"PUT"];
 
 // And fire it off
 NSURLConnection *connection = [NSURLConnection connectionWithRequest:registrationRequest
 delegate:self];
 [connection start];
 
 //debugLog(@"We successfully registered for push notifications");
 
 // Inform the user that registration failed
 NSString* successMessage = @"We successfully registered for push notifications.";
 UIAlertView* successAlert = [[UIAlertView alloc] initWithTitle:@"Success"
 message:successMessage
 delegate:nil
 cancelButtonTitle:nil
 otherButtonTitles:@"OK",nil];
 
 [successAlert show];
 }
 
 - (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
 {
 // Inform the user that registration failed
 NSString* failureMessage = @"There was an error while trying to register for push notifications.";
 UIAlertView* failureAlert = [[UIAlertView alloc] initWithTitle:@"Error"
 message:failureMessage
 delegate:nil
 cancelButtonTitle:nil
 otherButtonTitles:@"OK",nil];
 [failureAlert show];
 
 //debugLog(@"%@",failureMessage);
 }
 */

/*
 - (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
 // Check for previous failures
 if ([challenge previousFailureCount] > 0)
 {
 // We've already tried - something is wrong with our credentials
 //debugLog(@"Urban Airship credentials invalid");
 
 NSString* failureMessage = @"Urban Airship credentials invalid.";
 UIAlertView* failureAlert = [[UIAlertView alloc] initWithTitle:@"Error"
 message:failureMessage
 delegate:nil
 cancelButtonTitle:nil
 otherButtonTitles:@"OK",nil];
 [failureAlert show];
 return;
 }
 
 NSString *path = [[NSBundle mainBundle] pathForResource:@"AirshipConfig" ofType:@"plist"];
 NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
 
 NSString *appKey = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"DEVELOPMENT_APP_KEY"]];
 NSString *appSecret = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"DEVELOPMENT_APP_SECRET"]];
 
 if ([@"YES" isEqualToString:[plistData objectForKey:@"APP_STORE_OR_AD_HOC_BUILD"]]) {
 appKey = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"PRODUCTION_APP_KEY"]];
 appSecret = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"PRODUCTION_APP_SECRET"]];
 }
 
 // Send our Urban Airship credentials
 NSURLCredential *airshipCredentials = [NSURLCredential credentialWithUser:appKey
 password:appSecret
 persistence:NSURLCredentialPersistenceNone];
 
 [[challenge sender] useCredential:airshipCredentials
 forAuthenticationChallenge:challenge];
 }
 */


-(void)GetFacebookFriends {
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
	HUD.labelText = @"Loading...";
	HUD.dimBackground = YES;
	
    [facebook requestWithGraphPath:@"me/friends?fields=name,email,picture,installed" andDelegate:self];
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Timepass" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Timepass.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"temp.sqlite"];
    
    NSPersistentStoreCoordinator *tempPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![tempPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    if (tempPersistentStoreCoordinator != nil) {
        NSManagedObjectContext *scratchPad = [[NSManagedObjectContext alloc] init];
        [scratchPad setPersistentStoreCoordinator:tempPersistentStoreCoordinator];
        [scratchPad setUndoManager:nil];
        
        [[Utils sharedUtilsInstance] setScratchPad:scratchPad];
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    
    //NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //debugLog(@"Received Data from Registration Request:%@",responseString);
    
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    /*UIAlertView *didFailWithErrorMessage = [[UIAlertView alloc] initWithTitle: @"NSURLConnection " message: @"didFailWithError"  delegate: self  cancelButtonTitle:nil
     otherButtonTitles:@"OK",nil];
     [didFailWithErrorMessage show];*/
	
    //inform the user
    //debugLog(@"Connection failed! Error - %@",[error localizedDescription]);
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
        /*UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
         message:@"You will not be able to recieve push notifications in the simulator."
         delegate:self
         cancelButtonTitle:nil
         otherButtonTitles:@"OK",nil];
         
         [someError show];*/
        
        //debugLog(@"You will not be able to recieve push notifications in the simulator");
        
    }
}
#pragma mark - FBSessionDelegate Methods
-(void)DoFbPost:(NSString *)post
{
    currentAPICall = kAPIGraphMe;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[facebook accessToken],@"access_token",
                                   post, @"message",
                                   nil];
    
    // @"Test it!",@"name"
    NSLog(@"%@",params);
    
    //    Facebook *fb = [[Facebook alloc] init];
    
    
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    NSArray *fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", @"status_update", @"publish_stream",nil];
    NSLog(@"fbpermission array : %@",fbPermissions);
    if ([Utils FBAuthorization:facebook AppId:kAppId]){
        if (![facebook isSessionValid]) {
            [facebook authorize:fbPermissions];
            [facebook requestWithGraphPath:@"me/feed"   // or use page ID instead of 'me'
                                 andParams:params
                             andHttpMethod:@"POST"
                               andDelegate:self];
            
            
            // [NSString stringWithFormat:@"%@/feed",kAppId]
            
        } else {
            //[self apiRESTGetAppUsers];
            [facebook requestWithGraphPath:@"me/feed"   // or use page ID instead of 'me'
                                 andParams:params
                             andHttpMethod:@"POST"
                               andDelegate:self];
        }
    }
}

-(void)DialogForRequest:(NSNotification *)notification {
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:notification.object];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
	
	facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    NSArray *fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", @"status_update", @"publish_stream",nil];
    NSLog(@"fbpermission array : %@",fbPermissions);
    if ([Utils FBAuthorization:facebook AppId:kAppId]){
		
		if (![facebook isSessionValid]) {
            [facebook authorize:fbPermissions];
			[facebook dialog:@"apprequests" andParams:params andDelegate:self];
		} else {
			[facebook dialog:@"apprequests" andParams:params andDelegate:self];
		}
	}
	
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self application:application handleOpenURL:url];
}

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    // [self apiRESTGetAppUsers];
    
    [Utils storeFBAuthData:[facebook accessToken] expiresAt:[facebook expirationDate]];
    
    if (currentAPICall == fbAPIGetAppUsersFriendsUsing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetFacebookFriends" object:nil];
    }
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
-(void)InitfacebookForGetFriends
{
    currentAPICall = fbAPIGetAppUsersFriendsUsing;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
    
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    NSArray *fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", nil];
    NSLog(@"fbpermission array : %@",fbPermissions);
    if ([Utils FBAuthorization:facebook AppId:kAppId]){
        if (![facebook isSessionValid]) {
            [facebook authorize:fbPermissions];
            //[self apiRESTGetAppUsers];
        } else {
            //[self apiRESTGetAppUsers];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetFacebookFriends" object:nil];
        }
    }
    
}
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response objec-t.
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
    
    [HUD hide:YES];
    
    //check if the call is about frineds using the app
    if(currentAPICall == fbAPIGetAppUsersFriendsUsing) {

        //parse result to array
        NSDictionary *resultDict = [(NSDictionary *) result valueForKey:@"data"];
        
        if ([resultDict count] > 0) {
            
            [arrNonFacebookFriends removeAllObjects];
            [arrFacebookFriend removeAllObjects];
			[arrFriend removeAllObjects];
            
            NSMutableArray *theKeys = [[NSMutableArray alloc] init];
            NSMutableArray *theObjects = [[NSMutableArray alloc] init];
            NSMutableDictionary *theDict = [[NSMutableDictionary alloc] init];
            
            NSInteger indexPathPeopleRow = 0;

			//TODO check if array can be passed at once without iteration
            for (NSDictionary* user in resultDict) {
                
                theKeys = [NSMutableArray arrayWithObjects:@"name",@"id",@"photo",@"checked",@"isFriend", nil];
                theObjects = [NSMutableArray arrayWithObjects:[user valueForKey:@"name"],[user valueForKey:@"id"], [[[user valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"], @"NO", @"NO", nil];
                
                theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
				[arrFriend addObject:theDict];
				indexPathPeopleRow++;
            }
            
			NSMutableArray *data = [[NSMutableArray alloc] init];
			for (NSDictionary *people in arrFriend) {
				[data addObject:[people valueForKey:@"id"]];
			}
			
			NSDictionary *facebookIdsDictionary = [[NSDictionary alloc] initWithObjects:data forKeys:data];
			
			userOperation = [ApplicationDelegate.userEngine checkFacebookIds:facebookIdsDictionary onCompletion:^(NSArray *response) {
				
				NSArray *list = [response valueForKey:@"emails"];
				
				for (NSArray *user in list) {
					for (int i =0; i < [user count]; i++) {
						NSString *fullname = [NSString stringWithFormat:@"%@ %@", [[user valueForKey:@"name"] objectAtIndex:i], [[user valueForKey:@"surname"] objectAtIndex:i]];
						
						NSString *email = [NSString stringWithFormat:@"%@", [[user valueForKey:@"email"] objectAtIndex:i]];
						NSString *key = [NSString stringWithFormat:@"%@", [[user valueForKey:@"key"] objectAtIndex:i]];
						NSString *facebookId = [NSString stringWithFormat:@"%@", [[user valueForKey:@"facebookId"] objectAtIndex:i]];
						
						NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name",@"email",@"key",@"checked",@"isFriend", @"id", @"photo", nil];
						NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname,email,key,@"NO",@"NO", facebookId, [[user valueForKey:@"photo"] objectAtIndex:i], nil];
						
						NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
						[arrFacebookFriend addObject:theDict];
						
						for (NSDictionary *data in arrFriend) {
							if ([[data valueForKey:@"id"] isEqualToString:facebookId]) {
								[arrFriend removeObject:data];
								break;
							}
						}
					}
				}
				
				arrNonFacebookFriends = [arrFriend mutableCopy];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadtable" object:nil];
				
			} onError:^(NSError* error) {
			}];
            
        } else {
            //debugLog(@"None of your friends are using the app.");
        }
        
        return;
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [error userInfo]);
    NSLog(@"Err code: %d", [error code]);
    NSLog(@"Err code: %@", [error localizedDescription]);
	
	[HUD hide:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadtable" object:nil];
	
}

-(void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
	
	[HUD hide:YES];
	NSLog(@"Err message: %@", [error userInfo]);
    NSLog(@"Err code: %d", [error code]);
    NSLog(@"Err code: %@", [error localizedDescription]);
}

-(void)dialogCompleteWithUrl:(NSURL *)url {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invites sent!"
													message: nil
												   delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil,nil];
	[alert show];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
	CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	[image drawInRect:imageRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
