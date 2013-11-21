//
//  User+GAEUser.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User+GAEUser.h"
#import "UAirship.h"
#import "NSDataAdditions.h"
#import "Location+Management.h"
#import "Utils.h"
#import "SBJson.h"

// Create the NSURL for the request
static NSString * fetchUserURL = @"https://tymepass.com/api/?action=getuser";
static NSString * unfriendURL = @"https://tymepass.com/api/?action=unFriend";
static NSString * fetchUserByIdURL = @"https://tymepass.com/api/?action=getUserById";
static NSString * fetchUserByTwitterURL = @"https://tymepass.com/api/?action=getUserByTwitter";
static NSString * loginURL = @"https://tymepass.com/api/?action=login";

@implementation User (GAEUser)

+ (User *)getGAEUserWithEmail:(NSString *)email{
    if (!email)
        return nil;
	
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:email forKey:@"email"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:fetchUserURL];
    
    NSDictionary *responseDict = [[NSDictionary alloc] initWithDictionary:[response objectAtIndex:0]];
    NSArray *userList = [responseDict objectForKey:@"user"];
    
    if (userList.count == 0)
        return nil;
    else
        return [User parseGAEUserFromJSON:response CDUser:nil inContext:[modelUtils defaultManagedObjectContext]];
}

+ (User *)getGAEUserWithTwitterId:(NSString *)twitterId{
    if (!twitterId)
        return nil;
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:twitterId forKey:@"twitterId"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:fetchUserByTwitterURL];
    
    NSDictionary *responseDict = [[NSDictionary alloc] initWithDictionary:[response objectAtIndex:0]];
    NSArray *userList = [responseDict objectForKey:@"user"];
    
    if (userList.count == 0)
        return nil;
    else
        return [User parseGAEUserFromJSON:response CDUser:nil inContext:[modelUtils defaultManagedObjectContext]];
}

+ (NSArray *) getFriends:(NSArray *)response {
    return [User parseGAEUsers:response];
}

+ (NSArray *) getTwitterUsers:(NSArray *)response {
    return [User parseGAEUsers:response];
}

+ (User *) getGAEUserWithId:(NSString *)serverId CDUser:(User *) CDUser inContext:(NSManagedObjectContext *) context {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:serverId forKey:@"id"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:fetchUserByIdURL];
    
    //debugLog(@"response: %@",[response description]);
    
    return [User parseGAEUserFromJSON:response CDUser:CDUser inContext:context];
}

+ (User *) parseGAEUserFromJSON:(NSArray *) response CDUser:(User *) CDUser inContext:(NSManagedObjectContext *) context {
    //TODO check if user exists
    NSDictionary *responseDict = [[NSDictionary alloc] initWithDictionary:[response objectAtIndex:0]];
    NSArray *userList = [responseDict objectForKey:@"user"];
    
    if (!(userList.count > 0))
        return nil;
    
    NSDictionary *userDict = [userList objectAtIndex:0];
    User *user;
	
    //check server Id for nil value to eliminate error on request (timeout and stuff)
    if ([userDict objectForKey:@"key"] == nil)
        return nil;
    
    Location *newLocation = nil;
    //debugLog(@"location: %@",[userDict objectForKey:@"location"]);
	
    if ([userDict objectForKey:@"location"]){
        newLocation= [Location getLocationWithName:[userDict objectForKey:@"location"] inContext:context];
        if (!newLocation) {
            newLocation = (Location *)[Location insertLocationWithName:[userDict objectForKey:@"location"] inContext:context];
        }
    }
	
    if (!CDUser) {
        user = [User saveUserWithEmail:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"email"]]
								  name:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"name"]]
							   surname:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"surname"]]
							  password:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"password"]]
						   dateOfBirth:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"dateOfBirth"]]]
							occupation:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"occupation"]]
								gender:[NSNumber numberWithInt:[(NSString*)  [userDict objectForKey:@"gender"] intValue]]
								 photo:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"photo"]]
						homeLocationId:newLocation
							facebookId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"facebookId"]]
							 twitterId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"twitterId"]]
							  serverId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"key"]]
						   dateCreated:[GAEUtils parseDateFromGAE:[userDict objectForKey:@"dateCreated"]]
						  dateModified:[GAEUtils parseDateFromGAE:[userDict objectForKey:@"dateModified"]]
							 inContext:context];
		
        if (context == [modelUtils defaultManagedObjectContext])
            [modelUtils commitDefaultMOC];
    }
    else  {
        [User updateUser:CDUser
                withName:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"name"]]
                 surname:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"surname"]]
                password:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"password"]]
             dateOfBirth:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"dateOfBirth"]]]
              occupation:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"occupation"]]
                  gender:[NSNumber numberWithInt:[(NSString*)  [userDict objectForKey:@"gender"] intValue]]
                   photo:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"photo"]]
          homeLocationId:newLocation
			  facebookId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"facebookId"]]
			   twitterId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"twitterId"]]
            dateModified:[GAEUtils parseDateFromGAE:[userDict objectForKey:@"dateModified"]]
               updateGAE:FALSE];
        
        user = CDUser;
    }
	
    //debugLog(@"%@", [user dateModified]);
    
    return user;
}

