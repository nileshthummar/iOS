//
//  ChannelCell.m
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "ChannelCell.h"

@implementation ChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
