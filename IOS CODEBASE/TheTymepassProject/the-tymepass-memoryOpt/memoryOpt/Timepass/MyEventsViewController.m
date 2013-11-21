//
//  MyEventsViewController.m
//  Timepass
//
//  Created by Takis Sotiriadis on 22/1/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyEventsViewController.h"
#import "Event+Management.h"
#import "EventViewController.h"
#import "CreateEventViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyEventsViewController
@synthesize toolBar;
@synthesize tableView;
@synthesize fetchedEvents, events,GoldenEvents;
@synthesize attendingArray, nonAttendingArray, nonGoldArray;
@synthesize goldenBtn;
@synthesize eventOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        user = [[SingletonUser sharedUserInstance] user];
		attendingArray = [[NSMutableArray alloc] init];
		nonAttendingArray = [[NSMutableArray alloc] init];
		nonGoldArray = [[NSMutableArray alloc] init];
		isGoldenEvents = FALSE;
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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        [toolBar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_toolbar_bg.png"]] atIndex:1];
    else
        [toolBar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_toolbar_bg.png"]] atIndex:0];
    
    
    goldenBtn = [ApplicationDelegate.uiSettings createButton:@""];;
    [goldenBtn setBackgroundImage:[UIImage imageNamed:@"my_events_gry_star.png"] forState:UIControlStateNormal];
    [goldenBtn addTarget:self action:@selector(goldenBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    goldenBtn.frame=CGRectMake(0.0, 0.0, 35.0, 36.0);
	
    UIBarButtonItem *goldenView = [[UIBarButtonItem alloc] initWithCustomView:goldenBtn];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                         NSLocalizedString(@"  Pending  ",@"  Pending  "),
                                                         NSLocalizedString(@"  Attending",@"  Attending  "),
                                                         NSLocalizedString(@"  Not attending",@"  Not attending  "),
                                                         nil]];
    
    control.segmentedControlStyle = UISegmentedControlStyleBar;
	control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	control.apportionsSegmentWidthsByContent = YES;
	
    control.momentary = NO;
    control.selectedSegmentIndex = 0;
    [control addTarget:self action:@selector(toolBarSegmentButtons:) forControlEvents:UIControlEventValueChanged];
	
	
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    NSArray *items = [[NSArray alloc] initWithObjects:controlItem, flex, goldenView, nil];
    
    [toolBar setItems:items animated:NO];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	offset = 0;
	isLoaded = TRUE;
    [self getPagedEvents];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"My Events", @"My Events");
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	self.title = Nil;
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark private methods

-(void)getPagedEvents {
	
	if (!isLoaded) {
		return;
	}
	
	NSString *condition = @"";
	
	if (isGoldenEvents)
		condition = @"isGold == 1";
	
	else if ([control selectedSegmentIndex] == 0)
		condition = @"(attending == 3 OR attending == 2)";
	
	else if ([control selectedSegmentIndex] == 1)
		condition = @"attending == 1";
	
	else if([control selectedSegmentIndex] == 2)
		condition = @"attending == 0";
	
	if (isGoldenEvents)
		fetchedEvents = [Event getGoldStarredEvents:[[SingletonUser sharedUserInstance] user] offset:offset];
	else
		fetchedEvents = [Event getPendingEvents:[[SingletonUser sharedUserInstance] user] offset:offset index:[NSNumber numberWithInt:[control selectedSegmentIndex]]];
	
	if ([fetchedEvents count] < 50) {
		allLoad = TRUE;
	}
	
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
		if (isGoldenEvents)
			label.text = NSLocalizedString(@"No golden events!", nil);
        else if ([control selectedSegmentIndex] == 0)
            label.text = NSLocalizedString(@"No pending events!", nil);
        else if ([control selectedSegmentIndex] == 1)
            label.text = NSLocalizedString(@"No attending events!", nil);
        else if ([control selectedSegmentIndex] == 2)
            label.text = NSLocalizedString(@"No not attending events!", nil);
		
        [footerTableView addSubview:label];
        
        tableView.tableFooterView = footerTableView;
		
		self.navigationItem.rightBarButtonItem = nil;
		
		allLoad = TRUE;
		
    } else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
												  target:self action:@selector(btnEditPressed:)];
		
        UIView *footerTableView = [[UIView alloc] init];
        tableView.tableFooterView = footerTableView;
		
		if ([events count] < 50) {
			allLoad = TRUE;
		} else {
			allLoad = FALSE;
		}
		
		if ([fetchedEvents count] == 0) {
			allLoad = TRUE;
		}
    }
	
    [tableView reloadData];
}

