//
//  Utils.h
//  Timepass
//
//  Created by Mahmood1 on 14/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import "FBConnect.h"
#import "User+Management.h"

@interface Utils : NSObject{
    NSManagedObjectContext *scratchPad;
    //NSDictionary *invitationStatuses;
}

@property (nonatomic, retain) NSManagedObjectContext *scratchPad;
//@property (nonatomic, retain) NSDictionary * invitationStatuses;
+(Utils*)sharedUtilsInstance;
+(int) getStatusOf:(NSString *) invitation;
+(NSString *)postJson:(NSMutableDictionary *)jsonObject url:(NSString *)urlFormat responseKey:(NSString *)parameter;
+ (NSString *)sha1:(NSString *)str;
+ (NSArray *) scanAddressBook;
+ (NSString *) userSettingsPath;
+ (void) checkIfSettingsPathExist:(NSString *)path;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;

+(BOOL) FBAuthorization:(Facebook *) facebook AppId:(NSString *) kAppId;
+(void)storeFBAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;
+(UIImage *) resizedFromImage: (UIImage *) image inPixes:(float) px;
+(BOOL) isFriendOfByKey:(NSString *) userId;
+(BOOL) isFriendOfByFacebookId:(NSString *) facebookId;
+(UIViewController *) checkFriendshipOfUser:(User *) userA withUser:(User *) userB;
+(UIViewController *) checkEventStatusOfUser:(User *) user forEvent:(Event *) eventId;

+(NSString *) urlEncodedAndEmojiConverion:(NSString *) stringValue;

@end
