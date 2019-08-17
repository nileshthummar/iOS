//
//  SettingsTableViewCell.m
//  Watchback
//
//  Created by perk on 02/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "SettingsTableViewCell.h"

@implementation SettingsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor blackColor];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(NSDictionary *)data{
    if(data != nil && (id)data != [NSNull null]){
        if([data valueForKey:@"name"] != nil &&
           [data valueForKey:@"name"] != nil){
            self.lblTitle.text = [data valueForKey:@"name"];
        }
        if([data valueForKey:@"image"] != nil &&
           [data valueForKey:@"image"] != nil){
            self.imvIcon.image = [UIImage imageNamed: [data valueForKey:@"image"]];
        }else{
            self.leadingspaceConstraint_lblTitle.constant = 16;
        }
        
        
    }
}

@end
