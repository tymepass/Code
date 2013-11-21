//
//  TdCalendarDayView.m
//  Timepass
//
//  Created by Christos Skevis on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarDayView.h"
#import <QuartzCore/QuartzCore.h>
#import "TdCalendarEventTile.h"
#import "TdCalendarEvent.h"
#import "Event.h"

#define kAllDayTileLeftSide 2.0f
#define kTileLeftSide 52.0f
#define kTileRightSide 10.0f

#define kTopLineBuffer 15.0
#define kSideLineBuffer 42.0
#define kHalfHourDiff 22.0

#define kTileMargin 2.0

@interface TdCCalendarAllDayEventsView : UIView {
	NSArray *events;
    UIScrollView *scrollView;
}

- (id)initWithEvents:(NSArray *)evts uiSettings:(UISettings *)ui;
@end

@implementation TdCCalendarAllDayEventsView

- (id)initWithEvents:(NSArray *)evts {
    if (self = [super init]) {                
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay == YES"];
		events = [evts filteredArrayUsingPredicate:pred];
    }
	
	return self;
}

-(id)initWithEvents:(NSArray *)evts uiSettings:(UISettings *)ui {
	if (self = [super init]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay == YES"];
		events = [evts filteredArrayUsingPredicate:pred];
    }
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	// grab current graphics context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
        
    CGContextMoveToPoint(ctx, 2.0, 5.0);
    CGContextAddLineToPoint(ctx, 52.0, 5.0);
    CGContextAddLineToPoint(ctx, 62.0, 15.0);
    CGContextAddLineToPoint(ctx, 52.0, 25.0);
    CGContextAddLineToPoint(ctx, 2.0, 25.0);
    CGContextAddLineToPoint(ctx, 2.0, 5.0);
    
    CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0] CGColor]);
    CGContextFillPath(ctx);
    
    UIFont *allDayfont = [UIFont fontWithName:[ApplicationDelegate.uiSettings dayCalendarHoursFont] size:[ApplicationDelegate.uiSettings dayCalendarHoursFontSize]];
    CGContextSetRGBFillColor(ctx, [ApplicationDelegate.uiSettings dayCalendarHoursColorRed], [ApplicationDelegate.uiSettings dayCalendarHoursColorGreen], [ApplicationDelegate.uiSettings dayCalendarHoursColorBlue], 1.0);   
    [@"All Day" drawAtPoint:CGPointMake(5.0, 6.0) withFont:allDayfont];
    
    // draw border line
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
	CGContextMoveToPoint(ctx, 0.0, self.frame.size.height);
    CGContextSetLineWidth(ctx, 3.0);
	CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
	
	// stroke the path
	CGContextStrokePath(ctx);
    
    // create scroll view
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(67.0, 0.0, self.frame.size.width - 67.0, 60.0);
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(self.frame.size.width - 67.0, 100.0);
    //scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self addSubview:scrollView];
    int i =0;
    for (Event *e in events) {
        
        TdCalendarEventTile *eventTile = [[TdCalendarEventTile alloc] init];
        eventTile.frame = CGRectMake(kAllDayTileLeftSide,
                            3.0 + 25.0 * i++,
                            scrollView.frame.size.width - kAllDayTileLeftSide - kTileRightSide,
                            25.0);
        eventTile.event = e;
        [scrollView addSubview:eventTile];
    }
}

@end

static NSArray *timeStrings;

@interface TdCCalendarDayEventsView : UIView {
	NSArray *events;
    
    Event *eventToScroll;
    
   	UIScrollView *scrollView;
    NSDate *currentDate;
    
    CGFloat scrollX;
    CGFloat scrollY;
}

- (id)initWithEvents:(NSArray *)evts uiSettings:(UISettings *)ui scrollView:(UIScrollView *)sView currentDate:(NSDate *)curDate;
- (BOOL)hasEvents;
- (CGFloat)yValueForTime:(CGFloat)time;

@end

