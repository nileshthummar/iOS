//
//  RequestMoreInfoVC.m
//  Watchback
//
//  Created by perk on 24/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "RequestMoreInfoVC.h"
#import "JLManager.h"
#import "Constants.h"
#import "LoginVC.h"
#import "SignUpWithEmailVC.h"
#import "NavPortrait.h"

@interface RequestMoreInfoVC ()
@property (weak, nonatomic) IBOutlet UIView *viewLogout;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

@implementation RequestMoreInfoVC

#pragma mark-
#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeScreenUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reskinUIElements];

}

#pragma mark-
#pragma mark ibaction or custom methods
-(void)addBlurrEffect{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:blurEffectView];
    [self.view sendSubviewToBack:blurEffectView];

}

-(void)reskinUIElements{
    _lblTitle.textColor = kPrimaryTextColor;
    _lblSubTitle.textColor = kThirdTextColor;
    
    [_btnLogin setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];

   // [_btnSignup setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];
    _viewLogout.backgroundColor = kPrimaryBGColor;
    

    
}
- (IBAction)btnCloseTabbed:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

-(void)customizeScreenUI{
    _viewLogout.layer.cornerRadius = 12.0;
    _btnSignup.layer.cornerRadius = 8.0;
    [self addBlurrEffect];
}

- (IBAction)btnLoginTabbed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
        LoginVC *objLoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
        objLoginVC.delegate = ^(BOOL finished){
            [self finished];
        };
        NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objLoginVC];
        nav.navigationBarHidden = FALSE;
        nav.navigationBar.tintColor = kPrimaryTextColorNight;
        nav.navigationBar.barTintColor = kPrimaryBGColorNight;
        
        
        [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:objLoginVC action:@selector(btnClosedClicked)];
                
                objLoginVC.navigationItem.leftBarButtonItem = btnClose;
            });
        }];
        });
    }];
    
}
- (IBAction)btnSignupTabbed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            SignUpWithEmailVC *objSignUpWithEmailVC = [[SignUpWithEmailVC alloc] initWithNibName:@"SignUpWithEmailVC" bundle:nil];
            objSignUpWithEmailVC.delegate = ^(BOOL finished){
                [self finished];
            };
            NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSignUpWithEmailVC];
            nav.navigationBarHidden = FALSE;
            nav.navigationBar.tintColor = kPrimaryTextColorNight;
            nav.navigationBar.barTintColor = kPrimaryBGColorNight;
            
            
            [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:objSignUpWithEmailVC action:@selector(btnClosedClicked)];
                    
                    objSignUpWithEmailVC.navigationItem.leftBarButtonItem = btnClose;
                });
            }];

        });

    }];
    

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


-(void)finished
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadHomePageNotification object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadHomePageNotification object:nil];
    }
}



@end
