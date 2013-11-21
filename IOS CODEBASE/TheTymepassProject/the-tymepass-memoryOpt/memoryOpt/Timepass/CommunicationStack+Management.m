//
//  CommunicationStack+Management.m
//  Timepass
//
//  Created by Christos Skevis on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommunicationStack+Management.h"
static NSString *entityName = @"CommunicationStack";

@implementation CommunicationStack (Management)
+ (CommunicationStack *)insertRequestWithJSON:(NSString *)json andURL:(NSString *)url{
    CommunicationStack *request = (CommunicationStack *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [request setUrl:url];
    [request setJson:json];
    [modelUtils commitDefaultMOC];
    return request;
}
+ (NSArray *) fetchCommunicationStackObjects{
    NSArray *requests = [modelUtils fetchManagedObjects:entityName predicate:nil sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    return requests;
}
@end
