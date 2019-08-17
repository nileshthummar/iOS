//
//  AppDelegate.m
//  Watchback
//
//  Created by Nilesh on 1/5/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "AppDelegate.h"
#import "JLManager.h"
#import "Constants.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "WelcomeVC.h"
//#import "LeftMenuVC.h"
#import "PerkTabVC.h"
#import "PerkoAuth.h"
#import <AVFoundation/AVFoundation.h>
#import "NavPortrait.h"
#import "AppBGView.h"
#import "AppTableView.h"
#import "AppLabel.h"
#import "AppButton.h"
#import "AppSecondBGView.h"
#import "Leanplum.h"
#import "WebServices.h"
#import "NavBoth.h"
#import "RedeemWebVC.h"
#import "LFCache.h"
#import <SDWebImage/SDWebImage.h>
#import "CustomSplashScreenVC.h"
#import "CodeVerificationVC.h"

@interface AppDelegate ()
{
    NavPortrait *navWelcomeVC;
    PerkTabVC *objPerkTabVC;
   // NavPortrait *navPerkTabVC;
    CodeVerificationVC * objCodeVerificationVC;
    BOOL m_bIsInitLeanplum;
}
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:0.5];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [JLManager sharedManager];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserLoginSignupNotification) name:kGetUserLoginSignupNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHomeScreen) name:kLoadHomePageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcomeScreen) name:kLoadWelcomePageNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVerificationCodeScreen) name:kLoadVerificationCodePageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissVerificationCodeScreen) name:kDismissVerificationCodePageNotification object:nil];
    
    
    [self themeChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    
    
    [self initLeanplum];
    [[JLManager sharedManager] callAPIForGetDeveloperMode];
   
    
    [self showCustomSplashScreen];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if(kDebugLog)NSLog(@"%@",[[JLManager sharedManager] topViewController]);
    
    [[JLTrackers sharedTracker] applicationDidEnterBackground];
    [[JLTrackers sharedTracker] notifyExitForeground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[JLTrackers sharedTracker] applicationWillEnterForeground];
    [[JLTrackers sharedTracker] notifyEnterForeground];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [UIDevice currentDevice].proximityMonitoringEnabled = NO; // Disables the Proximity Sensor and won't turnoff the display when sensor covered
     [[JLTrackers sharedTracker] notifyUxActive];
    [[JLTrackers sharedTracker] applicationDidBecomeActive];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//    if([PerkoAuth IsUserLogin])
//    {
//        [[JLManager sharedManager] getUserInfo:^(BOOL successUserInfo) {
//
//        }];
//    }
    [[JLManager sharedManager] checkAndClearLocalCacheForWatchedVideos:FALSE];
    
    if([PerkoAuth getPerkUser].IsUserLogin){
    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
        JLPerkUser * loginuser = [PerkoAuth getPerkUser];
        BOOL isphoneverified = true;
        if(loginuser.phone_verified_at == nil ||
           (id)loginuser.phone_verified_at == [NSNull null]){
            isphoneverified = false;
        }
        
        if(!isphoneverified){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoadVerificationCodePageNotification object:nil];
            });
        }
    }];
    }else{
        // dismiss verification screen if present..
        [[NSNotificationCenter defaultCenter] postNotificationName:kDismissVerificationCodePageNotification object:nil];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [[JLTrackers sharedTracker] notifyUxInactive];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:kSaveVideoNotification object:nil];
    [[LFCache sharedManager] saveData];
}
/*- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[JLTrackers sharedTracker] openURL:url sourceApplication:sourceApplication annotation:annotation];
    @try {
        if(kDebugLog)NSLog(@"openURL %@",url);
        if ([url.scheme isEqualToString:@"watchback"] ) {
            
            NSString *urlS = url.absoluteString;
            if (urlS.length > 0)
            {
                [self performSelector:@selector(handlePerkURL:) withObject:urlS afterDelay:1];
                //[self handlePerkURL:urlS];
            }
        }
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    @catch (NSException * e) {
    }
    @finally {
    }
    
    return YES;
}
*/
// Reports app open from deep link for iOS 10
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            options:(NSDictionary *) options {
    [[JLTrackers sharedTracker] openURL:url options:options];
    
    @try {
        if(kDebugLog)NSLog(@"openURL %@",url);
        if ([url.scheme isEqualToString:@"watchback"] ) {
            
            NSString *urlS = url.absoluteString;
            if (urlS.length > 0)
            {
                [self performSelector:@selector(handlePerkURL:) withObject:urlS afterDelay:1];
                //[self handlePerkURL:urlS];
            }
        }
    }
    @catch (NSException * e) {
    }
    @finally {
    }
    
    
    //return YES;
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url options:options];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler{
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    
//    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
//        NSURL *url = userActivity.webpageURL;
//        
//        [[JLTrackers sharedTracker] initApsalarTrackerwithURL:url];
//    }
    
    [[JLTrackers sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}

#pragma mark --
-(void)showCustomSplashScreen{
    CustomSplashScreenVC * objCustomSplashScreenVC = [[CustomSplashScreenVC alloc] initWithNibName:@"CustomSplashScreenVC" bundle:nil];
    navWelcomeVC = [[NavPortrait alloc] initWithRootViewController:objCustomSplashScreenVC];
    navWelcomeVC.navigationBarHidden = YES;
    self.window.rootViewController = navWelcomeVC;
    [self.window makeKeyAndVisible];
}

-(void)showVerificationCodeScreen{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->objCodeVerificationVC = [[CodeVerificationVC alloc] initWithNibName:@"CodeVerificationVC" bundle: nil];
        self->objCodeVerificationVC.phone_no = [PerkoAuth getPerkUser].phoneno;
        self->objCodeVerificationVC.country_code = @"+1";
        UINavigationController * nav = [[NavPortrait alloc] initWithRootViewController:self->objCodeVerificationVC];
        nav.navigationBarHidden = YES;
        [self.window.rootViewController presentViewController:nav animated:YES completion:^{
            
        }];
    });
}
-(void)dismissVerificationCodeScreen{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->objCodeVerificationVC){
                [self->objCodeVerificationVC.navigationController dismissViewControllerAnimated:NO completion:nil];
                self->objCodeVerificationVC = nil;
            }
        });
}