+ (NSArray *) parseGAEUsers:(NSArray *)responseArray {
    //TODO check if user exists
    NSDictionary *responseDict;
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
    if (!isIOS5){
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonObject = [parser objectWithString:(NSString *)responseArray];
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            // treat as a dictionary, or reassign to a dictionary ivar
            debugLog(@"Dictionary");
            responseDict = [[NSDictionary alloc] initWithDictionary:jsonObject];
        }
        else if ([jsonObject isKindOfClass:[NSArray class]]){
            debugLog(@"Array");
            responseDict = [[NSDictionary alloc] initWithObjects:jsonObject forKeys:jsonObject];
        }
    } else {
        responseDict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
    }
	
    NSArray *userList = [responseDict objectForKey:@"friends"];
    
    if (!(userList.count > 0))
        return nil;
    
    NSMutableArray *usersArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *userDict in userList) {
		
        User *user;
		if ((user = [User checkExistsInCD:[userDict objectForKey:@"key"] inContext:[modelUtils defaultManagedObjectContext]]) != nil) {
			
			Location *newLocation = nil;
			//debugLog(@"location: %@",[userDict objectForKey:@"location"]);
			
			if ([userDict objectForKey:@"location"]){
				newLocation= [Location getLocationWithName:[userDict objectForKey:@"location"] inContext:[modelUtils defaultManagedObjectContext]];
				if (!newLocation) {
					newLocation = (Location *)[Location insertLocationWithName:[userDict objectForKey:@"location"] inContext:[modelUtils defaultManagedObjectContext]];
				}
			}
						
			[User updateUser:user
					withName:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"name"]]
					 surname:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"surname"]]
					password:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"password"]]
				 dateOfBirth:[GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"dateOfBirth"]]]
				  occupation:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"occupation"]]
					  gender:[NSNumber numberWithInt:[(NSString*)  [userDict objectForKey:@"gender"] intValue]]
					   photo:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"photo"]]
			  homeLocationId:newLocation
				  facebookId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"facebookId"]]
				   twitterId:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"twitterId"]]
				dateModified:[GAEUtils parseDateFromGAE:[userDict objectForKey:@"dateModified"]]
				   updateGAE:FALSE];
			
		} else {
			user = [User getUserWithId:[userDict objectForKey:@"key"] inContext:[modelUtils defaultManagedObjectContext]];
		}
        
        
        if (user)
            [usersArray addObject:user];
    }
    
    //[modelUtils commitDefaultMOC];
    return usersArray;
}

+ (NSArray *) parseGAEUsersFromListString: (NSString *) list{
    
    NSArray *returnArray;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    [User parseGAEUsers: [parser objectWithString:list error:nil]];
    //debugLog(@"%@", [returnArray JSONRepresentation]);
    return returnArray;
}

+ (User *) loginGAEUser: (NSString *) email password:(NSString *) password{
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:email forKey:@"email"];
    [jsonObject setObject:password forKey:@"password"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:loginURL];
    //debugLog(@"login response: %@", [response JSONRepresentation]);
    NSDictionary *responseDict = [[NSDictionary alloc] initWithDictionary:[response objectAtIndex:1]];
    int status = [[responseDict objectForKey:@"statusCode"] intValue];
    if (status > 200) {
        if (status == 401) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oooops!"
                                                              message:[NSString stringWithFormat:@"The login info you gave\n is not quite right.\n Please, give it another go!"]
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"Try again",nil];
            [message show];
            return nil;
        }
        else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oooops!"
                                                              message:[NSString stringWithFormat:@"The login info you gave\n is not quite right.\n Please, give it another go!"]
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"Try again",nil];
            [message show];
            return nil;
        }
    }
    
    return [User parseGAEUserFromJSON:response CDUser:nil inContext:[modelUtils defaultManagedObjectContext]];
}

