//
//  FaqViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaqViewController : UIViewController<UITableViewDelegate> 

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