- (IBAction)toolBarSegmentButtons:(id)sender {
	
	isGoldenEvents = FALSE;
	offset = 0;
	[goldenBtn setBackgroundImage:[UIImage imageNamed:@"my_events_gry_star.png"] forState:UIControlStateNormal];
    tableView.tableFooterView = nil;
	
	if(self.editing) {
		[self btnEditPressed:nil];
	}
	
	[self getPagedEvents];
}

-(IBAction)goldenBtnPressed:(id)sender {
	
	offset = 0;
	isGoldenEvents = TRUE;
	[goldenBtn setBackgroundImage:[UIImage imageNamed:@"gold_star.png"] forState:UIControlStateNormal];
	
    tableView.tableFooterView = nil;
	
	if(self.editing) {
		[self btnEditPressed:nil];
	}
	
    [control setSelectedSegmentIndex:UISegmentedControlNoSegment];
	[self getPagedEvents];
}

-(IBAction)btnEditPressed:(id)sender {
	
    if(self.editing) {
		
		bool changed = false;
		
		if ([nonAttendingArray count] > 0) {
			
			NSMutableArray *eventIds = [[NSMutableArray alloc] init];
			
			for (Event *event in nonAttendingArray) {
				if (event.creatorId != [[SingletonUser sharedUserInstance] user]) {
					event.attending = [NSNumber numberWithInt:0];
					[eventIds addObject:event.serverId];
				}
			}
			
			HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
			HUD.labelText = @"Saving...";
			HUD.detailsLabelText = @"This function will not remove you from events you have created.";
			HUD.dimBackground = YES;
			
			eventOperation = [ApplicationDelegate.eventEngine changeEventStatus:eventIds
																attendingStatus:[NSNumber numberWithInt:0]
																   onCompletion:^(NSString *result)
							  {
								  
								  [HUD hide:YES afterDelay:2];
								  [modelUtils commitDefaultMOC];
							  } onError:^(NSError *error) {
								  
								  [HUD hide:YES afterDelay:2];
								  [modelUtils rollbackDefaultMOC];
							  }];
			
			changed = true;
		}
		
		if ([attendingArray count] > 0) {
			
			NSMutableArray *eventIds = [[NSMutableArray alloc] init];
			
			for (Event *event in attendingArray) {
				
				if (event.creatorId != [[SingletonUser sharedUserInstance] user]) {
					event.attending = [NSNumber numberWithInt:1];
					[eventIds addObject:event.serverId];
				}
			}
			
			HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
			HUD.labelText = @"Saving...";
			HUD.detailsLabelText = @"This function will not remove you from events you have created.";
			HUD.dimBackground = YES;
			
			eventOperation = [ApplicationDelegate.eventEngine changeEventStatus:eventIds attendingStatus:[NSNumber numberWithInt:1]onCompletion:^(NSString *result) {
				
				[HUD hide:YES afterDelay:2];
				[modelUtils commitDefaultMOC];
				
			} onError:^(NSError *error) {
				
				[HUD hide:YES afterDelay:2];
				[modelUtils rollbackDefaultMOC];
			}];
			changed = true;
		}
		
		if ([nonGoldArray count] > 0) {
			
			for (Event *event in nonGoldArray) {
				event.isGold = [NSNumber numberWithInt:0];
			}
			
			[modelUtils commitDefaultMOC];
			changed = true;
		}
		
		[nonAttendingArray removeAllObjects];
		[attendingArray removeAllObjects];
		[nonGoldArray removeAllObjects];
		
        [super setEditing:NO animated:YES];
        [self.tableView setEditing:NO animated:YES];
        [self getPagedEvents];
    }
    else {
        [super setEditing:YES animated:YES];
		
		if ([control selectedSegmentIndex] == 0) {
			[self.tableView setEditing:YES animated:YES];
		}
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																				  style:UIBarButtonItemStylePlain
																				 target:self
																				 action:@selector(btnEditPressed:)];
		
		[self.tableView reloadData];
    }
}

-(IBAction)markToNotAttendingEvent:(id)sender {
	UIButton *btn = (UIButton *)sender;
	
	Event *selectedEvent = (Event *)[events objectAtIndex:[sender tag]];
	
	if ([nonAttendingArray containsObject:selectedEvent]) {
		
		[nonAttendingArray removeObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"gray_btn.png"] forState:UIControlStateNormal];
		
	} else {
		
		[nonAttendingArray addObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"red_btn.png"] forState:UIControlStateNormal];
	}
}

-(IBAction)markToAttendingEvent:(id)sender {
	UIButton *btn = (UIButton *)sender;
	
	Event *selectedEvent = (Event *)[events objectAtIndex:[sender tag]];
	
	if ([attendingArray containsObject:selectedEvent]) {
		
		[attendingArray removeObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"yes_gray.png"] forState:UIControlStateNormal];
		
	} else {
		
		[attendingArray addObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"yes_green.png"] forState:UIControlStateNormal];
		
	}
}

