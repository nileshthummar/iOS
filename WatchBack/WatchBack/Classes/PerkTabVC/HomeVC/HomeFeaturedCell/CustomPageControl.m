//
//  CustomPageControl.m
//  Watchback
//
//  Created by Nilesh on 6/9/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)layoutSubviews{
    
    CGFloat spacing = 3;
    CGFloat width  = 15 ;
    CGFloat height = 7;
    CGFloat total  = 0;
    
    for (UIView *view in self.subviews) {
        view.layer.cornerRadius = 3;
        view.frame =  CGRectMake(total, 0, width, height);////CGRect(x: total, y: frame.size.height / 2 - height / 2, width: width, height: height)
        // view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 1);
        total += width + spacing;
        
    }
    total -= spacing;
    CGRect frame = self.frame;
    frame.origin.x = frame.origin.x + frame.size.width / 2 - total / 2;
    frame.size.width = total;
    self.frame = frame;
}
@end
