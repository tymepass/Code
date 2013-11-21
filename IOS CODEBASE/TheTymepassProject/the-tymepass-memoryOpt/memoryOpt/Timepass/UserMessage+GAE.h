//
//  UserMessage+GAE.h
//  Timepass
//
//  Created by jason on 18/10/12.
//
//

#import "UserMessage.h"
#import "SBJson.h"
#import "GAEUtils.h"

@interface UserMessage (GAE)

+ (NSArray *) getMessages:(NSArray *)response forUser:(User *) user;
+ (NSArray *) parseGAEMesasges:(NSArray *) responseArray forUser:(User *) user;

@end