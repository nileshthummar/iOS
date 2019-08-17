//
//  BrandVideoCell.m
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "BrandVideoCell.h"

@implementation BrandVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.imvVideoBackground.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setBrandVideo:(NSDictionary *)videodetails{
    if(videodetails != nil && (id)videodetails != [NSNull null]){
        if([videodetails valueForKey:@"poster"] != nil &&
           [videodetails valueForKey:@"poster"] != [NSNull null]){
            NSURL * imageURL = [NSURL URLWithString:[videodetails valueForKey:@"poster"]];
            if(imageURL){
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.imvVideoBackground setImageURL:imageURL];
                    [self.imvVideoBackground sd_setImageWithURL:imageURL placeholderImage:nil];
                });
            }
        }
        
        if([videodetails valueForKey:@"name"] != nil &&
           [videodetails valueForKey:@"name"] != [NSNull null]){
            self.lblVideoName.text = [videodetails valueForKey:@"name"];
        }
        
    }
}

@end
