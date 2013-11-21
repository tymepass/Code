//
//  CalendarMonthViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarMonthViewController.h"
#import "Event+Management.h"
#import "Event+GAE.h"

@implementation CalendarMonthViewController
@synthesize tdCalendarView;
@synthesize headerView;
@synthesize nextButton;
@synthesize previousButton;
@synthesize monthTitle;

-(void)initView {
    tdCalendarView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    
    [self.view addSubview:tdCalendarView];
    [tdCalendarView setCalendarMonthViewDelegate:self];
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

        //debugLog(@"### Started month view without friendId and context ##");
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
    [self setMonthTitle:nil];
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

-(IBAction)movePrevMonth:(id)sender {
	[tdCalendarView movePrevMonth];
    [self changeHeaderTitle];
}

-(IBAction)moveNextMonth:(id)sender {
	[tdCalendarView moveNextMonth];
    [self changeHeaderTitle];
}

-(void)changeHeaderTitle {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
	[df setDateFormat:@"MMMM yyyy"];
    
	[monthTitle setText:[df stringFromDate:[tdCalendarView currentDate]]];
}

#pragma mark -
#pragma mark CalendarMonthEventsForDate

- (NSArray *)calendarMonthEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSMutableArray *events;
    
    if (!aFriend)
        events = [[NSMutableArray alloc] initWithArray:[Event getMonthEventsForPeriod:startDate endDate:endDate]];
 
	return events;
}

@end