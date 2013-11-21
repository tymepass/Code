//
//  CalendarViewController.m
//  Timepass
//
//  Created by Mahmood1 on 28/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "MyProfileViewController.h"
#import "CreateEventViewController.h"
#import "Utils.h"
#import "TdCalendarDayPopup.h"

@implementation CalendarViewController

@synthesize calendarView;
@synthesize toolBar;
@synthesize initViewController;
@synthesize eventDate;
@synthesize footerView;
//@synthesize passEventDateDelegate;
@synthesize calendarAgendaViewController,calendarDayViewController,calendarWeekViewController,calendarMonthViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        profileUser = [[SingletonUser sharedUserInstance] user];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil initViewController:(UIViewController *)initView showToolBar:(BOOL) showToolBar
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        profileUser = [[SingletonUser sharedUserInstance] user];
        
        initViewController = initView;
        toolBarWillBeShown = showToolBar;
        
        //debugLog(@"### Started calendar view without friendId and context ##");
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
   initViewController:(UIViewController *)initView
          showToolBar:(BOOL) showToolBar
              aFriend:(User *)localFriend
            inContext:(NSManagedObjectContext *) context;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        scratchContext = context;
        profileUser = localFriend;
        
        initViewController = initView;
        toolBarWillBeShown = showToolBar;
        
        //debugLog(@"### Started calendar view with friendId and context ##");
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
    
    if (initViewController) {
        [calendarView addSubview:initViewController.view];
    }
    if (toolBarWillBeShown) {
        UIButton *profileBtn =[[UIButton alloc] init];
		[profileBtn setBackgroundImage:[UIImage imageNamed:@"default_profilepic.png"] forState:UIControlStateNormal];
		[profileBtn setBackgroundImage:[UIImage imageNamed:@"default_profilepic.png"] forState:UIControlStateHighlighted];
        
        if (profileUser.photo) {
			
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:profileUser.photo]];
			AFImageRequestOperation *operation;
			operation = [AFImageRequestOperation imageRequestOperationWithRequest:request  success:^(UIImage *image) {
				[profileBtn setBackgroundImage:image forState:UIControlStateNormal];
				[profileBtn setBackgroundImage:image forState:UIControlStateHighlighted];
			}];
			
			[operation start];
            
        }
        
        profileBtn.frame = CGRectMake(0,0,31.0,30.0);
        profileBtn.layer.cornerRadius = 3;
        [profileBtn setClipsToBounds: YES];
        [profileBtn addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view1  = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0, 31.0, 32.0)];
        [view1 addSubview:profileBtn];
		
		UIBarButtonItem *btn1 =[[UIBarButtonItem alloc] initWithCustomView:view1];
        self.navigationItem.leftBarButtonItem = btn1;
        self.navigationItem.leftItemsSupplementBackButton = YES;
		
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0, 65.0, 32.0)];
		
		//CalendarView not being initialized by CreateEventView
		if (!(initViewController && [initViewController isKindOfClass:[CalendarDayViewController class]])) {
			UIButton *addEventBtn = [ApplicationDelegate.uiSettings createButton:@""];
			[addEventBtn setFrame:CGRectMake(0.0, -1.0, 65.0, 32.0)];
			[addEventBtn setBackgroundImage:[UIImage imageNamed:@"add_event_navbar_btn.png"] forState:UIControlStateNormal];
			[addEventBtn setBackgroundImage:[UIImage imageNamed:@"add_event_navbar_btn_pressed.png"] forState:UIControlStateHighlighted];
			[addEventBtn addTarget:self action:@selector(addEvent:)  forControlEvents:UIControlEventTouchUpInside];
			
			[view addSubview:addEventBtn];
		}
        
        if ([[[SingletonUser sharedUserInstance] user] isEqual:profileUser]) {
            toolBar = [[TdCalendarToolbar alloc] initWithViewController:self
												   showSegmentedControl:YES];
        } else {
            toolBar = [[TdCalendarToolbar alloc] initWithViewController:self
												   showSegmentedControl:YES
																aFriend:profileUser
															  inContext:scratchContext];
        }
        
        UIBarButtonItem *btn =[[UIBarButtonItem alloc] initWithCustomView:view];
        self.navigationItem.rightBarButtonItem = btn;
        
        [footerView addSubview:toolBar];
        
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
        
        toolBar = [[TdCalendarToolbar alloc] initWithViewController:self showSegmentedControl:NO aFriend:profileUser inContext:scratchContext];
        //else toolBar = [[TdCalendarToolbar alloc] initWithViewController:self showSegmentedControl:NO];
        [footerView addSubview:toolBar];
    }
    
    [toolBar.segmentedControl addTarget:self action:@selector(toolBarSegmentButtons:) forControlEvents:UIControlEventValueChanged];
    [toolBar.todayControl addTarget:self action:@selector(todayBtn:) forControlEvents:UIControlEventValueChanged];
	
	shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
		
		[shadowImage setFrame:CGRectMake(0, 45, 320, 416)];
		
	} else {
		
		[shadowImage setFrame:CGRectMake(0, 45, 320, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 88)];
		
	}
	
	[self.view addSubview:shadowImage];
	shadowImage.hidden = TRUE;
}

