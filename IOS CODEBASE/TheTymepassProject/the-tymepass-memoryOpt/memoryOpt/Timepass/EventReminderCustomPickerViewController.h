//
//  EventReminderCustomPickerViewController.h
//  Timepass
//
//  Created by jason on 11/10/12.
//
//

#import <UIKit/UIKit.h>

@protocol EventReminderCustomPickerDelegate;

@protocol EventReminderCustomPickerDelegate<NSObject>
@required
- (void)setEventReminderDate:(NSDate *)reminderCustomDate;
@end

@interface EventReminderCustomPickerViewController : UIViewController  {
	id<EventReminderCustomPickerDelegate> eventReminderCustomPickerDelegate;
	NSDate *reminderDate;
}

@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (strong, nonatomic) IBOutlet UIView *labelView;
@property (nonatomic, retain) id<EventReminderCustomPickerDelegate> eventReminderCustomPickerDelegate;
@property (copy) NSDate *reminderDate;

- (IBAction)datePickerValueChanged:(id)sender;
- (void) doneBtnPressed:(id) sender;

- (IBAction)saveBtnPressed:(id) sender;
- (void) setLabel;

@end