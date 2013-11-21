//
//  Validation.m
//  TimePass
//
//  Created by Christos Skevis on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Validation.h"

@implementation Validation

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (BOOL) validateText:(NSString *) text{
    //TODO implement checks
    if ([text length] == 0)
        return  false;
    
    return true;
}
+ (BOOL) validateEmail:(NSString *) email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:email];
}
+ (BOOL) validateDate:(NSString *) date{
    //TODO implement checks
    return true;
}
+ (BOOL) validateUsername:(NSString *) username{
    //TODO implement checks
    return true;
}
+ (BOOL) validatePassword:(NSString *) password{
    //TODO implement checks
    return true;
}

@end
