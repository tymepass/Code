//
//  weekTableCell.m
//  Timepass
//
//  Created by Christos Skevis on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WeekTableCell.h"

@implementation WeekTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        columns = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)addColumn:(CGFloat)position {
	[columns addObject:[NSNumber numberWithFloat:position]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect { 
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// just match the color and size of the horizontal line
	CGContextSetRGBStrokeColor(ctx, 0.67, 0.67, 0.67, 1.0); 
	CGContextSetLineWidth(ctx, 0.50);
    
	for (int i = 0; i < [columns count]; i++) {
		// get the position for the vertical line
		CGFloat f = [((NSNumber*) [columns objectAtIndex:i]) floatValue];
		CGContextMoveToPoint(ctx, f, 0);
		CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
	}
	
	CGContextStrokePath(ctx);
	
	[super drawRect:rect];
} 

@end
