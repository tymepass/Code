//
//  CreateEventViewController.m
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateEventViewController.h"
#import "UIViewFirstResponder.h"
#import "CalendarMonthViewController.h"
#import "GlobalData.h"
#import "Event+GAE.h"
#import "Validation.h"
#import "Invitation+GAE.h"
#import "EventMessage+GAE.h"
#import "CalendarDayViewController.h"
#import "CalSync.h"
#import "Invitation+Management.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>
#import <Accounts/Accounts.h>

static float stepValue = 1.0;

@implementation CreateEventViewController
@synthesize tableView,eventTitleField,eventDescriptionField,eventLocationField,eventStartTimeLabel,eventEndTimeLabel,eventRecurringField,eventReminderField,allDayEventSegmentControl,viewCalendarBtn,advancedPrivacyBtn,viewAllMessagesBtn,saveEventBtn,privacySlider,stealthModeLabel,stealthModeDetailLabel,standardModeLabel,standardModeDetailLabel,viralModeLabel,viralModeDetailLabel,deleteBtn,goldenBtn,setTimeBtn,setPrivacyBtn,descriptionBtn,locationBtn,reccuranceBtn,reminderBtn, privacySliderView, sendInvitationBtn,descriptionLabel,locationLabel,reccuranceLabel,reminderLabel,privacyStatusLabel;
@synthesize eventRecurringPickerViewController, passedEventRecurringSelectedIndex;
@synthesize eventReminderPickerViewController, passedEventReminderSelectedIndex;
@synthesize eventSetStartEndTimeViewController, passedEventStartTime, passedEventEndTime;
@synthesize calendarViewController, passedEventDate;
@synthesize viewWallTableViewController,messageWallTableViewController;
@synthesize eventPrivacyViewController;
@synthesize friendsArray,fbFriendsArray,privateFromFriendsArray;
@synthesize description;
@synthesize location_name;
@synthesize eventTitle;
@synthesize currentEvent;
@synthesize HUD;
@synthesize doneBtn;

@synthesize recurranceEndDate;

@synthesize eventOperation,strFBpost;
@synthesize messagesOperation;
@synthesize BtnEventImg,btnEventBgImg,ImgEventBG;
@synthesize isEventImageSelection;
@synthesize facebook;

@synthesize reminderCustomDate;

enum {
    SectionEventInfo                    = 0,
    SectionEventStartEndTime            = 1,
    SectionEventPrivacy                 = 2,
    SectionEventDetails                 = 3,
    SectionEventInvitations             = 4,
    SectionEventMessageWall             = 5,
    SectionEventCreate                  = 6,
    SectionsCount                       = 7
};

enum {
    EventDetailSectionRowsCount         = 1
};
enum {
    EventStartEndTimeSectionRowsCount   = 0
};

enum {
    EventReminderSectionRowsCount       = 1
};

enum {
    EventPrivacySectionPrivateCell      = 0,
    EventPrivacySectionRowsCount        = 1
};

enum {
    EventMessageWallSectionRowsCount    = 1
};

enum {
    EventCreateSectionRowsCount         = 0
};

int selectedEventRecurringIndex			= 0;
int selectedEventReminderIndex			= 0;
bool eventDateChanged					= NO;