-(void)showWelcomeScreen
{
    
    WelcomeVC *objWelcomeVC = [[WelcomeVC alloc] initWithNibName:@"WelcomeVC" bundle:nil];
    navWelcomeVC = [[NavPortrait alloc] initWithRootViewController:objWelcomeVC];
    navWelcomeVC.navigationBarHidden = YES;
    
    //self.window.rootViewController = navWelcomeVC;
    //[self.window makeKeyAndVisible];
    
    
   // LeftMenuVC *objLeftMenuVC = [[LeftMenuVC alloc] initWithNibName:@"LeftMenuVC" bundle:nil];
    //objPerkTabVC = [[PerkTabVC alloc] init];
   // navPerkTabVC = [[NavPortrait alloc] initWithRootViewController:objPerkTabVC];
   // navPerkTabVC.navigationBarHidden = YES;
    self.window.rootViewController = navWelcomeVC;
    [self.window makeKeyAndVisible];
    
    [[JLManager sharedManager] checkForUserLoginStatusChanged];
}
-(void)setupMainUI{
    objPerkTabVC = [[PerkTabVC alloc] init];
    self.window.rootViewController = objPerkTabVC;
    [self.window makeKeyAndVisible];
    if(kDebugLog)NSLog(@"postInterest From AppDelegate");
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetHeaderNotification object:nil];
    [[JLManager sharedManager] checkForUserLoginStatusChanged];

}

