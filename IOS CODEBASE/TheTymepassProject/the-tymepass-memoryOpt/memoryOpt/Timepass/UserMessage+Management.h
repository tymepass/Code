//
//  UserMessage+Management.h
//  Timepass
//
//  Created by jason on 19/10/12.
//
//

#import "UserMessage.h"
#import "User.h"
#import "ModelUtils.h"

@interface UserMessage (Management)

+ (UserMessage *)getUserMessageWithId:(NSString *)messageId;
+ (NSMutableArray *) getMessages: (User *) user;

@end
