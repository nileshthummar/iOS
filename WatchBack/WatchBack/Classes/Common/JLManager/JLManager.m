//
//  JLManager.m
//  Perk
//
//  Created by Nilesh on 8/21/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "JLManager.h"
#import "UIView+Toast.h"
#import <AdSupport/AdSupport.h>

#import "NSMutableURLRequest+Additions.h"
#import "NSString+HMACString.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MBProgressHUD.h"
#import "JLTrackers.h"

//#import "Reachability.h"
#import "Leanplum_Reachability.h"
#import "WebServices.h"
#import "ForceUpdateVC.h"

#import "PerkoAuth.h"
#import "Constants.h"
#import "NavPortrait.h"
#import "WelcomeVC.h"
#import "CodeVerificationVC.h"
#import "FBShimmeringView.h"
#import "AppSecondBGView.h"
#import "Leanplum.h"
#import "LFCache.h"
static JLManager * manager;

@interface JLManager (){
    NSString * userEmail;
    MBProgressHUD *HUD;
    NSString *m_strCurrentAdNameForBlocker;
    UIImageView * m_viewAdBlock;
    ForceUpdateVC * objForceUpdateVC;
    
    BOOL m_bIsInMarketInitialised;
    
    NSOperationQueue *operationQueue;
    
    BOOL m_bUserLoginStatus;
    
    FBShimmeringView *m_shimmeringViewHome;
    FBShimmeringView *m_shimmeringViewPlayer;
    FBShimmeringView *m_shimmeringViewChannel;
    
    UIAlertController * m_alertNoInternet;
    NSCache *m_longformVideoCache;
    
    
}
@property (nonatomic) Leanplum_Reachability *internetReachability;

@end

@implementation JLManager

+(JLManager *)sharedManager{
    if(manager==nil){
        manager = [[JLManager alloc] init];
       // [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(GetUserInfo:) name:kGetUserInfoNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRRV2Points) name:@"updateRRV2Points" object:nil];


//        [[NSNotificationCenter defaultCenter] addObserver:manager
//                                                 selector:@selector(logoutUserWithAlert:)
//                                                     name:@"logoutUserWithAlert"
//                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(handleStatusBarDidChangeOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        
        [[JLTrackers sharedTracker] initTracker];
        
//        if([PerkoAuth IsUserLogin])
//        {
//            [manager getUserInfo:^(BOOL success) {
//                
//            }];
//            
//        }
        [manager initInternetChecker];
        
        if([PerkoAuth IsUserLogin] ){
            
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCurrencyNotification object:nil];
        }
        
        [manager performSelector:@selector(checkAppversion) withObject:nil afterDelay:5];
        manager.m_strCombrePlacementName = @"between_videos";
        
        [manager getAppSettings:nil];
    }
    return manager;
}

-(void)setLogoutStatus{
   [self clearLeanplumAttributes];
    [PerkoAuth setLogoutStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopVideoNotification object:nil];
	
   // [self resetDefaults];
    
    
}
-(void)clearLeanplumAttributes{
    
    [Leanplum setUserAttributes:@{@"Gender":[NSNull null], @"DOB": [NSNull null],@"Email":[NSNull null],@"Email Verified":[NSNull null],@"user_uuid":[NSNull null],@"Marketing Email Opt-in":[NSNull null],@"Selected Channels":[NSNull null],@"Selected Interests":[NSNull null] }];

    
}
- (void)resetDefaults {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [[LFCache sharedManager] resetData];
    
    //NSString *strTermsPrivacyAgreement = [[JLManager sharedManager] getObjectuserDefault:kTermsPrivacyAgreement];
    //NSString *strMarketingAgreement = [[JLManager sharedManager] getObjectuserDefault:kMarketingAgreement];
 //   NSString *dev_mode_protocol =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:@"dev_mode_protocol"]];
    //NSString *dev_mode_api_endpoint =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:@"dev_mode_api_endpoint"]];
    
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if (key != nil && [key isKindOfClass:[NSString class]] && [key hasPrefix:@"perkUser"]) {
            [defs removeObjectForKey:key];
        }
    }
    [defs synchronize];
    [self checkAndClearLocalCacheForWatchedVideos:TRUE];
    [self clearAllLocalFavorites];

    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeChangedNotification object:nil];
    
    
   // [[JLManager sharedManager] setObjectuserDefault:dev_mode_protocol forKey:@"dev_mode_protocol"];
  //  [[JLManager sharedManager] setObjectuserDefault:dev_mode_api_endpoint forKey:@"dev_mode_api_endpoint"];
   // [[JLManager sharedManager] setObjectuserDefault:strTermsPrivacyAgreement forKey:kTermsPrivacyAgreement];
    //[[JLManager sharedManager] setObjectuserDefault:strMarketingAgreement forKey:kMarketingAgreement];
}
-(NSString *)getUserCountry
{
    NSString *strCountry = [PerkoAuth getPerkUser].country;
    if (!strCountry || strCountry == nil || strCountry.length < 1) {
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [NSString stringWithFormat:@"%@",[currentLocale objectForKey:NSLocaleCountryCode]];
        // if(kDebugLog)NSLog(@"%@",countryCode);
        if (countryCode && ([countryCode isEqualToString:@"GB"] || [countryCode isEqualToString:@"EU"] || [countryCode isEqualToString:@"OC"] || [countryCode isEqualToString:@"IE"] || [countryCode isEqualToString:@"UK"])) {
            //return 'UK';
            strCountry = @"UK";
        }
        else
        {
            strCountry = @"US";
        }
        
    }
    return strCountry;
}
#pragma mark -
#pragma mark version check api

-(void)checkAppversion{
    NSString *strUrl = [NSString stringWithFormat:@"%@",API_AppVersion];
    
    // NSString *param = [NSString stringWithFormat:@"?format=json&device_id=%@&device_type=%@&version=%@&client_id=%@&client_secret=%@",[OpenUDID value],kDeviceType,GetBuildVersion (),kPerkKey,kPerkSecret];
//    NSString *param = [NSString stringWithFormat:@"?format=json&device_id=%@&device_type=%@&version=%@",watchbackGetDeviceID(),kDeviceType,GetBuildVersion ()];
//    param = [param stringByAppendingFormat:@"&bundle_id=%@",GetBuildIdentifier ()];
//
//    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    param = [param stringByAppendingFormat:@"&idfa=%@",idfa];
//
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    param = [param stringByAppendingFormat:@"&idfv=%@",idfv];
//
//    param = [param stringByAppendingFormat:@"&appid="];
//    param = [param stringByAppendingFormat:perkAppID];
//
//    if ([PerkoAuth IsUserLogin]) {
//        param = [param stringByAppendingFormat:@"&access_token=%@",kPERK_ACCESS_TOKEN];
//    }

    NSString * param = @"";
    
    [[WebServices sharedManager] callAPI:strUrl params:param httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        if (success) {
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                if (dict != nil && [dict valueForKey:@"status"]) {
                    
                    id value = [dict valueForKey:@"status"];
                    
                    if (value != nil && ![value isEqual:[NSNull null]]) {
                        
                        if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"error"]) {
                            
                            [self showAPIResponseError:[NSString stringWithFormat:@"%@",[dict valueForKey:@"message"]]];
                            return;
                        }
                    }
                }
                dict = [dict objectForKey:@"data"];
                if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                    
                    bool bUpdate = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"update"] ] boolValue];
                    if (bUpdate)
                    {
                        NSString *striTunesURL = [NSString stringWithFormat:@"%@",[dict objectForKey:@"url"]];
                        
                        bool force_update = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"force_update"]] boolValue];
                        [self showPerkUpdateRibbon:force_update url:striTunesURL];
                        //[appDelegate statusBarDidChangeFrame:nil];
                    }
                    
                }
            }

        }
    }];
}


