//
//  TdCalendarView.h
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol CalendarMonthViewDelegate;

@interface TdCalendarMonthView : UIView {
	UIImageView* viewImageView;
    NSArray *events;
@private
	NSCalendar *calendar;
	NSDate *currentDate;
	NSDate *today;
    NSDate *eventSelectedDate;
    
    int monthDay;
    
    float eventX;
    float eventY;
    
    float todayX;
    float todayY;
    
    BOOL todayBtnPressed;
    BOOL fetchEvents;
	
	double incr;
	double itemHeight;
}

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *currentSelectDate;
@property (nonatomic, retain) NSDate *today;
@property (nonatomic, retain) NSDate *eventSelectedDate;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) id<CalendarMonthViewDelegate> calendarMonthViewDelegate;
@property (nonatomic, retain) User *aFriend;

@property (nonatomic, strong) MKNetworkOperation *eventOperation;

-(void)movePrevMonth;
-(void)moveNextMonth;
-(void)setToday;
-(void)drawCurrentSelectDate;
@end

@protocol CalendarMonthViewDelegate<NSObject>
@required
- (NSArray *)calendarMonthEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate;
@optional
- (void) selectDateChanged:(NSDate *) selectDate;
- (void) monthChanged:(NSDate *) currentMonth viewLeftTop:(CGPoint)viewLeftTop height:(float)height;
- (void) beforeMonthChange:(TdCalendarMonthView*) calendarView willto:(CFGregorianDate) currentMonth;

@end
