//
//  SignUpWithEmailVC.m
//  Watchback
//
//  Created by Nilesh on 8/12/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "SignUpWithEmailVC.h"
#import "RedeemWebVC.h"
#import "LoginVC.h"
#import "UITextField+Shake.h"
#import "PerkoAuth.h"
#import "Constants.h"
#import "JLManager.h"
#import "NavPortrait.h"
#import <SDWebImage/SDWebImage.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "PhoneNoVC.h"
#import "CodeVerificationVC.h"

@interface SignUpWithEmailVC ()
{
    IBOutlet UITextField *m_txtEmail;
    IBOutlet UITextField *m_txtPassword;
    IBOutlet UITextField *m_txtRepeatPassword;
    __weak IBOutlet UILabel *lblRepeatPassword;
    IBOutlet UIButton *m_btnGender;
    IBOutlet UIButton *m_btnDateOfBirth;
    IBOutlet UIButton *m_btnRegisterAccount;

    
    IBOutlet UIPickerView *objGenderpicker;
    IBOutlet UIDatePicker * objDOBPicker;
    
    IBOutlet UIView *viewGenderPicker;
    IBOutlet UIView *viewDOBPicker;
    
    NSArray *m_arrGender;
    
    IBOutlet UIScrollView *objscrollview;
    
    BOOL m_bIsGender;
    
    
    UIButton *m_btnPasswordShow;
    IBOutlet UIWebView *m_webViewDisclaimer;
    
    BOOL is_agreed;
    BOOL is_agreed_for_promotion;
    __weak IBOutlet UIButton *btnCheckbox;
    
    __weak IBOutlet UIButton *btnCheckbox2;
    NSString * user_dob;
    NSString * user_gender;
}
@end

@implementation SignUpWithEmailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kPrimaryBGColorNight;
    [self customizeNavigationBar];
    [self customizeScreenLayout];
    [self initGender];
   
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.registrationstart"];
    [dictTrackingData setObject:@"Email" forKey:@"tve.registrationtype"];
    [dictTrackingData setObject:@"Sign-Up:Email" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Sign-Up:Email" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Sign-Up:Email" data:dictTrackingData];
    ////////////
    
   // [self checkforLast24HoursAttempts];
    [self setDefaultDesclaimer];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;

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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark-
#pragma mark uitextfield delegagte methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *strEmail = m_txtEmail.text;
    NSString *strPassword = m_txtPassword.text;
    NSString *strRepeatPassword = m_txtRepeatPassword.text;
    
    if (m_txtEmail == textField) {
        strEmail = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else if(m_txtPassword == textField) {
        strPassword = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else if(m_txtRepeatPassword == textField) {
        strRepeatPassword = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self setCorrectEmailPassword];
    [self setBottomBorder:textField color:[UIColor whiteColor]];
    return TRUE;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString * strEmail = m_txtEmail.text;;
    
    if(![PerkoAuth inValidateEmail:strEmail]){
        NSString *strPassword = m_txtPassword.text;
        if (![PerkoAuth inValidatePassword:strPassword isSignup:TRUE]) {
//            if(  m_txtRepeatPassword.text.length > 0 && [m_txtPassword.text isEqualToString:m_txtRepeatPassword.text]){
//                m_btnRegisterAccount.alpha = 1;
//            }
        }
        else{
            if (textField == m_txtPassword) {
                [self setWrongPassword];
            }
        }
        
    }
    else{
        if (textField == m_txtEmail) {
            [self setWrongEmail];
        }
    }
    //return TRUE;
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
        [m_txtPassword resignFirstResponder];
        [m_txtRepeatPassword becomeFirstResponder];
    }
    return YES;
}
- (IBAction)btnAgreePromotionTabbed:(id)sender {
    is_agreed_for_promotion = ! is_agreed_for_promotion;
    
    UIImage * checkbox_image;
    if (is_agreed_for_promotion) {
        checkbox_image = [UIImage imageNamed:@"checkmark-on"];
    }else{
        checkbox_image = [UIImage imageNamed:@"checkmark-off"];
    }
    [btnCheckbox2 setImage:checkbox_image forState:UIControlStateNormal];
}

