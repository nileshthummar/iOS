//
//  RedeemWebVCViewController.m
//  Perk Wallet
//
//  Created by Nilesh on 3/12/14.
//  Copyright (c) 2014 Nilesh. All rights reserved.
//

#import "RedeemWebVC.h"
#import "JLManager.h"

#import "NSMutableURLRequest+Additions.h"
#import "Constants.h"
#import "PerkoAuth.h"
#import "WebViewJavascriptBridge.h"
#import "NSURL+QueryString.h"
#define kBtnMarkUsedTag 48493

@interface RedeemWebVC ()<UIWebViewDelegate>
@property WebViewJavascriptBridge* bridge;
@end

@implementation RedeemWebVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark view life cycle methods
- (void)viewDidLoad{
    [super viewDidLoad];
  // if (_bridge) { return; }
    [self setupBridge];
    _objwebview.scalesPageToFit = YES;    
    //NSMutableURLRequest * req = [NSMutableURLRequest defaultRequestWithURL:self.m_strUrl param:@"" httpMethod:@"GET"];
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [PerkoAuth getPerkUser].accessToken;
    }
    self.m_strUrl = [self.m_strUrl stringByReplacingOccurrencesOfString:@"{access_token}" withString:accessToken];
    
    if([self.m_strUrl rangeOfString:@"watchback://"].location != NSNotFound
       || [self.m_strUrl rangeOfString:@"safari=1"].location != NSNotFound
       ){
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.m_strUrl] options:@{} completionHandler:nil];
        }];
    }
    else{
        
        NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:self.m_strUrl] URLByAppendingQueryString:QueryParameter]];
        [_objwebview loadRequest:req];
        
    }
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"carrot_down"] style:UIBarButtonItemStylePlain target:self action:@selector(btnClosedClicked)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    
}
-(void)btnClosedClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _objwebview.delegate = nil;
    self.navigationItem.rightBarButtonItem = nil;
   
    [[self.navigationController.navigationBar viewWithTag:kBtnMarkUsedTag] removeFromSuperview];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark --webview delegate
