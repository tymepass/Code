//
//  User.m
//  Timepass
//
//  Created by Christos Skevis on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Event.h"
#import "EventMessage.h"
#import "Group.h"
#import "Invitation.h"
#import "Location.h"

@implementation User

@dynamic twitterId;
@dynamic facebookId;
@dynamic dateOfBirth;
@dynamic name;
@dynamic dateCreated;
@dynamic serverId;
@dynamic occupation;
@dynamic email;
@dynamic gender;
@dynamic dateModified;
@dynamic isLoggedIn;
@dynamic photo;
@dynamic surname;
@dynamic password;
@dynamic eventId;
@dynamic messageId;
@dynamic invitationFrom;
@dynamic homeLocationId;
@dynamic currentLocationId;
@dynamic groupId;
@dynamic invitationTo;
@synthesize photoData;

@end