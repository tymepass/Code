//
//  EventRecurringPickerViewController.m
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventRecurringPickerViewController.h"

@implementation EventRecurringPickerViewController

@synthesize tableView;
@synthesize eventRecurringPickerDelegate;
@synthesize eventRecurringSelectedIndex;
@synthesize recurranceDate;
@synthesize eventStartDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
        listOfRecurrences = [[NSArray alloc] initWithObjects:@"Never",@"Everyday",@"Every weekday",@"Every week",@"Every 2 weeks",@"Monthly",@"Annually",nil];
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
																			  style:UIBarButtonItemStyleBordered target:self action:@selector(doneBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void) doneBtnPressed:(id) sender {
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
	self.title = NSLocalizedString(@"Recurring", @"Recurring");
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	
	self.title = Nil;
	
	if ([eventRecurringSelectedIndex isEqualToNumber:[NSNumber numberWithInt:0]]) {
		[[self eventRecurringPickerDelegate] setEventRecurring:eventRecurringSelectedIndex];
	} else {
		[[self eventRecurringPickerDelegate] setEventRecurring:eventRecurringSelectedIndex recurranceDate:recurranceDate];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([eventRecurringSelectedIndex isEqualToNumber:[NSNumber numberWithInt:0]]) {
		return 1;
	} else {
		return 2;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([eventRecurringSelectedIndex isEqualToNumber:[NSNumber numberWithInt:0]]) {
		return @" ";
	} else {
		switch (section) {
			case 0:
				return @" ";
				break;
			case 1:
				return @"Recurring End Time";
				break;
				
			default:
				break;
		}
	}
	
	return @" ";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [listOfRecurrences count];
	} else {
		return 1;
	}
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		
		NSString *cellValue = [listOfRecurrences objectAtIndex:indexPath.row];
		cell.textLabel.text = cellValue;
		
		if (indexPath.row == [eventRecurringSelectedIndex intValue]) {
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			
			cell.textLabel.textColor = [[UIColor alloc] initWithRed:49.0/255.0 green:140.0/255.0 blue:199.0/255.0 alpha:1.0];
		}
		
		return cell;
	} else {
		
		UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.textLabel.text = @"Recurring End Time";
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"EEEE dd MMM yyyy"];
		
		cell.detailTextLabel.text = [df stringFromDate:recurranceDate];
		return cell;
	}
	
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		for (int iterator = 0; iterator < [listOfRecurrences count]; iterator++) {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:iterator inSection:0]];
			//[cell setSelected:NO animated:YES];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			
			cell.textLabel.textColor = [UIColor blackColor];
		}
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		//[cell setSelected:YES animated:YES];
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		
		cell.textLabel.textColor = [[UIColor alloc] initWithRed:49.0/255.0 green:140.0/255.0 blue:199.0/255.0 alpha:1.0];
		eventRecurringSelectedIndex = [NSNumber numberWithInt:indexPath.row];
		
		NSCalendar *gregorian = [NSCalendar currentCalendar];
		NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
		
		switch (indexPath.row) {
			case 1:
			{
				[offsetComponents setDay:4];
				break;
			}
				
			case 2:
			{
				
				unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
				NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:eventStartDate];
				switch ([components weekday]) {
						// sunday
					case 1:
					{
						[offsetComponents setDay:5];
						break;
					}
						// monday
					case 2:
					{
						[offsetComponents setDay:4];
						break;
					}
					// tuesday
					case 3:
					{
						[offsetComponents setDay:6];
						break;
					}
						// wednesday
					case 4:
					{
						[offsetComponents setDay:6];
						break;
					}
						// thursday
					case 5:
					{
						[offsetComponents setDay:6];
						break;
					}
						// friday
					case 6:
					{
						[offsetComponents setDay:6];
						break;
					}
						// saturday
					case 7:
					{
						[offsetComponents setDay:6];
						break;
					}
						
					default:
						break;
				}
				break;
			}
				
			case 3:
			{
				[offsetComponents setWeek:4];
				break;
			}
				
			case 4:
			{
				[offsetComponents setWeek:8];
				break;
			}
				
			case 5:
			{
				[offsetComponents setMonth:4];
				break;
			}
				
			case 6:
			{
				[offsetComponents setYear:4];
				break;
			}
			default:
				break;
		}
		
		self.recurranceDate = [gregorian dateByAddingComponents:offsetComponents toDate:eventStartDate options:0];
		
		[tableView reloadData];
	} else {
		EventRecurringCustomPickerViewController *controller = [[EventRecurringCustomPickerViewController alloc] initWithNibName:@"EventRecurringCustomPickerViewController" bundle:nil];
		controller.recurranceDate = self.recurranceDate;
		[controller setEventRecurringCustomPickerDelegate:self];
		[self.navigationController pushViewController:controller animated:YES];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - event custom recuring delegate

-(void)setEventrecurringDate:(NSDate *)recurranceCustomDate {
	self.recurranceDate = recurranceCustomDate;
	[tableView reloadData];
}


@end