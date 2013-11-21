//
//  CalendarDayViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TdCalendarDayView.h"
#import "User+Management.h"
#import "TTTAttributedLabel.h"

@interface CalendarDayViewController : UIViewController <UIApplicationDelegate,CalendarDayViewDelegate> {
    User *aFriend;
    NSManagedObjectContext *scratchContext;
}

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *dayTitle;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet TdCalendarDayView *tdCalendarDayView;

-(IBAction)movePrevDay:(id)sender;
-(IBAction)moveNextDay:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friend:(User *) afriendId inContext:(NSManagedObjectContext *) context;
-(void)changeHeaderTitle;
@end