-(void)showHomeScreen
{

///if push notification promp after login
    [self requestPushNotificationPermission];
    
    if([JLManager sharedManager].skip_registration){
        [self setupMainUI];
        return;
    }
    JLPerkUser * loginuser = [PerkoAuth getPerkUser];
    BOOL isphoneverified = true;
    if(loginuser.phone_verified_at == nil ||
       (id)loginuser.phone_verified_at == [NSNull null]){
        isphoneverified = false;
    }

    if(!isphoneverified){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadVerificationCodePageNotification object:nil];
        });
    }else{
        [self setupMainUI];
    }
}
-(void)getUserLoginSignupNotification
{
   //[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    if (PerkoAuth.IsUserLogin) {
        [self performSelectorOnMainThread:@selector(showHomeScreen) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(showWelcomeScreen) withObject:nil waitUntilDone:YES];
    }
    
}
-(void)themeChanged
{
    
    ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
    switch (currentTheme) {
        case DayMode:
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            break;
            
        default:
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            break;
    }
    
    [[UINavigationBar appearance] setTintColor:kPrimaryTextColor];
    [[UINavigationBar appearance] setBarTintColor:kPrimaryBGColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor}];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor,  NSFontAttributeName: kFontPrimary20,NSKernAttributeName:@(0.5f)}];   
    UIImage *backButtonImage = [[UIImage imageNamed:@"backIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-400.f, 0)
                                                         forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    //[[UINavigationBar appearance] setShadowImage:[self imageFromColor:[UIColor colorWithRed:173.0/255.0 green:174.0/255.0 blue:179.0/255.0 alpha:0.15]]];
    [[UINavigationBar appearance] setShadowImage:[self imageFromColor:[UIColor clearColor]]];
    
    ///
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryBGColor,  NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Bold" size:13]} forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor,  NSFontAttributeName: [UIFont fontWithName:@"SFProDisplay-Bold" size:13]} forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:kPrimaryTextColor];
    ////
    
    [[UITabBar appearance] setBarTintColor:kPrimaryBGColorNight];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : kCommonColor, NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Bold" size:10.0f] } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : kRedColor, NSFontAttributeName:[UIFont fontWithName:@"SFProDisplay-Bold" size:10.0f] } forState:UIControlStateSelected];
    [[UITabBar appearance] setShadowImage:[self imageFromColor:[UIColor colorWithRed:120.0/255.0 green:137.0/255.0 blue:149.0/255.0 alpha:0.24]]];
    

    ////
    [[AppButton appearance] setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];
    [[AppBGView appearance] setBackgroundColor:kPrimaryBGColor];
    [[AppTableView appearance] setBackgroundColor:kPrimaryBGColor];
    [[AppLabel appearance] setTextColor:kPrimaryTextColor];
    [[AppSecondBGView appearance] setBackgroundColor:kSecondBGColor];
    ////
    //[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kCommonColor,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]  setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kCommonColor,NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UISearchBar appearance] setBarTintColor:kPrimaryBGColor];
    
    ////
    
  //  [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UIToolbar appearance] setBarTintColor:kPrimaryBGColorDay];
    
    ////
    
    
}
- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark --Notifications

-(void)manageNotifications: (NSDictionary *) dicNotificationInfo {
    if(dicNotificationInfo!=nil){
        if(kDebugLog)NSLog(@" %@",dicNotificationInfo);
        //NSString *notificationtype =[dicNotificationInfo valueForKey:@"notificationtype"];
        NSString *notificationtype =[NSString stringWithFormat:@"%@",[dicNotificationInfo valueForKey:@"page"]];
        notificationtype = [notificationtype stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *strUrl = @"watchback://";
        
        [self performSelector:@selector(handlePerkURL:) withObject:strUrl afterDelay:1];
    }
}
-(void)handlePerkURL:(NSString *)strUrl
{
    if(kDebugLog)NSLog(@" handleWatchbackURL %@",strUrl);
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateActive && [JLManager sharedManager].m_bIsVideoLooping ) {
        if(kDebugLog)NSLog(@" handleWatchbackURL2 %@",strUrl);
        return;
    }
//    if (![PerkoAuth IsUserLogin]) {
//        if(kDebugLog)NSLog(@" handleWatchbackURL3 %@",strUrl);
//        return;
//    }
    if(kDebugLog)NSLog(@" handleWatchbackURL4 %@",strUrl);
    if (strUrl != nil && strUrl.length > 0) {
        
        [[JLManager sharedManager] dismissPresentedControllerIfAny];
        strUrl = [[NSString stringWithFormat:@"%@",strUrl] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([strUrl rangeOfString:@"watchback://video"].location != NSNotFound) {
            //objPerkTabVC.selectedIndex = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"0"];
            strUrl = [strUrl stringByReplacingOccurrencesOfString:@"watchback://video:" withString:@""];
            strUrl = [strUrl stringByReplacingOccurrencesOfString:@"watchback://" withString:@""];

            NSString *strURL =[NSString stringWithFormat:@"https://edge.api.brightcove.com/playback/v1/accounts/5622532334001/videos/%@",strUrl];
            NSString * params =@"";
            [[WebServices sharedManager] callAPIBR:strURL params:params httpMethod:@"GET" checkforRefreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
                if(kDebugLog)NSLog(@"%@",dict);
                
                if (success) {
                    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                        //[[JLManager sharedManager] getRecommendedForYou:^(NSMutableArray *arr) {
                        
                            NSMutableArray *arr = [NSMutableArray new];
                        
                            [arr addObject:dict];
                            
                            int nIndex = 0;
                            PlayerVC *objPlayerVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
                            objPlayerVC.m_nCurrentIndex = nIndex;
                            objPlayerVC.m_arrPlaylistVideos = [NSMutableArray arrayWithArray:arr];
                            objPlayerVC.m_strChannelName  = @"";
                            objPlayerVC.m_bIsNotFromChannel = FALSE;
                            NavBoth *nav = [[NavBoth alloc] initWithRootViewController:objPlayerVC];
                            
                            [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
                            
                            
                            ////////////
                        //}];
                    }
                }
                
            }];
           
        }
        else  if ([strUrl rangeOfString:@"watchback://featured"].location != NSNotFound) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"0"];
            NSString *uuid = [strUrl stringByReplacingOccurrencesOfString:@"watchback://featured:" withString:@""];
            uuid = [uuid stringByReplacingOccurrencesOfString:@"watchback://" withString:@""];
            if (uuid == nil || ![uuid isKindOfClass:[NSString class]]) {
                return;
            }
            NSString *strURL =[NSString stringWithFormat:@"%@/%@",GET_RELATE_VIDEOS_URL,uuid];
            NSString *params = [NSString stringWithFormat:@"limit=%d&offset=%d",0, 0];
            [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
                if(kDebugLog)NSLog(@"%@",dict);
                
                if (success) {
                    
                    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                        dict =[dict objectForKey:@"data"];
                        //[[JLManager sharedManager] getRecommendedForYou:^(NSMutableArray *arr) {
                        NSMutableArray *arr = [NSMutableArray new];
                        
                        [arr addObject:dict];
                            
                            int nIndex = 0;
                            PlayerVC *objPlayerVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
                            objPlayerVC.m_nCurrentIndex = nIndex;
                            objPlayerVC.m_arrPlaylistVideos = [NSMutableArray arrayWithArray:arr];
                            objPlayerVC.m_strChannelName  = @"";
                            objPlayerVC.m_bIsNotFromChannel = FALSE;
                            NavBoth *nav = [[NavBoth alloc] initWithRootViewController:objPlayerVC];
                            
                            [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
                            
                            
                            ////////////
                        //}];
                    }
                    
                }
            }];
        }
        else if ([strUrl rangeOfString:@"watchback://sweeps"].location != NSNotFound) {
           // objPerkTabVC.selectedIndex = 2;
            [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"2"];
        }
