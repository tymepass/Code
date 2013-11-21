//
//  EventSetStartEndTimeViewController.h
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventSetStartEndTimeDelegate;

@protocol EventSetStartEndTimeDelegate<NSObject>
@required
- (void)setEventStartEndTime:(NSDate *) startTime endTime:(NSDate *) endTime;
@end

@interface EventSetStartEndTimeViewController : UIViewController {
    UITableView *tableView;
    UIDatePicker *datePicker;
    
    id<EventSetStartEndTimeDelegate> eventSetStartEndTimeDelegate;
    NSDate *eventStartTime;
    NSDate *eventEndTime;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) id<EventSetStartEndTimeDelegate> eventSetStartEndTimeDelegate;
@property (copy) NSDate *eventStartTime;
@property (copy) NSDate *eventEndTime;

@end
