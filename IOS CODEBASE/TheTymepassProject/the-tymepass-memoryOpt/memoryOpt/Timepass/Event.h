//
//  Event.h
//  Timepass
//
//  Created by Christos Skevis on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventMessage, Group, Location, User;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * iCalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * isGold;
@property (nonatomic, retain) NSNumber * isAllDay;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSDate * dateCreated;

@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSDate * reminderDate;

@property (nonatomic, retain) NSNumber * recurring;
@property (nonatomic, retain) NSDate * recurranceEndTime;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * parentServerId;
@property (nonatomic, retain) NSNumber * attending;
@property (nonatomic, retain) NSNumber * isStealth;
@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * isEditable;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * photoChange;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) User *creatorId;
@property (nonatomic, retain) Location *locationId;
@property (nonatomic, retain) NSSet *messageId;
@property (nonatomic, retain) User *invitedBy;
@property (nonatomic, retain) NSSet *groupId;
@property (nonatomic, retain) User *userId;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * busy;

@property (nonatomic, retain) NSNumber * isTymePassEvent;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSNumber * saveCurrentEvent;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addMessageIdObject:(EventMessage *)value;
- (void)removeMessageIdObject:(EventMessage *)value;
- (void)addMessageId:(NSSet *)values;
- (void)removeMessageId:(NSSet *)values;
- (void)addGroupIdObject:(Group *)value;
- (void)removeGroupIdObject:(Group *)value;
- (void)addGroupId:(NSSet *)values;
- (void)removeGroupId:(NSSet *)values;
@end
