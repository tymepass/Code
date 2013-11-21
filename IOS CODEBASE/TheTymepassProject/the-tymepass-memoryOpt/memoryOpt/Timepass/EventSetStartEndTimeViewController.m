//
//  EventSetStartEndTimeViewController.m
//  Timepass
//
//  Created by Mahmood1 on 15/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventSetStartEndTimeViewController.h"

@implementation EventSetStartEndTimeViewController
@synthesize tableView;
@synthesize datePicker;
@synthesize eventSetStartEndTimeDelegate;
@synthesize eventStartTime, eventEndTime;

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
    
    self.title = NSLocalizedString(@"Start & End", @"Start & End");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [datePicker setLocale:[NSLocale currentLocale]];
    [datePicker addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [datePicker setDate:eventStartTime animated:NO];
}

- (void) doneBtnPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[[self eventSetStartEndTimeDelegate] setEventStartEndTime:eventStartTime endTime:eventEndTime];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    
    cell.detailTextLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellDetailFont] size:[ApplicationDelegate.uiSettings cellDetailFontSize]];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed] green:[ApplicationDelegate.uiSettings cellDetailColorGreen] blue:[ApplicationDelegate.uiSettings cellDetailColorBlue] alpha:1.0];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Start Time"; 
        cell.detailTextLabel.text = [df stringFromDate:eventStartTime]; 
    } else {
        cell.textLabel.text = @"End Time"; 
        cell.detailTextLabel.text = [df stringFromDate:eventEndTime]; 
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        datePicker.date = eventStartTime;
    } else {
        datePicker.date = eventEndTime;        
    }
}

- (void) datePickerDidChange:(id) sender {
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
    
    cell.detailTextLabel.text = [df stringFromDate:datePicker.date]; 
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:datePicker.date];
    
    NSDateComponents *componentsEventEndTime = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:eventEndTime];
    if (componentsEventEndTime) {
        
    }
    
    if (indexPath.row == 0) {
            NSTimeInterval interval = [eventStartTime timeIntervalSinceDate:eventEndTime];
            eventStartTime = datePicker.date;
        
            components = [[NSCalendar currentCalendar] components:[ApplicationDelegate.uiSettings units] | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:eventStartTime];
                        
            [components setDay:[components day] + abs(roundf(interval/86400))]; 
            [components setHour:[components hour] + 1]; 
            [components setMinute:[components minute]]; 

            eventEndTime = [[NSCalendar currentCalendar] dateFromComponents:components];
           
            indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            cell = [tableView cellForRowAtIndexPath:indexPath];
        
            cell.detailTextLabel.text = [df stringFromDate:eventEndTime];
    }
    else {
        eventEndTime = datePicker.date;
        
        if ([eventEndTime compare:eventStartTime] == NSOrderedAscending) {
            [components setHour:[components hour] - 1]; 
            eventStartTime = [[NSCalendar currentCalendar] dateFromComponents:components];
            
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.detailTextLabel.text = [df stringFromDate:eventStartTime];
        }
    }
}

@end
