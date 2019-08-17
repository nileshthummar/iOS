//
//  HomeFeaturedCollCell.m
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "HomeFeaturedCollCell.h"
#import "Constants.h"
#import "JLManager.h"
#import <SDWebImage/SDWebImage.h>
@interface HomeFeaturedCollCell ()
{
    NSString *m_strCurrentVideoID;
}
@end
@implementation HomeFeaturedCollCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
      //  AppSecondBGView *objAppSecondBGView = [[AppSecondBGView alloc] initWithFrame:self.bounds];
      //  [self addSubview:objAppSecondBGView];
        //self.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:34.0/255.0 blue:44.0/255.0 alpha:1];
        CGFloat fMargin = 16;
        CGFloat fWidth = frame.size.width- (fMargin * 2);
        CGFloat fHeight = fWidth*9/16;
        CGFloat fBrandImageWidthHeight = 33;
        
        CGFloat image_rect_offset = 4;
        
        CGRect imgRect =CGRectMake(image_rect_offset,image_rect_offset, frame.size.width- (image_rect_offset * 2), fHeight);
        
        self.m_viewImgBackground = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imgRect)-4, CGRectGetMinY(imgRect)-4, imgRect.size.width+8, imgRect.size.height+8)];
        [self addSubview:self.m_viewImgBackground];
        self.m_viewImgBackground.hidden = TRUE;
        
        self.m_imgView = [[UIImageView alloc] initWithFrame:imgRect];
        self.m_imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.m_imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.m_imgView];
        /////
        
        self.m_imgViewBrand = [[UIImageView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(imgRect)+15, fBrandImageWidthHeight, fBrandImageWidthHeight)];
        self.m_imgViewBrand.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.m_imgViewBrand.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.m_imgViewBrand];
        
        
        
        self.m_imgViewBrand.layer.cornerRadius = self.m_imgViewBrand.frame.size.width / 2;
        self.m_imgViewBrand.clipsToBounds = TRUE;
        ////
        
        self.m_lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(46,CGRectGetMaxY(imgRect)+8, frame.size.width-62, 30)];
        self.m_lblTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.m_lblTitle.font = [[JLManager sharedManager] getVideoLargeTitleFont];
        self.m_lblTitle.numberOfLines =0;
        self.m_lblTitle.backgroundColor = [UIColor clearColor];
        self.m_lblTitle.textColor = kPrimaryTextColor;
        [self addSubview:self.m_lblTitle];
       
    
        self.m_lblSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(46,CGRectGetMaxY(imgRect)+30+10, frame.size.width-62, 30)];
        self.m_lblSubTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.m_lblSubTitle.font =  [[JLManager sharedManager] getSubTitleFont];
        self.m_lblSubTitle.numberOfLines = 0;
        self.m_lblSubTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.m_lblSubTitle.backgroundColor = [UIColor clearColor];
        self.m_lblSubTitle.textColor = kCommonColor;
        [self addSubview:self.m_lblSubTitle];
        
        ///
        
//        self.m_lblTime = [[UILabel alloc] initWithFrame:CGRectMake(imgRect.size.width-100,imgRect.size.height-100, 100, 21)];
//        self.m_lblTime.backgroundColor = [UIColor redColor];
//        self.m_lblTime.textAlignment = NSTextAlignmentCenter;
//        self.m_lblTime.textColor = [UIColor whiteColor];
//        self.m_lblTime.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:9];
//        [self addSubview:self.m_lblTime];
       
//        self.m_lblWatched = [[UILabel alloc] init];
//        self.m_lblWatched.backgroundColor = [UIColor blackColor];
//        self.m_lblWatched.textAlignment = NSTextAlignmentCenter;
//        self.m_lblWatched.textColor = [UIColor whiteColor];
//        self.m_lblWatched.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:9];
//        [self addSubview:self.m_lblWatched];
//        self.m_lblWatched.text = @"WATCHED";
//        self.m_lblWatched.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
//
//        [self.m_lblWatched sizeToFit];
//        CGRect rectWatched = self.m_lblWatched.frame;
//        rectWatched.size.width += 10;
//        rectWatched.size.height += 10;
//
//        rectWatched.origin.x = CGRectGetMaxX(imgRect)-rectWatched.size.width-10;
//        rectWatched.origin.y = CGRectGetMinY(imgRect)+10;
//        self.m_lblWatched.frame = rectWatched;
//        self.m_lblWatched.layer.cornerRadius = 3;
//        self.m_lblWatched.clipsToBounds = TRUE;
//        self.m_lblWatched.hidden = TRUE;
        
        ////
        self.m_imgView.layer.cornerRadius = 6;
        self.m_imgView.clipsToBounds = TRUE;
        
        self.m_viewImgBackground.layer.cornerRadius = 6;
        self.m_viewImgBackground.clipsToBounds = TRUE;
        
