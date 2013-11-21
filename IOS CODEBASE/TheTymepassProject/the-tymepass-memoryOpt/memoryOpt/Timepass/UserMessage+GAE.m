//
//  UserMessage+GAE.m
//  Timepass
//
//  Created by jason on 18/10/12.
//
//

#import "UserMessage+GAE.h"
#import "UserMessage+Management.h"
#import "Utils.h"

//static NSString *entityName = @"UserMessage";

@implementation UserMessage (GAE)

+ (NSArray *) getMessages:(NSArray *)response forUser:(User *)user {
    return [UserMessage parseGAEMesasges:response forUser:user];
}

+ (NSArray *) parseGAEMesasges:(NSArray *)response forUser:(User *)user {
    
    NSArray *listItems = [[response valueForKey:@"message"] objectAtIndex:0];
    
    //check if no messages
    if([listItems count] < 1)
        return nil;
	
    //parse to array of dictionarys
    NSMutableArray * messagesArray = [[NSMutableArray alloc] init];
    NSManagedObjectContext *context = [modelUtils defaultManagedObjectContext];
	
    for (NSDictionary *messageArray in listItems) {
		
		UserMessage *message = [UserMessage getUserMessageWithId:[messageArray valueForKey:@"id"]];
		[message setServerId:[NSString stringWithFormat:@"%@", [messageArray valueForKey:@"id"]]];
        [message setText:[messageArray valueForKey:@"message"]];
		
		[message setTimeStamp:[NSNumber numberWithInt:[[messageArray objectForKey:@"id"] intValue]]];
        [message setDateCreated:[GAEUtils parseTimeStampFromGAE:[messageArray objectForKey:@"dateCreated"]]];
        
		if ([[messageArray objectForKey:@"fromUser"] isEqualToString:[user serverId]]) {
			
			User *user = [User getUserWithId:[messageArray objectForKey:@"fromUser"] inContext:context];
			[message setFromUserId:user];
			[message setToUserId:[[SingletonUser sharedUserInstance] user]];
			
		} else {
			
			User *user = [User getUserWithId:[messageArray objectForKey:@"toUser"] inContext:context];
			[message setFromUserId:[[SingletonUser sharedUserInstance] user]];
			[message setToUserId:user];
			
		}
		
		[modelUtils commitDefaultMOC];
        [messagesArray addObject:message];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    [messagesArray sortUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor, nil]];
	
    return messagesArray;
}

@end