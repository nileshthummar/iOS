//
//  CrashTrackerController.m

//
//  Created by Nilesh on 7/27/17.
//  Copyright © 2017 Nilesh. All rights reserved.
//

#import "CrashTrackerController.h"
#import <Crashlytics/Crashlytics.h>
@interface CrashTrackerController ()

@end

@implementation CrashTrackerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // NSString *topViewControllerName = NSStringFromClass([[[JLManager sharedManager] topViewController] class]);
   // CLSLog(@"TOPVIEWCONTROLLER - %@",topViewControllerName);
    
    
   CLSLog(@"CONTROLLER_DID_LOAD - %@",NSStringFromClass([self class]));
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
   
    
    // Set the log
  CLSLog(@"CONTROLLER_DID_APPEAR - %@",NSStringFromClass([self class]));
    // Set the key
  [[Crashlytics sharedInstance] setObjectValue:NSStringFromClass([self class]) forKey:@"CONTROLLER_APPEARED"];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // Set the log
    CLSLog(@"CONTROLLER_DID_DISAPPEAR - %@",NSStringFromClass([self class]));
    // Set the key
    [[Crashlytics sharedInstance] setObjectValue:NSStringFromClass([self class]) forKey:@"CONTROLLER_DISAPPEARED"];
    
}
-(void)dealloc{
    
  CLSLog(@"CONTROLLER_DEALLOCATED - %@",NSStringFromClass([self class]));
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

@end