+ (BOOL)unfriendGAEUser:(NSString *)friendId with:(NSString *)myId {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    [jsonObject setObject:friendId forKey:@"from"];
    [jsonObject setObject:myId forKey:@"to"];
    
    NSArray *response = [GAEUtils sendRequest:jsonObject toURL:unfriendURL];
    NSArray *status = [response valueForKey:@"status"];
    
    //debugLog(@"%@",[response JSONRepresentation]);
    
    if ([status count] > 0) {
        NSMutableArray *theKey = [NSMutableArray arrayWithObject:@"key"];
        NSMutableArray *theObject = [NSMutableArray arrayWithObject:friendId];
        NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObject forKeys:theKey];
        
        [[[SingletonUser sharedUserInstance] gaeFriends] removeObject:theDict];
        
		//[ApplicationDelegate.userEngine getGAEFriendKeysOfUser:[[SingletonUser sharedUserInstance] user]];
		
        return TRUE;
    }
    return FALSE;
}

+ (NSArray *) getNewsreel:(NSArray *)response{
    return [User parseGAENewsreel:response];
}

+ (NSArray *) parseGAENewsreel:(NSArray *)response{
    NSArray *listItems;
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
    if (!isIOS5){
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonObject = [parser objectWithString:(NSString *)response];
        NSDictionary *responseDict;
        if ([jsonObject isKindOfClass:[NSArray class]]){
            debugLog(@"Array");
            responseDict = [[NSDictionary alloc] initWithDictionary:[jsonObject objectAtIndex:0]];
            listItems = [responseDict objectForKey:@"news"];
        }
    } else {
        listItems = [[response valueForKey:@"news"] objectAtIndex:0];
    }
    
    //parse to array of dictionarys
    NSMutableArray * newsreelArray = [[NSMutableArray alloc] init];
	
    for (NSDictionary *dict in listItems){
		
        NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
        
        NSString* type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
        
        NSString *userId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromUser"]];
        User* friend = [User getUserWithId:userId inContext:[modelUtils defaultManagedObjectContext]];
		

//		MOBI 5-7-13
//		if (![Utils isFriendOfByKey:userId] && ![[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:userId]) {
		if (![Utils isFriendOfByKey:userId] && ![[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:userId]) {
			userId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"toUser"]];
			friend = [User getUserWithId:userId inContext:[modelUtils defaultManagedObjectContext]];
		}
        
        //NSData *photo = [NSData dataWithBase64EncodedString:[NSString stringWithFormat:@"%@",[new objectForKey:@"photo"]]];
        //NSString *name = [NSString stringWithFormat:@"%@",[new objectForKey:@"name"]];
        //NSString *surname = [NSString stringWithFormat:@"%@",[new objectForKey:@"surname"]];
        
        [objDict setObject:userId forKey:@"fromUser"];
		if (friend.photo) {
			[objDict setObject:friend.photo forKey:@"photo"];
		}
		if(friend){
			[objDict setObject:friend.name forKey:@"name"];
			[objDict setObject:friend.surname forKey:@"surname"];
			[objDict setObject:type forKey:@"type"];
		}
        
        if ([type isEqualToString:@"EventRequestAccepted"] ||
			[type isEqualToString:@"EventRequestAcceptedGold"] ||
			[type isEqualToString:@"OpenEvent"] ||
			[type isEqualToString:@"EventRequestMayBe"] ||
			[type isEqualToString:@"GoldEvent"] ||
			[type isEqualToString:@"EventMessage"] ||
			[type isEqualToString:@"EventPicture"]) {
            //we have an event situation
			
			NSDictionary *newDict = [[dict objectForKey:@"eventInfo"] objectAtIndex:0];
			
            NSString *title = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"title"]];
            NSDate *startTime = [GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[newDict objectForKey:@"eventStartTime"]]];
            NSString *eventId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"eventId"]];
			
            [objDict setObject:title forKey:@"title"];
            [objDict setObject:eventId forKey:@"eventId"];
            [objDict setObject:startTime forKey:@"startTime"];
			[objDict setObject:[dict objectForKey:@"attending"] forKey:@"attending"];
            
        } else {
			
			NSDictionary *newDict = [[dict objectForKey:@"friendInfo"] objectAtIndex:0];
			
			NSString *friendId = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"serverId"]];
			
			if ([type isEqualToString:@"UserFriends"]) {
				if ([friendId isEqualToString:friend.serverId]) {
					newDict = [[dict objectForKey:@"userInfo"] objectAtIndex:0];
				}
			}
			
			NSString *friendName = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"name"]];
			NSString *friendSurname = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"surname"]];
			friendId = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"serverId"]];
            
            [objDict setObject:friendName forKey:@"friendName"];
            [objDict setObject:friendSurname forKey:@"friendSurname"];
            [objDict setObject:friendId forKey:@"friendId"];
        }
        
        [newsreelArray addObject:objDict];
    }
    
    return newsreelArray;
}

