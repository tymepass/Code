//
//  MessageWallTableViewController.M
//
//  ----  U S I N G ----
//  GrowingTextViewExampleViewController
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "MessageWallTableViewController.h"
#import "EventMessage+Management.h"
#import "EventMessage+GAE.h"

#import "UserMessage+GAE.h"
#import "UserMessage+Management.h"

#import "MessageTableViewCell.h"
#import "MessageBubbleView.h"

@implementation MessageWallTableViewController
@synthesize tableView, eventMessages, textView, messagesOperation , HUD, messageOperation;

-(id)initWithMessages:(NSMutableArray *)messages forEvent:(Event *) event
{
	self = [super init];
	if(self){
        viewFrame = [[UIScreen mainScreen] applicationFrame];
        //onlyOneMessage = FALSE;
        fullView = YES;
		isEvent = YES;
        eventMessages = messages;
        
        if ([eventMessages count] == 0)
            eventMessages = [[NSMutableArray alloc] init];
		
        currentEvent = event;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
        self.title = NSLocalizedString(@"Message Wall", @"Message Wall");
    }
	
	return self;
}

-(id)initWithMessages:(NSMutableArray *)messages forUser:(User *) friendObj {
	
	self = [super init];
	if(self){
        viewFrame = [[UIScreen mainScreen] applicationFrame];
        //onlyOneMessage = FALSE;
        fullView = YES;
		isEvent = NO;
        eventMessages = messages;
        
        if ([eventMessages count] == 0)
            eventMessages = [[NSMutableArray alloc] init];
		
        aFriend = friendObj;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
        self.title = NSLocalizedString(@"Messages", @"Messages");
    }
	
	return self;
}

