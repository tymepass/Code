//
//  CalendarDayViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarDayViewController.h"
#import "Event+Management.h"
#import "Event+GAE.h"

@implementation CalendarDayViewController;
@synthesize headerView;
@synthesize dayTitle;
@synthesize nextButton;
@synthesize previousButton;
@synthesize tdCalendarDayView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //tdCalendarDayView = [[TdCalendarDayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];

        tdCalendarDayView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
        [self.view addSubview:tdCalendarDayView];
        
        [tdCalendarDayView setCalendarDayViewDelegate:self];
        //[tdCalendarDayView reloadData];
            
        [self changeHeaderTitle];

        //debugLog(@"### Started day view without friendId and context ##");
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		scratchContext = context;
        aFriend = afriendId;

        // Custom initialization
        //tdCalendarDayView = [[TdCalendarDayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        
        tdCalendarDayView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
        [self.view addSubview:tdCalendarDayView];
        
        [tdCalendarDayView setCalendarDayViewDelegate:self];
        //[tdCalendarDayView reloadData];
        
        [self changeHeaderTitle];
        
        
        //debugLog(@"### Started day view with friendId and context ##");
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
            
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
}

- (void)viewDidUnload
{
    [self setTdCalendarDayView:nil];
    [self setDayTitle:nil];
    [self setNextButton:nil];
    [self setPreviousButton:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[tdCalendarDayView reloadData];
}

#pragma mark -
#pragma mark Action Methods

-(IBAction)movePrevDay:(id)sender {
	[tdCalendarDayView movePrevDay];
    [self changeHeaderTitle];
}

-(IBAction)moveNextDay:(id)sender {
	[tdCalendarDayView moveNextDay];
    [self changeHeaderTitle];
}

-(void)changeHeaderTitle {
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
	[df setDateFormat:@"EEEE dd MMM"];
	
	NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setLocale:[NSLocale currentLocale]];
	[df1 setDateFormat:@"EEEE"];
	
	NSDate *dateTitle = [tdCalendarDayView currentDate];
    
	[dayTitle setText:[df stringFromDate:dateTitle]];
	
	dayTitle.textAlignment = UITextAlignmentCenter;
	dayTitle.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
	[dayTitle setText:[df stringFromDate:dateTitle] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
		
		NSRange range = [[mutableAttributedString string] rangeOfString:[df1 stringFromDate:dateTitle] options:NSCaseInsensitiveSearch];
		
		UIColor *color = [[UIColor alloc] initWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
		
		[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
		
		UIFont *boldSystemFont =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:[ApplicationDelegate.uiSettings cellFontSize]];
		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
		if (font) {
			[mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
			CFRelease(font);
		}
		
		return mutableAttributedString;
	}];
	
}

#pragma mark -
#pragma mark CalendarDayViewDelegate

- (NSArray *)calendarEventsForDate:(NSDate *)date {
	NSMutableArray *events = [NSMutableArray array];

    if (!aFriend){
        for (Event* cdEvent in [Event getDayEventsForDay:date]){
            NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                            (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit)
                                                                           fromDate:date];
            
            if ([date compare:[cdEvent startTime]] == NSOrderedDescending) {  
                [components setHour:0];
                [components setMinute:0];
                [components setSecond:0];
                
                //cdEvent.startTime = [[NSCalendar currentCalendar] dateFromComponents:components];
            }
            
            [components setHour:23];
            [components setMinute:59];
            [components setSecond:59];
            
            if ([[[NSCalendar currentCalendar] dateFromComponents:components] compare:[cdEvent endTime]] == NSOrderedAscending) {
                [components setDay:[components day] + 1];
                [components setHour:0];
                [components setMinute:0];
                [components setSecond:0];
                
                //cdEvent.endTime  = [[NSCalendar currentCalendar] dateFromComponents:components];
            }
            
            [events addObject:cdEvent];
            
        }
    } else {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                        (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                       fromDate:date];
        
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        
        NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];
        
        [components setHour:23];
        [components setMinute:59];
        [components setSecond:59];

        NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components]; 
        [events addObjectsFromArray:[Event getGAEMonthEventsForPeriod:dayStart endDate:dayEnd andUser:aFriend.serverId inContext:scratchContext]]; 
        
        //events = [[NSMutableArray alloc] initWithArray:[Event getGAEMonthEventsForPeriod:startDate endDate:endDate andUser:friendId inContext:[util scratchManagedObjectContext]]];
    }
    	
	return events;
}

@end
