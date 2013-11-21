//
//  HelpViewController.m
//  Timepass
//
//  Created by mac book pro on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController
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
    
    self.title = NSLocalizedString(@"Help", @"Help");
    
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
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section {  
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, 0.0, 300.0, 40.0)];
    
    UILabel *headerLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
    UILabel *headerDetailLabel = [ApplicationDelegate.uiSettings createTableViewHeaderDetailLabel];
    
    switch (section) {
        case 0: 
            headerLabel.text =  @"HOW TO USE TYMEPASS";
            
            [headerDetailLabel setFrame:CGRectMake(12.0, 15.0, 300.0, 40.0)];
            headerDetailLabel.numberOfLines = 2;
            headerDetailLabel.text =  @"(Take a stroll through our screenshots\nto get a taste for Tymepass)";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel];
            
            return headerView;
        case 1:  
            headerLabel.text =  @"TUTORIAL VIDEO";
            headerDetailLabel.text =  @"(A step-by-step guide to our basic functions)";
            
            [headerView addSubview:headerLabel];
            [headerView addSubview:headerDetailLabel]; 
            
            return headerView;
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 2460.0)];
        backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"help.png"]];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = backView;
        
    } else if (indexPath.section == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"Watch Video"; 
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    if (section == 0)
        return 60.0;
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {  
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 240.0;
    
    return 40.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    /*
     if (indexPath.section == 1) {
     UIAlertView *reviewAlert = [[UIAlertView alloc] initWithTitle:@"Write a review?" message:@"You are going to be redirected to iTunes Store to leave a review." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Do it!", nil];
     [reviewAlert show];
     }
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
