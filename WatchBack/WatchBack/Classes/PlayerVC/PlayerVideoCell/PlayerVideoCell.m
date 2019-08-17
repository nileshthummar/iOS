//
//  PlayerVideoCell.m
//  Watchback
//
//  Created by Nilesh on 7/31/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "PlayerVideoCell.h"
#import "JLManager.h"
@interface PlayerVideoCell ()
{
    NSString *m_strCurrentVideoID;
}
@end
@implementation PlayerVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.m_imgView.layer.cornerRadius = 3;
    self.m_imgView.clipsToBounds = TRUE;
    
    self.m_lblTime.layer.cornerRadius = 3;
    self.m_lblTime.clipsToBounds = TRUE;
    
    self.m_lblTitle.font = [[JLManager sharedManager] getVideoLargeTitleFont];
    
    self.m_lblPlayingNow.font = kFontPrimary12;
}
-(void)setTitle:(NSString *)strTitle subTitle:(NSString *)strSubTitle{
    
    
    
    CGRect rectImage = self.m_imgView.frame;
    CGRect rectTitle = CGRectMake(CGRectGetMaxX(rectImage)+16, 16, (self.bounds.size.width-(CGRectGetMaxX(rectImage)+16)-16), 0);
    CGRect rectSubTitle = CGRectMake(CGRectGetMaxX(rectImage)+16, 16, (self.bounds.size.width-(CGRectGetMaxX(rectImage)+16)-16), 0);
    self.m_lblTitle.frame = rectTitle;
    
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.firstLineHeadIndent = 0.0f;
    style.headIndent = 0.0f;
    style.tailIndent = 0.0f;
    
    
    NSAttributedString *attrTextTitle = [[NSAttributedString alloc] initWithString:strTitle attributes:@{ NSParagraphStyleAttributeName : style}];
    
    self.m_lblTitle.attributedText = attrTextTitle;
    self.m_lblTitle.font = [[JLManager sharedManager] getVideoTitleFont];
    self.m_lblTitle.numberOfLines =4;
    self.m_lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.m_lblTitle.textColor = kPrimaryTextColor;
    
    [self.m_lblTitle sizeToFit];
    
    ///
    rectTitle = self.m_lblTitle.frame;
    if (rectTitle.size.height > self.m_lblTitle.font.pointSize * 5) {
        rectTitle.size.height = self.m_lblTitle.font.pointSize * 5;
    }
    
    if (strSubTitle.length > 0) {
        NSAttributedString *attrTextSubTitle = [[NSAttributedString alloc] initWithString:strSubTitle attributes:@{ NSParagraphStyleAttributeName : style}];
        self.m_lblSubTitle.numberOfLines = 1;
        self.m_lblSubTitle.attributedText = attrTextSubTitle;
        self.m_lblSubTitle.font = [[JLManager sharedManager] getSubTitleFont];
        self.m_lblSubTitle.textColor = kCommonColor;
        
        rectSubTitle.size.height = self.m_lblSubTitle.font.pointSize+5;
        self.m_lblSubTitle.hidden = FALSE;
        CGFloat fTotalHeight = rectTitle.size.height + rectSubTitle.size.height;
        rectTitle.origin.y = (self.bounds.size.height-fTotalHeight)/2;
        rectSubTitle.origin.y = CGRectGetMaxY(rectTitle);
        self.m_lblSubTitle.frame = rectSubTitle;
    }
    else{
        rectTitle.origin.y = (self.bounds.size.height-rectTitle.size.height)/2;
        self.m_lblSubTitle.hidden = TRUE;
    }
    self.m_lblTitle.frame = rectTitle;
    
    
    ///
//    [self.m_lblWatched sizeToFit];
//    CGRect rectWatched = self.m_lblWatched.frame;
//    rectWatched.size.width += 10;
//    rectWatched.size.height += 10;
//    CGRect imgRect = self.m_imgView.frame;
//    rectWatched.origin.x = CGRectGetMaxX(imgRect)-rectWatched.size.width-5;
//    rectWatched.origin.y = CGRectGetMinY(imgRect)+5;
//    self.m_lblWatched.frame = rectWatched;
//    self.m_lblWatched.layer.cornerRadius = 3;
//    self.m_lblWatched.clipsToBounds = TRUE;
   // self.m_lblWatched.hidden = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserWatchedVideoData:) name:kUserWatchedVideoNotification object:nil];
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
    
    /////
    self.m_imgView.userInteractionEnabled = FALSE;
    
    self.m_imgView.image = nil;
    NSString *image =[dict objectForKey:@"thumbnail"];
    [self.m_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",image]] placeholderImage:nil];
//    [self.m_imgView setImageURL:];
    
    /////
    float milliseconds = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"duration"]] floatValue];
    float time = milliseconds / 1000;
    int hours = (int)(time / (60*60))%24;
    int minutes = (int)(time / 60)%60;
    int seconds = ((int)time) % 60;
    if (hours > 0) {
        self.m_lblTime.text = [NSString stringWithFormat:@"%d:%02d:%02d",hours, minutes, seconds];
    }
    else{
        self.m_lblTime.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    
    [self.m_lblTime sizeToFit];
    CGRect rectTime = self.m_lblTime.frame;
    rectTime.size.width += 10;
    rectTime.size.height += 10;
    CGRect rectImage = self.m_imgView.frame;
    rectTime.origin.x = CGRectGetMaxX(rectImage)-rectTime.size.width-5;
    rectTime.origin.y = CGRectGetMaxY(rectImage)-rectTime.size.height-5;
    self.m_lblTime.frame = rectTime;
   
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
