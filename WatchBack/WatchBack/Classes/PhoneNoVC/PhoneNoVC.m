//
//  PhoneNoVC.m
//  Watchback
//
//  Created by perk on 14/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "PhoneNoVC.h"
#import "Constants.h"
#import "JLManager.h"
#import "PerkoAuth.h"
#import "CodeVerificationVC.h"
#import "LFCache.h"

@interface PhoneNoVC (){
        
    __weak IBOutlet UIButton *btnContinue;
    __weak IBOutlet UITextField *txtPhoneNo;
    __weak IBOutlet UITextField *txtCountryCode;
}


@end

@implementation PhoneNoVC

#pragma mark-
#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customoizeNavigationBar];
    [self customizeScreenLayout];
    [self setDefaultParameters];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}

#pragma mark-
#pragma mark UITextField delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * phoneno = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(phoneno.length > 0){
        if(phoneno.length>10){
            return  NO;
        }
        btnContinue.enabled = YES;
        [btnContinue setBackgroundColor:[UIColor colorWithRed:255/255.0 green:0 blue:53/255.0 alpha:1]];
    }else{
        btnContinue.enabled = NO;
        [btnContinue setBackgroundColor:[UIColor colorWithRed:255/255.0 green:0 blue:53/255.0 alpha:0.5]];
        
        
    }
    return YES;
}

#pragma mark-
#pragma mark ibaction or custom methods

-(void)signupSuccessAlert
{
    [self loginSignupSuccessed];
    
}

-(void)loginSignupSuccessed
{
    [[JLManager sharedManager] setObjectuserDefault:@"1" forKey:kTermsPrivacyAgreement];
    
    
    [self finished];
    [[JLManager sharedManager] loginSignupSuccessed];
    
}

