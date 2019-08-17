//
//  PlayerVideoCell.h
//  Watchback
//
//  Created by Nilesh on 7/31/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>
@interface PlayerVideoCell : UITableViewCell
{
    
}
@property(strong)IBOutlet UIImageView *m_imgView;
@property(strong)IBOutlet UILabel *m_lblTitle;
@property(strong)IBOutlet UILabel *m_lblSubTitle;
@property(strong)IBOutlet UILabel *m_lblTime;
//@property(strong)IBOutlet UILabel *m_lblWatched;
@property(strong)IBOutlet UIView *m_viewPlayingNow;
@property(strong)IBOutlet UILabel *m_lblPlayingNow;
-(void)setTitle:(NSString *)strTitle subTitle:(NSString *)strSubTitle;
-(void)setData:(NSDictionary *)dict;
@end
