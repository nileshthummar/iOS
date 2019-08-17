//
//  JLManager.h
//  Perk
//
//  Created by Nilesh on 8/21/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPerkUser.h"
#import "JLTrackers.h"
#import "JLPerkUser.h"
#import "JLPerkPoint.h"
#import "NSString+HMACString.h"
#import <UIKit/UIKit.h>
#import "FBTrackingEvents.h"
#import "PlayerVC.h"
#import "Constants.h"
@protocol PerkAdDelegate <NSObject>
- (void)adDidFinished:(bool) success sdk:(NSString *)strSDK;
@end
@interface JLManager : NSObject{
    
}
@property(strong)NSString *m_strFAN_PlacementID;
@property (atomic,strong) id  presentedViewController;

@property (atomic, readwrite) int skip_registration;

@property (assign)bool m_bIsVideoLooping;
@property (assign)bool m_bIsBonusAd;
@property(strong)NSString *m_strCombrePlacementName;
//@property(strong)PlayerVC * m_objPlayerVC;
@property(assign)BOOL m_bIsTabbarVisible;
@property(assign)BOOL needToRefreshChannels;

+(JLManager *)sharedManager;
-(void)setLogoutStatus;
-(void)UpdatePerkUserwithPointAttributes:(NSDictionary*)dictPerkUserPointsAttributes;
-(void) showLoadingView:(UIView *)view;
-(void) hideLoadingView ;
- (BOOL) isInternetConnected;
-(void)checkAppversion;
- (void) showNetworkError;
-(id)getObjectuserDefault:(id)key;
-(void)setObjectuserDefault:(id)value forKey:(id)key;

- (void) showLoginSignUpwithUserAction:(int)userAction;

- (void) showAPIResponseError:(NSString *) errorMessage;
//- (void) showToastForMessage:(NSString *) message;
//- (void) showToastForMessage:(NSString *) message position:(NSString *) position;
//-(void)clearCache;
- (void) handleCommonErrorResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)connectionError ;
- (void) logoutUserWithAlert:(LogoutMode)mode;
-(void)callAPIForGetDeveloperMode;
-(void)sentLog:(NSString *)str;
-(BOOL)checkForUseWiFiOnly;
- (void)openFBSessionwithUserAction:(BOOL)bIsWeb topController:(UIViewController *)topController  handler:(void (^) (BOOL success, NSString *strFBToken,NSString *strFBUserID,NSString *strError))handler;
-(void)closeAndClearFBTokenInformation;
- (void) showAdBlockerOverlay;


- (UIViewController*)topViewController;
- (void) checkForAdBlocker:(NSString *)strURL;

-(void)getUserInfo:(void (^) (BOOL success))handler;
-(void)checkForForceUpdate:(NSData *)data responseStatusCode:(int) responseStatusCode;
#pragma mark-
#pragma mark app rating prompt related methods
-(void)showPerkUpdateRibbon:(bool) force_update url:(NSString *)url;
-(void)loginSignupSuccessed;

#pragma mark --
-(void)GoToVerificationCodeScreenwithPhoneNumber:(NSString *)phoneno;
#pragma mark --
-(BOOL)updateVideoView:(NSDictionary *)dicVideoInfo;
-(void)updatePlayerBarLayout;

-(void)setAppTheme:(ThemeType)themeType;
-(ThemeType )getAppTheme;
-(UIColor *)getPrimaryBGColor;
-(UIColor *)getSecondaryTextColor;
-(UIColor *)getSecondBGColor;
-(UIColor *)getPrimaryTextColor;
-(UIColor *)getThirdTextColor;
-(UIImage *)getPrimaryBackbuttonImage;
-(NSArray *)removedLongformAmazonBC:(NSArray *)arr;
-(NSMutableArray *)removedWatchedLongformVideos:(NSMutableArray *)arr;
-(void)loginAfterDelay;
-(void)checkForUserLoginStatusChanged;
-(UIFont *)getVideoTitleFont;
-(UIFont *)getVideoLargeTitleFont;
-(UIFont *)getSubTitleFont;
-(void) showLoadingViewHome:(UIView *)view;
-(void)hideLoadingViewHome;
-(void) showLoadingViewSearch:(UIView *)view top:(int)nTop;
-(void)hideLoadingViewSearch;
-(void) showLoadingViewChannel:(UIView *)view;
-(void)hideLoadingViewChannel;
-(void)setLeanplumData;
-(void)dismissPresentedControllerIfAny;
-(void)setUserVideoWatched:(NSString *)strVideoID;
-(int)getUserVideoWatched:(NSString *)strVideoID;
-(void)getAppSettings:(void(^)(NSDictionary *dict))handler;
-(void)checkAndClearLocalCacheForWatchedVideos:(BOOL)isForced;
- (void)resetDefaults;

#pragma mark-
#pragma mark age difference calculation method
-(BOOL)checkifLessthenMinAgeRequirementwithDate:(NSString *)dob min_age : (int)min_age;

#pragma mark-
#pragma mark favorite channels/shows add/remove/search related methods
-(BOOL)checkFavoriteshowExistsLocally:(NSString *)uuid;
-(BOOL)checkFavoriteshowExistsLocally;
-(void)AddToFavoriteshowsLocally:(NSDictionary *)dict_channel;
-(void)removeFavoriteshowWithUUIDLocally:(NSString *)uuid;
-(void)clearAllLocalFavorites;
-(void)syncLocalFavoriteShowsToServer:(void (^) (BOOL success))handler;
@end