- (IBAction)btnIsAgreeTabbed:(id)sender {
    is_agreed = !is_agreed;
    UIImage * checkbox_image;
    if (is_agreed) {
        checkbox_image = [UIImage imageNamed:@"checkmark-on"];
    }else{
        checkbox_image = [UIImage imageNamed:@"checkmark-off"];
    }
    [btnCheckbox setImage:checkbox_image forState:UIControlStateNormal];
}


-(IBAction)btnDoneDOBTabbed:(id)sender{
    [viewDOBPicker removeFromSuperview];
    //NSLog(@"%@",objDOBPicker.date.description);
    

    
    [m_btnDateOfBirth setTitleColor:kPrimaryTextColorNight forState:UIControlStateNormal];
    
    //2019-06-14 10:27:15 +0000
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString * originalDateString = [dateFormatter stringFromDate:objDOBPicker.date];
    
    
    [m_btnDateOfBirth setTitle:originalDateString forState:UIControlStateNormal];
    user_dob = originalDateString;
}

- (IBAction)btnDoneGenderTabbed:(id)sender {
    NSInteger row = [objGenderpicker selectedRowInComponent:0];
    NSString * str = [m_arrGender objectAtIndex:row];
    [m_btnGender setTitle:str forState:UIControlStateNormal];
    [m_btnGender setTitleColor:kPrimaryTextColorNight forState:UIControlStateNormal];
    
    [viewGenderPicker removeFromSuperview];
    if (row < 2) {
        m_bIsGender = TRUE;
    }
    user_gender = str;
}
- (IBAction)downKeyboard:(id)sender {
    [sender resignFirstResponder];
    
}
-(IBAction)btnSelectDOBTabbed:(id)sender{
    [viewGenderPicker removeFromSuperview];

    [self.view endEditing:YES];

    
    CGRect frame = viewDOBPicker.frame;
    frame.size.width = self.view.frame.size.width;
    frame.origin.x = 0;
    frame.origin.y = self.view.bounds.size.height - viewDOBPicker.frame.size.height;
    viewDOBPicker.frame = frame;
    [self.view addSubview:viewDOBPicker];
    
}

- (IBAction)btnSelectGenderTabbed:(id)sender {
    [viewDOBPicker removeFromSuperview];
    
    [self.view endEditing:YES];
    CGRect frame = viewGenderPicker.frame;
    frame.size.width = self.view.frame.size.width;
    frame.origin.x = 0;
    frame.origin.y = self.view.bounds.size.height - viewGenderPicker.frame.size.height;
    viewGenderPicker.frame = frame;
    [self.view addSubview:viewGenderPicker];
}


