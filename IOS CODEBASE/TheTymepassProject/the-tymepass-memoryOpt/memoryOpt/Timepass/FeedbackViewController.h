//
//  FeedbackViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController<UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *sendEmailBtn;

- (IBAction)sendEmailBtnPressed:(id)sender;
@end
