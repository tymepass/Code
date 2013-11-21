//
//  EventRecurringCustomPickerViewController.h
//  Timepass
//
//  Created by jason on 01/11/12.
//
//

#import <UIKit/UIKit.h>

@protocol EventRecurringCustomPickerDelegate;

@protocol EventRecurringCustomPickerDelegate<NSObject>
@required
- (void)setEventrecurringDate:(NSDate *)recurranceCustomDate;
@end

@interface EventRecurringCustomPickerViewController : UIViewController {
	id<EventRecurringCustomPickerDelegate> eventRecurringCustomPickerDelegate;
	NSDate *recurranceDate;
}

@property (strong, nonatomic) IBOutlet UIView *labelView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (nonatomic, retain) id<EventRecurringCustomPickerDelegate> eventRecurringCustomPickerDelegate;
@property (copy) NSDate *recurranceDate;

- (IBAction)datePickerValueChanged:(id)sender;
- (void) doneBtnPressed:(id) sender;
- (void) setLabel;

@end