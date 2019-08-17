//
//  HomeFeaturedView.h
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "AppBGView.h"
#import "AppSecondBGView.h"
@interface HomeFeaturedView : AppSecondBGView<iCarouselDelegate,iCarouselDataSource>
{
    NSMutableArray *m_arrVideos;
    NSTimer *m_timerAutoScroll;    
}
@property(strong)IBOutlet iCarousel *carousel;
@property(strong)IBOutlet UIPageControl *pageControl;
@property(strong) NSString *m_strChannelName;
-(void)updateData:(NSArray *)arr;
@end
