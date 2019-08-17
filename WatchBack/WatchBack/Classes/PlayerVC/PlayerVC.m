//
//  PlayerVC.m
//  Watchback
//
//  Created by Nilesh on 1/19/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "PlayerVC.h"
#import "PerkoAuth.h"
#import "UIView+Toast.h"
#import "WebServices.h"
#import "Constants.h"
#import "JLManager.h"
#import "PlayerVideoCell.h"
#import "NielsenBrightcovePlugin.h"
#import "RedeemWebVC.h"
#import "NavPortrait.h"
//#import "Reachability.h"
#import "Leanplum_Reachability.h"
#import <AdSupport/AdSupport.h>
#import "LFCache.h"
static NSString * const kViewControllerAccountID = @"5622532334001";//Brightcove
//static NSUInteger  const kFreeWheelNetworkdID =  169843;//comcast //392025; //NBCU updated on 07/31/2018;//

static NSString * const kViewControllerPlaybackServicePolicyKey = @"BCpkADawqM34qZK0FVZiqjW1d48fSZ2VmagDAjA_jVTXIRDfHKQLFNSzR7j9rSmPlg5HIzqnMlPvMxWUjonLpBbUXEaj3Nv1UGeQ-OyTgAc0ZfjXZbCj9LG3HE1xagNU9HYC3AJHkIvK3Nff";



@import BrightcovePlayerSDK;
@interface PlayerVC ()<BCOVPlaybackControllerDelegate,BCOVPUIPlayerViewDelegate,NielsenBrightcoveDataSource,NielsenBrightcoveDelegate>
{
    IBOutlet UITableView *m_tblView;
    IBOutlet UILabel *m_lblCurrentVideoName;
    IBOutlet UILabel *m_lblCurrentChannelName;
    IBOutlet UIImageView *m_imgBrandIcon;
    IBOutlet UIButton *m_btnClose;
    IBOutlet UIView *m_viewTitle;
    
    NSString *m_strCurrentVideoID;
    NSString *m_strPerkReward;
    BOOL m_bDisableSeek;
    BOOL m_bLongform;
    BOOL m_bIsForLongform;
    BCOVPUIControlLayout *customLayoutWSeek;
    BCOVPUIControlLayout *customLayoutWithSeek;
    int m_nAutoplay;
    int m_nCurrentCount;
    int m_nVideoPlayingIndex;
    
    UIBarButtonItem *btnCloseCarrot;
    UIBarButtonItem *btnCloseRound;
    
   // BOOL m_bNoInternet;
    
    IBOutlet UIView *m_viewAYSWLongform;
    IBOutlet UIView *m_viewBlurredAYSW;
    IBOutlet UIButton *m_btnAYSWExit;
    IBOutlet UIButton *m_btnSYSWContinue;
    BOOL m_bIsViewActive;
    BOOL m_bIsFastForwarded;
    int m_nfastforward_limit_pct;
    int m_nlongform_complete_pct;
    int m_naysw_prompt_seconds;
    int m_naysw_no_response_minutes;
    NSString *m_strCurrentImage;
    
    //
    
    IBOutlet UIView *m_viewPosterView;
    IBOutlet UIImageView *m_imgPoster;
    
    BOOL m_bIsPointAwarded;
    int m_nPercentCurrent;
    int m_nPercentAwarded;
    BOOL m_b_start_video;
    
    ///
    IBOutlet UIView *m_viewResumePlayback;
    IBOutlet UIView *m_viewBlurredRP;
    IBOutlet UIButton *m_btnRPResume;
    IBOutlet UIButton *m_btnRPStartBeginning;
    CMTime m_cmTime;
    id<BCOVPlaybackSession> m_session;
    long long m_nCurrentPosition;
    long long m_nSavedPosition;
    BOOL m_bIsAdFree;
    BOOL m_bIsPaused;
    
    BOOL m_bIsLoading;
    int m_nOffset;
    int m_nLimit;
    
    NSMutableArray *m_arrVideos;
    NSDictionary *m_dictCurrentVideo;
    
}
@property (nonatomic, strong) BCOVPlaybackService *service;
@property (nonatomic, strong) id<BCOVPlaybackController> playbackControllerFW;
@property (nonatomic, strong) id<BCOVPlaybackController> playbackControllerNoAd;
@property (nonatomic) BCOVPUIPlayerView *playerView;

@property (nonatomic,strong) NielsenBrightcovePlugin *brightcovePlugin;
@end

