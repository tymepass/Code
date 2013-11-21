//
//  Event+Management.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "modelUtils.h"
#import "Location.h"
#import "EventMessage+Management.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface Event (Management)

+ (Event *)createEventWithTitle:(NSString *) title
                           info:(NSString *) info
                      startTime:(NSDate *) startTime
                        endTime:(NSDate *)endTime
                         isGold:(NSNumber *) isGold
                         iCalId:(NSString *) iCalId
                      recurring:(NSNumber *) recurring
			   recurringEndDate:(NSDate *) recurringEndDate
                       serverId:(NSString *) serverId
                          photo:(NSString *) photo
                     isEditable:(NSNumber *) isEditable
                       isAllDay:(NSNumber *) isAllDay
                      attending:(NSNumber *) attending
                      isPrivate:(NSNumber *) isPrivate
						 isOpen:(NSNumber *) isOpen
				isTymePassEvent:(NSNumber *)isTymePassEvent
                      messageId:(EventMessage *)messageId
                     locationId:(Location *)locationId
                        creator:(User *)creatorId
                           user:(User *)userId
                       reminder:(NSNumber *) reminder
				   reminderTime:(float) reminderTime
				   reminderDate:(NSDate *) reminderDate
                   dateModified:(NSDate *) dateModified
                    dateCreated:(NSDate *) dateCreated
                    invitations:(NSMutableArray *) friendsArray
                  eventMessages:(NSMutableArray *) eventMessages
                    privateFrom:(NSMutableArray *) privateFromFriendsArray;

+ (Event *)parseGAEEventInviteWithTitle:(NSString *)title
                                   info:(NSString *)info
                              startTime:(NSString *)startTime
                                endTime:(NSString *) endTime
                                 isGold:(NSNumber *) isGold
                                  photo:(NSString *) photo
							   reminder:(NSNumber *) reminder
						   reminderDate:(NSString *) reminderDate
                              recurring:(NSNumber *) recurring
					   recurringEndDate:(NSString *) recurringEndDate
                               serverId:(NSString *) serverId
						 parentServerId:(NSString *)parentServerId
                               messages:(NSArray *) messages
                                 allDay:(NSNumber *)isAllDay
                              attending:(NSNumber *) attending
                              isPrivate:(NSNumber *) isPrivate
                                 isOpen:(NSNumber *) isOpen
						isTymepassEvent:(NSNumber *) isTymepassEvent
                              isStealth:(NSNumber *) isStealth
                             locationId:(Location *)locationId
                                creator:(User *)creatorId
                                   user:(User *)userId
                                 iCalId:(NSString *) iCalId
                                   busy:(NSNumber *) busy
                           dateModified:(NSString *) dateModified
                            dateCreated:(NSString *) dateCreated
                              invitedBy:(User *)invitedByUser
                                context:(NSManagedObjectContext *) context;

+ (void)updateEvent:(Event *)currentEvent
          withTitle:(NSString *)title
               info:(NSString *)info
          startTime:(NSDate *) startTime
            endTime:(NSDate *) endTime
             isGold:(NSNumber *) isGold
              photo:(NSString *) photo
          recurring:(NSNumber *) recurring
   recurringEndDate:(NSDate *) recurringEndDate
           location:(Location *)location
           isAllDay:(NSNumber *)isAllDay
         isEditable:(NSNumber *)isEditable
          isPrivate:(NSNumber *) isPrivate
             isOpen:(NSNumber *) isOpen
           reminder:(NSNumber *) reminder
	   reminderTime:(float) reminderTime
	   reminderDate:(NSDate *) reminderDate;

+ (Event *)getEventWithId:(NSString *)eventId;
+ (void) deleteAllEvents;

+ (NSArray *) getAgendaEvents;
+ (NSArray *) getAgendaEvents:(NSInteger)offset;
+ (NSArray *) getAgendaEventsForDay:(NSDate *) selectedDay;

+ (NSArray *) getAllEvents;
+ (NSArray *) getChildEvents:(Event *)event;

+ (NSUInteger) getTotalNumberAgendaEventsForDay:(NSDate *) selectedDay;
+ (NSArray *) getMonthEventsForPeriod:(NSDate *) startDate endDate:(NSDate *) endDate;
+ (NSArray *) getDayEventsForDay:(NSDate *) selectedDay;

+ (Event *) getEventWithICalId:(NSString *) eventIdentifier;

+ (NSNumber *) getPendingEventsCount: (User *) user;
+ (NSMutableArray *) getPendingEvents: (User *) user;
+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset;
+ (NSMutableArray *) getPendingEventsForPending: (User *) user offset:(NSInteger)offset;
+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset condition:(NSString *)conditions;
+ (NSMutableArray *) getPendingEvents: (User *) user offset:(NSInteger)offset index:(NSNumber *)index;

+ (NSMutableArray *) getGoldStarredEvents: (User *) user;
+ (NSMutableArray *) getGoldStarredEvents: (User *) user offset:(NSInteger)offset;

+ (int) getGoogleCalendarFromStore:(EKEventStore *) eventStore;
+ (NSArray *)getEventIdsOfUser:(User *)user;

+(void)addRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds;
+(NSArray *)addRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds inContext:(NSManagedObjectContext *) context;
+(void)updateRecurringEvent:(Event *)currentEvent serverIds:(NSArray *)serverIds;

@end