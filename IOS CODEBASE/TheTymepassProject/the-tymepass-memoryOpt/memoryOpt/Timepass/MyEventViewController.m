//
//  MyEventViewController.m
//  Timepass
//
//  Created by mac book pro on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyEventViewController.h"
#import "Invitation+Management.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "TTTAttributedLabel.h"
#import "CalendarDayViewController.h"
#import "GlobalData.h"
#import "NSDataAdditions.h"
#import "CreateEventViewController.h"
#import "User+GAEUser.h"
#import "Utils.h"
#import "CalSync.h"

enum {
    SectionEventInfo                    = 0,
    SectionEventDetails                 = 1,
    SectionEventMessageWall             = 2,
    SectionsCount                       = 3
};

enum {
    EventInfoSectionRowsCount               = 1
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


@implementation MyEventViewController

@synthesize tableView,eventTitleLabel,eventDescriptionLabel,eventLocationLabel,viewCalendarBtn,viewAllMessagesBtn,peopleAttendingHeaderView;
@synthesize viewWallTableViewController,messageWallTableViewController;
@synthesize calendarViewController;
@synthesize currentEvent;
@synthesize EventImg;
@synthesize attendeesOperation;
@synthesize attendeesImagesOperation;
@synthesize messagesOperation;

@synthesize attendingLabel, maybeLabel, reminderBtn, reminderLabel;
@synthesize attendingBtn, maybeBtn, inviteFriendBtn, goldenBtn;
@synthesize openImageView;

@synthesize reminderCustomDate, eventReminderPickerViewController, passedEventReminderSelectedIndex;

-(void)initView {
    switchArray = [NSArray arrayWithObjects:@"On",@"Off", nil];
	
	listOfReminders = [[NSMutableArray alloc] initWithObjects:@"None", @"Custom Time", @"5 minutes before", @"15 minutes before",@"30 minutes before",@"1 hour before",@"2 hours before",@"1 day before",@"2 days before",@"1 week before",nil];
	
	if (currentEvent) {
				
		selectedEventReminderIndex = [currentEvent.reminder intValue];
		
        //get ical event to fetch reminder
        EKEvent *ekevent = [CalSync getIcalEvent:currentEvent];
		if (ekevent != nil) {
			debugLog(@"Event %@", ekevent.description);
			
			if ([ekevent alarms]) {
				
				EKAlarm *alarm = [[ekevent alarms] objectAtIndex:0];
				float reminderTime = [alarm relativeOffset];
				debugLog(@"Reminder : %d", (int) reminderTime);
				
				if (currentEvent.reminderDate != nil) {
					selectedEventReminderIndex = 1;
					self.reminderCustomDate = currentEvent.reminderDate;
				} else {
					switch ((int)reminderTime * -1) {
						case 0:
							selectedEventReminderIndex = 0;
							break;
						case 60 * 5:
							selectedEventReminderIndex = 2;
							break;
						case 60 * 15:
							selectedEventReminderIndex = 3;
							break;
						case 60 * 30:
							selectedEventReminderIndex = 4;
							break;
						case 60 * 60:
							selectedEventReminderIndex = 5;
							break;
						case 60 * 120:
							selectedEventReminderIndex = 6;
							break;
						case 24 * 60 * 60:
							selectedEventReminderIndex = 7;
							break;
						case 48 * 60 * 60:
							selectedEventReminderIndex = 8;
							break;
						case 7 * 24 * 60 * 60:
							selectedEventReminderIndex = 9;
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
								
								selectedEventReminderIndex = 10;
							}
							
							break;
							
					}
				}
				
			} else {
				selectedEventReminderIndex = 0;
			}
		}
	} else {
        selectedEventReminderIndex = 0;
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
    scrollViewContentHeight = 1000;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                              style:UIBarButtonItemStyleBordered target:self action:@selector(editBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    
    viewAllMessagesBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [viewAllMessagesBtn setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn.png"] forState:UIControlStateNormal];
    [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn_pressed.png"] forState:UIControlStateHighlighted];
    [viewAllMessagesBtn addTarget:self action:@selector(viewAllMessages:) forControlEvents:UIControlEventTouchUpInside];
    [viewAllMessagesBtn setEnabled:TRUE];
	
    viewWholeTitle = FALSE;
	
	attendingBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [attendingBtn addTarget:self action:@selector(attendingBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    maybeBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [maybeBtn addTarget:self action:@selector(maybeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    reminderBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [reminderBtn addTarget:self action:@selector(reminderBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    inviteFriendBtn = [ApplicationDelegate.uiSettings createButton:@"Invite your Friends"];
    [inviteFriendBtn addTarget:self action:@selector(inviteFriendBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	isGoldenEvent = (currentEvent) ? [[NSNumber alloc] initWithInt:[currentEvent.isGold intValue]] :[[NSNumber alloc] initWithInt:0];
	
	if ([isGoldenEvent intValue] == 1) {
        [goldenBtn setImage:[UIImage imageNamed:@"event_gold_star.png"] forState:UIControlStateNormal];
        isGolden = 1;
    } else {
        [goldenBtn setImage:[UIImage imageNamed:@"event_gry_star.png"] forState:UIControlStateNormal];
        isGolden = 0;
    }
	
	if ([currentEvent.isOpen intValue] == 1) {
		openImageView.hidden = false;
	}
	
	[self loadImages];
}

- (void)viewDidUnload {
	[self setEventImg:nil];
    [self setTableView:nil];
    [self setEventTitleLabel:nil];
    [self setEventDescriptionLabel:nil];
    [self setEventLocationLabel:nil];
    [self setViewCalendarBtn:nil];
    [self setViewAllMessagesBtn:nil];
    [self setPeopleAttendingHeaderView:nil];
    
    [self setViewWallTableViewController:nil];
    [self setMessageWallTableViewController:nil];
    [self setCalendarViewController:nil];
    [self setCurrentEvent:nil];
    
    [self setOpenImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
	
	self.title = NSLocalizedString(@"Event", @"Event");
    [super viewWillAppear:animated];
	
	selectedEventReminderIndex = [passedEventReminderSelectedIndex intValue];
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async( dispatch_get_main_queue(), ^{
        
        attendeesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"attendeesCount" onCompletion:^(NSArray *responseData) {
			
			NSString *text =  [NSString stringWithFormat:@"ATTENDING (%@)", [[responseData objectAtIndex:0] valueForKey:@"count"]];
			NSString *subText = [NSString stringWithFormat:@"(%@)", [[responseData objectAtIndex:0] valueForKey:@"count"]];
			
			[attendingLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
				NSRange range = [[mutableAttributedString string] rangeOfString:subText options:NSCaseInsensitiveSearch];
				
				UIColor *color = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
				
				[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
				
				return mutableAttributedString;
			}];
			
			
			NSString *text2 =  [NSString stringWithFormat:@"MAYBE (%@)", [[responseData objectAtIndex:0] valueForKey:@"mybecount"]];
			NSString *subText2 = [NSString stringWithFormat:@"(%@)", [[responseData objectAtIndex:0] valueForKey:@"mybecount"]];
			
			[maybeLabel setText:text2 afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
				NSRange range = [[mutableAttributedString string] rangeOfString:subText2 options:NSCaseInsensitiveSearch];
				
				UIColor *color = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
				
				[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
				
				return mutableAttributedString;
			}];
			
		} onError:^(NSError* error) {
		}];

        
        messagesOperation = [ApplicationDelegate.eventEngine requestObjectOfEvent:currentEvent objectType:@"messages" onCompletion:^(NSArray *responseData) {
			eventMessages = [NSMutableArray arrayWithArray:[EventMessage getMessages:responseData forEvent:currentEvent]];
			
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionEventMessageWall];
			UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
			
			for (UIView *view in [cell.contentView subviews]) {
				[view removeFromSuperview];
			}
			
			UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, 0.0, self.view.frame.size.width + 10.0, 210.0)];
			backView.backgroundColor = [UIColor clearColor];
			
			cell.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backView;
			
			messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 0.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5) messages:eventMessages forEvent:currentEvent];
			
			[cell.contentView addSubview:messageWallTableViewController.view];
			[viewAllMessagesBtn setEnabled:TRUE];
		} onError:^(NSError* error) {
		}];
        
    });
    
    canInvitePeople = YES;
    NSLog(@"current event is golden : %@ ",currentEvent.isGold);
    
	EventImg.image = [UIImage imageNamed:@"camera_img.png"];
	
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:EventImg.bounds
												   byRoundingCorners:UIRectCornerBottomRight
														 cornerRadii:CGSizeMake(5.0, 5.0)];
	
	// Create the shape layer and set its path
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.frame = EventImg.bounds;
	maskLayer.path = maskPath.CGPath;
	
	// Set the newly created shape layer as the mask for the image view's layer
	EventImg.layer.mask = maskLayer;
	
    if(currentEvent.photo) {
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:currentEvent.photo]];
		AFImageRequestOperation *operation;
		operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
			[EventImg setImage:image];
		}];
		
		[operation start];
    }
	
    if ([currentEvent.isPrivate boolValue])
        canInvitePeople = NO;
    if ([currentEvent.endTime compare:[NSDate date]] == NSOrderedAscending)
        canInvitePeople = NO;
    
    if (canInvitePeople)
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 1100)];
    else
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 1000)];
    
    [tableView reloadData];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	
	self.title = Nil;
    if (self.attendeesOperation) {
        [self.attendeesOperation cancel];
        self.attendeesOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
    
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

-(IBAction)GoldenEventSegmentChange:(id)sender {
    
    if (isGolden == 0) {
        isGolden=1;
        isGoldenEvent = [NSNumber numberWithInt:1];
        [goldenBtn setImage:[UIImage imageNamed:@"event_gold_star.png"] forState:UIControlStateNormal];
    } else {
		
        isGolden=0;
        isGoldenEvent=[NSNumber numberWithInt:0];
        [goldenBtn setImage:[UIImage imageNamed:@"event_gry_star.png"] forState:UIControlStateNormal];
    }
	
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.labelText = @"Saving...";
	HUD.dimBackground = YES;
	
	attendeesImagesOperation = [ApplicationDelegate.eventEngine changeEvent:currentEvent ofUser:[[[SingletonUser sharedUserInstance] user] serverId] attendingStatus:currentEvent.attending isGold:isGoldenEvent onCompletion:^(NSDictionary *result) {
		
		NSString *resultStr = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"id"]];
		
		if ([resultStr intValue] != 400) {
			
			[currentEvent setIsGold:isGoldenEvent];
			[modelUtils commitDefaultMOC];
		}
		
		[HUD setHidden:YES];
		
	} onError:^(NSError* error) {
		[HUD setHidden:YES];
	}];
}

