#import "TdCalendarWeekView.h"
#import <QuartzCore/QuartzCore.h>
#import "TdCalendarDayPopup.h"
#import "CalendarWeekViewController.h"
#import "CalendarViewController.h"
#import "GlobalData.h"
#import "Event+GAE.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "Location+Management.h"

@implementation TdCalendarWeekView

@synthesize currentDate;
@synthesize currentSelectDate;
@synthesize today;
@synthesize eventSelectedDate;
@synthesize viewController;
@synthesize parentViewController;
@synthesize calendarWeekViewDelegate;
@synthesize aFriend;
@synthesize eventOperation;

CGRect daySelectedRect;

-(void)initCalView{
	
	itemHeight =  110;
	UIScreen* screen = [UIScreen mainScreen];
	if (screen.currentMode.size.height == 1136.0f) {
		itemHeight = 139;
	}
	
	itemWidth =  107;
	
    //set the default calendar type
	calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setLocale:[NSLocale currentLocale]];
	[calendar setFirstWeekday:1];
    
	// set today
	today = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
	
	//set the current day to show the calendar
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[NSDate date]];
    [components setWeekday:1];
	
    self.currentDate = [calendar dateFromComponents:components];
	
    [components setYear:3000];
    self.currentSelectDate = [calendar dateFromComponents:components];
    
    eventSelectedDate = [[[GlobalData sharedGlobalData] event] startDate];
    
    //test get events method
    //NSArray *events = [calendarViewDelegate calendarMonthEventsForDate:currentDate];
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreenLeft:)];
    swipeGestureLeft.numberOfTouchesRequired = 1;
    swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreenRight:)];
    swipeGestureRight.numberOfTouchesRequired = 1;
    swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight);
    [self addGestureRecognizer:swipeGestureRight];
    
    weekDay = 0;
    
    eventX = -1000;
    eventY = -1000;
    
    todayX = -1000;
    todayY = -1000;
    
    todayBtnPressed = FALSE;
    fetchEvents = TRUE;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
		[self initCalView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self initCalView];
	}
	return self;
}

- (void)setCurrentDate:(NSDate *)value {
	currentDate = value;
}

