//
//  BrandPortalCell.h
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrandPortalCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imvBrandLogo;
@property (weak, nonatomic) IBOutlet UIButton *btnRequestMoreInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBranddetail;
- (IBAction)btnRequestMoreInfoTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFavorite;
- (IBAction)btnAddFavoriteTapped:(id)sender;
@property (atomic,strong) NSDictionary * brand_info;
@property (atomic, readwrite) BOOL is_favorite;
-(void)setBranddetails:(NSDictionary *)brand_details;
-(void)checkFavorites;
@end

NS_ASSUME_NONNULL_END