-(void)showPerkUpdateRibbon:(bool) force_update url:(NSString *)url{
    objForceUpdateVC = [[ForceUpdateVC alloc] initWithNibName:@"ForceUpdateVC" bundle:nil];
    objForceUpdateVC.m_striTunesURL = url;
    objForceUpdateVC.view.frame =[UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:objForceUpdateVC.view];
    if (force_update) {
        objForceUpdateVC.m_btnClose.hidden = true;
    }
}
#pragma mark -
#pragma mark reachibility methods
- (BOOL) isInternetConnected {
    Leanplum_Reachability *reachability = [Leanplum_Reachability reachabilityForInternetConnection];
    
     Leanplum_NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
   
    
    if (internetStatus != NotReachable){
        return YES;
    }else{
        return NO;
    }
}





#pragma mark -
#pragma mark update user points
-(void)UpdatePerkUserwithPointAttributes:(NSDictionary*)dictPerkUserPointsAttributes{
    JLPerkUser * user = [PerkoAuth getPerkUser];
    
    user.userId = [NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"user_id"]];
    user.email =[NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"email"]];
    user.firstname =[NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"first_name"]];
    user.lastname =[NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"last_name"]];
    user.referralCode = [NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"referral_id"]];
    user.email_confirmed = [NSString stringWithFormat:@"%@",[dictPerkUserPointsAttributes valueForKey:@"email_confirmed"]];
    
    user.perkPoint.availableperks = [dictPerkUserPointsAttributes valueForKey:@"available_perks"];
    user.perkPoint.availableTokens = [dictPerkUserPointsAttributes valueForKey:@"available_tokens"];
    user.perkPoint.lifetimeperks =  [dictPerkUserPointsAttributes valueForKey:@"lifetime_perks"];
    user.perkPoint.miscperks = [dictPerkUserPointsAttributes valueForKey:@"misc_perks"];
    user.perkPoint.pendingperks = [dictPerkUserPointsAttributes valueForKey:@"pending_perks"];
    
    
    // user.perkPoint.unread_notifications = [dictPerkUserPointsAttributes valueForKey:@"notificationCount"];
    
    // user.country  = [dictPerkUserPointsAttributes valueForKey:@"uCountry"];
    user.isOver21 = [dictPerkUserPointsAttributes valueForKey:@"21_and_over"];
    user.birthday =[dictPerkUserPointsAttributes valueForKey:@"birth_date"];
    user.gender =[dictPerkUserPointsAttributes valueForKey:@"gender"];
    user.userUUID = [dictPerkUserPointsAttributes valueForKey:@"uuid"];
    
    user.profile_image =[dictPerkUserPointsAttributes valueForKey:@"profile_image"];
    user.email_verified_at = [dictPerkUserPointsAttributes valueForKey:@"email_verified_at"];
    user.phone_verified_at = [dictPerkUserPointsAttributes valueForKey:@"phone_verified_at"];
    user.phoneno = [dictPerkUserPointsAttributes valueForKey:@"phone"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:perkUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setLeanplumData];
    ////
    [self checkForUnderAge];
    ///
}

-(void)getUserInfo:(void (^) (BOOL success))handler{
 
    if(![PerkoAuth getPerkUser].IsUserLogin){
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@?access_token=%@",GET_USERINFO,[PerkoAuth getPerkUser].accessToken];
    
    NSString *params = @"";
    
    [[WebServices sharedManager] callAPI:strUrl params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        BOOL bGetUserDataSuccess = FALSE;
        if (success) {
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                    [self processUserInfo:dict];
                    bGetUserDataSuccess = true;
                   // [[JLManager sharedManager] initInMarketSDK];
                }
            }
        }
        if(handler != nil)  handler(bGetUserDataSuccess);
    }];
}
- (void) processUserInfo:(NSDictionary *) dicUserInfo {
    [self hideLoadingView];
    if(dicUserInfo==nil){
    }else{
        if([dicUserInfo valueForKey:@"error"]==nil){
			
			if ([dicUserInfo valueForKey:@"status"]) {
				
				id value = [dicUserInfo valueForKey:@"status"];
				
				if (value != nil && ![value isEqual:[NSNull null]]) {
					
					if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"error"]) {
						[self showAPIResponseError:[NSString stringWithFormat:@"%@",[dicUserInfo valueForKey:@"message"]]];
						return;
					}
				}
				
			}else {
				
				[self UpdatePerkUserwithPointAttributes:dicUserInfo];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCurrencyNotification object:nil];
				

			}
            
            
        }else{
			NSString * refreshTokenError = [dicUserInfo valueForKey:@"error"];
			NSString * refreshTokenDesc = [dicUserInfo valueForKey:@"error_description"];
			
			if (refreshTokenError != nil && [refreshTokenError isEqualToString:@"invalid_grant"] && refreshTokenDesc != nil && [refreshTokenDesc isEqualToString:@"The access token provided has expired."]) {
				
                [self logoutUserWithAlert : LogoutModeDefault];
			}
			else if(refreshTokenError != nil && [refreshTokenError isEqualToString:@"User could not be found"]) {
                    [self logoutUserWithAlert : LogoutModeDefault];
			}
			else {
			
				dispatch_async(dispatch_get_main_queue(), ^{
					
                    
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"Error"
                                                 message:[dicUserInfo valueForKey:@"error"]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* btnOK = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                                
                                                
                                            }];
                    
                    [alert addAction:btnOK];
                   
                    [self.topViewController presentViewController:alert animated:YES completion:nil];
				});
			}
        }
    }
}
#pragma mark --user default
-(void)setObjectuserDefault:(id)value forKey:(id)key{
    //  if (!value) value = @"";
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id)getObjectuserDefault:(id)key{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (data) {
        return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        return  @"";
    }
}



- (void) showServerError {
 dispatch_async(dispatch_get_main_queue(), ^{
    
     
     UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@"App is not responding. Please try again."
                                  preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction* btnOK = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 //Handle your yes please button action here
                                 
                                 
                             }];
     
     [alert addAction:btnOK];
     
     [self.topViewController presentViewController:alert animated:YES completion:nil];
 });
}

- (void) showNetworkError {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self->m_alertNoInternet == nil)        
        {
    
            self->m_alertNoInternet = [UIAlertController
                                       alertControllerWithTitle:@"No Internet Connection"
                                       message:@"An Internet connection is required to use WatchBack. Please reconnect and try again."
                                       preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOK = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        self->m_alertNoInternet = nil;
                                        
                                    }];
            
            [self->m_alertNoInternet addAction:btnOK];
            
            [self.topViewController presentViewController:self->m_alertNoInternet animated:YES completion:nil];
            //[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self->m_alertNoInternet animated:YES completion:nil];
        }
        
    });
}

- (void) handleStatusBarDidChangeOrientation:(NSNotification *) notification {

   
}


- (void) logoutUserWithAlert:(LogoutMode)mode {
    // 0 - default mode..
    // 1 - "watchback not available mode", when 403 error occurs

    dispatch_async(dispatch_get_main_queue(), ^{
        
    if([PerkoAuth IsUserLogin])
    {
        [self setLogoutStatus];
        [[JLManager sharedManager] closeAndClearFBTokenInformation];
        
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Alert"
                                     message:@"Your Session has expired. Please log in to continue."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* btnOK = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [[self topViewController] dismissViewControllerAnimated:NO completion:nil];
                                    [self performSelector:@selector(loginAfterDelay) withObject:nil afterDelay:1];
                                    
                                }];
        
        [alert addAction:btnOK];
        [[self topViewController] presentViewController:alert animated:YES completion:nil];

        

    }else{
        
        if(mode == LogoutModeNoWatchbackAvailable){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Alert"
                                     message:kNotAvailableMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
        
       
        [[self topViewController] presentViewController:alert animated:YES completion:nil];
        }

    }
    });

}
-(void)logoutUserWithoutAlert{
    if([PerkoAuth IsUserLogin])
    {
        [self setLogoutStatus];
        [[JLManager sharedManager] closeAndClearFBTokenInformation];
        [[self topViewController] dismissViewControllerAnimated:NO completion:nil];
        [self performSelector:@selector(loginAfterDelay) withObject:nil afterDelay:1];
        
    }
}
-(void)loginAfterDelay{
     [self showLoginSignUpwithUserAction:1];
}
- (void) showAPIResponseError:(NSString *) errorMessage{
	
	//dispatch_async(dispatch_get_main_queue(), ^{
       
		if (errorMessage != nil && ![errorMessage isEqual:[NSNull null]] && [errorMessage isKindOfClass:[NSString class]] && [errorMessage length] > 0) {
            UIViewController *vc = [[JLManager sharedManager] topViewController];
			//[vc.view makeToast:errorMessage duration:1.0 position:@"center"];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.label.text = errorMessage;
            hud.margin = 10.f;
            //hud.offset = 150.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hideAnimated:YES afterDelay:1];
			
		}
	//});
}