- (IBAction)btnAlreadyhaveperkAccountTabbed:(id)sender {
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Sign-Up:Email" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Log-In" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Log-In" data:dictTrackingData];
    ////////
    
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

- (IBAction)btnCreateAccountTabbed:(id)sender {
    [self.view endEditing:YES];

    [self setBottomBorder:m_txtRepeatPassword color:kPrimaryBGColorNight];
    [self setBottomBorder:m_txtEmail color:kPrimaryBGColorNight];
    [self setBottomBorder:m_txtPassword color:kPrimaryBGColorNight];
    
    [self setBottomBorder:m_txtEmail color:kCommonColor2];
    [self setBottomBorder:m_txtPassword color:kCommonColor2];
    [self setBottomBorder:m_txtRepeatPassword color:kCommonColor2];
    
    
    if([PerkoAuth inValidateEmail:m_txtEmail.text]){
        [self setWrongEmail];
        return;
    }
    if([PerkoAuth inValidatePassword:m_txtPassword.text isSignup:TRUE]){
        [self setWrongPassword];
        return;
    }
    if(![m_txtPassword.text isEqualToString:m_txtRepeatPassword.text]){
        [self setWrongRepeatPassword];
        return;
    }
    if(user_dob == nil || (id)user_dob == [NSNull null] || user_dob.length == 0){
        NSString *strText = @"Please select Date Of Birth.";
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:strText
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* btnOk = [UIAlertAction
                                actionWithTitle:@"OKAY"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                }];
        [alert addAction:btnOk];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }else{
        if(![[JLManager sharedManager] checkifLessthenMinAgeRequirementwithDate:user_dob min_age:18]){
            NSString *strText = @"You should be at least 18 years old in order to register with WatchBack.";
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:strText
                                         message:@""
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOk = [UIAlertAction
                                    actionWithTitle:@"OKAY"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                    }];
            [alert addAction:btnOk];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
    }

    [self checkforAgreeDesclaimer:FALSE handler:^(BOOL success) {
        if (success) {
            [self GoToPhoneNumberScreen];
        }
    }];

    
}
-(void)GoToPhoneNumberScreen{
    PhoneNoVC * objPhoneNoVC = [[PhoneNoVC alloc] initWithNibName:@"PhoneNoVC" bundle:nil];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:m_txtEmail.text forKey:@"email"];
    [dict setValue:m_txtPassword.text forKey:@"password"];
    
    if(user_gender){
        [dict setValue:user_gender forKey:@"gender"];
    }
    if(user_dob){
        [dict setValue:user_dob forKey:@"dob"];
    }
    
    objPhoneNoVC.dict_signup_user_info = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [self.navigationController pushViewController:objPhoneNoVC animated:YES];
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


#pragma mark --

-(void)setWrongEmail
{
    [m_txtEmail shake:10 withDelta:5 speed:0.03];
    m_txtEmail.textColor  = kRedColor;
    [self setBottomBorder:m_txtEmail color:kRedColor];
}
-(void)setWrongPassword
{
    [m_txtPassword shake:10 withDelta:5 speed:0.03];
    m_txtPassword.textColor  = kRedColor;
    [self setBottomBorder:m_txtPassword color:kRedColor];
}
-(void)setWrongRepeatPassword
{
    [m_txtRepeatPassword shake:10 withDelta:5 speed:0.03];
   // m_txtRepeatPassword.textColor  = kRedColor;
    [self setBottomBorder:m_txtRepeatPassword color:kRedColor];
    lblRepeatPassword.hidden = false;
}
-(void)setCorrectEmailPassword
{
   
    m_txtEmail.textColor  = [UIColor whiteColor];
    m_txtPassword.textColor  = [UIColor whiteColor];
    m_txtRepeatPassword.textColor  = [UIColor whiteColor];
    lblRepeatPassword.hidden = true;
    [self setBottomBorder:m_txtRepeatPassword color:kPrimaryBGColorNight];
    [self setBottomBorder:m_txtEmail color:kPrimaryBGColorNight];
    [self setBottomBorder:m_txtPassword color:kPrimaryBGColorNight];
    
    [self setBottomBorder:m_txtEmail color:kCommonColor2];
    [self setBottomBorder:m_txtPassword color:kCommonColor2];
    [self setBottomBorder:m_txtRepeatPassword color:kCommonColor2];
}

