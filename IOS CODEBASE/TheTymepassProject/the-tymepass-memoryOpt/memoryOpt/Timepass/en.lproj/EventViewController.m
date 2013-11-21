//
//  EventViewController.m
//  Timepass
//
//  Created by Takis Sotiriadis on 21/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "Invitation+Management.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "TTTAttributedLabel.h"
#import "CalendarDayViewController.h"
#import "GlobalData.h"
#import "CreateEventViewController.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "CalSync.h"

enum {
    SectionEventInfo                    = 0,
    SectionEventSettings                = 1,
    SectionEventDetails                 = 2,
    SectionEventInvitees                = 3,
    SectionEventInviteFriends           = 4,
    SectionEventMessageWall             = 5,
    SectionEventReminder                = 6,
    SectionsCount                       = 8
};

enum {
    EventInfoSectionRowsCount               = 1
};

enum {
    EventSettingsSectionAttendaceCell       = 0,
    EventSettingsSectionStealthModeCell     = 1,
    EventSettingsSectionRowsCount           = 2
};

enum {
    EventDetailsSectionRowsCount            = 1
};

enum {
    EventInviteesSectionRowsCount           = 1
};

enum {
    EventInviteFriendsSectionRowsCount      = 1
};

enum {
    EventMessageWallSectionRowsCount        = 1
};

enum {
    EventReminderSectionRowsCount           = 1
};

@implementation EventViewController

@synthesize tableView,eventTitleLabel,eventDescriptionLabel,eventLocationLabel,attendingSegmentControl,stealthModeSegmentControl,viewCalendarBtn,viewAllMessagesBtn,doneBtn,peopleAttendingHeaderView;
@synthesize eventReminderPickerViewController, passedEventReminderSelectedIndex;
@synthesize viewWallTableViewController,messageWallTableViewController;
@synthesize calendarViewController;
@synthesize currentEvent;
@synthesize EventImg;
@synthesize eventOperation;
@synthesize attendeesOperation;
@synthesize messagesOperation;

