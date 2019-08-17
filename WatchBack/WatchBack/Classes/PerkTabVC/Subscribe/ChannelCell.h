//
//  ChannelCell.h
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChannelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIStackView *stackChannel;
@property (weak, nonatomic) IBOutlet ViewChannel *channelA;
@property (weak, nonatomic) IBOutlet ViewChannel *channelB;
@property (weak, nonatomic) IBOutlet ViewChannel *channelC;

@end

NS_ASSUME_NONNULL_END