#pragma mark-
#pragma mark  custom methods
-(void)btnClosedClicked{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)customizeNavigationBar{
    UILabel *lblnavigationtitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    lblnavigationtitle.text = @"Sign up";
    lblnavigationtitle.backgroundColor = [UIColor clearColor];
    lblnavigationtitle.textAlignment = NSTextAlignmentCenter;
    lblnavigationtitle.textColor = [UIColor whiteColor];
    lblnavigationtitle.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:20];
    
    self.navigationItem.titleView = lblnavigationtitle;
}
-(void)customizeScreenLayout{
   
   

    NSDate *now = [NSDate date];
    NSDateComponents *minusEighteenYears = [NSDateComponents new];
    minusEighteenYears.year = 0; // we can show here -18, if we don't want user to select any date less then 18 years.
    NSDate * eighteenYearsAgo = [[NSCalendar currentCalendar] dateByAddingComponents:minusEighteenYears
                                                                              toDate:now
                                                                             options:0];
    
    
    objDOBPicker.maximumDate = eighteenYearsAgo;

    
    objscrollview.contentSize = CGSizeMake(0, 700);
    m_btnGender.titleLabel.numberOfLines = 1;
//    m_btnGender.titleLabel.adjustsFontSizeToFitWidth = YES;
    m_btnGender.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //////
    m_btnRegisterAccount.layer.cornerRadius =  8;
    if ([m_txtEmail respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
       
        m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: kCommonColor2}];
        
        m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Choose a Password" attributes:@{NSForegroundColorAttributeName: kCommonColor2}];
        
        m_txtRepeatPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Repeat Password" attributes:@{NSForegroundColorAttributeName: kCommonColor2}];
    }
    m_btnRegisterAccount.backgroundColor = kRedColor;
   // m_btnRegisterAccount.alpha = 0.3;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setBottomBorder:self->m_txtEmail color:kCommonColor];
        [self setBottomBorder:self->m_txtPassword color:kCommonColor];
        [self setBottomBorder:self->m_txtRepeatPassword color:kCommonColor];
        
        
        [self setBottomBorder:self->m_btnGender color:kCommonColor];
        [self setBottomBorder:self->m_btnDateOfBirth color:kCommonColor];
    });
    
    
    [m_btnGender setTitleColor:kCommonColor2 forState:UIControlStateNormal];
    [m_btnDateOfBirth setTitleColor:kCommonColor2 forState:UIControlStateNormal];
    
    //////
    
    m_txtEmail.backgroundColor = m_txtPassword.backgroundColor = m_txtRepeatPassword.backgroundColor = m_btnGender.backgroundColor = m_btnDateOfBirth.backgroundColor  = [UIColor clearColor];
    

    
    m_txtEmail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    m_txtEmail.leftViewMode = UITextFieldViewModeAlways;
    
    m_txtPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    m_txtPassword.leftViewMode = UITextFieldViewModeAlways;
    
    m_txtRepeatPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    m_txtRepeatPassword.leftViewMode = UITextFieldViewModeAlways;
    
    ////
    
//    NSString *string = @"SIGN UP WITH EMAIL";
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
//
//    float spacing = 0.5f;
//    [attributedString addAttribute:NSKernAttributeName
//                             value:@(spacing)
//                             range:NSMakeRange(0, [string length])];
//
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [string length])];
//    [m_btnRegisterAccount setAttributedTitle:attributedString forState:UIControlStateNormal];
    
//    string = @"CONTINUE WITH FACEBOOK";
//
//    attributedString = [[NSMutableAttributedString alloc] initWithString:string];
//
//    [attributedString addAttribute:NSKernAttributeName
//                             value:@(spacing)
//                             range:NSMakeRange(0, [string length])];
//
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [string length])];
//    [m_btnContinueWithFB setAttributedTitle:attributedString forState:UIControlStateNormal];
    ////
    
    m_btnPasswordShow = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 14)];
    m_btnPasswordShow.contentMode = UIViewContentModeScaleAspectFit;
    [m_btnPasswordShow setImage:[UIImage imageNamed:@"show-icon-off"] forState:UIControlStateNormal];
    [m_btnPasswordShow setImage:[UIImage imageNamed:@"show-icon-off"] forState:UIControlStateSelected];
    [m_btnPasswordShow addTarget:self action:@selector(passwordShowClicked:) forControlEvents:UIControlEventTouchUpInside];
    m_txtPassword.rightView = m_btnPasswordShow;
    m_txtPassword.rightViewMode = UITextFieldViewModeAlways;
    
    is_agreed = NO;
    is_agreed_for_promotion = NO;
    [btnCheckbox setImage:[UIImage imageNamed:@"checkmark-off"] forState:UIControlStateNormal];

}
-(void)passwordShowClicked:(id)sender{
    if ([sender isSelected]) {
        [sender setSelected:FALSE];
        m_txtPassword.secureTextEntry = TRUE;
        m_txtRepeatPassword.secureTextEntry = TRUE;
    }
    else{
        [sender setSelected:TRUE];
        m_txtPassword.secureTextEntry = FALSE;
        m_txtRepeatPassword.secureTextEntry = FALSE;
    }
    NSString *tmpString = m_txtPassword.text;
    m_txtPassword.text = @" ";
    m_txtPassword.text = tmpString;
    
    tmpString = m_txtRepeatPassword.text;
    m_txtRepeatPassword.text = @" ";
    m_txtRepeatPassword.text = tmpString;
}
-(void)initGender{
    m_arrGender = [NSArray arrayWithObjects:@"Male",@"Female",@"Prefer not to answer", nil];
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
#pragma mark -- Picker view data souce
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return m_arrGender.count;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [m_arrGender objectAtIndex:row];
}

