//
//  LogoutVC.m
//  Watchback
//
//  Created by Nilesh on 8/18/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "LogoutVC.h"
#import "LoginVC.h"
#import "SignUpWithEmailVC.h"
#import "JLManager.h"
#import "PerkoAuth.h"
#import "WebServices.h"
@interface LogoutVC ()
{
    IBOutlet UIScrollView *m_viewLogout;
    IBOutlet UIButton *m_btnSignup;
    IBOutlet UIButton *m_btnLogin;
    IBOutlet UILabel *m_lblText1;
    IBOutlet UILabel *m_lblText2;
}
@end

@implementation LogoutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customizeScreenLayout];
    [self callAPIforGetData];
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
-(void)customizeScreenLayout{
    m_btnLogin.layer.cornerRadius = m_btnSignup.layer.cornerRadius = 8;
    m_btnSignup.titleLabel.font = kFontBtn14;
    m_lblText1.font = kFontPrimary23;
    m_lblText2.font = kFontPrimary17;
    
    m_viewLogout.contentSize = CGSizeMake(0, 700);
    if (self.view.bounds.size.height > 700) {
        m_viewLogout.scrollEnabled = FALSE;
    }
    else{
        m_viewLogout.scrollEnabled = TRUE;
    }
}

- (IBAction)btnLoginClicked {
    LoginVC *objLoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    objLoginVC.delegate = ^(BOOL finished){
        [self finished];
    };
    [self.navigationController pushViewController:objLoginVC animated:YES];
}

- (IBAction)btnSignupClicked{
    SignUpWithEmailVC *objSignUpWithEmailVC = [[SignUpWithEmailVC alloc] initWithNibName:@"SignUpWithEmailVC" bundle:nil];
    objSignUpWithEmailVC.delegate = ^(BOOL finished){
        [self finished];
    };
    [self.navigationController pushViewController:objSignUpWithEmailVC animated:YES];
    
}
-(void)loginSignupSuccessed
{
    [self finished];
    [[JLManager sharedManager] loginSignupSuccessed];
}

-(void)finished
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetHeaderNotification object:nil];
}
-(void)callAPIforGetData{
   
    [[JLManager sharedManager] showLoadingView:self.view];
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",API_CAROUSELS,@"Logged Out Screens"] ;
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
                                NSDictionary *dictData = [arr objectAtIndex:0];
                                if (dictData != nil && [dictData isKindOfClass:[NSDictionary class]]) {
                                    NSDictionary *fields = [dictData objectForKey:@"fields"];
                                    if (fields != nil && [fields isKindOfClass:[NSDictionary class]]) {
                                        //NSAttributedString *attrTextTitle = [[NSAttributedString alloc] initWithString:strTitle attributes:@{ NSParagraphStyleAttributeName : style}];
                                        
                                       // self.m_lblTitle.attributedText = attrTextTitle;
                                        NSString *txt1 = [fields objectForKey:@"txt1"];
                                        txt1 = [txt1 stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                                        NSString *txt2 = [fields objectForKey:@"txt2"];
                                        txt2 = [txt2 stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                                        self->m_lblText1.attributedText  = [[NSAttributedString alloc] initWithString:txt1];
                                        self->m_lblText2.attributedText  = [[NSAttributedString alloc] initWithString:txt2];
                                        
                                    }
                                }
                            }
                        
                        }
                    }
                }
            }
           
        }
        [[JLManager sharedManager] hideLoadingView];
        
    }];
}
@end
