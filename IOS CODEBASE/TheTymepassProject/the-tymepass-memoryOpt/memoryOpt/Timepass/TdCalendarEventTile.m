//
//  TdCalendarEventTile.m
//  Timepass
//
//  Created by Christos Skevis on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TdCalendarEventTile.h"
#import "Event.h"
#import "Utils.h"

@implementation TdCalendarEventTile

@synthesize event;

- (id)init {
	if (self = [super init]) {
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = NO;
		
		titleLabel = [[UILabel alloc] init];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor blackColor];
		//titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0];
		
		descriptionLabel = [[UILabel alloc] init];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:114.0/255.0 blue:188.0 alpha:1.0];
		//descriptionLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
		descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
		descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
		descriptionLabel.numberOfLines = 0;
		
		timeLabel = [[UILabel alloc] init];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textColor = [[UIColor alloc] initWithRed:0.0/255.0 green:114.0/255.0 blue:188.0/255.0 alpha:1.0];
		timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
		
		backgroundView = [[UIImageView alloc] init];
		backgroundView.alpha = 0.90f;
		
		alarmImage = [UIImage imageNamed:@"event_alarm_icon_big.png"];
		alarmImageView = [[UIImageView alloc] init];
		alarmImageView.image = alarmImage;
		
		repeatImage = [UIImage imageNamed:@"event_repeat_icon_big.png"];
		repeatImageView = [[UIImageView alloc] init];
		repeatImageView.image = repeatImage;
		
		[self addSubview:backgroundView];
		[self addSubview:titleLabel];
		[self addSubview:descriptionLabel];
		[self addSubview:timeLabel];
		[self addSubview:alarmImageView];
		[self addSubview:repeatImageView];
	}
	
	return self;
}

- (void)setEvent:(Event *)e {
	event = e;
	
	// set bg image
	UIImage *bgImage = [UIImage imageNamed:@"calendar_event_attending_tile_bg.png"];
    
    if ([event.attending intValue] != 1)
        bgImage = [UIImage imageNamed:@"calendar_event_not_attending_tile_bg.png"];
    
	
	// set title if not busy
    if ([event.busy intValue] != 0 ) {
		//MOBI 5-8-13 removed below line from if condition
		//&&  ![event.creatorId isEqual:[[SingletonUser sharedUserInstance] user]] && [event.attending intValue] == 0
        titleLabel.text = @"busy";
        bgImage = [UIImage imageNamed:@"calendar_event_busy_tile_bg.png"];
    }
    else {
        titleLabel.text = event.title;
    }
	
    backgroundView.image = [bgImage stretchableImageWithLeftCapWidth:6 topCapHeight:13];
	
	if ([event.isAllDay intValue] == 0) {
		NSDateFormatter *dfTime = [[NSDateFormatter alloc] init];
		[dfTime setDateFormat:@"HH:mm"];
		
		timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [dfTime stringFromDate:event.startTime], [dfTime stringFromDate:event.endTime]];
	}
    
	descriptionLabel.text = event.description;
	
	[self setNeedsDisplay];
}

- (void)layoutSubviews {
	CGRect myBounds = self.bounds;
	
	backgroundView.frame = myBounds;
	
	CGSize stringSize = [titleLabel.text sizeWithFont:titleLabel.font];
	titleLabel.frame = CGRectMake(7,
								  2,
								  stringSize.width,
								  stringSize.height);
	
	int width = 0;
	
	if (event.isAllDay) {
		descriptionLabel.frame = CGRectZero;
	}
	else {
		descriptionLabel.frame = CGRectMake(7,
											titleLabel.frame.size.height + 2,
											myBounds.size.width - 12,
											myBounds.size.height - 14 - titleLabel.frame.size.height);
	}
	
	if (myBounds.size.height <= 25 && myBounds.size.width > 125) {
		timeLabel.frame = CGRectMake(7 + titleLabel.frame.size.width + 2,
									 2,
									 myBounds.size.width - titleLabel.frame.size.width,
									 stringSize.height);
		
		
		
	}
	
	else if(myBounds.size.height > 40 && myBounds.size.width > 80) {
		timeLabel.frame = CGRectMake(7,
									 titleLabel.frame.size.height + 2,
									 myBounds.size.width,
									 stringSize.height);
		
	}
	
	if (![event.reminder isEqualToNumber:[NSNumber numberWithInt:0]]) {
		alarmImageView.frame = CGRectMake(self.bounds.size.width - alarmImage.size.width,
										  2,
										  alarmImage.size.width,
										  alarmImage.size.height);
		
		width = alarmImage.size.width * 2;
	}
	
	if (![event.recurring isEqualToNumber:[NSNumber numberWithInt:0]]) {
		repeatImageView.frame = CGRectMake(self.bounds.size.width - alarmImage.size.width - 2 - repeatImage.size.width,
										   2,
										   repeatImage.size.width,
										   repeatImage.size.height);
		
		width = repeatImage.size.width * 2;
	}

	/*if(width > 0) {
		titleLabel.frame = CGRectMake(titleLabel.frame.origin.x,
									  titleLabel.frame.origin.y,
									  titleLabel.frame.size.width - width,
									  titleLabel.frame.size.height);
	}*/
}

#pragma mark touch handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-began state
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)e {
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)e {
    if ([event.busy intValue] != 0)
        return;
	
	UITouch *touch = [touches anyObject];
	
	if ([self pointInside:[touch locationInView:self] withEvent:nil]) {
		[self touchesCancelled:touches withEvent:e];
        UIViewController *eventViewController = [Utils checkEventStatusOfUser:[[SingletonUser sharedUserInstance] user] forEvent:event];
        
        [[ApplicationDelegate navigationController] pushViewController:eventViewController animated:YES];
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)e {
	// show touch-end state
}

@end
