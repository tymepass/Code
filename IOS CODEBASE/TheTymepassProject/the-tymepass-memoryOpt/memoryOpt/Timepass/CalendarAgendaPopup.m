//
//  CalendarAgendaViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarAgendaPopup.h"
#import "Event+Management.h"
#import "EventViewController.h"
#import "Event+GAE.h"

@implementation CalendarAgendaPopup
@synthesize headerView;
@synthesize dayTitle;
@synthesize nextButton;
@synthesize previousButton;
@synthesize tableView;
@synthesize currentDate;
@synthesize selectedDate;
@synthesize fetchedEvents;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //default value
        popup = FALSE;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        popup = FALSE;
        
        scratchContext = context;
        aFriend = afriendId;
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isPopup:(BOOL) isPopup currentDay:(NSDate *)currentSelectDate{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedDate = currentSelectDate;
        popup = isPopup;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context isPopup:(BOOL) isPopup currentDay:(NSDate *)currentSelectDate{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil friend:afriendId inContext:context];
    if (self) {
        selectedDate = currentSelectDate;
        popup = isPopup;
    }
    return self;
    
}

- (void)setCurrentDate:(NSDate *)value {
	currentDate = value;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)didFinishLoading
{
    if (sectionToVisible > 0) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(rowToVisible == -1) ? NSNotFound : rowToVisible inSection:sectionToVisible]atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    tableView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    //[self changeHeaderTitle];
}