-(void)initView {
	
	reminderCustomDate = [NSDate date];
	recurranceEndDate = [NSDate date];
	
    eventTitle = @"";
    description = @"";
    location_name = @"";
	
	filepath = [Utils userSettingsPath];
	
	// Build the array from the plist
	settingsDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DoFacebookPost) name:@"DOFacebookPost" object:nil];
    listOfRecurrences = [[NSArray alloc] initWithObjects:@"Never",@"Everyday",@"Every weekday",@"Every week",@"Every 2 weeks",@"Monthly",@"Annually",nil];
    
    selectedEventRecurringIndex = (currentEvent) ? [currentEvent.recurring intValue] : 0;
	passedEventRecurringSelectedIndex = [[NSNumber alloc] initWithInt:selectedEventRecurringIndex];
    
    listOfReminders = [[NSMutableArray alloc] initWithObjects:@"None", @"Custom Time", @"5 minutes before", @"15 minutes before",@"30 minutes before",@"1 hour before",@"2 hours before",@"1 day before",@"2 days before",@"1 week before",nil];
    
    if (currentEvent) {
		
		// set recurrance end date
		if (currentEvent.recurranceEndTime != Nil) {
			recurranceEndDate = currentEvent.recurranceEndTime;
		}
		
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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    [components setMinute:[components minute] - [components minute]%5 + 30];
    passedEventStartTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    passedEventDate = passedEventStartTime;
    
    [components setHour:[components hour] + 1];
    passedEventEndTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    passedEventStartTime = (currentEvent) ? currentEvent.startTime : passedEventStartTime;
    passedEventEndTime = (currentEvent) ? currentEvent.endTime : passedEventEndTime;
    
    allDayValue = (currentEvent) ? [[NSNumber alloc] initWithInt:[currentEvent.isAllDay intValue]] : [[NSNumber alloc] initWithInt:0];
    //debugLog(@"allday: %@", allDayValue);
    isGoldenEvent = (currentEvent) ? [[NSNumber alloc] initWithInt:[currentEvent.isGold intValue]] :[[NSNumber alloc] initWithInt:0];
    
    isPrivate = (currentEvent) ? currentEvent.isPrivate : [[NSNumber alloc] initWithInt:0];
    isOpen = (currentEvent) ? currentEvent.isOpen : [[NSNumber alloc] initWithInt:0];
    //postToFB = [[NSNumber alloc] initWithInt:1];
    
    privateFromFriendsArray = [[NSMutableArray alloc] init];
    
    UIImage *profileImage = [UIImage imageNamed:@"camera_img.png"];
    if (currentEvent.photo) {
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:currentEvent.photo]];
		AFImageRequestOperation *operation;
		operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
			[BtnEventImg setBackgroundImage:image forState:UIControlStateNormal];
		}];
		
		[operation start];
		
    }
    BtnEventImg = [ApplicationDelegate.uiSettings createButton:@""];
    [BtnEventImg addTarget:self action:@selector(AddEventImage:) forControlEvents:UIControlEventTouchUpInside];
    [BtnEventImg setBackgroundImage:profileImage forState:UIControlStateNormal];
    [BtnEventImg setFrame:CGRectMake(1.0, 0.0, 84.0, 84.0)];
    //BtnEventImg.layer.cornerRadius = 5;
    [BtnEventImg setClipsToBounds: YES];
    
    goldenBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [goldenBtn addTarget:self action:@selector(GoldenEventSegmentChange:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([isGoldenEvent intValue] == 1) {
        [goldenBtn setBackgroundImage:[UIImage imageNamed:@"gold_stared_icon2.png"] forState:UIControlStateNormal];
        isGolden = 1;
    } else {
        [goldenBtn setBackgroundImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        isGolden = 0;
    }
    
    setTimeBtn = [ApplicationDelegate.uiSettings createButton:@""];
    // [setTimeBtn addTarget:self action:@selector(setEventStartEndTime:) forControlEvents:UIControlEventTouchUpInside];
    
    setPrivacyBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [setPrivacyBtn addTarget:self action:@selector(privacyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    descriptionBtn = [ApplicationDelegate.uiSettings createButton:@""];
    descriptionBtn.tag = 1;
    [descriptionBtn addTarget:self action:@selector(detailsBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    locationBtn = [ApplicationDelegate.uiSettings createButton:@""];
    locationBtn.tag = 2;
    [locationBtn addTarget:self action:@selector(locationBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    reccuranceBtn = [ApplicationDelegate.uiSettings createButton:@""];
    reccuranceBtn.tag = 3;
    [reccuranceBtn addTarget:self action:@selector(recurringBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	reminderBtn = [ApplicationDelegate.uiSettings createButton:@""];
    reminderBtn.tag = 4;
    [reminderBtn addTarget:self action:@selector(reminderBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    sendInvitationBtn = [ApplicationDelegate.uiSettings createButton:@"Invite your Friends"];
    [sendInvitationBtn addTarget:self action:@selector(sendInvitationBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    privacyStatusLabel =[[UILabel alloc] initWithFrame:CGRectMake(190.0, 20.0, 100.0, [ApplicationDelegate.uiSettings cellFontSize])];
    privacyStatusLabel.textColor = [UIColor grayColor];
    privacyStatusLabel.textAlignment = UITextAlignmentRight;
    privacyStatusLabel.backgroundColor = [UIColor clearColor];
    
    privacySliderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 50.0)];
    privacySliderView.hidden = TRUE;
    
    privacySlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 9.0)];
    
    privacySlider.minimumValue = 0.0;
    privacySlider.maximumValue = 2.0;
    privacySlider.Value = 1.0;
    privacySlider.continuous = NO;
    
    [privacySlider addTarget:self action:@selector(privacySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [privacySliderView addSubview:privacySlider];
    
    // STEALTH
    stealthModeLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    [stealthModeLabel setFrame:CGRectMake(privacySlider.frame.origin.x + 2.0, privacySlider.frame.origin.y + 45.0, 100.0, 12.0)];
    stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                        green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                         blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                        alpha:1.0];
    stealthModeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
    stealthModeLabel.text = @"PRIVATE";
    
    [privacySliderView addSubview:stealthModeLabel];
    
    // STANDARD
    standardModeLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    [standardModeLabel setFrame:CGRectMake(privacySlider.frame.size.width / 2.0 - 30.0, privacySlider.frame.origin.y + 45.0, 100.0, 12.0)];
    standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                         green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                          blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                         alpha:1.0];
    standardModeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
    standardModeLabel.text = @"STANDARD";
    
    [privacySliderView addSubview:standardModeLabel];
    
    // VIRAL
    viralModeLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    [viralModeLabel setFrame:CGRectMake(privacySlider.frame.size.width - 40.0, privacySlider.frame.origin.y + 45.0, 100.0, 12.0)];
    viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                      green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                       blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                      alpha:1.0];
    viralModeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:10.0];
    viralModeLabel.text = @"OPEN";
    
    [privacySliderView addSubview:viralModeLabel];
    
    if (currentEvent) {
        if ([currentEvent.isPrivate isEqualToNumber:[NSNumber numberWithInt:1]]) {
            stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                                green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                                 blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                                alpha:1.0];
            privacyStatusLabel.text = @"PRIVATE";
            privacySlider.Value = 0.0;
        }
        
        else if ([currentEvent.isOpen isEqualToNumber:[NSNumber numberWithInt:1]]) {
            viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                              green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                               blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                              alpha:1.0];
            privacyStatusLabel.text = @"OPEN";
            privacySlider.Value = 2.0;
        } else {
			
			// set some global fields
            standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                                 green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                                  blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                                 alpha:1.0];
            privacyStatusLabel.text = @"STANDARD";
        }
        
        description = currentEvent.info;
        eventTitle = currentEvent.title;
        location_name = currentEvent.locationId.name;
        
        
    } else {
        standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                             green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                              blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                             alpha:1.0];
        privacyStatusLabel.text = @"STANDARD";
    }
    
    eventTitleField = [ApplicationDelegate.uiSettings createCellTextField:215 textHeight:43 placeholder:@"Event title" inputAccessoryView:keyboardToolbar];
    [eventTitleField setTextColor:[[UIColor alloc] initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0]];
    eventTitleField.autocorrectionType = UITextAutocorrectionTypeDefault;
    eventTitleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    eventTitleField.delegate = self;
    eventTitleField.tag = 5000;
    
    [eventTitleField setFrame:CGRectMake(10.0, 0.0, 205.0, 43.0)];
    [eventTitleField setTextColor:[[UIColor alloc] initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0]];
    
    eventDescriptionField = [[UITextView alloc] initWithFrame:CGRectMake(18.0, 95.0, 290.0, 80.0)];
    eventDescriptionField.scrollEnabled = YES;
    eventDescriptionField.textColor = [UIColor grayColor];
    eventDescriptionField.backgroundColor = [UIColor whiteColor];
    eventDescriptionField.inputAccessoryView = keyboardToolbar;
	eventDescriptionField.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:14.0];
    [eventDescriptionField setDelegate:self];
    
    placeholderLabel= [[UILabel alloc]initWithFrame:CGRectMake(6.0, 0.0, eventDescriptionField.frame.size.width, 30.0)];
    placeholderLabel.text = @"Description";
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.textColor = [UIColor lightGrayColor];
    
    if (currentEvent && currentEvent.info && [currentEvent.info length] > 0)
        placeholderLabel.hidden = YES;
    
    [eventDescriptionField addSubview:placeholderLabel];
    eventDescriptionField.hidden = YES;
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil invitee:(User *) aFriend
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        if ([aFriend serverId]) {
            NSString *fullname = [NSString stringWithFormat:@"%@ %@",[aFriend name] ? [aFriend name] : @"", [aFriend surname] ? [aFriend surname] : @""];
			
			__block UIImage *profileImage = [UIImage imageNamed:@"default_profilepic.png"];
			if ([aFriend valueForKey:@"photo"]) {
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[aFriend valueForKey:@"photo"]]];
				AFImageRequestOperation *operation;
				operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
					profileImage = image;
				}];
				
				[operation start];
			}
            
            NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name",@"key",@"photo",@"checked",@"isInvited", nil];
            NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:fullname,[aFriend serverId],profileImage, @"YES", @"YES", nil];
            
            NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
            friendsArray = [NSMutableArray arrayWithObject:theDict];
        }
        
        [self initView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *) event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentEvent = event;
		currentEvent.photoChange = [NSNumber numberWithInt:0];
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 900)];
	
	if (currentEvent) {
		
		if ([currentEvent.recurring intValue] > 0) {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																					  style:UIBarButtonItemStyleBordered target:self action:@selector(askForChanges:)];
		} else {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																					  style:UIBarButtonItemStyleBordered target:self action:@selector(saveEvent:)];
		}
		
	} else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																				  style:UIBarButtonItemStyleBordered target:self action:@selector(saveEvent:)];
	}
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    /*viewCalendarBtn = [ApplicationDelegate.uiSettings createButton:@"View Calendar"];
     [viewCalendarBtn setFrame:CGRectMake(self.view.frame.size.width - 140.0, 2.0, 130.0, 29.0)];
     viewCalendarBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:14.0];
     [viewCalendarBtn addTarget:self action:@selector(viewCalendar:) forControlEvents:UIControlEventTouchUpInside];*/
    
    advancedPrivacyBtn = [ApplicationDelegate.uiSettings createButton:@"Advanced"];
    [advancedPrivacyBtn setFrame:CGRectMake(self.view.frame.size.width - 111.0, 22.0, 101.0, 29.0)];
    advancedPrivacyBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings buttonFont] size:14.0];
    [advancedPrivacyBtn addTarget:self action:@selector(advancedPrivacyBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if([isPrivate isEqualToNumber:[NSNumber numberWithInt:1]]) {
        [advancedPrivacyBtn setEnabled:FALSE];
    }
    if (currentEvent) {
        viewAllMessagesBtn = [ApplicationDelegate.uiSettings createButton:@""];
        [viewAllMessagesBtn setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn.png"] forState:UIControlStateNormal];
        [viewAllMessagesBtn setBackgroundImage:[UIImage imageNamed:@"view_all_messages_btn_pressed.png"] forState:UIControlStateHighlighted];
        [viewAllMessagesBtn addTarget:self action:@selector(viewAllMessages:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewAllMessagesBtn setEnabled:FALSE];
    }
    
    if (currentEvent)
        saveEventBtn = [ApplicationDelegate.uiSettings createButton:@"Save Changes"];
    else
        saveEventBtn = [ApplicationDelegate.uiSettings createButton:@"Save Event"];
    
    [saveEventBtn setFrame:CGRectMake(self.view.frame.size.width - 165.0, -15.0, 155.0, 44.0)];
    [saveEventBtn addTarget:self action:@selector(saveEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    deleteBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [deleteBtn setFrame:CGRectMake(saveEventBtn.frame.origin.x - 55.0, saveEventBtn.frame.origin.y, 45.0, 44.0)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_event_btn.png"] forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_event_btn_h.png"] forState:UIControlStateHighlighted];
    [deleteBtn addTarget:self action:@selector(deleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!currentEvent)
        [deleteBtn setEnabled:FALSE];
	
	doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 150, 50.0, 30.0)];
	doneBtn.titleLabel.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.buttonFont size:13.0];
	[doneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[doneBtn setTitle:@"DONE" forState:UIControlStateNormal];
	
	[doneBtn addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *itemsArray = [NSArray arrayWithObjects:@"On",@"Off", nil];
    
    allDayEventSegmentControl = [[UISegmentedControl alloc] initWithItems:itemsArray];
    [allDayEventSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 111.0, 10.0, 101.0, 29.0)];
    
    allDayEventSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    allDayEventSegmentControl.selectedSegmentIndex = [allDayValue intValue] == 0 ? 1 : 0;
    
    [allDayEventSegmentControl addTarget:self action:@selector(allDayEventSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (currentEvent)
        self.title = NSLocalizedString(@"Edit Event", @"Edit Event");
    else
        self.title = NSLocalizedString(@"Create Event", @"Create Event");
    
	selectedEventRecurringIndex = [passedEventRecurringSelectedIndex intValue];
    selectedEventReminderIndex = [passedEventReminderSelectedIndex intValue];
    startTime = passedEventStartTime;
    endTime = passedEventEndTime;
    
    if (eventDateChanged == YES) {
        NSTimeInterval startInterval = [startTime timeIntervalSinceNow];
        NSTimeInterval endInterval = [endTime timeIntervalSinceNow];
        
        NSTimeInterval diff = endInterval - startInterval;
        
        eventDate = passedEventDate;
        NSDateComponents *comp1 = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:eventDate];
        NSDateComponents *comp2 = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:startTime];
        
        [comp2 setDay:[comp1 day]];
        [comp2 setMonth:[comp1 month]];
        [comp2 setYear:[comp1 year]];
        
        startTime =  [[NSCalendar currentCalendar] dateFromComponents:comp2];
        
        comp1 = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:endTime];
        
        [comp2 setDay:[comp2 day] + roundf(diff / 86400)];
        
        [comp2 setHour:[comp1 hour]];
        [comp2 setMinute:[comp1 minute]];
        
        endTime =  [[NSCalendar currentCalendar] dateFromComponents:comp2];
        
        eventSetStartEndTimeViewController = [[EventSetStartEndTimeViewController alloc] initWithNibName:@"EventSetStartEndTimeViewController" bundle:nil];
        
        eventSetStartEndTimeViewController.eventStartTime = startTime;
        eventSetStartEndTimeViewController.eventEndTime = endTime;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM HH:mm"];
    
    if ([allDayValue intValue] == 1) {
        [df setDateFormat:@"EEE, dd MMM yyyy"];
    }
    
    eventStartTimeLabel.text = [df stringFromDate:startTime];
    eventEndTimeLabel.text = [df stringFromDate:endTime];
    
    /*NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SectionEventReminder];
     UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
     
     cell.detailTextLabel.text = [listOfReminders objectAtIndex:selectedEventReminderIndex];*/
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (currentEvent) {
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
			
			if (currentEvent)
				messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 0.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5) messages:eventMessages forEvent:currentEvent];
			else
				messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 0.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5)];
			
			[cell.contentView addSubview:messageWallTableViewController.view];
			[viewAllMessagesBtn setEnabled:TRUE];
			
		} onError:^(NSError* error) {
		}];
    }
    
	[self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    
    
    if (tableView)
        [self setTableView:nil];
    
    if (eventTitleField)
        [self setEventTitleField:nil];
    
    if (eventDescriptionField)
        [self setEventDescriptionField:nil];
    
    if (eventLocationField)
        [self setEventLocationField:nil];
    
    if (eventStartTimeLabel)
        [self setEventStartTimeLabel:nil];
    
    if (eventEndTimeLabel)
        [self setEventEndTimeLabel:nil];
    
    if (eventRecurringField)
        [self setEventRecurringField:nil];
    
    if (eventReminderField)
        [self setEventReminderField:nil];
    
    if (allDayEventSegmentControl)
        [self setAllDayEventSegmentControl:nil];
    
    //    if (viewCalendarBtn)
    //        [self setViewCalendarBtn:nil];
    
    if (advancedPrivacyBtn)
        [self setAdvancedPrivacyBtn:nil];
    
    if (viewAllMessagesBtn)
        [self setViewAllMessagesBtn:nil];
    
    if (saveEventBtn)
        [self setSaveEventBtn:nil];
    
    if (privacySlider)
        [self setPrivacySlider:nil];
    
    if (stealthModeLabel)
        [self setStealthModeLabel:nil];
    
    if (stealthModeDetailLabel)
        [self setStealthModeDetailLabel:nil];
    
    if (standardModeLabel)
        [self setStandardModeLabel:nil];
    
    if (standardModeDetailLabel)
        [self setStandardModeDetailLabel:nil];
    
    if (viralModeLabel)
        [self setViralModeLabel:nil];
    
    if (viralModeDetailLabel)
        [self setViralModeDetailLabel:nil];
    
    if (passedEventRecurringSelectedIndex)
        [self setPassedEventRecurringSelectedIndex:nil];
    
    if (passedEventStartTime)
        [self setPassedEventStartTime:nil];
    
    if (passedEventEndTime)
        [self setPassedEventEndTime:nil];
    
    if (passedEventDate)
        [self setPassedEventDate:nil];
    
    if (passedEventReminderSelectedIndex)
        [self setPassedEventReminderSelectedIndex:nil];
    
    if (eventRecurringPickerViewController)
        [self setEventRecurringPickerViewController:nil];
    
    if (eventReminderPickerViewController)
        [self setEventReminderPickerViewController:nil];
    
    if (eventSetStartEndTimeViewController)
        [self setEventSetStartEndTimeViewController:nil];
    
    if (calendarViewController)
        [self setCalendarViewController:nil];
    
    if (viewWallTableViewController)
        [self setViewWallTableViewController:nil];
    
    if (messageWallTableViewController)
        [self setMessageWallTableViewController:nil];
    
    if (eventPrivacyViewController)
        [self setEventPrivacyViewController:nil];
    
    if (friendsArray)
        [self setFriendsArray:nil];
    
    if (fbFriendsArray)
        [self setFbFriendsArray:nil];
    
    if (privateFromFriendsArray)
        [self setPrivateFromFriendsArray:nil];
    
    if (currentEvent)
        [self setCurrentEvent:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	
    self.title = Nil;
    
    if (self.eventOperation) {
        [self.eventOperation cancel];
        self.eventOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
	
	[HUD hide:YES];
	
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
	if (HUD)
        [self setHUD:nil];
	
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Actionsheet  Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (actionSheet.tag == 999) {
		if (buttonIndex != actionSheet.cancelButtonIndex) {
			if (buttonIndex == 0) {
				[currentEvent setSaveCurrentEvent:[NSNumber numberWithInt:0]];
			} else {
				[currentEvent setSaveCurrentEvent:[NSNumber numberWithInt:1]];
			}
			[self performSelector:@selector(saveEvent:) withObject:nil afterDelay:0.1];
		}
	} else if (buttonIndex == 0 || buttonIndex == 1) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Camera Not Available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
    }
}

#pragma mark -
#pragma mark Image picker Method
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    
	
    if(isEventImageSelection) {
        UIImage * resizedImage = [Utils resizedFromImage:image inPixes:[ApplicationDelegate.uiSettings profileImagePixels]];
        [BtnEventImg setBackgroundImage:resizedImage forState:UIControlStateNormal];
    } else {
        ImgEventBG = image;
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:ImgEventBG]];
    }
	
	imageChanged = TRUE;
	if (currentEvent) {
		currentEvent.photoChange = [NSNumber numberWithInt:1];
	}
	
    [picker dismissModalViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Action Methods
-(void)AddEventBackgroundImage {
    isEventImageSelection=FALSE;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add a Event Background photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag=2222;
	[popupQuery showInView:self.view];
}

-(IBAction)AddEventImage:(id)sender {
    isEventImageSelection=TRUE;
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Add a Event photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag=1111;
	[popupQuery showInView:self.view];
}

- (void)viewCalendar:(id) sender {
    [[GlobalData sharedGlobalData] setCurrentDate:startTime];
    [[GlobalData sharedGlobalData] setEvent:currentEvent];
    [[GlobalData sharedGlobalData] setEventFlag:YES];
    
    /*
     CalendarMonthViewController *calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil];
     
     calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarDayViewController showToolBar:NO];
     
     //[calendarMonthViewController.tdCalendarView setViewController:calendarViewController];
     
     [calendarViewController setPassEventDateDelegate:self];
     */
    
    CalendarDayViewController *calendarDayViewController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayViewController" bundle:nil];
    
    calendarViewController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil initViewController:calendarDayViewController showToolBar:YES];
    [calendarDayViewController.tdCalendarDayView setCurrentDate:startTime];
    [calendarDayViewController.tdCalendarDayView reloadData];
    
    [calendarDayViewController changeHeaderTitle];
    
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

- (void)advancedPrivacyBtnPressed:(id)sender {
    eventPrivacyViewController = [[EventPrivateViewController alloc] initWithNibName:@"EventPrivateViewController" bundle:nil event:currentEvent];
    
    [eventPrivacyViewController setToStealthFromArray:privateFromFriendsArray];
    [eventPrivacyViewController setEventPrivacyDelegate:self];
    [self.navigationController pushViewController:eventPrivacyViewController animated:YES];
}

-(IBAction)privacyButtonPressed:(id) sender {
    privacySliderView.frame = CGRectMake(50, 60, 250, 50);
    
    float newStep = roundf((privacySlider.value) / stepValue);
    self.privacySlider.value = newStep * stepValue;
    
    
    if (privacySliderView.hidden) {
        privacySliderView.hidden = false;
        privacyStatusLabel.text = @"DONE";
		privacyStatusLabel.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.buttonFont size:13.0];
		
    } else {
        privacySliderView.hidden = true;
        if (privacySlider.value == 0.0) {
            privacyStatusLabel.text = @"PRIVATE";
        }else if (privacySlider.value == 1.0) {
            privacyStatusLabel.text = @"STANDARD";
        } else {
            privacyStatusLabel.text = @"OPEN";
        }
		
		privacyStatusLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    }
    
    [self.tableView reloadData];
}