- (void)viewDidUnload {
	[self setCalendarView:nil];
    [self setToolBar:nil];
    [self setInitViewController:nil];
    //[self setPassEventDateDelegate:nil];
    
    [self setCalendarAgendaViewController:nil];
    [self setCalendarDayViewController:nil];
    [self setCalendarMonthViewController:nil];
	
    [self setFooterView:nil];
    [super viewDidUnload];
}


- (void)viewDidAppear:(BOOL)animated
{
    [initViewController viewDidAppear:NO];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
    if ([[[SingletonUser sharedUserInstance] user] isEqual:profileUser])
        self.title = NSLocalizedString(@"My Calendar", @"My Calendar");
    else
        self.title = [NSString stringWithFormat:@"%@'s Cal", profileUser.name];
    
    [super viewWillAppear:animated];
	//[self toolBarSegmentButtons:toolBar.segmentedControl];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = Nil;
	
	for (int i = 0; i < [[self.view subviews] count]; i++ ) {
		
		if ([[[self.view subviews] objectAtIndex:i] isKindOfClass:[TdCalendarDayPopup class]]) {
			[(TdCalendarDayPopup *)[[self.view subviews] objectAtIndex:i] closePopupWindow];
		}
		
	}
    
    [super viewWillDisappear:animated];
}

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *__strong)item{
    //debugLog(@"popup");
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) addEvent:(id)sender {
	
	if ([[[SingletonUser sharedUserInstance] user] isEqual:profileUser]) {
		CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil];
		
		[self.navigationController pushViewController:createEventViewController animated:YES];
	} else {
		CreateEventViewController *createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil invitee:profileUser];
		
		[self.navigationController pushViewController:createEventViewController animated:YES];
	}
}

- (void) doneBtnPressed:(id) sender
{
    /*
	 if ([initViewController isKindOfClass:[CalendarMonthViewController class]])
	 [[self passEventDateDelegate] setEventDate:[((CalendarMonthViewController *)initViewController).tdCalendarView eventSelectedDate]];
	 */
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)viewProfile:(id)sender {
    
    UIViewController *profileViewController;
    
    if (![[[SingletonUser sharedUserInstance] user] isEqual:profileUser])
        profileViewController = [Utils checkFriendshipOfUser:[[SingletonUser sharedUserInstance] user] withUser:profileUser];
    else
        profileViewController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}


