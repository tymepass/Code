//
//  Utils.m
//  Timepass
//
//  Created by Mahmood1 on 14/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "User+Management.h"
#import "MyProfileViewController.h"
#import "FriendsProfileViewController.h"
#import "FriendsFriendsProfileViewController.h"
#import "CreateEventViewController.h"
#import "EventViewController.h"
#import "EventNotInvitedViewController.h"
#import "MyEventViewController.h"

@implementation Utils
@synthesize scratchPad;
static NSDictionary * invitationStatuses;

static inline double getRadians (double degrees) {return degrees * M_PI/180;}

+(Utils*)sharedUtilsInstance {
    static dispatch_once_t pred;
    static Utils *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[Utils alloc] init];
        invitationStatuses = [[NSDictionary alloc] initWithObjectsAndKeys: @"0",@"no", @"1", @"confirmed",@"2", @"maybe",@"3",  @"pending", nil];
    });
    
    return shared;
}

+(int) getStatusOf:(NSString *) invitation{
    return [[invitationStatuses objectForKey:invitation] intValue];
}

+(NSString *)postJson:(NSMutableDictionary *)jsonObject url:(NSString *)urlFormat responseKey:(NSString *)parameter {
    NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject];
    NSData *postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    //debugLog(@"Json post data:%@",postDataString);
    
    // Create the NSURL for the request
    NSURL *url = [NSURL URLWithString:urlFormat];
    
    // Create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url];
    [request setHTTPMethod:@"POST"];
    //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *responseObject = [parser objectWithString:responseString error:nil];
    
    if([responseObject count] > 0){
        NSDictionary *dict = [responseObject objectAtIndex:0];
        NSString *response = [[NSString alloc] initWithFormat:@"%@",[dict objectForKey:parameter]];
        //debugLog(@"Response: %@", response);
        
        return response;
    }
	
    return @"";
	
}

+ (NSString *)sha1:(NSString *)str {
    if(str == [NSString stringWithFormat:@"%d", -1]) return str;
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return [s lowercaseString];
}

+ (NSArray *) scanAddressBook
{
#if TARGET_OS_IPHONE
	
    NSUInteger i;
    CFIndex index;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    //NSString *userName = @"NoName";
    if ( CFArrayGetCount(people) == 0 )
    {
        return nil;
    }
	
    
    for ( i=0; i<CFArrayGetCount(people); i++ ) {
		
        CFStringRef phone;
		ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
		CFStringRef companyName = ABRecordCopyValue(person, kABPersonOrganizationProperty);
		//CFStringRef middleName = ABRecordCopyValue(person, kABPersonMiddleNameProperty);
		NSString *userName = @"Zzzzz No Name";
		
		if (firstName != nil && lastName != nil) {
			userName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		} else if(firstName != nil) {
			userName = [NSString stringWithFormat:@"%@", firstName];
		} else if(lastName != nil) {
			userName = [NSString stringWithFormat:@"%@", lastName];
		} else if(companyName != nil) {
			userName = [NSString stringWithFormat:@"%@", companyName];
		}
		
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
		
		phone = nil;
		
        for ( index=0; index<phoneNumberCount; index++ )
        {
            CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, index);
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, index);
            // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
            // Find the ones you want here
            //
			
			if (phoneNumberLabel != nil) {
				
				NSString *phoneNumber = [NSString stringWithFormat:@"%@", phoneNumberValue];
				
				NSStringCompareOptions  compareOptions = NSCaseInsensitiveSearch;
				if(!CFStringCompare(phoneNumberValue, CFSTR("1-800-MY-APPLE"),compareOptions)) {
					continue;
				}
				
				NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name", @"small_name",@"phone", @"email", @"checked", nil];
				NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:userName, [userName lowercaseString], phoneNumber, @"", @"NO", nil];
				NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
				[result addObject:theDict];
			}
        }
		
		ABMutableMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
		CFIndex mailsNumberCount = ABMultiValueGetCount( emails );
		
		NSString *email = @"";
		if (mailsNumberCount > 0) {
			for ( index=0; index < mailsNumberCount; index++ ) {
				CFStringRef emailValue = ABMultiValueCopyValueAtIndex( emails,index);
				email = [NSString stringWithFormat:@"%@", emailValue];
				
				NSMutableArray *theKeys = [NSMutableArray arrayWithObjects:@"name", @"small_name",@"phone", @"email", @"checked", nil];
				NSMutableArray *theObjects = [NSMutableArray arrayWithObjects:userName, [userName lowercaseString], @"", email, @"NO", nil];
				NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
				[result addObject:theDict];
			}
		}
	}
	
	//sort array
	NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"small_name" ascending:YES];
	NSArray * sortedArray = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
	return sortedArray;
