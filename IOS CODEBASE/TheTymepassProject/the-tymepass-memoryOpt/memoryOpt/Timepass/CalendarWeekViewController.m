//
//  CalendarWeekViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarWeekViewController.h"
#import "Event+Management.h"
#import "Event+GAE.h"


@implementation CalendarWeekViewController

@synthesize tdCalendarView;
@synthesize headerView;
@synthesize nextButton;
@synthesize previousButton;
@synthesize weekTitle;

-(void)initView {
    tdCalendarView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [self.view addSubview:tdCalendarView];
    [tdCalendarView setCalendarWeekViewDelegate:self];
    [tdCalendarView setAFriend:aFriend];
    
    //TODO  get events from gae and change header to friend's name
    [self changeHeaderTitle];
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
        [self initView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
			   friend:(User *) afriendId
            inContext:(NSManagedObjectContext *) context
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        scratchContext = context;
        aFriend = afriendId;
        
        [self initView];
        
        //debugLog(@"### Started month view with friendId and context ##");
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
    [self setTdCalendarView:nil];
    [self setNextButton:nil];
    [self setPreviousButton:nil];
    [self setWeekTitle:nil];
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

#pragma mark -
#pragma mark Action Methods

-(IBAction)movePrevWeek:(id)sender {
	[tdCalendarView movePrevWeek];
    [self changeHeaderTitle];
}

-(IBAction)moveNextWeek:(id)sender {
	[tdCalendarView moveNextWeek];
    [self changeHeaderTitle];
}

-(void)changeHeaderTitle {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
	[df setDateFormat:@"w"];
	
	NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setLocale:[NSLocale currentLocale]];
	[df1 setDateFormat:@"dd MMM"];
	
	NSDate *currentDate = [tdCalendarView currentDate];
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	
	[components setDay:([components day]-([components weekday]-1)) + 1];
	components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] fromDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
	[components setDay:([components day]-([components weekday]-1)) + 1];
	NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	
	[components setDay:([components day]+6)];
	NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:components];
	
	weekTitle.textAlignment = UITextAlignmentCenter;
	weekTitle.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
	[weekTitle setText:[NSString stringWithFormat:@"W%@ %@ - %@", [df stringFromDate:currentDate],
						[df1 stringFromDate:startDate],
						[df1 stringFromDate:endDate]] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
		
		NSRange range = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"W%@", [df stringFromDate:currentDate]] options:NSCaseInsensitiveSearch];
		
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
#pragma mark CalendarMonthEventsForDate

- (NSArray *)calendarWeekEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSMutableArray *events;
    
    if (!aFriend)
        events = [[NSMutableArray alloc] initWithArray:[Event getMonthEventsForPeriod:startDate endDate:endDate]];
	
	return events;
}

@end
