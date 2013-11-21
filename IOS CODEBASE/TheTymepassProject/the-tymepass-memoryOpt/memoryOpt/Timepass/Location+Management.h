//
//  Location+Management.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "modelUtils.h"

@interface Location (Management)
+ (Location *)insertLocationWithName:(NSString *)name inContext:(NSManagedObjectContext *) context;
+ (Location *)getLocationWithName:(NSString *)name inContext:(NSManagedObjectContext *) context;
@end
