//
//  FriendsViewForCalendarController.h
//  Timepass
//
//  Created by jason on 16/10/12.
//
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface FriendsViewForCalendarController : UIViewController <UITableViewDelegate> {
	
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * friendsArray;
@property (nonatomic, strong) MKNetworkOperation *friendsOperation;
@property (nonatomic, strong) MBProgressHUD *HUD;

-(IBAction)loadCalendar:(id)sender;

@end