@implementation PlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    m_nOffset = 0;
    m_nLimit = 50;
    m_bIsLoading = NO;
    [JLManager sharedManager].m_bIsVideoLooping = TRUE;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
   
    // Do any additional setup after loading the view from its nib.
    m_nAutoplay = 0;
    m_nCurrentCount = 0;
    m_nVideoPlayingIndex = 0;
    m_bIsFastForwarded = false;
    m_nfastforward_limit_pct = 0;
    m_naysw_prompt_seconds = 0;
    m_naysw_no_response_minutes = 0;
    
    m_tblView.backgroundView = nil;
   
    btnCloseCarrot =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"carrot_down"] style:UIBarButtonItemStylePlain target:self action:@selector(btnCloseClicked)];
    //self.navigationItem.leftBarButtonItem = btnCloseCarrot;
    
    self.navigationController.navigationBarHidden = FALSE;
    m_btnClose.hidden = TRUE;
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.contenthub"];
    ///
    m_arrVideos = [NSMutableArray arrayWithArray:self.m_arrPlaylistVideos];
    m_dictCurrentVideo = [self getDictForCurrentIndex];
    
    BOOL bLongform = FALSE;
    NSString *content_provider = @"Undefined";
    NSString *program = @"Undefined";
    NSDictionary *custom_fields = [m_dictCurrentVideo objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            program = show;
        }
    }
    m_bIsForLongform = bLongform;
    if (bLongform) {
        [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
        
    }
    else{
        [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
        
    }
    NSString *episode_title = [NSString stringWithFormat:@"%@",[m_dictCurrentVideo objectForKey:@"name"]];
    [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
    [dictTrackingData setObject:program forKey:@"tve.program"];
    [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
    ///
    [dictTrackingData setObject:@"Portrait" forKey:@"tve.contentmode"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Video Player" data:dictTrackingData];
    
    [self callAPIForGetSettings];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopVideo)
                                                 name:kStopVideoNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActiveNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveVideoPosition)
                                                name:kSaveVideoNotification
                                                                 object:nil];
    
    [self initAYSWLongform];
    
}
-(void)applicationWillResignActiveNotification{
    if(self->m_bLongform){
        [self saveLongformPositionAndCallAPI];
    }
    [self pauseVideo];
}
-(void)applicationDidBecomeActiveNotification{
    if(!m_bIsPaused)[self playVideo];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    m_bIsViewActive = TRUE;
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    if(!m_bIsPaused)[self playVideo];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
//    if(_playerView){
//        [_playerView.controlsView.options
//    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self->m_bLongform){
        [self saveLongformPositionAndCallAPI];
    }
    m_bIsViewActive = FALSE;
    [self pauseVideo];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {

    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.contenthub"];
    ///
    //NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    BOOL bLongform = FALSE;
    NSString *content_provider = @"Undefined";
    NSString *program = @"Undefined";
    NSDictionary *custom_fields = [m_dictCurrentVideo objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            program = show;
        }
    }
    if (bLongform) {
        [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
    }
    else{
        [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
    }
    NSString *episode_title = [NSString stringWithFormat:@"%@",[m_dictCurrentVideo objectForKey:@"name"]];
    [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
    [dictTrackingData setObject:program forKey:@"tve.program"];
    [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
    ///
    ////////
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationUnknown:
        {
            //load the portrait view
            self.navigationController.navigationBarHidden = FALSE;
            m_btnClose.hidden = TRUE;
            CGRect f = self.view.bounds;
            self.videoContainer.frame = CGRectMake(0, 0, f.size.width, 216);
//            m_btnClose.frame = CGRectMake(0, 10, 41, 41);
//            [m_btnClose setImage:[UIImage imageNamed:@"carrot_down"] forState:UIControlStateNormal];
//
            [self.playerView.controlsView.screenModeButton showPrimaryTitle:TRUE];
            [dictTrackingData setObject:@"Portrait" forKey:@"tve.contentmode"];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
            m_btnClose.hidden = FALSE;
            self.navigationController.navigationBarHidden = TRUE;
            
            CGRect f = self.view.bounds;
            self.videoContainer.frame = f;
            
            if([UIScreen mainScreen].nativeBounds.size.height >= 2436){
                // if iphoneX or iphoneXS, iphoneXSMAx
                m_btnClose.frame = CGRectMake(self.view.bounds.size.width-105,5 , 41, 41);
            }else{
                m_btnClose.frame = CGRectMake(self.view.bounds.size.width-55,5 , 41, 41);
            }
            [m_btnClose setImage:[UIImage imageNamed:@"close-icon"] forState:UIControlStateNormal];
            [self.playerView.controlsView.screenModeButton showPrimaryTitle:FALSE];
            [dictTrackingData setObject:@"Landscape" forKey:@"tve.contentmode"];
        }
            break;
        
    }
    
    
    [[JLTrackers sharedTracker] trackAdobeStates:@"Video Player" data:dictTrackingData];
    
    
    //////
   [self performSelectorOnMainThread:@selector(updateLayout) withObject:nil waitUntilDone:YES];
    /////
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSDictionary *)getDictForCurrentIndex
{
    NSArray *aryVideos = m_arrVideos;
    if (aryVideos != nil && [aryVideos isKindOfClass:[NSArray class]] && aryVideos.count > 0) {
        if (self.m_nCurrentIndex < [aryVideos count] ) {
            return [aryVideos objectAtIndex:self.m_nCurrentIndex];
        }
        else{
            self.m_nCurrentIndex = 0;
            return [aryVideos objectAtIndex:self.m_nCurrentIndex];
        }
    }
    else{
        return [NSMutableDictionary new];
    }
    
}


-(void)callAPIForAwardPoints:(int)percent isForStart:(BOOL)isForStart{
    if (m_bIsPointAwarded && !m_bLongform) {
        return;
    }
    if (m_bLongform && m_nPercentAwarded == percent && !isForStart) {
        return;
    }
    
    if (percent >= 100 || (m_bLongform && percent >=90)) {
        [[JLTrackers sharedTracker] trackAppsFlyerRetentionEvent:@"app_open_video_complete"];
    }
    if (percent >= 100 || (m_bLongform && m_nlongform_complete_pct > 0 && percent >=m_nlongform_complete_pct) ) {
       if (!m_bIsFastForwarded)
        {
            [[JLManager sharedManager] setUserVideoWatched:m_strCurrentVideoID];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserWatchedVideoNotification object:m_strCurrentVideoID];
            if (m_bLongform) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserWatchedLongformVideoNotification object:m_strCurrentVideoID];
            }
        }
        
    }
    
    if(!isForStart)m_bIsPointAwarded = TRUE;
    /*NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    if (dictCurrentVideo != nil && [dictCurrentVideo isKindOfClass:[NSDictionary class]]) {
        
        NSArray *tags = [dictCurrentVideo objectForKey:@"tags"];
        if (tags != nil && [tags isKindOfClass:[NSArray class]]) {
            BOOL removeIt = [tags containsObject:@"redemption_partner"];
            if (removeIt) {
                return;
            }
        }
    }*/
    
    if (![PerkoAuth IsUserLogin]) {
        //[self.view makeToast:@"Log in to Watchback to earn points!" duration:1.0 position:@"top"];
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.verticalPadding = 30;
//        [self.view makeToast:@"Log in to Watchback to earn Thank You Points!" duration:1.0 position:CSToastPositionTop style:style];
        return;
    }
    
    NSString *strFastforward = [NSString stringWithFormat:@"%d",m_bIsFastForwarded];
    m_nPercentAwarded = percent;
    NSDictionary *dictBody =
    @{ @"access_token":[PerkoAuth getPerkUser].accessToken,@"video_id":m_strCurrentVideoID,@"perk_reward":m_strPerkReward,@"ad_filled":@"false",@"fastforward":strFastforward,@"percent":[NSString stringWithFormat:@"%d",percent]};
    JLPerkUser *user = [PerkoAuth getPerkUser];
    if(kDebugLog)NSLog(@"%@",user.userId);
    if (kDebugLog)NSLog(@"Award Points -> %@",dictBody);
    [[WebServices sharedManager] callAPIJSON:VIEW_VIDEO_URL params:dictBody httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        if (success) {
            @try {
                if(dict!=nil){
                    [[JLManager sharedManager] updateVideoView:dict];
                    if([PerkoAuth IsUserLogin]){
                        if([dict valueForKey:@"data"]==nil ||
                           [dict valueForKey:@"data"]==[NSNull null]){
                            return;
                        }
                        
                        if(dict != nil)
                        {
                            int nPoints = 0;
                            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                                NSString * message = [dict valueForKey:@"message"];
                                if (message != nil && [message isKindOfClass:[NSString class]] && message.length > 0) {
                                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                                    style.verticalPadding = 30;
                                    [self.view makeToast:message duration:4.0 position:CSToastPositionTop style:style];
                                }
                                
                                NSDictionary *dictData = [dict objectForKey:@"data"];
                                if (dictData != nil && [dictData isKindOfClass:[NSDictionary class]]) {
                                    if ([dictData valueForKey:@"point_type"] != nil) {
                                        NSString *point_type = [dictData objectForKey:@"point_type"];
                                        if ([point_type isKindOfClass:[NSString class]] && point_type.length > 0) {
                                            [[JLTrackers sharedTracker] trackLeanplumEvent:point_type param:nil];
                                        }
//                                        if ([point_type isEqualToString:@"daily bonus"]) {
//                                            [[JLTrackers sharedTracker] trackLeanplumEvent:@"earned_daily_bonus" param:nil];
//                                        }
                                    }
                                    nPoints = [[NSString stringWithFormat:@"%@",[dictData objectForKey:@"points_awarded"]] intValue];
                                    
                                    if(nPoints > 0)
                                    {                                        
                                        ////////////
                                        NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                                        [dictTrackingData setObject:@"true" forKey:@"tve.points"];
                                        
                                        [dictTrackingData setObject:@"Event:Points Accrued" forKey:@"tve.userpath"];
                                        
                                        ///
                                        NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
                                        BOOL bLongform = FALSE;
                                        NSString *content_provider = @"Undefined";
                                        NSString *program = @"Undefined";
                                        NSDictionary *custom_fields = [dictCurrentVideo objectForKey:@"custom_fields"];
                                        if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
                                            NSString *longform = [custom_fields objectForKey:@"longform"];
                                            if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
                                                bLongform = [longform boolValue];
                                            }
                                            NSString *provider = [custom_fields objectForKey:@"provider"];
                                            if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
                                                content_provider = provider;
                                            }
                                            NSString *show = [custom_fields objectForKey:@"show"];
                                            if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
                                                program = show;
                                            }
                                        }
                                        if (bLongform) {
                                            [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
                                        }
                                        else{
                                            [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
                                        }
                                        NSString *episode_title = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"name"]];
                                        [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
                                        [dictTrackingData setObject:program forKey:@"tve.program"];
                                        [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
                                        ///
                                        [dictTrackingData setObject:[NSString stringWithFormat:@"%d",nPoints] forKey:@"tve.rewardsvalue"];
                                        [dictTrackingData setObject:@"Video Player" forKey:@"tve.title"];
                                        [dictTrackingData setObject:@"Video Player" forKey:@"tve.contenthub"];
                                        
                                        [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Points Accrued" data:dictTrackingData];
                                        ////////
                                        
                                        
                                        NSNumber * points_balance = [dictData valueForKey:@"points_balance"];
                                        
                                        if (points_balance != nil && ![points_balance isEqual:[NSNull null]]) {
                                            
                                            //NSString * currentPoints = [NSString stringWithFormat:@"%0.0f",[points_balance doubleValue]] ;
                                            JLPerkUser * user = [PerkoAuth getPerkUser];
                                            
                                            user.perkPoint.availableperks = points_balance;
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:perkUserKey];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                        }
                                        ////
                                    }
                                }
                            }
                        }
                    }
                }else{
                }
            }
            @catch (NSException *exception) {
            }
        }
    }];
}

