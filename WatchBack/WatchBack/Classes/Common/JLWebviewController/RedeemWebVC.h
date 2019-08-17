//
//  RedeemWebVCViewController.h
//  Perk Wallet
//
//  Created by Nilesh on 3/12/14.
//  Copyright (c) 2014 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashTrackerController.h"
@interface RedeemWebVC : CrashTrackerController
@property (strong, nonatomic) IBOutlet UIWebView *objwebview;
@property (strong,nonatomic) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (strong, atomic) NSString * m_strUrl;
//@property (strong, atomic) NSString *mTitle;
@end
