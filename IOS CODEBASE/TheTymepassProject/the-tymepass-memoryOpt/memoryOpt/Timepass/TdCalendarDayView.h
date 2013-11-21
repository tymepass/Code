//
//  TdCalendarDayView.h
//  Timepass
//
//  Created by Christos Skevis on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const __TdCalendarEventTileTouchNotification = @"__TdCalendarEventTileTouchNotification";

@protocol CalendarDayViewDelegate;

@interface TdCalendarDayView : UIView {
	CFGregorianDate currentSelectDate;
	CFAbsoluteTime	currentTime;
    
    UIView *allDayEventsView;
	UIView *dayEventsView;
	UIScrollView *dayEventsScrollView;
    
	UIImageView* viewImageView;
    NSArray *events;
    id<CalendarDayViewDelegate> calendarDayViewDelegate;

    NSDate * todate;
    
@private
	NSCalendar *calendar;
	NSDate *currentDate;
	NSDate *today;
}

@property CFGregorianDate currentSelectDate;
@property CFAbsoluteTime  currentTime;

@property (nonatomic, strong) IBOutlet UIView *allDayEventsView;
@property (nonatomic, strong) IBOutlet UIView *dayEventsView;
@property (nonatomic, strong) IBOutlet UIView *dayEventsScrollView;

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) id<CalendarDayViewDelegate> calendarDayViewDelegate;
@property (nonatomic, retain) NSDate * todate;
@property (nonatomic, retain) NSArray * events;


-(void)reloadData;
-(void)movePrevDay;
-(void)moveNextDay;
-(void)setToday;
@end

@protocol CalendarDayViewDelegate<NSObject>
@required
- (NSArray *)calendarEventsForDate:(NSDate *)date;
@end