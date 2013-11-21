//
//  TileScreenController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileScreenController.h"
#import "CalendarViewController.h"
#import "NewsFeedViewController.h"
#import "MessageFriendListController.h"
#import "FriendsViewController.h"
#import "FriendsViewForCalendarController.h"
#import "SettingsMainPageViewController.h"
#import "LoginViewController.h"
#import "CreateEventViewController.h"
#import "CalendarAgendaViewController.h"
#import "GlobalData.h"
#import "MyProfileViewController.h"
#import "MyEventsViewController.h"
#import "MyGoldEventsViewController.h"
#import "CalSync.h"
#import "Event+Management.h"

@implementation TileScreenController
@synthesize calendarLabel;
@synthesize createEventLabel;
@synthesize myProfileLabel;
@synthesize newsreelLabel;
@synthesize myEventsLabel;
@synthesize settingsLabel;
@synthesize notificationsLabel;
@synthesize myFriendsLabel;
@synthesize friendsCalLabel;
@synthesize versionInfo;
@synthesize backgroundImage;

@synthesize userOperation;

@synthesize btnMessages, btnNewsReel, btnMyEvents;

@synthesize customBadge2, customBadge1, customBadge3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
        
        [[GlobalData sharedGlobalData] setCurrentDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
        [[GlobalData sharedGlobalData] setToday:[[NSDate alloc] initWithTimeIntervalSinceNow:1]];
        [[GlobalData sharedGlobalData] setEventFlag:NO];
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
	
	UIImage* myImage;
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
		myImage = [UIImage imageNamed:@"tilescreen_bg-568h@2x.png"];
	} else {
		myImage = [UIImage imageNamed:@"tilescreen_bg.png"];
	}
	
	[backgroundImage setImage:myImage];
	
    // Do any additional setup after loading the view from its nib.
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tilescreen_bg.jpg"]];
    versionInfo.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    versionInfo.text = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    float tileColorRed = 152.0/255.0;
    float tileColorGreen = 152.0/255.0;
    float tileColorBlue = 152.0/255.0;
    
    friendsCalLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    calendarLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    createEventLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    myProfileLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    newsreelLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    myEventsLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    settingsLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    notificationsLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
    myFriendsLabel.textColor = [[UIColor alloc] initWithRed:tileColorRed green:tileColorGreen blue:tileColorBlue alpha:1.0];
	
	customBadge1 = [CustomBadge customBadgeWithString:@""
									  withStringColor:[UIColor whiteColor]
									   withInsetColor:[UIColor redColor]
									   withBadgeFrame:YES
								  withBadgeFrameColor:[UIColor whiteColor]
											withScale:1.0
										  withShining:YES];
		
	[self.view addSubview:customBadge1];
	customBadge1.hidden = TRUE;
	
	customBadge2 = [CustomBadge customBadgeWithString:@""
									  withStringColor:[UIColor whiteColor]
									   withInsetColor:[UIColor redColor]
									   withBadgeFrame:YES
								  withBadgeFrameColor:[UIColor whiteColor]
											withScale:1.0
										  withShining:YES];
		
	[self.view addSubview:customBadge2];
	customBadge2.hidden = TRUE;
	
	customBadge3 = [CustomBadge customBadgeWithString:@""
									  withStringColor:[UIColor whiteColor]
									   withInsetColor:[UIColor redColor]
									   withBadgeFrame:YES
								  withBadgeFrameColor:[UIColor whiteColor]
											withScale:1.0
										  withShining:YES];
	
	[self.view addSubview:customBadge3];
	customBadge3.hidden = TRUE;
}

