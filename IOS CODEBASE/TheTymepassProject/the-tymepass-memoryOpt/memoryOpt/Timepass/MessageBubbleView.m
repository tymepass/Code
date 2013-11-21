//
//  MessageBubbleView.m
//  PIMPS
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageBubbleView.h"

static UIFont* font = nil;
static UIImage* bubbleImage = nil;

const CGFloat VertPadding = 4;       // additional padding around the edges
const CGFloat HorzPadding = 4;

const CGFloat TextLeftMargin = 17;   // insets for the text
const CGFloat TextRightMargin = 15;
const CGFloat TextTopMargin = 10;
const CGFloat TextBottomMargin = 11;

const CGFloat MinBubbleWidth = 50;   // minimum width of the bubble
const CGFloat MinBubbleHeight = 40;  // minimum height of the bubble

const CGFloat WrapWidth = 250;       // maximum width of text in the bubble

@implementation MessageBubbleView

+ (void)initialize
{
	if (self == [MessageBubbleView class])
	{
		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

		bubbleImage = [[UIImage imageNamed:@"bubble.png"]
			stretchableImageWithLeftCapWidth:20 topCapHeight:5];
	}
}

+ (CGSize)sizeForText:(NSString*)text 
{
	CGSize textSize = [text sizeWithFont:font
		constrainedToSize:CGSizeMake(WrapWidth, 9999)
		lineBreakMode:UILineBreakModeWordWrap];

	CGSize bubbleSize;
	bubbleSize.width = textSize.width + TextLeftMargin + TextRightMargin;
	bubbleSize.height = textSize.height + TextTopMargin + TextBottomMargin;

	if (bubbleSize.width < MinBubbleWidth)
		bubbleSize.width = MinBubbleWidth;

	if (bubbleSize.height < MinBubbleHeight)
		bubbleSize.height = MinBubbleHeight;

	bubbleSize.width += HorzPadding*2;
	bubbleSize.height += VertPadding*2;

	return bubbleSize;
}

- (void)drawRect:(CGRect)rect
{
	[self.backgroundColor setFill];
	UIRectFill(rect);

	CGRect bubbleRect = CGRectInset(self.bounds, VertPadding, HorzPadding);

    //if ([text length] > 30)
    //    bubbleRect.size.width -= 30;
    
	CGRect textRect;
	textRect.origin.y = bubbleRect.origin.y + TextTopMargin;
    
    //if ([text length] > 30)
    //    textRect.size.width = bubbleRect.size.width - TextLeftMargin - TextRightMargin - 10;
    //else 
        textRect.size.width = bubbleRect.size.width - TextLeftMargin - TextRightMargin;

	textRect.size.height = bubbleRect.size.height - TextTopMargin - TextBottomMargin;

	[bubbleImage drawInRect:bubbleRect];
    textRect.origin.x = bubbleRect.origin.x + TextLeftMargin;
	
    [[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0] set];
	[text drawInRect:textRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0] lineBreakMode:UILineBreakModeWordWrap];
}

- (void)setText:(NSString*)newText
{
	text = [newText copy];
    
	[self setNeedsDisplay];
}

@end
