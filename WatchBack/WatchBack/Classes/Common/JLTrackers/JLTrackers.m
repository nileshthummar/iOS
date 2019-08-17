//
//  JLTrackers.m
//  Watchback
//
//  Created by Nilesh on 10/23/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "JLTrackers.h"
#import <AdSupport/AdSupport.h>
#import "JLUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "PerkoAuth.h"
#import "ADBMobile.h"
#import "ADBMediaHeartbeat+Nielsen.h"
#import <ComScore/ComScore.h>
#import "Leanplum.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "Singular.h"
static JLTrackers * trackers;
@interface JLTrackers ()<AppsFlyerTrackerDelegate>

@end
@implementation JLTrackers
+(id)sharedTracker{
    if(trackers==nil){
        trackers = [[JLTrackers alloc] init];
    }
    return trackers;
}
-(void)initTracker
{

    [self initAdobe];
    [self trackAdobeLoadingEvents];
    [self initHeartbeat];
    [self initComScore];
    [self initAppsFlyer];
    
    [Fabric with:@[[Crashlytics class]]];
    
}

-(void)trackFBEvent:(NSString *)strEventName params:(NSDictionary *)params
{   
    //[FBSDKAppEvents logEvent:strEventName];
    if(!strEventName){
        return;
    }
    if(!params){
        [FBSDKAppEvents logEvent:strEventName];
    }else{
        [FBSDKAppEvents logEvent:strEventName parameters:params];
    }
}


#pragma mark -
#pragma mark Crashlytics methods

- (void) setCrashlyticsDataForCurrentUser{
	
	JLPerkUser * user = [PerkoAuth getPerkUser];
    
    [[Crashlytics sharedInstance] setUserIdentifier:user.userId];
    [[Crashlytics sharedInstance] setUserEmail:user.email];

}

- (NSMutableDictionary *) getUserAttributes
{
    // Set User GUID if available.
    NSMutableDictionary* userAttributes = [[NSMutableDictionary alloc] init];
    [userAttributes setObject:[NSString stringWithFormat:@"%@",PerkoAuth.getPerkUser.userUUID]
                       forKey:@"perk_uuid"];
    return userAttributes;
}

-(void)initAdobe{
   
    NSMutableDictionary *contextData = [NSMutableDictionary dictionary];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [contextData setObject:[NSString stringWithFormat:@"%@",idfa] forKey:@"tve.did"];
    [contextData setObject:@"NBCUniversal Watchback Rewards" forKey:@"tve.app"];
    [contextData setObject:@"iOS" forKey:@"tve.platform"];
    [contextData setObject:@"NBCUniversal" forKey:@"tve.network"];
    /////
    NSDate * currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *minute = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:00"];
    NSString *hour = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *day = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    [contextData setObject:minute forKey:@"tve.minute"];
    [contextData setObject:hour forKey:@"tve.hour"];
    [contextData setObject:day forKey:@"tve.day"];
    [contextData setObject:date forKey:@"tve.date"];
    ////
    [ADBMobile collectLifecycleDataWithAdditionalData:contextData];
    
}
-(void)trackAdobeStates:(NSString *)name data:(NSDictionary *)dict{
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        dict = @{};
    }
    /////
    NSMutableDictionary *contextData = [NSMutableDictionary dictionaryWithDictionary:dict];
    [contextData setObject:@"NBCUniversal Watchback Rewards" forKey:@"tve.app"];
    [contextData setObject:@"iOS" forKey:@"tve.platform"];
    [contextData setObject:@"NBCUniversal" forKey:@"tve.network"];
    
    NSDate * currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *minute = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:00"];
    NSString *hour = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *day = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    [contextData setObject:minute forKey:@"tve.minute"];
    [contextData setObject:hour forKey:@"tve.hour"];
    [contextData setObject:day forKey:@"tve.day"];
    [contextData setObject:date forKey:@"tve.date"];
    ////
    
    [ADBMobile trackState:name data:contextData];
}
-(void)trackAdobeActions:(NSString *)name data:(NSDictionary *)dict{
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        dict = @{};
    }
    /////
    NSMutableDictionary *contextData = [NSMutableDictionary dictionaryWithDictionary:dict];
    [contextData setObject:@"NBCUniversal Watchback Rewards" forKey:@"tve.app"];
    [contextData setObject:@"iOS" forKey:@"tve.platform"];
    [contextData setObject:@"NBCUniversal" forKey:@"tve.network"];
    
    NSDate * currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *minute = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:00"];
    NSString *hour = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *day = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    [contextData setObject:minute forKey:@"tve.minute"];
    [contextData setObject:hour forKey:@"tve.hour"];
    [contextData setObject:day forKey:@"tve.day"];
    [contextData setObject:date forKey:@"tve.date"];
    ////
    
    [ADBMobile trackAction:name data:contextData];
}