+ (NSArray *) getNewsreelPage:(NSArray *)response{
    return [User parseGAENewsreelPage:response];
}

+ (NSArray *) parseGAENewsreelPage:(NSArray *)response{
    NSArray *listItems;
    BOOL isIOS5 = [[[UIDevice currentDevice] systemVersion] floatValue] > 4.3;
    if (!isIOS5){
        // Create new SBJSON parser object
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id jsonObject = [parser objectWithString:(NSString *)response];
        NSDictionary *responseDict;
        if ([jsonObject isKindOfClass:[NSArray class]]){
            debugLog(@"Array");
            responseDict = [[NSDictionary alloc] initWithDictionary:[jsonObject objectAtIndex:0]];
            listItems = [responseDict objectForKey:@"news"];
        }
    } else {
        listItems = [[response valueForKey:@"news"] objectAtIndex:0];
    }
    
    //parse to array of dictionarys
    NSMutableArray * newsreelArray = [[NSMutableArray alloc] init];
	
    for (NSDictionary *dict in listItems){
		
        NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
        
        NSString* type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
        
        NSString *userId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"fromUser"]];
        User* friend = [User getUserWithId:userId inContext:[modelUtils defaultManagedObjectContext]];
		
		
		//		MOBI 5-7-13
		//		if (![Utils isFriendOfByKey:userId] && ![[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:userId]) {
		if (![Utils isFriendOfByKey:userId] && [[[[SingletonUser sharedUserInstance] user] serverId] isEqualToString:userId]) {
			userId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"toUser"]];
			friend = [User getUserWithId:userId inContext:[modelUtils defaultManagedObjectContext]];
		}
        
        //NSData *photo = [NSData dataWithBase64EncodedString:[NSString stringWithFormat:@"%@",[new objectForKey:@"photo"]]];
        //NSString *name = [NSString stringWithFormat:@"%@",[new objectForKey:@"name"]];
        //NSString *surname = [NSString stringWithFormat:@"%@",[new objectForKey:@"surname"]];
        
        [objDict setObject:userId forKey:@"fromUser"];
		if (friend.photo) {
			[objDict setObject:friend.photo forKey:@"photo"];
		}
		if(friend){
			[objDict setObject:friend.name forKey:@"name"];
			[objDict setObject:friend.surname forKey:@"surname"];
			[objDict setObject:type forKey:@"type"];
		}
        
        if ([type isEqualToString:@"EventRequestAccepted"] ||
			[type isEqualToString:@"EventRequestAcceptedGold"] ||
			[type isEqualToString:@"OpenEvent"] ||
			[type isEqualToString:@"EventRequestMayBe"] ||
			[type isEqualToString:@"GoldEvent"] ||
			[type isEqualToString:@"EventMessage"] ||
			[type isEqualToString:@"EventPicture"] ||
			[type isEqualToString:@"friendTofriendOpenEventNotification"]) {
            //we have an event situation
			
			NSDictionary *newDict = [[dict objectForKey:@"eventInfo"] objectAtIndex:0];
			
            NSString *title = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"title"]];
            NSDate *startTime = [GAEUtils parseDateFromGAE:[NSString stringWithFormat:@"%@",[newDict objectForKey:@"eventStartTime"]]];
            NSString *eventId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"eventId"]];
			
            [objDict setObject:title forKey:@"title"];
            [objDict setObject:eventId forKey:@"eventId"];
            [objDict setObject:startTime forKey:@"startTime"];
			[objDict setObject:[dict objectForKey:@"attending"] forKey:@"attending"];
            
        } else {
			
			NSDictionary *newDict = [[dict objectForKey:@"friendInfo"] objectAtIndex:0];
			
			NSString *friendId = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"serverId"]];
			
			if ([type isEqualToString:@"UserFriends"]) {
				if ([friendId isEqualToString:friend.serverId]) {
					newDict = [[dict objectForKey:@"userInfo"] objectAtIndex:0];
				}
			}
			
			NSString *friendName = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"name"]];
			NSString *friendSurname = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"surname"]];
			friendId = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"serverId"]];
            
            [objDict setObject:friendName forKey:@"friendName"];
            [objDict setObject:friendSurname forKey:@"friendSurname"];
            [objDict setObject:friendId forKey:@"friendId"];
        }
        
        [newsreelArray addObject:objDict];
    }
    
    return newsreelArray;
}

