//
//  CalendarAgendaViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarAgendaViewController.h"
#import "CreateEventViewController.h"
#import "Event+Management.h"
#import "Event+GAE.h"
#import "NSDataAdditions.h"
#import "EventViewController.h"

@implementation CalendarAgendaViewController
@synthesize headerView;
@synthesize dayTitle;
@synthesize nextButton;
@synthesize previousButton;
@synthesize tableView;
@synthesize currentDate;

@synthesize HUD;
@synthesize eventOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		loading = 0;
		offset = 0;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil afriend:(User *)afriendId inContext:(NSManagedObjectContext *) context {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		scratchContext = context;
        aFriend = afriendId;
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
    /*if (sectionToVisible > 0) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(rowToVisible == -1) ? NSNotFound : rowToVisible
															 inSection:sectionToVisible]
						 atScrollPosition:UITableViewScrollPositionTop
								 animated:YES];
    }*/
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

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	loading++;
	if (loading > 1) {
		return;
	}
	
	if (aFriend) {
		fetchedEvents = [[NSMutableArray alloc] init];
		
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.frame = CGRectMake(0.0, 63.0, [ApplicationDelegate navigationController].view.frame.size.width, [ApplicationDelegate navigationController].view.frame.size.height);
		HUD.labelText = @"Fetching events...";
		HUD.dimBackground = YES;
		
		[self getPagedEvents];
	} else {
		fetchedEvents = [self calendarAgendaEvents:0];
		[self parseData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	loading = 0;
	
	if (self.eventOperation) {
        
        [self.eventOperation cancel];
        self.eventOperation = nil;
    }
    
    if (HUD)
        [self setHUD:nil];
	
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getPagedEvents {
	
	eventOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"getEventsByDate" offset:offset onCompletion:^(NSArray *responseData) {
		
		NSArray *listItems = [[responseData objectAtIndex:0] objectForKey:@"entities"];
		
		//parse to array of dictionarys
		NSManagedObjectContext *context = [[Utils sharedUtilsInstance] scratchPad];
		
		for (NSMutableDictionary *dict in listItems) {
			Location *newLocation;
			
			NSMutableDictionary *data = [dict mutableCopy];
			
			if ([[dict objectForKey:@"locations"] count] > 0) {
				NSString *locationText = [NSString stringWithFormat:@"%@",[[[dict valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
				
				newLocation = [Location getLocationWithName:locationText inContext:context];
				
				if (!newLocation) {
					newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
				}
			}
			
			//[dict setObject:newLocation forKey:@"location"];
			[data setValue:newLocation forKey:@"location"];
			
			User *creatorUser = [User getUserWithId:[dict valueForKey:@"creator"] inContext:context];
			[data setValue:creatorUser forKey:@"creator"];
			
			NSString *attendingStatus;
			if ([dict objectForKey:@"attending"])
				attendingStatus = [dict objectForKey:@"attending"];
			else
				attendingStatus = @"confirmed";
			[data setValue:[NSString stringWithFormat:@"%d",[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
			
			Event *eventObj = [Event createEventFromDictionary:data inContext:context];
			NSLog(@"event obj is %@",eventObj);
			
			[fetchedEvents addObject:eventObj];
		}
		
		if ([listItems count] > 0) {
			[self parseData];
		}
		[HUD hide:YES];
		
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
}

-(void)parseData {
	//set the current day
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    self.currentDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSMutableSet *filteredData = [NSMutableSet setWithArray:[fetchedEvents valueForKey:@"startDate"]];
	[filteredData addObjectsFromArray:[fetchedEvents valueForKey:@"endDate"]];
    distinctDays = [NSMutableArray arrayWithArray:[filteredData allObjects]];
    
    if ([distinctDays count] > 0 && ![distinctDays containsObject:currentDate])
        [distinctDays addObject:currentDate];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for(int i = 0; i < [distinctDays count];i++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[distinctDays objectAtIndex:i] forKey:@"date"];
        
        [tempArray addObject:dict];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [tempArray sortUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];
    
    distinctDays = [NSMutableArray arrayWithArray:tempArray];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:currentDate forKey:@"date"];
    
    if (distinctDays.count > 0)
        sectionToVisible = [distinctDays indexOfObject:dict];
    else
        sectionToVisible = 0;
    
    NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    
    [components setDay:[components day] + 1];
    
    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"startTime >= %@ AND endTime < %@",currentDate, endTime];
    [filteredEvents filterUsingPredicate:pred];
    
    rowToVisible = -1;
    
    if ([filteredEvents count] > 0)
        rowToVisible = 0;
    
    tableView.scrollsToTop = YES;
    
    // Show a label in the table's footer if there are no events
    if (fetchedEvents.count == 0) {
        UIView *footerTableView = [[UIView alloc] init];
        
        UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
        label.text = NSLocalizedString(@"No events yet!", nil);
        
        [footerTableView addSubview:label];
        
        tableView.tableFooterView = footerTableView;
    } else {
		tableView.tableFooterView = nil;
		if ([fetchedEvents count] < 50) {
			allLoad = TRUE;
		}
	}
    
	[self performSelector:@selector(didFinishLoading) withObject:nil afterDelay:0.0];
    [tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [distinctDays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[[distinctDays objectAtIndex:section] valueForKey:@"date"]];
    
    [components setDay:[components day] + 1];
    
    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"endTime >= %@ AND startTime < %@",[[distinctDays objectAtIndex:section] valueForKey:@"date"],endTime];
    [filteredEvents filterUsingPredicate:pred];
    
	NSInteger sectionsAmount = [self.tableView numberOfSections];
	int total = [filteredEvents count];
	if (section == sectionsAmount - 1) {
		if (!allLoad) {
			total++;
		}
	}
	
    return total;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {
    UIView *tableHeaderView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, self.view.frame.size.width, 27.0)];
    tableHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_agenda_tdheader_bg.png"]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 3.0, 90.0, 20.0)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.clearsContextBeforeDrawing = YES;
    headerLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
    headerLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:15.0];
    
    UILabel *headerDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 3.0, 300.0, 20.0)];
    
    headerDetailLabel.backgroundColor = [UIColor clearColor];
    headerDetailLabel.opaque = NO;
    headerDetailLabel.clearsContextBeforeDrawing = YES;
    
    if ([[[distinctDays objectAtIndex:section] valueForKey:@"date"] isEqual:currentDate])
        headerDetailLabel.textColor = headerLabel.textColor;
    else
        headerDetailLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    
    headerDetailLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue"] size:15.0];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
    
    [df setDateFormat:@"EEEE"];
    headerLabel.text =  [df stringFromDate:[[distinctDays objectAtIndex:section] valueForKey:@"date"]];
    
    [df setDateFormat:@"dd MMM yyyy"];
    
    headerDetailLabel.text =  [df stringFromDate:[[distinctDays objectAtIndex:section] valueForKey:@"date"]];
    
    [tableHeaderView addSubview:headerLabel];
    [tableHeaderView addSubview:headerDetailLabel];
    
    return tableHeaderView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
	if (!allLoad) {
		NSInteger sectionsAmount = [self.tableView numberOfSections];
		NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
		
		if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[cell.contentView addSubview:activity];
			[activity startAnimating];
			[activity setCenter:cell.center];
			return cell;
		}
	}
    
    cell.backgroundView = [[UIImageView alloc] init];
    ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"calendar_agenda_cell_bg.png"];
    
    NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[[distinctDays objectAtIndex:indexPath.section] valueForKey:@"date"]];
    
    [components setDay:[components day] + 1];
    
    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"endTime >= %@ AND startTime < %@",[[distinctDays objectAtIndex:indexPath.section] valueForKey:@"date"],endTime];
    [filteredEvents filterUsingPredicate:pred];
    
    Event *event = (Event *)[filteredEvents objectAtIndex:indexPath.row];
    
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
    //durationLabel.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];
	
	//durationLabel.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];
	
	//////    -------------	MOBI  -- 28/05/2013\
	
	NSString *str = @"1";
	NSString *strAddday =  [[filteredEvents objectAtIndex:indexPath.row] valueForKey:@"isAllDay"];
	NSLog(@"str...%@",strAddday);
	
	NSString *strchecknew = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];

	NSString *strstart = @"00:00";
	NSString *strlast = @"23:59";
	NSString *strcheckold = [NSString stringWithFormat:@"%@ - %@",strstart,strlast];

	
	
	 if ([str isEqualToString:strAddday] || [strcheckold isEqualToString:strchecknew] )
	 {
		durationLabel.text = @"All Day";
	 }
	 else
	 {
		 durationLabel.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:event.startTime],[df stringFromDate:event.endTime]];

	 }
	
	
	//durationLabel.text = @"All Day";
    
    [cell addSubview:durationLabel];
    
    UILabel *eventTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0 + durationLabel.frame.size.width, 10.0, cell.frame.size.width - durationLabel.frame.size.width - 13.0, 15.0)];
    
    eventTitleLabel.backgroundColor = [UIColor clearColor];
    eventTitleLabel.opaque = NO;
    eventTitleLabel.clearsContextBeforeDrawing = YES;
    eventTitleLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    eventTitleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:15.0];
	
	bool busyEvent = false;
	
	if(aFriend && [event.busy intValue] == 1) {
		busyEvent = TRUE;
	}
	
	if (!busyEvent) {
		eventTitleLabel.text = event.title;
	} else {
		eventTitleLabel.text = @"busy";
	}
    
    [cell addSubview:eventTitleLabel];
	
	if (![event.locationId.name isEqualToString:@""] && !busyEvent) {
		UIImage *locationIcon = [UIImage imageNamed:@"event_location_icon_big.png"];
		UIImageView *locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 12.0 + durationLabel.frame.size.height + 2.0, locationIcon.size.width, locationIcon.size.height)];
		locationImageView.image = locationIcon;
		
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
		
		[cell addSubview:locationLabel];
	}
	
	UIImage *alarmIcon;
	
	if (![event.reminder isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		alarmIcon = [UIImage imageNamed:@"event_alarm_icon_big.png"];
		UIImageView *alarmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width - alarmIcon.size.width - 3.0, 12.0 + durationLabel.frame.size.height + 2.0, alarmIcon.size.width, alarmIcon.size.height)];
		alarmImageView.image = alarmIcon;
		[cell addSubview:alarmImageView];
	}
    
    if (![event.recurring isEqualToNumber:[NSNumber numberWithInt:0]]) {
		
		UIImage *repeatIcon = [UIImage imageNamed:@"event_repeat_icon_big.png"];
		UIImageView *repeatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width - alarmIcon.size.width - 1.0 - repeatIcon.size.width - 3.0, 12.0 + durationLabel.frame.size.height + 2.0, repeatIcon.size.width, repeatIcon.size.height)];
		repeatImageView.image = repeatIcon;
        [cell addSubview:repeatImageView];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (!allLoad) {
		NSInteger sectionsAmount = [self.tableView numberOfSections];
		NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
		
		if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
			
			offset+=50;
			
			if (aFriend) {
				[self getPagedEvents];
			} else {
				
				NSMutableArray *events = [[NSMutableArray alloc] initWithArray:[self calendarAgendaEvents:offset]];
				if ([events count] > 0) {
					[fetchedEvents addObjectsFromArray:[self calendarAgendaEvents:offset]];
					[self parseData];
				} else {
					allLoad = TRUE;
				}
			}
		}
	}
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
    /*
     int objectIndex = indexPath.row;
     
     if (indexPath.section > 0)
     objectIndex = indexPath.section * indexPath.row  + totalCurrentDayEvents;
     
     Event *selectedEvent = [fetchedEvents objectAtIndex:objectIndex];
     */
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *filteredEvents = [NSMutableArray arrayWithArray:fetchedEvents];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[[distinctDays objectAtIndex:indexPath.section] valueForKey:@"date"]];
    
    [components setDay:[components day] + 1];
    
    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"endTime >= %@ AND startTime < %@",[[distinctDays objectAtIndex:indexPath.section] valueForKey:@"date"],endTime];
    [filteredEvents filterUsingPredicate:pred];
    
    Event *selectedEvent = (Event *)[filteredEvents objectAtIndex:indexPath.row];
	if (aFriend && [selectedEvent.busy intValue] == 1) {
		return;
	}
	
    eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:selectedEvent];
    
    /*
     * Changed to use global function
     *
     if (![selectedEvent.creatorId isEqual:[[SingletonUser sharedUserInstance] user]])
     eventViewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil event:selectedEvent];
     else
     eventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil event:selectedEvent];
     */
    
    [[ApplicationDelegate navigationController] pushViewController:eventViewController animated:YES];
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
    if ([tableView numberOfRowsInSection:0] > 0)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(rowToVisible == -1) ? NSNotFound : rowToVisible
															 inSection:sectionToVisible]
						 atScrollPosition:UITableViewScrollPositionTop
								 animated:YES];
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
    
    for (Event* cdEvent in [Event getAgendaEvents])
        [events addObject:cdEvent];
    NSLog(@"event id %@",[Event getAgendaEvents]);
	
    return events;
}

- (NSMutableArray *)calendarAgendaEvents:(NSInteger)offsetlocal {
    NSMutableArray *events = [NSMutableArray array];
    
    for (Event* cdEvent in [Event getAgendaEvents:offsetlocal])
        [events addObject:cdEvent];
    
    return events;
}

@end