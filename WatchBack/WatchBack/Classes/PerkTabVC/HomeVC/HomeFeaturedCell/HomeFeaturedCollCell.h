//
//  HomeFeaturedCollCell.h
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppLabel.h"
#import "AppSecondBGView.h"
@interface HomeFeaturedCollCell : UIView{
    
}
@property(strong) UIImageView *m_imgView;
@property(strong) UIImageView *m_imgViewBrand;
@property(strong) UIView *m_viewImgBackground;
@property(strong) AppLabel *m_lblTitle;
@property(strong) UILabel *m_lblSubTitle;
//@property(strong) UILabel *m_lblTime;
//@property(strong) UILabel *m_lblWatched;
@property(strong) UIImageView *m_imgViewFeatured;
-(void)setData:(NSDictionary *)dict;
@end
