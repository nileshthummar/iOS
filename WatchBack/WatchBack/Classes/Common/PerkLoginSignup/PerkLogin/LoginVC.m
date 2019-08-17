//
//  LoginVC.m
//  Watchback
//
//  Created by Nilesh on 8/12/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "LoginVC.h"
#import "RedeemWebVC.h"
#import "UITextField+Shake.h"
#import "PerkoAuth.h"
#import "NavPortrait.h"
#import "Constants.h"
#import "JLManager.h"
#import "SignUpWithEmailVC.h"
#import "UIView+Toast.h"
#import "LFCache.h"

@interface LoginVC ()
{
    IBOutlet UITextField *m_txtPassword;
    IBOutlet UITextField *m_txtEmail;
    IBOutlet UIButton *m_btnLogin;
    UIButton *m_btnPasswordShow;
    IBOutlet UIScrollView *m_scrollView;
}
@end

@implementation LoginVC

#pragma mark-
#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kPrimaryBGColorNight;
    [self customizeNavigationBar];
    [self customizeScreenLayout];

    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.loginstart"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Log-In" data:dictTrackingData];
    
    //NSLog(@"Available fonts: %@", [UIFont familyNames]);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;



}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-
#pragma mark uitextfield delegagte methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strEmail = m_txtEmail.text;
    NSString *strPassword = m_txtPassword.text;
    if (m_txtEmail == textField) {
        strEmail = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else if(m_txtPassword == textField) {
        strPassword = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
   /* m_btnLogin.alpha = 0.3;
    if(![PerkoAuth inValidateEmail:strEmail]){
        if(strPassword.length > 5){
            m_btnLogin.alpha = 1;
        }
    }*/
    if(strEmail.length > 0 && strPassword.length >0){
        [m_btnLogin setBackgroundColor:kRedColor];
    }else{
        [m_btnLogin setBackgroundColor:kRedColorDisabled];
    }
    return YES;
}
 
#pragma mark --TextFiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == m_txtEmail) {
        [m_txtEmail resignFirstResponder];
        [m_txtPassword becomeFirstResponder];
    }
    else if(textField == m_txtPassword)
    {
        [self btnLoginwithEmailTabbed:nil];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setCorrectEmailPasswordDisclaimer];
}
-(IBAction)switchMarketingValueChanged{
    
}