-(IBAction)sendInvitationBtnPressed:(id)sender {
    FriendsEventInvitationViewController *friendsEventInvitationViewController = [[FriendsEventInvitationViewController alloc] initWithNibName:@"FriendsEventInvitationViewController" bundle:nil];
    
    if (currentEvent) {
        friendsEventInvitationViewController = [[FriendsEventInvitationViewController alloc] initWithNibName:@"FriendsEventInvitationViewController" bundle:nil fetchFBFriends:false event:currentEvent];
    }
    
    friendsEventInvitationViewController.friendsToInviteArray = friendsArray;
    friendsEventInvitationViewController.fbFriendsToInviteArray = fbFriendsArray;
    
    [friendsEventInvitationViewController setFriendsEventInvitationDelegate:self];
    
    [self.navigationController pushViewController:friendsEventInvitationViewController animated:YES];
}

- (void)viewAllMessages:(id) sender {
    viewWallTableViewController = [[MessageWallTableViewController alloc] initWithMessages:eventMessages forEvent:currentEvent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController pushViewController:viewWallTableViewController animated:YES];
}

-(void)askForChanges:(id)sender {
	
	if (selectedEventRecurringIndex != [currentEvent.recurring intValue]) {
		UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"This is a recurring event"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Save Future Events",nil];
		
		actionsheet.tag = 999;
		[actionsheet showInView:self.view];
	} else {
		UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"This is a recurring event"
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Save Future Events", @"Save This Event Only", nil];
		
		actionsheet.tag = 999;
		[actionsheet showInView:self.view];
	}
}

