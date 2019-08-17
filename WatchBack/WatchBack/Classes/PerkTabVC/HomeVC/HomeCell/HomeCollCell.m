//
//  HomeCollCell.m
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "HomeCollCell.h"
#import "JLManager.h"
@interface HomeCollCell ()
{
    NSString *m_strCurrentVideoID;
}
@end
@implementation HomeCollCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.m_imgView.layer.cornerRadius = 3;
    self.m_imgView.clipsToBounds = TRUE;
   
    self.m_lblTime.layer.cornerRadius = 3;
    self.m_lblTime.clipsToBounds = TRUE;
    
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
//    self.m_lblWatched.hidden = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserWatchedVideoData:) name:kUserWatchedVideoNotification object:nil];
}
-(void)layoutSubviews{
    [super layoutSubviews];
   // self.gradientMask.frame = self.m_lblTitle.bounds;
}
-(void)setData:(NSDictionary *)dict{
    self.m_imgView.image = nil;
//    self.m_imgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"thumbnail"]]];
    [self.m_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"thumbnail"]]] placeholderImage:nil];
    NSString *strName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    self.m_lblTitle.text = strName;
    
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
    m_strCurrentVideoID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"watched"]] boolValue] || [[JLManager sharedManager] getUserVideoWatched:m_strCurrentVideoID]>0) {
//        self.m_lblWatched.hidden = FALSE;
    }
    else{
//        self.m_lblWatched.hidden = TRUE;
    }
}
-(void)updateUserWatchedVideoData:(id)sender
{
    NSString *strVideoID =[NSString stringWithFormat:@"%@",[sender object]];
    if (strVideoID != nil && m_strCurrentVideoID != nil && [strVideoID isKindOfClass:[NSString class]] && [m_strCurrentVideoID isKindOfClass:[NSString class]] && [strVideoID isEqualToString:m_strCurrentVideoID]) {
//        self.m_lblWatched.hidden = FALSE;
    }
    else{
        //self.m_lblWatched.hidden = TRUE;
    }

}

@end
