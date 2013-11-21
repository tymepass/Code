//
//  TdCalendarEvent.m
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarEvent.h"

@implementation TdCalendarEvent

@synthesize eventName;
@synthesize eventDescription;
@synthesize startDate;
@synthesize endDate;
@synthesize allDayEvent;

- (id)init {
	if (self = [super init]) {
    }
	
	return self;
}

@end
