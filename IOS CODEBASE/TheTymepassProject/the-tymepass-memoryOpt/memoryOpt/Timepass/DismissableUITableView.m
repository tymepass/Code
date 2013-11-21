//
//  DismissableUITableView.m
//  Timepass
//
//  Created by Mahmood1 on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DismissableUITableView.h"

@implementation DismissableUITableView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.superview endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