@implementation TdCCalendarDayEventsView
- (id)initWithEvents:(NSArray *)evts scrollView:(UIScrollView *)sView currentDate:(NSDate *)curDate {
	if (self = [super init]) { 
        currentDate = curDate;
        scrollView = sView;
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay == NO"];
        events = [evts filteredArrayUsingPredicate:pred];

        if ([events count] > 0) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
        
        
            Event *firstEvent = [events objectAtIndex:0];
            
            NSDateComponents *componentsToPredicate = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[firstEvent startTime]];
            
            [componentsToPredicate setHour:[components hour]];
            [componentsToPredicate setMinute:[components minute]];
            
            pred = [NSPredicate predicateWithFormat:@"startTime >= %@",[[NSCalendar currentCalendar] dateFromComponents:componentsToPredicate]];  
            
            NSArray *tempEvents = [events filteredArrayUsingPredicate:pred];
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
            [events sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            [tempEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            
            if ([tempEvents count] > 0)
                eventToScroll = (Event *)[tempEvents objectAtIndex:0];

            for (Event *e in events) {
                TdCalendarEventTile *eventTile = [[TdCalendarEventTile alloc] init];
                eventTile.event = e;
                
                [self addSubview:eventTile];
            }
        }
        
        timeStrings = [NSArray arrayWithObjects:@"00:00",@"01:00", @"02:00", @"03:00", @"04:00", @"05:00", @"06:00", @"07:00", @"08:00", @"09:00", @"10:00", @"11:00",@"12:00",@"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00", @"19:00", @"20:00", @"21:00", @"22:00",@"23:00", @"00:00", nil];
        
	}
	
	return self;
}

- (id)initWithEvents:(NSArray *)evts uiSettings:(UISettings *)ui scrollView:(UIScrollView *)sView currentDate:(NSDate *)curDate {
	
	if (self = [super init]) {
        currentDate = curDate;
        scrollView = sView;
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay == NO"];
        events = [evts filteredArrayUsingPredicate:pred];
		
        if ([events count] > 0) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
			
			
            Event *firstEvent = [events objectAtIndex:0];
            
            NSDateComponents *componentsToPredicate = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[firstEvent startTime]];
            
            [componentsToPredicate setHour:[components hour]];
            [componentsToPredicate setMinute:[components minute]];
            
            pred = [NSPredicate predicateWithFormat:@"startTime >= %@",[[NSCalendar currentCalendar] dateFromComponents:componentsToPredicate]];
            
            NSArray *tempEvents = [events filteredArrayUsingPredicate:pred];
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
            [events sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            [tempEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            
            if ([tempEvents count] > 0)
                eventToScroll = (Event *)[tempEvents objectAtIndex:0];
			
            for (Event *e in events) {
                TdCalendarEventTile *eventTile = [[TdCalendarEventTile alloc] init];
                eventTile.event = e;
                
                [self addSubview:eventTile];
            }
        }
        
        timeStrings = [NSArray arrayWithObjects:@"00:00",@"01:00", @"02:00", @"03:00", @"04:00", @"05:00", @"06:00", @"07:00", @"08:00", @"09:00", @"10:00", @"11:00",@"12:00",@"13:00", @"14:00", @"15:00", @"16:00", @"17:00", @"18:00", @"19:00", @"20:00", @"21:00", @"22:00",@"23:00", @"00:00", nil];
        
	}
	
	return self;
}

- (BOOL)hasEvents {
	return ([events count] != 0);
}

