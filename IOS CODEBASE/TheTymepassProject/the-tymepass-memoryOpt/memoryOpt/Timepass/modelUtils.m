//
//  modelUtils.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "modelUtils.h"

@implementation modelUtils

+ (NSManagedObjectContext*) defaultManagedObjectContext{
	NSManagedObjectContext *moc = nil;
	
	id appDelegate = [[UIApplication sharedApplication] delegate];
	if ([appDelegate respondsToSelector:@selector(managedObjectContext)]) {
		moc = [appDelegate managedObjectContext];
	}
	
	return moc;
}

+ (BOOL) commitDefaultMOC{
	NSManagedObjectContext *moc = [modelUtils defaultManagedObjectContext];
	NSError *error = nil;
	if (![moc save:&error]) {
		// Save failed
		NSLog(@"Core Data Save Error: %@, %@", error, [error userInfo]);
		return NO;
	}
	return YES;
}

+ (void) rollbackDefaultMOC{
	NSManagedObjectContext *moc = [modelUtils defaultManagedObjectContext];
	[moc rollback];
}

+ (void) deleteManagedObjectFromDefaultMOC:(NSManagedObject *)managedObject{
	NSManagedObjectContext *moc = [modelUtils defaultManagedObjectContext];
	[moc deleteObject:managedObject];
}

+ (NSArray *) fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *) predicate sortDescriptors:(NSArray *)sortDescriptors moc:(NSManagedObjectContext *)moc
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults == nil) {
		// Handle the error.
		NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}
	
	return fetchResults;
}

+ (NSArray *) fetchManagedObjects:(NSString *)entityName predicate:(NSPredicate *) predicate sortDescriptors:(NSArray *)sortDescriptors offset:(NSInteger)offset moc:(NSManagedObjectContext *)moc
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	[fetchRequest setFetchOffset:offset];
	[fetchRequest setFetchLimit:50];
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults == nil) {
		// Handle the error.
		NSLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}
	
	return fetchResults;
}

+ (NSManagedObject *) fetchManagedObject:(NSString *) entityName predicate:(NSPredicate *) predicate sortDescriptors: (NSArray *) sortDescriptors moc: (NSManagedObjectContext *)moc
{
	NSArray *fetchResults = [modelUtils fetchManagedObjects:entityName predicate:predicate sortDescriptors:sortDescriptors moc:moc];
	
	NSManagedObject *managedObject = nil;
	
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		managedObject = [fetchResults objectAtIndex:0];
	}
	
	return managedObject;	
}

+ (int) checkIfObjectIfType:(NSString *) entityName existsforRequest:(NSString *) predicateString inContext:(NSManagedObjectContext *) context{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [request setPredicate:predicate];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:request error:&error];
    
    if (!error){
        return count;
    }
    else
        return 0;

}

@end