-(void)viewWillAppear:(BOOL)animated {
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
	
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    [[GlobalData sharedGlobalData] setCurrentDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
    [[GlobalData sharedGlobalData] setToday:[[NSDate alloc] initWithTimeIntervalSinceNow:1]];
    [[GlobalData sharedGlobalData] setEventFlag:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    //Sync after login
    if ([[GlobalData sharedGlobalData] sync]) {
        //sync with server
        if ([[SingletonUser sharedUserInstance] user])
            [GAEUtils getSyncDataFromGAEFor:[[SingletonUser sharedUserInstance] user]];
        
        [[GlobalData sharedGlobalData] setSync:FALSE];
        [[GlobalData sharedGlobalData] setGetGAEFriends:TRUE];
    }
	
	userOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"unreadMessageCount" onCompletion:^(NSArray *responseData) {
		
		int totalMsg = [[[responseData objectAtIndex:0] valueForKey:@"message"] intValue];
		if (totalMsg > 0) {
			
			[customBadge1 setBadgeText:[NSString stringWithFormat:@"%d", totalMsg]];
			[customBadge1 setNeedsDisplay];
			[customBadge1 setFrame:CGRectMake(btnMessages.frame.size.width-customBadge1.frame.size.width+btnMessages.frame.size.width/2-30, btnMessages.frame.origin.y, customBadge1.frame.size.width, customBadge1.frame.size.height)];
			
			customBadge1.hidden = FALSE;
		} else {
			customBadge1.hidden = TRUE;
		}
		
		
	} onError:^(NSError* error) {
	}];
	
	userOperation = [ApplicationDelegate.invitationEngine requestInvitationsCountOfUser:[[SingletonUser sharedUserInstance] user] onCompletion:^(NSArray *responseData) {
		BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
		if (!isIOS5){
			// Create new SBJSON parser object
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			responseData = [parser objectWithString:(NSString *) responseData];
		}
		
		int totalNotification = [[[responseData objectAtIndex:0] valueForKey:@"Count"] intValue];
		if (totalNotification > 0) {
			
			[customBadge2 setBadgeText:[NSString stringWithFormat:@"%d", totalNotification]];
			[customBadge2 setNeedsDisplay];
			[customBadge2 setFrame:CGRectMake(btnNewsReel.frame.origin.x+btnNewsReel.frame.size.width-customBadge2.frame.size.width/2 - 10, btnNewsReel.frame.origin.y, customBadge2.frame.size.width, customBadge2.frame.size.height)];
			
			customBadge2.hidden = FALSE;
		} else {
			customBadge2.hidden = TRUE;
		}
	
	} onError:^(NSError* error) {

	}];
	
	
	int totalNotification = [[Event getPendingEventsCount:[[SingletonUser sharedUserInstance] user]] intValue];
	if (totalNotification > 0) {
		
		[customBadge3 setBadgeText:[NSString stringWithFormat:@"%d", totalNotification]];
		[customBadge3 setNeedsDisplay];
		[customBadge3 setFrame:CGRectMake(btnMyEvents.frame.origin.x+btnMyEvents.frame.size.width-customBadge3.frame.size.width/2 - 15, btnMyEvents.frame.origin.y, customBadge3.frame.size.width, customBadge3.frame.size.height)];
		
		customBadge3.hidden = FALSE;
	} else {
		customBadge3.hidden = TRUE;
	}
	
	/*userOperation = [ApplicationDelegate.userEngine requestObjectOfUser:[[SingletonUser sharedUserInstance] user] objectType:@"pendingEventCount" onCompletion:^(NSArray *responseData) {
		BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
		if (!isIOS5){
			// Create new SBJSON parser object
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			responseData = [parser objectWithString:(NSString *) responseData];
		}
		
		int totalNotification = [[[responseData objectAtIndex:0] valueForKey:@"count"] intValue];
		if (totalNotification > 0) {
			
			[customBadge3 setBadgeText:[NSString stringWithFormat:@"%d", totalNotification]];
			[customBadge3 setNeedsDisplay];
			[customBadge3 setFrame:CGRectMake(btnMyEvents.frame.origin.x+btnMyEvents.frame.size.width-customBadge3.frame.size.width/2, btnMyEvents.frame.origin.y, customBadge3.frame.size.width, customBadge3.frame.size.height)];
			
			customBadge3.hidden = FALSE;
		} else {
			customBadge3.hidden = TRUE;
		}
		
	} onError:^(NSError* error) {
		
	}];*/

    [super viewDidAppear:animated];
}

- (IBAction)calendarBtnPressed:(id)sender
{
    CalendarAgendaViewController *calendarAgendaViewController = [[CalendarAgendaViewController alloc] initWithNibName:@"CalendarAgendaViewController" bundle:nil];
	
    CalendarViewController *calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarAgendaViewController showToolBar:YES];
	
    [calendarAgendaViewController viewDidAppear:YES];
    
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

- (IBAction)createEventBtnPressed:(id)sender{
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
	
    CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil];
    [self.navigationController pushViewController:createEventViewController animated:YES];
}

