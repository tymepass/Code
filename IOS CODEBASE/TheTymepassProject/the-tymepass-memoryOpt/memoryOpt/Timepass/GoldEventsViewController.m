//
//  GoldEventsViewController.m
//  Timepass
//
//  Created by jason on 23/10/12.
//
//

#import "GoldEventsViewController.h"
#import "Event+Management.h"
#import "Event+GAE.h"
#import "NSDataAdditions.h"
#import "EventViewController.h"
#import "CreateEventViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GoldEventsViewController

@synthesize tableView;
@synthesize fetchedEvents, events;
@synthesize eventOperation;
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forFriend:(User *)myfriend {
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		aFriend = myfriend;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
	HUD.frame = CGRectMake(0.0, 63.0, [ApplicationDelegate navigationController].view.frame.size.width, [ApplicationDelegate navigationController].view.frame.size.height);
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Gold Starred", @"Gold Starred");
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.title = nil;
	
	[HUD hide:YES];
	self.title = nil;
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	events = [[NSMutableArray alloc] init];
	[self getPagedEvents];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.eventOperation) {
        
        [self.eventOperation cancel];
        self.eventOperation = nil;
    }
    
    if (HUD)
        [self setHUD:nil];
    
    [super viewDidDisappear:animated];
}

-(void)getPagedEvents {
	eventOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"goldEvents" offset:offset onCompletion:^(NSArray *responseData) {
		
		NSArray *listItems = [[responseData objectAtIndex:0] objectForKey:@"entities"];
		
		//parse to array of dictionarys
		NSManagedObjectContext *context = [[Utils sharedUtilsInstance] scratchPad];
		
		for (NSMutableDictionary *dict in listItems) {
			Location *newLocation;
			
			NSMutableDictionary *data = [dict mutableCopy];
			
			if ([[dict objectForKey:@"locations"] count] > 0) {
				NSString *locationText = [NSString stringWithFormat:@"%@",[[[dict valueForKey:@"locations"] objectAtIndex:0] objectForKey:@"name"]];
				
				newLocation = [Location getLocationWithName:locationText inContext:context];
				
				if (!newLocation) {
					newLocation = (Location *)[Location insertLocationWithName:locationText inContext:context];
				}
			}
			
			//[dict setObject:newLocation forKey:@"location"];
			[data setValue:newLocation forKey:@"location"];
			
			User *creatorUser = [User getUserWithId:[dict valueForKey:@"creator"] inContext:context];
			[data setValue:creatorUser forKey:@"creator"];
			
			NSString *attendingStatus;
			if ([dict objectForKey:@"attending"])
				attendingStatus = [dict objectForKey:@"attending"];
			else
				attendingStatus = @"confirmed";
			[data setValue:[NSString stringWithFormat:@"%d",[Utils getStatusOf:attendingStatus]] forKey:@"attendingStatus"];
			
			Event *eventObj = [Event createEventFromDictionary:data inContext:context];
			[events addObject:eventObj];
		}
		
		if (events.count == 0) {
			UIView *footerTableView = [[UIView alloc] init];
			
			UILabel *label = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
			[label setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, 40.0)];
			label.textAlignment = UITextAlignmentCenter;
			label.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:17.0];
			label.text = NSLocalizedString(@"No golden events!", nil);
			
			[footerTableView addSubview:label];
			tableView.tableFooterView = footerTableView;
		}
		else{
			[self.tableView reloadData];
		}
		[HUD hide:YES];
	} onError:^(NSError* error) {
		[HUD hide:YES];
	}];
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
		eventTitle.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.appFontBold
										  size:ApplicationDelegate.uiSettings.cellDetailFontSize];
		
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
	
	NSInteger sectionsAmount = [self.tableView numberOfSections];
    NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
    if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {

        offset+=50;
		if ([events count] == offset) {
			HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
			HUD.labelText = @"Loading...";
			HUD.dimBackground = YES;
			
			[self getPagedEvents];
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

@end