-(id)init:(CGRect) frame
{
	self = [super init];
	if(self){
        viewFrame = frame;
        //onlyOneMessage = TRUE;
        fullView = FALSE;
		isEvent = YES;
        eventMessages = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)init:(CGRect) frame  messages:(NSMutableArray *)messages forEvent:(Event *)event
{
	self = [super init];
	if(self){
        viewFrame = frame;
        //onlyOneMessage = FALSE;
        fullView = FALSE;
		isEvent = YES;
		
        eventMessages = messages;
        
        if ([eventMessages count] == 0)
            eventMessages = [[NSMutableArray alloc] init];
        
        currentEvent = event;
	}
	
	return self;
}

-(id)init:(CGRect) frame  messages:(NSMutableArray *)messages forUser:(User *) friendObj {
	self = [super init];
	if(self){
        viewFrame = frame;
        //onlyOneMessage = FALSE;
        fullView = FALSE;
		isEvent = NO;
		
        eventMessages = messages;
        
        if ([eventMessages count] == 0)
            eventMessages = [[NSMutableArray alloc] init];
        
        aFriend = friendObj;
	}
	
	return self;
}

- (void)scrollToNewestMessage
{
	// The newest message is at the bottom of the table
	if ([eventMessages count] > 0) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(eventMessages.count - 1) inSection:0];
		[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:viewFrame];
	
    /*
	 if (fullView)
	 tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 120) style:UITableViewStyleGrouped];
	 else
	 tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 80) style:UITableViewStyleGrouped];
	 */
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
	
	if (fullView) {
		tableView.frame = CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 87);
	}
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
	
	[tableView setBackgroundView:nil];
    tableView.backgroundColor = [UIColor whiteColor];
	
    [self.view addSubview:tableView];
	
	if (!fullView) {
		UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_panel.png"]];
		[shadow setFrame:CGRectMake(0.0, 40.0, 320.0, 5.0)];
		[self.view addSubview:shadow];
	}
    
    if (eventMessages.count == 0) {
        UIView *footerTableView = [[UIView alloc] init];
        
        UILabel *label1 = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [label1 setFrame:CGRectMake(0.0, 10.0, self.view.bounds.size.width, 20.0)];
        label1.textAlignment = UITextAlignmentCenter;
        label1.text = NSLocalizedString(@"No messages yet!", nil);
        
        UILabel *label2 = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        [label2 setFrame:CGRectMake(0.0, 40.0, self.view.bounds.size.width, 40.0)];
        label2.textAlignment = UITextAlignmentCenter;
        label2.numberOfLines = 2;
        label2.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        label2.text = @"Be the first to post a message\nfor all invitees to see";
		
        [footerTableView addSubview:label1];
        [footerTableView addSubview:label2];
        
        tableView.tableFooterView = footerTableView;
	}
    
    [tableView setDelaysContentTouches:NO];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [tableView addGestureRecognizer:tapGestureRecognizer];
	
    if (eventMessages.count > 0)
        [self scrollToNewestMessage];
    
	containerView = [[UIView alloc] initWithFrame:CGRectMake(9.0, 0.0,self.view.frame.size.width - 18, 40)];
	containerView.backgroundColor = [UIColor clearColor];
	if (fullView) {
		containerView.frame = CGRectMake(0, self.view.bounds.size.height - 87.0 ,self.view.frame.size.width, 40);
		containerView.backgroundColor = [UIColor colorWithPatternImage:[ApplicationDelegate.uiSettings backgroundImage]];
	}
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, self.view.frame.size.width - 100, 40)];
    textView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
	[textView setMinNumberOfLines:1];
	[textView setMaxNumberOfLines:6];
	textView.returnKeyType = UIReturnKeyDefault; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
	
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
	
	textView.internalTextView.backgroundColor = [UIColor clearColor];
    textView.backgroundColor = [UIColor clearColor];
    textView.placeholderText = @"Post Message";
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
	
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField_whtBG.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, self.view.frame.size.width - 92, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    /*UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
	 UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
	 UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
	 imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
	 imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;*/
	
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    //[containerView addSubview:imageView];
    [containerView addSubview:entryImageView];
	[containerView addSubview:textView];
	
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"post_btn.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"post_btn_pressed.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 3, 67, 34);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
	//[doneBtn setTitle:@"Post" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont fontWithName:[ApplicationDelegate.uiSettings appFontBold] size:16.0];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateHighlighted];
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    /*NSArray *itemsArray = [NSArray arrayWithObjects:@"On",@"Off", nil];
	 
	 postToFBSegmentControl = [[UISegmentedControl alloc] initWithItems:itemsArray];
	 [postToFBSegmentControl setFrame:CGRectMake(self.view.frame.size.width - 121.0, 10.0, 101.0, 29.0)];
	 
	 postToFBSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	 postToFBSegmentControl.selectedSegmentIndex = 0;
	 
	 [postToFBSegmentControl addTarget:self action:@selector(postToFBSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	 
	 footerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, self.view.frame.size.height - 43.0, 300.0, 40.0)];
	 
	 if (fullView)
	 footerView = [[UIView alloc] initWithFrame: CGRectMake(12.0, self.view.frame.size.height - 87.0, 300.0, 40.0)];
	 
	 UILabel *lbl = [ApplicationDelegate.uiSettings createTableViewFooterLabel];
	 
	 [footerView addSubview:lbl];
	 [footerView addSubview:postToFBSegmentControl];
	 
	 if (fullView) {
	 [lbl setFrame:CGRectMake(20.0, 14.5, 200.0, 20.0)];
	 lbl.text =  @"Post message to Facebook";
	 
	 //[self.view addSubview:footerView];
	 } else {
	 [lbl setFrame:CGRectMake(60.0, 14.5, 200.0, 20.0)];
	 lbl.text =  @"Post to Facebook!";
	 
	 //[self.view addSubview:footerView];
	 }*/
	
	if (!isEvent) {
		HUD = [MBProgressHUD showHUDAddedTo:[ApplicationDelegate navigationController].view animated:YES];
		HUD.frame = CGRectMake(0.0, 63.0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
		HUD.labelText = @"Loading...";
		HUD.dimBackground = YES;
	}
}

- (void)didSaveMessage:(EventMessage*)message atIndex:(int)index
{
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
		tableView.tableFooterView = nil;
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self scrollToNewestMessage];
	}
}

- (void)didSaveMessageatIndex:(int)index {
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
		tableView.tableFooterView = nil;
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self scrollToNewestMessage];
	}
}

