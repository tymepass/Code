//
//  modelUtils.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface modelUtils : NSObject

+ (NSManagedObjectContext*) defaultManagedObjectContext;

+ (BOOL) commitDefaultMOC;

+ (void) rollbackDefaultMOC;

+ (void) deleteManagedObjectFromDefaultMOC:(NSManagedObject *)managedObject;

+ (NSArray *) fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *) predicate sortDescriptors:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc;

+ (NSArray *) fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *) predicate sortDescriptors:(NSArray *)sortDescriptors offset:(NSInteger)offset moc:(NSManagedObjectContext *)moc;

+ (NSManagedObject *) fetchManagedObject:(NSString *) entityName predicate:(NSPredicate *) predicate sortDescriptors: (NSArray *) sortDescriptors moc: (NSManagedObjectContext *)moc;

+ (int) checkIfObjectIfType:(NSString *) entity existsforRequest:(NSString *) request inContext:(NSManagedObjectContext *) context;
@end