-(IBAction)attendingBtnPressed:(id)sender {
    
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.labelText = @"Loading...";
	HUD.dimBackground = YES;
	
	attendeesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"attendees" onCompletion:^(NSArray *responseData) {
		
		peopleAttending = [Invitation getAttendees:responseData];
		
		EventAttendeesViewController *eventAttendeesViewController = [[EventAttendeesViewController alloc] initWithNibName:@"EventAttendeesViewController" bundle:nil attendees:peopleAttending];
		
		[self.navigationController pushViewController:eventAttendeesViewController animated:YES];
		
		[HUD hide:YES];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];

}

-(IBAction)maybeBtnPressed:(id)sender {
  
	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.labelText = @"Loading...";
	HUD.dimBackground = YES;
	
	attendeesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"maybe" onCompletion:^(NSArray *responseData) {
		
		peopleAttending = [Invitation getAttendees:responseData];
		
		EventAttendeesViewController *eventAttendeesViewController = [[EventAttendeesViewController alloc] initWithNibName:@"EventAttendeesViewController" bundle:Nil maybe:peopleAttending];
		
		[self.navigationController pushViewController:eventAttendeesViewController animated:YES];
		
		[HUD hide:YES];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
	
}

-(IBAction)reminderBtnPressed:(id)sender {
	
    eventReminderPickerViewController = [[EventReminderPickerViewController alloc] initWithNibName:@"EventReminderPickerViewController" bundle:nil];
	
	eventReminderPickerViewController.eventReminderSelectedIndex = [[NSNumber alloc] initWithInt:selectedEventReminderIndex];
	eventReminderPickerViewController.reminderDate = self.reminderCustomDate;
	[eventReminderPickerViewController setEventReminderPickerDelegate:self];
	
	[self.navigationController pushViewController:eventReminderPickerViewController animated:YES];
}

-(IBAction)inviteFriendBtnPressed:(id)sender {
    
    if (canInvitePeople) {
        FriendsEventInvitationViewController *friendsEventInvitationViewController = [[FriendsEventInvitationViewController alloc] initWithNibName:@"FriendsEventInvitationViewController" bundle:nil fetchFBFriends:false event:currentEvent];
		
		friendsEventInvitationViewController.friendsToInviteArray = friendsArray;
		friendsEventInvitationViewController.fbFriendsToInviteArray = fbFriendsArray;
		friendsEventInvitationViewController.sendInvite = TRUE;
		
		[friendsEventInvitationViewController setFriendsEventInvitationDelegate:self];
		
		[self.navigationController pushViewController:friendsEventInvitationViewController animated:YES];
    }
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

- (void)editBtnPressed:(id) sender {
    if (self.attendeesOperation) {
        [self.attendeesOperation cancel];
        self.attendeesOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
    
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
	
    CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil event:currentEvent];
    [self.navigationController pushViewController:createEventViewController animated:YES];
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

- (void) headerLabelMoreClicked{
    viewWholeTitle = TRUE;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:SectionEventInfo] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)loadImages {
	
	dispatch_async( dispatch_get_main_queue(), ^{
		
		attendeesImagesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"attendeesLimited" onCompletion:^(NSArray *responseData) {
			
			NSArray *listItems = [[responseData objectAtIndex:0] objectForKey:@"users"];
			
			int OriginX = 4;
			int OriginY = 4;
			int imgViewHeight = 44;
			int imgViewWidth = 44;
			
			int i = 0;
			int j = 0;
			int total = 0;
			
			for (NSMutableDictionary *dict in listItems) {
				
				User *user = [User getUserWithId:[dict valueForKey:@"key"] inContext:[[Utils sharedUtilsInstance] scratchPad]];
				
				UIButton *btnImage;
				if (total == 0) {
					btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth, OriginY, imgViewWidth, imgViewHeight)];
				} else {
					btnImage = [[UIButton alloc] initWithFrame:CGRectMake((OriginX+j * imgViewWidth) + j, OriginY, imgViewWidth, imgViewHeight)];
				}
				
				btnImage.tag = [user.serverId intValue];
				
				UIImage* image;
				if ([user.gender intValue] == 0) {
					image = [UIImage imageNamed:@"eve_male.png"];
				} else {
					image = [UIImage imageNamed:@"eve_female.png"];
				}
				[btnImage setImage:image forState:UIControlStateNormal];
				
				if (user.photo) {
					
					NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.photo]];
					AFImageRequestOperation *operation;
					operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
						image = [Utils resizedFromImage:image inPixes:88];
						[btnImage setImage:image forState:UIControlStateNormal];
					}];
					
					[operation start];
				}
				
				[btnImage addTarget:self action:@selector(btnEvenViewPressed:) forControlEvents:UIControlEventTouchUpInside];
				[self.scrollView addSubview:btnImage];
				
				j++;
				
				if (j >= 7 && i == 0) {
					i++;
					j = 0;
					OriginX = 139;
					OriginY += imgViewHeight+2;
				} else if(j >= 4 && i > 0) {
					i++;
					j = 0;
					OriginY += imgViewHeight+2;
				}
				
				total++;
				if (total >= 15) {
					break;
				}
				
			}
			
			while (true) {
				
				if (total >= 15) {
					break;
				}
				
				UIImage* thumbImage = [UIImage imageNamed:@"eve_male.png"];
				if( total % 2 == 0)  {
					thumbImage = [UIImage imageNamed:@"eve_female.png"];
				}
				
				if (total == 0) {
					UIButton *btnImage = [[UIButton alloc] initWithFrame:CGRectMake(OriginX+j * imgViewWidth, OriginY, imgViewWidth, imgViewHeight)];
					[btnImage setImage:thumbImage forState:UIControlStateNormal];
					[self.scrollView addSubview:btnImage];
				} else {
					UIButton *btnImage = [[UIButton alloc] initWithFrame:CGRectMake((OriginX+j * imgViewWidth) + j, OriginY, imgViewWidth, imgViewHeight)];
					[btnImage setImage:thumbImage forState:UIControlStateNormal];
					[self.scrollView addSubview:btnImage];
				}
				
				j++;
				
				if (j >= 7 && i == 0) {
					i++;
					j = 0;
					OriginX = 139;
					OriginY += imgViewHeight+2;
				} else if(j >= 4 && i > 0) {
					i++;
					j = 0;
					OriginY += imgViewHeight+2;
				}
				
				total++;
			}
			
		} onError:^(NSError* error) {
		}];
		
		
	});
}

