//
//  RewardsVC.m
//  Watchback
//
//  Created by Nilesh on 1/17/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "RewardsVC.h"
#import "JLManager.h"
#import <SDWebImage/SDWebImage.h>
#import "WebServices.h"
#import "PerkoAuth.h"
#import "RedeemWebVC.h"
#import "NavPortrait.h"
#import "NavBoth.h"
#import "UINavigationController+TransparentNavigationController.h"
#import "RedeemWebVC.h"
#import "LogoutVC.h"
@interface RewardsVC ()
{
   
    NSString *mPlacement;
    NSDictionary *m_dictData;
    
    LogoutVC *m_objLogoutVC;
    
    IBOutlet UIWebView *m_webViewSweep;
    UIRefreshControl *m_refreshControl;
    NSTimeInterval m_lastRefreshTime;
}
@end

@implementation RewardsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mPlacement = @"Sweeps Screen";
    
    ////
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserHeader) name:kResetHeaderNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kRefreshThankyouDataNotification object:nil];

    {
        ////////////
        NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
        [dictTrackingData setObject:@"Rewards" forKey:@"tve.userpath"];
        [dictTrackingData setObject:@"Rewards" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Rewards" forKey:@"tve.contenthub"];
        [dictTrackingData setObject:@"Rewards" forKey:@"tve.partnertype"];
        [dictTrackingData setObject:@"true" forKey:@"tve.rewardsbrowse"];
        [[JLTrackers sharedTracker] trackAdobeStates:@"Rewards" data:dictTrackingData];
        ////////
    }
    
    m_refreshControl = [[UIRefreshControl alloc]init];
    [m_refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
    [m_webViewSweep.scrollView addSubview:m_refreshControl];
    
    [self callAPIforGetData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    self.navigationController.navigationBarHidden = TRUE;
    
    // self.title = @"";
     [JLManager sharedManager].m_bIsTabbarVisible = TRUE;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}
-(void)viewWillDisappear:(BOOL)animated{
   
    [super viewWillDisappear:animated];
     [JLManager sharedManager].m_bIsTabbarVisible = FALSE;
    ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
    switch (currentTheme) {
        case DayMode:
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            break;
            
        default:
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            break;
    }
    
    [self.navigationController showNonTransparentNavigationBar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callAPIforGetData{

    if (![PerkoAuth IsUserLogin]) {
         [self loadWebView];
        return;
    }
    m_lastRefreshTime = [[NSDate date] timeIntervalSince1970];
    [[JLManager sharedManager] showLoadingView:self.view];
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",API_CAROUSELS,mPlacement] ;
    NSString *params = @"";
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if(kDebugLog)NSLog(@"%@",dict);
                if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    
                    dict = [dict objectForKey:@"carousel"];
                    if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                        NSArray *arr = [dict objectForKey:@"items"];
                        if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
                            if (arr.count > 0) {
                                self->m_dictData = [arr objectAtIndex:0];
                            }
                            if (self->m_dictData == nil || ![self->m_dictData isKindOfClass:[NSDictionary class]]) {
                                self->m_dictData = [NSDictionary new];
                            }
                        }
                    }                    
                }
            }
            //[self updateUI];
            [self loadWebView];
        }
         [[JLManager sharedManager] hideLoadingView];
        [self->m_refreshControl endRefreshing];
    }];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    // Your layout logic here
   
}
-(void)addLogoutView{
    [self removeLogoutView];
    m_objLogoutVC = [[LogoutVC alloc] initWithNibName:@"LogoutVC" bundle:nil];
    [self addChildViewController:m_objLogoutVC];
    m_objLogoutVC.view.frame = self.view.bounds;
    [self.view addSubview:m_objLogoutVC.view];
}
-(void)removeLogoutView{
    if (m_objLogoutVC) {
        [m_objLogoutVC removeFromParentViewController];
        [m_objLogoutVC.view removeFromSuperview];
        m_objLogoutVC = nil;
    }
}

-(void)setUserHeader{
    [self loadWebView];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)themeChanged{
    
    [self loadWebView];
    
}

-(void)loadWebView{
    
    if ([PerkoAuth IsUserLogin]) {
        [m_webViewSweep loadHTMLString:@"" baseURL:nil];
        NSString *strSweepHTMLNight = @"";
        NSString *strSweepHTMLDay = @"";
        if (m_dictData != nil && [m_dictData isKindOfClass:[NSDictionary class]]) {
            NSDictionary *fields = [m_dictData objectForKey:@"fields"];
            if (fields != nil && [fields isKindOfClass:[NSDictionary class]]) {
                strSweepHTMLNight = [fields objectForKey:@"txt1"];
                strSweepHTMLDay = [fields objectForKey:@"txt2"];
            }
        }
        
        [m_webViewSweep setBackgroundColor:[UIColor clearColor]];
        [m_webViewSweep setOpaque:NO];
        ThemeType currentTheme = [[JLManager sharedManager] getAppTheme];
        switch (currentTheme) {
            case DayMode:
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                [m_webViewSweep loadHTMLString:strSweepHTMLDay baseURL:nil];
                break;
                
            default:
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                [m_webViewSweep loadHTMLString:strSweepHTMLNight baseURL:nil];
                break;
        }
        
    }
    else{
        [self addLogoutView];
    }
    
}
-(void)pullDownToRefresh{
    [self callAPIforGetData];
}
#pragma mark -
#pragma mark UIWebview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@",request.URL.absoluteString];
    if([strUrl rangeOfString:@"http://"].location!=NSNotFound
       ||
       [strUrl rangeOfString:@"https://"].location!=NSNotFound
       ||
       [strUrl rangeOfString:@"www."].location != NSNotFound
       ){
        strUrl = [strUrl stringByRemovingPercentEncoding];
        NSString *accessToken = @"";
        if ([PerkoAuth IsUserLogin]) {
            accessToken = [PerkoAuth getPerkUser].accessToken;
        }
        [[JLTrackers sharedTracker] trackSingularEvent:@"visit_web_thanks"];
        [[JLTrackers sharedTracker] trackFBEvent:@"visit_web_thanks" params:nil];
        
        strUrl = [strUrl stringByReplacingOccurrencesOfString:@"{access_token}" withString:accessToken];
        if ([strUrl rangeOfString:@"safari=1"].location == NSNotFound) {
            RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
            NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
            nav.navigationBarHidden = FALSE;
            objRedeemWebVC.m_strUrl = request.URL.absoluteString;
            objRedeemWebVC.title = @"WatchBack";
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:nil];
        }
        
        
       
        return NO;
        
    }
    else if([strUrl rangeOfString:@"watchback://"].location != NSNotFound
       ){
        webView.delegate = nil;
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:nil];
        return NO;
        
    }
    return YES;
}
-(void)refreshData{
    [m_webViewSweep.scrollView setContentOffset:CGPointZero animated:NO];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fDiffrent = currentTime - m_lastRefreshTime;
    if(kDebugLog)NSLog(@"%f %f",currentTime, fDiffrent);
    if (fDiffrent > kAPICacheTime) {
        [self callAPIforGetData];
    }
    
    
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
@end