- (void)saveEvent:(id)sender {
	
	if ([eventTitleField canResignFirstResponder]) {
		[eventTitleField resignFirstResponder];
	}
	
    if(![Validation validateText:eventTitle]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
														message:@"You have to set a title."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
        alert.tag = 1000;
		[alert show];
        return;
    }
    
    if (self.eventOperation) {
        [self.eventOperation cancel];
        self.eventOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
    
    if([Validation validateText:eventDescriptionField.text]) {
        
    }
    //get the reminder time
    float reminderTime;
    switch (selectedEventReminderIndex) {
        case 0:
            reminderTime = 0.0f;
            break;
		case 1:
			reminderTime = -1.0f;
			break;
        case 2:
            reminderTime = 60.0 * 5.0f;
            break;
        case 3:
            reminderTime = 60.0f * 15.0f;
            break;
        case 4:
            reminderTime = 60.0f * 30.0f;
            break;
        case 5:
            reminderTime = 60.0f * 60.0f;
            break;
        case 6:
            reminderTime = 60.0f * 120.0f;
            break;
        case 7:
            reminderTime = 24.0f * 60.0f * 60.0f;
            break;
        case 8:
            reminderTime = 48.0f * 60.0f * 60.0f;
            break;
        case 9:
            reminderTime = 7.0f * 24.0f * 60.0f * 60.0f;
            break;
        default:
            break;
    }
    
    
    //if currentEvent is not null we are looking the edit page
    if (currentEvent) {
        //check location
		
		if (imageChanged) {
			currentEvent.photoData = [NSData dataWithData:UIImagePNGRepresentation([BtnEventImg backgroundImageForState:UIControlStateNormal])];
		}
        
        //        UIImage* thumbImage = [Utils resizedFromImage:[changeProfilePhotoBtn backgroundImageForState:UIControlStateNormal] inPixes:[ApplicationDelegate.uiSettings profileThumbImagePixels]];
        //        NSData* thumbImageData = [NSData dataWithData:UIImagePNGRepresentation(thumbImage)];
        
        Location * location = [self updateLocation:location_name];
        NSLog(@"golden %@",isGoldenEvent);
        [Event updateEvent:currentEvent
                 withTitle:eventTitle
                      info:description
                 startTime:startTime
				   endTime:endTime
                    isGold:isGoldenEvent
                     photo:currentEvent.photo
                 recurring:[NSNumber numberWithInt:selectedEventRecurringIndex]
		  recurringEndDate:recurranceEndDate
                  location:location
                  isAllDay:allDayValue
                isEditable:[NSNumber numberWithInt:0]
                 isPrivate:isPrivate
                    isOpen:isOpen
				  reminder:[NSNumber numberWithInt:selectedEventReminderIndex]
			  reminderTime:reminderTime
			  reminderDate:reminderCustomDate];
        
        HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
        HUD.labelText = @"Saving changes...";
        HUD.dimBackground = YES;
        
        eventOperation = [ApplicationDelegate.eventEngine updateGAEEventWithEvent:currentEvent onCompletion:^(NSString *result) {
			if ([result intValue] > 0) {
				
				NSString *parentServerId = currentEvent.parentServerId;
				NSDate *recurEndTime = currentEvent.startTime;
				[currentEvent setParentServerId:nil];
				[modelUtils commitDefaultMOC];
				
				if ([[settingsDictionary valueForKey:@"iCal_sync"] boolValue]) {
					
					// remove old recurrance and then create new recurrance
					if (parentServerId != nil) {
						Event *oldEvent = [Event getEventWithId:parentServerId];
						[oldEvent setRecurranceEndTime:recurEndTime];
						[modelUtils commitDefaultMOC];
						[CalSync updateToICal:oldEvent];
					}
					
					// update original synchronize
					[CalSync updateToICal:currentEvent];
				}
				
				if (friendsArray && [friendsArray count] > 0){
					
					// check if recurring and is the master event then send invitation
					if ([[currentEvent recurring] intValue] > 0 &&
						[[currentEvent parentServerId] intValue] <= 0) {
						[self sendRecurringEventInvitation:currentEvent];
					}
					
					[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user]
																	  ToUsers:friendsArray
																	   OfType:@"TymepassEvent"
																  stealthMode:isPrivate
																	 forEvent:currentEvent.serverId];
				}
			}
			
			//if fb user thn post on fb wall
			
			if ([isOpen isEqualToNumber:[NSNumber numberWithInt:1]] && [isPrivate isEqualToNumber:[NSNumber numberWithInt:0]]) {
				if ([[settingsDictionary valueForKey:@"fCal_sync"] intValue] == 1) {
					strFBpost = [NSString stringWithFormat:@"I am attending the open event %@. To attend, go to www.tymepass.com/download" ,currentEvent.title];
					[self DoFbPost:strFBpost];
				} else {
					[self DoTweet:strFBpost];
				}
			} else {
				
				[HUD setHidden:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}
			
		} onError:^(NSError* error) {
			[modelUtils rollbackDefaultMOC];
			
			[HUD hide:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}];
        
    }
    else {
        //check if location exists
        Location * location = [self updateLocation:location_name];
        //for (EventMessage *message in messageWallTableViewController.eventMessages){
        //
        //}
		
		
		
        //create the event
        NSLog(@"golden %@",isGoldenEvent);
        Event *newEvent = [Event createEventWithTitle:eventTitle
                                                 info:description
                                            startTime:startTime
                                              endTime:endTime
                                               isGold:isGoldenEvent
                                               iCalId:nil
                                            recurring:[NSNumber numberWithInt:selectedEventRecurringIndex]
									 recurringEndDate:recurranceEndDate
                                             serverId:nil
                                                photo:@""
                                           isEditable:[NSNumber numberWithInt:0]
                                             isAllDay:allDayValue
                                            attending:[NSNumber numberWithInt:1]
                                            isPrivate:isPrivate
                                               isOpen:isOpen
									  isTymePassEvent:[NSNumber numberWithInt:1]
                                            messageId: nil
                                           locationId:location
                                              creator:[[SingletonUser sharedUserInstance] user]
                                                 user:[[SingletonUser sharedUserInstance] user]
                                             reminder:[NSNumber numberWithInt:selectedEventReminderIndex]
										 reminderTime:reminderTime
										 reminderDate:reminderCustomDate
                                         dateModified:[NSDate date]
                                          dateCreated:[NSDate date]
                                          invitations:friendsArray
                                        eventMessages:messageWallTableViewController.eventMessages
                                          privateFrom:privateFromFriendsArray
                           ];
		
		if (imageChanged) {
			newEvent.photoData = [NSData dataWithData:UIImagePNGRepresentation([BtnEventImg backgroundImageForState:UIControlStateNormal])];
		}
		
        NSLog(@"user id : %@",[[SingletonUser sharedUserInstance] user]);
        NSLog(@"\n event creator id: %@ event golden %@ event icalid %@",newEvent,newEvent.isGold, newEvent.iCalId);
        HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
        HUD.labelText = @"Saving event...";
        HUD.dimBackground = YES;
        
        eventOperation = [ApplicationDelegate.eventEngine insertGAEEventWithEvent:newEvent onCompletion:^(NSString *serverId) {
			if (![serverId isEqualToString:@"-1"]) {
				[newEvent setServerId:serverId];
				[modelUtils commitDefaultMOC];
				
				//Update iCal Event URL
				[CalSync updateToICal:newEvent];
				
				//NSLog(@"currentEvent %@",[newEvent serverId]);
				
				if (friendsArray && [friendsArray count] > 0){
					
					if ([[newEvent recurring] intValue] > 0) {
						[self sendRecurringEventInvitation:newEvent];
					}
					
					[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user]
																	  ToUsers:friendsArray
																	   OfType:@"TymepassEvent"
																  stealthMode:isPrivate
																	 forEvent:serverId];
					
				}
				
				if (messageWallTableViewController.eventMessages && [messageWallTableViewController.eventMessages count] > 0){
					for (EventMessage *message in messageWallTableViewController.eventMessages) {
						[message setEventId:newEvent];
						[ApplicationDelegate.eventEngine sendMessageToGAE:message];
					}
				}
				
				if (privateFromFriendsArray && [privateFromFriendsArray count] > 0){
					[ApplicationDelegate.eventEngine setEvent:newEvent PrivateFrom:privateFromFriendsArray];
				}
			}
			
			//if fb user thn post on fb wall
			
			if ([isOpen isEqualToNumber:[NSNumber numberWithInt:1]] && [isPrivate isEqualToNumber:[NSNumber numberWithInt:0]]) {
				strFBpost = [NSString stringWithFormat:@"I am attending the open event %@. To attend, go to www.tymepass.com/download" ,newEvent.title];
				if ([[settingsDictionary valueForKey:@"fCal_sync"] intValue] == 1) {
					[self DoFbPost:strFBpost];
					[self DoTweet:strFBpost];
				} else {
					[HUD setHidden:YES];
					[self.navigationController popViewControllerAnimated:YES];
				}
			} else {
				
				[HUD setHidden:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}
			
			
		} onError:^(NSError* error) {
			[modelUtils rollbackDefaultMOC];
			
			[HUD setHidden:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}];
    }
}

-(void)sendRecurringEventInvitation:(Event *)event {
	
	NSArray *events = [Event getChildEvents:event];
	if ([events count] > 0) {
		
		NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
		for (Event *eventObj in events) {
			[eventDict setValue:eventObj.serverId forKey:eventObj.serverId];
		}
		
		[ApplicationDelegate.invitationEngine sendUserInvitesFrom:[[SingletonUser sharedUserInstance] user]
														  ToUsers:friendsArray
														   OfType:@"TymepassEventNoPush"
													  stealthMode:isPrivate
													 forEventDict:eventDict];
	}
}

-(void)DoFbPost:(NSString *)post {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *kAppId = [NSString stringWithFormat:@"%@",[plistData objectForKey:@"FACEBOOK_API_KEY"]];
    facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    
    currentAPICall = kAPIGraphMe;
    
    NSArray *fbPermissions = [[NSArray alloc] initWithObjects:@"offline_access", @"status_update", @"publish_stream",nil];
    NSLog(@"fbpermission array : %@",fbPermissions);
    if ([Utils FBAuthorization:facebook AppId:kAppId]) {
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[facebook accessToken],@"access_token",
                                       post, @"message",
                                       nil];
        NSLog(@"%@",params);
        
        if (![facebook isSessionValid]) {
            [facebook authorize:fbPermissions];
        } else {
            [facebook requestWithGraphPath:@"me/feed"   // or use page ID instead of 'me'
                                 andParams:params
                             andHttpMethod:@"POST"
                               andDelegate:self];
        }
    }
}

-(void)DoTweet:(NSString *)post {
	
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
				
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
															 parameters:[NSDictionary dictionaryWithObject:post forKey:@"status"]
														  requestMethod:TWRequestMethodPOST];
				
				// Set the account used to post the tweet.
				[postRequest setAccount:twitterAccount];
				
				
				[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					dispatch_async(dispatch_get_main_queue(), ^(void) {
						if ([urlResponse statusCode] == 200) {
							
							[HUD hide:YES];
							[self.navigationController popViewControllerAnimated:YES];
							
						}else {
							
							[HUD hide:YES];
							[self.navigationController popViewControllerAnimated:YES];
						}
					});
				}];
				
			}
			else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
			}
		}else{
			[HUD hide:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}];
}