-(IBAction)btnEvenViewPressed:(id)sender {
	
	User *user = [User getUserWithId:[NSString stringWithFormat:@"%d", [sender tag]] inContext:[[Utils sharedUtilsInstance] scratchPad]];
	
	UIViewController *eventViewController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:user];
	[self.navigationController pushViewController:eventViewController animated:YES];
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
        case SectionEventDetails:
            return EventDetailsSectionRowsCount;
        case SectionEventMessageWall:
            return EventMessageWallSectionRowsCount;
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, self.view.frame.size.width, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    
    switch (section) {
        case SectionEventInfo:
			// headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"event_page_header_bg.png"]];
            [headerLabel setFrame:CGRectMake(12.0, 0.0,  self.view.frame.size.width - 24.0, 20.0)];
            headerLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:18.0];
            headerLabel.text = [currentEvent title];
            
            if (viewWholeTitle) {
                headerView.backgroundColor = nil;
                
                [headerLabel setNumberOfLines:0];
                CGRect headerLabelFrame = [headerLabel frame];
                CGSize headerLabelSize = [headerLabel.text         sizeWithFont:headerLabel.font
															  constrainedToSize:CGSizeMake(headerLabelFrame.size.width, 9999)
																  lineBreakMode:UILineBreakModeWordWrap];
                
                headerLabelFrame.size.height = headerLabelSize.height;
                
                [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight + headerLabelFrame.size.height)];
                
                [headerLabel setFrame:headerLabelFrame];
            }
            
            [headerView addSubview:headerLabel];
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
			
            return headerView;
			
        case SectionEventMessageWall:
            headerLabel.text =  @"MESSAGE WALL";
            [headerView addSubview:headerLabel];
            
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    if (section == SectionEventInfo) {
		
        UILabel *createdByLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
        [createdByLabel setFrame:CGRectMake(12.0, 9.0, 120.0, 20.0)];
        createdByLabel.textColor = [[UIColor alloc] initWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
        createdByLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
        createdByLabel.text = @"Event created by:";
        
        UILabel *createdBy = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
        [createdBy setFrame:CGRectMake(130.0, 9.0,  150.0, 20.0)];
        createdBy.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
        createdBy.userInteractionEnabled = true;
        createdBy.text = [NSString stringWithFormat:@"%@ %@",[[currentEvent creatorId] name], [[currentEvent creatorId] surname]];
        UITapGestureRecognizer *tapCreated = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createdByClicked)];
        [createdBy addGestureRecognizer:tapCreated];
        
        createdBy.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
													 green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
													  blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
													 alpha:1.0];
        
        [footerView addSubview:createdByLabel];
        [footerView addSubview:createdBy];
        return footerView;
    } else if(section == SectionEventDetails) {
		UIView *eventDetailsView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 110.0)];
        
        [attendingBtn setBackgroundImage:[UIImage imageNamed:@"attending_icon.png"] forState:UIControlStateNormal];
		[attendingBtn setBackgroundImage:[UIImage imageNamed:@"attending_icon_pressed.png"] forState:UIControlStateHighlighted];
        [attendingBtn setFrame:CGRectMake(0.0, 14.0, 80.0, 81.0)];
        
        [maybeBtn setBackgroundImage:[UIImage imageNamed:@"maybe_icon.png"] forState:UIControlStateNormal];
		[maybeBtn setBackgroundImage:[UIImage imageNamed:@"maybe_icon_pressed.png"] forState:UIControlStateHighlighted];
        [maybeBtn setFrame:CGRectMake(114, 15.0, 80.0, 81.0)];
        
        [reminderBtn setBackgroundImage:[UIImage imageNamed:@"reminder_icon.png"] forState:UIControlStateNormal];
		[reminderBtn setBackgroundImage:[UIImage imageNamed:@"reminder_icon_pressed.png"] forState:UIControlStateHighlighted];
        [reminderBtn setFrame:CGRectMake(228.0, 15.0, 80.0, 81.0)];
        
        [eventDetailsView addSubview:attendingBtn];
        [eventDetailsView addSubview:maybeBtn];
        [eventDetailsView addSubview:reminderBtn];
        
        attendingLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 80.0, 90.0, 30.0)];
		
		attendingLabel.backgroundColor = [UIColor clearColor];
		attendingLabel.opaque = NO;
		attendingLabel.clearsContextBeforeDrawing = YES;
		attendingLabel.textColor = [UIColor grayColor];
		attendingLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
		attendingLabel.textAlignment = UITextAlignmentCenter;
		
		NSString *text =  [NSString stringWithFormat:@"ATTENDING (%d)", [peopleAttending count]];
		NSString *subText = [NSString stringWithFormat:@"(%d)", [peopleAttending count]];
		
		[attendingLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
			NSRange range = [[mutableAttributedString string] rangeOfString:subText options:NSCaseInsensitiveSearch];
			
			UIColor *color = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
			
			[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
			
			return mutableAttributedString;
		}];
        
        maybeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(114.0, 80.0, 80.0, 30)];
		maybeLabel.backgroundColor = [UIColor clearColor];
		maybeLabel.opaque = NO;
		maybeLabel.clearsContextBeforeDrawing = YES;
		maybeLabel.textColor = [UIColor grayColor];
		maybeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
        maybeLabel.text =  @"MAYBE";
        maybeLabel.textAlignment = UITextAlignmentCenter;
        
        reminderLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
        [reminderLabel setFrame:CGRectMake(228.0, 90.0, 80.0, 30)];
        reminderLabel.text =  @"REMINDER";
        reminderLabel.textAlignment = UITextAlignmentCenter;
        
        [eventDetailsView addSubview:attendingLabel];
        [eventDetailsView addSubview:maybeLabel];
        [eventDetailsView addSubview:reminderLabel];
		
		UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(10.0, 10.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        [footerView addSubview:eventDetailsView];
        
        imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(10.0, 120.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
        if (canInvitePeople) {
			
            [inviteFriendBtn setFrame:CGRectMake(12.0, 121.0, 300.0, 30.0)];
            
            [footerView addSubview:inviteFriendBtn];
            
            UIImageView *imageSeparator2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
            [imageSeparator2 setFrame:CGRectMake(10.0, 158.0, 300.0, 2.0)];
            [footerView addSubview:imageSeparator2];
        }
        
        return footerView;
		
	} else if (section == SectionEventMessageWall) {
        [footerView addSubview:viewAllMessagesBtn];
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
        
        TTTAttributedLabel *eventStartTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(startTimeLabel.frame.origin.x + startTimeLabel.frame.size.width + 40.0, 5.0, cell.frame.size.width - startTimeLabel.frame.size.width - 60, 40.0)];
        eventStartTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        eventStartTimeLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
        eventStartTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
        eventStartTimeLabel.numberOfLines = 2;
        eventStartTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
		eventStartTimeLabel.textAlignment = UITextAlignmentRight;
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
        
        TTTAttributedLabel *eventEndTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(startTimeLabel.frame.origin.x + startTimeLabel.frame.size.width + 40.0, 32.0, cell.frame.size.width - startTimeLabel.frame.size.width - 60, 40.0)];
        eventEndTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        eventEndTimeLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
        eventEndTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
        eventEndTimeLabel.numberOfLines = 2;
        eventEndTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
		eventEndTimeLabel.textAlignment = UITextAlignmentRight;
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
		UIColor *color = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
		loc.textColor = color;
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
        
    } else if (indexPath.section == SectionEventMessageWall) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 15.0f, 20.0f, 20.0f)];
        [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:[cell center]];
        [spinner startAnimating];
        
        [cell.contentView addSubview:spinner];
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	if (section == SectionEventInfo){
        if(viewWholeTitle) {
            CGSize headerLabelSize = [currentEvent.title sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:18.0]
													constrainedToSize:CGSizeMake(self.view.frame.size.width - 24.0, 9999)
                                                        lineBreakMode:UILineBreakModeWordWrap];
            //24.0 is the top and bottom margin
            return (headerLabelSize.height + 20.0);
            
        }
        return 40.0;
    }
    else if (section == SectionEventDetails)
        return 0.0;
    else if (section == SectionEventMessageWall)
        return 20.0;
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	if (section == SectionEventInfo)
        return 30.0;
    else if (section == SectionEventDetails) {
        
        if (canInvitePeople) {
            return 185.0;
        } else {
            return 130.0;
        }
    } else if (section == SectionEventMessageWall)
        return 60.0;
    
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionEventInfo)
        return 58.0;
    else if (indexPath.section == SectionEventDetails) {
        CGSize constraintSize = CGSizeMake(310.0, MAXFLOAT);
        CGSize descriptionlabelSize = [[currentEvent info] sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
        return 80.0 + descriptionlabelSize.height;
    }
    else if (indexPath.section == SectionEventMessageWall)
        return 210.0;
    
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - invite friends delegate
-(void) setFriends:(NSMutableArray *)afriends {
    friendsArray = afriends;
}

-(void) setFBFriends:(NSMutableArray *)fbFriends {
    fbFriendsArray = fbFriends;
}

#pragma mark - friends invite delegate
- (void)setFriends:(NSMutableArray *)friends2 areFBFriends:(BOOL) areFB {
	if (areFB) {
		fbFriendsArray = [NSMutableArray arrayWithArray:friends2];
	} else {
		friendsArray = [NSMutableArray arrayWithArray:friends2];
	}
}

#pragma mark event reminder delegate

- (void)setEventReminder:(NSNumber *)eventReminderSelectedIndex reminderDate:(NSDate *)reminderDate {
	passedEventReminderSelectedIndex = eventReminderSelectedIndex;
	reminderCustomDate = reminderDate;
}

- (void) setEventReminder:(NSNumber *)eventReminderSelectedIndex {
	passedEventReminderSelectedIndex = eventReminderSelectedIndex;
}

- (void) hideKeyboard {
    /*
	 if (messageWallTableViewController)
	 if ([messageWallTableViewController textView])
	 [messageWallTableViewController.textView resignFirstResponder];
     */
}

@end