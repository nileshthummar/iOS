//
//  HomeFeaturedCell.m
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "HomeFeaturedCell.h"
#import "PlayerVC.h"
#import "NavPortrait.h"
#import "JLManager.h"
@implementation HomeFeaturedCell
-(void)updateData:(NSArray *)arr{
    if (m_arrVideos != nil && [m_arrVideos isKindOfClass:[NSArray class]]) {
        NSSet *set1 = [NSSet setWithArray:m_arrVideos];
        NSSet *set2 = [NSSet setWithArray:arr];
        
        if ([set1 isEqualToSet:set2]) {
            return;
        }
    }
    m_arrVideos = arr;
    [self.m_featuredView updateData:arr];
    
}
//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//}

@end
