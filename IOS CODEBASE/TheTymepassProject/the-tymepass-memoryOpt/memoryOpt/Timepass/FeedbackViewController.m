//
//  FeedbackViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"

@implementation FeedbackViewController
@synthesize scrollView;
@synthesize tableView;
@synthesize sendEmailBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Contact Us", @"Contact Us");
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    sendEmailBtn = [ApplicationDelegate.uiSettings createButton:@"Send us an email"];
    [sendEmailBtn setFrame:CGRectMake(self.view.frame.size.width - 180.0, 0.0, 170.0, 44.0)];
    [sendEmailBtn addTarget:self action:@selector(sendEmailBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setSendEmailBtn:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)sendEmailBtnPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];        
        mailer.mailComposeDelegate = self;
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"info@tymepass.com", nil];
        [mailer setToRecipients:toRecipients];
                
        // only for iPad
        // mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        
        [self presentModalViewController:mailer animated:YES];
        
        mailer.navigationBar.tintColor = [[UIColor alloc] initWithRed:[ApplicationDelegate.uiSettings navigationBarTintColorRed] green:[ApplicationDelegate.uiSettings navigationBarTintColorGreen] blue:[ApplicationDelegate.uiSettings navigationBarTintColorBlue] alpha:1.0];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" 
                                                        message:@"Your device doesn't support the composer sheet" 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK",nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {  
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    
    headerLabel.text =  @"DROP US A LINE";
            
    [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 170.0)];
    headerDetailLabel.numberOfLines = 10;
    headerDetailLabel.text =  @"Do you have a question that we could answer?\nDid you find a bug in the app?\nDo you wish to speak to us in a professional\ncapacity?\nWould you like to ask us out on a date?!...\n(we are a handsome bunch :)\nOr do you just wanna say “hi”?\n    \nWhatever the reason, we will always be happy\nto hear from you!";
            
    [headerView addSubview:headerLabel];
    [headerView addSubview:headerDetailLabel];
            
    return headerView;

}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection:(NSInteger)section {  
    UIView *footerView = [[UIView alloc] init];
    [footerView addSubview:sendEmailBtn];     
        
    return footerView;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    return 200.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {  
    return 80.0;
}

@end