- (IBAction)myProfileBtnPressed:(id)sender{
    MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    [self.navigationController pushViewController:myProfileViewController animated:YES];
}

- (IBAction)newsreelBtnPressed:(id)sender{
    NewsfeedViewController *newsfeedViewController = [[NewsfeedViewController alloc] initWithNibName:@"NewsfeedViewController" bundle:nil];
    [self.navigationController pushViewController:newsfeedViewController animated:YES];
}

- (IBAction)messageFriendBtnPressed:(id)sender{
    MessageFriendListController *messageFriendListController = [[MessageFriendListController alloc] initWithNibName:@"MessageFriendListController" bundle:nil];
    [self.navigationController pushViewController:messageFriendListController animated:YES];
}

- (IBAction)myFriendsBtnPressed:(id)sender{
    FriendsViewController *friendsViewController = [[FriendsViewController alloc] initWithNibName:@"FriendsViewController" bundle:nil];
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

- (IBAction)pendingEventsBtnPressed:(id)sender{
    MyEventsViewController *myEventsViewController = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
    [self.navigationController pushViewController:myEventsViewController animated:YES];
}

- (IBAction)settingsBtnPressed:(id)sender{
    SettingsMainPageViewController *settingsMainPageViewController = [[SettingsMainPageViewController alloc] initWithNibName:@"SettingsMainPageViewController" bundle:nil];
    [self.navigationController pushViewController:settingsMainPageViewController animated:YES];
}

- (IBAction)infoBtnPressed:(id)sender{
    SettingsMainPageViewController *settingsMainPageViewController = [[SettingsMainPageViewController alloc] initWithNibName:@"SettingsMainPageViewController" bundle:nil];
    [self.navigationController pushViewController:settingsMainPageViewController animated:YES];
}

- (IBAction)friendCalendarBtnPressed:(id)sender {
	FriendsViewForCalendarController *friendsViewController = [[FriendsViewForCalendarController alloc] initWithNibName:@"FriendsViewForCalendarController" bundle:nil];
    [self.navigationController pushViewController:friendsViewController animated:YES];
}

- (IBAction)goldBtnPressed:(id)sender {
	MyGoldEventsViewController *eventsViewController = [[MyGoldEventsViewController alloc] initWithNibName:@"MyGoldEventsViewController" bundle:nil];
    [self.navigationController pushViewController:eventsViewController animated:YES];
}

- (void)viewDidUnload {
    [self setVersionInfo:nil];
    [self setCalendarLabel:nil];
    [self setCreateEventLabel:nil];
    [self setMyProfileLabel:nil];
    [self setNewsreelLabel:nil];
    [self setMyEventsLabel:nil];
    [self setSettingsLabel:nil];
    [self setNotificationsLabel:nil];
    [self setMyFriendsLabel:nil];
    [self setFriendsCalLabel:nil];
	[self setBtnMessages:nil];
	[self setBtnNewsReel:nil];
	[self setBackgroundImage:nil];
	[self setBtnMyEvents:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end