- (IBAction)deleteBtnPressed:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Are you sure you want to delete the event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 1002;
    [alert show];
}

- (Location *) updateLocation:(NSString *) location{
    Location *newLocation = [Location getLocationWithName:location inContext:[modelUtils defaultManagedObjectContext]];
    if (newLocation) {
        //debugLog(@"Location :%@", [newLocation name]);
        return newLocation;
        
    }
    newLocation = (Location *)[Location insertLocationWithName:location inContext:[modelUtils defaultManagedObjectContext]];
    //debugLog(@"Location :%@", [newLocation name]);
    return newLocation;
}

- (IBAction)doneBtnPressed:(id)sender {
	if (sectionForDetails == 1) {
		description = eventDescriptionField.text;
	} else {
		location_name = eventDescriptionField.text;
	}
	
	eventDescriptionField.hidden = TRUE;
	sectionForDetails = 0;
	
	[locationBtn setEnabled:TRUE];
	[descriptionBtn setEnabled:TRUE];
	[reccuranceBtn setEnabled:TRUE];
	[reminderBtn setEnabled:TRUE];
	
	[self.tableView reloadData];
}

-(IBAction)detailsBtnPressed:(id)sender {
    
	if ([description isEqualToString:@""] == FALSE && currentEvent) {
		description = currentEvent.info;
	}
	
	eventDescriptionField.hidden = FALSE;
	placeholderLabel.text = @"Description";
	eventDescriptionField.text = description;
	sectionForDetails = 1;
	
	if ([description isEqualToString:@""] == FALSE) {
		placeholderLabel.hidden = YES;
	}
	
	[locationBtn setEnabled:FALSE];
	[reccuranceBtn setEnabled:FALSE];
	[reminderBtn setEnabled:FALSE];
	
	[self.tableView reloadData];
}

-(IBAction)locationBtnPressed:(id)sender {
	
	if ([location_name isEqualToString:@""] == FALSE && currentEvent) {
		location_name = currentEvent.locationId.name;
	}
	
	eventDescriptionField.text = location_name;
	eventDescriptionField.hidden = FALSE;
	sectionForDetails = 2;
	placeholderLabel.text = @"Location";
	
	if ([location_name isEqualToString:@""] == FALSE) {
		placeholderLabel.hidden = YES;
	}
	
	[descriptionBtn setEnabled:FALSE];
	[reccuranceBtn setEnabled:FALSE];
	[reminderBtn setEnabled:FALSE];
	
	[self.tableView reloadData];
	
}

-(IBAction)recurringBtnPressed:(id)sender {
	
	eventRecurringPickerViewController = [[EventRecurringPickerViewController alloc] initWithNibName:@"EventRecurringPickerViewController" bundle:nil];
	
	eventRecurringPickerViewController.eventRecurringSelectedIndex = [[NSNumber alloc]
																	  initWithInt:selectedEventRecurringIndex];
	eventRecurringPickerViewController.recurranceDate = recurranceEndDate;
	eventRecurringPickerViewController.eventStartDate = startTime;
	[eventRecurringPickerViewController setEventRecurringPickerDelegate:self];
	[self.navigationController pushViewController:eventRecurringPickerViewController animated:YES];
	
}

