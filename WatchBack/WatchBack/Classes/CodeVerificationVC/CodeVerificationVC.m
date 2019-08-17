//
//  CodeVerificationVC.m
//  Watchback
//
//  Created by perk on 14/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "CodeVerificationVC.h"
#import "WebServices.h"
#import "Constants.h"
#import "PerkoAuth.h"
#import "UIView+Toast.h"
#import "JLManager.h"
#import "PerkoAuth.h"

@interface CodeVerificationVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (weak, nonatomic) IBOutlet UITextField *txt1;
@property (weak, nonatomic) IBOutlet UITextField *txt2;
@property (weak, nonatomic) IBOutlet UITextField *txt3;
@property (weak, nonatomic) IBOutlet UITextField *txt4;
@property (weak, nonatomic) IBOutlet UITextField *txt5;

@end

@implementation CodeVerificationVC

#pragma mark-
#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeScreenLayout];
    [self customoizeNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}
-(void)viewDidAppear:(BOOL)animated{
    if(![PerkoAuth getPerkUser].IsUserLogin){
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}

#pragma mark-
#pragma mark ibaction or custom methods
-(void)checkforEnableState{
    if(_txt1.text.length > 0 &&
       _txt2.text.length > 0 &&
       _txt3.text.length > 0 &&
       _txt4.text.length > 0 &&
       _txt5.text.length > 0){
        [_btnContinue setBackgroundColor:kRedColor];
        _btnContinue.enabled = true;
    }else{
        [_btnContinue setBackgroundColor:kRedColorDisabled];
        _btnContinue.enabled = false;
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField layoutIfNeeded];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    float delay_time = 0.25;
    
    if(textField == _txt1){
    NSString * digit = [textField.text stringByReplacingCharactersInRange:range withString:string];

        if([digit isEqualToString:@""]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt1 resignFirstResponder];
            });
            return YES;
        }

        
    if(digit.length == 1){
        [self checkforEnableState];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.txt2 becomeFirstResponder];
        });
        return YES;
    }else if (digit.length > 1){
        return NO;
    }
        
    }else if(textField == _txt2){
        NSString * digit = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if([digit isEqualToString:@""]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt1 becomeFirstResponder];
            });
            return YES;
        }

        
        if(digit.length == 1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt3 becomeFirstResponder];
                [self checkforEnableState];

            });
            return YES;
        }else if (digit.length > 1){
            return NO;
        }
    }else if(textField == _txt3){
        NSString * digit = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if([digit isEqualToString:@""]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt2 becomeFirstResponder];
            });
            return YES;
        }

        
        if(digit.length == 1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt4 becomeFirstResponder];
                [self checkforEnableState];

            });
            return YES;
        }else if (digit.length > 1){
            return NO;
        }
    }else if(textField == _txt4){
        NSString * digit = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if([digit isEqualToString:@""]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt3 becomeFirstResponder];
            });
            return YES;
        }
        
        if(digit.length == 1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt5 becomeFirstResponder];
                [self checkforEnableState];

            });
            return YES;
        }else if (digit.length > 1){
            return NO;
        }
    }else if(textField == _txt5){
        NSString * digit = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if([digit isEqualToString:@""]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt4 becomeFirstResponder];
            });
            return YES;
        }
        if(digit.length == 1){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.txt5 resignFirstResponder];
                [self checkforEnableState];

            });
            return YES;
        }else if (digit.length > 1){
            return NO;
        }
    }
    
    [self checkforEnableState];
    
    return YES;
}

-(IBAction)downKeyboard:(id)sender{
    if (sender == _txt1) {
        [_txt2 becomeFirstResponder];
    }else if(sender == _txt2){
        [_txt3 becomeFirstResponder];
    }else if(sender == _txt3){
        [_txt4 becomeFirstResponder];
    }else if(sender == _txt4){
        [_txt5 becomeFirstResponder];
    }else{
        [_txt5 resignFirstResponder];
    }
}

-(void)setBottomBorder :(id)sender color:(UIColor *)color{
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = color.CGColor;
    border.frame = CGRectMake(0, [sender frame].size.height - borderWidth, [sender frame].size.width, [sender frame].size.height);
    border.borderWidth = borderWidth;
    [[sender layer] addSublayer:border];
    [sender layer].masksToBounds = YES;
    
}