#pragma mark-
#pragma mark ibaction or custom methods
-(void)btnClosedClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)customizeNavigationBar{
    UILabel *lblnavigationtitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    lblnavigationtitle.text = @"Log in";
    lblnavigationtitle.backgroundColor = [UIColor clearColor];
    lblnavigationtitle.textAlignment = NSTextAlignmentCenter;
    lblnavigationtitle.textColor = [UIColor whiteColor];
    lblnavigationtitle.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:20];
    
    self.navigationItem.titleView = lblnavigationtitle;
    
}
-(void)customizeScreenLayout{
    m_btnLogin.layer.cornerRadius =  8;
    if ([m_txtEmail respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: kCommonColor}];
        m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: kCommonColor}];
    }
    m_btnLogin.backgroundColor = kRedColorDisabled;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBottomBorder:self->m_txtEmail color:kCommonColor];
        [self setBottomBorder:self->m_txtPassword color:kCommonColor];        
    });
    
    
    m_txtEmail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    m_txtEmail.leftViewMode = UITextFieldViewModeAlways;
    
    m_txtPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    m_txtPassword.leftViewMode = UITextFieldViewModeAlways;
    
    ////
    
    NSString *string = @"Log In";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 0.5f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [string length])];
    [m_btnLogin setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    
    m_btnPasswordShow = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 14)];
    m_btnPasswordShow.contentMode = UIViewContentModeScaleAspectFit;
    [m_btnPasswordShow setImage:[UIImage imageNamed:@"show-icon-off"] forState:UIControlStateNormal];
    [m_btnPasswordShow setImage:[UIImage imageNamed:@"show-icon-off"] forState:UIControlStateSelected];
    [m_btnPasswordShow addTarget:self action:@selector(passwordShowClicked:) forControlEvents:UIControlEventTouchUpInside];
    m_txtPassword.rightView = m_btnPasswordShow;
    m_txtPassword.rightViewMode = UITextFieldViewModeAlways;
    
    
}
-(void)passwordShowClicked:(id)sender{
    if ([sender isSelected]) {
        [sender setSelected:FALSE];
        m_txtPassword.secureTextEntry = TRUE;
    }
    else{
        [sender setSelected:TRUE];
        m_txtPassword.secureTextEntry = FALSE;
    }
    NSString *tmpString = m_txtPassword.text;
    m_txtPassword.text = @" ";
    m_txtPassword.text = tmpString;
    
}
- (IBAction)downKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)btnSignedUpTabbed:(id)sender {
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Sign-Up with Email" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Sign-Up with Email" data:dictTrackingData];
    ////////
    
    
    NSArray *arrVC = self.navigationController.viewControllers;
    for (UIViewController *vc in arrVC){
        if ([vc isKindOfClass:[SignUpWithEmailVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    
    SignUpWithEmailVC *objSignUpWithEmailVC = [[SignUpWithEmailVC alloc] initWithNibName:@"SignUpWithEmailVC" bundle:nil];
    objSignUpWithEmailVC.delegate = self.delegate;
    [self.navigationController pushViewController:objSignUpWithEmailVC animated:YES];
    
}
- (IBAction)btnForgotPasswordTabbed:(id)sender {
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc] initWithNibName:@"RedeemWebVC" bundle:nil];
    
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl=kForgotPasswordLink;
    objRedeemWebVC.title = @"Forgot Password";
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)btnLoginwithEmailTabbed:(id)sender {
    [m_txtEmail resignFirstResponder];
    [m_txtPassword resignFirstResponder];
    if([PerkoAuth inValidateEmail:m_txtEmail.text]){
     
        [self setWrongEmail];
        NSString *errorMessage = @"Invalid email";
        [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:1.0 position:CSToastPositionCenter title:errorMessage image:nil style:nil completion:nil];
        return;
    }
    if([m_txtPassword.text length]==0){
        [self setWrongPassword];
        return;
    }
    [self emailLogin];

    
}
-(void)emailLogin{
    
    [[JLManager sharedManager] showLoadingView:self.view];
    
    [PerkoAuth loginWithEmail:m_txtEmail.text password:m_txtPassword.text passwordcheck:false handler:^(BOOL success, NSDictionary *dict) {
        [[JLManager sharedManager] hideLoadingView];
        if (success) {
            
            [self loginSignupSuccessed];
            [[JLManager sharedManager] setObjectuserDefault:@"0" forKey:kIsUserFacebookLogin];
            [[JLManager sharedManager] syncLocalFavoriteShowsToServer:^(BOOL success) {
                if(success){
                    [[JLManager sharedManager] clearAllLocalFavorites];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kStopVideoNotification object:nil];
            
            [[LFCache sharedManager] resetData];

            ////////////
            NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
            [dictTrackingData setObject:@"true" forKey:@"tve.loginsuccess"];
            [dictTrackingData setObject:@"true" forKey:@"tve.userlogin"];
            [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
            [dictTrackingData setObject:@"Event:Email:Log-In Success" forKey:@"tve.userpath"];
            [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
            ////
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
            [dictTrackingData setObject:@"Email" forKey:@"tve.registrationtype"];
            
            ////
            [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Email:Log-In Success" data:dictTrackingData];
            ////////
           
        }
        else{
            NSString *message = @"";
            if (dict != nil) {
                message = [dict valueForKey:@"message"];
            }
            ////////////
            NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
            [dictTrackingData setObject:@"true" forKey:@"tve.loginerror"];
            [dictTrackingData setObject:@"Email" forKey:@"tve.registrationtype"];
            [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
            [dictTrackingData setObject:@"Event:Email:Log-In Error" forKey:@"tve.userpath"];
            [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
            [dictTrackingData setObject:[NSString stringWithFormat:@"%@",message] forKey:@"tve.error"];
            [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Email:Log-In Error" data:dictTrackingData];
            ////////
        }
    }];
}
/*
-(void)fbLogin{
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Continue with Facebook" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Continue with Facebook" data:dictTrackingData];
    ////////
    
    [[JLManager sharedManager] openFBSessionwithUserAction:NO topController:self handler:^(BOOL success, NSString *strFBToken, NSString *strFBUserID,NSString *strError) {
        if (success) {
            //[self signupUserwithFacebookwithAccessToken:strFBToken fbuserid:strFBUserID];
            [[JLManager sharedManager] showLoadingView:self.view];
            [PerkoAuth loginWithFB:strFBToken handler:^(BOOL success, NSDictionary *dict) {
                [[JLManager sharedManager] hideLoadingView];
                if (success) {
                    // [[JLTrackers sharedTracker] trackEvent:@"registered"];
                    
                    [self loginSignupSuccessed];
                    [[JLManager sharedManager] setObjectuserDefault:@"1" forKey:kIsUserFacebookLogin];
                    
                    
                    ////////////
                    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                    [dictTrackingData setObject:@"true" forKey:@"tve.loginsuccess"];
                    [dictTrackingData setObject:@"true" forKey:@"tve.userlogin"];
                    [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
                    [dictTrackingData setObject:@"Event:Facebook:Log-In Success" forKey:@"tve.userpath"];
                    [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
                    ////
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
                    [dictTrackingData setObject:@"Facebook" forKey:@"tve.registrationtype"];
                    
                    ////
                    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Facebook:Log-In Success" data:dictTrackingData];
                    ////////
                    
                    
                }
                else{
                    ////////////
                    NSString *strErrorLocal = strError;
                    if (strErrorLocal == nil) {
                        strErrorLocal = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
                    }
                    
                    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                    [dictTrackingData setObject:@"true" forKey:@"tve.loginerror"];
                    [dictTrackingData setObject:strErrorLocal forKey:@"tve.error"];
                    [dictTrackingData setObject:@"Log-In" forKey:@"tve.title"];
                    [dictTrackingData setObject:@"Event:Facebook:Log-In Error" forKey:@"tve.userpath"];
                    [dictTrackingData setObject:@"Facebook" forKey:@"tve.registrationtype"];
                    [dictTrackingData setObject:@"Log-In" forKey:@"tve.contenthub"];
                    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Facebook:Log-In Error" data:dictTrackingData];
                    ////////
                }
            }];
        }
        
    }];
}
*/

-(void)loginSignupSuccessed
{
    [[JLTrackers sharedTracker] trackSingularEvent:@"log_in"];
    [[JLTrackers sharedTracker] trackFBEvent:@"log_in" params:nil];
    [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"log_in" withValues:nil];

    [self finished];
    [[JLManager sharedManager] loginSignupSuccessed];
}
-(void)finished
{
    if ([self isModal]) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
        
    }
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


-(void)clearEmailClicked:(id)sender
{
    if (m_txtEmail.tag == 9) {
        m_txtEmail.text = @"";
    }
}
-(void)clearPasswordClicked:(id)sender
{
    m_txtPassword.text = @"";
}

-(void)setWrongEmail
{
    [m_txtEmail shake:10   // 10 times
            withDelta:5    // 5 points wide
                speed:0.03 // 30ms per shake
     ];
    m_txtEmail.textColor  = kRedColor;
    [self setBottomBorder:m_txtEmail color:kRedColor];
    m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: kRedColor}];
    
}
-(void)setWrongPassword
{
    [m_txtPassword shake:10   // 10 times
               withDelta:5    // 5 points wide
                   speed:0.03 // 30ms per shake
     ];
    m_txtPassword.textColor  = kRedColor;
    [self setBottomBorder:m_txtPassword color:kRedColor];
    
    m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: kRedColor}];
}
-(void)setCorrectEmailPasswordDisclaimer
{
    m_txtEmail.textColor  = [UIColor whiteColor];
    m_txtPassword.textColor  = [UIColor whiteColor];
    [self setBottomBorder:m_txtEmail color:kCommonColor];
    [self setBottomBorder:m_txtPassword color:kCommonColor];
    m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: kCommonColor}];
    m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: kCommonColor}];
    

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

@end
