//
//  TermsGateVC.h
//  Watchback
//
//  Created by Nilesh on 8/12/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashTrackerController.h"
@interface TermsGateVC : CrashTrackerController
@property(strong)void (^delegate)(BOOL finished);
@end