#pragma mark --Brightcove
- (void)requestContentFromPlaybackService:(NSString *)strVideoId
{
    if (![[self getPlaybackController:m_bIsAdFree] isAutoPlay] ) {
        [self getPlaybackController:m_bIsAdFree].autoPlay = TRUE;
    }
    [self.service findVideoWithVideoID:strVideoId parameters:nil completion:^(BCOVVideo *video, NSDictionary *jsonResponse, NSError *error) {
        
        if (video)
        {
            [self.brightcovePlugin onChangedVideo:[self getDictForCurrentIndex]];
            [[self getPlaybackController:self->m_bIsAdFree] setVideos:@[ video ]];
            if(kDebugLog)NSLog(@"%@",video.properties);
        }
        else
        {
            if ([[JLManager sharedManager] isInternetConnected]) {
                self.m_nCurrentIndex++;
                self.m_bIsFeaturedContent = FALSE;
                [self performSelector:@selector(checkForAutoPlayAndStartVideo) withObject:nil afterDelay:1.0];
            }
            else{
               [self btnCloseClicked];
            }
            
            if(kDebugLog)NSLog(@"ViewController Debug - Error retrieving video: `%@`", error);
            
            ////////////
            NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
            [dictTrackingData setObject:@"true" forKey:@"tve.error"];
            [dictTrackingData setObject:@"Error" forKey:@"tve.userpath"];
            [dictTrackingData setObject:@"Error" forKey:@"tve.title"];
            [dictTrackingData setObject:@"Error" forKey:@"tve.contenthub"];
            [dictTrackingData setObject:[NSString stringWithFormat:@"%@",[error localizedDescription]] forKey:@"tve.error"];
            [[JLTrackers sharedTracker] trackAdobeStates:@"Error" data:dictTrackingData];
            ////////
            
            [self.brightcovePlugin onError:[NSString stringWithFormat:@"%@",[error localizedDescription]]];
        }
        
    }];
    
}

- (id<BCOVPlaybackController>) getPlaybackController:(BOOL)bIsAdFree {
    
    id<BCOVPlaybackController> playbackController = nil;
    if (bIsAdFree) {
        playbackController = self.playbackControllerNoAd;
    }
    else{
        playbackController = self.playbackControllerFW;
    }
    
    
    if (_service == nil) {
        _service = [[BCOVPlaybackService alloc] initWithAccountId:kViewControllerAccountID policyKey:kViewControllerPlaybackServicePolicyKey];
    }
    ////
    // Nielsen Brightcove Plugin Setup
    if ( self.brightcovePlugin == nil) {
        self.brightcovePlugin = [[NielsenBrightcovePlugin alloc] init];
        self.brightcovePlugin.dataSource = self;
        self.brightcovePlugin.delegate = self;
        
    }
    if (playbackController == nil) {
        BCOVPlayerSDKManager *manager = [BCOVPlayerSDKManager sharedManager];
        //if (bIsAdFree)
        {
            playbackController = self.playbackControllerNoAd = [manager createSidecarSubtitlesPlaybackControllerWithViewStrategy:nil];
        }
//        else{
//            playbackController = self.playbackControllerFW  = [manager createFWPlaybackControllerWithAdContextPolicy:[self adContextPolicy] viewStrategy:nil];
//        }
        playbackController.analytics.account = kViewControllerAccountID;
        //_playbackController.delegate = self;
        playbackController.autoAdvance = YES;
        playbackController.autoPlay = YES;
        [playbackController setAllowsExternalPlayback:YES];
         [playbackController addSessionConsumer:self.brightcovePlugin];
        
        
        
    }
    playbackController.delegate = self.brightcovePlugin;
    if (_playerView == nil) {
        BCOVPUIPlayerViewOptions *options = [[BCOVPUIPlayerViewOptions alloc] init];
        options.presentingViewController = self;
        options.hideControlsInterval = 3;
        
        // Create and configure Control View
        BCOVPUIBasicControlView *controlsView = [BCOVPUIBasicControlView basicControlViewWithVODLayout];
        BCOVPUIPlayerView *playerView = [[BCOVPUIPlayerView alloc] initWithPlaybackController:playbackController options:options controlsView:controlsView ];
        [_videoContainer addSubview:playerView];
        _playerView = playerView;
        //////
    }
    [_playerView setPlaybackController:playbackController];
    _playerView.delegate = self;
    _playerView.frame = _videoContainer.bounds;
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (customLayoutWithSeek == nil || customLayoutWSeek == nil) {
        //////////////
        BCOVPUILayoutView *playbackLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagButtonPlayback                   width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        //   BCOVPUILayoutView *jumpBackButtonLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagButtonJumpBack width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *currentTimeLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagLabelCurrentTime width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *timeSeparatorLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagLabelTimeSeparator width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *durationLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagLabelDuration      width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *progressLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagSliderProgress width:kBCOVPUILayoutUseDefaultValue elasticity:1.0];
        BCOVPUILayoutView *closedCaptionLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagButtonClosedCaption width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *screenModeLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagButtonScreenMode width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        
        BCOVPUILayoutView *externalRouteLayoutView = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagViewExternalRoute width:kBCOVPUILayoutUseDefaultValue elasticity:0.0];
        BCOVPUILayoutView *spacerLayoutView1 = [BCOVPUIBasicControlView layoutViewWithControlFromTag:BCOVPUIViewTagViewEmpty width:1.0 elasticity:1.0];
        NSArray *compactLayoutLineWSeek = @[playbackLayoutView, currentTimeLayoutView,timeSeparatorLayoutView, durationLayoutView,spacerLayoutView1, closedCaptionLayoutView, externalRouteLayoutView,screenModeLayoutView ];
        NSArray *compactLayoutLineWithSeek = @[playbackLayoutView, currentTimeLayoutView, progressLayoutView, durationLayoutView, closedCaptionLayoutView,externalRouteLayoutView,screenModeLayoutView ];
        
        NSArray *standardLayoutLinesWSeek =  @[  compactLayoutLineWSeek ];
        NSArray *standardLayoutLinesWithSeek =  @[  compactLayoutLineWithSeek ];
        
        customLayoutWSeek = [[BCOVPUIControlLayout alloc] initWithStandardControls:standardLayoutLinesWSeek compactControls:standardLayoutLinesWSeek];
        
        
        float fWidth = [[UIScreen mainScreen] bounds].size.width;
        if (fWidth > 350) {
            customLayoutWithSeek = [[BCOVPUIControlLayout alloc] initWithStandardControls:standardLayoutLinesWithSeek compactControls:standardLayoutLinesWithSeek];
        }
        else{
            NSArray *compactLayoutLine1 = @[ currentTimeLayoutView, progressLayoutView, durationLayoutView ];
            NSArray *compactLayoutLine2 = @[ playbackLayoutView, spacerLayoutView1,closedCaptionLayoutView, externalRouteLayoutView, screenModeLayoutView];
            NSArray *compactLayoutLinesWithSeek =  @[ compactLayoutLine1, compactLayoutLine2 ];
            customLayoutWithSeek = [[BCOVPUIControlLayout alloc] initWithStandardControls:standardLayoutLinesWithSeek compactControls:compactLayoutLinesWithSeek];
        }
    }
    if (bIsAdFree) {
        self.playbackControllerNoAd = playbackController ;
    }
    else{
        self.playbackControllerFW = playbackController;
    }
    [self updatePlayerController];
   
    return playbackController;
}
- (void)handleButtonTap:(UIButton *)button{

    
    UIInterfaceOrientation currentOrientation =  [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight){
        //[self.playerView.controlsView.screenModeButton showPrimaryTitle:TRUE];
        
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        if(kDebugLog)NSLog(@"landscape left");

       // [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    }
    else{ //if (currentOrientation == UIInterfaceOrientationPortrait){
      //  [self.playerView.controlsView.screenModeButton showPrimaryTitle:FALSE];
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        if(kDebugLog)NSLog(@"portrait");
       // [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        
    }
}
#pragma mark -- brightcove
#pragma mark BCOVPlaybackControllerDelegate Methods


- (void)playbackController:(id<BCOVPlaybackController>)controller didCompletePlaylist:(id<NSFastEnumeration>)playlist{
//-(void)didCompletePlaylist{
    [[JLTrackers sharedTracker] trackFBEvent:VideoCompleteEvent params:nil];
    
    PlayerVideoCell * cellPlayerVideoCell = [m_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_nVideoPlayingIndex inSection:0]];
    if (cellPlayerVideoCell) {
        cellPlayerVideoCell.m_viewPlayingNow.hidden = TRUE;
        cellPlayerVideoCell.m_lblTime.hidden = FALSE;
    }
    NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    NSString *strCurrentVideoId = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"id"]];
   // [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"video_complete" withValues:nil];
    
    if(m_bLongform){
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"longform_complete" param:@{@"videoid":strCurrentVideoId}];
        [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"complete_longform_video" withValues:@{}];
        [[JLTrackers sharedTracker] trackSingularEvent:@"complete_longform_video"];
        [[JLTrackers sharedTracker] trackFBEvent:@"complete_longform_video" params:nil];
        [[JLTrackers sharedTracker] trackFBEvent:LongformVideoCompleteEvent params:nil];
        //////
        NSString *strUserUUID = @"";
        if ([PerkoAuth IsUserLogin]){
            strUserUUID = [PerkoAuth getPerkUser].userUUID;
        }
       
      
        [[LFCache sharedManager] remove:m_strCurrentVideoID];
        
        ////
    }
    else{
        if (!m_bIsFastForwarded) {
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"complete_shortform_video" withValues:@{}];
        }
        [[JLTrackers sharedTracker] trackFBEvent:ShortformVideoCompleteEvent params:nil];
        [[JLTrackers sharedTracker] trackSingularEvent:@"complete_shortform_video"];
        [[JLTrackers sharedTracker] trackFBEvent:@"complete_shortform_video" params:nil];
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"shortform_complete"  param:@{@"videoid":strCurrentVideoId}];
        
        
    }
    
    if(kDebugLog)NSLog(@"ViewController Debug - didCompletePlaylist");
    
    [self showCountDownScreen];
    
    
   
}