-(void)applicationDidEnterBackground{
    m_BackgroundDate =[NSDate date];
}
-(void)applicationWillEnterForeground{
    if (m_BackgroundDate && [m_BackgroundDate isKindOfClass:[NSDate class]]) {
        NSTimeInterval timeDiff =  [m_BackgroundDate timeIntervalSinceNow];
        int minutes = floor(timeDiff/60);
        if (minutes > 5) {
            [self initAdobe];
        }
    }
}
-(void)trackAdobeLoadingEvents{
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Loading" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Loading" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Loading" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Loading" data:dictTrackingData];
    ////
    ////////////
    dictTrackingData = [[NSMutableDictionary alloc] init];
    
    [dictTrackingData setObject:@"Loading" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Event:Log-In Check" forKey:@"tve.userpath"];    
    [dictTrackingData setObject:@"Loading" forKey:@"tve.contenthub"];
    
    
    ////
    
    if ([PerkoAuth IsUserLogin]) {
        [dictTrackingData setObject:@"true" forKey:@"tve.userlogin"];
        JLPerkUser *user = [PerkoAuth getPerkUser];
        [dictTrackingData setObject:[NSString stringWithFormat:@"%@",user.userId] forKey:@"tve.userid"];
        [dictTrackingData setObject:@"Logged In" forKey:@"tve.userstatus"];
        NSString *strDateOfBirth = [NSString stringWithFormat:@"%@",user.birthday];
        if(strDateOfBirth != nil && ![strDateOfBirth isEqualToString:@"(null)"] && ![strDateOfBirth isEqualToString:@"<null>"]){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSDate *recDate = [dateFormatter dateFromString:strDateOfBirth];
            if (recDate != nil) {
                [dateFormatter setDateFormat:@"yyyy"];
                NSString *year = [dateFormatter stringFromDate:recDate];
                [dictTrackingData setObject:[NSString stringWithFormat:@"%@",year] forKey:@"tve.usercat1"];
            }
        }
        [dictTrackingData setObject:[NSString stringWithFormat:@"%@",user.gender] forKey:@"tve.usercat2"];
        BOOL facebook_login =  [[[JLManager sharedManager] getObjectuserDefault:kIsUserFacebookLogin] boolValue];
        if (facebook_login) {
            [dictTrackingData setObject:@"Facebook" forKey:@"tve.registrationtype"];
        }
        else{
            [dictTrackingData setObject:@"Email" forKey:@"tve.registrationtype"];
        }
    }
    else{
        [dictTrackingData setObject:@"false" forKey:@"tve.userlogin"];
        [dictTrackingData setObject:@"unkown" forKey:@"tve.userid"];
        [dictTrackingData setObject:@"Not Logged In" forKey:@"tve.userstatus"];
        [dictTrackingData setObject:@"unkown" forKey:@"tve.usercat1"];
        [dictTrackingData setObject:@"unkown" forKey:@"tve.usercat2"];
    }
    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Log-In Check" data:dictTrackingData];
}
-(void)initHeartbeat{
    // Configure Nielsen API
    [ADBMediaHeartbeat nielsenConfigure:@{
                                          @"appid"      : @"P54B3792C-4737-4437-8D14-28F044730D77",
                                          @"appversion" : [NSString stringWithFormat:@"%@",GetBuildVersion()],
                                          @"appname"    : @"NBCUniversal Watchback - iOS",
                                          @"sfcode"     : @"dcr"
                                          //,@"no1_devDebug"     : @"DEBUG" //debug "DEBUG" during certification Leave blank for production builds

                                          }];
    
    
}

#pragma mark -- comScore
-(void)initComScore{
    SCORPublisherConfiguration *myPublisherConfig = [SCORPublisherConfiguration publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder) {
        builder.publisherId = @"6035083";
        builder.publisherSecret = @"5f94da45f8b0635bdfd6c1ccd9df1227";
        builder.applicationName = @"NBCUniversal Watchback Rewards";
        
    }];
    [[SCORAnalytics configuration] addClientWithConfiguration:myPublisherConfig];
    
    [SCORAnalytics start];
    
    
}
-(void)notifyEnterForeground
{
    [SCORAnalytics notifyEnterForeground];
}
-(void)notifyExitForeground
{
    [SCORAnalytics notifyExitForeground];
}
-(void)notifyUxActive
{
    [SCORAnalytics notifyUxActive];
}
-(void)notifyUxInactive
{
    [SCORAnalytics notifyUxInactive];
}
-(void)trackLeanplumEvent:(NSString *)strEventName param:(NSDictionary *)dict{
    [Leanplum track:strEventName withParameters:dict];
}
-(void)trackLeanplumState:(NSString *)strStateName{
    [Leanplum advanceTo:strStateName];
}

