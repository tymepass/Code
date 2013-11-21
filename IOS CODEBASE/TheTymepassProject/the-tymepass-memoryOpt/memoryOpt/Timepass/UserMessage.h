//
//  UserMessage.h
//  Timepass
//
//  Created by jason on 18/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserMessage : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, assign) NSNumber * timeStamp;
@property (nonatomic, retain) User *fromUserId;
@property (nonatomic, retain) User *toUserId;

@end
