//
//  FavoriteCollectionViewCell.h
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoriteCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
-(void)setChannel:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
