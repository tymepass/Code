//
//  EventReminderCustomPickerViewController.m
//  Timepass
//
//  Created by jason on 11/10/12.
//
//

#import "EventReminderCustomPickerViewController.h"
#import "TTTAttributedLabel.h"

@implementation EventReminderCustomPickerViewController

@synthesize eventReminderCustomPickerDelegate;
@synthesize reminderDate;
@synthesize labelView;
@synthesize datePickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reminderDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = NSLocalizedString(@"Reminder", @"Reminder");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(doneBtnPressed:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
	
	self.datePickerView.minimumDate = [NSDate date];
	self.datePickerView.minuteInterval = 5;
	self.datePickerView.timeZone = [NSTimeZone localTimeZone];
	self.datePickerView.date = reminderDate;
	[self.datePickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	UIView *view = [[datePickerView subviews] objectAtIndex:0];
	[view setBackgroundColor:[UIColor clearColor]];
	// hide the first and the last subviews
	[[[view subviews] objectAtIndex:0] setHidden:YES];
	[[[view subviews] lastObject] setHidden:YES];
	
	[self setLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setDatePickerView:nil];
	[self setLabelView:nil];
	[super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated {
	[[self eventReminderCustomPickerDelegate] setEventReminderDate:self.datePickerView.date];
}

- (void) doneBtnPressed:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveBtnPressed:(id) sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)datePickerValueChanged:(id)sender {
	self.reminderDate = self.datePickerView.date;
	[self setLabel];
}

-(void) setLabel {
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEEE dd MMM yyyy HH:mm"];
		
	NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
	[dfTime setDateFormat:@"HH:mm"];
	
	TTTAttributedLabel *eventStartTimeLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 280.0, 40.0)];
	eventStartTimeLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
	eventStartTimeLabel.textColor = [UIColor grayColor];
	
	eventStartTimeLabel.lineBreakMode = UILineBreakModeWordWrap;
	eventStartTimeLabel.numberOfLines = 2;
	eventStartTimeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
	eventStartTimeLabel.backgroundColor = [UIColor clearColor];
	eventStartTimeLabel.textAlignment = UITextAlignmentCenter;
	
	[eventStartTimeLabel setText:[df stringFromDate:self.reminderDate] afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
		NSRange range = [[mutableAttributedString string] rangeOfString:[dfTime stringFromDate:self.reminderDate] options:NSCaseInsensitiveSearch];
		
		UIColor *color = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
		
		[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[color CGColor] range:range];
		
		UIFont *boldSystemFont =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:[ApplicationDelegate.uiSettings cellFontSize]];
		CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
		if (font) {
			[mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:range];
			CFRelease(font);
		}
		
		return mutableAttributedString;
	}];
	
	for (UIView *subview in [labelView subviews]) {
		[subview removeFromSuperview];
	}
	
	[labelView addSubview:eventStartTimeLabel];
}

@end