//
//  FavoriteCell.m
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "FavoriteCell.h"
#import "FavoriteCollectionViewCell.h"
#import "Constants.h"

@implementation FavoriteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
     typeof(self) __weak weakSelf = self;
    
    self.fav_collectionview.dataSource = weakSelf;
    self.fav_collectionview.delegate = weakSelf;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _ary_fav_items.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FavoriteCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fav" forIndexPath:indexPath];
    [cell setChannel:[_ary_fav_items objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenChannelNotification object:[self->_ary_fav_items objectAtIndex:indexPath.row]];
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 140);
}

//- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(10, 16, 10, 10); // top, left, bottom, right
//}


@end
