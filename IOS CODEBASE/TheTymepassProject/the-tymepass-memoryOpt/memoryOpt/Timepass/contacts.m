//
//  contacts.m
//  NM Messenger
//
//  Created by jason on 16/08/12.
//  Copyright (c) 2012 mobispector. All rights reserved.
//

#import "contacts.h"

#define TMP NSTemporaryDirectory()

@implementation contacts

+(NSMutableArray *)fetchContacts {
    
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    
    ABAddressBookRef ab;
	ab = ABAddressBookCreate();
    CFArrayRef arrRef = ABAddressBookCopyArrayOfAllPeople(ab);
	NSArray *arr = (__bridge NSArray *) arrRef;
	
    for (int i=0; i<[arr count]; i++) {
        
        // create manual object of detail
        NSMutableDictionary *dicDetail = [[NSMutableDictionary alloc] init];
        
        ABRecordRef person = (__bridge ABRecordRef) [arr objectAtIndex:i];
        int RecordID = (int) ABRecordGetRecordID(person);
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *personName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        personName = [personName stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        if ([[personName stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            continue;
        }
        
        [dicDetail setValue:personName forKey:@"fullname"];
        [dicDetail setValue:[personName stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"fullnameSearch"];
        
        ABMultiValueRef phoneNums = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNums) > 0) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNums); i++) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                
                NSString *phoneNum;
                NSString *searchString;
                
                searchString = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneNums, i);
                searchString = [searchString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@"_" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@"$" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@"!" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@"<" withString:@""];
                searchString = [searchString stringByReplacingOccurrencesOfString:@">" withString:@""];
                
                [dic setValue:searchString forKey:@"phonetype"];
                [dic setValue:[NSString stringWithFormat:@"%d_%@",RecordID,searchString] forKey:@"id"];
                
                CFStringRef tempRef = (CFStringRef)ABMultiValueCopyValueAtIndex(phoneNums, i);
                phoneNum = (__bridge NSString *)tempRef;
                
                phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
                phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                tempRef = NULL;
                [dic setValue:phoneNum forKey:@"number"];
                [dic setValue:[NSString stringWithFormat:@"%@ (%@)",personName,searchString] forKey:@"phonename"];
                
                if (phoneNum != Nil && [searchString isEqualToString:@"Mobile"]) {
                    [arr addObject:dic];
                }
                
                phoneNum = nil;
                searchString = nil;
                dic = nil;
            }
            
            if ([arr count] > 0) {
                [dicDetail setObject:arr forKey:@"phonenumbers"];
            } else {
                dicDetail = nil;
            }
            arr = nil;
        }
        if (dicDetail != nil) {
            [contactArray addObject:dicDetail];
            dicDetail = nil;
        }
    }
    
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullname" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	NSArray *sortedArray;
	sortedArray = [contactArray sortedArrayUsingDescriptors:sortDescriptors];
	sortDescriptors=nil;
	
	[contactArray removeAllObjects];
	contactArray = (NSMutableArray*)[sortedArray copy];
	
	arr = nil;
	CFRelease(arrRef);
    return  contactArray;
}

@end