- (void)viewDidUnload
{
    [self setDayTitle:nil];
    [self setNextButton:nil];
    [self setPreviousButton:nil];
    [self setHeaderView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //set the current day
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:selectedDate];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    self.selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    [components setDay:components.day + 1];
    selectedDateEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    fetchedEvents = [self calendarAgendaEvents];
    sectionsArray = [[NSMutableArray alloc] init];
    allDayEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    otherEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay = %d OR (startDate < %@ AND endTime > %@)", 1, selectedDate, selectedDateEnd];
    [allDayEvents filterUsingPredicate:pred];
    if (allDayEvents.count > 0) {
        [sectionsArray addObject:allDayEvents];
    }
	
    pred = [NSPredicate predicateWithFormat:@"isAllDay = %d AND (startDate >= %@ OR endTime <= %@)", 0, selectedDate, selectedDateEnd];
    [otherEvents filterUsingPredicate:pred];
	NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
    [otherEvents sortUsingDescriptors:[NSArray arrayWithObject:sortByStartTime]];
	
    if (otherEvents.count > 0) {
        [sectionsArray addObject:otherEvents];
    }
	
    tableView.scrollsToTop = YES;
    
    // Show a label in the table's footer if there are no events
	if (fetchedEvents.count == 0)
	{
        UIView *footerTableView = [[UIView alloc] init];
        
        UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
        label.text = NSLocalizedString(@"No events yet!", nil);
        
        [footerTableView addSubview:label];
        
        tableView.tableFooterView = footerTableView;
    }
    
    [tableView reloadData];
    
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[sectionsArray objectAtIndex:section] count];
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    if (section == 0 && [[sectionsArray objectAtIndex:section] count] == 0)
        return [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 0.0)];
    if (section == 1 && [[sectionsArray objectAtIndex:section] count] == 0)
        return [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 0.0)];
	
    UIView *tableHeaderView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, self.view.frame.size.width, 27.0)];
    tableHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_agenda_tdheader_bg.png"]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 3.0, 90.0, 20.0)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.clearsContextBeforeDrawing = YES;
    headerLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
    headerLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:15.0];
    
    UILabel *headerDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2.0, 3.0, 300.0, 20.0)];
    
    headerDetailLabel.backgroundColor = [UIColor clearColor];
    headerDetailLabel.opaque = NO;
    headerDetailLabel.clearsContextBeforeDrawing = YES;
    
    /*if ([[[distinctDays objectAtIndex:section] valueForKey:@"isAllDay"] isEqual:currentDate])
	 
	 else
	 headerDetailLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	 */
    headerDetailLabel.textColor = headerLabel.textColor;
    headerDetailLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:15.0];
    
    if ([sectionsArray objectAtIndex:section] == allDayEvents) {
        headerDetailLabel.text = @"All-Day Events";
        
        CGSize labelSize = [@"All-Day Events" sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:15.0]
										 constrainedToSize:CGSizeMake(self.view.frame.size.width, 9999)
											 lineBreakMode:UILineBreakModeWordWrap];
        
        [headerDetailLabel setFrame:CGRectMake(self.view.frame.size.width / 2.0 - labelSize.width / 2.0, 3.0, labelSize.width, 20.0)];
    }
    else {
        if (allDayEvents.count == 0) {
            headerDetailLabel.text = @"Events";
            
            CGSize labelSize = [@"Events" sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:15.0]
									 constrainedToSize:CGSizeMake(self.view.frame.size.width, 9999)
										 lineBreakMode:UILineBreakModeWordWrap];
            
            [headerDetailLabel setFrame:CGRectMake(self.view.frame.size.width / 2.0 - labelSize.width / 2.0, 3.0, labelSize.width, 20.0)];
        }
        else {
            headerDetailLabel.text = @"Other Events";
            
            CGSize labelSize = [@"Other Events" sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:15.0]
										   constrainedToSize:CGSizeMake(self.view.frame.size.width, 9999)
											   lineBreakMode:UILineBreakModeWordWrap];
            
            [headerDetailLabel setFrame:CGRectMake(self.view.frame.size.width / 2.0 - labelSize.width / 2.0, 3.0, labelSize.width, 20.0)];
        }
    }
    
    [tableHeaderView addSubview:headerLabel];
    [tableHeaderView addSubview:headerDetailLabel];
    
    return tableHeaderView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
	
    cell.backgroundView = [[UIImageView alloc] init];
    ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"calendar_agenda_cell_bg.png"];
    Event *event = [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 10.0, 95.0, 15.0)];
    
    durationLabel.backgroundColor = [UIColor clearColor];
    durationLabel.opaque = NO;
    durationLabel.clearsContextBeforeDrawing = YES;
    
    if (aFriend && [event.busy intValue] == 1)
        durationLabel.textColor = [[UIColor alloc] initWithRed:168.0/255.0 green:168.0/255.0 blue:168.0/255.0 alpha:1.0];
    else if ([event.attending intValue] == 1)
        durationLabel.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
    else
        durationLabel.textColor = [[UIColor alloc] initWithRed:218.0/255.0 green:132.0/255.0 blue:0.0/255.0 alpha:1.0];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    
    durationLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:15.0];
    
    if ([sectionsArray objectAtIndex:indexPath.section] == allDayEvents){
        //check if it is multiday
        if ([event.startDate compare:selectedDate] == NSOrderedAscending){
            durationLabel.text = [NSString stringWithFormat:@"Multi Day"];
        } else
            durationLabel.text = [NSString stringWithFormat:@"All Day"];
    } else {
        if ([event.startTime compare:selectedDate] == NSOrderedAscending){
            if ([event.endTime compare:selectedDateEnd] == NSOrderedDescending){
                durationLabel.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];
            } else {
                durationLabel.adjustsFontSizeToFitWidth = YES;
                durationLabel.text = [NSString stringWithFormat:@"Ends at %@",[df stringFromDate:event.endTime]];
            }
        } else {
            if ([event.endTime compare:selectedDateEnd] == NSOrderedAscending){
                durationLabel.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];
            } else {
                durationLabel.adjustsFontSizeToFitWidth = YES;
                durationLabel.text = [NSString stringWithFormat:@"Starts at %@",[df stringFromDate:event.startTime]];
            }
        }
    }
	
    [cell addSubview:durationLabel];
    UILabel *eventTitleLabel;
	
    eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0 + durationLabel.frame.size.width, 10.0, cell.frame.size.width - durationLabel.frame.size.width - 30.0, 15.0)];
	
    
    eventTitleLabel.backgroundColor = [UIColor clearColor];
    eventTitleLabel.opaque = NO;
    eventTitleLabel.clearsContextBeforeDrawing = YES;
    eventTitleLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    eventTitleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:15.0];
    if (aFriend && [event.busy intValue] == 1)
        eventTitleLabel.text = @"Busy";
    else
        eventTitleLabel.text = event.title;
    
    [cell addSubview:eventTitleLabel];
    
    
	if (![event.locationId.name isEqualToString:@""]) {
		UIImage *locationIcon = [UIImage imageNamed:@"event_location_icon_big.png"];
		UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 12.0 + durationLabel.frame.size.height + 2.0, locationIcon.size.width, locationIcon.size.height)];
		locationImageView.image = locationIcon;
		if (!aFriend || (aFriend && [event.busy intValue] == 0))
			[cell addSubview:locationImageView];
		
		CGSize locationSize = [event.locationId.name sizeWithFont:[UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:13.0]
												constrainedToSize:CGSizeMake(200, 9999)
													lineBreakMode:UILineBreakModeWordWrap];
		
		UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0 + locationImageView.frame.size.width + 2.0, 12.0 + durationLabel.frame.size.height + 3.0, locationSize.width, 15.0)];
		
		locationLabel.backgroundColor = [UIColor clearColor];
		locationLabel.opaque = NO;
		locationLabel.clearsContextBeforeDrawing = YES;
		locationLabel.textColor = [[UIColor alloc] initWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
		locationLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:13.0];
		locationLabel.text = event.locationId.name;
		
		if (!aFriend || (aFriend && [event.busy intValue] == 0))
			[cell addSubview:locationLabel];
	}
	
	UIImage *alarmIcon;
	
	if (![event.reminder isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		alarmIcon = [UIImage imageNamed:@"event_alarm_icon_big.png"];
		UIImageView *alarmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - alarmIcon.size.width - 3.0, 12.0 + durationLabel.frame.size.height + 2.0, alarmIcon.size.width, alarmIcon.size.height)];
		alarmImageView.image = alarmIcon;
		[cell addSubview:alarmImageView];
	}
    
    if (![event.recurring isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		UIImage *repeatIcon = [UIImage imageNamed:@"event_repeat_icon_big.png"];
		UIImageView *repeatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - alarmIcon.size.width - 1.0 - repeatIcon.size.width - 3.0, 12.0 + durationLabel.frame.size.height + 2.0, repeatIcon.size.width, repeatIcon.size.height)];
		repeatImageView.image = repeatIcon;
        [cell addSubview:repeatImageView];
    }
    
    if ([event.busy intValue] != 0)
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 27.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *selectedEvent = (Event *)[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (aFriend && [selectedEvent.busy intValue] != 0)
        return;
    
    eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:selectedEvent];
    [[ApplicationDelegate navigationController] pushViewController:eventViewController animated:YES];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Action Methods

