//
//  CalendarYearViewController.m
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalendarAgendaViewController.h"
#import "CalendarDayViewController.h"
#import "CalendarWeekViewController.h"
#import "CalendarMonthViewController.h"
#import "CalendarYearViewController.h"

@implementation CalendarYearViewController

CalendarDayViewController *calendarDayViewController;
CalendarWeekViewController *calendarWeekViewController;
CalendarMonthViewController *calendarMonthViewController;
CalendarYearViewController *calendarYearViewController;
CalendarAgendaViewController *calendarAgendaViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)returnBtn:(id)sender{
    [self.view removeFromSuperview];
}

-(IBAction)dayViewBtn:(id)sender{
    calendarDayViewController = [[CalendarDayViewController alloc] initWithNibName:@"CalendarDayViewController" bundle:nil];
    UINavigationController * navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:calendarDayViewController animated:YES];
}
-(IBAction)weekViewBtn:(id)sender{
    calendarWeekViewController = [[CalendarWeekViewController alloc] initWithNibName:@"CalendarWeekViewController" bundle:nil];
    UINavigationController * navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:calendarWeekViewController animated:YES];
}
-(IBAction)monthViewBtn:(id)sender{
    calendarMonthViewController = [[CalendarMonthViewController alloc] initWithNibName:@"CalendarMonthViewController" bundle:nil];
    UINavigationController * navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:calendarMonthViewController animated:YES];
}
-(IBAction)agendaViewBtn:(id)sender{
    calendarAgendaViewController = [[CalendarAgendaViewController alloc] initWithNibName:@"CalendarAgendaViewController" bundle:nil];
    UINavigationController * navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:calendarAgendaViewController animated:YES];
}
-(IBAction)createEventBtn:(id)sender{
    /*
    eventCreateViewController = [[EventCreateViewController alloc] initWithNibName:@"EventCreateViewController" bundle:nil];
    [self.navigationController pushViewController:eventCreateViewController animated:YES];
     */
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