-(void)resetNavigationBar{
   /* self.navigationItem.backBarButtonItem = nil;
    [[self.navigationController.navigationBar viewWithTag:menubtnTag] removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:currencybtnTag] removeFromSuperview];
    */
}

/*
-(void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //clean documnt directory
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSError *error = nil;
    
    NSMutableArray *dirArr = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]];
    
    [dirArr removeObject:@".DS_Store"];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
        
    }
    
    NSString * cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSError *error1 = nil;
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:&error1])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[cacheDirectory stringByAppendingPathComponent:file] error:&error1];
        
    }
    
}
*/
- (void) handleCommonErrorResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)connectionError {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = (int)[httpResponse statusCode];
    if (responseStatusCode == 200)
    {
        
    }
    else if (responseStatusCode == 401 || responseStatusCode == 403)
    {
        
            if(responseStatusCode == 401){
                [self logoutUserWithAlert:LogoutModeDefault];
            }else{
                [self logoutUserWithAlert:LogoutModeNoWatchbackAvailable];
            }
    }
    else if(responseStatusCode >= 500 && responseStatusCode <= 599)
    {
        [self showAPIResponseError:@"App is not responding. Please try again."];
    }
    else
    {
        if (connectionError) {
            long errorCode = connectionError.code;
            //if(kDebugLog)NSLog(@"%ld",errorCode);
            if (errorCode == -1012) {
                    [self logoutUserWithAlert:LogoutModeDefault];
            }
        }
        if(data)
        {
            NSDictionary *serverResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (serverResponseDict && [serverResponseDict isKindOfClass:[NSDictionary class]]) {
                
                if (serverResponseDict != nil) {
                    
                    NSString *message = [serverResponseDict valueForKey:@"message"];
                    if(message != nil && [message isKindOfClass:[NSString class]])
                    {
                        [self showAPIResponseError:[NSString stringWithFormat:@"%@",message]];
                    }
                    
                }
                
            }
        }
        
    }
    [self hideLoadingView];
    ////
    
    
}

-(void)callAPIForGetDeveloperMode
{
    
    BOOL isAppInstalled =  [[[JLManager sharedManager] getObjectuserDefault:kIsAppInstalled] boolValue];
    if(isAppInstalled){
        return;
    }
    
    //[[JLTrackers sharedTracker] trackEvent:@"App Installed"];
    [[JLManager sharedManager] setObjectuserDefault:@"YES" forKey:kIsAppInstalled];
    
    
    //  http://api-tv.perk.com/v1/geo.json
    
    NSString *strUrl = GEO_URL;
    

    
    [[WebServices sharedManager] callAPI:strUrl params:@"" httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        if (success) {
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                    dict = [dict objectForKey:@"geo"];
                    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                        
                        NSString *debug = [NSString stringWithFormat:@"%@",[dict objectForKey:@"debug"]];
                        
                        [self setObjectuserDefault:debug forKey:kDevModeDebug];
                        
                        ////
                        NSString *country = [NSString stringWithFormat:@"%@",[dict objectForKey:@"country"]];
                        
                        [self setObjectuserDefault:country forKey:kPerkUserCountry];
                        
                        
                        ////
                    }
                    
                    
                }
            }
        }
    }];
    
}
-(void)sentLog:(NSString *)str
{
    
   // [[QLog log] logOption:kLogOptionNetworkData withFormat:@"%@",str];
}

-(BOOL)checkForUseWiFiOnly
{
    if ([[JLManager sharedManager] getObjectuserDefault:@"isUseWiFiOnlyVideo"] != nil && [[[JLManager sharedManager] getObjectuserDefault:@"isUseWiFiOnlyVideo"] boolValue]) {
        Leanplum_Reachability *reachability = [Leanplum_Reachability reachabilityForInternetConnection];
        
        Leanplum_NetworkStatus netStatus = [reachability currentReachabilityStatus];
        
        if(netStatus == ReachableViaWiFi)
        {
            return NO;
        }
        else{
            [[UIApplication sharedApplication].keyWindow makeToast:@"You must connect to a wireless network to use this!" duration:4.0 position:@"center"];
            return YES;
        }
        /*
        if (![reachability isReachableViaWiFi]) {
            [[UIApplication sharedApplication].keyWindow makeToast:@"You must connect to a wireless network to use this!" duration:4.0 position:@"center"];
            return YES;

        }
        */
    }
    
    return NO;
}

#pragma mark --AdBlock

- (void) checkForAdBlocker:(NSString *)strURL {
    m_strCurrentAdNameForBlocker = strURL;
    
    
    CheckForAdBlockerWithBlock(strURL, ^(bool isAdblockerEnabled) {
        
        if (isAdblockerEnabled) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showAdBlockerOverlay];
                
            });
            
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self removeAdBlockOverlay];
                
                
            });
            
        }
        
    });
    
    
    
}
-(void)retTryAdBlock
{
    [self checkForAdBlocker:m_strCurrentAdNameForBlocker];
}
- (void) removeAdBlockOverlay {
    
    UIImageView * adBlockOverlay = (UIImageView *)[[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:kAdBlockOverlayTag];
    if (adBlockOverlay != nil) {
        
        [adBlockOverlay removeFromSuperview];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) showAdBlockerOverlay{
    
    [self removeAdBlockOverlay];
    if (self.presentedViewController != nil) {
        
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    [self performSelector:@selector(displayAdBlockOverlay) withObject:nil afterDelay:1];
    
    
}

-(void)displayAdBlockOverlay
{
    
    CGRect frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    
    m_viewAdBlock = (UIImageView *)[[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:kAdBlockOverlayTag];
    m_viewAdBlock.userInteractionEnabled = true;
    if (m_viewAdBlock) {
       return;
    }
    
    m_viewAdBlock = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.size.height, frame.size.width, frame.size.height)];
    m_viewAdBlock.tag = kAdBlockOverlayTag;
    m_viewAdBlock.userInteractionEnabled = YES;
    m_viewAdBlock.contentMode = UIViewContentModeScaleToFill;
    m_viewAdBlock.image = [UIImage imageNamed:@"bg_adblock"];//[[UIImage imageNamed:@"bg_adblock"] applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0.1 alpha:0.5] saturationDeltaFactor:5 maskImage:nil];
    m_viewAdBlock.backgroundColor = [UIColor blackColor];
    m_viewAdBlock.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view  addSubview:m_viewAdBlock];
    
    UIImageView * logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(m_viewAdBlock.frame), 70)];
    logoView.image = [UIImage imageNamed:@"logo.png"];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [m_viewAdBlock addSubview:logoView];
    UILabel * textTodisplay = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(logoView.frame), CGRectGetWidth(m_viewAdBlock.frame)- 40, CGRectGetHeight(m_viewAdBlock.frame) - 200)];
    textTodisplay.textColor = [UIColor whiteColor];
    textTodisplay.backgroundColor = [UIColor clearColor];
    textTodisplay.font = [UIFont systemFontOfSize:19];
    textTodisplay.lineBreakMode = NSLineBreakByWordWrapping;
    
    textTodisplay.numberOfLines = 0;
    textTodisplay.text = @"Uh oh. Looks like you may be using an ad blocking service or experiencing network connection issues on your device.\nApp does not support the use of ad blocking services.\nIf you feel this is an error, you can tap \"Retry\" below.";
    textTodisplay.textAlignment = NSTextAlignmentCenter;
    textTodisplay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [m_viewAdBlock addSubview:textTodisplay];
    
    UIButton * retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    retryButton.tag = 1311;
    retryButton.userInteractionEnabled = YES;
    retryButton.frame = CGRectMake(50, CGRectGetMaxY(textTodisplay.frame) , (CGRectGetWidth(m_viewAdBlock.frame) - 100), 50);
    retryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
    [retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    retryButton.titleLabel.textColor = [UIColor whiteColor];
    retryButton.titleLabel.numberOfLines = 0;
    retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    retryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    retryButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    [retryButton setBackgroundColor:[UIColor colorWithRed:81.0f/255.0f green:140.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
    retryButton.layer.cornerRadius = 5.0f;
    [retryButton addTarget:self action:@selector(retTryAdBlock) forControlEvents:UIControlEventTouchUpInside];
    retryButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [m_viewAdBlock addSubview:retryButton];
    
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.tag = 1312;
    activity.frame = CGRectMake(ceilf((CGRectGetWidth(m_viewAdBlock.frame) - 50)/2.0), CGRectGetMaxY(textTodisplay.frame) , 50, 50);
    activity.hidden = YES;
    activity.hidesWhenStopped = YES;
    [m_viewAdBlock addSubview:activity];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:m_viewAdBlock];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self->m_viewAdBlock.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height + 20);
        
    } completion:^(BOOL finished) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}