-(IBAction)reminderBtnPressed:(id)sender {
	
	eventReminderPickerViewController = [[EventReminderPickerViewController alloc] initWithNibName:@"EventReminderPickerViewController" bundle:nil];
	
	eventReminderPickerViewController.eventReminderSelectedIndex = [[NSNumber alloc] initWithInt:selectedEventReminderIndex];
	eventReminderPickerViewController.reminderDate = self.reminderCustomDate;
	[eventReminderPickerViewController setEventReminderPickerDelegate:self];
	
	[self.navigationController pushViewController:eventReminderPickerViewController animated:YES];
	
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionEventPrivacy: {
			
			if ([description isEqualToString:@""] && [location_name isEqualToString:@""] && selectedEventRecurringIndex <= 0 && selectedEventReminderIndex <= 0) {
                return 0;
            }
            
            return EventDetailSectionRowsCount;
		}
        case SectionEventMessageWall:
            return EventMessageWallSectionRowsCount;
        case SectionEventCreate:
            return EventCreateSectionRowsCount;
        default:
            break;
    }
    return 0;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 10.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
	UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 30.0, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
    
    switch (section) {
        case SectionEventInfo:  {
            
            [headerView addSubview:BtnEventImg];
            eventTitleField.text = (currentEvent) ? currentEvent.title : eventTitle;
			if ([eventTitle isEqualToString:@""] == FALSE) {
				eventTitleField.text = eventTitle;
			}
            
            UIView *eventTitleView = [[UIView alloc] initWithFrame: CGRectMake(100.0, 43.0, 215.0, 43.0)];
            UIImageView *eventTitleBg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 215.0, 43.0)];
            [eventTitleBg setImage:[UIImage imageNamed:@"event_title_bg.png"]];
            
            [eventTitleView addSubview:eventTitleBg];
            [eventTitleView addSubview:eventTitleField];
            
            // adding star button to the screen
            [goldenBtn setFrame:CGRectMake(self.tableView.frame.size.width - 50.0, 0.0, 34.0, 34.0)];
            [headerView addSubview:goldenBtn];
            
            [headerView addSubview:eventTitleView];
            return headerView;
        }
			
        case SectionEventStartEndTime: {
            // adding set time button to the screen
			
			UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_time_bg.png"]];
			backgroundImage.frame = CGRectMake(19.0, 0.0, 301.0, 51.0);
			[headerView addSubview:backgroundImage];
			
            [setTimeBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [setTimeBtn setFrame:CGRectMake(19.0, 0.0, 301.0, 51.0)];
            
            [setTimeBtn addTarget:self action:@selector(setEventStartEndDate:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *setTimeView = [[UIView alloc] initWithFrame: CGRectMake(self.tableView.frame.size.width - 301.0, 0.0, 301.0, 51.0)];
			
            startTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            startTimeLabel.textColor = [UIColor grayColor];
            startTimeLabel.backgroundColor = [UIColor clearColor];
            startTimeLabel.text =  @"Start";
			
			endTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
            endTimeLabel.textColor = [UIColor grayColor];
            endTimeLabel.backgroundColor = [UIColor clearColor];
            endTimeLabel.text =  @"End";
            
            [setTimeView addSubview:startTimeLabel];
			[setTimeView addSubview:endTimeLabel];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE, dd MMM HH:mm"];
            
            if ([allDayValue intValue] == 1) {
                [df setDateFormat:@"EEE, dd MMM"];
            }
            
            UIView *eventTimeView = [[UIView alloc] initWithFrame:CGRectMake(startTimeLabel.frame.origin.x + startTimeLabel.frame.size.width, 10.0, 290.0 - startTimeLabel.frame.size.width - 70.0, 40)];
			
			NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
			[dfTime setDateFormat:@"HH:mm"];
			
			TTTAttributedLabel *eventStartTimeLabel1 = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, -5.0, 155, 25.0)];
			eventStartTimeLabel1.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
			eventStartTimeLabel1.textColor = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
			
			eventStartTimeLabel1.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
			eventStartTimeLabel1.backgroundColor = [UIColor clearColor];
			eventStartTimeLabel1.textAlignment = UITextAlignmentRight;
			
			[eventStartTimeLabel1 setText:[df stringFromDate:startTime] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
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
			
			for (UIView *subview in [eventTimeView subviews]) {
				[subview removeFromSuperview];
			}
			
			[eventTimeView addSubview:eventStartTimeLabel1];
			
			TTTAttributedLabel *eventEndTimeLabel1 = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 15.0, 155, 25.0)];
			eventEndTimeLabel1.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
			eventEndTimeLabel1.textColor = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
			
			eventEndTimeLabel1.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
			eventEndTimeLabel1.backgroundColor = [UIColor clearColor];
			eventEndTimeLabel1.textAlignment = UITextAlignmentRight;
			
			[eventEndTimeLabel1 setText:[df stringFromDate:endTime] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
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
			
			[eventTimeView addSubview:eventEndTimeLabel1];
            [setTimeView addSubview:eventTimeView];
			[setTimeView addSubview:setTimeBtn];
            [headerView addSubview:setTimeView];
            
            return headerView;
        }
            
        case SectionEventPrivacy: {
			
            // adding set Privacy button to the screen
            [setPrivacyBtn setBackgroundImage:[UIImage imageNamed:@"set_privacy_bg.png"] forState:UIControlStateNormal];
            [setPrivacyBtn setFrame:CGRectMake(0.0, 0.0, 301.0, 51.0)];
            
            UIView *setPrivacyView = [[UIView alloc] initWithFrame: CGRectMake(self.tableView.frame.size.width - 301.0, 0.0, 301.0, 51.0)];
            UILabel *privacyLabel =[[UILabel alloc] initWithFrame:CGRectMake(60.0, 20.0, 100.0, [ApplicationDelegate.uiSettings cellFontSize])];
            
            privacyLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
            privacyLabel.textColor = [[UIColor alloc]  initWithRed:41.0/255.0 green:171.0/255.0 blue:225.0/255.0 alpha:1.0];
            privacyLabel.backgroundColor = [UIColor clearColor];
            privacyLabel.text =  @"Set privacy";
            
            [setPrivacyView addSubview:setPrivacyBtn];
            [setPrivacyView addSubview:privacyLabel];
            [setPrivacyView addSubview:privacyStatusLabel];
            
            [headerView addSubview:setPrivacyView];
			privacyStatusLabel.textColor = [UIColor grayColor];
            
            if (!privacySliderView.hidden) {
                headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height + 60);
                privacyStatusLabel.frame = CGRectMake(180.0, 20.0, 100.0, [ApplicationDelegate.uiSettings cellFontSize]);
                privacyStatusLabel.text =  @"DONE";
				privacyStatusLabel.textColor = [UIColor lightGrayColor];
                [setPrivacyBtn setFrame:CGRectMake(0.0, 0.0, 291.0, 51.0)];
                [setPrivacyBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                setPrivacyView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"serpr_bg.png"]];
                setPrivacyView.frame = CGRectMake(self.tableView.frame.size.width - 301.0, 0.0, 291.0, 130.0);
            }
            
            
            [headerView addSubview:privacySliderView];
            return headerView;
        }
			
        case SectionEventDetails: {
            UIView *eventDetailsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 100.0)];
            
            [descriptionBtn setBackgroundImage:[UIImage imageNamed:@"discr_icon.png"] forState:UIControlStateNormal];
			[descriptionBtn setBackgroundImage:[UIImage imageNamed:@"discr_icon_hov.png"] forState:UIControlStateHighlighted];
            [descriptionBtn setFrame:CGRectMake(13.0, 0.0, 70.0, 70.0)];
            
            [locationBtn setBackgroundImage:[UIImage imageNamed:@"locn_icon.png"] forState:UIControlStateNormal];
			[locationBtn setBackgroundImage:[UIImage imageNamed:@"locn_icon_hov.png"] forState:UIControlStateHighlighted];
            [locationBtn setFrame:CGRectMake(87.0, 0.0, 70.0, 70.0)];
            
            [reccuranceBtn setBackgroundImage:[UIImage imageNamed:@"reccu_icon.png"] forState:UIControlStateNormal];
			[reccuranceBtn setBackgroundImage:[UIImage imageNamed:@"reccu_icon_hov.png"] forState:UIControlStateHighlighted];
            [reccuranceBtn setFrame:CGRectMake(163.0, 0.0, 70.0, 70.0)];
            
            [reminderBtn setBackgroundImage:[UIImage imageNamed:@"remindr_icon.png"] forState:UIControlStateNormal];
			[reminderBtn setBackgroundImage:[UIImage imageNamed:@"remindr_icon_hov.png"] forState:UIControlStateHighlighted];
            [reminderBtn setFrame:CGRectMake(240.0, 0.0, 70.0, 70.0)];
            
            [eventDetailsView addSubview:descriptionBtn];
            [eventDetailsView addSubview:locationBtn];
            [eventDetailsView addSubview:reccuranceBtn];
            [eventDetailsView addSubview:reminderBtn];
			
            descriptionLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
            descriptionLabel.text =  @"DESCRIPTION";
			descriptionLabel.textAlignment = UITextAlignmentCenter;
			[descriptionLabel setFrame:CGRectMake(13.0, 75.0, 70.0, 20.0)];
            
            locationLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
            [locationLabel setFrame:CGRectMake(87.0, 75.0, 70.0, 20.0)];
			locationLabel.textAlignment = UITextAlignmentCenter;
            locationLabel.text =  @"LOCATION";
            
            reccuranceLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
			[reccuranceLabel setFrame:CGRectMake(160.0, 75.0, 76.0, 20.0)];
			reccuranceLabel.textAlignment = UITextAlignmentCenter;
            reccuranceLabel.text =  @"RECCURANCE";
            
            reminderLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
            [reminderLabel setFrame:CGRectMake(239.0, 75.0, 70.0, 20.0)];
			reminderLabel.textAlignment = UITextAlignmentCenter;
            reminderLabel.text =  @"REMINDER";
            
            [eventDetailsView addSubview:descriptionLabel];
            [eventDetailsView addSubview:locationLabel];
            [eventDetailsView addSubview:reccuranceLabel];
            [eventDetailsView addSubview:reminderLabel];
            
            [headerView addSubview:eventDetailsView];
            
            if (eventDescriptionField.hidden) {
                
                UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, eventDescriptionField.frame.origin.y, self.view.frame.size.width, 0.0)];
                backView.backgroundColor = [UIColor whiteColor];
                [headerView addSubview:backView];
                
            } else {
                
                UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, eventDescriptionField.frame.origin.y, self.view.frame.size.width, 80.0)];
                backView.backgroundColor = [UIColor whiteColor];
                [headerView addSubview:backView];
                
                if (sectionForDetails == 2) {
                    UIImage *locationIcon = [UIImage imageNamed:@"event_location_icon_small.png"];
                    UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, eventDescriptionField.frame.origin.y + 10.0, locationIcon.size.width, locationIcon.size.height)];
                    locationImageView.image = locationIcon;
                    
                    [headerView addSubview:locationImageView];
                }
            }
            
            [headerView addSubview:eventDescriptionField];
			
			if (!eventDescriptionField.hidden) {
				[eventDescriptionField becomeFirstResponder];
				[headerView addSubview:doneBtn];
				[headerView bringSubviewToFront:doneBtn];
			} else {
				[eventDescriptionField resignFirstResponder];
			}
            
            return headerView;
        }
        case SectionEventInvitations: {
            
			UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
			[imageSeparator setFrame:CGRectMake(10.0, 0.0, 300.0, 2.0)];
			[headerView addSubview:imageSeparator];
			
            sendInvitationBtn.frame = CGRectMake(12.0, 10.0, 300.0, 30.0);
            [headerView addSubview:sendInvitationBtn];
			
			UIImageView *imageSeparator2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
			[imageSeparator2 setFrame:CGRectMake(10.0, 48.0, 300.0, 2.0)];
			[headerView addSubview:imageSeparator2];
            
            return headerView;
		}
        default:
            break;
    }
    
    return nil;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
	
    if (currentEvent && section == SectionEventMessageWall) {
        [footerView addSubview:viewAllMessagesBtn];
        
        return footerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == SectionEventPrivacy) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        CGSize descriptionlabelSize = CGRectZero.size;
		cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        if([description isEqualToString:@""] == FALSE) {
            CGSize constraintSize = CGSizeMake(cell.frame.size.width  - 10.0, MAXFLOAT);
            descriptionlabelSize = [description sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        }
        
        int height = 10;
		
		if ([location_name isEqualToString:@""] == FALSE) {
			height += 40;
		} if([description isEqualToString:@""] == FALSE) {
            height += 40;
        } if (selectedEventReminderIndex > 0) {
            height += 40;
        } if (selectedEventRecurringIndex > 0) {
            height += 40;
        }
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, 10.0, self.view.frame.size.width, height + descriptionlabelSize.height + 2)];
        backView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:backView];
        
        int y = 18.0;
        
        if([description isEqualToString:@""] == FALSE) {
            
            UILabel *descriptionLabelCell = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y, 120.0, [ApplicationDelegate.uiSettings cellFontSize])];
            descriptionLabelCell.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
            descriptionLabelCell.textColor = [UIColor grayColor];
            descriptionLabelCell.backgroundColor = [UIColor clearColor];
            descriptionLabelCell.text = @"Description";
            
            [cell.contentView addSubview:descriptionLabelCell];
            
            UILabel *descr = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [descr setFrame:CGRectMake(0.0, descriptionLabelCell.frame.origin.y + 15.0, descriptionlabelSize.width, descriptionlabelSize.height)];
            descr.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            descr.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
            descr.lineBreakMode = UILineBreakModeWordWrap;
            descr.baselineAdjustment = UIBaselineAdjustmentNone;
            descr.numberOfLines = 100;
            descr.text = description;
            
            [cell.contentView addSubview:descr];
            y = y + descriptionlabelSize.height + 23.0;
        }
        
        if([location_name isEqualToString:@""] == FALSE) {
            
            UILabel *locationLabelCell = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
            locationLabelCell.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
            locationLabelCell.textColor = [UIColor grayColor];
            locationLabelCell.backgroundColor = [UIColor clearColor];
            locationLabelCell.text =  @"Location";
            
            [cell.contentView addSubview:locationLabelCell];
            
            UIImage *locationIcon = [UIImage imageNamed:@"event_location_icon_small.png"];
            UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, locationLabelCell.frame.origin.y + 20.0, locationIcon.size.width, locationIcon.size.height)];
            locationImageView.image = locationIcon;
            
            [cell addSubview:locationImageView];
            
            UILabel *loc = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [loc setFrame:CGRectMake(10.0 + locationImageView.frame.size.width, y + 17.0,  cell.frame.size.width  - 10.0, 20.0)];
            loc.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
            loc.text = location_name;
            loc.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                            green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                             blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                            alpha:1.0];
            
            [cell addSubview:loc];
            
            y += 50.0;
        }
        
        if (selectedEventRecurringIndex > 0) {
            UILabel *recurringLabelCell = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
            recurringLabelCell.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
            recurringLabelCell.textColor = [UIColor grayColor];
            recurringLabelCell.backgroundColor = [UIColor clearColor];
            recurringLabelCell.text =  @"Recurrance";
            
            [cell.contentView addSubview:recurringLabelCell];
            
            UIImage *recurringIcon = [UIImage imageNamed:@"repeat_icon.png"];
            UIImageView *recurringImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, recurringLabelCell.frame.origin.y + 20.0, recurringIcon.size.width, recurringIcon.size.height)];
            recurringImageView.image = recurringIcon;
            
            [cell addSubview:recurringImageView];
            
            UILabel *recur = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [recur setFrame:CGRectMake(10.0 + recurringImageView.frame.size.width, y + 17.0,  cell.frame.size.width  - 10.0, 20.0)];
            recur.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
            recur.text = [listOfRecurrences objectAtIndex:selectedEventRecurringIndex];
            recur.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                              green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                               blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                              alpha:1.0];
            
            [cell addSubview:recur];
            
            y += 50.0;
        }
        
        if (selectedEventReminderIndex > 0) {
            
            UILabel *reminderLabelCell = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y, 80.0, [ApplicationDelegate.uiSettings cellFontSize])];
            reminderLabelCell.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:14.0];
            reminderLabelCell.textColor = [UIColor grayColor];
            reminderLabelCell.backgroundColor = [UIColor clearColor];
            reminderLabelCell.text =  @"Reminder";
            
            [cell.contentView addSubview:reminderLabelCell];
            
            UIImage *reminderIcon = [UIImage imageNamed:@"watch_icon.png"];
            UIImageView *reminderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, reminderLabelCell.frame.origin.y + 20.0, reminderIcon.size.width, reminderIcon.size.height)];
            reminderImageView.image = reminderIcon;
            
            [cell addSubview:reminderImageView];
            
            UILabel *rem = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
            [rem setFrame:CGRectMake(10.0 + reminderImageView.frame.size.width, y + 17.0,  cell.frame.size.width  - 10.0, 20.0)];
            rem.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:14.0];
			
			if (selectedEventReminderIndex == 1) {
				NSDateFormatter *df = [[NSDateFormatter alloc] init];
				[df setDateFormat:@"EEE, dd MMM HH:mm"];
				rem.text = [df stringFromDate:reminderCustomDate];
				
			} else {
				rem.text = [listOfReminders objectAtIndex:selectedEventReminderIndex];
			}
			
            rem.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                            green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                             blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                            alpha:1.0];
            
            [cell addSubview:rem];
            
            y += 50.0;
        }
		
		[backView setFrame:CGRectMake(backView.frame.origin.x, backView.frame.origin.y, backView.frame.size.width, y - 15)];
		
		UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
		[imageSeparator setFrame:CGRectMake(10.0, backView.frame.origin.y + backView.frame.size.height + 10 , 300.0, 2.0)];
		[cell addSubview:imageSeparator];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setSelected:FALSE];
        [cell setEditing:FALSE];
		
    } else if (indexPath.section == SectionEventMessageWall) {
		if (currentEvent) {
			
			if (!viewAllMessagesBtn.enabled) {
				UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 15.0f, 20.0f, 20.0f)];
				
				[spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
				[spinner setCenter:[cell center]];
				[spinner startAnimating];
				
				[cell.contentView addSubview:spinner];
			} else {
				
				for (UIView *view in [cell.contentView subviews]) {
					[view removeFromSuperview];
				}
				
				UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, 0.0, self.view.frame.size.width + 10.0, 210.0)];
				backView.backgroundColor = [UIColor clearColor];
				
				cell.backgroundColor = [UIColor clearColor];
				cell.backgroundView = backView;
				
				if (currentEvent)
					messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 0.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5) messages:eventMessages forEvent:currentEvent];
				else
					messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 0.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5)];
				
				[cell.contentView addSubview:messageWallTableViewController.view];
				[viewAllMessagesBtn setEnabled:TRUE];
			}
			
		} else {
			UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, 0.0, self.view.frame.size.width + 10.0, 210.0)];
			backView.backgroundColor = [UIColor clearColor];
			
			cell.backgroundColor = [UIColor clearColor];
			cell.backgroundView = backView;
			
			messageWallTableViewController = [[MessageWallTableViewController alloc] init:CGRectMake(-10.0, 5.0, backView.frame.size.width - 18.0 + 10.0, backView.frame.size.height - 7.5) messages:messageWallTableViewController.eventMessages forEvent:nil];
			
			[cell.contentView addSubview:messageWallTableViewController.view];
		}
	}
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
    if (section == SectionEventPrivacy && privacySliderView.hidden)
        return 51.0;
    else if(section == SectionEventPrivacy && !privacySliderView.hidden)
        return 130.0;
    else if (section == SectionEventMessageWall)
        return 0.0;
    else if (section == SectionEventCreate)
        return 0.0;
    else if(section == SectionEventDetails) {
        if (eventDescriptionField.hidden) {
            return 100.0;
        } else {
            return 180.0;
        }
    }
    else if(section == SectionEventInfo)
        return 80.0;
    else if (section == SectionEventStartEndTime)
        return 51.0;
    else if (section == SectionEventInvitations)
        return 30.0;
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (currentEvent && section == SectionEventMessageWall)
        return 60.0;
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == SectionEventMessageWall) {
        return 210.0;
		
    } else if(indexPath.section == SectionEventPrivacy) {
		
		CGSize descriptionlabelSize = CGRectZero.size;
        
        if([description isEqualToString:@""] == FALSE) {
            CGSize constraintSize = CGSizeMake(300  - 10.0, MAXFLOAT);
            descriptionlabelSize = [description sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        }
		
		int y = 18.0;
        
        if([description isEqualToString:@""] == FALSE)
			y = y + descriptionlabelSize.height + 23.0;
        
        if([location_name isEqualToString:@""] == FALSE)
            y += 50.0;
        
        if (selectedEventRecurringIndex > 0)
            y += 50.0;
        
        if (selectedEventReminderIndex > 0)
            y += 50.0;
        
        return y;
    }
    
    return 0.0;
}

