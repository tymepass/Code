//
//  EventMessage+GAE.h
//  Timepass
//
//  Created by Christos Skevis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventMessage.h"
#import "Event.h"
#import "SBJson.h"
#import "GAEUtils.h"

@interface EventMessage (GAE)
+ (NSArray *) getMessages:(NSArray *)response forEvent:(Event *) event;
+ (NSArray *) parseGAEMesasges:(NSArray *) responseArray forEvent:(Event *) event;

@end