#else
	return nil ;
#endif
}

+ (NSString *) userSettingsPath{
    // Path to the plist (in the application bundle)
    NSString *path;
    //get user
    User *user  = [[SingletonUser sharedUserInstance] user];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistDirectory = [paths objectAtIndex:0];
    
    path = [plistDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"settings_%@.plist", user.serverId]];
    //path = [path stringByReplacingOccurrencesOfString:@"@" withString:@"_"];
    [Utils checkIfSettingsPathExist:path];
    return path;
}

+ (void) checkIfSettingsPathExist:(NSString *)path{
    NSString *fullPath = path;
    //TODO check i plist already exists
    if(![[NSFileManager defaultManager] fileExistsAtPath: fullPath]) {
        NSArray *userObjects = [[NSArray alloc] initWithObjects:@"1", @"0", @"1", nil];
        NSArray *userKeys = [[NSArray alloc] initWithObjects:@"iCal_sync", @"gCal_sync", @"fCal_sync", nil];
        
        NSDictionary *userSettings = [[NSDictionary alloc] initWithObjects:userObjects forKeys:userKeys];
        
        [userSettings writeToFile:fullPath atomically:YES];
        //debugLog(@"File created an path: %@", fullPath);
        return;
    }
    return;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize {
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, getRadians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, getRadians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, getRadians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}


+ (BOOL) FBAuthorization:(Facebook *) facebook AppId:(NSString *) kAppId  {
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // Check App ID:
    // This is really a warning for the developer, this should not
    // happen in a completed app
    if (!kAppId) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Setup Error"
                                  message:@"Missing app ID. You cannot run the app until you provide this in the code."
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil];
        [alertView show];
        return FALSE;
        
    } else {
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kAppId];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
            ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                    ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Setup Error"
                                      message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK",nil];
            [alertView show];
            return FALSE;
        }
    }
    
    return TRUE;
}

+ (void)storeFBAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

+ (UIImage *) resizedFromImage: (UIImage *) image inPixes:(float) px {
    // Resize, crop the image to make sure it is square and renders
    // well on Retina display
    float ratio;
    float delta;
    //float px = 200; // Double the pixels of the UIImageView (to render on Retina)
    CGPoint offset;
    CGSize size = image.size;
    if (size.width > size.height) {
        ratio = px / size.width;
        delta = (ratio*size.width - ratio*size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = px / size.height;
        delta = (ratio*size.height - ratio*size.width);
        offset = CGPointMake(0, delta/2);
    }
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * size.width) + delta,
                                 (ratio * size.height) + delta);
    UIGraphicsBeginImageContext(CGSizeMake(px, px));
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *imgThumb = UIGraphicsGetImageFromCurrentImageContext();
    //debugLog(@"MyImage size in pixels: %f:%f",imgThumb.size.width , imgThumb.size.height);
    //debugLog(@"MyImage size in bytes: %i",[UIImagePNGRepresentation(imgThumb) length]);
    return imgThumb;
}