-(void)initView {
    listOfReminders = [[NSMutableArray alloc] initWithObjects:@"None", @"5 minutes before", @"15 minutes before",@"30 minutes before",@"1 hour before",@"2 hours before",@"1 day before",@"2 days before",@"1 week before",nil];

    attendanceArray = [NSArray arrayWithObjects:@"Yes",@"No",@"Maybe",@"Decide later", nil];
    attendanceValuesArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3], nil];
    attendingOption = [[NSNumber alloc] initWithInt:2];
    
    switchArray = [NSArray arrayWithObjects:@"On",@"Off", nil];
    isInStealthMode = [[NSNumber alloc] initWithInt:1];
    
    pendingChanges = [[NSMutableArray alloc] init];
    
    canInvitePeople = YES;
    if ([currentEvent.isPrivate boolValue])
        canInvitePeople = NO;
    if (![currentEvent.isOpen boolValue])
        canInvitePeople = NO;    
    if ([currentEvent.endTime compare:[NSDate date]] == NSOrderedAscending)
        canInvitePeople = NO;
    
    selectedEventReminderIndex = 0;
    EKEvent *ekevent = [CalSync getIcalEvent:currentEvent];
    
    debugLog(@"Event %@", ekevent.description); 
    
    if ([ekevent alarms]) {
        
        EKAlarm *alarm = [[ekevent alarms] objectAtIndex:0];
        float reminderTime = [alarm relativeOffset];
        debugLog(@"Reminder : %d", (int) reminderTime);
        
        switch ((int)reminderTime * -1) {
            case 0:
                selectedEventReminderIndex = 0;
                break;
            case 60 * 5:
                selectedEventReminderIndex = 1;
                break;
            case 60 * 15:
                selectedEventReminderIndex = 2;
                break;
            case 60 * 30:
                selectedEventReminderIndex = 3;
                break;
            case 60 * 60:
                selectedEventReminderIndex = 4;
                break;
            case 60 * 120:
                selectedEventReminderIndex = 5;
                break;
            case 24 * 60 * 60:
                selectedEventReminderIndex = 6;
                break;
            case 48 * 60 * 60:
                selectedEventReminderIndex = 7;
                break;
            case 7 * 24 * 60 * 60:
                selectedEventReminderIndex = 8;
                break;
                
            default:
                if ((int)reminderTime % 60 == 0){
                    int totalMinutes = -(int)reminderTime / 60;
                    
                    if (totalMinutes == 1)
                        [listOfReminders addObject:[NSString stringWithFormat:@"%d minute before",totalMinutes]];
                    else 
                        if (totalMinutes > 7 * 24 * 60 * 60)
                            [listOfReminders addObject:[NSString stringWithFormat:@"%d weeks before",totalMinutes/7 * 24 * 60 * 60]];
                        else if (totalMinutes > 24 * 60 * 60)
                            [listOfReminders addObject:[NSString stringWithFormat:@"%d days before",totalMinutes/24 * 60 * 60]];
                        else
                            [listOfReminders addObject:[NSString stringWithFormat:@"%d minutes before",totalMinutes]];
                    
                    selectedEventReminderIndex = 9;
                }
                
                break;
                
        }
    }
    
   passedEventReminderSelectedIndex = [[NSNumber alloc] initWithInt:selectedEventReminderIndex];

}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
		[self initView];
    }
    return self;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    if (canInvitePeople)
        scrollViewContentHeight = 1200;
    else 
        scrollViewContentHeight = 1100;
        
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                            style:UIBarButtonItemStyleBordered target:self action:@selector(doneBtnPressed:)];
        
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    viewCalendarBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [viewCalendarBtn setFrame:CGRectMake(self.view.frame.size.width - 150.0, 10.0, 140.0, 29.0)];
    [viewCalendarBtn setBackgroundImage:[UIImage imageNamed:@"view_calendar_btn.png"] forState:UIControlStateNormal];
    [viewCalendarBtn setBackgroundImage:[UIImage imageNamed:@"view_calendar_btn_pressed.png"] forState:UIControlStateHighlighted];
    [viewCalendarBtn addTarget:self action:@selector(viewCalendar:) forControlEvents:UIControlEventTouchUpInside];
    
    viewAllMessagesBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [viewAllMessagesBtn setFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn.png"] forState:UIControlStateNormal];
    [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn_pressed.png"] forState:UIControlStateHighlighted];
    [viewAllMessagesBtn addTarget:self action:@selector(viewAllMessages:) forControlEvents:UIControlEventTouchUpInside];
    [viewAllMessagesBtn setEnabled:TRUE];
    
    doneBtn = [ApplicationDelegate.uiSettings createButton:@"Done"];
    [doneBtn setFrame:CGRectMake(self.view.frame.size.width - 165.0, 15.0, 155.0, 40.0)];
    [doneBtn addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    attendingSegmentControl = [[UISegmentedControl alloc] initWithItems:attendanceArray];
    
    attendingSegmentControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    attendingSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    attendingSegmentControl.frame = CGRectMake(self.view.frame.size.width - 315.0, 23.0, 300.0, 29.0);
    attendingSegmentControl.apportionsSegmentWidthsByContent = YES;

    int attendingValue;
    switch ([currentEvent.attending intValue]) {
        case 0:
            attendingValue = 1;
            break;
        case 1:
            attendingValue = 0;
            break;
        case 2:
            attendingValue = 2;
            break;
        case 3:
            attendingValue = 3;
            break;
        default:
            break;
    }
    
    [attendingSegmentControl setSelectedSegmentIndex:attendingValue];    
    [attendingSegmentControl addTarget:self action:@selector(attendingSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    attendingOption = currentEvent.attending;
    
    stealthModeSegmentControl = [[UISegmentedControl alloc] initWithItems:switchArray];
    [stealthModeSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 121.0, 0.0, 101.0, 29.0)];
    
    stealthModeSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    stealthModeSegmentControl.selectedSegmentIndex = 1;
    
    if ([[currentEvent isStealth] intValue] == 0)
        isInStealthMode = [[NSNumber alloc] initWithInt:1];
    else
        isInStealthMode = [[NSNumber alloc] initWithInt:0];

    stealthModeSegmentControl.selectedSegmentIndex = [isInStealthMode intValue];
    [stealthModeSegmentControl addTarget:self action:@selector(stealthModeSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    viewWholeTitle = FALSE;
    
   
    EventImg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profilepic.png"]];
    [EventImg setFrame:CGRectMake(12.0, 0.0, 85.0, 85.0)];
    EventImg.layer.cornerRadius = 5;
    [EventImg setClipsToBounds: YES];

    if(currentEvent.photo)
    {
        EventImg.image=[UIImage imageWithData:currentEvent.photo];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setEventTitleLabel:nil];
    [self setEventDescriptionLabel:nil];
    [self setEventLocationLabel:nil];
    [self setAttendingSegmentControl:nil];
    [self setStealthModeSegmentControl:nil];
    [self setViewCalendarBtn:nil];
    [self setViewAllMessagesBtn:nil];
    [self setDoneBtn:nil];
    [self setPeopleAttendingHeaderView:nil];
    
    [self setEventReminderPickerViewController:nil];
    [self setPassedEventReminderSelectedIndex:nil];
    [self setViewWallTableViewController:nil];
    [self setMessageWallTableViewController:nil];
    [self setCalendarViewController:nil];
    [self setCurrentEvent:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.title = NSLocalizedString(@"Event", @"Event");
    selectedEventReminderIndex = [passedEventReminderSelectedIndex intValue];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionEventReminder];
    UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.detailTextLabel.text = [listOfReminders objectAtIndex:selectedEventReminderIndex];
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async( dispatch_get_main_queue(), ^{
	
    attendeesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"attendees"
           onCompletion:^(NSArray *responseData) {
               peopleAttending = [NSMutableArray arrayWithArray:[Invitation getAttendees:responseData]];
                
               NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionEventInvitees];
               UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
               
               for (UIView *view in [cell.contentView subviews]) {
                   [view removeFromSuperview];
               }
               
               if ([peopleAttending count] == 0) {
                   cell.accessoryType = UITableViewCellAccessoryNone;
                   
                   cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
                   cell.textLabel.textColor = [UIColor lightGrayColor];
                   
                   cell.textLabel.text = @"No attendees"; 
               } else {
                   //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                   cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                   
                   int numberOfAttendeesShown = peopleAttending.count < 8 ? peopleAttending.count :7;
                   
                   for (int i = 0; i < numberOfAttendeesShown; i++) {
                       NSDictionary *invitee =[peopleAttending objectAtIndex:i];
                       
                       UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profilepic.png"]];
                       
                       if ([invitee valueForKey:@"photo"])
                           imageView.image = [UIImage imageWithData:[invitee valueForKey:@"photo"]];
                       
                       [imageView setFrame:CGRectMake(8.0 + 35.0 * i, 8.0, 31.0, 30.0)];
                       imageView.layer.cornerRadius = 4;
                       [imageView setClipsToBounds: YES];
                       
                       [cell.contentView addSubview:imageView];
                   }
               }
               
               UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
               [headerDetailLabel setFrame:CGRectMake(12.0, 5.0, 300.0, 20.0)];
               if ([peopleAttending count] == 1) {
                   headerDetailLabel.text =  [NSString stringWithFormat:@"%d person attending", [peopleAttending count]];
               } else {
                   headerDetailLabel.text =  [NSString stringWithFormat:@"%d people attending", [peopleAttending count]];
               }
               
               for (UIView *view in [peopleAttendingHeaderView subviews]) {
                   [view removeFromSuperview];
               }
               
               [peopleAttendingHeaderView addSubview:headerDetailLabel];
           } 
           onError:^(NSError* error) {
           }];

    messagesOperation = [ApplicationDelegate.eventEngine requestObjectOfEvent:currentEvent objectType:@"messages"
          onCompletion:^(NSArray *responseData) {
              eventMessages = [NSMutableArray arrayWithArray:[EventMessage getMessages:responseData forEvent:currentEvent]];
               
              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionEventMessageWall];
              UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
              
              for (UIView *view in [cell.contentView subviews]) {
                  [view removeFromSuperview];
              }
              
              UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 210.0)];
              backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"message_wall_shadowed_bg.png"]];
              
              cell.backgroundColor = [UIColor clearColor];
              cell.backgroundView = backView;
              
              messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-1.0, 5.0, backView.frame.size.width - 18.0, backView.frame.size.height - 7.5) messages:eventMessages forEvent:currentEvent];
              
              [cell.contentView addSubview:messageWallTableViewController.view];
              [viewAllMessagesBtn setEnabled:TRUE];
          } 
          onError:^(NSError* error) {
          }];

    });

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self cancelOperations];
    self.title = nil;
    [super viewDidDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if ([item isEqual: self.navigationController.navigationBar.backItem]) {
        if ([pendingChanges count] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Unsaved changes will be lost?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
            
            [alert show];
        }
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Action Methods

// View more & reload section
- (void) headerLabelMoreClicked{
    viewWholeTitle = TRUE;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionEventInfo] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)viewCalendar:(id) sender { 
    CalendarDayViewController *calendarDayViewController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayViewController" bundle:nil];
    
    calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarDayViewController showToolBar:YES]; 
    
    [calendarDayViewController.tdCalendarDayView setCurrentDate:currentEvent.startDate];
    [calendarDayViewController.tdCalendarDayView reloadData];
    
    [calendarDayViewController changeHeaderTitle];
    
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

- (void)viewAllMessages:(id) sender { 
    viewWallTableViewController = [[MessageWallTableViewController alloc] initWithMessages:eventMessages forEvent:currentEvent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController pushViewController:viewWallTableViewController animated:YES];

}

- (void)doneBtnPressed:(id) sender { 
    /*
    if (friendsArray && [friendsArray count] > 0){                                  
        [ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user] ToUsers:friendsArray OfType:@"TymepassEvent" forEvent:[currentEvent serverId]];
    }
    */
    
    if ([pendingChanges count] > 0) {
        
        if (self.eventOperation) {
            [self.eventOperation cancel];
            self.eventOperation = nil;
        }
        
        if (self.attendeesOperation) {
            [self.attendeesOperation cancel];
            self.attendeesOperation = nil;
        }
        
        if (self.messagesOperation) {
            [self.messagesOperation cancel];
            self.messagesOperation = nil;
        }
   
        if ([pendingChanges containsObject:@"attendingStatusChanged"] ||  [pendingChanges containsObject:@"stealthModeChanged"]) {
            HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
            HUD.labelText = @"Saving changes...";
            HUD.dimBackground = YES;

            eventOperation = [ApplicationDelegate.eventEngine changeEvent:currentEvent 
                       ofUser:[[[SingletonUser sharedUserInstance] user] serverId] 
             attendingStatus:attendingOption 
                  stealthMode:isInStealthMode
                 onCompletion:^(NSString *result) {
                     if ([result intValue] != 400) {
                         [currentEvent setAttending:attendingOption];
                         [currentEvent setIsStealth:isInStealthMode];
                         
                         [modelUtils commitDefaultMOC];
                         
                         if (![currentEvent iCalId])  {
                             if ([attendingOption intValue] == 1 || [attendingOption intValue] == 2) {
                                 [currentEvent setICalId:[CalSync saveToICal:currentEvent reminder:900.0f]];
                                 
                                 //Update server event with new iCalId 
                                 [ApplicationDelegate.eventEngine changeICalEvent:currentEvent 
                                                                           ofUser:[[[SingletonUser sharedUserInstance] user] serverId]];
                             }
                         } else {
                             if ([attendingOption intValue] == 0 || [attendingOption intValue] == 3) {
                                 [CalSync removeIcalEvent:currentEvent];
                                 
                                 [currentEvent setICalId:nil];
                                 [modelUtils commitDefaultMOC];
                                 
                                 //Update server event with new iCalId 
                                 [ApplicationDelegate.eventEngine changeICalEvent:currentEvent 
                                                                           ofUser:[[[SingletonUser sharedUserInstance] user] serverId]];
                             }
                         }
                     }
                     
                     [HUD setHidden:YES];
                     [self.navigationController popViewControllerAnimated:YES];
                 } 
                 onError:^(NSError* error) {
                      [HUD setHidden:YES];
                      [self.navigationController popViewControllerAnimated:YES];
                 }];
        }
        
        if ([pendingChanges containsObject:@"eventReminderChanged"]) {
            if ([currentEvent iCalId])  {
                float reminderTime = 0.0f;
                
                switch (selectedEventReminderIndex) {
                    case 0:
                        reminderTime = 0.0f;
                        break;
                    case 1:
                        reminderTime = 60.0 * 5.0f;
                        break;
                    case 2:
                        reminderTime = 60.0f * 15.0f;
                        break;
                    case 3:
                        reminderTime = 60.0f * 30.0f;
                        break;
                    case 4:
                        reminderTime = 60.0f * 60.0f;
                        break;
                    case 5:
                        reminderTime = 60.0f * 120.0f;
                        break;
                    case 6:
                        reminderTime = 24.0f * 60.0f * 60.0f;
                        break;
                    case 7:
                        reminderTime = 48.0f * 60.0f * 60.0f;
                        break;
                    case 8:
                        reminderTime = 7.0f * 24.0f * 60.0f * 60.0f;
                        break;
                    default:
                        break;
                }
                
                [CalSync updateToICal:currentEvent reminder:reminderTime];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else 
        [self.navigationController popViewControllerAnimated:YES];
}

- (void) invitedByClicked {
    //check currentEvent.invitedBy and display profile
    UIViewController *profileController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:currentEvent.invitedBy];
    
    [self.navigationController pushViewController:profileController animated:YES];
}

- (void) createdByClicked {
    UIViewController *profileController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:currentEvent.creatorId];
    
    [self.navigationController pushViewController:profileController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionEventInfo:
            return EventInfoSectionRowsCount;
        case SectionEventSettings:
            return EventSettingsSectionRowsCount;
        case SectionEventDetails:
            return EventDetailsSectionRowsCount;
        case SectionEventInvitees:
            return EventInviteesSectionRowsCount;
        case SectionEventInviteFriends:
            if (canInvitePeople)
                return EventInviteFriendsSectionRowsCount;
            else
                return 0;
        case SectionEventMessageWall:
            return EventMessageWallSectionRowsCount;
        case SectionEventReminder:
            return EventReminderSectionRowsCount;
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
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    
    switch (section) {
        case SectionEventInfo: {   
           //headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_page_header_bg.png"]];
            
            
            [headerLabel setFrame:CGRectMake(12.0, 15.0,  self.view.frame.size.width, 20.0)];
            headerLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:18.0];
            headerLabel.text = [currentEvent title];
            if (viewWholeTitle) {
                headerView.backgroundColor = nil;
                
                [headerLabel setNumberOfLines:0];
                CGRect headerLabelFrame = [headerLabel frame];
                CGSize headerLabelSize = [headerLabel.text        sizeWithFont:headerLabel.font
                                                             constrainedToSize:CGSizeMake(headerLabelFrame.size.width, 9999)
                                                                 lineBreakMode:UILineBreakModeWordWrap];
                
                headerLabelFrame.size.height = headerLabelSize.height;

                [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight + headerLabelFrame.size.height + EventImg.frame.size.height)];

                [headerLabel setFrame:headerLabelFrame];
            }   
            //check if label has been truncated
            CGSize size = [headerLabel.text sizeWithFont:headerLabel.font];
            if (size.width > headerLabel.bounds.size.width && !viewWholeTitle) {
                UILabel *headerLabelMore = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
                [headerLabelMore setFrame:CGRectMake(self.view.frame.size.width - 100.0, 35.0,  88.0, 10.0)];
                headerLabelMore.textColor = [[UIColor alloc] initWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
                headerLabelMore.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:12.0];
                headerLabelMore.text = @"view more";
                headerLabelMore.textAlignment = UITextAlignmentRight;
                headerLabelMore.userInteractionEnabled = true;
                [headerView addSubview:headerLabelMore];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerLabelMoreClicked)];
                [headerView addGestureRecognizer:tap];
                
            }
            
           [EventImg setFrame:CGRectMake(12.0,headerLabel.frame.size.height + 25.0,85.0,85.0)];
            
            UILabel *createdByLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [createdByLabel setFrame:CGRectMake(12.0,EventImg.frame.size.height + 45.0, self.view.frame.size.width / 2, 20.0)];
            createdByLabel.textColor = [[UIColor alloc] initWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
            createdByLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
            createdByLabel.text = @"Event created by";
            
            UILabel *createdBy = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [createdBy setFrame:CGRectMake(12.0,EventImg.frame.size.height + 60.0,  self.view.frame.size.width / 2, 20.0)];
            createdBy.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
            createdBy.userInteractionEnabled = true;
            createdBy.text = [NSString stringWithFormat:@"%@ %@",[[currentEvent creatorId] name], [[currentEvent creatorId] surname]];
            UITapGestureRecognizer *tapCreated = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createdByClicked)];
            [createdBy addGestureRecognizer:tapCreated];
            
            if (currentEvent.invitedBy){
                UILabel *invitedByLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
                [invitedByLabel setFrame:CGRectMake(12.0 +  self.view.frame.size.width / 2,EventImg.frame.size.height + 45.0,  self.view.frame.size.width / 2, 20.0)];
                invitedByLabel.textColor = [[UIColor alloc] initWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
                invitedByLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
                invitedByLabel.text = @"You were invited by";
                
                UILabel *invitedBy = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
                [invitedBy setFrame:CGRectMake(12.0 +  self.view.frame.size.width / 2, EventImg.frame.size.height + 60.0,  self.view.frame.size.width / 2, 20.0)];
                invitedBy.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
                invitedBy.userInteractionEnabled = true;
                invitedBy.text = [NSString stringWithFormat:@"%@ %@", currentEvent.invitedBy.name, currentEvent.invitedBy.surname];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(invitedByClicked)];
                [invitedBy addGestureRecognizer:tap];
                [headerView addSubview:invitedByLabel]; 
                [headerView addSubview:invitedBy]; 
            }
            UILabel *textLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
            [textLabel setFrame:CGRectMake(12.0,createdBy.frame.origin.y +30.0, textLabel.frame.size.width, textLabel.frame.size.height)];
            textLabel.text = @"Is this an Golden event?";
            
            [headerView addSubview:textLabel];
            
            UILabel *openTextLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
            [openTextLabel setFrame:CGRectMake(self.view.frame.size.width - 55.0,createdBy.frame.origin.y +30.0, 35.0, 29.0)];
            openTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:16.0];
            openTextLabel.textAlignment = UITextAlignmentRight;
            
            if ([[currentEvent isGold] intValue] == 0) {
                openTextLabel.textColor = [UIColor redColor];
                openTextLabel.text = @"NO";
            }
            else {
                openTextLabel.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
                openTextLabel.text = @"YES";
            }
            
            [headerView addSubview:openTextLabel];

            [headerView addSubview:EventImg];
            [headerView addSubview:headerLabel]; 
            [headerView addSubview:createdByLabel]; 
            [headerView addSubview:createdBy]; 
        }
            return headerView;
        case SectionEventInvitees: {
            UIView *spinnerView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 5.0, 31.0, 30.0)];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinnerView addSubview:spinner];
            
            [headerView addSubview:spinnerView];
            
            [spinner startAnimating];
            
            headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [headerDetailLabel setFrame:CGRectMake(37.0, 4.0, 300.0, 20.0)];
            headerDetailLabel.text = @"people attending";
            
            [headerView addSubview:headerDetailLabel];
            
            [peopleAttendingHeaderView addSubview:headerDetailLabel];
            
            peopleAttendingHeaderView = headerView;

            return headerView;
        }
        case SectionEventInviteFriends: 
            headerLabel.text =  @"INVITE YOUR FRIENDS TO THIS EVENT";
            if ([currentEvent.isOpen isEqualToNumber:[NSNumber numberWithInt:1]]) {
                headerDetailLabel.text =  @"(This is an open event! Spread the word, pass it on!)";                     
            }
            //headerDetailLabel.text =  @"(This is an open event! Spread the word, pass it on!)";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel]; 
            
            if (canInvitePeople)
                return headerView;
            else
                return nil;
        case SectionEventMessageWall:   
            headerLabel.text =  @"MESSAGE WALL";
            [headerView addSubview:headerLabel];
            
            return headerView;
        case SectionEventReminder: 
            headerLabel.text =  @"REMINDER";
            headerDetailLabel.text = @"(Let us remember for you)";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {  
    UIView *footerView = [[UIView alloc] init];
    if (section == SectionEventInfo) {    
        footerView.backgroundColor = [UIColor lightTextColor];
        
        NSString *text = @"At that time\nyou are FREE";
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(12.0, 9.0, 100.0, 40.0)];
        label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
        label.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 2;
        label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        label.backgroundColor = [UIColor clearColor];
        
        [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange range = [[mutableAttributedString string] rangeOfString:@"FREE" options:NSCaseInsensitiveSearch];
            
            UIColor *color = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
            
            return mutableAttributedString;
        }];
        
        [footerView addSubview:label];        
        [footerView addSubview:viewCalendarBtn];
        return footerView;
    } else if (section == SectionEventMessageWall) {    
        [footerView addSubview:viewAllMessagesBtn];
        return footerView;
    } else if (section == SectionEventReminder) {    
        [footerView addSubview:doneBtn];
        return footerView;
    } 
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionEventInfo) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, -2.0, self.view.frame.size.width, 60.0)];
        backView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:backView];
        
        UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 8.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
        startTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:14.0];
        startTimeLabel.textColor = [UIColor lightGrayColor]; 
        startTimeLabel.backgroundColor = [UIColor clearColor];
        startTimeLabel.text =  @"Start Time";
        
        UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 35.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
        endTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:14.0];
        endTimeLabel.textColor = [UIColor lightGrayColor];
        endTimeLabel.backgroundColor = [UIColor clearColor];
        endTimeLabel.text =  @"End Time";
        
        [cell.contentView addSubview:startTimeLabel]; 
        [cell.contentView addSubview:endTimeLabel]; 
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
        
        /*if ([currentEvent.isAllDay intValue] == 1) {
            [df setDateFormat:@"EEE, dd MMM yyyy"];
        } */
        
        NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
        [dfTime setDateFormat:@"HH:mm"];
        
        NSDate * startTime = currentEvent.startTime;
        NSDate * endTime = currentEvent.endTime;
        
        TTTAttributedLabel *eventStartTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(startTimeLabel.frame.origin.x + startTimeLabel.frame.size.width + 40.0, 5.0, cell.frame.size.width - startTimeLabel.frame.size.width, 40.0)];
        eventStartTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        eventStartTimeLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
        eventStartTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
        eventStartTimeLabel.numberOfLines = 2;
        eventStartTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        eventStartTimeLabel.backgroundColor = [UIColor clearColor];
        
        [eventStartTimeLabel setText:[df stringFromDate:startTime] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange range = [[mutableAttributedString string] rangeOfString:[dfTime stringFromDate:startTime] options:NSCaseInsensitiveSearch];
            
            UIColor *color = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
            
            UIFont *boldSystemFont =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:[ApplicationDelegate.uiSettings cellFontSize]];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
                CFRelease(font);
            }
            
            return mutableAttributedString;
        }];
        
        TTTAttributedLabel *eventEndTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(startTimeLabel.frame.origin.x + startTimeLabel.frame.size.width + 40.0, 32.0, cell.frame.size.width - startTimeLabel.frame.size.width, 40.0)];
        eventEndTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        eventEndTimeLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
        eventEndTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
        eventEndTimeLabel.numberOfLines = 2;
        eventEndTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        eventEndTimeLabel.backgroundColor = [UIColor clearColor];
        
        [eventEndTimeLabel setText:[df stringFromDate:endTime] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange range = [[mutableAttributedString string] rangeOfString:[dfTime stringFromDate:endTime] options:NSCaseInsensitiveSearch];
            
            UIColor *color = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
            
            UIFont *boldSystemFont =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:[ApplicationDelegate.uiSettings cellFontSize]];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            if (font) {
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
                CFRelease(font);
            }
            
            return mutableAttributedString;
        }];
        

        [cell.contentView addSubview:eventStartTimeLabel]; 
        [cell.contentView addSubview:eventEndTimeLabel]; 
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSelected:FALSE];
        [cell setEditing:FALSE];
        
    } else if (indexPath.section == SectionEventSettings) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings headerFont] size:[ApplicationDelegate.uiSettings headerFontSize]];
        cell.textLabel.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings headerColorRed] green:[ApplicationDelegate.uiSettings headerColorGreen] blue:[ApplicationDelegate.uiSettings headerColorBlue] alpha:1.0];
        
        UILabel *textLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [textLabel setFrame:CGRectMake(2.0, -4.0, textLabel.frame.size.width, textLabel.frame.size.height)];
        
        UILabel *detailTextLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
        
        switch (indexPath.row) {
            case EventSettingsSectionAttendaceCell:   
                textLabel.text = @"Are you attending the event?";
                
                [cell.contentView addSubview:textLabel];
                [cell.contentView addSubview:attendingSegmentControl];
                
                break;
            case EventSettingsSectionStealthModeCell:
                textLabel.text = @"Wanna go stealth?";
                
                detailTextLabel.numberOfLines = 3;
                [detailTextLabel setFrame:CGRectMake(2.0, 6.0, detailTextLabel.frame.size.width, detailTextLabel.frame.size.height * detailTextLabel.numberOfLines)];
                detailTextLabel.text = @"(Nobody can see you going,\nexcept for the person\nwho invited you)";
                
                [cell.contentView addSubview:textLabel];
                [cell.contentView addSubview:detailTextLabel];
                [cell.contentView addSubview:stealthModeSegmentControl];
                
                break;
            default:
                break;
        }
        
    } else if (indexPath.section == SectionEventDetails) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CGSize constraintSize = CGSizeMake(cell.frame.size.width  - 10.0, MAXFLOAT);
        CGSize descriptionlabelSize = [[currentEvent info] sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, -2.0, self.view.frame.size.width, 85.0 + descriptionlabelSize.height)];
        backView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:backView];
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 8.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
        locationLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
        locationLabel.textColor = [UIColor lightGrayColor]; 
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.text =  @"Location";
        
        [cell.contentView addSubview:locationLabel]; 
        
        UIImage *locationIcon = [UIImage imageNamed:@"event_location_icon_small.png"];
        UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, locationLabel.frame.origin.y + 20.0, locationIcon.size.width, locationIcon.size.height)];
        locationImageView.image = locationIcon;
        
        [cell addSubview:locationImageView];
        
        UILabel *loc = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
        [loc setFrame:CGRectMake(10.0 + locationImageView.frame.size.width, locationLabel.frame.origin.y + 17.0,  cell.frame.size.width  - 10.0, 20.0)];
        loc.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
        loc.text = currentEvent.locationId.name;
        
        [cell addSubview:loc];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, locationLabel.frame.origin.y + 50.0, 120.0, [ApplicationDelegate.uiSettings cellFontSize])];
        descriptionLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
        descriptionLabel.textColor = [UIColor lightGrayColor];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.text = @"Description";
        
        [cell.contentView addSubview:descriptionLabel]; 
        
        UILabel *descr = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
        [descr setFrame:CGRectMake(0.0, descriptionLabel.frame.origin.y + 15.0, descriptionlabelSize.width, descriptionlabelSize.height)];
        descr.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        descr.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
        descr.lineBreakMode = UILineBreakModeWordWrap;
        descr.baselineAdjustment = UIBaselineAdjustmentNone;
        descr.numberOfLines = 100;
        descr.text = [currentEvent info];
        
        [cell.contentView addSubview:descr];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSelected:FALSE];
        [cell setEditing:FALSE];
        
    } else if (indexPath.section == SectionEventInvitees) {
        if (!peopleAttending) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UIView *spinnerView = [[UIView alloc] initWithFrame:CGRectMake(15.0, 12.0, 31.0, 30.0)];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinnerView addSubview:spinner];
            
            [cell.contentView addSubview:spinnerView];
            
            [spinner startAnimating];
        } 
    } else if (indexPath.section == SectionEventInviteFriends) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"Invite Friends"; 
    } else if (indexPath.section == SectionEventMessageWall) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 15.0f, 20.0f, 20.0f)];
        [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:[cell center]];
        [spinner startAnimating];
        
        [cell.contentView addSubview:spinner];
    } else if (indexPath.section == SectionEventReminder) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        cell.textLabel.text = @"Reminder"; 
        
        cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed] green:[ApplicationDelegate.uiSettings cellDetailColorGreen] blue:[ApplicationDelegate.uiSettings cellDetailColorBlue] alpha:1.0];
        cell.detailTextLabel.text = [listOfReminders objectAtIndex:selectedEventReminderIndex];
        
    }    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    if (section == SectionEventInfo){
        if(viewWholeTitle){
            CGSize headerLabelSize = [currentEvent.title sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:18.0]
                                      
                                                    constrainedToSize:CGSizeMake(self.view.frame.size.width - 24.0, 9999)
                                                        lineBreakMode:UILineBreakModeWordWrap];
            //24.0 is the top and bottom margin
            return (headerLabelSize.height + 64.0);
            
        }
        return 200.0;
    }
    else if (section == SectionEventSettings)
        return 0.0;
    else if (section == SectionEventDetails)
        return 0.0;
    else if (section == SectionEventInvitees)
        return 25.0;
    else if (section == SectionEventMessageWall)
        return 25.0;
    else if (section == SectionEventInviteFriends && ([currentEvent.isPrivate boolValue] || ![currentEvent.isOpen boolValue]))
        return 0.0;

    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { 
    if (section == SectionEventInfo)
        return 52.0;
    else if (section == SectionEventSettings)
        return -10.0;
    else if (section == SectionEventDetails)
        return 0.0;
    else if (section == SectionEventReminder)
        return 80.0;
    else if (section == SectionEventMessageWall)
        return 60.0;
    else if ((section == SectionEventInviteFriends || section == SectionEventInvitees) && ([currentEvent.isPrivate boolValue] || ![currentEvent.isOpen boolValue]))
        return 0.0;
    
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionEventInfo)
        return 58.0;
    else if (indexPath.section == SectionEventSettings) {
        if (indexPath.row == EventSettingsSectionAttendaceCell)
            return 65.0;
        else   
            return 55.0;
    }
    else if (indexPath.section == SectionEventDetails) {
        CGSize constraintSize = CGSizeMake(310.0, MAXFLOAT);
        CGSize descriptionlabelSize = [[currentEvent info] sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return 80.0 + descriptionlabelSize.height;
    }
    else if (indexPath.section == SectionEventInvitees)
        return 48.0;
    else if (indexPath.section == SectionEventMessageWall)
        return 210.0;
    
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [self cancelOperations];
    
    if (indexPath.section == SectionEventReminder) {
        eventReminderPickerViewController = [[EventReminderPickerViewController alloc] initWithNibName:@"EventReminderPickerViewController" bundle:nil];
        
        eventReminderPickerViewController.eventReminderSelectedIndex = [[NSNumber alloc] initWithInt:selectedEventReminderIndex];
        [eventReminderPickerViewController setEventReminderPickerDelegate:self];
        
        [self.navigationController pushViewController:eventReminderPickerViewController animated:YES];
    } else if (indexPath.section == SectionEventInvitees) {
        EventAttendeesViewController *eventAttendeesViewController = [[EventAttendeesViewController alloc] initWithNibName:@"EventAttendeesViewController" bundle:nil attendees:peopleAttending];
        
        [self.navigationController pushViewController:eventAttendeesViewController animated:YES];
    } else if (indexPath.section == SectionEventInviteFriends) {
        InviteFriendsForEventViewController *inviteFriendsForEventViewController = [[InviteFriendsForEventViewController alloc] initWithNibName:@"InviteFriendsForEventViewController" bundle:nil event:currentEvent];
        
        inviteFriendsForEventViewController.friendsToInviteArray = friendsArray;
        inviteFriendsForEventViewController.fbFriendsToInviteArray = fbFriendsArray;
        
        [inviteFriendsForEventViewController setInviteFriendsForEventDelegate:self];
        
        [self.navigationController pushViewController:inviteFriendsForEventViewController animated:YES];
    } 
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) setEventReminder:(NSNumber *)eventReminderSelectedIndex
{
	passedEventReminderSelectedIndex = eventReminderSelectedIndex;
    
    [pendingChanges addObject:@"eventReminderChanged"];
}

