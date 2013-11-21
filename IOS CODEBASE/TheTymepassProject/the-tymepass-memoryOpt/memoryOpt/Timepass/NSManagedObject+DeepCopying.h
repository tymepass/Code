//
//  NSManagedObject+DeepCopying.h
//  Timepass
//
//  Created by jason on 03/11/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (RXCopying) <NSCopying>

-(void)setRelationshipsToObjectsByIDs:(id)objects;

-(id)deepCopyWithZone:(NSZone *)zone;
-(NSDictionary *)ownedIDs;

@end
