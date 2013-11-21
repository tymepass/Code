//
//  TdCalendarEventTile.h
//  TimePass
//
//  Created by Christos Skevis on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface TdCalendarEventTile : UIView {
	UILabel *titleLabel;
	UILabel *descriptionLabel;
	UILabel *timeLabel;
    UIImageView *backgroundView;
	
	UIImageView *alarmImageView;
	UIImage *alarmImage;
	UIImageView *repeatImageView;
	UIImage *repeatImage;
    
	Event *event;
    UIViewController *viewController;
}

@property (nonatomic, retain) Event *event;

@end
