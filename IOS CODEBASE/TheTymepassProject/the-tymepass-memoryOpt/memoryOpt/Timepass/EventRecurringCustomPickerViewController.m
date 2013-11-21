//
//  EventRecurringCustomPickerViewController.m
//  Timepass
//
//  Created by jason on 01/11/12.
//
//

#import "EventRecurringCustomPickerViewController.h"
#import "TTTAttributedLabel.h"

@implementation EventRecurringCustomPickerViewController

@synthesize eventRecurringCustomPickerDelegate;
@synthesize recurranceDate;
@synthesize datePickerView;
@synthesize labelView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Recurring End Time", @"Recurring End Time");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(doneBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
	
	self.datePickerView.minimumDate = [NSDate date];
	self.datePickerView.minuteInterval = 5;
	self.datePickerView.timeZone = [NSTimeZone localTimeZone];
	if (recurranceDate != Nil) {
		self.datePickerView.date = recurranceDate;
		[self setLabel];
	}
	
	[self.datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
	[[self eventRecurringCustomPickerDelegate] setEventrecurringDate:self.datePickerView.date];
}

- (void) doneBtnPressed:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)datePickerValueChanged:(id)sender {
	self.recurranceDate = self.datePickerView.date;
	[self setLabel];
}

-(void) setLabel {
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEEE dd MMM yyyy"];
		
	TTTAttributedLabel *eventStartTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 280.0, 40.0)];
	eventStartTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
	eventStartTimeLabel.textColor = [UIColor grayColor];
	
	eventStartTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
	eventStartTimeLabel.numberOfLines = 1;
	eventStartTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
	eventStartTimeLabel.backgroundColor = [UIColor clearColor];
	eventStartTimeLabel.textAlignment = UITextAlignmentCenter;
	
	[eventStartTimeLabel setText:[df stringFromDate:self.recurranceDate]];
	
	for (UIView *subview in [labelView subviews]) {
		[subview removeFromSuperview];
	}
	
	[labelView addSubview:eventStartTimeLabel];
}

- (void)viewDidUnload {
	[self setDatePickerView:nil];
	[self setLabelView:nil];
	[super viewDidUnload];
}
@end