- (void)layoutSubviews {
	NSMutableSet *done = [[NSMutableSet alloc] initWithCapacity:[self.subviews count]];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:
                                    (NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
                                                                   fromDate:currentDate];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    int count = 0;
    
	for (TdCalendarEventTile *tile in self.subviews)
	{    
        //NSLog(@"event %@",[tile.event title]);
        
		NSInteger nCollisions = 0;
		NSInteger nX = 0;
        
        NSDate *eventStartTime = tile.event.startTime;
        
        //NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //[df setDateFormat:@"EEE, dd MMM HH:mm"];
        
        //NSLog(@"eventStartTime %@",[df stringFromDate:eventStartTime]);
        //NSLog(@"dayStart %@",[df stringFromDate:dayStart]);
        
        if ([eventStartTime compare:dayStart] == NSOrderedAscending)
            eventStartTime = dayStart;
        
        NSDate *eventEndTime = tile.event.endTime;
        
        //NSLog(@"eventEndTime %@",[df stringFromDate:eventEndTime]);
        //NSLog(@"dayEnd %@",[df stringFromDate:dayEnd]);

        if ([eventEndTime compare:dayEnd] == NSOrderedDescending)
            eventEndTime = dayEnd;
        
		components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
													 fromDate:eventStartTime];
        
		NSInteger tileStart = 60 * [components hour] + [components minute];
        
		components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
													 fromDate:eventEndTime];
        
		NSInteger tileEnd = 60 * [components hour] + [components minute];
        
        components = [[NSCalendar currentCalendar] components: [ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | 
                                                                NSMinuteCalendarUnit | NSSecondCalendarUnit						
                                                     fromDate:eventStartTime];
        [components setHour:23];
        [components setMinute:59];
        [components setSecond:59];
        
        //when endDate is on the next date
        if ([[[NSCalendar currentCalendar] dateFromComponents:components] compare:eventEndTime] == NSOrderedAscending)
            tileEnd = 60 * 23 + 60;
        
        NSInteger nLocalColl = 0;
        NSInteger nLocalX = 0;

        if (tileEnd - tileStart <= 5) {
            components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                        fromDate:eventEndTime];
            
            [components setMinute:[components minute] + 5]; 
            tileEnd = 60 * [components hour] + [components minute];
            
        }
        
        for(Event *checkEvent in events) {
            NSDate *checkEventStartTime = checkEvent.startTime;
            
            if ([checkEventStartTime compare:dayStart] == NSOrderedAscending)
                checkEventStartTime = dayStart;
            
            NSDate *checkEventEndTime = checkEvent.endTime;
            
            if ([checkEventEndTime compare:dayEnd] == NSOrderedDescending)
                checkEventEndTime = dayEnd;
            
            if (![checkEvent isEqual:tile.event]) {   
                components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                             fromDate:checkEventStartTime];
                
                NSInteger checkTileStart = 60 * [components hour] + [components minute];
                
                components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                             fromDate:checkEventEndTime];
                
                NSInteger checkTileEnd = 60 * [components hour] + [components minute];
                
                components = [[NSCalendar currentCalendar] components: [ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | 
                              NSMinuteCalendarUnit | NSSecondCalendarUnit						
                                                             fromDate:checkEventStartTime];
                [components setHour:23];
                [components setMinute:59];
                [components setSecond:59];
                
                //when endDate is on the next date
                if ([[[NSCalendar currentCalendar] dateFromComponents:components] compare:checkEventEndTime] == NSOrderedAscending)
                    checkTileEnd = 60 * 23 + 60;
                                
                if (checkTileEnd - checkTileStart <= 5) {
                    components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit 
                                                                 fromDate:checkEventEndTime];
                    
                    [components setMinute:[components minute] + 5]; 
                    checkTileEnd = 60 * [components hour] + [components minute];
                }
                
				NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
															 fromDate:tile.event.startTime];
				
				NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
																				fromDate:checkEvent.startTime];
                
				if ([components1 hour] == [components2 hour]) {
                    nLocalColl++;
                 
                    if ([done containsObject:checkEvent]) {
                        nLocalX++;
					}
                }
            }
            
            nCollisions = (nLocalColl > nCollisions) ? nLocalColl : nCollisions;
            nX = (nLocalX > nX) ? nLocalX : nX;
        }
                
        if (nCollisions >= 1)
            nCollisions++;
        else
            nCollisions = 1;
        
        [done addObject:tile.event];   
        		
		CGFloat startPos = kTopLineBuffer + (tileStart / 60 ) * 2 * kHalfHourDiff - 2;
		startPos += ((tileStart % 60) / 60.0) * (kHalfHourDiff * 2.0);
		startPos = floor(startPos);
		
		CGFloat endPos = kTopLineBuffer + (tileEnd / 60 ) * 2 * kHalfHourDiff;
		endPos += ((tileEnd % 60) / 60.0) * (kHalfHourDiff * 2.0);
		endPos = floor(endPos);
        
        CGFloat tileHeight = endPos - startPos;
        if (tileHeight < kHalfHourDiff)
            tileHeight = kHalfHourDiff;
                
		CGFloat tileWidth = (self.bounds.size.width - kTileLeftSide -
							 kTileRightSide - kTileMargin * (nCollisions - 1)) / nCollisions;
        
		tile.frame = CGRectMake(kTileLeftSide + kTileMargin * (nCollisions - 1) + nX * tileWidth,
								startPos, tileWidth, tileHeight);
        
        if ([eventToScroll serverId] == [[tile event] serverId])
            scrollY = startPos;
        
        count++;
	}
}

