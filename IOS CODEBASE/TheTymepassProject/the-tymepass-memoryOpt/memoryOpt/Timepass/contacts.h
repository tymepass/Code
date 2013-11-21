//
//  contacts.h
//  NM Messenger
//
//  Created by jason on 16/08/12.
//  Copyright (c) 2012 mobispector. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface contacts : NSObject

+(NSMutableArray *)fetchContacts;

@end