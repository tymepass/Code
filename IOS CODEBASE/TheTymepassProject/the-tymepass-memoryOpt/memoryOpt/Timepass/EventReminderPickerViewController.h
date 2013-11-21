//
//  EventReminderPickerViewController.h
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventReminderCustomPickerViewController.h"

@protocol EventReminderPickerDelegate;

@protocol EventReminderPickerDelegate<NSObject>
@required
- (void)setEventReminder:(NSNumber *)ReminderSelected;
- (void)setEventReminder:(NSNumber *)ReminderSelected reminderDate:(NSDate *)reminderDate;
@end

@interface EventReminderPickerViewController : UIViewController<EventReminderCustomPickerDelegate> {
    UITableView *tableView;
    NSArray *listOfReminders;
    
    id<EventReminderPickerDelegate> eventReminderPickerDelegate;
    NSNumber *eventReminderSelectedIndex;
	NSDate *reminderDate;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) id<EventReminderPickerDelegate> eventReminderPickerDelegate;
@property (copy) NSNumber *eventReminderSelectedIndex;
@property (copy) NSDate *reminderDate;
@end
