//
//  Event.m
//  Timepass
//
//  Created by Christos Skevis on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "EventMessage.h"
#import "Group.h"
#import "Location.h"
#import "User.h"


@implementation Event

@dynamic iCalId;
@dynamic title;
@dynamic isGold;
@dynamic isAllDay;
@dynamic endTime;
@dynamic isPrivate;
@dynamic info;
@dynamic dateCreated;

@dynamic reminder;
@dynamic reminderDate;

@dynamic recurring;
@dynamic recurranceEndTime;
@dynamic serverId;
@dynamic parentServerId;
@dynamic attending;
@dynamic isStealth;
@dynamic isOpen;
@dynamic dateModified;
@dynamic isEditable;
@dynamic photo;
@dynamic startTime;
@dynamic creatorId;
@dynamic locationId;
@dynamic messageId;
@dynamic invitedBy;
@dynamic groupId;
@dynamic userId;
@dynamic startDate;
@synthesize busy;

@dynamic isTymePassEvent;

@synthesize saveCurrentEvent;
@synthesize photoChange;
@synthesize photoData;

-(NSDate *) startDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self startTime]];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

-(NSDate *) endDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[self endTime]];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end