- (void)drawRect:(CGRect)rect {
    // grab current graphics context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw hour lines
	CGContextSetShouldAntialias(ctx, NO);
	CGContextSetRGBStrokeColor(ctx, 192.0/255.0, 192.0/255.0, 192.0/255.0, 1.0);	
    for (NSInteger i = 0; i <= 24; i++) {
		CGFloat yVal = [self yValueForTime:(CGFloat)i];
		CGContextMoveToPoint(ctx, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(ctx, self.frame.size.width, yVal);
	}
	CGContextStrokePath(ctx);
    
    // draw half hour lines
	CGContextSetShouldAntialias(ctx, NO);
	const CGFloat dashPattern[2] = {1.0, 1.0};
	CGContextSetRGBStrokeColor(ctx, 192.0/255.0, 192.0/255.0, 192.0/255.0, 0.8);	
	CGContextSetLineDash(ctx, 0, dashPattern, 2);
	for (NSInteger i = 0; i < 24; i++) {
		CGFloat time = (CGFloat)i + 0.5f;
		CGFloat yVal = [self yValueForTime:time];
		CGContextMoveToPoint(ctx, kSideLineBuffer, yVal);
		CGContextAddLineToPoint(ctx, self.frame.size.width, yVal);
	}
	CGContextStrokePath(ctx);
    
    // draw hour tiles
    for (NSInteger i = 0; i <= 24; i++) {
        CGFloat yVal = [self yValueForTime:(CGFloat)i] - 10;
        
        CGContextMoveToPoint(ctx, 2.0, yVal);
        CGContextAddLineToPoint(ctx, 42.0, yVal);
        CGContextAddLineToPoint(ctx, 52.0, yVal + 10.0);
        CGContextAddLineToPoint(ctx, 42.0, yVal + 20.0);
        CGContextAddLineToPoint(ctx, 2.0, yVal + 20.0);
        CGContextAddLineToPoint(ctx, 2.0, yVal);
        
        CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0] CGColor]);
        CGContextFillPath(ctx);
    }

    // draw hour numbers
	CGContextSetShouldAntialias(ctx, YES);
    CGContextSetRGBFillColor(ctx, [ApplicationDelegate.uiSettings dayCalendarHoursColorRed], [ApplicationDelegate.uiSettings dayCalendarHoursColorGreen], [ApplicationDelegate.uiSettings dayCalendarHoursColorBlue], 1.0);	UIFont *numberFont = [UIFont fontWithName:[ApplicationDelegate.uiSettings dayCalendarHoursFont] size:[ApplicationDelegate.uiSettings dayCalendarHoursFontSize]];
	for (NSInteger i = 0; i <= 24; i++) {
		CGFloat yVal = [self yValueForTime:(CGFloat)i] - 10;
		NSString *hour = [timeStrings objectAtIndex:i];
		[hour drawAtPoint:CGPointMake(5.0, yVal + 1) withFont:numberFont];
        
        if ([hour isEqualToString:@"12:00"] && !eventToScroll)
            scrollY = yVal +1;
	}

    scrollX = 0.0;
    
    CGPoint offset = CGPointMake(scrollX, scrollY - 5.0);
    [scrollView setContentOffset:offset animated:YES];
}

