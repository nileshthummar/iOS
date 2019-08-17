//
//  SettingsTableViewCell.h
//  Watchback
//
//  Created by perk on 02/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imvIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingspaceConstraint_lblTitle;
-(void)setData:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
