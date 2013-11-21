//
//  EventReminderPickerViewController.m
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventReminderPickerViewController.h"

@implementation EventReminderPickerViewController
@synthesize tableView;
@synthesize eventReminderPickerDelegate;
@synthesize eventReminderSelectedIndex;
@synthesize reminderDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        listOfReminders = [[NSArray alloc] initWithObjects:@"None", @"Custom Time", @"5 minutes before", @"15 minutes before",@"30 minutes before",@"1 hour before",@"2 hours before",@"1 day before",@"2 days before",@"1 week before",nil];
		
		self.reminderDate = [NSDate date];
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
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(doneBtnPressed:)];
	   
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void) doneBtnPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.title = NSLocalizedString(@"Reminder", @"Reminder");
}

- (void) viewWillDisappear:(BOOL)animated
{
	if ([eventReminderSelectedIndex isEqualToNumber:[NSNumber numberWithInt:1]]) {
		[[self eventReminderPickerDelegate] setEventReminder:eventReminderSelectedIndex reminderDate:self.reminderDate];
	} else {
		[[self eventReminderPickerDelegate] setEventReminder:eventReminderSelectedIndex];
	}
	self.title = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listOfReminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    NSString *cellValue = [listOfReminders objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
	
	if (indexPath.row == 1) {
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
    
    if (indexPath.row == [eventReminderSelectedIndex intValue]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:49.0/255.0 green:140.0/255.0 blue:199.0/255.0 alpha:1.0];
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int iterator = 0; iterator < [listOfReminders count]; iterator++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:iterator inSection:0]];
        //[cell setSelected:NO animated:YES];
        if (iterator == 1) {
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		} else{
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		}
        
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[cell setSelected:YES animated:YES];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    cell.textLabel.textColor = [[UIColor alloc] initWithRed:49.0/255.0 green:140.0/255.0 blue:199.0/255.0 alpha:1.0];
    eventReminderSelectedIndex = [NSNumber numberWithInt:indexPath.row];
	
	if (indexPath.row == 1) {
		EventReminderCustomPickerViewController *controller = [[EventReminderCustomPickerViewController alloc] initWithNibName:@"EventReminderCustomPickerViewController" bundle:nil];
		controller.reminderDate = self.reminderDate;
		[controller setEventReminderCustomPickerDelegate:self];
		[self.navigationController pushViewController:controller animated:YES];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - event custom reminder delegate

-(void)setEventReminderDate:(NSDate *)reminderCustomDate {
	self.reminderDate = reminderCustomDate;
}

@end
