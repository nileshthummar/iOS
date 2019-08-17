//
//  Constants.h
//  Watchback
//
//  Created by Nilesh on 1/8/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//
#import "JLUtils.h"

#ifndef Constants_h
#define Constants_h
#ifdef DEBUG
    #define kDebugLog 1
#else
    #define kDebugLog 0 
#endif

//temp AppStore for enable push notification from capability

#define kWeb_Domain_Watchback    getWatchbackWebDomain()

#define kWatchbackAPI_Doamin    getWatchbackAPITVDomain()
////

#define kProd [kWatchbackAPI_Doamin isEqualToString:@"https://api.watchback.com"]

////


#define LOGIN_OAUTH_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/tokens"]
#define REGISTER_OAUTH_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/register"]

///

///api.watchback.com
#define GET_HOMESCREEN2_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/homescreen"]
#define GET_GENRES_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/genres"]
#define GET_CHANNEL_VIDEOS [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/channel"]
#define GET_FAVORITES_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/channels/favorites"]
#define ADD_FAVORITES_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/channel/<uuid_value>/favorite"]
////api-tv.perk.com

#define API_AppVersion [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/v4/versions.json"]
#define API_AssingUnAssingDeviceUser [NSString stringWithFormat:@"%@/users/me/devices",kWatchbackAPI_Doamin]
#define GET_USERINFO [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/users/me"]
#define API_CAROUSELS [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/carousels"]
#define GEO_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/v1/geo.json"]
#define VERIFY_PHONE_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/verify-phone"]
#define REVERIFY_PHONE_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/resend-verification"]
#define GET_REWARS_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/rewards"]
#define VIEW_VIDEO_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/views"]
#define USER_INTERESTS_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/interests"]
#define GET_CHANNELS_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/channels"]
#define GET_HOMESCREEN_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/homescreen"]
#define GET_RECOMMENDED_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/recommended"]
#define GET_SETTINGS_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/settings"]
#define GET_RELATE_VIDEOS_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/featured"]
#define LOGOUT_URL [NSString stringWithFormat:@"%@%@",kWatchbackAPI_Doamin,@"/logout"]

//#define kForgotPasswordLink [NSString stringWithFormat:@"%@%@",kWeb_Domain_Perk,@"/authentication/watchback-forgot-password?app=watchback"]
//#define kMyAccountWebpage     [NSString stringWithFormat:@"%@/profile/edit",kWeb_Domain_Perk]
#define kTermsAndConditionsLink  [NSString stringWithFormat:@"%@/terms",kWeb_Domain_Watchback]
#define kPrivacyPolicy [NSString stringWithFormat:@"%@/privacy",kWeb_Domain_Watchback]
#define kVPPA [NSString stringWithFormat:@"%@/vppa",kWeb_Domain_Watchback]
#define kMyAccountWebpage     [NSString stringWithFormat:@"%@/profile",kWeb_Domain_Watchback]
#define kForgotPasswordLink [NSString stringWithFormat:@"%@/auth/forgot-password",kWeb_Domain_Watchback]

#define kHelpLink  @"https://watchbacksupport.zendesk.com/hc/en-us"
#define kFBLikePage @"https://www.facebook.com/WatchBack-400958693688613"

#define kPerkDomain @"watchback.com"

#define isIPad (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)


/////App specific start
#define kDeviceType @"watchback2_ios"
#define HMAC_SALT  @"1999566e5f7b5a3b08f937c91888a19f432551684e8623b6fe83933cee9e4811"
#define perkAppID @"1459544784"

#define kPerkSecret kProd? @"4c1911ed21b87de70b0ed6ae5f0f816279db8d8308cee6eb724d13a085b4bb5c":@"d6944f4cfe63a1f37c20398944a51fb25fbf56c8d931b75cbda93f702404e110"

#define kAppStore_URL  @"https://itunes.apple.com/us/app/watchback%202/id1459544784?ls=1" //temp nilesh
/////App specific end
#define kNotAvailableMessage @"Sorry, WatchBack is currently not available to you."
#define kStopVideoNotification @"STOP_VIDEO"
#define kSaveVideoNotification @"SAVE_VIDEO"
/////AppTheme Specific start
#define kPrimaryBGColor [[JLManager sharedManager] getPrimaryBGColor]
#define kSecondBGColor [[JLManager sharedManager] getSecondBGColor]
#define kPrimaryTextColor [[JLManager sharedManager] getPrimaryTextColor]
#define kSecondaryTextColor [[JLManager sharedManager] getSecondaryTextColor]
#define kThirdTextColor [[JLManager sharedManager] getThirdTextColor]
#define kPrimaryBackImage [[JLManager sharedManager] getPrimaryBackbuttonImage]

