//
//  NewsfeedViewController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventViewController.h"
#import "TTTAttributedLabel.h"

@interface NewsfeedViewController : UIViewController {
    User *user;
    NSArray *newsreelItems;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, retain) EventViewController *eventPageViewController;
@property (nonatomic, retain) NSArray *newsreelItems;

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKNetworkOperation *newsReelOperation;
@property (nonatomic, strong) MKNetworkOperation *notificationsOperation;

@property (nonatomic, strong) TTTAttributedLabel *headerDetailLabel;

-(TTTAttributedLabel *) setObject:(NSMutableDictionary *) dict setType:(NSString *) type intoFrame:(CGRect)frame;

-(void)deleteNewsReel:(NSMutableDictionary *)dict;

@end
