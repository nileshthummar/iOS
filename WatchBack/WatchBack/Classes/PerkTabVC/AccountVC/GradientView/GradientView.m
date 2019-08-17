//
//  GradientView.m
//  Watchback
//
//  Created by Nilesh on 4/12/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@dynamic layer;

+ (Class)layerClass {
    return [CAGradientLayer class];
}
@end
