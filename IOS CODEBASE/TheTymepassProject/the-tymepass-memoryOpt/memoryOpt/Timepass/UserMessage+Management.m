//
//  UserMessage+Management.m
//  Timepass
//
//  Created by jason on 19/10/12.
//
//

#import "UserMessage+Management.h"

@implementation UserMessage (Management)

static NSString *entityName = @"UserMessage";

+ (UserMessage *)getUserMessageWithId:(NSString *)messageId {
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId == %@", messageId];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"serverId" ascending:YES]];
    
    UserMessage *message = (UserMessage *)[modelUtils fetchManagedObject:entityName
												 predicate:predicate
										   sortDescriptors:sortDescriptors
													   moc:[modelUtils defaultManagedObjectContext]];
    if (message)
        return message;
    else {
		
		message = (UserMessage *)[NSEntityDescription insertNewObjectForEntityForName:entityName
															   inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
        return message;
	}
}

+ (NSMutableArray *) getMessages: (User *) user {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fromUserId == %@ OR toUserId = %@) AND (fromUserId == %@ OR toUserId = %@)", user, user, [[SingletonUser sharedUserInstance] user], [[SingletonUser sharedUserInstance] user]];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
	
    NSMutableArray * result = [[NSMutableArray alloc] initWithArray:[modelUtils fetchManagedObjects:entityName
																						  predicate:predicate
																					sortDescriptors:sortDescriptors
																								moc:[modelUtils defaultManagedObjectContext]]];
    return result;
}

@end