- (CGFloat)yValueForTime:(CGFloat)time {
	return kTopLineBuffer + (44.0f * time);
}
@end

@implementation TdCalendarDayView

@synthesize currentSelectDate;
@synthesize currentTime;
@synthesize calendarDayViewDelegate, todate;
@synthesize currentDate;
@synthesize events;

@synthesize allDayEventsView;
@synthesize dayEventsView;
@synthesize dayEventsScrollView;


-(void)initCalView{
	currentTime=CFAbsoluteTimeGetCurrent();
    //TODO check how to obtain correct timezone
    currentSelectDate=CFAbsoluteTimeGetGregorianDate(currentTime, CFTimeZoneCopyDefault());

    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    self.todate = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(currentSelectDate, timeZone)];
    
    //set the default calendar type
	calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[calendar setLocale:[NSLocale currentLocale]];
    
	// set today
	today = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
	
	//set the current day to show the calendar
	NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[NSDate date]];    
	self.currentDate = [calendar dateFromComponents:components];

    self.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]]; 
}

- (void)reloadData {
    if (!events)
        events = [calendarDayViewDelegate calendarEventsForDate:currentDate];
      
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAllDay == YES"];
    NSUInteger allDayEventsCount = [[events filteredArrayUsingPredicate:pred] count];
    
    if (allDayEventsCount > 0) {
        allDayEventsView = [[TdCCalendarAllDayEventsView alloc] initWithEvents:events];
        allDayEventsView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 60.0);
        allDayEventsView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]]; 
        allDayEventsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:allDayEventsView];
    } else {
        [allDayEventsView removeFromSuperview];
        allDayEventsView.frame = CGRectZero;
    }
    
    // create scroll view
	dayEventsScrollView = [[UIScrollView alloc] init];
	dayEventsScrollView.backgroundColor = [UIColor clearColor];
	dayEventsScrollView.frame = CGRectMake(0, allDayEventsView.frame.size.height, self.frame.size.width,
                                           self.frame.size.height - allDayEventsView.frame.size.height);
	dayEventsScrollView.contentSize = CGSizeMake(self.frame.size.width, 44.0 * 25 + 40.0);
	dayEventsScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self addSubview:dayEventsScrollView];
    
    dayEventsView = [[TdCCalendarDayEventsView alloc] initWithEvents:events scrollView:dayEventsScrollView currentDate:currentDate];
	dayEventsView.frame = CGRectMake(0, 0, self.frame.size.width, 1080);
    dayEventsView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]]; 
	dayEventsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[dayEventsScrollView addSubview:dayEventsView];
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

- (void) movePrevNext:(int)isPrev{
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
    
	if(viewImageView == nil)
	{
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
    
    events = [calendarDayViewDelegate calendarEventsForDate:currentDate];
    [self reloadData];    
}

- (void) movePrevDay{
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day -= 1;
    
	self.currentDate = [calendar dateFromComponents:components];
	[self movePrevNext:0];
}

- (void) moveNextDay{
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:currentDate];
	components.day += 1;
    
	self.currentDate = [calendar dateFromComponents:components];
	[self movePrevNext:1];
}

-(void)setToday {
    NSDateComponents *components = [calendar components:[ApplicationDelegate.uiSettings units] fromDate:[NSDate date]];    
    today = [calendar dateFromComponents:components];
    
    if ([today compare:currentDate] == NSOrderedAscending) {
        currentDate = today;
        [self movePrevNext:0];
    } else  if ([today compare:currentDate] == NSOrderedDescending) {
        currentDate = today;
        [self movePrevNext:1];
    }
}

@end
