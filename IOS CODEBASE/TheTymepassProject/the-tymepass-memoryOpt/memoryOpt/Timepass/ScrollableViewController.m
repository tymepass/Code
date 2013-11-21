/*
 
 Copyright (c) 2010, Mobisoft Infotech
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are 
 permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of 
 conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, 
 this list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 
 Neither the name of Mobisoft Infotech nor the names of its contributors may be used to 
 endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS 
 OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
 AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 OF SUCH DAMAGE.
 
 */

#import "ScrollableViewController.h"
#import "UIViewFirstResponder.h"

@implementation ScrollableViewController
@synthesize svScrollViewM,nextPreviousControl,keyboardToolbar;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {  
	[self registerForKeyboardNotifications];
    
    keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    keyboardToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Previous",@"Previous form field"),
                                                                             NSLocalizedString(@"Next",@"Next form field"),nil]];
    
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = [UIColor darkGrayColor];
    control.momentary = YES;
    [control addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged];			
    
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    
    self.nextPreviousControl = control;
    
    NSArray *items = [[NSArray alloc] initWithObjects:controlItem, flex, barButtonItem, nil];
    [keyboardToolbar setItems:items];
    
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.svScrollViewM = nil;
}

- (void)registerForKeyboardNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (bKeyboardShownM)
        return;
	
	NSDictionary* info = [aNotification userInfo];
	
	// Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
    
	// Resize the scroll view (which is the root view of the window)
	CGRect viewFrame = [self.svScrollViewM frame];
    viewFrame.size.height -= keyboardSize.height;

	self.svScrollViewM.frame = viewFrame;
	
	// Scroll the active text field into view.
    UIView *responder = [self.view findFirstResponder];	
    CGRect responderRect = responder.frame;
    
    if ([responder isKindOfClass:[UITextView class]])
        responderRect = CGRectMake(responderRect.origin.x, responderRect.origin.y - 20, responderRect.size.width, responderRect.size.height); 
            
	[self.svScrollViewM scrollRectToVisible:responderRect animated:YES];
		
    bKeyboardShownM = YES;
}

// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification
{   
    NSDictionary* info = [aNotification userInfo];
	
	// Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
    
	// Reset the height of the scroll view to its original value
	CGRect viewFrame = [self.svScrollViewM frame];
    viewFrame.size.height += keyboardSize.height;
   
	self.svScrollViewM.frame = viewFrame;
		
    bKeyboardShownM = NO;
}

-(IBAction) backgroundTap:(id) sender{   
    UIView *responder = [self.view findFirstResponder];		
    [responder resignFirstResponder];
}

- (void)dismissKeyboard:(id)sender
{
	[[self.view findFirstResponder] resignFirstResponder];
}
@end