//        self.m_lblTime.layer.cornerRadius = 3;
//        self.m_lblTime.clipsToBounds = TRUE;
        /////
        
        
        self.m_imgViewFeatured = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(imgRect)+10, CGRectGetMaxY(imgRect)-30, 150, 20)];
        self.m_imgViewFeatured.contentMode = UIViewContentModeScaleAspectFit;
        self.m_imgViewFeatured.clipsToBounds = TRUE;
        //self.m_imgViewFeatured.image = [UIImage imageNamed:@"featured-tag"];
        [self addSubview:self.m_imgViewFeatured];
        
        
        self.m_imgViewFeatured.hidden = TRUE;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserWatchedVideoData:) name:kUserWatchedVideoNotification object:nil];
        
        
    }
    return self;
}

-(void)updateUserWatchedVideoData:(id)sender
{
    NSString *strVideoID =[NSString stringWithFormat:@"%@",[sender object]];
    if (strVideoID != nil && m_strCurrentVideoID != nil && [strVideoID isKindOfClass:[NSString class]] && [m_strCurrentVideoID isKindOfClass:[NSString class]] && [strVideoID isEqualToString:m_strCurrentVideoID]) {
//        self.m_lblWatched.hidden = FALSE;
    }
    else{
       // self.m_lblWatched.hidden = TRUE;
    }
    
}
-(void)setData:(NSDictionary *)dict{
    ///
    BOOL bLongform = FALSE;
    //NSString *content_provider = @"";
    
    NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
    }
    //    view.m_imgView.image = nil;
    //    view.m_imgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"poster"]]];
    self.m_lblTitle.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    self.m_lblTitle.textColor = kPrimaryTextColor;
    NSString *strSubtitle;
    if([dict valueForKey:@"custom_fields"] != nil && [dict valueForKey:@"custom_fields"] != [NSNull null]){
        if([[dict valueForKey:@"custom_fields"] valueForKey:@"provider"] != nil &&
           [[dict valueForKey:@"custom_fields"] valueForKey:@"provider"] != [NSNull null]){
            strSubtitle = [[dict valueForKey:@"custom_fields"] valueForKey:@"provider"];
        }
    }

    if (strSubtitle == nil || [strSubtitle isEqualToString:@"(null)"] || [strSubtitle isEqualToString:@"<null>"] || [strSubtitle isEqualToString:@"unknown"]) {
        strSubtitle = @"";
    }
    
    NSString *bottom_left_icon_url = [NSString stringWithFormat:@"%@",[dict objectForKey:@"bottom_left_icon_url"]];
    if (bottom_left_icon_url != nil && [bottom_left_icon_url isKindOfClass:[NSString class]] && bottom_left_icon_url.length > 0 ) {
        self.m_imgViewFeatured.hidden = FALSE;
        //self.m_imgViewFeatured.imageURL =[NSURL URLWithString:bottom_left_icon_url];
        [self.m_imgViewFeatured sd_setImageWithURL:[NSURL URLWithString:bottom_left_icon_url] placeholderImage:nil];
    }
    else{
        self.m_imgViewFeatured.hidden = TRUE;
    }
