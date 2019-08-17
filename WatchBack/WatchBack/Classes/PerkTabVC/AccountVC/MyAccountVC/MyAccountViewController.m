//
//  MyAccountViewController.m
//  Watchback
//
//  Created by perk on 03/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "MyAccountViewController.h"
#import "PerkoAuth.h"
#import "AppLabel.h"
#import "JLManager.h"
#import "RedeemWebVC.h"
#import "NavPortrait.h"

@interface MyAccountViewController (){
    AppLabel * lblTitle;
}
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@end

@implementation MyAccountViewController

#pragma mark-
#pragma mark view life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[JLManager sharedManager] showLoadingView:self.view];
    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
        if(success){
            [self configureScreenLayout];
        }
        [[JLManager sharedManager] hideLoadingView];
    }];
}
#pragma mark-
#pragma mark ibaction or custom methods
-(void)btnBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)customizeNavigationBar{
    lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 27)];
    lblTitle.textColor = kPrimaryTextColor;
    lblTitle.font = kFontPrimary18;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"My Account";
    
    self.navigationItem.titleView = lblTitle;
    
    
    
    UIBarButtonItem * leftItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBackClicked)];
    self.navigationItem.leftBarButtonItem = leftItem;

}


-(void)configureScreenLayout{
    _btnEdit.layer.cornerRadius = 8.0;
    
    if([PerkoAuth getPerkUser].IsUserLogin){
        JLPerkUser * loginuser = [PerkoAuth getPerkUser];
        if(loginuser.email != nil && (id)loginuser.email != [NSNull null]){
            _lblEmail.text = loginuser.email;
        }
        if(loginuser.gender != nil && (id)loginuser.gender != [NSNull null] && ![loginuser.gender isEqualToString:@""]){
            if([[loginuser.gender lowercaseString] isEqualToString:@"m"] || [[loginuser.gender lowercaseString] isEqualToString:@"male"]){
                _lblGender.text = @"Male";
            }else if([[loginuser.gender lowercaseString] isEqualToString:@"f"] || [[loginuser.gender lowercaseString] isEqualToString:@"female"]){
                _lblGender.text = @"Female";
            }
        }else{
            _lblGender.text = @"Unknown";
        }
        
        if(loginuser.phoneno !=nil && (id)loginuser.phoneno != [NSNull null]){
            _lblPhoneNumber.text = loginuser.phoneno;
        }
    }
}
- (IBAction)btnEditTapped:(id)sender {
    if([PerkoAuth getPerkUser].IsUserLogin){
        RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
        NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
        nav.navigationBarHidden = FALSE;
        objRedeemWebVC.m_strUrl = [NSString stringWithFormat:@"%@?access_token=%@",kMyAccountWebpage,[PerkoAuth getPerkUser].accessToken];
        objRedeemWebVC.title = @"Edit My Account";
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