-(IBAction)markToNotGoldEvent:(id)sender {
	UIButton *btn = (UIButton *)sender;
	
	Event *selectedEvent = (Event *)[events objectAtIndex:[sender tag]];
	
	if ([nonGoldArray containsObject:selectedEvent]) {
		
		[nonGoldArray removeObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"gold_star.png"] forState:UIControlStateNormal];
		
	} else {
		
		[nonGoldArray addObject:selectedEvent];
		[btn setBackgroundImage:[UIImage imageNamed:@"gry_star.png"] forState:UIControlStateNormal];
		
	}
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int total = [events count];
	if (!allLoad) {
		total++;
	}
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
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
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    if ([events count] == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:[ApplicationDelegate.uiSettings cellFontSize]];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
        cell.textLabel.text = @"No pending events";
    } else {
		Event *event = [events objectAtIndex:indexPath.row];
		
		if ([control selectedSegmentIndex] == 0) {
			
			UIImageView *imageView = [[UIImageView alloc] init];
			
			[imageView setImageWithURL:[NSURL URLWithString:event.photo]
					  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
			
			[imageView setFrame:CGRectMake(8.0, 16.0, 31.0, 30.0)];
			imageView.layer.cornerRadius = 4;
			[imageView setClipsToBounds: YES];
			
			[cell.contentView addSubview:imageView];
            
			CGRect frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 8.0f, 8.0f, cell.frame.size.width - imageView.frame.size.width - 35.0f, cell.frame.size.height + 15.0f);
            
			[cell.contentView addSubview:[self setEvent:event intoFrame:frame]];
		} else {
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_img.png"]];
			
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
			
			if (self.editing) {
				
				UIButton *editButton = [ApplicationDelegate.uiSettings createButton:@""];
				[editButton setFrame:CGRectMake(0, 0, 67, 34)];
				editButton.tag = indexPath.row;
				
				if ([control selectedSegmentIndex] == 1) {
					if ([nonAttendingArray containsObject:event]) {
						[editButton setBackgroundImage:[UIImage imageNamed:@"red_btn.png"] forState:UIControlStateNormal];
					} else {
						[editButton setBackgroundImage:[UIImage imageNamed:@"gray_btn.png"] forState:UIControlStateNormal];
					}
					[editButton addTarget:self action:@selector(markToNotAttendingEvent:) forControlEvents:UIControlEventTouchUpInside];
					
				} else if ([control selectedSegmentIndex] == 2) {
					if ([attendingArray containsObject:event]) {
						[editButton setBackgroundImage:[UIImage imageNamed:@"yes_green.png"] forState:UIControlStateNormal];
					} else {
						[editButton setBackgroundImage:[UIImage imageNamed:@"yes_gray.png"] forState:UIControlStateNormal];
					}
					[editButton addTarget:self action:@selector(markToAttendingEvent:) forControlEvents:UIControlEventTouchUpInside];
					
				} else {
					
					[editButton setFrame:CGRectMake(0, 0, 35, 36)];
					if ([GoldenEvents containsObject:event]) {
						[editButton setBackgroundImage:[UIImage imageNamed:@"gry_star.png"] forState:UIControlStateNormal];
					} else {
						[editButton setBackgroundImage:[UIImage imageNamed:@"gold_star.png"] forState:UIControlStateNormal];
					}
					[editButton addTarget:self action:@selector(markToNotGoldEvent:) forControlEvents:UIControlEventTouchUpInside];
					
				}
				
				cell.accessoryView = editButton;
			}
		}
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!allLoad) {
		NSInteger sectionsAmount = [self.tableView numberOfSections];
		NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
		
		if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
			offset+=50;
			[self getPagedEvents];
		}
	}
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([control selectedSegmentIndex] == 0) {
		return 64.0;
	} else {
		return 60.0;
	}
}

- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *selectedEvent = (Event *)[events objectAtIndex:indexPath.row];
    eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:selectedEvent];
    
    [self.navigationController pushViewController:eventViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger count = [events count];
	
	if (row < count) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
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
    
    /*if (textSize.height > label.frame.size.height)
	 [string appendString:@"..."];
	 
	 while (textSize.height > label.frame.size.height) {
	 [string deleteCharactersInRange:NSMakeRange ([string length] - 4,1)];
	 
	 textSize = [string sizeWithFont:[UIFont fontWithName:[ApplicationDelegate.uiSettings cellFont] size:13.0]
	 constrainedToSize:CGSizeMake(label.frame.size.width, 9999)
	 lineBreakMode:UILineBreakModeWordWrap];
	 }*/
    
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

@end