+ (NSArray *) getUpcomingEvents:(NSArray *)response andStore:(NSManagedObjectContext *) context{
    return [User parseGAEUpcomingEvents:response andStore:context];
}

+ (NSArray *) parseGAEUpcomingEvents:(NSArray *)response andStore:(NSManagedObjectContext *) context{
    NSArray *listItems = [[response objectAtIndex:0] valueForKey:@"entities"];
    
    //parse to array of dictionarys
    NSMutableArray * eventsArray = [[NSMutableArray alloc] init];
    Event *eventObj;
    
    for (NSDictionary *event in listItems){
        Location *newLocation;
        if ([[event objectForKey:@"locations"] count] > 0) {
            NSString *locationText = [NSString stringWithFormat:@"%@",[[[event valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
            newLocation = [Location getLocationWithName:locationText inContext:context];
            if (!newLocation) {
                newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
            }
        }
        
        User *creatorUser = [User getUserWithId:[event valueForKey:@"creator"] inContext:context];
        
        eventObj = [Event parseGAEEventInviteWithTitle:[event valueForKey:@"title"]
                                                  info:[event valueForKey:@"info"]
                                             startTime:[event valueForKey:@"startTime"]
                                               endTime:[event valueForKey:@"endTime"]
                                                isGold:[NSNumber numberWithInt:[[event valueForKey:@"isGold"] intValue]]
                                                 photo:nil
											  reminder:[NSNumber numberWithInt:[[event valueForKey:@"reminder"] intValue]]
										  reminderDate:[event valueForKey:@"reminderDate"]
											 recurring:[NSNumber numberWithInt:[[event valueForKey:@"recurring"] intValue]]
									  recurringEndDate:[event valueForKey:@"recurringEndTime"]
                                              serverId:[event valueForKey:@"key"]
										parentServerId:[event valueForKey:@"parentServerId"]
                                              messages:nil
                                                allDay:[NSNumber numberWithInt:[[event valueForKey:@"isAllDay"] intValue]]
                                             attending:[NSNumber numberWithInt:[[event valueForKey:@"isAttending"] intValue]]
                                             isPrivate:[NSNumber numberWithInt:[[event valueForKey:@"title"] intValue]]
                                                isOpen:[NSNumber numberWithInt:[[event valueForKey:@"isOpen"] intValue]]
									   isTymepassEvent:[NSNumber numberWithInt:[[event valueForKey:@"isTymePassEvent"] intValue]]
                                             isStealth:[NSNumber numberWithInt:0]
                                            locationId:newLocation
                                               creator:creatorUser
                                                  user:nil
                                                iCalId:nil
                                                  busy:[event valueForKey:@"busy"]
                                          dateModified:[event valueForKey:@"dateModified"]
                                           dateCreated:[event valueForKey:@"dateCreated"]
                                             invitedBy:nil
                                               context:context
                    ];
        [eventsArray addObject:eventObj];
    }
    
    return eventsArray;
}

@end
