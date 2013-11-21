//
//  User+Management.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User+Management.h"
#import "User+GAEUser.h"
#import "Utils.h"

static NSString *entityName = @"User";

@implementation User (Management)

+ (User *)insertUserWithEmail:(NSString *)email
                         name:(NSString *)name
                      surname:(NSString *)surname
                     password:(NSString *) password
                   datOfBirth:(NSDate *) birthdate
                   occupation:(NSString *) occupation
                       gender:(NSNumber *) gender
                        photo:(NSString *) photo
               homeLocationId:(Location *)locationId
                   facebookId:(NSString *)fbId {

    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    
    user.email = email;
    user.name = name;
    user.surname = surname;
    user.password = password;
    
    if (birthdate)
        user.dateOfBirth = birthdate;
    
    user.occupation = occupation;
    user.photo = photo;
    user.gender = [NSNumber numberWithInt:[gender intValue]];
    user.homeLocationId = locationId;
    user.facebookId = fbId;
    user.twitterId = @"-1";
    user.dateModified = [NSDate date];
    user.dateCreated = [NSDate date];
    
    return user;
}


+ (User *)insertUserWithEmail:(NSString *)email
                         name:(NSString *)name
                      surname:(NSString *)surname
                     password:(NSString *) password
                   datOfBirth:(NSDate *) birthdate
                   occupation:(NSString *) occupation
                       gender:(NSNumber *) gender
                        photo:(NSString *) photo
               homeLocationId:(Location *)locationId
                   TwitterId:(NSString *)Tid {
    
    User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    
    user.email = email;
    user.name = name;
    user.surname = surname;
    user.password = password;
    
    if (birthdate)
        user.dateOfBirth = birthdate;
    
    user.occupation = occupation;
    user.photo = photo;
    user.gender = [NSNumber numberWithInt:[gender intValue]];
    user.homeLocationId = locationId;
    NSLog(@"%@",Tid);
    user.twitterId = [NSString stringWithFormat:@"%@",Tid];
    user.facebookId = @"-1";
    user.dateModified = [NSDate date];
    user.dateCreated = [NSDate date];
    
    return user;
}

+ (User *) checkExistsInCD:(NSString *) serverId inContext:(NSManagedObjectContext *) context{
    //check if exists in CoreData
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:context];
    if (user) {
        //debugLog(@"User exists in Core Data");
        return user;
    }
    return nil;
}

+ (User *) checkExistsByEmailInCD:(NSString *) email inContext:(NSManagedObjectContext *) context{
    //check if exists in CoreData
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:context];
    return user;
}

+ (User *) checkExistsByTwitterIdInCD:(NSString *) twitterId inContext:(NSManagedObjectContext *) context{
    //check if exists in CoreData
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twitterId == %@", twitterId];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:context];
    return user;
}

+ (User *) getUserWithEmail:(NSString *)email{
    if (!email)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (!user)
       user = [User getGAEUserWithEmail:email];

    return user;
}

+ (User *) getUserWithTwitterId:(NSString *)twitterId{
    if (!twitterId)
        return nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"twitterId == %@", twitterId];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (!user)
        user = [User getGAEUserWithTwitterId:twitterId];
    
    return user;
}

//use this function if you do not want to save the user in core data
+ (User *) getUserWithId:(NSString *)serverId inContext:(NSManagedObjectContext *) context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:context];
    
    if (!user)
        user = [User getGAEUserWithId:serverId CDUser:nil inContext:context];
    
    return user;
}

+ (User *) loginUser: (NSString *) email password:(NSString *) password{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@ AND password == %@", email, password];
 
    User *user = (User *)[modelUtils fetchManagedObject:entityName predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (!user)
        user = [User loginGAEUser:email password:password];
    
    return user;
}

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
                  inContext:(NSManagedObjectContext *) context{
    User *user;
    //check if exists in cd
    if ([modelUtils checkIfObjectIfType:@"User" existsforRequest:[NSString stringWithFormat:@"serverId = '%@'", serverId] inContext:context] > 0) {
        //fetch the user
        user = [User checkExistsInCD:serverId inContext:context];
        return user;
    }
    user = (User *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    user.email = email;
    user.name = name;
    user.surname = surname;
    user.password = password;
    
    if (birthdate)
        user.dateOfBirth = birthdate;
    
    user.occupation = occupation;
    
    if (photo && [photo length] > 0)
        user.photo = photo;
	
    
    user.gender = gender;
    
    if (locationId)
        user.homeLocationId = locationId;
    
    user.facebookId = facebookId;
	user.twitterId = twitterId;
    user.serverId = serverId;
    user.dateCreated = dateCreated;
    user.dateModified = dateModified;
    
    return user;
}


+ (BOOL)unfriend:(NSString *)friendId with:(NSString *)myId{
    //TODO implement in coredata
    
    //implement it in GAE
    
    return [User unfriendGAEUser:friendId with :myId];
}

+ (NSArray *) getUsersToSync{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"User" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    //[result JSONRepresentation];
    return result;
}

+ (NSArray *) getMyFriends{
    //TODO implement it
    NSPredicate *pred= [NSPredicate predicateWithFormat:@""];
    return [modelUtils fetchManagedObjects:entityName predicate:pred sortDescriptors:nil moc:[modelUtils  defaultManagedObjectContext]];
}

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
         updateGAE:(BOOL) updateGAE {
    [currentUser setName:name];
    [currentUser setSurname:surname];
    //no password update needed
    //[currentUser setPassword:password];
    
    if (birthdate)
        [currentUser setDateOfBirth:birthdate];
    
    [currentUser setOccupation:occupation];
    [currentUser setGender:gender];
	
	[currentUser setTwitterId: twitterId];
	[currentUser setFacebookId: facebookId];
    
    if (photo && [photo length] > 0)
        [currentUser setPhoto:photo];
    
    if (locationId)
        [currentUser setHomeLocationId:locationId];
    
    [currentUser setDateModified:dateModified];
    
    BOOL result = TRUE;
    
    if (!updateGAE) {
        result = [modelUtils commitDefaultMOC];
    }
    
    return result;
}

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
         updateGAE:(BOOL) updateGAE {
    [currentUser setName:name];
    [currentUser setSurname:surname];
    //no password update needed
    //[currentUser setPassword:password];
    
    if (birthdate)
        [currentUser setDateOfBirth:birthdate];
    
    [currentUser setOccupation:occupation];
    [currentUser setGender:gender];
	
	[currentUser setEmail:email];
	
	[currentUser setFacebookId:facebookId];
	[currentUser setTwitterId:twitterId];
    
    if (photo && [photo length] > 0)
        [currentUser setPhoto:photo];
    
    
    if (locationId)
        [currentUser setHomeLocationId:locationId];
    
    [currentUser setDateModified:dateModified];
    
    BOOL result = TRUE;
    
    if (!updateGAE) {
        result = [modelUtils commitDefaultMOC];
    }
    
    return result;
}

+ (NSMutableArray *) getFriendsOfUser:(User *) user {    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"User" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverId <> %@", [user serverId]];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *result = [[modelUtils defaultManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return [[NSMutableArray alloc] initWithArray:result];
}

@end