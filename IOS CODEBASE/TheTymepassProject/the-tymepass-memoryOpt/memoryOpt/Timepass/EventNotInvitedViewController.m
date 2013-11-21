//
//  EventViewController.m
//  Timepass
//
//  Created by Takis Sotiriadis on 21/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventNotInvitedViewController.h"
#import "Invitation+Management.h"
#import "Invitation+GAE.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "TTTAttributedLabel.h"
#import "CalendarDayViewController.h"
#import "GlobalData.h"
#import "User+GAEUser.h"
#import "Utils.h"

enum {
    SectionEventInfo                    = 0,
    SectionEventDetails                 = 1,
    SectionsCount                       = 2
};

enum {
    EventInfoSectionRowsCount           = 1
};

enum {
    EventDetailsSectionRowsCount        = 1
};

enum {
    EventInviteesSectionRowsCount       = 0
};

@implementation EventNotInvitedViewController
@synthesize tableView;
@synthesize currentEvent;
@synthesize attendeesOperation;
@synthesize attendeesImagesOperation;
@synthesize EventImg;

@synthesize attendingBtn, attendingLabel, reminderBtn, reminderLabel, maybeBtn, maybeLabel;

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event *)event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentEvent = event;
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
    scrollViewContentHeight = 620;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight)];
    
    self.title = NSLocalizedString(@"Event", @"Event");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    viewCalendarBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [viewCalendarBtn setFrame:CGRectMake(self.view.frame.size.width - 150.0, 10.0, 140.0, 29.0)];
    [viewCalendarBtn setBackgroundImage:[UIImage imageNamed:@"view_calendar_btn.png"] forState:UIControlStateNormal];
    [viewCalendarBtn setBackgroundImage:[UIImage imageNamed:@"view_calendar_btn_pressed.png"] forState:UIControlStateHighlighted];
    [viewCalendarBtn addTarget:self action:@selector(viewCalendar:) forControlEvents:UIControlEventTouchUpInside];
    viewWholeTitle = FALSE;
    
    attendingBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [attendingBtn addTarget:self action:@selector(attendingBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    maybeBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [maybeBtn addTarget:self action:@selector(maybeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	[maybeBtn setEnabled:FALSE];
    
    reminderBtn = [ApplicationDelegate.uiSettings createButton:@""];
    [reminderBtn addTarget:self action:@selector(reminderBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	[reminderBtn setEnabled:FALSE];
	
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
    
    [self loadImages];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    attendeesOperation = [ApplicationDelegate.invitationEngine requestObjectOfEvent:currentEvent objectType:@"attendees"
       onCompletion:^(NSArray *responseData) {
           peopleAttending = [NSMutableArray arrayWithArray:[Invitation getAttendees:responseData]];
           [self.tableView reloadData];  
       } 
       onError:^(NSError* error) {
      }];
	
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.attendeesOperation) {
        [self.attendeesOperation cancel];
        self.attendeesOperation = nil;
    }
    
    [super viewDidDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

-(IBAction)attendingBtnPressed:(id)sender {
    eventAttendeesViewController = [[EventAttendeesViewController alloc] initWithNibName:@"EventAttendeesViewController" bundle:nil attendees:peopleAttending];
    
    [self.navigationController pushViewController:eventAttendeesViewController animated:YES];
}

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
    
    [self.navigationController pushViewController:calendarViewController animated:YES];}

- (void) createdByClicked {
    UIViewController *profileController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:currentEvent.creatorId];
    
    [self.navigationController pushViewController:profileController animated:YES];
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
				if (user.photo) {
					
					NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.photo]];
					AFImageRequestOperation *operation;
					operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
						image = [Utils resizedFromImage:image inPixes:88];
						[btnImage setImage:image forState:UIControlStateNormal];
					}];
					
					[operation start];
				}
				
				[btnImage setImage:image forState:UIControlStateNormal];
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
        default:
            break;
    }
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @" ";
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {  
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 30.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    
    switch (section) {
        case SectionEventInfo: {
            
			[headerLabel setFrame:CGRectMake(12.0, 0.0,  self.view.frame.size.width, 20.0)];
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
				
                [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewContentHeight + headerLabelFrame.size.height)];
				
                [headerLabel setFrame:headerLabelFrame];
            }
            
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
			
		    [headerView addSubview:headerLabel];
			return headerView;
		}
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
		
    }  else if(section == SectionEventDetails) {
        
        UIView *eventDetailsView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 80.0)];
		
		UIImageView *imageSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dobble_line.png"]];
        [imageSeparator setFrame:CGRectMake(10.0, 10.0, 300.0, 2.0)];
        [footerView addSubview:imageSeparator];
        
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
        
        attendingLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
        [attendingLabel setFrame:CGRectMake(0.0, 100.0, 90.0, [ApplicationDelegate.uiSettings cellFontSize])];
        attendingLabel.text =  [NSString stringWithFormat:@"ATTENDING (%d)", [peopleAttending count]];
        attendingLabel.textAlignment = UITextAlignmentLeft;
        
        maybeLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
        [maybeLabel setFrame:CGRectMake(114.0, 100.0, 72.0, [ApplicationDelegate.uiSettings cellFontSize])];
        maybeLabel.text =  @"MAYBE";
        maybeLabel.textAlignment = UITextAlignmentCenter;
        
        reminderLabel = [ApplicationDelegate.uiSettings createEventViewDetailsLabel];
        [reminderLabel setFrame:CGRectMake(228.0, 100.0, 72.0, [ApplicationDelegate.uiSettings cellFontSize])];
        reminderLabel.text =  @"REMINDER";
        reminderLabel.textAlignment = UITextAlignmentCenter;
        
        [eventDetailsView addSubview:attendingLabel];
        [eventDetailsView addSubview:maybeLabel];
        [eventDetailsView addSubview:reminderLabel];
        
        [footerView addSubview:eventDetailsView];
        
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
        
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == SectionEventDetails)
        return -10.0;
	
	if (section == SectionEventInfo) {
		return 30.0;
	}
   
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section { 
    if (section == SectionEventInfo)
        return 30.0;
    
    if (section == SectionEventDetails)
        return 110.0;
    
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
    
    return 40.0;
}

@end
