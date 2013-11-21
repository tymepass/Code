//
//  MessageBubbleView.h
//  PIMPS
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface MessageBubbleView : UIView 
{
	NSString* text;
}

// Calculates how big the speech bubble needs to be to fit the specified text
+ (CGSize)sizeForText:(NSString*)text;

// Configures the speech bubble
- (void)setText:(NSString*)text;

@end
