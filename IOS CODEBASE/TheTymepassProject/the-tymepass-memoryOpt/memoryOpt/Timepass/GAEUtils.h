//
//  GAEUtils.h
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "User+Management.h"
#import "Event+Management.h"
#import "MBProgressHUD.h"

@interface GAEUtils : NSObject<MBProgressHUDDelegate> {
    NSMutableData *receivedData;
    NSArray *responseData;
    
    NSMutableArray *requestStack;
}

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSArray *responseData;
@property (nonatomic, retain) NSMutableArray *requestStack;

+ (NSArray *) sendRequest:(NSMutableDictionary *) jsonObject toURL:(NSString *) urlString;
+ (NSArray *) getAndParseResponse:(NSMutableURLRequest *) request;
+ (NSMutableDictionary *) addToDictWith:(NSString *) invitationText 
                               andPhoto:(NSString *) invitationPhoto
                                 status:(NSString *) status 
                           invitationId:(NSString *) invitationId
                                 object:(id)object
                                   type:(NSString *) type
                          messagesCount:(NSString *) messagesCount;
+ (void) getSyncDataFromGAEFor:(User *) user;

+ (NSDate *) parseDateFromGAE:(NSString *)date;
+ (NSString *) formatDateForGAE:(NSDate *) dateString;

+ (NSDate *) parseTimeStampFromGAE:(NSString *)date;
+ (NSTimeInterval) formatTimeStampForGAE:(NSDate *) dateString;

+(GAEUtils*)sharedGAEUtils;
+(NSString *) documentsPath;

@end
