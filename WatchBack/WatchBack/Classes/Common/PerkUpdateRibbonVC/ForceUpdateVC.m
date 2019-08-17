//
//  ForceUpdateVC.m
//  Watchback
//
//  Created by Nilesh on 1/15/15.
//  Copyright (c) 2015 Nilesh. All rights reserved.
//

#import "ForceUpdateVC.h"

@interface ForceUpdateVC ()

@end

@implementation ForceUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStatusBarDidChangeOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
   
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:self.view];
    
    self.view.center = [UIApplication sharedApplication].keyWindow.rootViewController.view.center;
    

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)btnClose_Click:(id)sender
{
    [self.view removeFromSuperview];
}
-(IBAction)btnUpdate_Click:(id)sender
{
    if (self.m_striTunesURL) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.m_striTunesURL] options:@{} completionHandler:nil];
    }
}
-(void) handleStatusBarDidChangeOrientation:(NSNotification *) notification {
    
   
   
}
@end
