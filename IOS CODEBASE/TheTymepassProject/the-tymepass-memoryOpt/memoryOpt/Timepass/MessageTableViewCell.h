//
//  MessageTableViewCell.h
//  PIMPS
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class EventMessage;
@class MessageBubbleView;

// Table view cell that displays a Message. The message text appears in a
// speech bubble; the sender name and date are shown in a UILabel below that.
@interface MessageTableViewCell : UITableViewCell
{
	MessageBubbleView* bubbleView;
    UIImageView *imageView;
	UILabel* senderLabel;
    UILabel* dateLabel;
    
    
}

- (void)setUserMessage:(UserMessage*)message frame:(CGRect) frame;
- (void)setEventMessage:(EventMessage*)message frame:(CGRect) frame;

@end