-(void) drawGridLines {
	
	itemWidth =  107;
	
	// extracting components from date
	NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	
	// change for the first day
	[components setDay:([components day]-([components weekday]-2))];
	
	// update the component
	components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]];
	
	// change for the first day
	[components setDay:([components day]-([components weekday]-2))];
	
	int lessDay = [components day];
	int month = [components month];
	int year = [components year];
    
	CGFloat orgx=0;
    
    self.layer.sublayers = nil;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	int width = self.frame.size.width;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd MMMM yyyy"];
	
    bool drawEventSelectedDay = NO;
    
	for (int week=0; week<3; week++)
	{
        //Draw horizontal line
        CGContextSetRGBStrokeColor(ctx, 217.0/255.0, 217.0/255.0, 217.0/255.0, 1.0);
		//CGContextSetGrayStrokeColor(ctx,1,1);
		CGContextMoveToPoint(ctx, 0, week * itemHeight);
		CGContextAddLineToPoint(ctx, width, week * itemHeight);
		CGContextStrokePath(ctx);
		
		int total = 3;
		if (week > 0) {
			total = 2;
			itemWidth = 161;
		}
		
		for (int d=0; d< total; d++)
		{
			[components setDay:lessDay];
			
			/*int d =[[calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]] day];*/
			int m =[[calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]] month];
			int y =[[calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]] year];
            
            /*CGContextSetRGBFillColor(ctx, 210.0/255.0, 210.0/255.0, 210.0/255.0, 1.0);
			 CGRect dayRect = CGRectMake(orgx, week*itemHeight+headHeight, 45.0, 52.0);
			 CGContextFillRect(ctx, dayRect);*/
			
            //Draw day gradient background
            CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
            size_t num_locations = 2;
            CGFloat locations[2] = { 0.0, 1.0};
            CGFloat gradient_components[8] = {
                229.0/255.0, 229.0/255.0, 229.0/255.0, 1.0,
                242.0/255.0, 242.0/255.0, 242.0/255.0, 1.0
            };
            
            if (((m < month && y == year) || y < year) || ((m > month && y == year)||  y > year)) {
                gradient_components[0] = 192.0/255.0;
                gradient_components[1] = 192.0/255.0;
                gradient_components[2] = 192.0/255.0;
                gradient_components[4] = 217.0/255.0;
                gradient_components[5] = 217.0/255.0;
                gradient_components[6] = 217.0/255.0;
                
            }
            
            CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, gradient_components,
                                                                            locations, num_locations);
            CGRect rect = CGRectMake(orgx, week * itemHeight, itemWidth - 1, itemHeight - 1);
            
            //CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
            //CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            
            CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), rect.origin.y);
            CGPoint endPoint = CGPointMake(startPoint.x, rect.origin.y + rect.size.height);
            
            CGContextSaveGState(ctx);
            
            CGContextAddRect(ctx, rect);
            CGContextClip(ctx);
            CGContextDrawLinearGradient(ctx, myGradient, endPoint, startPoint, 0);
            CGContextRestoreGState(ctx);
            
            CGGradientRelease(myGradient);
            CGColorSpaceRelease(myColorspace);
            
            //today
            if ([[df stringFromDate:[calendar dateFromComponents:components]] isEqualToString:[df stringFromDate:[calendar dateFromComponents:[calendar components:[ApplicationDelegate.uiSettings units] fromDate:[[GlobalData sharedGlobalData] today]]]]]) {
				
				todayWidth = itemWidth;
				
                UIImage *todayBG = [UIImage imageNamed:@"calendar_today_bg.png"];
                CGImageRef bg = CGImageRetain(todayBG.CGImage);
				
                CGRect rect = CGRectMake(orgx, week * itemHeight + 34, itemWidth - 1, itemHeight - 34);
                
                CGContextDrawImage(ctx, rect, bg);
				
                todayX = orgx;
                todayY = week * itemHeight;
            }
            
            UIFont *dayfont = [UIFont fontWithName:[ApplicationDelegate.uiSettings monthCalendarDayNumberFont] size:[ApplicationDelegate.uiSettings monthCalendarDayNumberFontSize]];
			
			NSDateComponents *componentsDate = [calendar components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[calendar dateFromComponents:components]];
            
            NSDate *startDateInWords = [[NSCalendar currentCalendar] dateFromComponents:componentsDate];
			
			NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
			[dfTime setDateFormat:@"EEEE"];
			
			NSDateFormatter *dfTime2 = [[NSDateFormatter alloc] init];
			[dfTime2 setDateFormat:@"dd MMM"];
			
			UIImage *todayBG = [UIImage imageNamed:@"hadd_bg_gry.png"];
			CGImageRef bg = CGImageRetain(todayBG.CGImage);
			
			rect = CGRectMake(orgx, week * itemHeight, itemWidth - 1, 17);
			CGContextDrawImage(ctx, rect, bg);
			
			//Draw day number
			NSString *date = [[NSString alloc] initWithFormat:@"%@",[dfTime stringFromDate:startDateInWords]];
			
			NSString *dateStr = [[NSString alloc] initWithFormat:@"%@",[dfTime2 stringFromDate:startDateInWords]];
			CGContextSetRGBFillColor(ctx, [ApplicationDelegate.uiSettings monthCalendarDayNumberColorRed], [ApplicationDelegate.uiSettings monthCalendarDayNumberColorGreen], [ApplicationDelegate.uiSettings monthCalendarDayNumberColorBlue], 1.0);
			
			if (itemWidth <= 107) {
				[date drawAtPoint:CGPointMake(orgx + 3, week * itemHeight) withFont:dayfont];
			} else {
				[date drawAtPoint:CGPointMake(orgx + 10 + (itemWidth / 2) - (14 * ([date length] / 2)), week * itemHeight)
						 withFont:dayfont];
			}
			
			rect = CGRectMake(orgx, week * itemHeight + 17, itemWidth - 1, 17);
			CGContextDrawImage(ctx, rect, bg);
			
			CGContextSetRGBFillColor(ctx, 166.0/255.0, 166.0/255.0, 166.0/255.0, 1.0);
			
			//Draw day number
			
			
			if (itemWidth <= 107) {
				[dateStr drawAtPoint:CGPointMake(orgx + 3, week * itemHeight + 17) withFont:dayfont];
			} else {
				[dateStr drawAtPoint:CGPointMake(orgx + 10 + (itemWidth / 2) - ((14 * [dateStr length]) / 2), week * itemHeight + 17)
							withFont:dayfont];
			}
            
            //Event Day selected
            if ([[GlobalData sharedGlobalData] eventFlag] == YES)
                if ([[df stringFromDate:[calendar dateFromComponents:components]] isEqualToString:[df stringFromDate:[calendar dateFromComponents:[calendar components:[ApplicationDelegate.uiSettings units] fromDate:[[[GlobalData sharedGlobalData] event] startDate]]]]]) {
                    
                    eventX = orgx;
                    eventY = week * itemHeight;
                    
                    drawEventSelectedDay = YES;
                }
            
            NSDateComponents *components2 = [calendar components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[calendar dateFromComponents:components]];
            
            NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:components2];
            
            [components2 setDay:[components2 day] + 1];
            
            [components2 setHour:0];
            [components2 setMinute:0];
            [components2 setSecond:0];
            
            NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:components2];
            
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"((startTime >= %@) AND (startTime < %@)) OR ((startTime < %@) AND (endTime > %@))",startDate, endDate, startDate, startDate];
            
            [[events filteredArrayUsingPredicate:pred] count];
            int eventIndex = 0;
            
            for (Event *event in [events filteredArrayUsingPredicate:pred]) {
                if (eventIndex > 4)
                    break;
                
                //Draw day gradient background
                CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
                size_t num_locations = 2;
                CGFloat locations[2] = {0.0, 1.0};
                CGFloat gradient_components[8] = {
                    36.0/255.0, 121.0/255.0, 2.0/255.0, 1.0,
                    130.0/255.0, 188.0/255.0, 40.0/255.0, 1.0
                };
                
                if ([event.attending intValue] != 1) {
                    gradient_components[0] = 217.0/255.0;
                    gradient_components[1] = 130.0/255.0;
                    gradient_components[2] = 0.0/255.0;
                    gradient_components[3] = 1.0;
                    gradient_components[4] = 238.0/255.0;
                    gradient_components[5] = 193.0/255.0;
                    gradient_components[6] = 0.0/255.0;
                    gradient_components[7] = 1.0;
                }
				
				bool busyEvent = false;
				
				if(aFriend && [event.busy intValue] == 1) {
					busyEvent = TRUE;
				}

                
                if (busyEvent)  {
                    gradient_components[0] = 114.0/255.0;
                    gradient_components[1] = 114.0/255.0;
                    gradient_components[2] = 114.0/255.0;
                    gradient_components[3] = 1.0;
                    gradient_components[4] = 153.0/255.0;
                    gradient_components[5] = 153.0/255.0;
                    gradient_components[6] = 153.0/255.0;
                    gradient_components[7] = 1.0;
                }
                
                CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, gradient_components,
                                                                                locations, num_locations);
                
                CGRect rect = CGRectMake(orgx, week * itemHeight + 34.0 + (eventIndex * 15.0), 30.0, 15.0);
                
                CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), rect.origin.y);
                CGPoint endPoint = CGPointMake(startPoint.x, rect.origin.y + rect.size.height);
                
                CGContextSaveGState(ctx);
                CGContextAddRect(ctx, rect);
                CGContextClip(ctx);
                CGContextDrawLinearGradient(ctx, myGradient, endPoint, startPoint, 0);
                CGContextRestoreGState(ctx);
                
                CGGradientRelease(myGradient);
                CGColorSpaceRelease(myColorspace);
                
                UIFont *eventfont = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:10.0];
                CGContextSetRGBFillColor(ctx, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
				
				NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
				[dfTime setDateFormat:@"HH:mm"];
                
                NSMutableString *eventTime = [[NSMutableString alloc] initWithString:[dfTime stringFromDate:event.startTime]];
				
                if (eventIndex < 4) {
                    if (busyEvent)
                        [[NSString stringWithFormat:@"%@",eventTime] drawAtPoint:CGPointMake(orgx + 2, week * itemHeight + 35 + (eventIndex * 15.0)) withFont:eventfont];
                    else [[NSString stringWithFormat:@"%@",eventTime] drawAtPoint:CGPointMake(orgx + 2, week * itemHeight + 35 + (eventIndex * 15.0)) withFont:eventfont];
                    
                } else
                    [@"..." drawAtPoint:CGPointMake(orgx + 40.0 + rect.size.width / 2 - 3, week * itemHeight + 35 + (eventIndex * 15.0)) withFont:eventfont];
				
				/* new changes for title with date */
				
				gradient_components[0] = 207.0/255.0;
				gradient_components[1] = 207.0/255.0;
				gradient_components[2] = 207.0/255.0;
				gradient_components[3] = 1.0;
				gradient_components[4] = 236.0/255.0;
				gradient_components[5] = 236.0/255.0;
				gradient_components[6] = 236.0/255.0;
				gradient_components[7] = 1.0;
				
				myGradient = CGGradientCreateWithColorComponents (myColorspace, gradient_components,
																  locations, num_locations);
                
                rect = CGRectMake(orgx + 30.0, week * itemHeight + 34 + (eventIndex * 15.0), itemWidth - 31.0, 15.0);
				
				eventfont = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:12.0];
                
                startPoint = CGPointMake(CGRectGetMinX(rect), rect.origin.y);
				endPoint = CGPointMake(startPoint.x, rect.origin.y + rect.size.height);
                
                CGContextSaveGState(ctx);
                CGContextAddRect(ctx, rect);
                CGContextClip(ctx);
                CGContextDrawLinearGradient(ctx, myGradient, endPoint, startPoint, 0);
                CGContextRestoreGState(ctx);
                
                CGGradientRelease(myGradient);
                CGColorSpaceRelease(myColorspace);
                
                CGContextSetRGBFillColor(ctx, 0.0/255.0 , 0.0/255.0, 0.0/255.0 ,1.0);
                
                NSMutableString *eventTitle = [[NSMutableString alloc] initWithString:event.title];
                
                NSString * charToCount = @" ";
                NSArray * wsArray = [event.title componentsSeparatedByString:charToCount];
                
                int wsCount = 0;
                if ([wsArray count] > 1)
                    wsCount = 2;
                
				if (itemWidth == 107) {
					if ([event.title length] >= 8) {
						if (wsCount > 0) {
							NSRange wsRange = [eventTitle rangeOfString:@" "];
							
							if (wsRange.location < 8)
								eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 8)]];
							else
								eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 7)]];
						}
						else
							eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 8)]];
						
						[eventTitle appendString:@"..."];
					}
				} else {
					
					if ([event.title length] >= 15) {
						if (wsCount > 0) {
							NSRange wsRange = [eventTitle rangeOfString:@" "];
							
							if (wsRange.location < 15)
								eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 15)]];
							else
								eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 14)]];
						}
						else
							eventTitle = [[NSMutableString alloc] initWithString:[event.title substringWithRange:NSMakeRange(0, 15)]];
						
						[eventTitle appendString:@"..."];
					}
				}
                
                if (eventIndex < 4) {
					if (!aFriend) {
						[[NSString stringWithFormat:@"%@",eventTitle] drawAtPoint:CGPointMake(orgx + 34.0, week * itemHeight + 33 + (eventIndex * 15.0)) withFont:eventfont];
					} else {
						if (busyEvent)
							[@"busy" drawAtPoint:CGPointMake(orgx + 34.0, week * itemHeight + 33 + (eventIndex * 15.0)) withFont:eventfont];
						else
							[[NSString stringWithFormat:@"%@",eventTitle] drawAtPoint:CGPointMake(orgx + 34.0, week * itemHeight + 33 + (eventIndex * 15.0)) withFont:eventfont];
                    }
                }
                else
                    [@"(more)" drawAtPoint:CGPointMake(orgx + 30.0 + rect.size.width / 2 - 3, week * itemHeight + 33 + (eventIndex * 15.0)) withFont:eventfont];
                
                eventIndex++;
            }
			
            orgx += itemWidth;
			lessDay++;
            
		}
        
		orgx = 0;
	}
    
    if (drawEventSelectedDay == NO) {
        eventX = -1000;
        eventY = -1000;
    }
	
}

