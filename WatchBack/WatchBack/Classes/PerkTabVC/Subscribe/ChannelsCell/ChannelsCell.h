//
//  ChannelsCell.h
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>
typedef enum{
    kFromHome=0,
    kFromChannel
} kFromType;
@interface ChannelsCell : UITableViewCell
{
    NSArray *m_arrVideos;
}
@property(strong)IBOutlet UICollectionView *m_collView;
@property(strong) NSString *m_strChannelName;
@property(assign) int m_nIndexPathSection;
@property(assign)kFromType mFromType;
-(void)updateData:(NSArray *)arr;
@end
