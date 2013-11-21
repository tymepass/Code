//
//  EventAttendeesViewController.h
//  Timepass
//
//  Created by John P on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShadowedTableView.h"

@interface EventAttendeesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIApplicationDelegate>
{
    ShadowedTableView *tableView;
    UIButton *sendRequestsBtn;
    NSArray * peopleArray;
    
    UIViewController *viewController;
    UIViewController *profileViewController;
	BOOL isAttending;
}

@property (nonatomic, strong) IBOutlet ShadowedTableView *tableView;
@property (nonatomic, retain) NSArray *peopleArray;

-(void) sendRequestsBtnPressed:(id) sender;
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil attendees:(NSArray *) attendees;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil maybe:(NSArray *) maybe;
@end