+(BOOL) isFriendOfByKey:(NSString *) userId {
    if(userId != nil){
		NSMutableArray *theKey = [NSMutableArray arrayWithObject:@"key"];
		NSMutableArray *theObject = [NSMutableArray arrayWithObject:userId];
		NSMutableDictionary *theDict = [NSMutableDictionary dictionaryWithObjects:theObject forKeys:theKey];
    
		if ([[[SingletonUser sharedUserInstance] gaeFriends] containsObject:theDict])
			return YES;
	}
    
    return NO;
}

+(BOOL) isFriendOfByFacebookId:(NSString *) facebookId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"facebookId == %@", facebookId];
    User *user = (User *)[modelUtils fetchManagedObject:@"User" predicate:predicate sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (!user)
        return NO;
    
    return [Utils isFriendOfByKey:[user serverId]];
}

+(UIViewController *) checkFriendshipOfUser:(User *) userA withUser:(User *) userB {
    UIViewController *viewController;
    
    if ([userA.serverId isEqual:userB.serverId])
        viewController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil user:userA];
    else {
        /*
		 User *user = (User *)[modelUtils fetchManagedObject:@"User" predicate:[NSPredicate predicateWithFormat:@"email == %@", userB.email] sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
		 
		 if (user)
		 viewController = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:userB];
		 else
		 viewController = [[FriendsFriendsProfileViewController alloc] initWithNibName:@"FriendsFriendsProfileViewController" bundle:nil user:userB];
		 */
        
        if ([Utils isFriendOfByKey:[userB serverId]])
            viewController = [[FriendsProfileViewController alloc] initWithNibName:@"FriendsProfileViewController" bundle:nil afriend:userB];
        else
            viewController = [[FriendsFriendsProfileViewController alloc] initWithNibName:@"FriendsFriendsProfileViewController" bundle:nil user:userB];
    }
    
    return viewController;
}

+(UIViewController *) checkEventStatusOfUser:(User *) user forEvent:(Event *) eventObj {
    UIViewController *viewController;
    
    //if it is in cd you are invited or it is yours
    Event *event = (Event *) [modelUtils fetchManagedObject:@"Event" predicate:[NSPredicate predicateWithFormat:@"serverId == %@", eventObj.serverId] sortDescriptors:nil moc:[modelUtils defaultManagedObjectContext]];
    
    if (event) {
        //check if i am the creator
        if (event.creatorId == user) {
            viewController = [[MyEventViewController alloc] initWithNibName:@"MyEventViewController" bundle:nil event:event];
            //viewController = [[CreateEventViewController alloc] initWithNibName:@"CreateEventViewController" bundle:nil event:event];
        } else {
            viewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil event:event];
        }
    } else {
		if ([eventObj.isOpen intValue] == 1) {
			
			float reminderTime;
			switch ([eventObj.reminder intValue]) {
				case 0:
					reminderTime = 0.0f;
					break;
				case 1:
					reminderTime = -1.0f;
					break;
				case 2:
					reminderTime = 60.0 * 5.0f;
					break;
				case 3:
					reminderTime = 60.0f * 15.0f;
					break;
				case 4:
					reminderTime = 60.0f * 30.0f;
					break;
				case 5:
					reminderTime = 60.0f * 60.0f;
					break;
				case 6:
					reminderTime = 60.0f * 120.0f;
					break;
				case 7:
					reminderTime = 24.0f * 60.0f * 60.0f;
					break;
				case 8:
					reminderTime = 48.0f * 60.0f * 60.0f;
					break;
				case 9:
					reminderTime = 7.0f * 24.0f * 60.0f * 60.0f;
					break;
				default:
					reminderTime = 900.0f;
					break;
			}

			User *creatorUser = [User getUserWithId:[eventObj.creatorId serverId] inContext:[modelUtils defaultManagedObjectContext]];
			
			Event *newEvent = [Event createEventWithTitle:eventObj.title
													 info:eventObj.info
												startTime:eventObj.startTime
												  endTime:eventObj.endTime
												   isGold:eventObj.isGold
												   iCalId:nil
												recurring:eventObj.recurring
										 recurringEndDate:eventObj.recurranceEndTime
												 serverId:eventObj.serverId
													photo:eventObj.photo
											   isEditable:[NSNumber numberWithInt:0]
												 isAllDay:eventObj.isAllDay
												attending:[NSNumber numberWithInt:3]
												isPrivate:eventObj.isPrivate
												   isOpen:eventObj.isOpen
										  isTymePassEvent:[NSNumber numberWithInt:1]
												messageId: nil
											   locationId:nil
												  creator:creatorUser
													 user:[[SingletonUser sharedUserInstance] user]
												 reminder:eventObj.reminder
											 reminderTime:reminderTime
											 reminderDate:eventObj.reminderDate
											 dateModified:[NSDate date]
											  dateCreated:[NSDate date]
											  invitations:nil
											eventMessages:nil
											  privateFrom:nil
							   ];
			[newEvent setServerId:eventObj.serverId];
			[newEvent setInvitedBy:creatorUser];
			[modelUtils commitDefaultMOC];
			
			viewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil event:newEvent];
		} else {
			viewController = [[EventNotInvitedViewController alloc] initWithNibName:@"EventNotInvitedViewController" bundle:nil event:eventObj];
		}
        
    }
    
    return viewController;
}