/*
-(void)showAlertUnderAge{
    [self saveDate];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Sorry, you are not eligible to participate at this time."
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOK = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                //Handle your yes please button action here
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
    
    
    [alert addAction:btnOK];
    [self presentViewController:alert animated:YES completion:nil];
}
*/
/*
-(void)checkforLast24HoursAttempts{
    NSString *selectedDob = [[JLManager sharedManager] getObjectuserDefault:@"user_selected_date"];
    if (selectedDob != nil && [selectedDob isKindOfClass:[NSString class]] && selectedDob.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"y-MM-dd"];
        
        NSDate * startDate = [dateFormatter dateFromString:selectedDob];
        objDOBPicker.date = startDate;
        NSDate * endDate = [NSDate date];
        if (startDate && endDate) {
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dateComponent = [gregorianCalendar components:NSCalendarUnitYear fromDate:startDate toDate:endDate options:0];
            if(kDebugLog)NSLog(@"%ld",(long)dateComponent.year);
            if(dateComponent.year<kMinAgeRequirement){
                NSString *selectedTime =[[JLManager sharedManager] getObjectuserDefault:@"user_selected_date_time"];
                [dateFormatter setDateFormat:@"y-MM-dd HH:mm:ss"];
                NSDate * lastTimeSelectedDate = [dateFormatter dateFromString:selectedTime];
                if (endDate && lastTimeSelectedDate) {
                    NSTimeInterval distanceBetweenDates = [endDate timeIntervalSinceDate:lastTimeSelectedDate];
                    double secondsInAnHour = 3600;
                    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
                    if (hoursBetweenDates < 24) {
                        [self showAlertUnderAge];
                    }
                }
                
            }
        }
        
    }
    
}
*/

#pragma privacy policy

-(void)btnVPPAClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kVPPA;
    objRedeemWebVC.title = @"VPPA";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(void)btnTermsClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kTermsAndConditionsLink;
    objRedeemWebVC.title = @"Terms and Conditions";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(void)btnPrivacyClicked{
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kPrivacyPolicy;
    objRedeemWebVC.title = @"Privacy Policy";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(void)checkforDOB:(NSString *)dob handler:(void(^)(BOOL success))handler{
    if(dob && dob.length>0){
        handler(TRUE);
    }else{
        NSString *strText = @"Please select Date Of Birth.";
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:strText
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* btnOk = [UIAlertAction
                                actionWithTitle:@"OKAY"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    handler(FALSE);
                                }];
        [alert addAction:btnOk];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)checkforAgreeDesclaimer:(BOOL)isFB handler:(void(^)(BOOL success))handler{
    if (!is_agreed) {
        NSString *strText = @"Please agree to the Terms & Conditions, Privacy Policy, and Video Viewing Policy.";
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:strText
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
       
            UIAlertAction* btnNo = [UIAlertAction
                                    actionWithTitle:@"OKAY"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {

                                        handler(FALSE);
                                    }];
            [alert addAction:btnNo];
        [self presentViewController:alert animated:YES completion:nil];
    }else if(!is_agreed_for_promotion){
        NSString *strText = @"To continue, please agree that you understand that WatchBack may send you the latest news, promotions and more.";
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:strText
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* btnNo = [UIAlertAction
                                actionWithTitle:@"OKAY"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    handler(FALSE);
                                }];
        [alert addAction:btnNo];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        handler(TRUE);
    }

}