- (void) movePrevNext:(int)isPrev{
    fetchEvents = TRUE;
    
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	
	[components setDay:([components day]-([components weekday]-2))];
	
	// update the component
	components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]];
	
	// change for the first day
	[components setDay:([components day]-([components weekday]-2))];
	
    currentSelectDate = [calendar dateFromComponents:components];
    weekDay = 0;
    
	int width = self.frame.size.width;
	int posX;
    
	if(isPrev == 1)
		posX = width;
	else
		posX = -width;
	
	UIImage *viewImage;
	
	UIGraphicsBeginImageContext(self.bounds.size);
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	if(viewImageView == nil) {
		viewImageView = [[UIImageView alloc] initWithImage:viewImage];
		
		viewImageView.center = self.center;
		[[self superview] addSubview:viewImageView];
	} else
		viewImageView.image=viewImage;
	
	viewImageView.hidden = NO;
	viewImageView.transform = CGAffineTransformMakeTranslation(0, 0);
    
	self.hidden = YES;
	[self setNeedsDisplay];
	self.transform = CGAffineTransformMakeTranslation(posX,0);
	self.hidden = NO;
    
	[UIView beginAnimations:nil	context:nil];
	[UIView setAnimationDuration:0.5];
    
	self.transform = CGAffineTransformMakeTranslation(0,0);
	viewImageView.transform = CGAffineTransformMakeTranslation(-posX, 0);
	[UIView commitAnimations];
}

