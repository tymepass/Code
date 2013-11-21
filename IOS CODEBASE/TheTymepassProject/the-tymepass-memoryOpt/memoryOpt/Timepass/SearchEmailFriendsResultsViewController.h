//
//  SearchEmailFriendsResultsViewController.h
//  Timepass
//
//  Created by Mahmood1 on 12/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SearchEmailFriendsResultsViewController : UIViewController<UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    NSMutableArray *currentFriendsArray;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, strong) IBOutlet UIButton *sendRequestsBtn;
@property (nonatomic, retain) NSMutableArray *friendsUsingTymepassArray;
@property (nonatomic, retain) NSMutableArray *friendsNotUsingTymepassArray;
@property (strong, nonatomic) IBOutlet UIView *footerView;

-(IBAction) sendRequestsBtnPressed:(id) sender;
-(IBAction) segmentControlChanged:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil friendsUsingArray:(NSMutableArray *)friendsUsingArray friendsNotUsingArray:(NSMutableArray* ) friendsNotUsingArray;
@end
