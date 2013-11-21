//
//  EventMessage.h
//  Timepass
//
//  Created by Christos Skevis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, User;

@interface EventMessage : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) Event *eventId;
@property (nonatomic, retain) User *userId;

@end