#pragma mark event recurring delegate

- (void)setEventRecurring:(NSNumber *)eventRecurringSelectedIndex recurranceDate:(NSDate *)recurranceDate {
	passedEventRecurringSelectedIndex = eventRecurringSelectedIndex;
	recurranceEndDate = recurranceDate;
}

- (void) setEventRecurring:(NSNumber *)eventRecurringSelectedIndex
{
	passedEventRecurringSelectedIndex = eventRecurringSelectedIndex;
}

#pragma mark event reminder delegate

- (void)setEventReminder:(NSNumber *)eventReminderSelectedIndex reminderDate:(NSDate *)reminderDate {
	passedEventReminderSelectedIndex = eventReminderSelectedIndex;
	reminderCustomDate = reminderDate;
}

- (void) setEventReminder:(NSNumber *)eventReminderSelectedIndex
{
	passedEventReminderSelectedIndex = eventReminderSelectedIndex;
}

#pragma mark event start end time delegate

- (void) setEventStartEndTime:(NSDate *) evtStartTime endTime:(NSDate *) evtEndTime
{
	passedEventStartTime = evtStartTime;
    passedEventEndTime = evtEndTime;
}

- (void) setEventDate:(NSDate *)date
{
	passedEventDate = date;
    
    if (![passedEventDate isEqualToDate:startTime])
        eventDateChanged = YES;
    else
        eventDateChanged = NO;
}

#pragma mark Button Actions

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField tag] == 5000) {
        eventTitle = textField.text;
    }
}


- (IBAction)nextPrevious:(id)sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionEventMessageWall] animated:NO];
    
	UIView *responder = [self.view findFirstResponder];
	switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
		case 0:
			// previous
			if (responder == eventTitleField) {
				[eventLocationField becomeFirstResponder];
			} else if (responder == eventDescriptionField) {
				[eventTitleField becomeFirstResponder];
			} else if (responder == eventLocationField) {
				[eventDescriptionField becomeFirstResponder];
            } else {
                [responder resignFirstResponder];
            }
			break;
		case 1:
			// next
			if (responder == eventTitleField) {
				[eventDescriptionField becomeFirstResponder];
			} else if (responder == eventDescriptionField) {
				[eventLocationField becomeFirstResponder];
			} else if (responder == eventLocationField) {
				[eventTitleField becomeFirstResponder];
			} else {
                [responder resignFirstResponder];
            }
			break;
	}
}

