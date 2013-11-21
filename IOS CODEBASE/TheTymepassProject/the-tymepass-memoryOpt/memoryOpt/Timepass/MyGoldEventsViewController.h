//
//  MyGoldEventsViewController.h
//  Timepass
//
//  Created by jason on 10/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MyGoldEventsViewController : UIViewController {
    User *user;
    
    NSMutableArray *events;
	NSMutableArray *fetchedEvents;
    
	int offset;
    UIViewController *eventViewController;
	BOOL allLoad;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *fetchedEvents;
@property (nonatomic, strong) NSMutableArray *events;

-(TTTAttributedLabel *) setEvent:(Event *)event intoFrame:(CGRect)frame;
-(void)getPagedEvents;

@end