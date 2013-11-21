//
//  TdCalendarDayPopup.m
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarDayPopup.h"
#import "CalendarAgendaPopup.h"
#import "CreateEventViewController.h"
#import "GlobalData.h"
#import "Utils.h"

#define kShadeViewTag 1000

@implementation TdCalendarDayPopup

CalendarAgendaPopup *calendarAgendaPopup;
CreateEventViewController *createEventViewController;

@synthesize currentSelectDate;
@synthesize aFriend;
@synthesize events;

/**
 * Initializes the class instance, gets a view where the window will pop up in
 * and a file name/ URL
 */
- (id)initWithSuperview:(UIView*)sView events:(NSArray *)evts {
    self = [super init];
    if (self) {
        events = evts;

        // Initialization code here.
        bgView = [[UIView alloc] initWithFrame: sView.bounds];
        [sView addSubview: bgView];
        
        // proceed with animation after the bgView was added
        [self performSelector:@selector(doTransitionWithContentFile:) withObject:nil afterDelay:0.1];
    }
    
    return self;
}

/**
 * Afrer the window background is added to the UI the window can animate in
 * and load the UIWebView
 */
-(void)doTransitionWithContentFile:(NSString*)fName
{
    //faux view
    UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [bgView addSubview: fauxView];

    //the new panel
    bigPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
    bigPanelView.center = CGPointMake( bgView.frame.size.width/2, bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_window_bg.png"]];
    background.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2);
    [bigPanelView addSubview: background];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
	[df setDateFormat:@"EEEE"];
    
    UILabel *headerDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, background.frame.origin.y + 15.0, 140.0, 36.0)];

    headerDayLabel.backgroundColor = [UIColor clearColor];
    headerDayLabel.opaque = NO;
    headerDayLabel.clearsContextBeforeDrawing = YES;
    headerDayLabel.textAlignment = UITextAlignmentRight;
    headerDayLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    headerDayLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue-Bold"] size:15.0];
    headerDayLabel.text = [NSString stringWithFormat:@"%@, ",[df stringFromDate:currentSelectDate]];;
    
    [bigPanelView addSubview: headerDayLabel];
    
	[df setDateFormat:@"dd MMM yyyy"];
    
    UILabel *headerDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + headerDayLabel.frame.size.width , background.frame.origin.y + 15.0, 159.0, 36.0)];
    
    headerDateLabel.backgroundColor = [UIColor clearColor];
    headerDateLabel.opaque = NO;
    headerDateLabel.clearsContextBeforeDrawing = YES;
    headerDateLabel.textAlignment = UITextAlignmentLeft;
    headerDateLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
    headerDateLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue-Bold"] size:15.0];
    headerDateLabel.text = [NSString stringWithFormat:@"%@",[df stringFromDate:currentSelectDate]];;
    
    [bigPanelView addSubview: headerDateLabel];
        
    if (!aFriend)
        calendarAgendaPopup = [[CalendarAgendaPopup alloc] initWithNibName:@"CalendarAgendaPopup" bundle:nil isPopup:TRUE currentDay:currentSelectDate];
    else
        calendarAgendaPopup = [[CalendarAgendaPopup alloc] initWithNibName:@"CalendarAgendaPopup" bundle:nil friend:aFriend inContext:[[Utils sharedUtilsInstance] scratchPad] isPopup:TRUE currentDay:currentSelectDate];
    
    [calendarAgendaPopup.view setFrame:CGRectMake(10.0, background.frame.origin.y + 50.0, 298, 326)];
    //[calendarAgendaViewController.tdCalendarDayView setFrame:CGRectMake(calendarAgendaViewController.headerView.frame.origin.x, calendarAgendaViewController.headerView.frame.origin.y, calendarAgendaViewController.tdCalendarDayView.frame.size.width, calendarAgendaViewController.tdCalendarDayView.frame.size.height)];    
    [calendarAgendaPopup.headerView setFrame:CGRectZero];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:currentSelectDate];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *startTime = [[NSCalendar currentCalendar] dateFromComponents:components];

    [components setDay:[components day] + 1];
    
    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(startTime <= %@ AND endTime > %@) OR (startTime > %@ AND startTime < %@)",startTime, startTime, startTime, endTime];
    events = [events filteredArrayUsingPredicate:pred];
 /*
    [calendarDayViewController.tdCalendarDayView setFrame:CGRectMake(0.0, 0.0, 298, 326)];
    [calendarDayViewController.tdCalendarDayView setCurrentDate:currentSelectDate];
    [calendarDayViewController.tdCalendarDayView setEvents:events];
*/
    calendarAgendaPopup.fetchedEvents = [NSMutableArray arrayWithArray:events];
    calendarAgendaPopup.view.backgroundColor = [UIColor whiteColor];
    calendarAgendaPopup.tableView.showsVerticalScrollIndicator = YES;
    calendarAgendaPopup.tableView.frame = CGRectMake(0.0, 0.0, 298, 326);
    //calendarDayViewController.tdCalendarDayView.backgroundColor = [UIColor whiteColor];
    //calendarDayViewController.tdCalendarDayView.allDayEventsView.backgroundColor = [UIColor whiteColor];
    //calendarDayViewController.tdCalendarDayView.dayEventsView.backgroundColor = [UIColor whiteColor];
    
    [bigPanelView addSubview:calendarAgendaPopup.view];
   // [calendarDayViewController.tdCalendarDayView reloadData];
    
    //add the add event button
    /*
    int addEventBtnOffset = 38.0f;
    UIImage* addEventBtnImg = [UIImage imageNamed:@"add_event_btn.png"];
    UIButton* addEventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addEventBtn setImage:addEventBtnImg forState:UIControlStateNormal];
    [addEventBtn setImage:[UIImage imageNamed:@"add_event_btn_pressed.png"] forState:UIControlStateHighlighted];
    [addEventBtn setFrame:CGRectMake(background.frame.origin.x - 4.0f, 
                                  background.frame.origin.y - 4.0f,
                                  addEventBtnImg.size.width + addEventBtnOffset, 
                                  addEventBtnImg.size.height + addEventBtnOffset)];
    [addEventBtn addTarget:self action:@selector(addEvent) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview: addEventBtn];
    */
    
    //add the close button
    int closeBtnOffset = 38.0f;
    UIImage* closeBtnImg = [UIImage imageNamed:@"popup_close_btn.png"];
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeBtnImg forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"popup_close_btn_pressed.png"] forState:UIControlStateHighlighted];
    [closeBtn setFrame:CGRectMake(background.frame.origin.x + background.frame.size.width 
                                                - closeBtnImg.size.width - closeBtnOffset + 2.0f, 
                                   background.frame.origin.y - 2.0f,
                                   closeBtnImg.size.width + closeBtnOffset, 
                                   closeBtnImg.size.height + closeBtnOffset)];
    [closeBtn addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview: closeBtn];
    
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:fauxView toView:bigPanelView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[UIView alloc] initWithFrame:bigPanelView.frame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [bigPanelView addSubview: shadeView];
        [bigPanelView sendSubviewToBack: shadeView];
    }];
}

/**
 * Removes the window background and calls the animation of the window
 */
-(void)addEvent
{
    //remove the shade
    [[bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
    
    [[GlobalData sharedGlobalData] setCurrentDate:currentSelectDate];
    
    createEventViewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil]; 
    
    [[ApplicationDelegate navigationController] pushViewController:createEventViewController animated:YES];
}

/**
 * Removes the window background and calls the animation of the window
 */
-(void)closePopupWindow
{
    //remove the shade
    [[bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
    
}

/**
 * Animates the window and when done removes all views from the view hierarchy
 * since they are all only retained by their superview this also deallocates them
 * finally deallocate the class instance
 */
-(void)closePopupWindowAnimate
{
    //faux view
    __block UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [bgView addSubview: fauxView];

    //run the animation
    UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState;
        
    [UIView transitionFromView:bigPanelView toView:fauxView duration:0.5 options:options completion:^(BOOL finished) {

        //when popup is closed, remove all the views
        for (UIView* child in bigPanelView.subviews) {
            [child removeFromSuperview];
        }
        for (UIView* child in bgView.subviews) {
            [child removeFromSuperview];
        }
        
        [bgView removeFromSuperview];
    }];
}

@end