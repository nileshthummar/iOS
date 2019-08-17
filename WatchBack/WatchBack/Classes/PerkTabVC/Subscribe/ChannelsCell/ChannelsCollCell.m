//
//  ChannelsCollCell.m
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "ChannelsCollCell.h"
#import "JLManager.h"
@interface ChannelsCollCell ()
{
    NSString *m_strCurrentVideoID;
}
@end
@implementation ChannelsCollCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.m_imgView.layer.cornerRadius = 3;
    self.m_imgView.clipsToBounds = TRUE;
   
}
-(void)layoutSubviews{
    [super layoutSubviews];
   // self.gradientMask.frame = self.m_lblTitle.bounds;
}
-(void)setData:(NSDictionary *)dict{
    self.m_imgView.image = nil;
//    self.m_imgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"background_image_url"]]];
    [self.m_imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"background_image_url"]]] placeholderImage:nil];
    NSString *strName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    self.m_lblTitle.text = strName;    
}
@end
