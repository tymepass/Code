#import <UIKit/UIKit.h>
#import "User.h"

@protocol CalendarWeekViewDelegate;

@interface TdCalendarWeekView : UIView {
	UIImageView* viewImageView;
    NSArray *events;
@private
	NSCalendar *calendar;
	NSDate *currentDate;
	NSDate *today;
    NSDate *eventSelectedDate;
    
    int weekDay;
    
    float eventX;
    float eventY;
    
    float todayX;
    float todayY;
    
    BOOL todayBtnPressed;
    BOOL fetchEvents;
	
	int itemHeight;
	int itemWidth;
	int todayWidth;
	
	CGPoint pos;
}

@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) NSDate *currentSelectDate;
@property (nonatomic, retain) NSDate *today;
@property (nonatomic, retain) NSDate *eventSelectedDate;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) id<CalendarWeekViewDelegate> calendarWeekViewDelegate;
@property (nonatomic, retain) User *aFriend;

@property (nonatomic, strong) MKNetworkOperation *eventOperation;

-(void)movePrevWeek;
-(void)moveNextWeek;
-(void)setToday;
-(void)drawCurrentSelectDate;
@end

@protocol CalendarWeekViewDelegate<NSObject>
@required
- (NSArray *)calendarWeekEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate;
@optional
- (void) selectDateChanged:(NSDate *) selectDate;
- (void) weekChanged:(NSDate *) currentMonth viewLeftTop:(CGPoint)viewLeftTop height:(float)height;
- (void) beforeWeekChange:(TdCalendarWeekView*) calendarView willto:(CFGregorianDate) currentMonth;

@end