-(void)attendingSegmentControlChanged:(id) sender {
    attendingOption = [attendanceValuesArray objectAtIndex:attendingSegmentControl.selectedSegmentIndex];
    //[Event changeAttendingStatusOfUser:[[[SingletonUser sharedUserInstance] user] serverId] toStatus:attendingOption forEvent:currentEvent];
    
    [pendingChanges addObject:@"attendingStatusChanged"];
}

-(void)stealthModeSegmentControlChanged:(id) sender {
    if (stealthModeSegmentControl.selectedSegmentIndex == 0) {
        isInStealthMode = [[NSNumber alloc] initWithInt:1];
    } else {
        isInStealthMode = [[NSNumber alloc] initWithInt:0];
    }
    
    //isInStealthMode = [switchArray objectAtIndex:stealthModeSegmentControl.selectedSegmentIndex];
    //[Event changeStealthModeOfUser:[[[SingletonUser sharedUserInstance] user] serverId] toMode:isInStealthMode forEvent:currentEvent];
    
    [pendingChanges addObject:@"stealthModeChanged"];
}

-(void) setFriends:(NSMutableArray *)afriends {
    friendsArray = afriends;
}

-(void) setFBFriends:(NSMutableArray *)fbFriends {
    fbFriendsArray = fbFriends;
}

- (void) hideKeyboard {
    /*
    if (messageWallTableViewController)
        if ([messageWallTableViewController textView])
            [messageWallTableViewController.textView resignFirstResponder];
    */
}

-(void) cancelOperations {
    if (self.eventOperation) {
        [self.eventOperation cancel];
        self.eventOperation = nil;
    }
    
    if (self.attendeesOperation) {
        [self.attendeesOperation cancel];
        self.attendeesOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
}

@end