- (void)orientationChanged:(NSNotification *)notification{
    if (m_viewAdBlock) {
       // if(kDebugLog)NSLog(@"%@",NSStringFromCGRect([UIApplication sharedApplication].keyWindow.rootViewController.view.frame));
        m_viewAdBlock.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
    }
}

#pragma mark -
#pragma mark facebook sdk methods

-(void)closeAndClearFBTokenInformation
{
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
}

- (void)openFBSessionwithUserAction:(BOOL)bIsWeb topController:(UIViewController *)topController  handler:(void (^) (BOOL success, NSString *strFBToken,NSString *strFBUserID,NSString *strError))handler{
   /* FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    if (bIsWeb) {
        login.loginBehavior = FBSDKLoginBehaviorWeb;
    }

    [login logInWithReadPermissions:[self getFBPermissions] fromViewController:topController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error || result.isCancelled) {
            
            [self closeAndClearFBTokenInformation];
            handler(false, @"",@"",[error localizedDescription]);
        }
        else
        {
            if ([result.grantedPermissions containsObject:@"email"]) {
              
                handler(true, result.token.tokenString,result.token.userID,nil);
            }else{
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Alert"
                                             message:@"please give access to email address in order to login with facebook successfully"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* btnOK = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                        }];
                
                [alert addAction:btnOK];
                [[self topViewController] presentViewController:alert animated:YES completion:nil];
                
                
               // [[[UIAlertView alloc] initWithTitle:@"please give access to email address in order to login with facebook successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                
                [self closeAndClearFBTokenInformation];
                handler(false, @"",@"",@"Required email permission");
            }
        }
    }];
*/
}

#pragma mark -
#pragma mark Facebook API methods

-(NSArray *)getFBPermissions
{
    return [NSArray arrayWithObjects:@"email",nil];
}
- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tbController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tbController.selectedViewController];
    }
    /*if ([rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController* sgController = (SWRevealViewController*)rootViewController;
        return [self topViewControllerWithRootViewController:sgController.frontViewController];
    }
    else*/ if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        if ([presentedViewController isKindOfClass:[UIAlertController class]]) {
            return rootViewController;
        }
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
-(void)initInternetChecker
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kLeanplumReachabilityChangedNotification object:nil];
    
    
    self.internetReachability = [Leanplum_Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    
    [self updateInterfaceWithReachability:self.internetReachability];
    
    
}
#pragma mark -
#pragma mark reachibility methods


-(void)hideOfflineView{
    
    if([[JLManager sharedManager]isInternetConnected]){
        
//        objNoInternetRibbonVC.m_bIsShowing = FALSE;
//        [objNoInternetRibbonVC removeFromSuperviewWithAnimation];
//        objNoInternetRibbonVC = nil;
        
    }
}

-(void) showOfflineView{
    
    if(![[JLManager sharedManager] isInternetConnected]){
        
       /* if (!objNoInternetRibbonVC) {
            objNoInternetRibbonVC = [[NoInternetRibbonVC alloc] initWithNibName:@"NoInternetRibbonVC" bundle:nil];
        }
        
        if (!objNoInternetRibbonVC.m_bIsShowing) {
            
            objNoInternetRibbonVC.m_bIsShowing = TRUE;
            
            CGRect rect = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
            
            objNoInternetRibbonVC.view.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - CGRectGetMaxX(rect))/2.0,60,CGRectGetMaxX(rect), 33);
            objNoInternetRibbonVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            
            [[UIApplication sharedApplication].keyWindow addSubview:objNoInternetRibbonVC.view];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:objNoInternetRibbonVC.view];
        }*/
        [self showNetworkError];
    }
    
}
- (void)updateInterfaceWithReachability:(Leanplum_Reachability *)reachability
{
    Leanplum_NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    if(netStatus != NotReachable)
    {
        [self hideOfflineView];
    }
    else{
        [self showOfflineView];
    }
    
}
-(void)reachabilityChanged:(NSNotification *)note
{
    
    Leanplum_NetworkStatus netStatus = [[note object] currentReachabilityStatus];
    if(netStatus != NotReachable)
    {
        [self hideOfflineView];
    }
    else{
        [self showOfflineView];
    }
}


-(void)updateRRV2Points
{
    [self getUserInfo:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLeanplumReachabilityChangedNotification object:nil];
    if (self.internetReachability) {
        [self.internetReachability stopNotifier];
        self.internetReachability = nil;
    }
}


