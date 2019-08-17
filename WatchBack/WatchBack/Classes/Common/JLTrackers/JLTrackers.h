//
//  JLTrackers.h
//  Watchback
//
//  Created by Nilesh on 10/23/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLManager.h"

@interface JLTrackers : NSObject
{
    NSDate * m_BackgroundDate;
    
}
+(id _Nullable )sharedTracker;
-(void)initTracker;
-(void)trackFBEvent:(NSString *_Nullable)strEventName params:(NSDictionary *_Nullable)params;
-(void)trackLeanplumEvent:(NSString *_Nullable)strEventName;
-(void)setCrashlyticsDataForCurrentUser;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)trackAdobeStates:(NSString *_Nullable)name data:(NSDictionary *_Nullable)dict;
-(void)trackAdobeActions:(NSString *_Nullable)name data:(NSDictionary *_Nullable)dict;
-(void)notifyEnterForeground;
-(void)notifyExitForeground;
-(void)notifyUxActive;
-(void)notifyUxInactive;
-(void)trackLeanplumEvent:(NSString *_Nullable)strEventName param:(NSDictionary *_Nullable)dict;
-(void)trackLeanplumState:(NSString *_Nullable)strStateName;

-(void)applicationDidBecomeActive;
- (void)continueUserActivity:(NSUserActivity *_Nullable)userActivity restorationHandler:(void (^_Nullable)(NSArray *_Nullable))restorationHandler;
- (void)openURL:(NSURL *_Nullable)url sourceApplication:(NSString*_Nullable)sourceApplication annotation:(id _Nullable )annotation;
- (void)openURL:(NSURL *_Nullable)url options:(NSDictionary *_Nullable) options;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nullable)deviceToken;
- (void) trackAppsFlyerEvent:(NSString *_Nullable)eventName withValues:(NSDictionary*_Nullable)values;

///
-(void)trackSingularEvent:(NSString *_Nullable)strEventName;
-(void)trackAppsFlyerRetentionEvent:(NSString *_Nullable)strEventName;
@end