////

-(void)initAppsFlyer{
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"Y9nn3tzNT5mbQVPDDjUTWf";
    [AppsFlyerTracker sharedTracker].appleAppID = perkAppID;
    [AppsFlyerTracker sharedTracker].delegate = self;
//#ifdef DEBUG
//    [AppsFlyerTracker sharedTracker].isDebug = true;
//#endif
    
    
}

#pragma AppsFlyer Delegate
- (void) onConversionDataReceived:(NSDictionary*) installData{
   /* id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        if(kDebugLog)NSLog(@"This is a none organic install. Media source: %@  Campaign: %@",sourceID,campaign);
    } else if([status isEqualToString:@"Organic"]) {
        if(kDebugLog)NSLog(@"This is an organic install.");
    
    }*/
    if(kDebugLog)NSLog(@"onConversionDataReceived -> %@",installData);
    NSString *install_time = [NSString stringWithFormat:@"%@",[installData objectForKey:@"install_time"]];
    [[JLManager sharedManager] setObjectuserDefault:install_time forKey:kAppsFlyerInstallTime];
    [self trackAppsFlyerRetentionEvent:@"app_open"];
}
- (void) onConversionDataRequestFailure:(NSError *)error{
    
}
- (void) onAppOpenAttribution:(NSDictionary*) attributionData{
    
}
- (void) onAppOpenAttributionFailure:(NSError *)error{
    
}


-(void)applicationDidBecomeActive{
   
        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
//        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunchWithCompletionHandler:^(NSDictionary<NSString *,id> *dictionary, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        if (dictionary) {
            NSLog(@"%@", dictionary);
            return;
        }
        [NSException exceptionWithName:@"fatalError" reason:nil userInfo:nil];
    }];
    
        // your other code here.... }
    
    [self startSessionSingular];
}
- (void)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
    if (@available(iOS 9.0, *)) {
        [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
    } else {
        // Fallback on earlier versions
    }
    
    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        [self startSessionSingularWithUrl:url];
    }
    
}

// Reports app open from deep link from apps which do not support Universal Links (Twitter) and for iOS8 and below
- (void)openURL:(NSURL *)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation {
    [[AppsFlyerTracker sharedTracker] handleOpenURL:url sourceApplication:sourceApplication withAnnotation:annotation];
    
}
// Reports app open from deep link for iOS 10
- (void)openURL:(NSURL *)url
            options:(NSDictionary *) options {
    [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
    [self startSessionSingularWithUrl:url];
    
}
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[AppsFlyerTracker sharedTracker] registerUninstall:deviceToken];
}
- (void) trackAppsFlyerEvent:(NSString *)eventName withValues:(NSDictionary*)values{
    [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:values];
}

#pragma mark --Singular
-(void)startSessionSingular{
    [Singular startSession:@"perkmobile" withKey:@"ycoJRRsZ"];
}
-(void)startSessionSingularWithUrl:(NSURL *)url{
    [Singular startSession:@"perkmobile" withKey:@"ycoJRRsZ" andLaunchURL:url];
}
-(void)trackSingularEvent:(NSString *)strEventName{
    [Singular event:strEventName];
}
-(void)trackLeanplumEvent:(NSString *)strEventName{
    @try {
        [Leanplum track:strEventName];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
-(void)trackAppsFlyerRetentionEvent:(NSString *)strEventName{
    NSString *install_time = [[JLManager sharedManager] getObjectuserDefault:kAppsFlyerInstallTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *fromDateTime  = [dateFormatter dateFromString:install_time];
    if (fromDateTime && [fromDateTime isKindOfClass:[NSDate class]]) {
        NSDate *toDateTime = [NSDate date];
        
        NSDate *fromDate;
        NSDate *toDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:fromDateTime];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:toDateTime];
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:fromDate toDate:toDate options:0];
        int nDays = (int)[difference day]+1;
        
        if (nDays == 1) {
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:[NSString stringWithFormat:@"D1_%@",strEventName] withValues:nil];
        }
        else if(nDays == 3){
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:[NSString stringWithFormat:@"D3_%@",strEventName] withValues:nil];
        }
        else if(nDays == 7){
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:[NSString stringWithFormat:@"D7_%@",strEventName] withValues:nil];
        }
        else if(nDays == 15){
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:[NSString stringWithFormat:@"D15_%@",strEventName] withValues:nil];
        }
    }
    
    
}
@end
