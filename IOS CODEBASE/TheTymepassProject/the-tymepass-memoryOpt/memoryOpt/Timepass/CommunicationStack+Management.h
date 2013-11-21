//
//  CommunicationStack+Management.h
//  Timepass
//
//  Created by Christos Skevis on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommunicationStack.h"
#import "modelUtils.h"

@interface CommunicationStack (Management)
+ (CommunicationStack *)insertRequestWithJSON:(NSString *)json andURL:(NSString *)url;
+ (NSArray *) fetchCommunicationStackObjects;
@end
