//
//  TdCalendarEvent.h
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TdCalendarEvent : NSObject {
	NSString *eventName;
	NSString *eventDescription;
	NSDate *startDate;
	NSDate *endDate;
	BOOL allDayEvent;
}

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;
@property (nonatomic) BOOL allDayEvent;

@end
