//
//  TPScrollableViewController.h
//  Timepass
//
//  Created by Mahmood1 on 31/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "DismissableUITableView.h"

@interface TPScrollableViewController : UIViewController<UITextFieldDelegate> {
    TPKeyboardAvoidingScrollView *scrollView;
    
    IBOutlet UIToolbar *keyboardToolbar;
	UISegmentedControl *nextPreviousControl;
}

@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, retain) UISegmentedControl *nextPreviousControl;
@property (nonatomic, retain) UIToolbar *keyboardToolbar;

- (void) dismissKeyboard:(id)sender;
@end
