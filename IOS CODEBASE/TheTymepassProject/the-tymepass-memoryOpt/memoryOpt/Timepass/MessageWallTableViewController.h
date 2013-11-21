//
//  MessageWallTableViewController.h
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

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "EventMessage.h"
#import "UserMessage.h"

@interface MessageWallTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate> {
    CGRect viewFrame;
	UIView *containerView;
    HPGrowingTextView *textView;
    
    UIView *footerView;
    UISegmentedControl *postToFBSegmentControl;
    NSNumber *postToFB;
    
    Event* currentEvent;
	User* aFriend;
    NSMutableArray *eventMessages;
    
    BOOL onlyOneMessage;
    BOOL fullView;
	BOOL isEvent;
}

@property (nonatomic, retain) NSMutableArray *eventMessages;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet HPGrowingTextView *textView;

@property (nonatomic, strong) MKNetworkOperation *messageOperation;
@property (nonatomic, strong) MKNetworkOperation *messagesOperation;

-(id)init:(CGRect) frame;
-(id)init:(CGRect) frame  messages:(NSMutableArray *)messages forEvent:(Event *) event;
-(id)initWithMessages:(NSMutableArray *)messages forEvent:(Event *) event;

-(id)init:(CGRect) frame  messages:(NSMutableArray *)messages forUser:(User *) aFriend;
-(id)initWithMessages:(NSMutableArray *)messages forUser:(User *) aFriend;

-(void)resignTextView;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