+(NSString *) urlEncodedAndEmojiConverion:(NSString *) stringValue {
    NSString *encodedString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes
    (NULL,
     (__bridge CFStringRef)stringValue,
     NULL,
     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
     kCFStringEncodingUTF8 );
    
    //Emoji conversion (hex -> unicode)
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%84" withString:@"\ue415"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%8A" withString:@"\ue056"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%83" withString:@"\ue057"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%BA" withString:@"\ue414"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%89" withString:@"\ue405"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%8D" withString:@"\ue106"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%98" withString:@"\ue418"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%9A" withString:@"\ue417"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%B3" withString:@"\ue40d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%8C" withString:@"\ue40a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%81" withString:@"\ue404"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%9C" withString:@"\ue105"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%9D" withString:@"\ue409"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%92" withString:@"\ue40e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%8F" withString:@"\ue402"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%93" withString:@"\ue108"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%94" withString:@"\ue403"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%9E" withString:@"\ue058"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%96" withString:@"\ue407"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A5" withString:@"\ue401"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%B0" withString:@"\ue40f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A8" withString:@"\ue40b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A3" withString:@"\ue406"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A2" withString:@"\ue413"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%AD" withString:@"\ue411"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%82" withString:@"\ue412"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%B2" withString:@"\ue410"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%B1" withString:@"\ue107"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A0" withString:@"\ue059"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%A1" withString:@"\ue416"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%AA" withString:@"\ue408"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%98%B7" withString:@"\ue40c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%BF" withString:@"\ue11a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%BD" withString:@"\ue10c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%9B" withString:@"\ue32c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%99" withString:@"\ue32a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%9C" withString:@"\ue32d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%97" withString:@"\ue328"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%9A" withString:@"\ue32b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9D%A4" withString:@"\ue022"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%94" withString:@"\ue023"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%93" withString:@"\ue327"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%98" withString:@"\ue329"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%A8" withString:@"\ue32e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%9F" withString:@"\ue32f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A2" withString:@"\ue334"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9D%95" withString:@"\ue337"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9D%94" withString:@"\ue336"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A4" withString:@"\ue13c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A8" withString:@"\ue330"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A6" withString:@"\ue331"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B6" withString:@"\ue326"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B5" withString:@"\ue03e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%A5" withString:@"\ue11d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A9" withString:@"\ue05a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8D" withString:@"\ue00e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8E" withString:@"\ue421"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8C" withString:@"\ue420"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8A" withString:@"\ue00d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%8A" withString:@"\ue010"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%8C" withString:@"\ue011"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8B" withString:@"\ue41e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8D" withString:@"\ue012"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%90" withString:@"\ue422"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8F" withString:@"\ue22e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%87" withString:@"\ue22f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%89" withString:@"\ue231"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%88" withString:@"\ue230"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%99%8C" withString:@"\ue427"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%99%8F" withString:@"\ue41d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%9D" withString:@"\ue00f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%8F" withString:@"\ue41f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%AA" withString:@"\ue14c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%B6" withString:@"\ue201"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%83" withString:@"\ue115"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%AB" withString:@"\ue428"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%83" withString:@"\ue51f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%AF" withString:@"\ue429"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%99%86" withString:@"\ue424"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%99%85" withString:@"\ue423"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%81" withString:@"\ue253"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%99%87" withString:@"\ue426"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%8F" withString:@"\ue111"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%91" withString:@"\ue425"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%86" withString:@"\ue31e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%87" withString:@"\ue31f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%85" withString:@"\ue31d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A6" withString:@"\ue001"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A7" withString:@"\ue002"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A9" withString:@"\ue005"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A8" withString:@"\ue004"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B6" withString:@"\ue51a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B5" withString:@"\ue519"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B4" withString:@"\ue518"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B1" withString:@"\ue515"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B2" withString:@"\ue516"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B3" withString:@"\ue517"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B7" withString:@"\ue51b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%AE" withString:@"\ue152"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%BC" withString:@"\ue04e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%B8" withString:@"\ue51c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%82" withString:@"\ue51e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%80" withString:@"\ue11c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A3" withString:@"\ue536"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%8B" withString:@"\ue003"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%84" withString:@"\ue41c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%82" withString:@"\ue41b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%80" withString:@"\ue419"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%83" withString:@"\ue41a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%80" withString:@"\ue04a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%94" withString:@"\ue04b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%81" withString:@"\ue049"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%84" withString:@"\ue048"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%99" withString:@"\ue04c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9A%A1" withString:@"\ue13d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%80" withString:@"\ue443"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%8A" withString:@"\ue43e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B1" withString:@"\ue04f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B6" withString:@"\ue052"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%AD" withString:@"\ue053"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B9" withString:@"\ue524"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B0" withString:@"\ue52c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%BA" withString:@"\ue52a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B8" withString:@"\ue531"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%AF" withString:@"\ue050"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%A8" withString:@"\ue527"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%BB" withString:@"\ue051"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B7" withString:@"\ue10b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%AE" withString:@"\ue52b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%97" withString:@"\ue52f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B5" withString:@"\ue528"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%92" withString:@"\ue01a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B4" withString:@"\ue134"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%8E" withString:@"\ue530"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%AB" withString:@"\ue529"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%91" withString:@"\ue526"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%98" withString:@"\ue52d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%8D" withString:@"\ue521"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%A6" withString:@"\ue523"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%A4" withString:@"\ue52e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%94" withString:@"\ue055"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%A7" withString:@"\ue525"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%9B" withString:@"\ue10a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%99" withString:@"\ue109"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%A0" withString:@"\ue522"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%9F" withString:@"\ue019"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%B3" withString:@"\ue054"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%AC" withString:@"\ue520"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%90" withString:@"\ue306"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%B8" withString:@"\ue030"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%B7" withString:@"\ue304"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%80" withString:@"\ue110"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%B9" withString:@"\ue032"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%BB" withString:@"\ue305"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%BA" withString:@"\ue303"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%81" withString:@"\ue118"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%83" withString:@"\ue447"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%82" withString:@"\ue119"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%B4" withString:@"\ue307"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%B5" withString:@"\ue308"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%BE" withString:@"\ue444"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%90%9A" withString:@"\ue441"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%8D" withString:@"\ue436"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%9D" withString:@"\ue437"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%8E" withString:@"\ue438"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%92" withString:@"\ue43a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%93" withString:@"\ue439"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%8F" withString:@"\ue43b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%86" withString:@"\ue117"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%87" withString:@"\ue440"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%90" withString:@"\ue442"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%91" withString:@"\ue446"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%83" withString:@"\ue445"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%BB" withString:@"\ue11b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%85" withString:@"\ue448"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%84" withString:@"\ue033"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%81" withString:@"\ue112"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%94" withString:@"\ue325"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%89" withString:@"\ue312"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%88" withString:@"\ue310"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%BF" withString:@"\ue126"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%80" withString:@"\ue127"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B7" withString:@"\ue008"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A5" withString:@"\ue03d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%BB" withString:@"\ue00c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%BA" withString:@"\ue12a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B1" withString:@"\ue00a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%A0" withString:@"\ue00b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%8E" withString:@"\ue009"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%BD" withString:@"\ue316"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%BC" withString:@"\ue129"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%8A" withString:@"\ue141"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%A2" withString:@"\ue142"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%A3" withString:@"\ue317"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%BB" withString:@"\ue128"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%A1" withString:@"\ue14b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9E%BF" withString:@"\ue211"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%8D" withString:@"\ue114"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%93" withString:@"\ue145"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%92" withString:@"\ue144"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%91" withString:@"\ue03f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%82" withString:@"\ue313"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%A8" withString:@"\ue116"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A1" withString:@"\ue10f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B2" withString:@"\ue104"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%A9" withString:@"\ue103"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%AB" withString:@"\ue101"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%AE" withString:@"\ue102"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9B%80" withString:@"\ue13f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%BD" withString:@"\ue140"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%BA" withString:@"\ue11f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%B0" withString:@"\ue12f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%B1" withString:@"\ue031"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%AC" withString:@"\ue30e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%A3" withString:@"\ue311"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%AB" withString:@"\ue113"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%8A" withString:@"\ue30f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%89" withString:@"\ue13b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%88" withString:@"\ue42b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%80" withString:@"\ue42a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9A%BD" withString:@"\ue018"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9A%BE" withString:@"\ue016"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%BE" withString:@"\ue015"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%B3" withString:@"\ue014"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B1" withString:@"\ue42c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%8A" withString:@"\ue42d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%84" withString:@"\ue017"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%BF" withString:@"\ue013"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%A0" withString:@"\ue20e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%A5" withString:@"\ue20c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%A3" withString:@"\ue20f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%A6" withString:@"\ue20d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%86" withString:@"\ue131"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%BE" withString:@"\ue12b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%AF" withString:@"\ue130"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%80%84" withString:@"\ue12d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%AC" withString:@"\ue324"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%9D" withString:@"\ue301"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%96" withString:@"\ue148"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A8" withString:@"\ue502"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A4" withString:@"\ue03c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A7" withString:@"\ue30a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%BA" withString:@"\ue042"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B7" withString:@"\ue040"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B8" withString:@"\ue041"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E3%80%BD" withString:@"\ue12c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%9F" withString:@"\ue007"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A1" withString:@"\ue31a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A0" withString:@"\ue13e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%A2" withString:@"\ue31b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%95" withString:@"\ue006"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%94" withString:@"\ue302"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%97" withString:@"\ue319"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%98" withString:@"\ue321"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%99" withString:@"\ue322"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%80" withString:@"\ue314"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A9" withString:@"\ue503"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%91" withString:@"\ue10e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%92" withString:@"\ue318"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%82" withString:@"\ue43c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%BC" withString:@"\ue11e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%91%9C" withString:@"\ue323"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%84" withString:@"\ue31c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%8D" withString:@"\ue034"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%8E" withString:@"\ue035"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%98%95" withString:@"\ue045"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B5" withString:@"\ue338"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%BA" withString:@"\ue047"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%BB" withString:@"\ue30c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B8" withString:@"\ue044"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B6" withString:@"\ue30b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B4" withString:@"\ue043"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%94" withString:@"\ue120"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9F" withString:@"\ue33b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9D" withString:@"\ue33f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9B" withString:@"\ue341"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B1" withString:@"\ue34c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%A3" withString:@"\ue344"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%99" withString:@"\ue342"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%98" withString:@"\ue33d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9A" withString:@"\ue33e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9C" withString:@"\ue340"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B2" withString:@"\ue34d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%9E" withString:@"\ue339"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B3" withString:@"\ue147"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%A2" withString:@"\ue343"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%A1" withString:@"\ue33c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%A6" withString:@"\ue33a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%A7" withString:@"\ue43f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%82" withString:@"\ue34b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%B0" withString:@"\ue046"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%8E" withString:@"\ue345"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%8A" withString:@"\ue346"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%89" withString:@"\ue348"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%93" withString:@"\ue347"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%86" withString:@"\ue34a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8D%85" withString:@"\ue349"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A0" withString:@"\ue036"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%AB" withString:@"\ue157"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A2" withString:@"\ue038"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A3" withString:@"\ue153"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A5" withString:@"\ue155"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A6" withString:@"\ue14d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%AA" withString:@"\ue156"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A9" withString:@"\ue501"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A8" withString:@"\ue158"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%92" withString:@"\ue43d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%AA" withString:@"\ue037"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%AC" withString:@"\ue504"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%87" withString:@"\ue44a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%86" withString:@"\ue146"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%A7" withString:@"\ue154"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%AF" withString:@"\ue505"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%B0" withString:@"\ue506"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%BA" withString:@"\ue122"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%AD" withString:@"\ue508"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%97%BC" withString:@"\ue509"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%97%BB" withString:@"\ue03b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%84" withString:@"\ue04d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%85" withString:@"\ue449"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%83" withString:@"\ue44b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%97%BD" withString:@"\ue51d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8C%88" withString:@"\ue44c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A1" withString:@"\ue124"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%B2" withString:@"\ue121"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A2" withString:@"\ue433"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%A2" withString:@"\ue202"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%A4" withString:@"\ue135"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%B5" withString:@"\ue01c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%88" withString:@"\ue01d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%80" withString:@"\ue10d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%B2" withString:@"\ue136"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%99" withString:@"\ue42e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%97" withString:@"\ue01b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%95" withString:@"\ue15a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%8C" withString:@"\ue159"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%93" withString:@"\ue432"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%92" withString:@"\ue430"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%91" withString:@"\ue431"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%9A" withString:@"\ue42f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%83" withString:@"\ue01e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%89" withString:@"\ue039"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%84" withString:@"\ue435"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%85" withString:@"\ue01f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%AB" withString:@"\ue125"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%BD" withString:@"\ue03a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%A5" withString:@"\ue14e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9A%A0" withString:@"\ue252"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%A7" withString:@"\ue137"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%B0" withString:@"\ue209"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%B0" withString:@"\ue133"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%8F" withString:@"\ue150"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%88" withString:@"\ue320"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%A8" withString:@"\ue123"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8F%81" withString:@"\ue132"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%8C" withString:@"\ue143"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%AF%F0%9F%87%B5" withString:@"\ue50b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%B0%F0%9F%87%B7" withString:@"\ue514"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%A8%F0%9F%87%B3" withString:@"\ue513"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%BA%F0%9F%87%B8" withString:@"\ue50c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%AB%F0%9F%87%B7" withString:@"\ue50d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%AA%F0%9F%87%B8" withString:@"\ue511"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%AE%F0%9F%87%B9" withString:@"\ue50f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%B7%F0%9F%87%BA" withString:@"\ue512"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%AC%F0%9F%87%A7" withString:@"\ue510"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%87%A9%F0%9F%87%AA" withString:@"\ue50e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"1%E2%83%A3" withString:@"\ue21c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"2%E2%83%A3" withString:@"\ue21d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"3%E2%83%A3" withString:@"\ue21e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"4%E2%83%A3" withString:@"\ue21f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"5%E2%83%A3" withString:@"\ue220"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"6%E2%83%A3" withString:@"\ue221"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"7%E2%83%A3" withString:@"\ue222"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"8%E2%83%A3" withString:@"\ue223"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"9%E2%83%A3" withString:@"\ue224"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"0%E2%83%A3" withString:@"\ue225"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%23%E2%83%A3" withString:@"\ue210"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%AC%86" withString:@"\ue232"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%AC%87" withString:@"\ue233"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%AC%85" withString:@"\ue235"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9E%A1" withString:@"\ue234"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%86%97" withString:@"\ue236"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%86%96" withString:@"\ue237"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%86%98" withString:@"\ue238"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%86%99" withString:@"\ue239"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%97%80" withString:@"\ue23b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%96%B6" withString:@"\ue23a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%8F%AA" withString:@"\ue23d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%8F%A9" withString:@"\ue23c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%97" withString:@"\ue24d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%95" withString:@"\ue212"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%9D" withString:@"\ue24c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%99" withString:@"\ue213"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%92" withString:@"\ue214"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%8E%A6" withString:@"\ue507"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%81" withString:@"\ue203"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B6" withString:@"\ue20b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B5" withString:@"\ue22a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B3" withString:@"\ue22b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%89%90" withString:@"\ue226"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B9" withString:@"\ue227"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%AF" withString:@"\ue22c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%BA" withString:@"\ue22d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B6" withString:@"\ue215"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%9A" withString:@"\ue216"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B7" withString:@"\ue217"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%B8" withString:@"\ue218"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%88%82" withString:@"\ue228"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%BB" withString:@"\ue151"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%B9" withString:@"\ue138"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%BA" withString:@"\ue139"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%BC" withString:@"\ue13a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%AD" withString:@"\ue208"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%85%BF" withString:@"\ue14f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%BF" withString:@"\ue20a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%87" withString:@"\ue434"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%9A%BE" withString:@"\ue309"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E3%8A%99" withString:@"\ue315"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E3%8A%97" withString:@"\ue30d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%9E" withString:@"\ue207"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%94" withString:@"\ue229"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%B3" withString:@"\ue206"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9C%B4" withString:@"\ue205"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%9F" withString:@"\ue204"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%9A" withString:@"\ue12e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B3" withString:@"\ue250"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%93%B4" withString:@"\ue251"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%B9" withString:@"\ue14a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%92%B1" withString:@"\ue149"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%88" withString:@"\ue23f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%89" withString:@"\ue240"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8A" withString:@"\ue241"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8B" withString:@"\ue242"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8C" withString:@"\ue243"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8D" withString:@"\ue244"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8E" withString:@"\ue245"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%8F" withString:@"\ue246"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%90" withString:@"\ue247"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%91" withString:@"\ue248"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%92" withString:@"\ue249"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%99%93" withString:@"\ue24a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9B%8E" withString:@"\ue24b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%AF" withString:@"\ue23e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%85%B0" withString:@"\ue532"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%85%B1" withString:@"\ue533"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%86%8E" withString:@"\ue534"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%85%BE" withString:@"\ue535"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%B2" withString:@"\ue21a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%B4" withString:@"\ue219"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%94%B3" withString:@"\ue21b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%9B" withString:@"\ue02f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%90" withString:@"\ue024"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%91" withString:@"\ue025"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%92" withString:@"\ue026"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%93" withString:@"\ue027"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%94" withString:@"\ue028"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%95" withString:@"\ue029"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%96" withString:@"\ue02a"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%97" withString:@"\ue02b"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%98" withString:@"\ue02c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%F0%9F%95%99" withString:@"\ue02d"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%C2%AE%F0%9F%95%9A" withString:@"\ue02e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%AD%95" withString:@"\ue332"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%9D%8C" withString:@"\ue333"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%C2%A9" withString:@"\ue24e"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%C2%AE" withString:@"\ue24f"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%E2%84%A2" withString:@"\ue537"];
    
    return encodedString;
    
}

@end