-(void)movePrevWeek {
	NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day -= 7;
	
	self.currentDate = [calendar dateFromComponents:components];
	// [[GlobalData sharedGlobalData] setCurrentDate:currentDate];
    
	[self movePrevNext:0];
}

-(void)moveNextWeek {
	NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day += 7;
    
	self.currentDate = [calendar dateFromComponents:components];
	// [[GlobalData sharedGlobalData] setCurrentDate:currentDate];
    
	[self movePrevNext:1];
}

- (void) swipedScreenLeft:(UISwipeGestureRecognizer*)swipeGesture {
    [self moveNextWeek];
    [(CalendarWeekViewController *)parentViewController changeHeaderTitle];
}

- (void) swipedScreenRight:(UISwipeGestureRecognizer*)swipeGesture {
    [self movePrevWeek];
    [(CalendarWeekViewController *)parentViewController changeHeaderTitle];
}

-(void)setToday {
    todayBtnPressed = TRUE;
    itemWidth =  107;
	
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[NSDate date]];
    today = [calendar dateFromComponents:components];
    
    currentSelectDate = today;
    weekDay = [components day];
    
    NSDateComponents *currentDateComponents = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	//MOBI 3-7-13 
//    if (!([currentDateComponents month] == [components month] && [currentDateComponents year] == [components year])) {
    if (!([currentDateComponents week] == [components week] && [currentDateComponents month] == [components month] && [currentDateComponents year] == [components year])) {
        if ([today compare:currentDate] == NSOrderedAscending) {
            currentDate = today;
            [[GlobalData sharedGlobalData] setCurrentDate:currentDate];
			
            today = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
			
            [self movePrevNext:0];
        } else  if ([today compare:currentDate] == NSOrderedDescending) {
            currentDate = today;
            [[GlobalData sharedGlobalData] setCurrentDate:currentDate];
			
            today = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
			
            [self movePrevNext:1];
        }
    }
    else
        [self setNeedsDisplay];
}

