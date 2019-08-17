//
//  FavoriteCell.h
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoriteCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *fav_collectionview;
@property (atomic,strong) NSArray * ary_fav_items;
@end

NS_ASSUME_NONNULL_END
