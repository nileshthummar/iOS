//
//  JLBtnCurrency.h
//  Watchback
//
//  Created by Nilesh on 8/9/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLManager.h"

@interface JLBtnCurrency : UIButton{
    
}
+(JLBtnCurrency *)sharedCurrencyButton;
+(void)updateCurrency;
@end
