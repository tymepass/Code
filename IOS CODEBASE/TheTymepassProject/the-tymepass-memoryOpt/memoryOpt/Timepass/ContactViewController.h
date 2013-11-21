//
//  ContactViewController.h
//  Timepass
//
//  Created by Urvesh Patel on 6/29/2012.
//  Copyright (c) 2012 Regius IT Solutions Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> ///ABPeoplePickerNavigationControllerDelegate
{
    NSMutableArray *arrContact;
    IBOutlet UITableView *tableview;
}
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSMutableArray *arrContact;

-(void)LoadContact;
@end
