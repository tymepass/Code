//
//  Invitation+GAE.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Invitation.h"
#import "SBJson.h"
#import "User.h"
#import "GAEUtils.h"
#import "Event+Management.h"

@interface Invitation (GAE)
+ (NSArray *) getInvitations:(NSArray *)response;
+ (NSArray *) parseGAEInvitations:(NSArray *)response;

+ (NSArray *) getAttendees:(NSArray *)response;
+ (NSArray *) parseGAEAttendees:(NSArray *)response;

+ (NSArray *) getInvitees:(NSArray *)response;
+ (NSArray *) parseGAEInvitees:(NSArray *)response;

+ (BOOL) setInvitation:(NSString *) invitationId toStatus:(NSString *) status;

@end