//    NSString *has_gold_border = [NSString stringWithFormat:@"%@",[dict objectForKey:@"has_gold_border"]];
    NSString *has_gold_border = @"1"; //earlier we used to depend upon api response, but now we are keeping it fixed from client side.

    NSString *type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
    self.m_viewImgBackground.layer.borderWidth = 0;
    if ([has_gold_border boolValue]) {
        //////
        self.m_viewImgBackground.hidden = FALSE;
        CAGradientLayer *gradientMask = [CAGradientLayer layer];
        gradientMask.frame = self.m_viewImgBackground.bounds;
        gradientMask.colors = @[
                                (id)[UIColor colorWithRed:229.0/255.0 green:205.0/255.0 blue:93.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:199.0/255.0 green:161.0/255.0 blue:67.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:245.0/255.0 green:236.0/255.0 blue:155.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:216.0/255.0 green:189.0/255.0 blue:100.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:254.0/255.0 green:213.0/255.0 blue:144.0/255.0 alpha:1].CGColor];
        
        gradientMask.startPoint = CGPointMake(0.0, 0.5);
        gradientMask.endPoint = CGPointMake(1.0, 0.5);
        [self.m_viewImgBackground.layer addSublayer:gradientMask];
        
        /////
    }
    else if (![type isEqualToString:@"url"]) {
        //////
        self.m_viewImgBackground.hidden = FALSE;
        CAGradientLayer *gradientMask = [CAGradientLayer layer];
        gradientMask.frame = self.m_viewImgBackground.bounds;
        gradientMask.colors = @[
                                (id)[UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:193.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1].CGColor,
                                (id)[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1].CGColor];
        
        
        gradientMask.startPoint = CGPointMake(0.0, 0.5);
        gradientMask.endPoint = CGPointMake(1.0, 0.5);
        [self.m_viewImgBackground.layer addSublayer:gradientMask];
        self.m_viewImgBackground.layer.borderWidth = 1;
        self.m_viewImgBackground.layer.borderColor = [UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1].CGColor;
        /////
    }
    self.m_lblSubTitle.text = [strSubtitle capitalizedString];
    CGFloat fMargin = 16;
    
    NSString *image_url ;
    if([dict valueForKey:@"channel"] != nil &&
       [dict valueForKey:@"channel"] != [NSNull null]){
        if([[dict valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"] != nil &&
           [[dict valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"] != [NSNull null]){
            image_url = [[dict valueForKey:@"channel"] valueForKey:@"details_screen_logo_url"];
        }
    }

    
   // if (bLongform)
    if (image_url && [image_url isKindOfClass:[NSString class]] && image_url.length > 0)         
    {
        
        self.m_imgViewBrand.hidden = FALSE;
        float xstart = 38;
        //self.m_imgViewBrand.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_url"]]];
        [self.m_imgViewBrand sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:nil];
        CGRect imgRect = self.m_imgView.frame;
        self.m_lblTitle.frame = CGRectMake(CGRectGetMinX(imgRect)+xstart,CGRectGetMaxY(imgRect)+fMargin, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)+xstart), 50);
        [self.m_lblTitle sizeToFit];
        
        self.m_lblSubTitle.frame = CGRectMake(CGRectGetMinX(imgRect)+xstart,CGRectGetMaxY(self.m_lblTitle.frame)+10, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)+xstart), 30);
        [self.m_lblSubTitle sizeToFit];
        
    }
    else{
        // view.m_imgView.layer.borderWidth = 0;
        //view.m_viewImgBackground.hidden = TRUE;
        self.m_imgViewBrand.hidden = TRUE;
        CGRect imgRect = self.m_imgView.frame;
        self.m_lblTitle.frame = CGRectMake(CGRectGetMinX(imgRect)-4,CGRectGetMaxY(imgRect)+fMargin, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)), 50);
        [self.m_lblTitle sizeToFit];
        self.m_lblSubTitle.frame = CGRectMake(CGRectGetMinX(imgRect)-4,CGRectGetMaxY(self.m_lblTitle.frame)+10, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)), 30);
        [self.m_lblSubTitle sizeToFit];
        
    }
    
    self.m_imgView.image = nil;
   // self.m_imgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"poster"]]];
     [self.m_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"poster"]]] placeholderImage:nil];
    
//    if ([type isEqualToString:@"url"]) {
//        self.m_lblTime.hidden = TRUE;
//    }
//    else{
//        /////
//        self.m_lblTime.hidden = FALSE;
//        float milliseconds = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"duration"]] floatValue];
//        float time = milliseconds / 1000;
//        if (time <= 0) {
//            self.m_lblTime.hidden = TRUE;
//        }
//        int hours = (int)(time / (60*60))%24;
//        int minutes = (int)(time / 60)%60;
//        int seconds = ((int)time) % 60;
//        if (hours > 0) {
//            self.m_lblTime.text = [NSString stringWithFormat:@"%d:%02d:%02d",hours, minutes, seconds];
//        }
//        else{
//            self.m_lblTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
//        }
//
//
//        [self.m_lblTime sizeToFit];
//        CGRect rectTime = self.m_lblTime.frame;
//        rectTime.size.width += 10;
//        rectTime.size.height += 10;
//        CGRect rectImage = self.m_imgView.frame;
//        rectTime.origin.x = CGRectGetMaxX(rectImage)-rectTime.size.width-10;
//        rectTime.origin.y = CGRectGetMaxY(rectImage)-rectTime.size.height-10;
//        self.m_lblTime.frame = rectTime;
//        /////
//    }
    ////
    m_strCurrentVideoID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"watched"]] boolValue] || [[JLManager sharedManager] getUserVideoWatched:m_strCurrentVideoID]>0) {
//        self.m_lblWatched.hidden = FALSE;
    }
    else{
//        self.m_lblWatched.hidden = TRUE;
    }
    
    ////
}
@end
