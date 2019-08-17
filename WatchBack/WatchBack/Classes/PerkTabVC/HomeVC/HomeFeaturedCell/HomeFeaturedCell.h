//
//  HomeFeaturedCell.h
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFeaturedView.h"
@interface HomeFeaturedCell : UITableViewCell
{
    NSArray *m_arrVideos;
}
@property(strong)IBOutlet HomeFeaturedView *m_featuredView;
-(void)updateData:(NSArray *)arr;
@end
