//
//  User+Management.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "ModelUtils.h"

@interface User (Management)

+ (User *)insertUserWithEmail:(NSString *)email
                         name:(NSString *)name
                      surname:(NSString *)surname
                     password:(NSString *) password
                   datOfBirth:(NSDate *) birthdate
                   occupation:(NSString *) occupation
                       gender:(NSNumber *) gender
                        photo:(NSString *) photo
               homeLocationId:(Location *)locationId
                   facebookId:(NSString *)fbId;

+ (User *)insertUserWithEmail:(NSString *)email
                         name:(NSString *)name
                      surname:(NSString *)surname
                     password:(NSString *) password
                   datOfBirth:(NSDate *) birthdate
                   occupation:(NSString *) occupation
                       gender:(NSNumber *) gender
                        photo:(NSString *) photo
               homeLocationId:(Location *)locationId
                    TwitterId:(NSString *)Tid;


+ (User *) getUserWithTwitterId:(NSString *)twitterId;
+ (User *)getUserWithEmail:(NSString *)email;
+ (User *) getUserWithId:(NSString *)serverId inContext:(NSManagedObjectContext *) context;
+ (User *) loginUser: (NSString *) email password:(NSString *) password;
+ (User *)saveUserWithEmail:(NSString *)email
                       name:(NSString *)name
                    surname:(NSString *)surname
                   password:(NSString *) password
                dateOfBirth:(NSDate *) birthdate
                 occupation:(NSString *) occupation
                     gender:(NSNumber *) gender
                      photo:(NSString *) photo
             homeLocationId: (Location *) locationId
                 facebookId:(NSString *) facebookId
				  twitterId:(NSString *) twitterId
                   serverId:(NSString *) serverId
                dateCreated:(NSDate *)dateCreated
               dateModified:(NSDate *) dateModified
                  inContext:(NSManagedObjectContext *) context;
+ (BOOL)unfriend:(NSString *)friendId with:(NSString *)myId;
+ (NSArray *) getUsersToSync;
+ (User *) checkExistsInCD:(NSString *) serverId inContext:(NSManagedObjectContext *) context;
+ (User *) checkExistsByEmailInCD:(NSString *) email inContext:(NSManagedObjectContext *) context;
+ (User *) checkExistsByTwitterIdInCD:(NSString *) email inContext:(NSManagedObjectContext *) context;
+ (NSArray *) getMyFriends;
+ (BOOL)updateUser:(User *)currentUser
          withName:(NSString *)name
           surname:(NSString *)surname
          password:(NSString *) password
       dateOfBirth:(NSDate *) birthdate
        occupation:(NSString *) occupation
            gender:(NSNumber *) gender
             photo:(NSString *) photo
    homeLocationId:(Location *) locationId
		facebookId:(NSString *) facebookId
		 twitterId:(NSString *) twitterId
      dateModified:(NSDate *) dateModified
         updateGAE:(BOOL) updateGAE;

+ (BOOL)updateUser:(User *)currentUser
          withName:(NSString *)name
           surname:(NSString *)surname
			 email:(NSString *) email
		  password:(NSString *) password
       dateOfBirth:(NSDate *) birthdate
        occupation:(NSString *) occupation
            gender:(NSNumber *) gender
             photo:(NSString *) photo
    homeLocationId:(Location *) locationId
		facebookId:(NSString *) facebookId
		 twitterId:(NSString *) twitterId
      dateModified:(NSDate *) dateModified
         updateGAE:(BOOL) updateGAE;

+ (NSMutableArray *) getFriendsOfUser:(User *) user;
@end
