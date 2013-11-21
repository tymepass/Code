//
//  TdCalendarToolbar.m
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarToolbar.h"
#import "CalendarViewController.h"

@implementation TdCalendarToolbar
@synthesize segmentedControl,todayControl;

- (id)initWithViewController:(UIViewController*)aViewController showSegmentedControl:(BOOL) show {
	self = [super init];
	if (self) {
        CGRect frame = aViewController.view.frame;
        frame = CGRectMake(0, 0, frame.size.width, 44.0);
        [super setFrame:frame];
        
        showSegmentedControl = show;
        
        //debugLog(@"### Started toolbar view without friendId and context ##");
        [self loadView];
	}
    
	return self;
}

- (id)initWithViewController:(UIViewController*)aViewController
        showSegmentedControl:(BOOL) show
                     aFriend:(User *) localFriend
                   inContext:(NSManagedObjectContext *) context {
	self = [super init];
	if (self) {
        CGRect frame = aViewController.view.frame;
        frame = CGRectMake(0, 0, frame.size.width, 44.0);
        [super setFrame:frame];
        
        showSegmentedControl = show;
        scratchContext = context;
        
        aFriend = localFriend;
		
        //debugLog(@"### Started toolbar view with friendId and context ##");
		
        [self loadView];
	}
    
	return self;
}


- (void)loadView {
	
	[self setBackgroundImage:[UIImage imageNamed:@"calendar_toolbar_bg.png"]
		  forToolbarPosition:UIToolbarPositionAny
				  barMetrics:UIBarMetricsDefault];
	
    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        [self insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_toolbar_bg.png"]] atIndex:1];
    else
        [self insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_toolbar_bg.png"]] atIndex:0];*/
	
    todayControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
															  NSLocalizedString(@"Today",@"Today"),
															  nil]];
    todayControl.segmentedControlStyle = UISegmentedControlStyleBar;
    todayControl.tintColor = [[UIColor alloc] initWithRed:143.0/255.0 green:145.0/255.0 blue:147.0/255.0 alpha:1.0];
    todayControl.momentary = YES;
    [todayControl setFrame:CGRectMake(0, 0, todayControl.frame.size.width, todayControl.frame.size.height)];
	
    UIBarButtonItem *todayControlItem = [[UIBarButtonItem alloc] initWithCustomView:todayControl];
	
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (showSegmentedControl) {
		segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																	  NSLocalizedString(@"  Agenda  ",@"  Agenda  "),
																	  NSLocalizedString(@"  Day  ",@"  Day  "),
																	  NSLocalizedString(@"  Week  ",@"  Week  "),
																	  NSLocalizedString(@"  Month  ",@"  Month  "),
																	  nil]];
        
        segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.apportionsSegmentWidthsByContent = YES;
        
        if (aFriend) {
            [segmentedControl setSelectedSegmentIndex:3];
        } else {
            [segmentedControl setSelectedSegmentIndex:0];
        }
        UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        
        NSArray *items = [[NSArray alloc] initWithObjects:todayControlItem, flex, controlItem, nil];
        [self setItems:items animated:NO];
    } else {
        NSArray *items = [[NSArray alloc] initWithObjects:todayControlItem, nil];
        [self setItems:items animated:NO];
    }
}

@end