-(void)checkForForceUpdate:(NSData *)data responseStatusCode:(int) responseStatusCode
{
    if (responseStatusCode == 429)
    {
        NSDictionary *dict;
        if (data) {
            dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        }
        else{
            dict = [NSDictionary new];
        }
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempDict = [dict objectForKey:@"data"];
            if (tempDict && [tempDict isKindOfClass:[NSDictionary class]]) {
                tempDict = [tempDict objectForKey:@"error"];
                if (tempDict && [tempDict isKindOfClass:[NSDictionary class]]) {
                    tempDict = [tempDict objectForKey:@"app"];
                    if (tempDict && [tempDict isKindOfClass:[NSDictionary class]]) {
                        NSString *strStoreURL = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"store_url"]];
                        
                        if(strStoreURL!=nil && strStoreURL.length>2 && ![strStoreURL isEqualToString:@"<null>"] && ![strStoreURL isEqualToString:@"(null)"]){
                            
                            [self showPerkUpdateRibbon:true url:strStoreURL];
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
}

#pragma mark --Perk

- (void) showLoginSignUpwithUserAction:(int)userAction{       
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
    
}
-(void)loginSignupSuccessed{
    [[JLManager sharedManager] checkAndClearLocalCacheForWatchedVideos:TRUE];
}

#pragma mark --
-(void)GoToVerificationCodeScreenwithPhoneNumber:(NSString *)phoneno{
    if(!phoneno){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        CodeVerificationVC * objCodeVerificationVC = [[CodeVerificationVC alloc] initWithNibName:@"CodeVerificationVC" bundle:nil];
        objCodeVerificationVC.phone_no = phoneno;
        objCodeVerificationVC.country_code = @"+1";
        
        [[self topViewController].navigationController pushViewController:objCodeVerificationVC animated:YES];
    });
}


#pragma mark --

-(BOOL)updateVideoView:(NSDictionary *)dicVideoInfo{
    // if(kDebugLog)NSLog(@"============ %s ====================== %@ ", __FUNCTION__, dicVideoInfo);
    /*
     Printing description of dicvideoviewStatus:
     {
     data =     {
     "earning_session_count" = 1;
     "lifetime_count" = 1;
     "points_awarded" = 0;
     "views_required" = 10;
     "views_required_next_award" = 9;
     };
     message = "<null>";
     status = success;
     }
     */
    
    
    if([PerkoAuth IsUserLogin]){
        
        JLPerkUser * user = [PerkoAuth getPerkUser];
        
        NSDictionary * dataDictFromServer = [dicVideoInfo valueForKey:@"data"];
        
        if (dataDictFromServer != nil && ![dataDictFromServer isEqual:[NSNull null]]) {
            
            for (id key in dataDictFromServer) {
                
                id value = [dataDictFromServer valueForKey:key];
                if (value != nil && ![value isEqual:[NSNull null]]) {
                    
                    if ([key isEqualToString:@"earning_session_count"]) {
                        
                        user.session_videos_watched = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"lifetime_count"]) {
                        
                        user.total_videos_watched = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"views_required"]) {
                        
                        user.video_views = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"views_required_next_award"]) {
                        
                        user.video_views_required = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"next_level_percentage"]) {
                        
                        user.next_level_percentage = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"current_user_level"]) {
                        
                        user.current_user_level = [NSNumber numberWithInt:[value intValue]];
                    }
                    if ([key isEqualToString:@"next_user_level"]) {
                        
                        user.next_user_level = [NSNumber numberWithInt:[value intValue]];
                    }
                }
            }
            user.perkPoint.availableperks = [dataDictFromServer valueForKey:@"points_balance"];            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:perkUserKey];
        
        return [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    return NO;
}
-(void)updatePlayerBarLayout{
   /*
     if (self.m_objPlayerVC != nil && self.m_objPlayerVC.m_bIsBar) {
         CGRect f = [[UIScreen mainScreen] bounds];
         
         UIViewController *vc = [self topViewController];;
         NSString *strChildClass =NSStringFromClass([vc class]);
         if(strChildClass!=nil && (id)strChildClass!=[NSNull null]){
             
         }
         
         if(kDebugLog)NSLog(@"TopViewController -> %@",strChildClass);
         if([[JLManager sharedManager] isAppViewController:strChildClass]){
             
              f.origin.y = f.size.height-170;//145
         }else{
             
             f.origin.y = f.size.height-100;
         }
         
         
//         if([JLManager sharedManager].m_bIsTabbarVisible){
//
//             f.origin.y = f.size.height-145;
//         }
//         else{
//             f.origin.y = f.size.height-100;
//         }
         f.size.height = 100;
         [JLManager sharedManager].m_objPlayerVC.view.frame = f;
          [JLManager sharedManager].m_objPlayerVC.videoContainer.frame = CGRectMake(0, 0, 200, 100);
     }
     else if (self.m_objPlayerVC != nil) {
         CGRect f = [[UIScreen mainScreen] bounds];
         [JLManager sharedManager].m_objPlayerVC.view.frame = f;
         
        [JLManager sharedManager].m_objPlayerVC.videoContainer.frame = CGRectMake(0, 0, f.size.width, 200);
     }
   
    ////
    
    */
    
}
-(BOOL)isAppViewController:(NSString *)viewcontrollername{
    if(viewcontrollername==nil){
        return NO;
    }
    
    NSArray * ary_app_viewcontrollers = [[NSArray alloc]initWithObjects:@"HomeVC",
                                         @"SubscribeVC",
                                         @"CharityVC",
                                         @"RewardsVC",
                                         @"AccountVC",
                                         nil];
    
    if([ary_app_viewcontrollers containsObject:viewcontrollername]){
        return YES;
    }else{
        return NO;
    }
}
-(void)setAppTheme:(ThemeType)themeType
{
    ThemeType currentTheme = [self getAppTheme];
    if (currentTheme != themeType) {
        NSString *strType = [NSString stringWithFormat:@"%d",themeType];
        [self setObjectuserDefault:strType forKey:kAppThemeKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kThemeChangedNotification object:nil];
    }
    
}
-(ThemeType )getAppTheme{
    NSString *strType = [self getObjectuserDefault:kAppThemeKey];
    ThemeType themeType = [strType intValue];
    return themeType;
}
-(UIColor *)getPrimaryBGColor{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return kPrimaryBGColorDay;
            break;
            
        default:
            return kPrimaryBGColorNight;
            break;
    }
}
-(UIColor *)getSecondBGColor{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return kSecondBGColorDay;
            break;
            
        default:
            return kSecondBGColorNight;
            break;
    }
}
-(UIColor *)getSecondaryTextColor{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return kOffStateColorDay;
            break;
            
        default:
            return kOffStateColorNight;
            break;
    }

}
-(UIImage *)getPrimaryBackbuttonImage{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return [UIImage imageNamed:@"back-dark"];
            break;
            
        default:
            return [UIImage imageNamed:@"backIcon"];
            break;
    }

}

-(UIColor *)getThirdTextColor{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return kOffStateColor2Day;
            break;
            
        default:
            return kOffStateColor2Night;
            break;
    }
    
}


-(UIColor *)getPrimaryTextColor{
    ThemeType currentTheme = [self getAppTheme];
    switch (currentTheme) {
        case DayMode:
            return kPrimaryTextColorDay;
            break;
            
        default:
            return kPrimaryTextColorNight;
            break;
    }
}
-(NSArray *)removedLongformAmazonBC:(NSArray *)arr{
    NSMutableArray *arrVideos = [NSMutableArray arrayWithArray:arr];
    
//    NSIndexSet *toBeRemoved = [arrVideos indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        BOOL removeIt = FALSE;
//        NSDictionary *dict = [arrVideos objectAtIndex:idx];
//        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
//            NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
//            if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
//                NSString *longform = [custom_fields objectForKey:@"longform"];
//                if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
//                    removeIt = [longform boolValue];
//                }
//            }
//        }
//        return removeIt;
//    }];
//    [arrVideos removeObjectsAtIndexes:toBeRemoved];
    
    ////
    NSIndexSet *toBeRemoved = [arrVideos indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL removeIt = FALSE;
        NSDictionary *dict = [arrVideos objectAtIndex:idx];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            
            NSArray *tags = [dict objectForKey:@"tags"];
            if (tags != nil && [tags isKindOfClass:[NSArray class]]) {
                removeIt = [tags containsObject:@"redemption_partner"];
            }
            
        }
        return removeIt;
    }];
    [arrVideos removeObjectsAtIndexes:toBeRemoved];
    ///
 
    return arrVideos;
}

