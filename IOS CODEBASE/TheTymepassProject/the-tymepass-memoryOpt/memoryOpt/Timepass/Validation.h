//
//  Validation.h
//  TimePass
//
//  Created by Christos Skevis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validation : NSObject

+ (BOOL) validateText:(NSString *) text;
+ (BOOL) validateEmail:(NSString *) email;
+ (BOOL) validateDate:(NSString *) date;
+ (BOOL) validateUsername:(NSString *) username;
+ (BOOL) validatePassword:(NSString *) password;

@end