#define  kPrimaryBGColorNight [UIColor colorWithRed:27.0/255.0 green:27.0/255.0 blue:37.0/255.0 alpha:1]
#define  kPrimaryBGColorDay [UIColor colorWithRed:245.0/255.0 green:247.0/255.0 blue:248.0/255.0 alpha:1]

#define  kSecondBGColorNight [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:24.0/255.0 alpha:0.7]
#define  kSecondBGColorDay [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7]

#define  kPrimaryTextColorNight [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]
#define  kPrimaryTextColorDay [UIColor colorWithRed:27.0/255.0 green:27.0/255.0 blue:37.0/255.0 alpha:1]

#define  kCommonColor [UIColor colorWithRed:120.0/255.0 green:137.0/255.0 blue:149.0/255.0 alpha:1]
#define  kCommonColor2 [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]

#define  kRedColor [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:74.0/255.0 alpha:1]
#define  kRedColorDisabled [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:74.0/255.0 alpha:0.5]
#define  kRedColorDisabled2 [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:74.0/255.0 alpha:0.7]

#define  kOffStateColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.2]

#define kOffStateColorNight [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:0.5]
#define kOffStateColorDay [UIColor colorWithRed:8/255.0 green:8/255.0 blue:8/255.0 alpha:0.5]

#define kOffStateColor2Night [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:0.8]
#define kOffStateColor2Day [UIColor colorWithRed:8/255.0 green:8/255.0 blue:8/255.0 alpha:0.8]

/////AppTheme Specific end

typedef enum{
    kSignup=0,
    kLogin
} kType;
typedef enum{
    NightMode=0,
    DayMode
} ThemeType;


typedef enum{
    LogoutModeDefault = 0,
    LogoutModeNoWatchbackAvailable
}LogoutMode;

#define perkUserKey @"perkUserKey"
#define kLongformVideoPositionCacheKey @"perkUserLongformVideoPositionCacheKey"
#define kIsAppInstalled @"perkisAppInstalled"
#define kTermsPrivacyAgreement @"perkUserTermsPrivacyAgreement"
#define kMarketingAgreement @"perkUserMarketingAgreement"
#define kDevModeProtocol    @"perkDevModeProtocol"
#define kDevModeAPIEndpoint @"perkDevModeAPIEndpoint"
#define kDevModeAPIEndpointCustomAPITV @"perkDevModeAPIEndpointCustomAPITV"
#define kDevModeAPIEndpointCustomWeb @"perkDevModeAPIEndpointCustomWeb"
#define kAppThemeKey @"perkUserAppThemeKey"
#define kDevModeDebug @"perkDevModeDebug"
#define kPerkUserCountry @"perkUserCountry"
#define kAppsFlyerInstallTime @"perkAppsFlyerInstallTime"
#define kUserSelectedChannels @"perkUserSelectedChannels"
#define kUserSelectedInterests @"perkUserSelectedInterests"
#define kIsUserFacebookLogin @"perkUserFacebookLogin"
#define kUserWatchedVideos @"perkUserWatchedVideos"
#define kFavoriteChannels @"kFavoriteChannels"
#define kAppSettings @"perkAppSettings"
#define QueryParameter @"source=app"
#define kUpdateCurrencyNotification @"kUpdateCurrencyNotification"
#define kGetUserLoginSignupNotification @"kGetUserLoginSignupNotification"
#define kLoadHomePageNotification @"kLoadHomePageNotification"
#define kLoadWelcomePageNotification @"kLoadWelcomePageNotification"
#define kLoadVerificationCodePageNotification @"kLoadVerificationCodePageNotification"
#define kDismissVerificationCodePageNotification @"kDismissVerificationCodePageNotification"
#define kSetSelectedTabIndexNotification @"kSetSelectedTabIndexNotification"
#define kThemeChangedNotification @"kThemeChangedNotification"
#define kResetHeaderNotification @"kResetHeaderNotification"
#define kUpdatedUserSelectionNotification @"kUpdatedUserSelectionNotification"
#define kThemeChangedNotification @"kThemeChangedNotification"
#define kRefreshHomeDataNotification @"kRefreshHomeDataNotification"
#define kRefreshChannelDataNotification @"kRefreshChannelDataNotification"
#define kRefreshDonateDataNotification @"kRefreshDonateDataNotification"
#define kRefreshThankyouDataNotification @"kRefreshThankyouDataNotification"
#define kRefreshMyAccountDataNotification @"kRefreshMyAccountDataNotification"
#define kUserWatchedVideoNotification @"kUserWatchedVideoNotification"
#define kUserWatchedLongformVideoNotification @"kUserWatchedLongformVideoNotification"
#define kReloadDataForWatchedVideosNotification @"kReloadDataForWatchedVideosNotification"
#define kOpenChannelNotification @"kOpenChannelNotification"
#define kRequestMoreInfoLogoutNotification @"kRequestMoreInfoLogoutNotification"
#define kReloadGenresDataNotification @"kReloadGenresDataNotification"

