//
//  SearchTWFriendsViewController.h
//  Timepass
//
//  Created by jason on 02/10/12.
//
//

#import <UIKit/UIKit.h>

@interface SearchTWFriendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate> {
    
    UITableView *tableView;
    UIButton *sendRequestsBtn;
    
    NSMutableArray* peopleMutable;
	NSString *nextCursor;
}

@property (nonatomic,retain)  NSMutableData *responseData;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *sendRequestsBtn;
@property (nonatomic, retain) NSMutableArray *peopleMutable;
@property (nonatomic, retain) NSMutableArray *peopleArray;
@property (nonatomic, retain) NSMutableArray *peopleUsingArray;
@property (nonatomic, retain) NSMutableArray *peopleNotUsingArray;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) MKNetworkOperation *userOperation;

@property (nonatomic, strong) MBProgressHUD *HUD;

-(void) sendRequestsBtnPressed:(id) sender;
-(IBAction) segmentControlChanged:(id) sender;

@end