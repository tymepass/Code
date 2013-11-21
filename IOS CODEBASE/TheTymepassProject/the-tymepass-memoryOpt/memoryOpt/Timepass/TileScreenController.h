//
//  TileScreenController.h
//  PIMPS_skeletor
//
//  Created by Christos Skevis on 8/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBadge.h"

@interface TileScreenController : UIViewController {
	
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIButton *btnMessages;
@property (strong, nonatomic) IBOutlet UIButton *btnNewsReel;
@property (strong, nonatomic) IBOutlet UIButton *btnMyEvents;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *calendarLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *createEventLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *myProfileLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *newsreelLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *myEventsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *settingsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *notificationsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *myFriendsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *friendsCalLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *versionInfo;
@property (unsafe_unretained, nonatomic) CustomBadge *customBadge1;
@property (unsafe_unretained, nonatomic) CustomBadge *customBadge2;
@property (unsafe_unretained, nonatomic) CustomBadge *customBadge3;

- (IBAction)friendCalendarBtnPressed:(id)sender;
- (IBAction)calendarBtnPressed:(id)sender;
- (IBAction)createEventBtnPressed:(id)sender;
- (IBAction)myProfileBtnPressed:(id)sender;
- (IBAction)newsreelBtnPressed:(id)sender;
- (IBAction)messageFriendBtnPressed:(id)sender;
- (IBAction)myFriendsBtnPressed:(id)sender;
- (IBAction)pendingEventsBtnPressed:(id)sender;
- (IBAction)settingsBtnPressed:(id)sender;
- (IBAction)infoBtnPressed:(id)sender;
- (IBAction)goldBtnPressed:(id)sender;

@property (nonatomic, strong) MKNetworkOperation *userOperation;

@end
