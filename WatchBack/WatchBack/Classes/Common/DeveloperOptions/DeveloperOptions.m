//
//  DeveloperOptions.m
//  LIVETV
//
//  Created by Nilesh on 4/6/15.
//  Copyright (c) 2015 Nilesh. All rights reserved.
//

#import "DeveloperOptions.h"
#import "JLManager.h"
@interface DeveloperOptions ()
{
    IBOutlet UISegmentedControl *m_segProtocol;
    IBOutlet UISegmentedControl *m_segAPIEndpoint;
    
    IBOutlet UIView *m_viewCustom;
    IBOutlet UITextField *m_txtAPITV;
    IBOutlet UITextField *m_txtAPI;
    IBOutlet UITextField *m_txtWeb;
    
}
@end

@implementation DeveloperOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Developer Options";
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnClosedClicked)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(btnSave_Click:)];

    
    NSString *protocol =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeProtocol]];
    
    if ([protocol isEqualToString:@"Non-SSL"]) {
        [m_segProtocol setSelectedSegmentIndex:1];
    }
    else
    {
        [m_segProtocol setSelectedSegmentIndex:0];
    }
    
    NSString *api_endpoint =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeAPIEndpoint]];
    
    if ([api_endpoint isEqualToString:@"Custom"]) {
        [m_segAPIEndpoint setSelectedSegmentIndex:2];
        m_viewCustom.hidden = false;
        
        m_txtAPI.text = @"api.watchback.com";
        m_txtAPITV.text = @"api.watchback.com";
        m_txtWeb.text = @"watchback.com";
    }
    else if([api_endpoint isEqualToString:@"Development"])
    {
        [m_segAPIEndpoint setSelectedSegmentIndex:1];
        m_viewCustom.hidden = true;
    }
    else
    {
        [m_segAPIEndpoint setSelectedSegmentIndex:0];
        m_viewCustom.hidden = true;
    }
    
    
}
-(void)btnClosedClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
-(IBAction)btnSave_Click:(id)sender
{
    
    
    
    NSInteger nAPIEndpoints = m_segAPIEndpoint.selectedSegmentIndex;
    
    if (nAPIEndpoints == 2) {
        
        
        NSString *strAPITV = m_txtAPITV.text;
        NSString *strAPI = m_txtAPI.text;
        NSString *strWeb = m_txtWeb.text;
        
        if (strAPITV == nil || strAPITV.length < 1) {
            
        
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Invalid Input"
                                         message:@"Please enter TV Domain"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOK = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];

            [alert addAction:btnOK];
            [self presentViewController:alert animated:YES completion:nil];
            

            
            return;
        }
        if (strAPI == nil || strAPI.length < 1) {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Invalid Input"
                                         message:@"Please enter API Domain"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOK = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
            
            [alert addAction:btnOK];
            [self presentViewController:alert animated:YES completion:nil];

            return;
        }
        
        if (strWeb == nil || strWeb.length < 1) {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Invalid Input"
                                         message:@"Please enter Web Domain"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* btnOK = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
            
            [alert addAction:btnOK];
            [self presentViewController:alert animated:YES completion:nil];

            
            
            return;
        }
        if(![JLManager sharedManager].skip_registration){
            [[JLManager sharedManager] logoutUserWithAlert : LogoutModeDefault];
        }
        
        [[JLManager sharedManager] setObjectuserDefault:@"Custom" forKey:kDevModeAPIEndpoint];
        [[JLManager sharedManager] setObjectuserDefault: strAPITV forKey:kDevModeAPIEndpointCustomAPITV];
        
        [[JLManager sharedManager] setObjectuserDefault:strWeb forKey:kDevModeAPIEndpointCustomWeb];
    }
    else if(nAPIEndpoints == 1)
    {
        if(![JLManager sharedManager].skip_registration){
            [[JLManager sharedManager] logoutUserWithAlert : LogoutModeDefault];
        }
        [[JLManager sharedManager] setObjectuserDefault:@"Development" forKey:kDevModeAPIEndpoint];
    }
    else
    {
        if(![JLManager sharedManager].skip_registration){
            [[JLManager sharedManager] logoutUserWithAlert : LogoutModeDefault];
        }
        
        [[JLManager sharedManager] setObjectuserDefault:@"Production" forKey:kDevModeAPIEndpoint];
    }
    
    NSInteger nProtocol = m_segProtocol.selectedSegmentIndex;
    if (nProtocol == 1) {
        [[JLManager sharedManager] setObjectuserDefault:@"Non-SSL" forKey:kDevModeProtocol];
    }
    else
    {
        [[JLManager sharedManager] setObjectuserDefault:@"SSL" forKey:kDevModeProtocol];
    }
    //giving 5 seconds delay before exiting app, inorder to save data.
    [[JLManager sharedManager] showLoadingView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[JLManager sharedManager] hideLoadingView];
        exit(0);
    });
}
-(IBAction)segProtocol_ChangeValue:(id)sender
{
    
}
-(IBAction)segAPI_Endpoint_ChangeValue:(id)sender
{
    if (m_segAPIEndpoint.selectedSegmentIndex == 2) {
        m_viewCustom.hidden = false;
    }
    else
    {
        m_viewCustom.hidden = true;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
@end
