//
//  Location+Management.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Location+Management.h"

static NSString *entityName = @"Location";

@implementation Location (Management)

+ (Location *)insertLocationWithName:(NSString *)name inContext:(NSManagedObjectContext *) context{
    Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    
    [location setName:name];
    [location setLat:0];
    [location setLon:0];
    //[modelUtils commitDefaultMOC];
    
    return location;
}

+ (Location *)getLocationWithName:(NSString *)name inContext:(NSManagedObjectContext *) context{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    Location *location = (Location *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:context];
    
    return location;
}

@end
