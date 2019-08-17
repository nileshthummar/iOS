//
//  FavoriteCollectionViewCell.m
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "FavoriteCollectionViewCell.h"
#import <SDWebImage.h>

@implementation FavoriteCollectionViewCell
-(void)setChannel:(NSDictionary *)dict{
    
    if(dict != nil && (id)dict != [NSNull null]){
        if([dict valueForKey:@"details_screen_logo_url"] != nil &&
           [dict valueForKey:@"details_screen_logo_url"] != [NSNull null]){
            NSURL * imageURL = [NSURL URLWithString:[dict valueForKey:@"details_screen_logo_url"]];
            [self.imvLogo sd_setImageWithURL:imageURL placeholderImage:nil];
        }else if([dict valueForKey:@"list_screen_logo_url"] != nil &&
                 [dict valueForKey:@"list_screen_logo_url"] != [NSNull null]){
            NSURL * imageURL = [NSURL URLWithString:[dict valueForKey:@"list_screen_logo_url"]];
            [self.imvLogo sd_setImageWithURL:imageURL placeholderImage:nil];
        }
        
        if([dict valueForKey:@"name"] != nil &&
           [dict valueForKey:@"name"] != [NSNull null]){
            self.lblName.text = [dict valueForKey:@"name"];
        }
        
        self.imvLogo.layer.cornerRadius = self.imvLogo.bounds.size.width/2.0;
        self.imvLogo.layer.masksToBounds = YES;
    }
}

@end
