//
//  CommunicationStack.h
//  Timepass
//
//  Created by Christos Skevis on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CommunicationStack : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * json;

@end