-(void)checkForUserLoginStatusChanged{
    if (m_bUserLoginStatus != [PerkoAuth IsUserLogin]) {
        m_bUserLoginStatus = [PerkoAuth IsUserLogin];
        [self updateDataAsPerUserLogin];
    }
}
-(void)updateDataAsPerUserLogin{
    [self checkForUserInterest];
}
-(void)checkForUserInterest{
    if([PerkoAuth IsUserLogin]){
        NSArray *arrInterestSelected = [[JLManager sharedManager] getObjectuserDefault:@"arrInterestSelected"];
        if (arrInterestSelected != nil && [arrInterestSelected isKindOfClass:[NSArray class]]) {
            if (arrInterestSelected.count > 0) {
                NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < arrInterestSelected.count; i++) {
                    NSDictionary *dictInterest = [arrInterestSelected objectAtIndex:i];
                    [arrTemp addObject:[NSString stringWithFormat:@"%@",[dictInterest objectForKey:@"id"]]];
                }
                //NSString *strInterest = [arrTemp componentsJoinedByString:@","];
                NSString *strURL = [NSString stringWithFormat:@"%@",USER_INTERESTS_URL] ;
                NSDictionary *dictBody =@{ @"access_token":[PerkoAuth getPerkUser].accessToken,@"interests":arrTemp};
                [[WebServices sharedManager] callAPIJSON:strURL params:dictBody httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
                    if (success) {
                        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                            dict = [dict objectForKey:@"data"];
                            if(kDebugLog)NSLog(@"%@",dict);
                            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                                
                            }
                        }
                    }
                }];
            }
        }
        
        //////
        NSArray *arrChannelSelected = [[JLManager sharedManager] getObjectuserDefault:kUserSelectedChannels];
        if (arrChannelSelected != nil && [arrChannelSelected isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
            for (int i = 0 ; i < arrChannelSelected.count; i++) {
                NSDictionary *dictChannel = [arrChannelSelected objectAtIndex:i];
                [arrTemp addObject:[NSString stringWithFormat:@"%@",[dictChannel objectForKey:@"uuid"]]];
            }
            NSString *strURL = [NSString stringWithFormat:@"%@/favorites",GET_CHANNELS_URL] ;
            
            NSDictionary *dictBody =@{ @"access_token":[PerkoAuth getPerkUser].accessToken,@"channels":arrTemp};
            [[WebServices sharedManager] callAPIJSON:strURL params:dictBody httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
                if (success) {
                    if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                        dict = [dict objectForKey:@"data"];
                        if(kDebugLog)NSLog(@"%@",dict);
                        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                            
                        }
                    }
                }
            }];
            
        }
    }
    
    
}
-(UIFont *)getVideoTitleFont{   
    UIFont *font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
    return font;
}
-(UIFont *)getVideoLargeTitleFont{
    UIFont *font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17];
    return font;
}
-(UIFont *)getSubTitleFont{
    UIFont *font = [UIFont fontWithName:@"SFProDisplay-Regular" size:12];
    
    return font;
}

#pragma mark  -
#pragma mark - activity indicator for laoding

-(void) showLoadingView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->HUD) {
            [self->HUD removeFromSuperview];
        }
        self->HUD = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:self->HUD];
        self->HUD.label.text = @"Loading";
        [self->HUD showAnimated:YES];
        
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = FALSE;
    });
    
}

-(void) hideLoadingView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->HUD hideAnimated:YES];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = TRUE;
        
    });
    
}
-(void) showLoadingViewHome:(UIView *)view{
    [self hideLoadingViewHome];
    CGRect rect = view.bounds;
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
    m_shimmeringViewHome = [[FBShimmeringView alloc] initWithFrame:rect];
    m_shimmeringViewHome.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewHome.shimmering = YES;
   // m_shimmeringView.shimmeringBeginFadeDuration = 0.1;
   // m_shimmeringView.shimmeringOpacity = 0.3;
    [view addSubview:m_shimmeringViewHome];
    ////
    
    UIView *viewLoading = [[UIView alloc] initWithFrame:m_shimmeringViewHome.bounds];
    viewLoading.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewHome.contentView = viewLoading;
    //343 X 239 featured
    //359 X 157 Carousel
    int nPaddingHorizontal = 15;
    int nPaddingVertical = 15;
    int nCellWidth = rect.size.width;// - (2 * nPaddingHorizontal);
    int nCellHeightFeatured = nCellWidth * 239 / 343;
    int nCellHeightCarousel = (nCellWidth+nPaddingHorizontal) * 157 / 359;
    

    
    //int nColumn = (rect.size.width) / (nCellWidth+nPaddingHorizontal) + 1;
    int nRaw = (rect.size.height) / (nCellHeightFeatured + nCellHeightCarousel + 4*nPaddingVertical) + 1;
    
   // for(int i = 0; i < nColumn; i++){
        for (int j = 0; j < nRaw; j++) {
            int nTop = j*(nCellHeightFeatured + nCellHeightCarousel +4*nPaddingVertical);
            CGRect rectFeaturedBackground = CGRectMake(0, nTop, nCellWidth, nCellHeightFeatured+ 2*nPaddingVertical);
            AppSecondBGView *objAppSecondBGView = [[AppSecondBGView alloc] initWithFrame:rectFeaturedBackground];
            [viewLoading addSubview:objAppSecondBGView];
            
            UIImageView *imgViewFeatured = [[UIImageView alloc] initWithFrame:CGRectMake(nPaddingHorizontal, nPaddingVertical, nCellWidth-(2 * nPaddingHorizontal), nCellHeightFeatured)];
            imgViewFeatured.image = [UIImage imageNamed:@"loading_video_featured"];
            [objAppSecondBGView addSubview:imgViewFeatured];
            
            
            UIImageView *imgViewCarousel = [[UIImageView alloc] initWithFrame:CGRectMake(nPaddingHorizontal, nTop+ nPaddingVertical+nCellHeightFeatured+nPaddingVertical+nPaddingVertical , nCellWidth, nCellHeightCarousel)];
            imgViewCarousel.image = [UIImage imageNamed:@"loading_video_featured"];
            [viewLoading addSubview:imgViewCarousel];
            
            ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
            switch (currentTheme) {
                case DayMode:
                    imgViewFeatured.alpha = 0.5;
                    imgViewCarousel.alpha = 0.5;
                    break;
                    
                default:
                    
                    break;
            }
        }
  //  }

}
-(void)hideLoadingViewHome{
    if (m_shimmeringViewHome) {
        m_shimmeringViewHome.shimmering = NO;
        [m_shimmeringViewHome removeFromSuperview];
    }
}
-(void) showLoadingViewSearch:(UIView *)view top:(int)nTop{
    [self hideLoadingViewSearch];
    CGRect rect = view.bounds;
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
    m_shimmeringViewPlayer = [[FBShimmeringView alloc] initWithFrame:rect];
    m_shimmeringViewPlayer.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewPlayer.shimmering = YES;
    // m_shimmeringView.shimmeringBeginFadeDuration = 0.1;
    // m_shimmeringView.shimmeringOpacity = 0.3;
    
    [view addSubview:m_shimmeringViewPlayer];
    ////
    
    UIView *viewLoading = [[UIView alloc] initWithFrame:m_shimmeringViewPlayer.bounds];
    viewLoading.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewPlayer.contentView = viewLoading;
    //332 X 79
    //int nTop = 100;
    int nPaddingHorizontal = 15;
    int nPaddingVertical = 15;
    int nCellWidth = rect.size.width- (2 * nPaddingHorizontal);
    int nCellHeight = rect.size.width * 79/332;
    
    //int nColumn = 1;//(rect.size.width) / (nCellWidth+nPaddingHorizontal) + 1;
    int nRaw = (rect.size.height) / (nCellHeight + nPaddingVertical) + 1;
   // for(int i = 0; i < nColumn; i++){
    int i = 0;
        for (int j = 0; j < nRaw; j++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(nCellWidth + nPaddingHorizontal)+ nPaddingHorizontal, j*(nCellHeight + nPaddingVertical)+ nPaddingVertical+nTop, nCellWidth, nCellHeight)];
            imgView.image = [UIImage imageNamed:@"loading_video_player"];
            [viewLoading addSubview:imgView];
            
            ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
            switch (currentTheme) {
                case DayMode:
                    imgView.alpha = 0.5;
                    break;
                    
                default:
                    
                    break;
            }
        }
   // }

}
-(void)hideLoadingViewSearch{
    if (m_shimmeringViewPlayer) {
        m_shimmeringViewPlayer.shimmering = NO;
        [m_shimmeringViewPlayer removeFromSuperview];
    }
}
-(void) showLoadingViewChannel:(UIView *)view{
    [self hideLoadingViewChannel];
    CGRect rect = view.bounds;
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
    m_shimmeringViewChannel = [[FBShimmeringView alloc] initWithFrame:rect];
    m_shimmeringViewChannel.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewChannel.shimmering = YES;
    // m_shimmeringView.shimmeringBeginFadeDuration = 0.1;
    // m_shimmeringView.shimmeringOpacity = 0.3;
    
    [view addSubview:m_shimmeringViewChannel];
    ////
    
    UIView *viewLoading = [[UIView alloc] initWithFrame:m_shimmeringViewChannel.bounds];
    viewLoading.backgroundColor = kPrimaryBGColor;
    m_shimmeringViewChannel.contentView = viewLoading;
    //359 X 143
    
    int nPaddingHorizontal = 15;
    int nPaddingVertical = 15;
    int nCellWidth = rect.size.width;
    int nCellHeight = nCellWidth * 143 / 359;
    int nTotalCellheight =nCellHeight + 3*nPaddingVertical;
    int nRaw = (rect.size.height) / nTotalCellheight + 1;
    // for(int i = 0; i < nColumn; i++){
    for (int j = 0; j < nRaw; j++) {
        int nTop = j*nTotalCellheight;
       
        UIImageView *imgViewCarousel = [[UIImageView alloc] initWithFrame:CGRectMake(nPaddingHorizontal, nTop, nCellWidth, nCellHeight)];
        imgViewCarousel.image = [UIImage imageNamed:@"loading_video_home"];
        [viewLoading addSubview:imgViewCarousel];
        ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
        switch (currentTheme) {
            case DayMode:
                imgViewCarousel.alpha = 0.5;
                break;
                
            default:
                
                break;
        }
    }
    //  }
    
}
-(void)hideLoadingViewChannel{
    if (m_shimmeringViewChannel) {
        m_shimmeringViewChannel.shimmering = NO;
        [m_shimmeringViewChannel removeFromSuperview];
    }
}
-(BOOL)checkifLessthenMinAgeRequirementwithDate:(NSString *)dob min_age : (int)min_age{
    NSString *dateString = dob;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthday = [dateFormatter dateFromString:dateString];

    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    if(age >= 18){
        return YES;
    }else{
        return NO;
    }
}

