//
//  WelcomeCarouselCell.m
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "WelcomeCarouselCell.h"
#import "Constants.h"
#import "JLManager.h"
@implementation WelcomeCarouselCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       // CGFloat fTitleMargin = 16;
        CGFloat fTitleHeight = 70;
        
        CGFloat fMargin = 0;
        CGFloat fWidth = frame.size.width- (fMargin * 2);
        CGFloat fHeight = frame.size.height;
        CGRect imgRect =CGRectMake(fMargin,fMargin, fWidth, fHeight-fTitleHeight);
        
        self.m_imgView = [[UIImageView alloc] initWithFrame:imgRect];
        self.m_imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.m_imgView.contentMode = UIViewContentModeScaleAspectFill;
         self.m_imgView.clipsToBounds = TRUE;
        [self addSubview:self.m_imgView];
        /////
             
    }
    return self;
}
@end
