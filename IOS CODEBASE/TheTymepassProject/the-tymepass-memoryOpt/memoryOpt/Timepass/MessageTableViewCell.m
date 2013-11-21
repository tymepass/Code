//
//  MessageTableViewCell.m
//  PIMPS
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "EventMessage.h"
#import "User.h"
#import "MessageBubbleView.h"
#import <QuartzCore/QuartzCore.h>

static UIColor* color = nil;

@implementation MessageTableViewCell

+ (void)initialize
{
	if (self == [MessageTableViewCell class])
	{
		color = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:237/255.0 alpha:1.0];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		// Create the speech bubble view
		bubbleView = [[MessageBubbleView alloc] initWithFrame:CGRectZero];
		bubbleView.backgroundColor = [UIColor clearColor];
		bubbleView.opaque = YES;
		bubbleView.clearsContextBeforeDrawing = NO;
		bubbleView.contentMode = UIViewContentModeRedraw;
		bubbleView.autoresizingMask = 0;

		[self.contentView addSubview:bubbleView];
        
        imageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profilepic.png"]];
        imageView.frame = CGRectMake(5.0, 2.0, 41.0, 39.0);
        
        imageView.layer.cornerRadius = 4;
        [imageView setClipsToBounds: YES];
        
        [self.contentView addSubview:imageView];

        senderLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
        senderLabel.textAlignment = UITextAlignmentLeft;
        senderLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        
		[self.contentView addSubview:senderLabel];
        
        dateLabel = [ApplicationDelegate.uiSettings createTableViewHeaderLabel];
		dateLabel.font = [UIFont fontWithName:ApplicationDelegate.uiSettings.appFont size:ApplicationDelegate.uiSettings.headerFontSize];
		dateLabel.textColor = [UIColor colorWithRed:[ApplicationDelegate.uiSettings cellDetailColorRed]
											  green:[ApplicationDelegate.uiSettings cellDetailColorGreen]
											   blue:[ApplicationDelegate.uiSettings cellDetailColorBlue]
											  alpha:1.0];
        dateLabel.textAlignment = UITextAlignmentRight;

		[self.contentView addSubview:dateLabel];
	}
	return self;
}

- (void)layoutSubviews
{
	// This is a little trick to set the background color of a table view cell.
	[super layoutSubviews];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = backView;
}

- (void)setEventMessage:(EventMessage*)message frame:(CGRect) frame
{
	
	[imageView setImageWithURL:[NSURL URLWithString:[message.userId photo]] placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    // Set the sender's name
    CGSize senderSize = [message.userId.name sizeWithFont:senderLabel.font
                                                          constrainedToSize:CGSizeMake(200, 9999)
                                                              lineBreakMode:UILineBreakModeWordWrap];
    
	if ([message.userId.surname length] > 0) {
		senderLabel.text = [NSString stringWithFormat:@"%@ %@.",message.userId.name,[message.userId.surname substringWithRange:NSMakeRange(0, 1)]];
	} else {
		senderLabel.text = message.userId.name;
	}
	
	senderLabel.frame = CGRectMake(imageView.bounds.size.width + 15.0, 4.0, senderSize.width, 16.0);
    [senderLabel sizeToFit];

    // Set the date on the label
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM HH:mm"];
    //CGSize dateSize = [[df stringFromDate:[NSDate date]] sizeWithFont:dateLabel.font constrainedToSize:CGSizeMake(200, 9999)lineBreakMode:UILineBreakModeWordWrap];
    
	dateLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:message.dateCreated]];
	dateLabel.frame = CGRectMake(imageView.bounds.size.width + senderLabel.frame.size.width + 20.0, 4.0, frame.size.width - senderLabel.frame.size.width - imageView.bounds.size.width - 40.0, 16.0);
    //[dateLabel sizeToFit];
    
    NSString *decodedString = (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapes(NULL,  (__bridge CFStringRef)message.text, CFSTR(""));

    CGSize bubbleSize = [MessageBubbleView sizeForText:decodedString];
    
	// Resize the bubble view and tell it to display the message text
	CGRect rect;
	rect.origin = CGPointMake(imageView.bounds.size.width - 3.0, senderLabel.frame.size.height + 6.0);
	rect.size = bubbleSize;
    
    if ([decodedString length] > 30)
        rect.size.width = frame.size.width - imageView.bounds.size.width - 10.0;
    
	bubbleView.frame = rect;
    
	[bubbleView setText:decodedString];
    
}

- (void)setUserMessage:(UserMessage*)message frame:(CGRect) frame
{
	
	[imageView setImageWithURL:[NSURL URLWithString:[message.fromUserId photo]]
			  placeholderImage:[UIImage imageNamed:@"default_profilepic.png"]];
    
    // Set the sender's name
    CGSize senderSize = [message.fromUserId.name sizeWithFont:senderLabel.font
										constrainedToSize:CGSizeMake(200, 9999)
											lineBreakMode:UILineBreakModeWordWrap];
    
	if ([message.fromUserId.surname length] > 0) {
		senderLabel.text = [NSString stringWithFormat:@"%@ %@.",message.fromUserId.name,[message.fromUserId.surname substringWithRange:NSMakeRange(0, 1)]];
	} else {
		senderLabel.text = message.fromUserId.name;
	}
	
	senderLabel.frame = CGRectMake(imageView.bounds.size.width + 15.0, 4.0, senderSize.width, 16.0);
    [senderLabel sizeToFit];
	
    // Set the date on the label
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM HH:mm"];
    //CGSize dateSize = [[df stringFromDate:[NSDate date]] sizeWithFont:dateLabel.font constrainedToSize:CGSizeMake(200, 9999)lineBreakMode:UILineBreakModeWordWrap];
    
	dateLabel.text = [NSString stringWithFormat:@"%@", [df stringFromDate:message.dateCreated]];
	dateLabel.frame = CGRectMake(imageView.bounds.size.width + senderLabel.frame.size.width + 20.0, 4.0, frame.size.width - senderLabel.frame.size.width - imageView.bounds.size.width - 40.0, 16.0);
    //[dateLabel sizeToFit];
    
    NSString *decodedString = (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapes(NULL,  (__bridge CFStringRef)message.text, CFSTR(""));
	
    CGSize bubbleSize = [MessageBubbleView sizeForText:decodedString];
    
	// Resize the bubble view and tell it to display the message text
	CGRect rect;
	rect.origin = CGPointMake(imageView.bounds.size.width - 3.0, senderLabel.frame.size.height + 6.0);
	rect.size = bubbleSize;
    
    if ([decodedString length] > 30)
        rect.size.width = frame.size.width - imageView.bounds.size.width - 10.0;
    
	bubbleView.frame = rect;
    
	[bubbleView setText:decodedString];
    
}

@end