//- (IBAction)btnContinueWithFBClicked{
//    [self checkforAgreeDesclaimer:TRUE handler:^(BOOL success) {
//        if (success) {
//            [self fbLogin];
//        }
//    }];
//}

/*
-(void)fbLogin{
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Continue with Facebook" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
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
                    [dictTrackingData setObject:@"true" forKey:@"tve.registrationsuccess"];
                    [dictTrackingData setObject:@"true" forKey:@"tve.userlogin"];
                    [dictTrackingData setObject:@"Sign-Up:Facebook" forKey:@"tve.title"];
                    [dictTrackingData setObject:@"Event:Facebook:Sign-Up Success" forKey:@"tve.userpath"];
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
                    [dictTrackingData setObject:@"Facebook" forKey:@"tve.registrationtype"];
                    
                    ////
                    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Facebook:Sign-Up Success" data:dictTrackingData];
                    ////////
                    [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"complete_registration" withValues:@{@"registration_method":@"facebook"}];
                    [[JLTrackers sharedTracker] trackSingularEvent:@"complete_registration"];
                    [[JLTrackers sharedTracker] trackFBEvent:@"complete_registration" params:nil];
                }
                else{
                    ////////////
                    NSString *strErrorLocal = strError;
                    if (strErrorLocal == nil) {
                        strErrorLocal = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]];
                    }
                    
                    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                    [dictTrackingData setObject:@"true" forKey:@"tve.registrationerror"];
                    [dictTrackingData setObject:strErrorLocal forKey:@"tve.error"];
                    [dictTrackingData setObject:@"Sign-Up:Facebook" forKey:@"tve.title"];
                    [dictTrackingData setObject:@"Event:Facebook:Sign-Up Error" forKey:@"tve.userpath"];
                    [dictTrackingData setObject:@"Facebook" forKey:@"tve.registrationtype"];
                    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
                    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Facebook:Sign-Up Error" data:dictTrackingData];
                    ////////
                }
                
                /////////////
                                    
            }];
        }
        
    }];
}
*/
-(void)setDefaultDesclaimer{
    is_agreed = NO;
    is_agreed_for_promotion = NO;
    
//    BOOL bTermsPrivacyAgreement = FALSE;// [[[JLManager sharedManager] getObjectuserDefault:kTermsPrivacyAgreement] boolValue];
//    [m_switchTermsPrivacy setOn: bTermsPrivacyAgreement];
    
//    BOOL bMarketingAgreement = FALSE;// [[[JLManager sharedManager] getObjectuserDefault:kMarketingAgreement] boolValue];
//    [m_switchMarketing setOn: bMarketingAgreement];
    
    NSString *str = @"<html><head><style type=\"text/css\">html, body {height: 100%;margin: 0;padding: 0;width: 100%;} html {display: table;} a{text-decoration:none; color:white;}  body { display: table-cell; vertical-align: middle;padding: 0px;text-align: left;-webkit-text-size-adjust: none; color:white;      font-family:\"SF Pro Display\";font-size: 10pt;}</style></head><body leftmargin=\"0\" topmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\"> I agree to the <a href=\"terms://\"><b>Terms of Service</b></a>, <a href=\"privacy://\"><b>Privacy Policy</b></a>, and the <a href=\"vvp://\"><b>Video Viewing Policy</b></a>.<br /><br>I understand that WatchBack may send me the latest news, promotions and more.</body></html>";
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
