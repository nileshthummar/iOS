//
//  BrandPortalVC.h
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BrandPortalVC : UIViewController
@property (atomic,strong) NSDictionary * dict_channel_info;
@property (atomic, readwrite) BOOL isfavorite;
@end

NS_ASSUME_NONNULL_END