-(void)checkForUnderAge{
    JLPerkUser * user = PerkoAuth.getPerkUser;
    
    NSString *strDateOfBirth = [NSString stringWithFormat:@"%@",user.birthday];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    if(strDateOfBirth != nil && ![strDateOfBirth isEqualToString:@"(null)"] && ![strDateOfBirth isEqualToString:@"<null>"]){
        //yyyy-MM-dd HH:mm:ss
        NSDateFormatter *dateFormatterNew = [[NSDateFormatter alloc] init];
        [dateFormatterNew setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate *recDate = [dateFormatterNew dateFromString:strDateOfBirth];
        if (recDate != nil) {
            //NSString *dateInString = [dateFormatter stringFromDate:recDate];
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
            NSDate *now = [NSDate date];
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *comps = [gregorian components:unitFlags fromDate:now];
            [comps setYear:[comps year] - kMinAgeRequirement];
            NSDate *thirteenYearsAgo = [gregorian dateFromComponents:comps];
            
            //NSDate * selectedDate = [objDatepicker date];
            if ([recDate compare:thirteenYearsAgo] == NSOrderedDescending) {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:kNotAvailableMessage
                                             message:@""
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* btnOK = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            [[JLManager sharedManager] logoutUserWithoutAlert];
                                        }];
                
                
                [alert addAction:btnOK];
                [[[JLManager sharedManager] topViewController] presentViewController:alert animated:YES completion:nil];
            }
        }
        
    }
    
}
-(void)setLeanplumData{
    @try {
        if ([PerkoAuth IsUserLogin]) {
            JLPerkUser * user = PerkoAuth.getPerkUser;
            if(kDebugLog)NSLog(@" user_uuid -> %@",user.userUUID);
            //NSLog(@" user_uuid -> %@",user.userUUID);
            NSString *gender = [NSString stringWithFormat:@"%@",user.gender];
            NSString *birthday = [NSString stringWithFormat:@"%@",user.birthday];
            NSString *u_email = [NSString stringWithFormat:@"%@",user.email];
            NSString *email_confirmed = [NSString stringWithFormat:@"%@",user.email_confirmed];
            NSString *user_uuid = [NSString stringWithFormat:@"%@",user.userUUID];
            NSString *referralCode = [NSString stringWithFormat:@"%@",user.referralCode];
            [Leanplum setUserAttributes:@{@"Gender":gender, @"DOB": birthday,@"Email":u_email,@"Email Verified":email_confirmed,@"user_uuid":@"" ,@"Referral Code":referralCode }];
            
            [Leanplum setDeviceId:user_uuid];
            [Leanplum setUserId:user_uuid];
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}
-(void)dismissPresentedControllerIfAny{
    if([[JLManager sharedManager] presentedViewController]!=nil){
        [[[JLManager sharedManager] presentedViewController] dismissViewControllerAnimated:NO completion:nil];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
}
-(void)setUserVideoWatched:(NSString *)strVideoID{
    NSMutableDictionary *dict = [[JLManager sharedManager] getObjectuserDefault:kUserWatchedVideos];
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary new];
    }
    //NSDate *toDateTime = [NSDate date];
    NSDate *currentVideoSavedDate = [dict objectForKey:@"currentVideoSavedDate"];
    if (currentVideoSavedDate == nil || ![currentVideoSavedDate isKindOfClass:[NSDate class]]) {
        [dict removeAllObjects];
    }
    else{
        NSDate *toDateTime = [NSDate date];
        
        NSDate *fromDate;
        NSDate *toDate;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:currentVideoSavedDate];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:toDateTime];
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:fromDate toDate:toDate options:0];
        int nDays = (int)[difference day];
        if (nDays > 0) {
            [dict removeAllObjects];
        }
    }
    [dict setObject:[NSDate date] forKey:@"currentVideoSavedDate"];
    
    int nCount = [[dict objectForKey:strVideoID] intValue] + 1;
    [dict setObject:[NSString stringWithFormat:@"%d",nCount] forKey:strVideoID];
    [[JLManager sharedManager] setObjectuserDefault:dict forKey:kUserWatchedVideos];
}
-(int)getUserVideoWatched:(NSString *)strVideoID{
    
    NSMutableDictionary *dict = [[JLManager sharedManager] getObjectuserDefault:kUserWatchedVideos];
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary new];
    }
    int nCount = [[dict objectForKey:strVideoID] intValue];
    return nCount;
}
-(void)getAppSettings:(void(^)(NSDictionary *dict))handler{
    NSDictionary *dictAppSettings = [[JLManager sharedManager] getObjectuserDefault:kAppSettings];
    if (dictAppSettings != nil && [dictAppSettings isKindOfClass:[NSDictionary class]]) {
        if(handler)handler(dictAppSettings);
        handler = nil;
    }
    NSString *strURL = [NSString stringWithFormat:@"%@",GET_SETTINGS_URL] ;
    NSString *params = @"";
   
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        NSDictionary *dictAppSettings;
        int n_save_playhead_count = 1;
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if(kDebugLog)NSLog(@"%@",dict);
                if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    dictAppSettings = [dict objectForKey:@"settings"];
                    if (dictAppSettings != nil && [dictAppSettings isKindOfClass:[NSDictionary class]]) {
                        n_save_playhead_count = [[NSString stringWithFormat:@"%@",[dictAppSettings objectForKey:@"save_playhead_count"]] intValue];
                    }
                    
                }
            }
        }
        if (dictAppSettings == nil || ![dictAppSettings isKindOfClass:[NSDictionary class]])
        {
            dictAppSettings = [NSDictionary new];
        }
        if(handler)handler(dictAppSettings);
        [[LFCache sharedManager] setCapacity:n_save_playhead_count];
        [[JLManager sharedManager] setObjectuserDefault:dictAppSettings forKey:kAppSettings];
        
    }];
}
-(NSMutableArray *)removedWatchedLongformVideos:(NSMutableArray *)arr{
    NSDictionary *dictAppSettings = [[JLManager sharedManager] getObjectuserDefault:kAppSettings];
    if (dictAppSettings == nil || ![dictAppSettings isKindOfClass:[NSDictionary class]]) {
        return arr;
    }
    int longform_cap = [[NSString stringWithFormat:@"%@",[dictAppSettings objectForKey:@"longform_cap"]] intValue];
    if (longform_cap < 1) {
        return arr;
    }
    NSMutableArray *arrPlaylists = [NSMutableArray arrayWithArray:arr];
    NSIndexSet *toBeRemoved = [arrPlaylists indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        BOOL removeIt = FALSE;
        NSDictionary *dict = [arrPlaylists objectAtIndex:idx];
        NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
        if ([type isEqualToString:@"featured"]) {
            NSArray *arr = [dict objectForKey:@"featured"];
            if (arr != nil && [arr isKindOfClass:[NSDictionary class]]) {
                arr = @[arr];
            }
            if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
                
                ////////
                NSMutableArray *arrVideos = [NSMutableArray arrayWithArray:arr];
                NSIndexSet *toBeRemoved = [arrVideos indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                    BOOL removeIt = FALSE;
                    NSDictionary *dict = [arrVideos objectAtIndex:idx];
                    ////////
                    if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                        BOOL bLongform = FALSE;
                        NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
                        if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
                            NSString *longform = [custom_fields objectForKey:@"longform"];
                            if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
                                bLongform = [longform boolValue];
                            }
                        }
                        if (bLongform) {
                            NSString *strVideoID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                            if (strVideoID != nil && [strVideoID isKindOfClass:[NSString class]] && strVideoID.length > 0 && [[JLManager sharedManager] getUserVideoWatched:strVideoID] >= longform_cap) {
                                removeIt = YES;
                            }
                        }
            
                    }
                    
                    return removeIt;
                }];
                [arrVideos removeObjectsAtIndexes:toBeRemoved];
                //////
                if (arrVideos.count < 1) {
                    removeIt = YES;
                }
            }
            
        }
        return removeIt;
    }];
    [arrPlaylists removeObjectsAtIndexes:toBeRemoved];
    
    return arrPlaylists;
}



