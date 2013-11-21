//
//  Event+GAE.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "SBJson.h"
#import "GAEUtils.h"

@interface Event (GAE)
+ (NSArray *) getGAEEventWithIds:(NSArray *) eventId inContext:(NSManagedObjectContext *) context;
+ (NSArray *) getGAEEventWithIds:(NSArray *) eventId attendingEventStatus:(NSArray *)eventAttendingArray inContext:(NSManagedObjectContext *) context;

+ (NSArray *) parseEventsDictsFromArray:(NSArray *) listItems inContext:(NSManagedObjectContext *) context;
+ (NSArray *) parseEventsDictsFromArray:(NSArray *) listItems attendingEventStatus:(NSArray *)eventAttendingArray inContext:(NSManagedObjectContext *) context;

+ (NSArray *) getGAEMonthEventsForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate andUser:(NSString *)friendId inContext:(NSManagedObjectContext *) context;

+ (Event *) createEventFromDictionary:(NSDictionary *) event inContext:(NSManagedObjectContext *) context;

+ (NSArray *) deleteGAEEventWithIds:(NSArray *) eventId;
+ (NSArray *) checkGAEEventWithIds:(NSArray *) eventId;

+ (Event *) getGAEEventWithId:(NSString *)serverId CDEvent:(Event *) CDEvent inContext:(NSManagedObjectContext *) context;
+ (Event *) parseGAEEventFromJSON:(NSArray *) response CDEvent:(Event *) CDEvent inContext:(NSManagedObjectContext *) context;

+ (NSArray *) getStealthFrom:(NSArray *)response;
+ (NSArray *) parseGAEStealthFrom:(NSArray *)response;
@end