#pragma mark --
-(void)showCountDownScreen
{
    [self stopVideo];
    [self callAPIForAwardPoints:100 isForStart:false];
     self.m_nCurrentIndex++;
    self.m_bIsFeaturedContent = FALSE;
    [self performSelector:@selector(checkForAutoPlayAndStartVideo) withObject:nil afterDelay:1.0];
    
}
-(IBAction)btnDownArrowClicked:(id)sender{
    if ([sender isSelected]) {
        [sender setSelected:FALSE];
        self.m_bIsBar = FALSE;
        [[JLManager sharedManager] updatePlayerBarLayout];
        
    }
    else{
        [sender setSelected:TRUE];
        self.m_bIsBar = TRUE;
        [[JLManager sharedManager] updatePlayerBarLayout];
    }
    
}


#pragma mark --Tableview
#pragma mark --table view delegate
#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_arrVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //////
    NSDictionary *tempDict = [m_arrVideos objectAtIndex:indexPath.row];
    //////
    
    NSString *CellIdentifier =[NSString stringWithFormat:@"CellPlayerVideoCell%@",[tempDict objectForKey:@"id"]];
    PlayerVideoCell * cellPlayerVideoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cellPlayerVideoCell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"PlayerVideoCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cellPlayerVideoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cellPlayerVideoCell.backgroundColor = [UIColor clearColor];
    cellPlayerVideoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    
    return cellPlayerVideoCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerVideoCell *cellPlayerVideoCell = (PlayerVideoCell *)cell;
    
    //////
    //////
    NSDictionary *dict = [m_arrVideos objectAtIndex:indexPath.row];
    [cellPlayerVideoCell setData:dict];
    
    //////
    NSString *strTitle = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    NSString *content_provider = @"";
    NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
    }
    
    if(!self.m_bIsNotFromChannel && !m_bIsForLongform){
        [cellPlayerVideoCell setTitle:strTitle subTitle:content_provider];
    }
    else{
        [cellPlayerVideoCell setTitle:strTitle subTitle:@""];
    }
    
    /////
    cellPlayerVideoCell.m_viewPlayingNow.hidden =!(indexPath.row == m_nVideoPlayingIndex);
    cellPlayerVideoCell.m_lblTime.hidden = (indexPath.row == m_nVideoPlayingIndex);
    ////
    // Check scrolled percentage
    CGFloat yOffset = tableView.contentOffset.y;
    CGFloat height = tableView.contentSize.height - tableView.frame.size.height;
    CGFloat scrolledPercentage = yOffset / height;
    // Check if all the conditions are met to allow loading the next page
    //
    if (scrolledPercentage > .6f && !m_bIsLoading)
    {
        [self callAPIForGetVidesByKeyword:^(NSArray *arr) {
            if (arr.count > 0) {
                [self->m_arrVideos addObjectsFromArray:arr];
                [self->m_tblView reloadData];
                //self->m_bIsLoading = NO;
            }
        }];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    NSString *strCurrentVideoId = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"id"]];
    //////
    int nIndex = (int) indexPath.row;
    if (m_arrVideos != nil && [m_arrVideos isKindOfClass:[NSArray class]] && m_arrVideos.count > 0) {
        if (nIndex < [m_arrVideos count] ) {
            NSDictionary *dictNew = [m_arrVideos objectAtIndex:nIndex];
            NSString *strNewVideoID = [NSString stringWithFormat:@"%@",[dictNew objectForKey:@"id"]];
            if ([strCurrentVideoId isEqualToString:strNewVideoID]) {
                return;
            }
        }
    }
    
    /////
    if(self->m_bLongform){
        [self saveLongformPositionAndCallAPI];
    }
    
    [self pauseVideo];
    [self stopVideo];
    m_bIsPaused = TRUE;
    [self removeResumePlayback];
   // NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    //NSString *strCurrentVideoId = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"id"]];
    if(m_bLongform){
        //[self saveLongformPositionAndCallAPI];
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"longform_exit" param:@{@"videoid":strCurrentVideoId}];
    }
    else{
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"shortform_exit"  param:@{@"videoid":strCurrentVideoId}];
    }
    m_nCurrentCount = 0;
    self.m_nCurrentIndex =(int) indexPath.row;
    self.m_bIsFeaturedContent = FALSE;
    [self checkForAutoPlayAndStartVideo];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    
    [dictTrackingData setObject:@"Click:Video" forKey:@"tve.userpath"];
    
    ///
    //NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    BOOL bLongform = FALSE;
    NSString *content_provider = @"Undefined";
    NSString *program = @"Undefined";
    NSDictionary *custom_fields = [dictCurrentVideo objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            program = show;
        }
    }
    if (bLongform) {
        [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
    }
    else{
        [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
    }
    NSString *episode_title = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"name"]];
    [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
    [dictTrackingData setObject:program forKey:@"tve.program"];
    [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
    ///
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Video Player" forKey:@"tve.contenthub"];
   
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Video" data:dictTrackingData];
    ////////
    
    
    
}
-(IBAction)btnCloseClicked{
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    if(kDebugLog)NSLog(@"btnCloseClicked");
    NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    NSString *strCurrentVideoId = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"id"]];
    if(self->m_bLongform){
        [self saveLongformPositionAndCallAPI];
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"longform_exit" param:@{@"videoid":strCurrentVideoId}];
    }
    else{
        [[JLTrackers sharedTracker] trackLeanplumEvent:@"shortform_exit"  param:@{@"videoid":strCurrentVideoId}];
    }
    [self pauseVideo];
    [self stopVideo];
    
    if (self.brightcovePlugin) {
        [self.brightcovePlugin onDestroy];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self dismissViewControllerAnimated:YES completion:^{
        [JLManager sharedManager].m_bIsVideoLooping = FALSE;
        if (![[JLManager sharedManager] isInternetConnected]) {
            [[JLManager sharedManager] performSelector:@selector(showNetworkError) withObject:nil afterDelay:1];
        }
    }];
    
}
/*- (void)onRendererEvent:(NSNotification *)notification {
   // if(kDebugLog)NSLog(@"%@", notification);
    NSString *eventName = [[notification userInfo] objectForKey:FWInfoKeyAdEventName];
    if(kDebugLog)NSLog(@"FWAdManager onRendererEvent -> %@", eventName);
    m_slot = [[notification userInfo] objectForKey:FWInfoKeySlot];
    if ([eventName isEqualToString:FWAdImpressionEvent]) {
        m_bAdFilled = YES;
        if (!m_bIsViewActive) {
            if (m_slot) {
                if (kDebugLog)NSLog(@"onRendererEvent2");
                [m_slot pause];
            }
        }
        [self showCloseButton];
    }
}*/


