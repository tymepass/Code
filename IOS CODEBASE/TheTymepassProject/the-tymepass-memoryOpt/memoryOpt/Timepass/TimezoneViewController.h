//
//  TimezoneViewController.h
//  Timepass
//
//  Created by Christos Skevis on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimezoneViewController : UIViewController{
    IBOutlet UIButton *returnBtn;
}
@property (retain, nonatomic) IBOutlet UIButton *returnBtn;
- (IBAction)returnBtnPressed:(id)sender;


@end