-(void)customizeScreenLayout{
    
    _btnContinue.layer.cornerRadius = 8.0;
    [self setBottomBorder:_txt1 color:[UIColor whiteColor]];
    [self setBottomBorder:_txt2 color:[UIColor whiteColor]];
    [self setBottomBorder:_txt3 color:[UIColor whiteColor]];
    [self setBottomBorder:_txt4 color:[UIColor whiteColor]];
    [self setBottomBorder:_txt5 color:[UIColor whiteColor]];
    
    
    
    if(!_phone_no){
        return;
    }
    NSRange  phone_no_part2_range;
    phone_no_part2_range.location = 3;
    phone_no_part2_range.length = 3;
    
    NSString * phone_part1 = [_phone_no substringToIndex:3];
    NSString * phone_part2 = [_phone_no substringWithRange:phone_no_part2_range];
    NSString * phone_part3 = [_phone_no substringWithRange:NSMakeRange(6, 4)];
    
    _lblTitle.text = [NSString stringWithFormat:@"We just sent a message to (%@) %@ - %@ with a code for you to enter here",phone_part1,phone_part2, phone_part3];
}

- (IBAction)btnContinueTabbed:(id)sender {
    
    if(_txt1.text.length == 1 &&
       _txt2.text.length == 1 &&
       _txt3.text.length == 1 &&
       _txt4.text.length == 1 &&
       _txt5.text.length == 1
       ){
        [[JLManager sharedManager] showLoadingView:self.view];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        [dict setValue:[PerkoAuth getPerkUser].accessToken forKey:@"access_token"];
        [dict setValue:[NSString stringWithFormat:@"%@%@%@%@%@",_txt1.text,_txt2.text, _txt3.text, _txt4.text, _txt5.text] forKey:@"code"];
        
        // NSLog(@"%@",dict);
        [WebServices sharedManager].m_bRetry = true;
        
        [[WebServices sharedManager] callAPIJSON:VERIFY_PHONE_URL params:dict httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
            [[JLManager sharedManager] hideLoadingView];


            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[JLManager sharedManager] showLoadingView:self.view];
                    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                          [[JLManager sharedManager] hideLoadingView];
                        
                        JLPerkUser * loginuser = [PerkoAuth getPerkUser];
                        if(loginuser.phone_verified_at == nil ||
                           (id)loginuser.phone_verified_at == [NSNull null]){
                            
                        }else{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
                        }
                    }];
                });
            }
            else{

                if(dict !=nil && (id)dict != [NSNull null]){
                    if ([dict valueForKey:@"message"]!=nil &&
                        [dict valueForKey:@"message"]!= [NSNull null]){
                        
                        [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:2.0 position:CSToastPositionCenter title:[dict valueForKey:@"message"] image:nil style:nil completion:nil];

                    }
                }
            }
            
        }];
    }
    
}
- (IBAction)btnResendTabbed:(id)sender {
   // NSLog(@"resend tabbed");

    [[JLManager sharedManager] showLoadingView:self.view];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[PerkoAuth getPerkUser].accessToken forKey:@"access_token"];
    
    // NSLog(@"%@",dict);
    [WebServices sharedManager].m_bRetry = true;
    
    [[WebServices sharedManager] callAPIJSON:REVERIFY_PHONE_URL params:dict httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{

        [[JLManager sharedManager] hideLoadingView];
        
        if (success) {
            if(dict !=nil && (id)dict != [NSNull null]){
                if ([dict valueForKey:@"data"]!=nil &&
                    [dict valueForKey:@"data"]!= [NSNull null]){
                    
                    [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:2.0 position:CSToastPositionCenter title:[dict valueForKey:@"data"] image:nil style:nil completion:nil];
                    
                    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                        
                    }];
                }
            }
        }
        else{

            if(dict !=nil && (id)dict != [NSNull null]){
                if ([dict valueForKey:@"message"]!=nil &&
                    [dict valueForKey:@"message"]!= [NSNull null]){
                    
                    [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:2.0 position:CSToastPositionCenter title:[dict valueForKey:@"message"] image:nil style:nil completion:nil];
                    
                }
            }
        }
        });
    }];
}
-(void)customoizeNavigationBar{
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = true;
    
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackTabbed)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    
    UILabel *lblnavigationtitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
    lblnavigationtitle.text = @"Enter Verification Code";
    lblnavigationtitle.backgroundColor = [UIColor clearColor];
    lblnavigationtitle.textAlignment = NSTextAlignmentCenter;
    lblnavigationtitle.textColor = [UIColor whiteColor];
    lblnavigationtitle.font = [UIFont fontWithName:@"SFProDisplay-Medium" size:20];
    
    self.navigationItem.titleView = lblnavigationtitle;

    
}

-(void)btnBackTabbed{
    
}

@end
