//
//  EventMessage+GAE.m
//  Timepass
//
//  Created by Christos Skevis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventMessage+GAE.h"
#import "Utils.h"

static NSString *entityName = @"EventMessage";

@implementation EventMessage (GAE)

+ (NSArray *) getMessages:(NSArray *)response forEvent:(Event *) event {
    return [EventMessage parseGAEMesasges:response forEvent:event];
}

+ (NSArray *) parseGAEMesasges:(NSArray *)response forEvent:(Event *) event {
    
    NSArray *listItems = [[response valueForKey:@"messages"] objectAtIndex:0];
    
    //check if no messages
    if([listItems count] < 1) 
        return nil;

    //parse to array of dictionarys
    NSMutableArray * messagesArray = [[NSMutableArray alloc] init]; 
    
    EventMessage *message;
    [event setMessageId:nil];
    
    NSManagedObjectContext *context = [modelUtils defaultManagedObjectContext];
    
    if (![event.creatorId isEqual:[[SingletonUser sharedUserInstance] user]])
        context = [[Utils sharedUtilsInstance] scratchPad];

    for (NSDictionary *messageArray in listItems)
    {
        message = (EventMessage *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        [message setText:[messageArray valueForKey:@"content"]];
        [message setDateCreated:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[messageArray objectForKey:@"dateCreated"]]]];
        //changed the response to have GMT dates so we convert them now to local
        //NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        //message.dateCreated = [NSDate dateWithTimeInterval:(double) destinationTimeZone.secondsFromGMT sinceDate:message.dateCreated];

        //debugLog(@"message text : %@", message.text);
        User *user;
        user = [User getUserWithId:[messageArray objectForKey:@"creator"] inContext:context];
        
        [message setUserId:user];
        
        [messagesArray addObject:message];
    }
    
    //[event addMessageId:[NSSet setWithArray:messagesArray]];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    [messagesArray sortUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];

    return messagesArray;
}

@end