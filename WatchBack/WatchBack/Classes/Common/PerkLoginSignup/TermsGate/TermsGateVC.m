//
//  TermsGateVC.m
//  Watchback
//
//  Created by Nilesh on 8/12/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "TermsGateVC.h"
#import "LoginVC.h"
#import "UITextField+Shake.h"
#import "PerkoAuth.h"


#import "Constants.h"
#import "JLManager.h"
#import "NavPortrait.h"
#import <SDWebImage/SDWebImage.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RedeemWebVC.h"
@interface TermsGateVC ()
{
    
    
    
    IBOutlet UIButton *m_btnContinue;
    IBOutlet UIScrollView *objscrollview;
    IBOutlet UILabel *m_lblTitle;
    IBOutlet UIWebView *m_webViewDisclaimer;
    
}
@end

@implementation TermsGateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kPrimaryBGColorNight;
    [self customizeScreenLayout];
    [self setDefaultDesclaimer];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   self.navigationController.navigationBarHidden = FALSE;
    self.title = @"AGREE TO TERMS & PRIVACY";

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}
-(void)viewDidAppear:(BOOL)animated{
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnAlreadyhaveperkAccountTabbed:(id)sender {
    
 
    
    NSArray *arrVC = self.navigationController.viewControllers;
    for (UIViewController *vc in arrVC){
        if ([vc isKindOfClass:[LoginVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    LoginVC *objLoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    objLoginVC.delegate = self.delegate;
    [self.navigationController pushViewController:objLoginVC animated:YES];

}

- (IBAction)btnContinueClicked {
    [self.view endEditing:YES];
    [self finished];
    
}

-(void)finished
{
    [[JLManager sharedManager] setObjectuserDefault:@"1" forKey:kTermsPrivacyAgreement];
    self.delegate(TRUE);
    [[JLTrackers sharedTracker] trackSingularEvent:@"skip_agree_terms"];
  //  [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"skip_agree_terms" withValues:nil];
    [[JLTrackers sharedTracker] trackFBEvent:@"skip_agree_terms" params:nil];
}


- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}


#pragma mark --
#pragma mark  custom methods
-(void)customizeScreenLayout{
   
    m_btnContinue.titleLabel.font = kFontBtn14;
    m_lblTitle.font = kFontPrimary20;
    
    objscrollview.contentSize = CGSizeMake(0, 700);
    
    m_btnContinue.layer.cornerRadius = 8;
    m_btnContinue.backgroundColor = kRedColor;
    m_btnContinue.alpha = 1.0;
    
    NSString *string = @"I AGREE";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 0.5f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [string length])];
    [m_btnContinue setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    ////
    
    
    
}



-(void)setBottomBorder :(id)sender color:(UIColor *)color{
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = color.CGColor;
    border.frame = CGRectMake(0, [sender frame].size.height - borderWidth, [sender frame].size.width, [sender frame].size.height);
    border.borderWidth = borderWidth;
    [[sender layer] addSublayer:border];
    [sender layer].masksToBounds = YES;
    
}
-(IBAction)btnVPPAClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kVPPA;
    objRedeemWebVC.title = @"VPPA";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(IBAction)btnTermsClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kTermsAndConditionsLink;
    objRedeemWebVC.title = @"Terms and Conditions";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(IBAction)btnPrivacyClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kPrivacyPolicy;
    objRedeemWebVC.title = @"Privacy Policy";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(void)setDefaultDesclaimer{
    NSString *str = @"<html><head><style type=\"text/css\">html, body {height: 100%;margin: 0;padding: 0;width: 100%;} html {display: table;} a{text-decoration:none; color:white;}  body { display: table-cell; vertical-align: middle;padding: 0px;text-align: center;-webkit-text-size-adjust: none; color:white;      font-family:\"SF Pro Display\";font-size: 10pt;}</style></head><body leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\">To continue, please agree to the <a href=\"terms://\"><b>Terms of Service</b></a>, <a href=\"privacy://\"><b>Privacy Policy</b></a>, and the <a href=\"vvp://\"><b>Video Viewing Policy</body></html>";
    [m_webViewDisclaimer setBackgroundColor:[UIColor clearColor]];
    [m_webViewDisclaimer setOpaque:NO];
    [m_webViewDisclaimer loadHTMLString:str baseURL:nil];
    m_webViewDisclaimer.scrollView.scrollEnabled = NO;
    m_webViewDisclaimer.scrollView.bounces = NO;
}
#pragma mark -
#pragma mark UIWebview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strUrl = request.URL.absoluteString;
    if([strUrl rangeOfString:@"terms://"].location!=NSNotFound){
        [self btnTermsClicked];
        return NO;
    }
    else if([strUrl rangeOfString:@"privacy://"].location!=NSNotFound){
        [self btnPrivacyClicked];
        return NO;
    }
    else if([strUrl rangeOfString:@"vvp://"].location!=NSNotFound){
        [self btnVPPAClicked];
        return NO;
    }
    return YES;
}
@end
