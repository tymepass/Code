//
//  GoldEventsViewController.h
//  Timepass
//
//  Created by jason on 23/10/12.
//
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"
#import "TTTAttributedLabel.h"

@interface GoldEventsViewController : UIViewController {
	
	User* aFriend;
	NSMutableArray *events;
	NSMutableArray *fetchedEvents;
    
    UIViewController *eventViewController;
	
	int offset;
}

@property (unsafe_unretained, nonatomic) IBOutlet ShadowedTableView *tableView;
@property (nonatomic, strong) NSMutableArray *fetchedEvents;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) MKNetworkOperation *eventOperation;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forFriend:(User *)myfriend;
-(void)getPagedEvents;

@end