- (IBAction)toolBarSegmentButtons:(id)sender
{
    BOOL aFriend = FALSE;
    
    if (![[[SingletonUser sharedUserInstance] user] isEqual:profileUser])
        aFriend = TRUE;
    
    [self removeCalendarViewSubviews];
    [self setInitViewController:nil];
		
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
		case 0:
			
			shadowImage.hidden = TRUE;
			
            if (aFriend) {
                
				calendarAgendaViewController = [[CalendarAgendaViewController alloc] initWithNibName:@"CalendarAgendaViewController" bundle:nil afriend:profileUser inContext:scratchContext];
                [calendarView addSubview:calendarAgendaViewController.view];
                
                [calendarAgendaViewController viewDidAppear:YES];
                
                CGRect frame = self.view.bounds;
                frame.size.height = frame.size.height - 44;
                
                [calendarAgendaViewController.tableView setFrame:frame];
				
            } else {
                calendarAgendaViewController = [[CalendarAgendaViewController alloc] initWithNibName:@"CalendarAgendaViewController" bundle:nil];
                [calendarView addSubview:calendarAgendaViewController.view];
                
                [calendarAgendaViewController viewDidAppear:YES];
                
                CGRect frame = self.view.bounds;
                frame.size.height = frame.size.height - 44;
                
                [calendarAgendaViewController.tableView setFrame:frame];
            }
			
			initViewController = calendarAgendaViewController;
            
			break;
		case 1:
			
			shadowImage.hidden = FALSE;
			
            if (aFriend) {
				
				calendarDayViewController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayViewController" bundle:nil friend:profileUser inContext:scratchContext];
				
                [calendarView addSubview:calendarDayViewController.view];
                [calendarDayViewController.tdCalendarDayView reloadData];
				
                
            } else {
                calendarDayViewController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayViewController" bundle:nil];
				[calendarView addSubview:calendarDayViewController.view];
                [calendarDayViewController.tdCalendarDayView reloadData];
            }
			
			initViewController = calendarDayViewController;
            
			break;
			
        case 2:
			
			shadowImage.hidden = FALSE;
			
			if (aFriend) {
				
				calendarWeekViewController = [[CalendarWeekViewController alloc] initWithNibName:@"CalendarWeekViewController" bundle:nil friend:profileUser inContext:scratchContext];
                
                [calendarWeekViewController.tdCalendarView setViewController:self];
                [calendarWeekViewController.tdCalendarView setParentViewController:calendarWeekViewController];
                
                [calendarView addSubview:calendarWeekViewController.view];
				
				
			}
            else {
                calendarWeekViewController = [[CalendarWeekViewController alloc] initWithNibName:@"CalendarWeekViewController" bundle:nil];
                
                [calendarWeekViewController.tdCalendarView setViewController:self];
                [calendarWeekViewController.tdCalendarView setParentViewController:calendarWeekViewController];
                
                [calendarView addSubview:calendarWeekViewController.view];
            }
			
			initViewController = calendarWeekViewController;
            
            break;
			
		case 3:
			
			shadowImage.hidden = FALSE;
			
			if (aFriend) {
				
				calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil friend:profileUser inContext:scratchContext];
				
                [calendarMonthViewController.tdCalendarView setViewController:self];
				[calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
				
                [calendarView addSubview:calendarMonthViewController.view];
				
			} else {
                calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil];
                
                [calendarMonthViewController.tdCalendarView setViewController:self];
                [calendarMonthViewController.tdCalendarView setParentViewController:calendarMonthViewController];
                
                [calendarView addSubview:calendarMonthViewController.view];
            }
			
			initViewController = calendarMonthViewController;
				
			break;
	}
}

-(IBAction)todayBtn:(id)sender{
    
	switch([toolBar.segmentedControl selectedSegmentIndex]) {
		case 0:
			[calendarAgendaViewController setToday];
			break;
			
		case 1:
			[calendarDayViewController.tdCalendarDayView setToday];
			[calendarDayViewController changeHeaderTitle];
			break;
			
        case 2:
			[calendarWeekViewController.tdCalendarView setToday];
			[calendarWeekViewController changeHeaderTitle];
            break;
			
		case 3:
			[calendarMonthViewController.tdCalendarView setToday];
			[calendarMonthViewController changeHeaderTitle];
            break;
	}
}

- (void)removeCalendarViewSubviews {
    for (UIView *v in [calendarView subviews]) {
        [v removeFromSuperview];
    }
}

@end
