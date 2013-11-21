//
//  MyGoldEventsViewController.m
//  Timepass
//
//  Created by jason on 10/10/12.
//
//

#import "MyGoldEventsViewController.h"
#import "Event+Management.h"
#import "EventViewController.h"
#import "CreateEventViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyGoldEventsViewController

@synthesize tableView;
@synthesize fetchedEvents, events;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        user = [[SingletonUser sharedUserInstance] user];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
	offset = 0;
    [self getPagedEvents];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Gold Starred", @"Gold Starred");
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = nil;
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)getPagedEvents {
	
	fetchedEvents = [Event getGoldStarredEvents:[[SingletonUser sharedUserInstance] user] offset:offset];
    
	if (offset > 0) {
		[events addObjectsFromArray:fetchedEvents];
	} else {
		events = [NSMutableArray arrayWithArray:(NSArray *)fetchedEvents];
	}
	
    [tableView numberOfRowsInSection:[events count]];
    
    if (events.count == 0) {
        UIView *footerTableView = [[UIView alloc] init];
        
        UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
        label.text = NSLocalizedString(@"No golden events!", nil);
        
        [footerTableView addSubview:label];
        
        tableView.tableFooterView = footerTableView;
		allLoad = TRUE;
	}
    else {
        UIView *footerTableView = [[UIView alloc] init];
        tableView.tableFooterView = footerTableView;
		
		allLoad = FALSE;
		if ([events count] < 50) {
			allLoad = TRUE;
		}
		
		if ([fetchedEvents count] == 0) {
			allLoad = TRUE;
		}
    }
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (!allLoad) {
		NSInteger sectionsAmount = [self.tableView numberOfSections];
		NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
		
		if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			[cell.contentView addSubview:activity];
			[activity startAnimating];
			[activity setCenter:cell.center];
			return cell;
		}
	}
	
    if ([events count] == 0) {
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        cell.textLabel.text = @"No golden events!";
    } else {
        Event *event = [events objectAtIndex:indexPath.row];
		
        UIImageView *imageView = [[UIImageView alloc] init];
		
		[imageView setImageWithURL:[NSURL URLWithString:event.photo]
				  placeholderImage:[UIImage imageNamed:@"camera_img.png"]];
		
        [imageView setFrame:CGRectMake(0.0, 0.0, 60.0, 60.0)];
		[imageView setClipsToBounds: YES];
		
		UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, 8.0f, cell.frame.size.width - imageView.frame.size.width - 15.0f, [ApplicationDelegate.uiSettings cellFontSize])];
		
		eventTitle.text = event.title;
		eventTitle.textColor = [[UIColor alloc] initWithRed:ApplicationDelegate.uiSettings.headerColorRed
													  green:ApplicationDelegate.uiSettings.headerColorGreen
													   blue:ApplicationDelegate.uiSettings.headerColorBlue
													  alpha:1.0];
		eventTitle.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.appFontBold size:ApplicationDelegate.uiSettings.cellDetailFontSize];
		
		UILabel *eventDate = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f,
																	   eventTitle.frame.size.height + 8.0f,
																	   cell.frame.size.width - imageView.frame.size.width - 15.0f,
																	   [ApplicationDelegate.uiSettings cellFontSize])];
		eventDate.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.appFont size:14];
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"EEEE dd MMM yyyy"];
		
		NSDate * startTime = event.startTime;
		NSDate * endTime = event.endTime;
		
		eventDate.text = [df stringFromDate:startTime];
		eventDate.textColor = [UIColor lightGrayColor];
		
		UILabel *eventTime = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f,
																	   eventTitle.frame.size.height + eventDate.frame.size.height + 8.0f,
																	   cell.frame.size.width - imageView.frame.size.width - 15.0f,
																	   [ApplicationDelegate.uiSettings cellFontSize])];
		
		if ([event.isAllDay isEqualToNumber:[NSNumber numberWithInt:1]]) {
			NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
			[dfTime setDateFormat:@"HH:mm"];
			
			eventTime.text = @"All Day";
			eventTime.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
			
		} else {
			NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
			[dfTime setDateFormat:@"HH:mm"];
			
			eventTime.text = [NSString stringWithFormat:@"%@ - %@", [dfTime stringFromDate:startTime], [dfTime stringFromDate:endTime]];
			eventTime.textColor = [[UIColor alloc] initWithRed:111.0/255.0 green:176.0/255.0 blue:24.0/255.0 alpha:1.0];
		}
		
		eventTime.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.appFont size:14];
		
        [cell.contentView addSubview:imageView];
		[cell.contentView addSubview:eventTitle];
		[cell.contentView addSubview:eventDate];
		[cell.contentView addSubview:eventTime];
    }
	
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (!allLoad) {
		NSInteger sectionsAmount = [self.tableView numberOfSections];
		NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
		if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
			offset+=50;
			if ([events count] == offset) {
				[self getPagedEvents];
			}
		}
	}	
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *selectedEvent = (Event *)[events objectAtIndex:indexPath.row];
    eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:selectedEvent];
    
    [self.navigationController pushViewController:eventViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(TTTAttributedLabel *) setEvent:(Event *)event intoFrame:(CGRect)frame {
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
    label.textColor = [[UIColor alloc] initWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 3;
    label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    label.backgroundColor = [UIColor clearColor];
    
    label.frame = frame;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy"];
    
    NSString *text = @"";
    NSString *location = @"";
    
    if ([event locationId] && [[[event locationId] name] length] > 0)
        location = [NSString stringWithFormat:@"\nin %@",[event.locationId name]];
    
    if ([[event.creatorId serverId] isEqualToString:[user serverId]])
        text = [NSString stringWithFormat:@"You have created and are attending %@ on %@%@",[event title],[df stringFromDate:event.startDate], location];
    else
        text = [NSString stringWithFormat:@"%@ %@ would like to Tymepass you to %@ on %@%@",[event.invitedBy name],[event.invitedBy surname],[event title], [df stringFromDate:event.startDate], location];
    
    CGSize textSize = [text sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                       constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    float originY = frame.origin.y;
    
    if (textSize.height <= 34.0f)
        originY += 8.0f;
    
    [label setFrame:CGRectMake(frame.origin.x, originY, textSize.width - 10.0f, textSize.height)];
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:text];
    
    if (textSize.height > label.frame.size.height)
        [string appendString:@"..."];
    
    while (textSize.height > label.frame.size.height) {
        [string deleteCharactersInRange:NSMakeRange ([string length] - 4,1)];
        
        textSize = [string sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
                      constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
                          lineBreakMode:UILineBreakModeWordWrap];
    }
    
    [label setText:string afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@ %@",[event.invitedBy name],[event.invitedBy surname]] options:NSCaseInsensitiveSearch];
        
        if ([[event.creatorId serverId] isEqualToString:[user serverId]])
			boldRange1 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[event title]] options:NSCaseInsensitiveSearch];
        
        NSRange boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[event title]] options:NSCaseInsensitiveSearch];
        
        if ([[event.creatorId serverId] isEqualToString:[user serverId]])
            boldRange2 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[df stringFromDate:event.startDate]] options:NSCaseInsensitiveSearch];
        
        NSRange boldRange3  = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",[df stringFromDate:event.startDate]] options:NSCaseInsensitiveSearch];
        
        if ([[event.creatorId serverId] isEqualToString:[user serverId]])
            if ([event locationId] && [[[event locationId] name] length] > 0)
                boldRange3 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",location] options:NSCaseInsensitiveSearch];
        
        NSRange boldRange4;
        if (![[event.creatorId serverId] isEqualToString:[user serverId]])
            if ([event locationId] && [[[event locationId] name] length] > 0)
                boldRange4 = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"%@",location] options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:13.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        
        UIFont *normalSystemFont =  [UIFont fontWithName:[ApplicationDelegate.uiSettings appFont] size:13.0];
        CTFontRef normalFont = CTFontCreateWithName((__bridge CFStringRef)normalSystemFont.fontName, normalSystemFont.pointSize, NULL);
        
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange1];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange2];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange3];
			
            if (![[event.creatorId serverId] isEqualToString:[user serverId]])
                if ([event locationId] && [[[event locationId] name] length] > 0)
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange4];
			
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)normalFont range:[[mutableAttributedString string] rangeOfString:@"\nin " options:NSCaseInsensitiveSearch]];
			
            CFRelease(font);
            CFRelease(normalFont);
			
        }
        
        return mutableAttributedString;
    }];
    
    return label;
}

-(IBAction)btnEditPressed:(id)sender {
    if(self.editing) {
        [super setEditing:NO animated:YES];
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                  target:self action:@selector(btnEditPressed:)];
        
    }
    else {
        [super setEditing:YES animated:YES];
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(btnEditPressed:)];
    }
    
}

@end