-(void)updatePlayerController{
    
    _playerView.controlsView.layout = m_bDisableSeek? customLayoutWSeek : customLayoutWithSeek;    
    [_playerView.controlsView setNeedsLayout];
     [self.playerView.controlsView.screenModeButton addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)callAPIForGetSettings{
    
    [[JLManager sharedManager] showLoadingView:self.view];
    [[JLManager sharedManager] getAppSettings:^(NSDictionary *dict) {
        [[JLManager sharedManager] hideLoadingView];
        self->m_nAutoplay = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"autoplay"]] intValue];
        self->m_nfastforward_limit_pct =[[NSString stringWithFormat:@"%@",[dict objectForKey:@"fastforward_limit_pct"]] intValue];
        self->m_naysw_prompt_seconds = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"aysw_prompt_seconds"]] intValue];
        self->m_naysw_no_response_minutes = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"aysw_no_response_minutes"]] intValue];
        self->m_nlongform_complete_pct = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"longform_complete_pct"]] intValue];
        
        [self performSelectorOnMainThread:@selector(checkForAutoPlayAndStartVideo) withObject:nil waitUntilDone:YES];
        
    }];
}
-(void)callAPIForGetVidesByKeyword:(void (^) (NSArray *arr))handler{
    if (m_bIsLoading || !self.m_bIsFeaturedContent) return;
    m_bIsLoading = YES;
    NSString *uuid = [m_dictCurrentVideo objectForKey:@"uuid"];
    if (uuid == nil || ![uuid isKindOfClass:[NSString class]]) {
         handler([NSArray new]);
        return;
    }
    NSString *strURL =[NSString stringWithFormat:@"%@/%@",GET_RELATE_VIDEOS_URL,uuid];
    NSString *params = [NSString stringWithFormat:@"limit=%d&offset=%d",m_nLimit, m_nOffset];
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO  handler:^(BOOL success, NSDictionary *dict) {
        if(kDebugLog)NSLog(@"%@",dict);
        NSArray *arr ;
        if (success) {
            
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data =[dict objectForKey:@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]]) {
                    arr =[data objectForKey:@"related"];
                }
            }
            
        }
        if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
            arr = [NSArray new];
        }
        if (arr.count > 0) {
            self->m_bIsLoading = NO;
        }
        handler(arr);
    }];
    
    m_nOffset = m_nOffset + m_nLimit;
}


-(void)initAYSWLongform{
   // m_viewAYSWLongform.hidden = TRUE;
    m_viewAYSWLongform.backgroundColor = [UIColor clearColor];
    m_btnSYSWContinue.backgroundColor = kCommonColor;
    m_btnSYSWContinue.layer.cornerRadius = 8;
    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        m_viewBlurredAYSW.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //blurEffectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.30];
        //always fill the view
        blurEffectView.frame = m_viewBlurredAYSW.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [m_viewBlurredAYSW addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
    } else {
        m_viewBlurredAYSW.backgroundColor = [UIColor blackColor];
    }
}

-(void)removeAYSW{
    if (m_viewAYSWLongform) {
        [m_viewAYSWLongform removeFromSuperview];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnCloseClicked) object:nil];
    }
}
-(void)askForAYSWLongform{
    [self pauseVideo];
    m_bIsPaused = TRUE;
    //m_viewAYSWLongform.hidden = FALSE;
    m_viewAYSWLongform.frame = self.videoContainer.bounds;
    m_viewAYSWLongform.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.videoContainer addSubview:m_viewAYSWLongform];
    [self.videoContainer bringSubviewToFront:m_viewAYSWLongform];
    
    if (m_naysw_no_response_minutes > 0) {
        [self performSelector:@selector(btnCloseClicked) withObject:nil afterDelay:m_naysw_no_response_minutes * 60];
    }
    
}

-(IBAction)btnAYSWExitClick{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Are you sure you want to exit the video?"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOK = [UIAlertAction
                            actionWithTitle:@"Yes"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self btnCloseClicked];
                                
                            }];
    UIAlertAction* btnNo = [UIAlertAction
                            actionWithTitle:@"No"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self btnAYSWContinueClick];
                                
                            }];
    
    [alert addAction:btnOK];
    [alert addAction:btnNo];
    [self presentViewController:alert animated:YES completion:nil];
}
-(IBAction)btnAYSWContinueClick{
  //  m_viewAYSWLongform.hidden = TRUE;
    [m_viewAYSWLongform removeFromSuperview];
    [self playVideo];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnCloseClicked) object:nil];
}
#pragma mark -- Resume Playback

-(void)initResumePlayback{
    
    m_viewResumePlayback.backgroundColor = [UIColor clearColor];
    m_btnRPResume.backgroundColor = kCommonColor;
    m_btnRPResume.layer.cornerRadius = 8;
    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        m_viewBlurredRP.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.frame = m_viewBlurredRP.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [m_viewBlurredRP addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
    } else {
        m_viewBlurredRP.backgroundColor = [UIColor blackColor];
    }
}
-(void)removeResumePlayback{
    if (m_viewResumePlayback) {
        [m_viewResumePlayback removeFromSuperview];
    }
}
-(void)askForResumePlayback{
    [self removeResumePlayback];
    [self pauseVideo];
    m_bIsPaused = TRUE;
    m_viewResumePlayback.frame = self.videoContainer.bounds;
    m_viewResumePlayback.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.videoContainer addSubview:m_viewResumePlayback];
    [self.videoContainer bringSubviewToFront:m_viewResumePlayback];
    
