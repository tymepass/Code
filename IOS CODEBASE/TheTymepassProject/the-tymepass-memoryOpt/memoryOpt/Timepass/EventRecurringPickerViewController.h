//
//  EventRecurringPickerViewController.h
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventRecurringCustomPickerViewController.h"

@protocol EventRecurringPickerDelegate;

@protocol EventRecurringPickerDelegate<NSObject>
@required
- (void)setEventRecurring:(NSNumber *)recurringSelected;
- (void)setEventRecurring:(NSNumber *)recurringSelected recurranceDate:(NSDate *)recurranceDate;
@end

@interface EventRecurringPickerViewController : UIViewController<UITableViewDelegate, EventRecurringCustomPickerDelegate> {
    UITableView *tableView;
    NSArray *listOfRecurrences;
    
    id<EventRecurringPickerDelegate> eventRecurringPickerDelegate;
    NSNumber *eventRecurringSelectedIndex;
	
	NSDate *recurranceDate;
	NSDate *recurranceNewDate;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id<EventRecurringPickerDelegate> eventRecurringPickerDelegate;
@property (copy) NSNumber *eventRecurringSelectedIndex;
@property (copy) NSDate *recurranceDate;
@property (copy) NSDate *eventStartDate;

@end
