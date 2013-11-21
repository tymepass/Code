//
//  weekTableCell.h
//  Timepass
//
//  Created by Christos Skevis on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekTableCell : UITableViewCell{
    	NSMutableArray *columns;
}

- (void)addColumn:(CGFloat)position;

@end
