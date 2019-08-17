//
//  JLBtnCurrency.m
//  Watchback
//
//  Created by Nilesh on 8/9/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "JLBtnCurrency.h"
//#import "JLMyAccountViewController.h"
#import "JLUtils.h"
#import "PerkoAuth.h"
#import "Constants.h"
static JLBtnCurrency * btnCurrency;
static NSDictionary *dictFont1;
static NSDictionary *dictFont2;
@interface JLBtnCurrency (){
    
}
@end

@implementation JLBtnCurrency

+(JLBtnCurrency *)sharedCurrencyButton{

    if(btnCurrency == nil ){
        
        btnCurrency = [JLBtnCurrency buttonWithType:UIButtonTypeCustom];
        CGRect f = [[UIScreen mainScreen] bounds];
        UIInterfaceOrientation o = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(o)) {
            
            if (f.size.width < f.size.height) {
                
                f = CGRectMake(f.origin.x, f.origin.y, f.size.height, f.size.width);
            }
            
        }else {
            
            if (f.size.height < f.size.width) {
                
                f = CGRectMake(f.origin.x, f.origin.y, f.size.height, f.size.width);
            }
        }
        btnCurrency.frame = CGRectMake(f.size.width - 75,(44-38)/2,75, 38);
        btnCurrency.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0,10);
        btnCurrency.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0,0);
        [btnCurrency setBackgroundColor:[UIColor clearColor]];
        [btnCurrency.titleLabel setTextAlignment:NSTextAlignmentRight];
        btnCurrency.titleLabel.textColor = [UIColor whiteColor];
       
        [btnCurrency.titleLabel setAdjustsFontSizeToFitWidth:YES];
        
        UIFont *font1 = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
        UIFont *font2 = [UIFont fontWithName:@"AvenirNext-Bold" size:11];
        dictFont1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font1};
        dictFont2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                                NSFontAttributeName:font2};
        
        [JLBtnCurrency updateCurrency];
        [[btnCurrency titleLabel] setNumberOfLines:0];
        [[btnCurrency titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];

        
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:(id)self
                                                 selector:@selector(updateCurrency)
                                                     name: kUpdateCurrencyNotification
                                                   object:nil];
        
        
        
       
//        UIImageView  *imgDots = [[UIImageView alloc] initWithFrame:CGRectMake(75, 0, 4, 38)];
//        imgDots.contentMode = UIViewContentModeScaleAspectFit;
//        imgDots.image = [UIImage imageNamed:@"mOREMENU"];
//        [btnCurrency addSubview:imgDots];
        
        
    }
    
    
    return btnCurrency;
    
}




+(void)updateCurrency{
	
	
    JLPerkUser * perkuser = [PerkoAuth getPerkUser];
	
    int points = [perkuser.perkPoint.availableperks intValue] + [perkuser.perkPoint.pendingperks intValue];
    
    
    NSString *strPoints = @"";
    if([PerkoAuth IsUserLogin]){
		
        NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
        [num setNumberStyle: NSNumberFormatterDecimalStyle];
        NSString *numberAsString = [num stringFromNumber:[NSNumber numberWithInt:points]];
        
        
       strPoints = [NSString stringWithFormat:@"%@ Points",numberAsString];;
        
		
    }else{
		
        strPoints = @"100 Points";
        
    }
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:strPoints    attributes:dictFont1]];
    //[attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Points"      attributes:dictFont2]];
    
    [btnCurrency setAttributedTitle:attString forState:UIControlStateNormal];
    
    
}



@end
