//
//  ChannelsCell.m
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "ChannelsCell.h"
#import "ChannelsCollCell.h"
#import "PlayerVC.h"
#import "NavBoth.h"
#import "JLManager.h"
#define kCellWidth 158
#define kCellHeight 145
@implementation ChannelsCell
-(void)updateData:(NSArray *)arr{
    if (m_arrVideos != nil && [m_arrVideos isKindOfClass:[NSArray class]]) {
        NSSet *set1 = [NSSet setWithArray:m_arrVideos];
        NSSet *set2 = [NSSet setWithArray:arr];
        
        if ([set1 isEqualToSet:set2]) {
            return;
        }
    }
    
    m_arrVideos = arr;
    [self.m_collView reloadData];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kCellWidth, kCellHeight);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    
    [self.m_collView setCollectionViewLayout:flowLayout];
    [self.m_collView registerNib:[UINib nibWithNibName:@"ChannelsCollCell" bundle:nil]   forCellWithReuseIdentifier: @"CellChannelsColl"];
   // self.m_collView.allowsMultipleSelection = true;
}
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    
//}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
#pragma mark --collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return m_arrVideos.count;
}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CellChannelsColl";
    ChannelsCollCell * channelsCollCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!channelsCollCell)
    {
        [collectionView registerNib:[UINib nibWithNibName:@"ChannelsCollCell" bundle:nil] forCellWithReuseIdentifier:identifier];
        channelsCollCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    }
  
    channelsCollCell.backgroundColor = [UIColor clearColor];
    /////////
    NSDictionary *dict = [m_arrVideos objectAtIndex:indexPath.row];
    [channelsCollCell setData:dict];
    ///////
    return channelsCollCell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[ChannelsCollCell class]]) {
        ChannelsCollCell *channelsCollCell = (ChannelsCollCell *)cell;
        channelsCollCell.m_lblTitle.frame = CGRectMake(0, 84+11, kCellWidth, 30);
        [channelsCollCell.m_lblTitle sizeToFit];
        
    }
    
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 16, 10, 10); // top, left, bottom, right
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    int nIndex = (int)indexPath.row;
    [[JLManager sharedManager] dismissPresentedControllerIfAny];
    PlayerVC *objPlayerVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
    objPlayerVC.m_nCurrentIndex = nIndex;
    objPlayerVC.m_arrPlaylistVideos = [NSMutableArray arrayWithArray:m_arrVideos];
    objPlayerVC.m_strChannelName  = self.m_strChannelName;
    if(self.mFromType == kFromChannel) objPlayerVC.m_bIsNotFromChannel = TRUE;
    NavBoth *nav = [[NavBoth alloc] initWithRootViewController:objPlayerVC];
    
    [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    
    [dictTrackingData setObject:@"Click:Video" forKey:@"tve.userpath"];
    [dictTrackingData setObject:[NSString stringWithFormat:@"%@:%d:%d",(self.mFromType == kFromChannel)?@"channels":@"home", self.m_nIndexPathSection+1, nIndex+1] forKey:@"tve.module"];
    
    ///
    NSDictionary *dictCurrentVideo = [m_arrVideos objectAtIndex:nIndex];
    BOOL bLongform = FALSE;
    NSString *content_provider = @"Undefined";
    NSString *program = @"Undefined";
    NSDictionary *custom_fields = [dictCurrentVideo objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            program = show;
        }
    }
    if (bLongform) {
        [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
    }
    else{
        [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
    }
    NSString *episode_title = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"name"]];
    [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
    [dictTrackingData setObject:program forKey:@"tve.program"];
    [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
    ///
    if (self.mFromType == kFromChannel) {
        [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.contenthub"];
    }
    else{
       [dictTrackingData setObject:@"Featured" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Featured" forKey:@"tve.contenthub"];
    }
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Video" data:dictTrackingData];
    
}
@end