//    if (m_naysw_no_response_minutes > 0) {
//        [self performSelector:@selector(btnCloseClicked) withObject:nil afterDelay:m_naysw_no_response_minutes * 60];
//    }
}
-(IBAction)btnRPResumeClicked{
    m_nSavedPosition = 0;
    [self removeResumePlayback];
    if (m_session) {
        [m_session.player seekToTime:m_cmTime completionHandler:^(BOOL finished) {
            //[self->m_session.player play];
            [self playVideo];
            self->m_bIsFastForwarded = FALSE;
        }];
    }
    
}
-(IBAction)btnRPStartBeginningClicked{
    m_nSavedPosition = 0;
    m_nCurrentPosition = 0;
    [[LFCache sharedManager] remove:m_strCurrentVideoID];
    [self removeResumePlayback];
    [self playVideo];
//    if (m_session) {
//        [m_session.player play];
//    }
    
}

#pragma mark NielsenBrightcoveDelegate
-(void)didVideoReady:(id<BCOVPlaybackSession>)session{
   
    m_session = session;
    if (m_bLongform) {
        if (m_nSavedPosition > 0) {
            if (!CMTIME_IS_INDEFINITE(session.player.currentItem.duration)) {
                if (m_nSavedPosition < CMTimeGetSeconds(session.player.currentItem.duration)) {
                    CMTime cmTime = CMTimeMakeWithSeconds(m_nSavedPosition, 1);
                    if(CMTIME_IS_VALID(cmTime)){
                        m_cmTime = cmTime;
                        m_session = session;
                        [self initResumePlayback];
                        [self askForResumePlayback];
                    }
                }
            }
        }
    }
}
-(void)didCompletePlaylist{
    
    [self playbackController:nil didCompletePlaylist:nil];
    
}
-(void)videoPlaying:(id<BCOVPlaybackSession>)session{
    if (kDebugLog)NSLog(@"videoPlaying");
    
    
    
    if (!m_bIsViewActive) {
        if (kDebugLog)NSLog(@"videoPlaying1");
        
        [self pauseVideo];
       
    }
    m_session = session;
}
-(void)videoPlay{
    ////////
    [[JLTrackers sharedTracker] trackFBEvent:VideoStartEvent params:nil];
   // [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"video_start" withValues:nil];
    
    PlayerVideoCell *cellPlayerVideoCell = [m_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.m_nCurrentIndex inSection:0]];
    if (cellPlayerVideoCell) {
        cellPlayerVideoCell.m_viewPlayingNow.hidden = FALSE;
        cellPlayerVideoCell.m_lblPlayingNow.text = @"PLAYING NOW";
        cellPlayerVideoCell.m_lblTime.hidden = TRUE;
        if (!m_b_start_video) {
            m_b_start_video = TRUE;
            
            if (m_bLongform) {
                [[JLTrackers sharedTracker] trackSingularEvent:@"start_longform_video"];
                [[JLTrackers sharedTracker] trackFBEvent:@"start_longform_video" params:nil];
                [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"start_longform_video" withValues:nil];
                [[JLTrackers sharedTracker] trackLeanplumEvent:@"longform_start"];
                [[JLTrackers sharedTracker] trackFBEvent:LongformVideoStartEvent params:nil];
                ///
            }
            else{
                [[JLTrackers sharedTracker] trackSingularEvent:@"start_shortform_video"];
                [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"start_shortform_video" withValues:nil];
                [[JLTrackers sharedTracker] trackFBEvent:@"start_shortform_video" params:nil];
                [[JLTrackers sharedTracker] trackLeanplumEvent:@"shortform_start"];
                [[JLTrackers sharedTracker] trackFBEvent:ShortformVideoStartEvent params:nil];
                
            }
            [self callAPIForAwardPoints:0 isForStart:true];
        }
        
    }
    ////////
    
    [self removeAYSW];
    [self hidePosterView];
    [self showCloseButton];
    [self scheduleAYSWTimer];
}
-(void)didProgressTo:(long long )previousContentPosition position:(long long) position duration:(long long)duration{
    if (position < 1) {
        return;
    }
    //if (m_nfastforward_limit_pct > 0 && duration > 0 && ((llabs(position-previousContentPosition))* 100 /duration) > m_nfastforward_limit_pct && !m_bDisableSeek) {
    if (m_nfastforward_limit_pct > 0 && duration > 0 && ((llabs(position-m_nCurrentPosition))* 100 /duration) > m_nfastforward_limit_pct && !m_bDisableSeek) {
        m_bIsFastForwarded = TRUE;
        [[JLTrackers sharedTracker] trackSingularEvent:@"fast_forward"];
    }
    
   /* if (m_nlongform_complete_pct > 0 && m_bLongform) {
        if(position * 100/duration > m_nlongform_complete_pct){
            [self callAPIForAwardPoints];
        }      
    }*/
   /* if (m_bLongform && m_nPercentCurrent > 0 && m_nPercentCurrent <= 100) {
        if(position * 100/duration > m_nPercentCurrent){
            [self callAPIForAwardPoints:m_nPercentCurrent];
            m_nPercentCurrent+=10;
        }
    }*/
    
    
    m_nCurrentPosition = position;
    if (duration > 0) {
        m_nPercentCurrent = (int)(position * 100/duration);
    }
    NSString *strUserUUID = @"";
    if ([PerkoAuth IsUserLogin]){
         strUserUUID = [PerkoAuth getPerkUser].userUUID;
    }
    
    
}
-(void)updateLayout{
    //////
     float fWidth = self.view.frame.size.width;
    
    //if (m_bLongform && m_strCurrentImage != nil && [m_strCurrentImage isKindOfClass:[NSString class]] && m_strCurrentImage.length > 0) {
    if ( m_strCurrentImage != nil && [m_strCurrentImage isKindOfClass:[NSString class]] && m_strCurrentImage.length > 0) {
        m_lblCurrentVideoName.frame = CGRectMake(15+52, 15, fWidth-30-40, 25);
        m_lblCurrentChannelName.frame = CGRectMake(15+52, 35, fWidth-30-40, 25);
        m_imgBrandIcon.hidden = FALSE;
    }
    else{
        m_lblCurrentVideoName.frame = CGRectMake(15, 15, fWidth-30, 25);
        m_lblCurrentChannelName.frame = CGRectMake(15, 35, fWidth-30, 25);
        m_imgBrandIcon.hidden = TRUE;
        
    }
    m_lblCurrentVideoName.font = [[JLManager sharedManager] getVideoLargeTitleFont];
    m_lblCurrentChannelName.font = [[JLManager sharedManager] getSubTitleFont];
    m_lblCurrentVideoName.numberOfLines = 0;
    m_lblCurrentVideoName.lineBreakMode = NSLineBreakByWordWrapping;
    [m_lblCurrentVideoName sizeToFit];    
    ///
    CGRect rectTitle = m_lblCurrentVideoName.frame;
    CGRect rectSubTitle = m_lblCurrentChannelName.frame;
   // if(kDebugLog)NSLog(@"Frame issue -> m_lblCurrentVideoName.frame ->%@",NSStringFromCGRect(rect));
    rectSubTitle.origin.y = CGRectGetMaxY(rectTitle);
    rectSubTitle.size.height = 25;
    m_lblCurrentChannelName.frame = rectSubTitle;
    [m_lblCurrentChannelName sizeToFit];
    rectSubTitle = m_lblCurrentChannelName.frame;
    //if(kDebugLog)NSLog(@"Frame issue -> m_lblCurrentChannelName.frame ->%@",NSStringFromCGRect(rect));
    CGRect titleViewFrame = m_viewTitle.frame;
    titleViewFrame.size.height = CGRectGetMaxY(rectSubTitle)+15;
    m_viewTitle.frame = titleViewFrame;
      
    CGRect rect = self.view.bounds;
    float fTop = CGRectGetMaxY(m_viewTitle.frame);
    m_tblView.frame = CGRectMake(0, fTop, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-fTop);
    
}
-(IBAction)btnVideoPlayClicked{
    [self loadAndPlayVideo];
    [self playVideo];
    [self hidePosterView];
    [self videoPlay];
}
-(void)hidePosterView{
    if (m_viewPosterView) {
        [m_viewPosterView removeFromSuperview];
    }
}
-(void)showPosterView{
    [self hidePosterView];
    [self showCloseButton];
    m_imgPoster.image = nil;
    m_viewPosterView.frame = self.videoContainer.bounds;
    m_viewPosterView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    m_viewPosterView.clipsToBounds = TRUE;
    [self.videoContainer addSubview:m_viewPosterView];
    [self.videoContainer bringSubviewToFront:m_viewPosterView];
    NSDictionary *dictCurrentVideo = [self getDictForCurrentIndex];
    NSString *strPoster = [dictCurrentVideo objectForKey:@"poster"];
    if (strPoster == nil || ![strPoster isKindOfClass:[NSString class]]) {
        NSDictionary *images = [dictCurrentVideo objectForKey:@"images"];
        if (images != nil && [images isKindOfClass:[NSDictionary class]]) {
            NSDictionary *poster = [images objectForKey:@"poster"];
            if (poster != nil && [poster isKindOfClass:[NSDictionary class]]) {
                strPoster = [poster objectForKey:@"src"];
            }
        }
    }
    
//    m_imgPoster.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strPoster]];
    [m_imgPoster sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",strPoster]] placeholderImage:nil];
    [self pauseVideo];
    m_bIsPaused = TRUE;
}
-(void)hideCloseButton{
    m_btnClose.alpha = 0;
    self.navigationItem.leftBarButtonItem = nil;
    
}
-(void)showCloseButton{
    m_btnClose.alpha = 1;
    self.navigationItem.leftBarButtonItem = btnCloseCarrot;
    
}
-(void)playVideo{
    if (m_session != nil && m_session.player != nil) {
        [m_session.player play];
        m_bIsPaused = FALSE;
        
    }
}
-(void)pauseVideo{
    if (m_session != nil && m_session.player != nil) {
        [m_session.player pause];
    }
}
-(void)stopVideo{
    id<BCOVPlaybackController> playbackController = [self getPlaybackController:m_bIsAdFree];
    if (playbackController != nil ) {
        [playbackController pause];
        [playbackController setVideos:@[]];
        
    }
//    if (_playerView) {
//        [_playerView setPlaybackController:nil];
//    }
    if (m_session != nil && m_session.player != nil) {
        [m_session.player pause];
        [m_session terminate];
        m_session = nil;
        
    }
}

-(void)saveVideoPosition{
    [[LFCache sharedManager] set:[NSString stringWithFormat:@"%@",m_strCurrentVideoID] value:[NSString stringWithFormat:@"%lld",m_nCurrentPosition]];
    [[LFCache sharedManager] saveData];
}

-(void)saveVideoPositionfromBeginning{
    [[LFCache sharedManager] set:[NSString stringWithFormat:@"%@",m_strCurrentVideoID] value:[NSString stringWithFormat:@"%lld",0]];
    [[LFCache sharedManager] saveData];
}


-(void)saveLongformPositionAndCallAPI{
    
    if (m_bLongform && m_nPercentCurrent > 0) {
        [self callAPIForAwardPoints:m_nPercentCurrent isForStart:false];
    }
    if(m_nCurrentPosition > 3){
        [self saveVideoPosition];
    }else{
        [self saveVideoPositionfromBeginning];
    }
}

-(void)checkForAutoPlayAndStartVideo{
    if (![[JLManager sharedManager] isInternetConnected]) {
        
        // [[JLManager sharedManager] performSelector:@selector(showNetworkError) withObject:nil afterDelay:2];
        
        [self btnCloseClicked];
        return;
    }
    m_nOffset = 0;
    m_bIsAdFree = TRUE;
    m_nCurrentPosition = 0;
    m_nSavedPosition = 0;
    m_nPercentCurrent = 0;
    m_nPercentAwarded = 0;
    m_b_start_video = FALSE;
    m_bIsPointAwarded = FALSE;
    m_nCurrentCount++;
    
    m_bIsFastForwarded = FALSE;
    m_nOffset = 0;
    m_nLimit = 50;
    m_bIsLoading = NO;
    [self removeAYSW];
    [self hidePosterView];
    m_dictCurrentVideo = [self getDictForCurrentIndex];
    NSString *strVideoId = [NSString stringWithFormat:@"%@",[m_dictCurrentVideo objectForKey:@"id"]];
    NSString *strVideoName = [NSString stringWithFormat:@"%@",[m_dictCurrentVideo objectForKey:@"name"]];
    NSDictionary *custom_fields = [m_dictCurrentVideo objectForKey:@"custom_fields"];
    if (self.m_bIsFeaturedContent) {
        //self.m_bIsFeaturedContent = FALSE;
        [self callAPIForGetVidesByKeyword:^(NSArray *arr) {
            if (arr != nil && [arr isKindOfClass:[NSArray class]] && arr.count > 0) {
                
                NSString *strCurrentVideoId = [NSString stringWithFormat:@"%@",[self->m_dictCurrentVideo objectForKey:@"id"]];
                NSMutableArray *arrMutable = [NSMutableArray arrayWithArray:arr];
                BOOL bFound = FALSE;
                for (int i = 0; i <arrMutable.count ; i++) {
                    NSDictionary *dictTemp = [arrMutable objectAtIndex:i];
                    NSString *strVideoId = [NSString stringWithFormat:@"%@",[dictTemp objectForKey:@"id"]];
                    if ([strCurrentVideoId isEqualToString:strVideoId]) {
                        bFound = TRUE;
                        self.m_nCurrentIndex = i;
                        break;
                    }
                }
                if (!bFound) {
                    [arrMutable insertObject:self->m_dictCurrentVideo atIndex:0];
                    self.m_nCurrentIndex = 0;
                    
                }
                self->m_arrVideos = arrMutable;
                self->m_nVideoPlayingIndex = self.m_nCurrentIndex;
                [self->m_tblView reloadData];
            }
        }];
    }
    
    m_strPerkReward = @"";
    m_strCurrentVideoID = strVideoId;
    m_bDisableSeek = false;
    BOOL bPrevLongform = m_bLongform;
    m_bLongform = false;
    NSString *content_provider = @"";
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *perk_reward = [custom_fields objectForKey:@"perk_reward"];
        if (perk_reward != nil && [perk_reward isKindOfClass:[NSString class]] && perk_reward.length > 0) {
            m_strPerkReward =perk_reward;
        }
        NSString *disable_seek = [custom_fields objectForKey:@"disable_seek"];
        if (disable_seek != nil && [disable_seek isKindOfClass:[NSString class]] && disable_seek.length > 0) {
            m_bDisableSeek = [disable_seek boolValue];
        }
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            m_bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
    }
    ////
    BOOL bPartnerVideos = FALSE;
    NSArray *tags = [m_dictCurrentVideo objectForKey:@"tags"];
    if (tags != nil && [tags isKindOfClass:[NSArray class]]) {
        bPartnerVideos = [tags containsObject:@"redemption_partner"];
    }
    NSString *economics = [[NSString stringWithFormat:@"%@",[m_dictCurrentVideo objectForKey:@"economics"]] lowercaseString];
    if(bPartnerVideos || m_bLongform || [economics isEqualToString:@"free"]){
        m_bIsAdFree = TRUE;
    }
    else{
        m_bIsAdFree = FALSE;
    }
    ////
    
    
    // cancel the above call (and any others on self)
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSString *image_url ;
    if([m_dictCurrentVideo valueForKey:@"channel"] != nil &&
       [m_dictCurrentVideo valueForKey:@"channel"] != [NSNull null]){
        if([[m_dictCurrentVideo valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"] != nil &&
           [[m_dictCurrentVideo valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"] != [NSNull null]){
            image_url = [[m_dictCurrentVideo valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"];
        }
    }
    
    m_strCurrentImage = image_url;
    ///////
    NSString *description = [m_dictCurrentVideo objectForKey:@"description"];
    if (description != nil && [description isKindOfClass:[NSString class]] && description.length > 0 && ![[description lowercaseString] isEqualToString:@"unknown"]) {
        m_lblCurrentChannelName.text = description;
    }
    else{
        if (self.m_strChannelName != nil && [self.m_strChannelName isKindOfClass:[NSString class]] && self.m_strChannelName.length > 0) {
            if ([[content_provider lowercaseString] isEqualToString:[self.m_strChannelName lowercaseString]]) {
                m_lblCurrentChannelName.text = self.m_strChannelName;
            }
            else{
                if (content_provider != nil && [content_provider isKindOfClass:[NSString class]] && content_provider.length > 0) {
                    m_lblCurrentChannelName.text = [NSString stringWithFormat:@"%@ - %@",content_provider,self.m_strChannelName];
                }
                else{
                    m_lblCurrentChannelName.text = self.m_strChannelName;
                }
                
            }
            
        }
        else{
            if (content_provider != nil && [content_provider isKindOfClass:[NSString class]] && content_provider.length > 0) {
                m_lblCurrentChannelName.text = [NSString stringWithFormat:@"%@",content_provider];
            }
        }
    }
    ///
    
    ////////
//    ///// schedule the selector
//    if (m_naysw_prompt_seconds > 0) {
//        [self performSelector:@selector(askForAYSWLongform) withObject:nil afterDelay:m_naysw_prompt_seconds];
//    }
    
    //if (m_bLongform)
    if (m_strCurrentImage && [m_strCurrentImage isKindOfClass:[NSString class]] && m_strCurrentImage.length > 0)         
    {
        
        
        m_imgBrandIcon.hidden = FALSE;
        m_imgBrandIcon.layer.cornerRadius = m_imgBrandIcon.frame.size.width / 2;
        m_imgBrandIcon.clipsToBounds = TRUE;
        
//        m_imgBrandIcon.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",m_strCurrentImage]];
        [m_imgBrandIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",m_strCurrentImage]] placeholderImage:nil];
        NSString *strUserUUID = @"";
        if ([PerkoAuth IsUserLogin]){
            strUserUUID = [PerkoAuth getPerkUser].userUUID;
        }
        
        ////
    }
    else{
        m_imgBrandIcon.hidden = TRUE;
    }
    NSString *strPosition = [[LFCache sharedManager] get:[NSString stringWithFormat:@"%@",m_strCurrentVideoID]];
    if(kDebugLog)NSLog(@"strPosition -> %@",strPosition);
    long long position = [strPosition longLongValue];
    m_nCurrentPosition = m_nSavedPosition =  position;

    //////
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.firstLineHeadIndent = 0.0f;
    style.headIndent = 0.0f;
    style.tailIndent = 0.0f;
    
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:strVideoName attributes:@{ NSParagraphStyleAttributeName : style}];
    m_lblCurrentVideoName.numberOfLines = 0;
    m_lblCurrentVideoName.attributedText = attrText;
    
    ///
    
    if (m_nAutoplay > 0 && m_nCurrentCount > m_nAutoplay) {
    // [self getPlaybackController:m_bIsAdFree].autoPlay = NO;
        m_bIsPaused = TRUE;
        m_nCurrentCount = 1;
        [self showPosterView];
     }
     else{
         //[self getPlaybackController:m_bIsAdFree].autoPlay = YES;
         m_bIsPaused = FALSE;
     }
     
     if (bPrevLongform) {
        // [self getPlaybackController:m_bIsAdFree].autoPlay = NO;
         m_bIsPaused = TRUE;
         [self showPosterView];
     }
    
    ///////
    if (!m_bIsPaused) {
        [self hideCloseButton];
    //    m_bIsPaused = FALSE;
    }
//    else{
//        m_bIsPaused = TRUE;
//    }
    
    [self updatePlayerController];
    
    ////////
    PlayerVideoCell * cellPlayerVideoCell = [m_tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_nVideoPlayingIndex inSection:0]];
    if (cellPlayerVideoCell) {
        cellPlayerVideoCell.m_viewPlayingNow.hidden = TRUE;
        cellPlayerVideoCell.m_lblTime.hidden = FALSE;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.m_nCurrentIndex inSection:0];
    if (indexPath) {
        [m_tblView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    }
    cellPlayerVideoCell = [m_tblView cellForRowAtIndexPath:indexPath];
    if (cellPlayerVideoCell) {
        cellPlayerVideoCell.m_viewPlayingNow.hidden = FALSE;
       
        if (!m_bIsPaused){
            cellPlayerVideoCell.m_lblPlayingNow.text = @"PLAYING NOW";
            cellPlayerVideoCell.m_lblTime.hidden = TRUE;
            if (!m_b_start_video) {
                m_b_start_video = TRUE;
                
                if (m_bLongform) {
                    [[JLTrackers sharedTracker] trackSingularEvent:@"start_longform_video"];
                    [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"start_longform_video" withValues:nil];
                    [[JLTrackers sharedTracker] trackFBEvent:@"start_longform_video" params:nil];
                    [[JLTrackers sharedTracker] trackLeanplumEvent:@"longform_start"];
                    [[JLTrackers sharedTracker] trackFBEvent:LongformVideoStartEvent params:nil];
                }
                else{
                    [[JLTrackers sharedTracker] trackSingularEvent:@"start_shortform_video"];
                    [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"start_shortform_video" withValues:nil];
                    [[JLTrackers sharedTracker] trackFBEvent:@"start_shortform_video" params:nil];
                    [[JLTrackers sharedTracker] trackLeanplumEvent:@"shortform_start"];
                    [[JLTrackers sharedTracker] trackFBEvent:ShortformVideoStartEvent params:nil];
                }
                [self callAPIForAwardPoints:0 isForStart:true];
            }
            
        }
        else{
            cellPlayerVideoCell.m_lblPlayingNow.text = @"WATCH NEXT";
            cellPlayerVideoCell.m_lblTime.hidden = FALSE;
        }
        
    }
    
    ////////
    
    
    //[self callAPIForAwardPoints:0 isForStart:true];
   
    
    m_nVideoPlayingIndex = self.m_nCurrentIndex;
    // self.m_nCurrentIndex++;
    
    [self performSelectorOnMainThread:@selector(updateLayout) withObject:nil waitUntilDone:YES];
    
    if (!m_bIsPaused) {
        [self performSelectorOnMainThread:@selector(loadAndPlayVideo) withObject:nil waitUntilDone:YES];
        //[self loadAndPlayVideo];
    }
}

-(void)loadAndPlayVideo{
     [self requestContentFromPlaybackService:m_strCurrentVideoID];
}
-(void)scheduleAYSWTimer{
    ///// schedule the selector
    if (kDebugLog)NSLog(@"scheduleAYSWTimer");
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(askForAYSWLongform) object:nil];
    if (m_naysw_prompt_seconds > 0) {
        [self performSelector:@selector(askForAYSWLongform) withObject:nil afterDelay:m_naysw_prompt_seconds];
    }
}
@end
