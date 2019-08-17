//
//  BrandVideoCell.h
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface BrandVideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imvVideoBackground;
@property (weak, nonatomic) IBOutlet UILabel * lblVideoName;
-(void)setBrandVideo:(NSDictionary *)videodetails;
@end

NS_ASSUME_NONNULL_END