#pragma mark - segment controll change events
-(IBAction)GoldenEventSegmentChange:(id)sender {
    
    if (isGolden == 0) {
        isGolden=1;
        isGoldenEvent = [NSNumber numberWithInt:1];
        [goldenBtn setBackgroundImage:[UIImage imageNamed:@"gold_stared_icon2.png"] forState:UIControlStateNormal];
    } else {
        isGolden=0;
        isGoldenEvent=[NSNumber numberWithInt:0];
        [goldenBtn setBackgroundImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
    }
    
    NSLog(@"golden event %@ %d",isGoldenEvent,isGolden);
}

-(void)allDayEventSegmentControlChanged:(id) sender {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
    allDayValue = [[NSNumber alloc] initWithInt:0];
    
    if (allDayEventSegmentControl.selectedSegmentIndex == 0) {
        [df setDateFormat:@"EEE, dd MMM yyyy"];
        allDayValue = [[NSNumber alloc] initWithInt:1];
    }
    
    eventStartTimeLabel.text = [df stringFromDate:startTime];
    eventEndTimeLabel.text = [df stringFromDate:endTime];
}

/*
 -(void)postToFBSegmentControlChanged:(id) sender {
 if (postToFBSegmentControl.selectedSegmentIndex == 0)
 postToFB = [[NSNumber alloc] initWithInt:1];
 else
 postToFB = [[NSNumber alloc] initWithInt:0];
 }
 */
#pragma mark - invite friends delegate
-(void) setFriends:(NSMutableArray *)friends {
    friendsArray = [NSMutableArray arrayWithArray:friends];
}

-(void) setFBFriends:(NSMutableArray *)fbFriends {
    fbFriendsArray = [NSMutableArray arrayWithArray:fbFriends];
}

#pragma mark - friends invite delegate
- (void)setFriends:(NSMutableArray *)friends areFBFriends:(BOOL) areFB {
	if (areFB) {
		fbFriendsArray = [NSMutableArray arrayWithArray:friends];
	} else {
		friendsArray = [NSMutableArray arrayWithArray:friends];
	}
}

//delegate method for privacy
-(void) setPrivacy:(NSMutableArray *)privateFromFriends {
    privateFromFriendsArray = [NSMutableArray arrayWithArray:privateFromFriends];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        if(alertView.tag == 1000) {
            [eventTitleField becomeFirstResponder];
            return;
        }
        
        if(alertView.tag == 1001) {
            isPrivate = [[NSNumber alloc] initWithInt:1];
            isOpen = [[NSNumber alloc] initWithInt:0];
            
            stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings headerColorRed] green:[ApplicationDelegate.uiSettings headerColorGreen] blue:[ApplicationDelegate.uiSettings headerColorBlue] alpha:1.0];
            
            standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed] green:[ApplicationDelegate.uiSettings footerDetailColorGreen] blue:[ApplicationDelegate.uiSettings footerDetailColorBlue] alpha:1.0];
            
            viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed] green:[ApplicationDelegate.uiSettings footerDetailColorGreen] blue:[ApplicationDelegate.uiSettings footerDetailColorBlue] alpha:1.0];
            
            friendsArray = nil;
            
            return;
        }
    }
    
    if (buttonIndex == 1)
    {
        if(alertView.tag == 1001) {
            privacySlider.value = 1.0;
            return;
        }
        
        if (alertView.tag == 1002) {
            if (self.eventOperation) {
                [self.eventOperation cancel];
                self.eventOperation = nil;
            }
            
            if (self.messagesOperation) {
                [self.messagesOperation cancel];
                self.messagesOperation = nil;
            }
            
            //TODO set my status to no
            HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
            HUD.labelText = @"Deleting event...";
            HUD.dimBackground = YES;
            NSNumber *isInStealthMode;
            //Attending option for delete
            NSNumber *attendingOption = [NSNumber numberWithInt:0];
            
            if ([[currentEvent isStealth] intValue] == 0)
                isInStealthMode = [[NSNumber alloc] initWithInt:1];
            else
                isInStealthMode = [[NSNumber alloc] initWithInt:0];
            
            eventOperation = [ApplicationDelegate.eventEngine changeEvent:currentEvent ofUser:[[[SingletonUser sharedUserInstance] user] serverId] attendingStatus:attendingOption stealthMode:isInStealthMode onCompletion:^(NSDictionary *result) {
				
				NSString *resultStr = [[NSString alloc] initWithFormat:@"%@",[result objectForKey:@"id"]];
				
				if ([resultStr intValue] != 400) {
					[currentEvent setAttending:attendingOption];
					[currentEvent setIsStealth:isInStealthMode];
					
					[modelUtils commitDefaultMOC];
					
					if ([attendingOption intValue] == 1) {
						NSArray *childIds = [result objectForKey:@"chield"];
						[Event updateRecurringEvent:currentEvent serverIds:childIds];
					} else {
						// delete all the recurring events
						[Event updateRecurringEvent:currentEvent serverIds:nil];
					}
				}
				
				[HUD setHidden:YES];
				[self.navigationController popToRootViewControllerAnimated:YES];
			} onError:^(NSError* error) {
				[HUD setHidden:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}];
        }
    }
}

- (void) hideKeyboard {
    [eventTitleField resignFirstResponder];
    [eventDescriptionField resignFirstResponder];
    [eventLocationField resignFirstResponder];
    
    /*
     if (messageWallTableViewController)
     if ([messageWallTableViewController textView])
     [messageWallTableViewController.textView resignFirstResponder];
     */
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([textView.text length] == 0)
        placeholderLabel.hidden = NO;
    else {
        placeholderLabel.hidden = YES;
        
        if (textView.text.length > 500)
            textView.text = [textView.text substringToIndex:500];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if([newString length] > 500)
        return NO;
    
    return YES;
}


-(IBAction) privacySliderValueChanged:(id) sender{
	float newStep = roundf((privacySlider.value) / stepValue);
    self.privacySlider.value = newStep * stepValue;
    
    if (privacySlider.value == 0.0) {
        
        if (friendsArray && [friendsArray count] > 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Info"
                                                            message: @"You have already invited some people. In private events you cannot invite anyone. Do you want to cancel your invitations?"
                                                           delegate: self
                                                  cancelButtonTitle: @"No"
                                                  otherButtonTitles: @"Yes", nil];
            
            alert.tag = 1001;
            
            [alert show];
            
            return;
        }
        
        
        isPrivate = [[NSNumber alloc] initWithInt:1];
        isOpen = [[NSNumber alloc] initWithInt:0];
        
        stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                            green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                             blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                            alpha:1.0];
        
        standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                             green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                              blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                             alpha:1.0];
        
        viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                          green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                           blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                          alpha:1.0];
        
        [advancedPrivacyBtn setEnabled:FALSE];
    } else if (privacySlider.value == 1.0) {
        isPrivate = [[NSNumber alloc] initWithInt:0];
        isOpen = [[NSNumber alloc] initWithInt:0];
        
        stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                            green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                             blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                            alpha:1.0];
        
        standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                             green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                              blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                             alpha:1.0];
        
        viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                          green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                           blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                          alpha:1.0];
        
        [advancedPrivacyBtn setEnabled:TRUE];
    } else {
        isPrivate = [[NSNumber alloc] initWithInt:0];
        isOpen = [[NSNumber alloc] initWithInt:1];
        
        stealthModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                            green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                             blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                            alpha:1.0];
        
        standardModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings footerDetailColorRed]
                                                             green:[ApplicationDelegate.uiSettings footerDetailColorGreen]
                                                              blue:[ApplicationDelegate.uiSettings footerDetailColorBlue]
                                                             alpha:1.0];
        
        viralModeLabel.textColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
                                                          green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
                                                           blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
                                                          alpha:1.0];
        
        [advancedPrivacyBtn setEnabled:TRUE];
    }
}

-(void)setEventStartEndDate:(id)sender {
    eventSetStartEndTimeViewController = [[EventSetStartEndTimeViewController alloc] initWithNibName:@"EventSetStartEndTimeViewController" bundle:nil];
    
    eventDateChanged = NO;
    
    eventSetStartEndTimeViewController.eventStartTime = startTime;
    eventSetStartEndTimeViewController.eventEndTime = endTime;
    
    [eventSetStartEndTimeViewController setEventSetStartEndTimeDelegate:self];
    
    [self.navigationController pushViewController:eventSetStartEndTimeViewController animated:YES];
}

#pragma mark - FBSessionDelegate Methods

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    //[self apiRESTGetAppUsers];
    
    [Utils storeFBAuthData:[facebook accessToken] expiresAt:[facebook expirationDate]];
    
	NSString *post = [NSString stringWithFormat:@"I am attending the open event %@. To attend, go to www.tymepass.com/download" , eventTitle];
	
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[facebook accessToken],@"access_token",
                                   post, @"message",
                                   nil];
    
    [facebook requestWithGraphPath:@"me/feed"   // or use page ID instead of 'me'
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:self];
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
	[self DoTweet:strFBpost];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Auth Exception"
														message:@"Your session has expired."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil, nil];
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
	
	[self DoTweet:strFBpost];
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
    NSLog(@"Err code: %@", [error localizedDescription]);
    NSLog(@"Err: %@", error);
	
	[self DoTweet:strFBpost];
}

@end