//        else if ([strUrl rangeOfString:@"watchback://donate"].location != NSNotFound) {
//            objPerkTabVC.selectedIndex = 2;
//        }
        else if ([strUrl rangeOfString:@"watchback://account"].location != NSNotFound) {
            //objPerkTabVC.selectedIndex = 3;
            [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"3"];
        }
       
    }
}
-(void)initLeanplum{
    
    if (m_bIsInitLeanplum) {
        return;
    }
    m_bIsInitLeanplum = TRUE;
    //////////////////
    // Insert your API keys here.
#ifdef DEBUG
   // LEANPLUM_USE_ADVERTISING_ID;
    [Leanplum setAppId:@"app_qf4q41qGqqQQJtdQ3kaxXOS9BfQH8NjSZvA2eWMgfl0"
    withDevelopmentKey:@"dev_Vl4NuHW6nBoxvEyWFKCgdmVmvvqd8fAsRHMeGhiKH5g"];
#else
    [Leanplum setAppId:@"app_qf4q41qGqqQQJtdQ3kaxXOS9BfQH8NjSZvA2eWMgfl0"
     withProductionKey:@"prod_zuyXx47mVHQxRG7e2XTDqgj8Odyx0VEcF9TWRFsKWNc"];
#endif
    
    // Optional: Tracks in-app purchases automatically as the "Purchase" event.
    // To require valid receipts upon purchase or change your reported
    // currency code from USD, update your app settings.
    // [Leanplum trackInAppPurchases];
    
    // Optional: Tracks all screens in your app as states in Leanplum.
    // [Leanplum trackAllAppScreens];
    
    // Optional: Activates UI Editor.
    // Requires the Leanplum-iOS-UIEditor framework.
    // [[LeanplumUIEditor sharedEditor] allowInterfaceEditing];
    
    // Sets the app version, which otherwise defaults to
    // the build number (CFBundleVersion).
    [Leanplum setAppVersion:GetBuildVersion()];
    
    if ([PerkoAuth IsUserLogin]) {
        JLPerkUser * user = PerkoAuth.getPerkUser;
        [Leanplum setDeviceId:user.userUUID];
    }
    ///Geofencing & location-based messaging
  
    // Starts a new session and updates the app content from Leanplum.
    if ([PerkoAuth IsUserLogin]) {
        JLPerkUser * user = PerkoAuth.getPerkUser;
        if(kDebugLog)NSLog(@" user_uuid -> %@",user.userUUID);
       // NSLog(@" user_uuid -> %@",user.userUUID);
        NSString *gender = [NSString stringWithFormat:@"%@",user.gender];
        NSString *birthday = [NSString stringWithFormat:@"%@",user.birthday];
        NSString *u_email = [NSString stringWithFormat:@"%@",user.email];
        NSString *email_confirmed = [NSString stringWithFormat:@"%@",user.email_confirmed];
       // NSString *user_uuid = [NSString stringWithFormat:@"%@",user.userUUID];
        [Leanplum startWithUserId:user.userUUID userAttributes:@{@"Gender":gender, @"DOB": birthday,@"Email":u_email,@"Email Verified":email_confirmed,@"user_uuid":@"" }];
    }
    else{
        [Leanplum start];
    }
    
//    [Leanplum onVariablesChanged:^{
//        if(kDebugLog)NSLog(@"onVariablesChanged");
//    }];
//    [Leanplum onStartResponse:^(BOOL success) {
//        if(kDebugLog)NSLog(@"onStartResponse");
//    }];
    
   // [[JLManager sharedManager] setLeanplumData];
   
}
-(void)requestPushNotificationPermission{
    id notificationCenterClass = NSClassFromString(@"UNUserNotificationCenter");
    if (notificationCenterClass) {
        // iOS 10.
        SEL selector = NSSelectorFromString(@"currentNotificationCenter");
        id notificationCenter =
        ((id (*)(id, SEL)) [notificationCenterClass methodForSelector:selector])
        (notificationCenterClass, selector);
        if (notificationCenter) {
            selector = NSSelectorFromString(@"requestAuthorizationWithOptions:completionHandler:");
            IMP method = [notificationCenter methodForSelector:selector];
            void (*func)(id, SEL, unsigned long long, void (^)(BOOL, NSError *__nullable)) =
            (void *) method;
            func(notificationCenter, selector,
                 0b111, /* badges, sounds, alerts */
                 ^(BOOL granted, NSError *__nullable error) {
                     if (error) {
                         if(kDebugLog)NSLog(@"Leanplum: Failed to request authorization for user "
                               "notifications: %@", error);
                     }
                     else{
                         [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"allow_push_notifications" withValues:@{}];
                         [[JLTrackers sharedTracker] trackSingularEvent:@"allow_push_notifications"];
                         [[JLTrackers sharedTracker] trackFBEvent:@"allow_push_notifications" params:nil];
                     }
                 });
        }
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if ([[UIApplication sharedApplication] respondsToSelector:
                @selector(registerUserNotificationSettings:)]) {
        // iOS 8-9.
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:UIUserNotificationTypeAlert |
                                                UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"allow_push_notifications" withValues:@{}];
            [[JLTrackers sharedTracker] trackSingularEvent:@"allow_push_notifications"];
            [[JLTrackers sharedTracker] trackFBEvent:@"allow_push_notifications" params:nil];
        }

    } else {
        // iOS 7 and below.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
#pragma clang diagnostic pop
         UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge];
    }
    [self initLeanplum];
}
#pragma mark --
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)notification completionHandler:(void (^)())completionHandler
{
    [Leanplum handleActionWithIdentifier:identifier
                   forRemoteNotification:notification
                       completionHandler:completionHandler];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    [Leanplum handleActionWithIdentifier:identifier
                    forLocalNotification:notification
                       completionHandler:completionHandler];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Only increment badge if in background.
    if(application.applicationState == UIApplicationStateBackground) {
        NSInteger badge = [[UIApplication sharedApplication] applicationIconBadgeNumber];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: badge + 1];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {   
    [[JLTrackers sharedTracker] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    if(kDebugLog)NSLog(@"Watchback applicationDidReceiveMemoryWarning");
//    [[AsyncImageLoader defaultCache] removeAllObjects];
}
@end