- (void) drawCurrentSelectDate {
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentSelectDate];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (todayBtnPressed)
	{
        UIImage *daySelectedBG = [UIImage imageNamed:@"calendar_day_selected_bg.png"];
        CGImageRef bg = CGImageRetain(daySelectedBG.CGImage);
        
        CGRect rect = CGRectMake(todayX, todayY + 34, todayWidth - 1, itemHeight - 34);
        
        daySelectedRect = rect;
        
        CGContextSetAlpha(ctx,0.6);
        
        CGContextBeginTransparencyLayer(ctx, nil);
        CGContextDrawImage(ctx, rect, bg);
        CGContextEndTransparencyLayer(ctx);
        
        CGImageRelease(bg);
        
        todayBtnPressed = FALSE;
        
        return;
    }
    
	if ([components year] != 3000 && weekDay != 0)
	{
		int x = pos.x / itemWidth;
		int y = pos.y / itemHeight;
		
		if (y > 0) {
			itemWidth = 161;
		} else {
			itemWidth = 107;
		}
		
		x = pos.x / itemWidth;
		
        UIImage *daySelectedBG = [UIImage imageNamed:@"calendar_day_selected_bg.png"];
        CGImageRef bg = CGImageRetain(daySelectedBG.CGImage);
        
        CGRect rect = CGRectMake(x * itemWidth, y * itemHeight + 34, itemWidth - 1, itemHeight - 34);
        
        daySelectedRect = rect;
        
        CGContextSetAlpha(ctx,0.6);
		
        CGContextBeginTransparencyLayer(ctx, nil);
        CGContextDrawImage(ctx, rect, bg);
        CGContextEndTransparencyLayer(ctx);
		
        CGImageRelease(bg);
        
        return;
	}
    
    //Event Day selected
    if ([[GlobalData sharedGlobalData] eventFlag] == YES) {
        UIImage *daySelectedBG = [UIImage imageNamed:@"calendar_day_selected_bg.png"];
        CGImageRef bg = CGImageRetain(daySelectedBG.CGImage);
        
        CGRect rect = CGRectMake(eventX, eventY, itemWidth, itemHeight);
        
        daySelectedRect = rect;
        
        CGContextSetAlpha(ctx,0.6);
        
        CGContextBeginTransparencyLayer(ctx, nil);
        CGContextDrawImage(ctx, rect, bg);
        CGContextEndTransparencyLayer(ctx);
        
        CGImageRelease(bg);
        
        eventSelectedDate = [[[GlobalData sharedGlobalData] event] startDate];
        
        return;
    }
}

