//
//  Group.h
//  Timepass
//
//  Created by Christos Skevis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, User;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *userId;
@property (nonatomic, retain) NSSet *eventId;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addUserIdObject:(User *)value;
- (void)removeUserIdObject:(User *)value;
- (void)addUserId:(NSSet *)values;
- (void)removeUserId:(NSSet *)values;
- (void)addEventIdObject:(Event *)value;
- (void)removeEventIdObject:(Event *)value;
- (void)addEventId:(NSSet *)values;
- (void)removeEventId:(NSSet *)values;
@end
