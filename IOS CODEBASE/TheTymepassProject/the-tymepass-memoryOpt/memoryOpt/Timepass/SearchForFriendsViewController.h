//
//  SearchForFriendsViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface SearchForFriendsViewController : UIViewController<UITableViewDelegate,MFMessageComposeViewControllerDelegate>{
    BOOL settingsMode;
    NSMutableDictionary *settingsDictionary;
    NSString* settingsPath;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *searchFromTWCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *invniteBySMSContactsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *searchByEmailCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *invniteByContactsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *searchFromFBCell;
@property (nonatomic, strong) IBOutlet UIButton *laterBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil settingsViewMode:(BOOL) _settingsMode;
- (void) initCells;
- (IBAction)laterBtnPressed:(id)sender;
- (void)iCalAlert;
@end