#pragma mark -
#pragma mark UIWebview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(kDebugLog)NSLog(@"============ %s ====================== %@ ", __FUNCTION__, request);
    
    if(kDebugLog)NSLog(@"request == %@",request.description);
    
    //Update device-info
    
    if([self.m_strUrl rangeOfString:@"watchback.com"].location != NSNotFound){
        NSString * jsCallBack = [NSString stringWithFormat:@"window.iosDeviceInfo= '%@'",GetPerkAPIDeviceInfo ()];
        [_objwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
        
    }
    

    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [_loadingIndicator startAnimating];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [_loadingIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //if (!webView.isLoading){    }
    [_loadingIndicator stopAnimating];
}
- (void)webView:(UIWebView *)sender windowScriptObjectAvailable:(id)windowScriptObject{
    
}


#pragma mark --Javascript
-(void)setupBridge{
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_objwebview];
    [_bridge setWebViewDelegate:self];
    
    
    //close webview callback
    [_bridge registerHandler:@"ioscloseWebview" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback closewebview called: %@", data);
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSDK"
                                                                object:self
                                                              userInfo:nil];
            
        }];
        responseCallback(@"Response from closewebview");
    }];
    
    // plastik callback
    [_bridge registerHandler:@"iosorderPerkPlastik" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback iosorderPerkPlastik called: %@", data);
        //plastik callback action
        NSString *strbundleId = [[NSBundle mainBundle] bundleIdentifier];
        if ([strbundleId isEqualToString:@"com.jutera.perkwallet"] || [strbundleId isEqualToString:@"net.functionxinc.oda-ota"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenWallet"
                                                                object:self
                                                              userInfo:nil];
            
        }
        else{
            
            
            NSString *customURL = @"perkwallet://";
            
            if ([[UIApplication sharedApplication]
                 canOpenURL:[NSURL URLWithString:customURL]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL] options:@{} completionHandler:nil];
                
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/perk-wallet/id891044525?mt=8"] options:@{} completionHandler:nil];
            }
            
        }
        
        
        responseCallback(@"Response from iosorderPerkPlastik");
    }];
    
    // points update callback
    [_bridge registerHandler:@"iosonPointsUpdated" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary * userInfo = [data objectForKey:@"points"];
        if(kDebugLog)NSLog(@"userInfo: %@",userInfo);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRRV2Points" object:nil userInfo:userInfo];
        /*
         2016-10-05 12:55:28.059 Rewards_2_5[42773:3046276] WVJB RCVD: {
         "callbackId" : "cb_2_1475652328058",
         "handlerName" : "iosonPointsUpdated",
         "data" : {
         "points" : 6544
         }
         }
         */
        if(kDebugLog)NSLog(@"ObjcCallback iosonPointsUpdated called: %@", data);
        responseCallback(@"Response from iosonPointsUpdated");
    }];
    
    // openLink callback
    [_bridge registerHandler:@"iosopenLinkExt" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback iosopenLinkExt called: %@", data);
        
        
        //Native openLink
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *strLink = [data objectForKey:@"linkName"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strLink] options:@{} completionHandler:nil];
        }
        
        responseCallback(@"Response from iosopenLinkExt");
    }];
    
    // Alert callback
    [_bridge registerHandler:@"iosshowDialog" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback iosshowDialog called: %@", data);
        //Native Alert
        if ([data isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *strTitle = [data objectForKey:@"title"];
                NSString *strDescription = [data objectForKey:@"description"];
                NSString *strButtonText = [data objectForKey:@"buttonText"];
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strDescription delegate:nil cancelButtonTitle:strButtonText otherButtonTitles:nil];
                //[alert show];
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:strTitle
                                             message:strDescription
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* btnOK = [UIAlertAction
                                        actionWithTitle:strButtonText
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                        }];
                
                [alert addAction:btnOK];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            });
        }
        responseCallback(@"Response from iosshowDialog");
    }];
    
    [_bridge registerHandler:@"onPartnersUpdated" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback onPartnersUpdated called: %@", data);
//     data   {
//            partnerName = "Boys & Girls Club of America";
//            rewardPrice = 10;
//        }
        if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
            NSString *partnerName = [NSString stringWithFormat:@"%@",[data objectForKey:@"partnerName"]];
            NSString *rewardPrice = [NSString stringWithFormat:@"%@",[data objectForKey:@"rewardPrice"]];
//            if ([partnerName isEqualToString:@"Boys & Girls Club of America"]) {
//
//            }
//            else{
//
//            }
            if ([self.title isEqualToString:@"Donate"]) {
                [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"donate_points" withValues:@{@"partner_name":partnerName}];
               // [[JLTrackers sharedTracker] trackSingularEvent:@"donate_points"];
                ////////////
                NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                [dictTrackingData setObject:@"Donations:Checkout:Complete" forKey:@"tve.userpath"];
                [dictTrackingData setObject:@"Donations:Checkout:Complete" forKey:@"tve.title"];
                [dictTrackingData setObject:@"Donations" forKey:@"tve.contenthub"];
                [dictTrackingData setObject:@"Donations" forKey:@"tve.partnertype"];
                [dictTrackingData setObject:@"true" forKey:@"tve.rewardsconfirmation"];
                [dictTrackingData setObject:partnerName forKey:@"tve.partner"];
                [dictTrackingData setObject:rewardPrice forKey:@"tve.redemptionvalue"];
                [[JLTrackers sharedTracker] trackAdobeStates:@"Donations:Checkout:Complete" data:dictTrackingData];
                ////////
            }
            else{
                [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"redeem_gift_card" withValues:@{@"partner_name":partnerName}];
                
                ////////////
                NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                [dictTrackingData setObject:@"Rewards:Checkout:Complete" forKey:@"tve.userpath"];
                [dictTrackingData setObject:@"Rewards:Checkout:Complete" forKey:@"tve.title"];
                [dictTrackingData setObject:@"Rewards" forKey:@"tve.contenthub"];
                [dictTrackingData setObject:@"Rewards" forKey:@"tve.partnertype"];
                [dictTrackingData setObject:@"true" forKey:@"tve.rewardsconfirmation"];
                [dictTrackingData setObject:partnerName forKey:@"tve.partner"];
                [dictTrackingData setObject:rewardPrice forKey:@"tve.redemptionvalue"];
                [[JLTrackers sharedTracker] trackAdobeStates:@"Rewards:Checkout:Complete" data:dictTrackingData];
                ////////
                
            }
            
            
        }
        
        responseCallback(@"Response from onPartnersUpdated");
        [[JLManager sharedManager] getUserInfo:^(BOOL successUserInfo) {
            
        }];
    }];
    [_bridge registerHandler:@"onWebViewLog" handler:^(id data, WVJBResponseCallback responseCallback) {
        if(kDebugLog)NSLog(@"ObjcCallback onWebViewLog called: %@", data);
        
        responseCallback(@"Response from onWebViewLog");
    }];

}
@end
