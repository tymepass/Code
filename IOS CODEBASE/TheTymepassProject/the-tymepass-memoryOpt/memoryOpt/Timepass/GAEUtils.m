//
//  GAEUtils.m
//  Timepass
//
//  Created by Christos Skevis on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GAEUtils.h"
#import "UAirship.h"
#import "User+GAEUser.h"
#import "Event+GAE.h"
#import "CalSync.h"
#import "GlobalData.h"

static MBProgressHUD *HUD;

@implementation GAEUtils
@synthesize receivedData;
@synthesize responseData;
@synthesize requestStack;

+(GAEUtils*) sharedGAEUtils {
    static dispatch_once_t pred;
    static GAEUtils *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[GAEUtils alloc] init];
    });
    
    return shared;
}

+(NSString *) documentsPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    return documentsDir;
    
}

+ (NSArray *) sendRequest:(NSMutableDictionary *) jsonObject toURL:(NSString *) urlString{
    //remove previous returned response data
    //[[GAEUtils sharedGAEUtils] setResponseData:nil];
	
	// send timezone to the server
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSDate* sourceDate = [NSDate date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    [jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timeZone"];
	
    NSError *error;
    NSString *jsonString = [[SBJsonWriter alloc] stringWithObject:jsonObject error:&error];
    //if (error) //debugLog(@"%@", error);
    //add the JSON string and the url to core data requests
    
    NSData *postData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    //debugLog(@"json post data:%@ to URL : %@",postDataString, urlString);
    
    // Create the NSURL for the request
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSArray *response = [GAEUtils getAndParseResponse:request];
    //debugLog(@"RESPONSE: %@", [response JSONRepresentation]);
    
    return response;
}

+ (NSArray *) getAndParseResponse:(NSMutableURLRequest *) request{
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSArray *response = [[NSArray alloc] init];
    
    if (error == 0) {
        NSString *detailMessage = [[NSString alloc]
                                   initWithFormat:@"Connection failed: %@",
                                   [error description]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:detailMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        
        [alert show];
        
    } else {
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        response = [parser objectWithString:responseString error:nil];
    }
    
    return response;
}

+ (NSMutableDictionary *) addToDictWith:(NSString *) invitationText
                               andPhoto:(NSString *) invitationPhoto
                                 status:(NSString *) status
                           invitationId:(NSString *) invitationId
                                 object:(id)object
                                   type:(NSString *) type
                          messagesCount:(NSString *) messagesCount {
    NSMutableDictionary *theDict;
    NSMutableArray* theKeys;
    NSMutableArray* theObjects;
	
	if (invitationPhoto == nil || [invitationPhoto isEqual:[NSNull null]]) {
		invitationPhoto = @"";
	}
    
    theKeys = [NSMutableArray arrayWithObjects:@"text",@"photo",@"status", @"invitationId",@"object", @"type", @"messagesCount", nil];
    theObjects = [NSMutableArray arrayWithObjects:invitationText,invitationPhoto,status,invitationId, object, type, messagesCount, nil];
    theDict = [NSMutableDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
    return theDict;
}

+ (void) getSyncDataFromGAEFor:(User *) user
{
    if (![user serverId]) {
        if (ApplicationDelegate.loadingView) {
            [ApplicationDelegate.loadingView removeFromSuperview];
            ApplicationDelegate.loadingView = nil;
        }
        
        return;
    }
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	double timeInterval = [[NSDate date] timeIntervalSince1970];
	[defaults setDouble:timeInterval forKey:@"firstSync"];
	[defaults synchronize];
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:[user serverId] forKey:@"id"];
	
	if ([[UAirship shared] deviceToken])
        [jsonObject setObject:[[UAirship shared] deviceToken] forKey:@"deviceId"];
	
	// send timezone to the server
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSDate* sourceDate = [NSDate date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    [jsonObject setObject:[NSNumber numberWithInt:destinationGMTOffset] forKey:@"timeZone"];
    
    [ApplicationDelegate.syncEngine jsonObject:jsonObject onCompletion:^(NSString *responseString) {
		SBJsonParser *parser = [[SBJsonParser alloc] init];
		NSArray *responseData = [parser objectWithString:responseString error:nil];
		
		//debugLog(@"responseData: %@",[responseData description]);
		
		if ([responseData count] > 0) {
			NSArray *userAndEventsList = [[responseData objectAtIndex:0] objectForKey:@"UsersAndEvents"];
			
			NSMutableArray *deleteEventIdsArray = [[NSMutableArray alloc] init];
			NSMutableArray *notExistingEventIdsArray = [[NSMutableArray alloc] init];
			NSMutableArray *eventAttendingArray = [[NSMutableArray alloc] init];
			
			for (NSDictionary *item in userAndEventsList) {
				if ([item objectForKey:@"userId"]) {
					//check if user exists in CD
					User *newUser = [User checkExistsInCD:[item objectForKey:@"userId"]
												inContext:[modelUtils defaultManagedObjectContext]];
					
					if (!newUser) {
						[User getGAEUserWithId:[item objectForKey:@"userId"]
										CDUser:nil
									 inContext:[modelUtils defaultManagedObjectContext]];
						//debugLog(@"synced user %@", newUser.name);
					} else {
						NSDateFormatter *df = [[NSDateFormatter alloc] init];
						[df setDateFormat:@"yyyy-MM-dd HH:mm"];
						
						if (![[item objectForKey:@"dateModified"] isEqualToString:[df stringFromDate:[newUser dateModified]]]) {
							
							[User getGAEUserWithId:[item objectForKey:@"userId"]
											CDUser:newUser
										 inContext:[modelUtils defaultManagedObjectContext]];
						}
					}
				}
				
				if ([item objectForKey:@"eventId"]) {
					NSString *eventId = [item objectForKey:@"eventId"];
					//debugLog(@"server id %@", eventId);
					//debugLog(@"%@ with date %@", eventId, [item objectForKey:@"dateModified"]);
					Event *syncEvent = [Event getEventWithId:eventId];
					
					if (!syncEvent) {
						//TODO get from server
						//debugLog(@"TODO get event with id %@", eventId);
						
						// if its not a tymepass event then delete that event from tymepass db too
						if ([[item objectForKey:@"isTymePassEvent"] intValue] == 0) {
							
							EKEventStore* eventStore = [[EKEventStore alloc] init];
							EKEvent *ekEvent = [eventStore eventWithIdentifier:[item objectForKey:@"iCalId"]];
							
							if (ekEvent == nil) {
								[deleteEventIdsArray addObject:eventId];
							} else {
								[notExistingEventIdsArray addObject:eventId];
								[eventAttendingArray addObject:item];
							}
							
						} else {
							[notExistingEventIdsArray addObject:eventId];
							[eventAttendingArray addObject:item];
						}
					} else {
						//debugLog(@"event with title %@ existed", syncEvent.title);
						NSDateFormatter *df = [[NSDateFormatter alloc] init];
						[df setDateFormat:@"yyyy-MM-dd HH:mm"];
						
						EKEventStore* eventStore = [[EKEventStore alloc] init];
						EKEvent *event = [eventStore eventWithIdentifier:syncEvent.iCalId];
						if (event == nil) {
							
							if ([syncEvent.isTymePassEvent intValue] == 1) {
								syncEvent = [Event getGAEEventWithId:[item objectForKey:@"eventId"]
															 CDEvent:syncEvent
														   inContext:[modelUtils defaultManagedObjectContext]];
							} else {
								[deleteEventIdsArray addObject:eventId];
							}
						}
					}
				}
			}
			
			//get from GAE the events that don't exist in CD
			//and add them in ical if needed
			if ([notExistingEventIdsArray count] > 0) {
				//get the events that you don't have from server
				[Event getGAEEventWithIds:notExistingEventIdsArray
					 attendingEventStatus:eventAttendingArray
								inContext:[modelUtils defaultManagedObjectContext]];
			}
			
			// code to delete those entries which are deleted from the ical by creator
			if ([deleteEventIdsArray count] > 0) {
				//MOBI 3-10-13 commented below line
//				[Event deleteGAEEventWithIds:deleteEventIdsArray];
			}
			
			// get friends for user
			if ([[GlobalData sharedGlobalData] getGAEFriends]) {
				[ApplicationDelegate.userEngine getGAEFriendKeysOfUser:[[SingletonUser sharedUserInstance] user]];
			}
			
			//after the above is complete we can sync with iCal
			[CalSync syncWithICalOnOneCall:[[SingletonUser sharedUserInstance] user]];

		}
		
		if (ApplicationDelegate.loadingView) {
			[ApplicationDelegate.loadingView removeFromSuperview];
			ApplicationDelegate.loadingView = nil;
		}
		
	} onError:^(NSError* error) {
		DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
		
		if (ApplicationDelegate.loadingView) {
			[ApplicationDelegate.loadingView removeFromSuperview];
			ApplicationDelegate.loadingView = nil;
		}
		
	}];
	
}

+ (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    
    [[[GAEUtils sharedGAEUtils] receivedData] setLength:0];
}

+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [[[GAEUtils sharedGAEUtils] receivedData] appendData:data];
}

+ (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[HUD hide:YES];
    
	NSString *detailMessage = [[NSString alloc]
							   initWithFormat:@"Connection failed: %@",
							   [error description]];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:detailMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    
	[alert show];
}

+ (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[HUD hide:YES];
    
	NSString *jsonResponse = [[NSString alloc] initWithData:[[GAEUtils sharedGAEUtils] receivedData] encoding:NSUTF8StringEncoding ];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *response = [parser objectWithString:jsonResponse error:nil];
    //debugLog(@"RESPONSE : %@", [response JSONRepresentation]);
    
    [[GAEUtils sharedGAEUtils] setResponseData:response];
    
    //debugLog(@"visibleViewController %@",[[ApplicationDelegate navigationController].visibleViewController description]);
    [[ApplicationDelegate navigationController].visibleViewController  viewWillAppear:YES];
}

+ (NSDate *) parseDateFromGAE:(NSString *)date{
	if ([date length] > 0) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd HH:mm"];
		return [df dateFromString:date];
	} else {
		return nil;
	}
}

+ (NSString *) formatDateForGAE:(NSDate *) dateString {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [df stringFromDate:dateString];
}

+ (NSDate *) parseTimeStampFromGAE:(NSString *)dateStr {
	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm"];
	
	NSString *dateString = [df stringFromDate:date];
	
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [df dateFromString:dateString];
}

+ (NSTimeInterval) formatTimeStampForGAE:(NSDate *) dateString {
	return [dateString timeIntervalSince1970];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
+ (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}
@end