-(void)checkAndClearLocalCacheForWatchedVideos:(BOOL)isForced{
    NSMutableDictionary *dict = [[JLManager sharedManager] getObjectuserDefault:kUserWatchedVideos];
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary new];
    }
    if (!isForced) {
        //NSDate *toDateTime = [NSDate date];
        NSDate *currentVideoSavedDate = [dict objectForKey:@"currentVideoSavedDate"];
        if (currentVideoSavedDate == nil || ![currentVideoSavedDate isKindOfClass:[NSDate class]]) {
            isForced = TRUE;
        }
        else{
            NSDate *toDateTime = [NSDate date];
            NSDate *fromDate;
            NSDate *toDate;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                         interval:NULL forDate:currentVideoSavedDate];
            [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                         interval:NULL forDate:toDateTime];
            NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                       fromDate:fromDate toDate:toDate options:0];
            int nDays = (int)[difference day];
            if (nDays > 0) {
                isForced = TRUE;
            }
        }
    }
    if (isForced) {
        [dict removeAllObjects];
        [dict setObject:[NSDate date] forKey:@"currentVideoSavedDate"];
        [[JLManager sharedManager] setObjectuserDefault:dict forKey:kUserWatchedVideos];
        
    }
}
#pragma mark-
#pragma mark favorite channels/shows add/remove/search related methods


-(void)syncLocalFavoriteShowsToServer:(void (^) (BOOL success))handler{
    
    if(![PerkoAuth getPerkUser].IsUserLogin){
        return;
    }
    
    if(![[JLManager sharedManager] checkFavoriteshowExistsLocally]){
        return;
    }
    
    NSString *strURL = GET_FAVORITES_URL;

    NSMutableDictionary * dictParameters = [[NSMutableDictionary alloc] init];

    
    [dictParameters setValue:[PerkoAuth getPerkUser].accessToken forKey:@"access_token"];
    
    NSArray * ary_local_fav_channels = [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels];
    
    NSMutableArray * channels_uuids = [[NSMutableArray alloc] init];
    
    if ( [ary_local_fav_channels isKindOfClass:[NSArray class]]){
        for (id obj in ary_local_fav_channels){
            if(obj != nil && (id)obj != [NSNull null]){
                if([obj valueForKey:@"uuid"] != nil && [obj valueForKey:@"uuid"] != [NSNull null]){
                    [channels_uuids addObject:[obj valueForKey:@"uuid"]];
                }
            }
        }
    }
    
    if(channels_uuids.count == 0){
        return;
    }
    [dictParameters setValue:channels_uuids forKey:@"channels"];
    
    [[WebServices sharedManager] callAPIJSON:strURL params:dictParameters httpMethod:@"POST" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {

        
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                if([dict valueForKey:@"message"] != nil &&
                   [dict valueForKey:@"message"] != [NSNull null]
                   ){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:2.0 position:CSToastPositionCenter title:[dict valueForKey:@"message"] image:nil style:nil completion:nil];
                    });
                }
            }
            handler(true);
        }else{
            handler(false);
        }
        
    }];
}

-(void)AddToFavoriteshowsLocally:(NSDictionary *)dict_channel{
    if(dict_channel != nil && (id)dict_channel != [NSNull null]){
    NSMutableArray * ary_local_fav_channels = [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels];
    if(!ary_local_fav_channels){
        ary_local_fav_channels = [[NSMutableArray alloc] init];
    }else if(![ary_local_fav_channels isKindOfClass:[NSArray class]]){
        ary_local_fav_channels = [[NSMutableArray alloc] init];
    }
    [ary_local_fav_channels addObject:[[NSMutableDictionary alloc] initWithDictionary:dict_channel]];
    [[JLManager sharedManager] setObjectuserDefault:ary_local_fav_channels forKey:kFavoriteChannels];
    }
}

-(void)removeFavoriteshowWithUUIDLocally:(NSString *)uuid{
    
    if([self checkFavoriteshowExistsLocally:uuid]){
        NSMutableArray * ary_local_fav_channels = [[NSMutableArray alloc] initWithArray:
                                                   [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels]];
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        
        if ( [ary_local_fav_channels isKindOfClass:[NSArray class]]){
            for (id obj in ary_local_fav_channels){
                if(uuid != nil && (id)uuid != [NSNull null] && [obj valueForKey:@"uuid"] != nil && (id)[obj valueForKey:@"uuid"] != [NSNull null]){
//                    if([[uuid lowercaseString] isEqualToString:[[obj valueForKey:@"uuid"] lowercaseString]]){
//                        [ary_local_fav_channels removeObject:obj];
//                    } // this doesn't work as we always get immutable array from nsuserdefault even though we saved it as mutable, so we have to do it other way...
                    if(![[uuid lowercaseString] isEqualToString:[[obj valueForKey:@"uuid"] lowercaseString]]){
                        [temp addObject:obj];
                    }
                }
            }
        }
        [[JLManager sharedManager] setObjectuserDefault:temp forKey:kFavoriteChannels];
    }
}

-(BOOL)checkFavoriteshowExistsLocally{
    
    NSArray * ary_local_fav_channels = [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels];
    
    if ([ary_local_fav_channels isKindOfClass:[NSArray class]]){
        if(ary_local_fav_channels.count > 0){
            return YES;
        }
    }
    return NO;
}

-(BOOL)checkFavoriteshowExistsLocally:(NSString *)uuid{
    
    
    NSArray * ary_local_fav_channels = [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels];
    
    if ( [ary_local_fav_channels isKindOfClass:[NSArray class]]){
        for (id obj in ary_local_fav_channels){
            if(uuid != nil && (id)uuid != [NSNull null] && [obj valueForKey:@"uuid"] != nil && (id)[obj valueForKey:@"uuid"] != [NSNull null]){
                if([[uuid lowercaseString] isEqualToString:[[obj valueForKey:@"uuid"] lowercaseString]]){
                    return true;
                }
            }
        }
    }
    return false;
}
-(void)clearAllLocalFavorites{
    [[JLManager sharedManager] setObjectuserDefault:@"" forKey:kFavoriteChannels];
}
@end