-(void)resignTextView
{
	[textView resignFirstResponder];
    
    if ([[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""] length] > 0) {
		
		if (isEvent) {
			NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:
									   [NSCharacterSet newlineCharacterSet]];
			
			EventMessage *message = (EventMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"EventMessage" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
			
			[message setText:trimmedString];
			[message setUserId:[[SingletonUser sharedUserInstance] user]];
			[message setEventId:currentEvent];
			[message setDateCreated:[NSDate date]];
			
			if (currentEvent) {
				//[EventMessage sendMessageToGAE:message];
				[ApplicationDelegate.eventEngine sendMessageToGAE:message];
			}
			
			[eventMessages addObject:message];
			[self didSaveMessage:message atIndex:eventMessages.count - 1];
			
		} else {
			NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			
			UserMessage *message = (UserMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"UserMessage" inManagedObjectContext:[modelUtils defaultManagedObjectContext]];
			
			[message setText:trimmedString];
			[message setFromUserId:[[SingletonUser sharedUserInstance] user]];
			[message setToUserId:aFriend];
			[message setDateCreated:[NSDate date]];
			
			messageOperation = [ApplicationDelegate.userEngine sendMessageToGAE:message onCompletion:^(NSString *serverId) {
				
				[message setServerId:serverId];
				[message setTimeStamp:[NSNumber numberWithInt:[serverId intValue]]];
				[modelUtils commitDefaultMOC];
			} onError:^(NSError* error) {
				[modelUtils rollbackDefaultMOC];
			}];
			
			[eventMessages addObject:message];
			[self didSaveMessageatIndex:eventMessages.count - 1];
		}
    }
    
    textView.text = @"";
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    //CGRect footerFrame = footerView.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    //containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height) - footerFrame.size.height;
    //footerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + footerFrame.size.height) - 3.0;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
	
	if (fullView) {
		tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height - keyboardBounds.size.height);
		[self scrollToNewestMessage];
	}
	
    //footerView.frame = footerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
	
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    //CGRect footerFrame = footerView.frame;
    
	// Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
	
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    //containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height - footerFrame.size.height;
    //footerFrame.origin.y = self.view.bounds.size.height - footerFrame.size.height - 3.0;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
	
	if (fullView) {
		tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height + keyboardBounds.size.height);
	}
	
    //footerView.frame = footerFrame;
    
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
	
	float diff = (growingTextView.frame.size.height - height);
	if (fullView) {
		CGRect r = containerView.frame;
		r.size.height -= diff;
		r.origin.y += diff;
		containerView.frame = r;
	} else {
		CGRect r = containerView.frame;
		r.size.height -= diff;
		//r.origin.y += diff;
		containerView.frame = r;
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    [self setTableView:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (fullView)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (self.messageOperation) {
        [self.messageOperation cancel];
        self.messageOperation = nil;
    }
    
    if (self.messagesOperation) {
        [self.messagesOperation cancel];
        self.messagesOperation = nil;
    }
	
	if (HUD)
        [self setHUD:nil];
}

-(void)dealloc {
    if (fullView)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setEventMessages:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	
	if (!isEvent) {
		messagesOperation = [ApplicationDelegate.userEngine requestObjectOfUser:aFriend objectType:@"messages" onCompletion:^(NSArray *responseData) {
			[UserMessage getMessages:responseData forUser:aFriend];
			eventMessages = [UserMessage getMessages:aFriend];
			
			if (eventMessages.count > 0) {
				tableView.tableFooterView = nil;
				
				[self.tableView reloadData];
				[self scrollToNewestMessage];
			}
			
			[HUD hide:YES];
			
		} onError:^(NSError* error) {
			[HUD hide:YES];
		}];
		
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return eventMessages.count;
}

- (UITableViewCell*)tableView:(UITableView*)aTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"MessageCellIdentifier";
    
	MessageTableViewCell* cell = (MessageTableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    if (isEvent) {
		
		EventMessage* message = [eventMessages objectAtIndex:indexPath.row];
		[cell setEventMessage:message frame:viewFrame];
		
	} else {
		
		UserMessage * message = [eventMessages objectAtIndex:indexPath.row];
		[cell setUserMessage:message frame:viewFrame];
	}
    
	return cell;
}

#pragma mark -
#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	// This function is called before cellForRowAtIndexPath, once for each cell.
	// We calculate the size of the speech bubble here and then cache it in the
	// Message object, so we don't have to repeat those calculations every time
	// we draw the cell. We add 16px for the label that sits under the bubble.
	EventMessage* message = [eventMessages objectAtIndex:indexPath.row];
    
    NSString *decodedString = (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapes(NULL,  (__bridge CFStringRef)message.text, CFSTR(""));
    
	CGSize bubbleSize = [MessageBubbleView sizeForText:decodedString];
    
    float height = bubbleSize.height;
    
    if (indexPath.row == eventMessages.count - 1)
        height += 60.0;
    else
        height += 40.0;
    
	return height;
}

-(void)postToFBSegmentControlChanged:(id) sender {
    if (postToFBSegmentControl.selectedSegmentIndex == 0)
        postToFB = [[NSNumber alloc] initWithInt:1];
    else
        postToFB = [[NSNumber alloc] initWithInt:0];
}

- (void) hideKeyboard {
    [textView resignFirstResponder];
}

@end