//
//  NielsenOptOutVCViewController.m
//  Perk Wallet
//
//  Created by Nilesh on 3/12/14.
//  Copyright (c) 2014 Nilesh. All rights reserved.
//

#import "NielsenOptOutVC.h"
#import "ADBMediaHeartbeat+Nielsen.h"
#import "NSURL+QueryString.h"
#import "Constants.h"

#define kBtnMarkUsedTag 48493

@interface NielsenOptOutVC ()

@end

@implementation NielsenOptOutVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark view life cycle methods
- (void)viewDidLoad{
    [super viewDidLoad];
   _objwebview.scalesPageToFit = YES;
  
    NSString *url = [ADBMediaHeartbeat nielsenOptOutURLString];
    [_objwebview loadRequest:[NSURLRequest requestWithURL:[[NSURL URLWithString:url] URLByAppendingQueryString:QueryParameter]]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    _objwebview.delegate = (id)self;
    
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"carrot_down"] style:UIBarButtonItemStylePlain target:self action:@selector(btnClosedClicked)];
    
    self.navigationItem.leftBarButtonItem = btnClose;
    
    

}
-(void)btnClosedClicked
{
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _objwebview.delegate = nil;
    self.navigationItem.rightBarButtonItem = nil;
   
    [[self.navigationController.navigationBar viewWithTag:kBtnMarkUsedTag] removeFromSuperview];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UIWebview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *command = [NSString stringWithFormat:@"%@", request.URL];
    if ([command isEqualToString:kNielsenWebClose])
    {
        // Close the web view
       [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    
    // Retrieve next URL if requested
    return (![ADBMediaHeartbeat nielsenUserOptOut:command]);

}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_loadingIndicator startAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_loadingIndicator stopAnimating];   
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_loadingIndicator stopAnimating];
}

@end