-(IBAction)movePrevDay:(id)sender {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day -= 1;
    
	self.currentDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [self changeHeaderTitle];
    fetchedEvents = [self calendarEventsForDate:currentDate];
    [tableView reloadData];
}

-(IBAction)moveNextDay:(id)sender {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day += 1;
    
	self.currentDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [self changeHeaderTitle];
    fetchedEvents = [self calendarEventsForDate:currentDate];
    [tableView reloadData];
}

-(void)setToday {
    /*
     //set the current day
     NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] fromDate:[NSDate date]];
     self.currentDate = [[NSCalendar currentCalendar] dateFromComponents:components];
     
     [self changeHeaderTitle];
     fetchedEvents = [self calendarEventsForDate:currentDate];
     [tableView reloadData];
     */
    
    /*
     CGRect sectionRect = [tableView rectForSection:sectionToVisible];
     sectionRect.size.height = tableView.frame.size.height;
     [tableView scrollRectToVisible:sectionRect animated:YES];
     */
    
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(rowToVisible == -1) ? NSNotFound : rowToVisible inSection:sectionToVisible]atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)changeHeaderTitle {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
	[df setDateFormat:@"EEEE dd MMM"];
    
	[dayTitle setText:[df stringFromDate:[self currentDate]]];
}

- (NSMutableArray *)calendarEventsForDate:(NSDate *)date {
    NSMutableArray *events = [NSMutableArray array];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                    [ApplicationDelegate.uiSettings units] | NSHourCalendarUnit |
                                    NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                                   fromDate:date];
    
    for (Event* cdEvent in [Event getAgendaEventsForDay:date])
        [events addObject:cdEvent];
    
    totalCurrentDayEvents = [events count];
    
    [components setDay:[components day] + 1];
    
    for (Event* cdEvent in [Event getAgendaEventsForDay:[[NSCalendar currentCalendar] dateFromComponents:components]]) {
        [events addObject:cdEvent];
    }
    
	return events;
}

- (NSMutableArray *)calendarAgendaEvents {
    NSMutableArray *events = [NSMutableArray array];
    if(aFriend){
        events = fetchedEvents;
        
    } else {
        [events addObjectsFromArray:[Event getAgendaEventsForDay:selectedDate]];
    }
    
    return events;
}

@end
