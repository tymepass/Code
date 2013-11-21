//
//  User.h
//  Timepass
//
//  Created by Christos Skevis on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, EventMessage, Group, Invitation, Location;

@interface User : NSManagedObject
@property (nonatomic, retain) NSString * twitterId;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * occupation;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * isLoggedIn;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * surname;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) Event *eventId;
@property (nonatomic, retain) NSSet *messageId;
@property (nonatomic, retain) NSSet *invitationFrom;
@property (nonatomic, retain) Location *homeLocationId;
@property (nonatomic, retain) Location *currentLocationId;
@property (nonatomic, retain) NSSet *groupId;
@property (nonatomic, retain) NSSet *invitationTo;

@property (nonatomic, retain) NSData *photoData;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMessageIdObject:(EventMessage *)value;
- (void)removeMessageIdObject:(EventMessage *)value;
- (void)addMessageId:(NSSet *)values;
- (void)removeMessageId:(NSSet *)values;
- (void)addInvitationFromObject:(Invitation *)value;
- (void)removeInvitationFromObject:(Invitation *)value;
- (void)addInvitationFrom:(NSSet *)values;
- (void)removeInvitationFrom:(NSSet *)values;
- (void)addGroupIdObject:(Group *)value;
- (void)removeGroupIdObject:(Group *)value;
- (void)addGroupId:(NSSet *)values;
- (void)removeGroupId:(NSSet *)values;
- (void)addInvitationToObject:(Invitation *)value;
- (void)removeInvitationToObject:(Invitation *)value;
- (void)addInvitationTo:(NSSet *)values;
- (void)removeInvitationTo:(NSSet *)values;
@end
