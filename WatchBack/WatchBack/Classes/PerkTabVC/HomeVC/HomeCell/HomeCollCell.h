//
//  HomeCollCell.h
//  Watchback
//
//  Created by Nilesh on 12/6/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>
@interface HomeCollCell : UICollectionViewCell{
    
}
@property(strong)IBOutlet UIImageView *m_imgView;
@property(strong)IBOutlet UILabel *m_lblTitle;
@property(strong)IBOutlet UILabel *m_lblChannelName;
@property(strong)IBOutlet UILabel *m_lblTime;
//@property(strong)IBOutlet  UILabel *m_lblWatched;
-(void)setData:(NSDictionary *)dict;
@end
