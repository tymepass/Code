//
//  TimePassAppDelegate.h
//  TimePass
//
//  Created by Christos Skevis on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "UISettings.h"
#import "SyncEngine.h"
#import "UserEngine.h"
#import "InvitationEngine.h"
#import "EventEngine.h"
#define ApplicationDelegate ((TimepassAppDelegate *)[UIApplication sharedApplication].delegate)
#import "Facebook.h"
#import "MBProgressHUD.h"

@interface TimepassAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
    UIWindow *window;
    NSMutableData *receivedData;
    NSMutableArray *arrTwitterData;
	Facebook *facebook;
    BOOL isFBpost;
	BOOL firstLoad;
}

@property (nonatomic) BOOL isFBpost;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain)NSMutableArray *arrTwitterData;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) IBOutlet UIViewController *rootViewController;

@property (strong, nonatomic) IBOutlet UIImageView *loadingView;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) MKNetworkEngine *gaeEngine;
@property (strong, nonatomic) SyncEngine *syncEngine;
@property (strong, nonatomic) UserEngine *userEngine;
@property (strong, nonatomic) InvitationEngine *invitationEngine;
@property (strong, nonatomic) EventEngine *eventEngine;
@property (strong, nonatomic) MKNetworkEngine *facebookEngine;

@property (nonatomic, strong) MKNetworkOperation *userOperation;

@property (strong, nonatomic) UISettings *uiSettings;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)failIfSimulator;
- (void)changeNavigationRoot:(UIViewController *) newRoot;
- (void)GetFacebookFriends;
- (void)InitfacebookForGetFriends;
- (void)DoFbPost:(NSString *)post;
- (void)handleNotificationsWithDictionary:(NSDictionary *)userInfo;
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

@end