- (void) touchAtDate:(CGPoint) touchPoint tapCount:(NSUInteger) tapCount{
	
	int x = touchPoint.x / itemWidth;
	int y = touchPoint.y / itemHeight;
	
	if (y > 0) {
		x = touchPoint.x / 161;
	} else {
		x = touchPoint.x / 107;
	}
	
	if (y > 1) {
		weekDay = x + (y*3);
	} else {
		weekDay = x + (y*3) + 1;
	}
	weekDay++;
	
	pos = touchPoint;
	
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
    [components setDay:([components day]-([components weekday])) + weekDay];
	
    currentSelectDate = [calendar dateFromComponents:components];
	
    [self setNeedsDisplay];
    
    currentSelectDate = [calendar dateFromComponents:components];
    eventSelectedDate = [calendar dateFromComponents:components];
	
    if (tapCount == 2) {
        TdCalendarDayPopup *popUp = [[TdCalendarDayPopup alloc] initWithSuperview:((CalendarViewController *)viewController).view events:events];
		
		[popUp setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
        [popUp setCurrentSelectDate:currentSelectDate];
        [popUp setAFriend:aFriend];
        [popUp setEvents:events];
        
        [((CalendarViewController *)viewController).view addSubview:popUp];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
    
    NSUInteger tapCount = [touch tapCount];
    
    [self touchAtDate:touchPoint tapCount:tapCount];
}

- (void)drawRect:(CGRect)rect{
    // extracting components from date
	NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	
	// change for the first day
	[components setDay:1];
    
	// update the component
	components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[calendar dateFromComponents:components]];
    NSInteger weekday = [components weekday] == 1 ? 7 : [components weekday] - 1;
    
	[components setDay:-weekday+2];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDateComponents *components2 = [calendar components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[calendar dateFromComponents:components]];
    
    [components2 setDay:[components2 day] + 6 * 7];
    
    NSDate *endDate = [calendar dateFromComponents:components2];
	
    if (fetchEvents) {
        if (!aFriend) {
            events = [calendarWeekViewDelegate calendarWeekEventsForPeriod:startDate endDate:endDate];
            
            fetchEvents = FALSE;
        } else {
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
			HUD.frame = CGRectMake(0.0, 63.0, [ApplicationDelegate navigationController].view.frame.size.width, [ApplicationDelegate navigationController].view.frame.size.height);
            HUD.labelText = @"Fetching events...";
            HUD.dimBackground = YES;
            [HUD layoutIfNeeded];
			
            eventOperation = [ApplicationDelegate.eventEngine getEventsByDate:[[[SingletonUser sharedUserInstance] user] serverId] user:[aFriend serverId] dateFrom:startDate dateTo:endDate onCompletion:^(NSMutableArray *eventsArray) {
				events = [NSArray arrayWithArray:eventsArray];
				
				fetchEvents = FALSE;
				
				[HUD setHidden:YES];
				[self setNeedsDisplay];
			} onError:^(NSError* error) {
				[HUD setHidden:YES];
			}];
        }
    }
	
    [self drawGridLines];
    [self drawCurrentSelectDate];
}

-(void) dealloc {
    [self setCurrentDate:nil];
    [self setCurrentSelectDate:nil];
    [self setToday:nil];
    [self setEventSelectedDate:nil];
    [self setViewController:nil];
    [self setParentViewController:nil];
    [self setCalendarWeekViewDelegate:nil];
    [self setAFriend:nil];
}

@end