#define kAdBlockOverlayTag 7890
#define kMinAgeRequirement 18
#define kAPICacheTime 300 // 5 minutes

#define kFontPrimary12 [UIFont fontWithName:@"SFProDisplay-Medium" size:12]
#define kFontPrimary14 [UIFont fontWithName:@"SFProDisplay-Medium" size:14]
#define kFontPrimary16 [UIFont fontWithName:@"SFProDisplay-Medium" size:16]
#define kFontPrimary17 [UIFont fontWithName:@"SFProDisplay-Medium" size:17]
#define kFontPrimary18 [UIFont fontWithName:@"SFProDisplay-Medium" size:18]
#define kFontPrimary36 [UIFont fontWithName:@"SFProDisplay-Medium" size:36]
#define kFontPrimary20 [UIFont fontWithName:@"SFProDisplay-Medium" size:20]
#define kFontPrimary23 [UIFont fontWithName:@"SFProDisplay-Medium" size:23]
#define kFontPrimary24 [UIFont fontWithName:@"SFProDisplay-Medium" size:24]

#define kFontPrimaryBold12 [UIFont fontWithName:@"SFProDisplay-Bold" size:12]
#define kFontPrimaryBold14 [UIFont fontWithName:@"SFProDisplay-Bold" size:14]
#define kFontPrimaryBold16 [UIFont fontWithName:@"SFProDisplay-Bold" size:16]
#define kFontPrimaryBold17 [UIFont fontWithName:@"SFProDisplay-Bold" size:17]
#define kFontPrimaryBold18 [UIFont fontWithName:@"SFProDisplay-Bold" size:18]
#define kFontPrimaryBold20 [UIFont fontWithName:@"SFProDisplay-Bold" size:20]
#define kFontPrimaryBold23 [UIFont fontWithName:@"SFProDisplay-Bold" size:23]
#define kFontPrimaryBold24 [UIFont fontWithName:@"SFProDisplay-Bold" size:24]

#define kFontSemiBold12 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:12]
#define kFontSemiBold14 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:14.6]
#define kFontSemiBold16 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:16]
#define kFontSemiBold17 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:17]
#define kFontSemiBold18 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:18]
#define kFontSemiBold20 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:20]
#define kFontSemiBold23 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:23]
#define kFontSemiBold24 [UIFont fontWithName:@"SFProDisplay-SemiBold" size:24]



//#define kFontPrimary12 [UIFont systemFontOfSize:12]
//#define kFontPrimary14 [UIFont systemFontOfSize:14]
//#define kFontPrimary16 [UIFont systemFontOfSize:16]
//#define kFontPrimary17 [UIFont systemFontOfSize:17]
//#define kFontPrimary18 [UIFont systemFontOfSize:18]
//#define kFontPrimary20 [UIFont systemFontOfSize:20]
//#define kFontPrimary23 [UIFont systemFontOfSize:23]
//#define kFontPrimary24 [UIFont systemFontOfSize:24]


#define kFontBtn12 [UIFont fontWithName:@"SFProDisplay-Medium" size:13]
#define kFontBtn14 [UIFont fontWithName:@"SFProDisplay-Medium" size:15]
//#define kFontBtn12 [UIFont systemFontOfSize:12]
//#define kFontBtn14 [UIFont systemFontOfSize:14]


#endif /* Constants_h */
