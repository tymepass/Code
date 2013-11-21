//
//  User+GAEUser.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "SBJson.h"
#import "GAEUtils.h"

@interface User (GAEUser)
+ (User *)getGAEUserWithTwitterId:(NSString *)twitterId;
+ (User *)getGAEUserWithEmail:(NSString *)email;
+ (User *) parseGAEUsersFromListString: (NSString *) list;
+ (User *) loginGAEUser: (NSString *) email password:(NSString *) password;
+ (BOOL)unfriendGAEUser:(NSString *)friendId with:(NSString *)myId;

//Friends
+ (NSArray *) getFriends:(NSArray *)response;
+ (NSArray *) getTwitterUsers:(NSArray *)response;
+ (NSArray *) parseGAEUsers:(NSArray *) responseArray;

//Newsreel
+ (NSArray *) getNewsreel:(NSArray *)response;
+ (NSArray *) parseGAENewsreel:(NSArray *) responseArray;
//NewsreelPage
+ (NSArray *) getNewsreelPage:(NSArray *)response;
+ (NSArray *) parseGAENewsreelPage:(NSArray *) responseArray;

//UpcomingEvents
+ (NSArray *) getUpcomingEvents:(NSArray *)response andStore:(NSManagedObjectContext *) context;
+ (NSArray *) parseGAEUpcomingEvents:(NSArray *) responseArray andStore:(NSManagedObjectContext *) context;

+ (User *) getGAEUserWithId:(NSString *)serverId CDUser:(User *) CDUser inContext:(NSManagedObjectContext *) context;
+ (User *) parseGAEUserFromJSON:(NSArray *) response CDUser:(User *) CDUser inContext:(NSManagedObjectContext *) context;
@end