-(void)finished
{
    if ([self isModal]) {
        [[JLManager sharedManager] showLoadingView:self.view];
        [self dismissViewControllerAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[JLManager sharedManager] hideLoadingView];
                [[JLManager sharedManager] GoToVerificationCodeScreenwithPhoneNumber:self->txtPhoneNo.text];
            });
        }];
        [[JLManager sharedManager] hideLoadingView];
    }
    else{
        [[JLManager sharedManager] GoToVerificationCodeScreenwithPhoneNumber:txtPhoneNo.text];
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


-(void)emailSignup{
    [[JLManager sharedManager] showLoadingView:self.view];
    
    NSString *gender = @"";

    if([self.dict_signup_user_info valueForKey:@"gender"] != nil &&
       [self.dict_signup_user_info valueForKey:@"gender"] != [NSNull null]){
        if(![[[self.dict_signup_user_info valueForKey:@"gender"] lowercaseString] isEqualToString:@"prefer not to answer"]){
            if([[[self.dict_signup_user_info valueForKey:@"gender"] lowercaseString] isEqualToString:@"male"]){
                gender = @"m";
            }else if([[[self.dict_signup_user_info valueForKey:@"gender"] lowercaseString] isEqualToString:@"female"]){
                gender = @"f";
            }
        }
    }
    
    NSString * dob = @"";
    if([self.dict_signup_user_info valueForKey:@"dob"] != nil &&
       [self.dict_signup_user_info valueForKey:@"dob"] != [NSNull null]){
        dob = [[self.dict_signup_user_info valueForKey:@"dob"] lowercaseString];
    }
    
    
    [PerkoAuth singupWithEmail:[self.dict_signup_user_info valueForKey:@"email"] firstName:@"" lastName:@"" password:[self.dict_signup_user_info valueForKey:@"password"] gender:gender dob:dob  phoneno:[self.dict_signup_user_info valueForKey:@"phoneno"]  handler:^(BOOL success, NSDictionary *dict) {
        
        [[JLManager sharedManager] hideLoadingView];
        if (success) {
            // [[JLTrackers sharedTracker] trackEvent:@"user registered ios"];
            
            [self signupSuccessAlert];
            
            [[JLManager sharedManager] syncLocalFavoriteShowsToServer:^(BOOL success) {
                if(success){
                    [[JLManager sharedManager] clearAllLocalFavorites];
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kStopVideoNotification object:nil];
            
            [[LFCache sharedManager] resetData];
            [[JLManager sharedManager] setObjectuserDefault:@"0" forKey:kIsUserFacebookLogin];
            ////////////
            NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
            [dictTrackingData setObject:@"true" forKey:@"tve.registrationsuccess"];
            [dictTrackingData setObject:@"true" forKey:@"tve.userlogin"];
            [dictTrackingData setObject:@"Sign-Up:Email" forKey:@"tve.title"];
            [dictTrackingData setObject:@"Event:Email:Sign-Up Success" forKey:@"tve.userpath"];
            [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
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
            [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Email:Sign-Up Success" data:dictTrackingData];
            ////////
            
            [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"complete_registration" withValues:@{@"registration_method":@"email"}];
            [[JLTrackers sharedTracker] trackSingularEvent:@"complete_registration"];
            [[JLTrackers sharedTracker] trackFBEvent:@"complete_registration" params:nil];

        }
        else{
            NSString *message = @"";
            if (dict != nil) {
                
                message = [dict valueForKey:@"message"];
                if(message != nil && [message isKindOfClass:[NSString class]])
                {

                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@""
                                                     message:message
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* btnOK = [UIAlertAction
                                                actionWithTitle:@"Okay"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    
                                                }];
                        
                        [alert addAction:btnOK];
                        
                        [self presentViewController:alert animated:YES completion:nil];
                    
                }
                
            }
            ////////////
            NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
            [dictTrackingData setObject:@"true" forKey:@"tve.registrationerror"];
            [dictTrackingData setObject:[NSString stringWithFormat:@"%@",message] forKey:@"tve.error"];
            [dictTrackingData setObject:@"Sign-Up:Email" forKey:@"tve.title"];
            [dictTrackingData setObject:@"Event:Email:Sign-Up Error" forKey:@"tve.userpath"];
            [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
            [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Email:Sign-Up Error" data:dictTrackingData];
            ////////
            
        }
        
    }];
    
}

-(void)setDefaultParameters{
    txtCountryCode.text = @"US +1";
}
- (IBAction)btnContinueTabbed:(id)sender {
    if(txtPhoneNo.text.length == 10){
        [_dict_signup_user_info setValue:txtPhoneNo.text forKey:@"phoneno"];
        [self emailSignup];
    }else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Mobile number should be of exactly 10 digits."
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* btnOK = [UIAlertAction
                                actionWithTitle:@"OKAY"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                }];
        
        [alert addAction:btnOK];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)downKeyboard:(id)sender{
    [sender resignFirstResponder];
}
-(void)dismissnumberPad{
    [txtPhoneNo resignFirstResponder];
}

-(void)customizeScreenLayout{
    [self setBottomBorder:txtCountryCode color:[UIColor whiteColor]];
    [self setBottomBorder:txtPhoneNo color:[UIColor whiteColor]];
    btnContinue.enabled = NO;
    btnContinue.layer.cornerRadius = 8;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismissnumberPad)]
                            ];
    [numberToolbar sizeToFit];
    txtPhoneNo.inputAccessoryView = numberToolbar;
    
}

-(void)setBottomBorder :(id)sender color:(UIColor *)color{
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 3;
    border.borderColor = color.CGColor;
    border.frame = CGRectMake(0, [sender frame].size.height - borderWidth, [sender frame].size.width, [sender frame].size.height);
    border.borderWidth = borderWidth;
    [[sender layer] addSublayer:border];
    [sender layer].masksToBounds = YES;
    
}


-(void)customoizeNavigationBar{
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnClosedClicked)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    

        UILabel *lblnavigationtitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
        lblnavigationtitle.text = @"Enter Mobile Number";
        lblnavigationtitle.backgroundColor = [UIColor clearColor];
        lblnavigationtitle.textAlignment = NSTextAlignmentCenter;
        lblnavigationtitle.textColor = [UIColor whiteColor];
        lblnavigationtitle.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:20];
        
        self.navigationItem.titleView = lblnavigationtitle;


}

-(void)btnClosedClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
