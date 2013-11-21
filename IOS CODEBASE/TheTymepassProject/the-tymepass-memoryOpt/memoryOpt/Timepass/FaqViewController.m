//
//  FaqViewController.m
//  Timepass
//
//  Created by Christos Skevis on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FaqViewController.h"

@implementation FaqViewController
@synthesize scrollView;
@synthesize tableView;

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
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width,530)];

    self.title = NSLocalizedString(@"F.A.Q.", @"F.A.Q.");

    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setScrollView:nil];
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
    
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {  
    UIView *headerView = [[UIView alloc] init];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    headerDetailLabel.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
	
	[headerLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue-Bold"] size:12.5]];
	[headerDetailLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"HelveticaNeue-Bold"] size:12.0]];
    
    switch (section) {
        case 0: 
            headerLabel.text = @"WHAT IS TYMEPASS?";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 80.0)];
            headerDetailLabel.numberOfLines = 4;
            headerDetailLabel.text = @"Tymepass is your hook up to a more easy and\nstreamlined way of arranging and sharing your time. \nSee what your friends are up to, invite them,\njoin them, or even avoid them!";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 1:  
            headerLabel.text = @"CAN I USE TYMEPASS WITHOUT REGISTERING?";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 60.0)];
            headerDetailLabel.numberOfLines = 3;
            headerDetailLabel.text = @"of arranging and sharing your time.\nSee what your friends are up to, invite them,\njoin them, or even avoid them!";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 2:  
            headerLabel.text = @"WHY DO I GIVE ALL THIS INFO?";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 60.0)];
            headerDetailLabel.numberOfLines = 3;
            headerDetailLabel.text = @"of arranging and sharing your time.\nSee what your friends are up to, invite them,\njoin them, or even avoid them!";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 3:  
            headerLabel.text = @"SHOULD I WORRY ABOUT MY PERSONAL INFO?";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 60.0)];
            headerDetailLabel.numberOfLines = 3;
            headerDetailLabel.text = @"of arranging and sharing your time.\nSee what your friends are up to, invite them,\njoin them, or even avoid them!";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 4:  
            headerLabel.text = @"WHAT IS THE ANSWER TO THE UNIVERSE?";
            headerDetailLabel.text = @"You already know.";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 5:  
            headerLabel.text = @"WHICH COUNTRIES ARE SUPPORTED?";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 60.0)];
            headerDetailLabel.numberOfLines = 3;
            headerDetailLabel.text = @"of arranging and sharing your time.\nSee what your friends are up to, invite them,\njoin them, or even avoid them!";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        default:
            break;
    }
    
    return nil;
    
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {   
    if (section == 0)
        return 90.0;
    
    if (section == 4)
        return 30.0;
    
    return 70.0;
}

@end

