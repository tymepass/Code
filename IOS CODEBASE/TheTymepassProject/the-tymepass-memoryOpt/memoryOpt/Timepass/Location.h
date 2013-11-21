//
//  Location.h
//  Timepass
//
//  Created by Christos Skevis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, User;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSDecimalNumber * lon;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) User *userHome;
@property (nonatomic, retain) User *user;

@end
