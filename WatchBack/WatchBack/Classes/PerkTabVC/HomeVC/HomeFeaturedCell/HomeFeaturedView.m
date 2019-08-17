//
//  HomeFeaturedView.m
//  Watchback
//
//  Created by Nilesh on 7/30/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "HomeFeaturedView.h"
#import "HomeFeaturedCollCell.h"
#import "VideoDetailsVC.h"
#import "NavBoth.h"
#import "JLManager.h"
#import "HomeFeaturedCollCell.h"
#import "AppSecondBGView.h"
#import "RedeemWebVC.h"
#import "NavPortrait.h"
@implementation HomeFeaturedView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.carousel = [[iCarousel alloc] init];
    self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.carousel];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.pageControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    
}

-(void)updateData:(NSArray *)arr{
    //m_arrVideos = arr;
    m_arrVideos = [arr mutableCopy];
    /////
    CGRect rectCarousel;
    if (m_arrVideos.count > 1) {
        rectCarousel =  CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)-20);
        
        // self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds)-20, CGRectGetMaxX(self.bounds), 20)];
        self.pageControl.frame =CGRectMake(0, CGRectGetMaxY(self.bounds)-25, CGRectGetMaxX(self.bounds), 20);
        
        
        self.pageControl.tintColor = kCommonColor;
        self.pageControl.pageIndicatorTintColor  = kCommonColor;
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55 alpha:1];
        
    }
    else{
        rectCarousel = self.bounds;// CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)-10);
    }
    //self.carousel = [[iCarousel alloc] initWithFrame:rectCarousel];
    self.carousel.frame = rectCarousel;
    
    
    
   
    
  //  self.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:33.0/255.0 green:34.0/255.0 blue:44.0/255.0 alpha:1];
    self.carousel.type = iCarouselTypeLinear;
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.bounces = FALSE;
    self.carousel.pagingEnabled = TRUE;
    ////
    [self.carousel reloadData];
    
    if(m_arrVideos.count > 1)
    {
       [self performSelector:@selector(startAutoScrollTimer) withObject:nil afterDelay:2];
        self.carousel.scrollEnabled = TRUE;
        self.pageControl.hidden = FALSE;
        //self.carousel.frame = CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)-20);
    }
    else{
        self.carousel.scrollEnabled = FALSE;
        self.pageControl.hidden = TRUE;
        //self.carousel.frame = CGRectMake(0, 0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)-10);
    }
    self.pageControl.numberOfPages = arr.count;
    
}
//- (void)awakeFromNib {
//    [super awakeFromNib];
//   // self.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:34.0/255.0 blue:44.0/255.0 alpha:1];
//    self.carousel.type = iCarouselTypeLinear;
//    self.carousel.dataSource = self;
//    self.carousel.delegate = self;
//    self.carousel.bounces = FALSE;
//    self.carousel.pagingEnabled = TRUE;
//    
//}

#pragma mark --collectionview delegate
#pragma mark --auto scroll
-(void)startAutoScrollTimer
{
    [self stopAutoScrollTimer];
    m_timerAutoScroll = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(scrollNext) userInfo:nil repeats:YES];
    
}
-(void)stopAutoScrollTimer
{
    if(m_timerAutoScroll)
    {
        [m_timerAutoScroll invalidate];
        m_timerAutoScroll = nil;
    }
}
-(void)scrollNext
{
    if (self.window != nil) {
        // do stuff
        if(m_arrVideos.count > 1)
        {
            
            NSInteger currentIndex = self.carousel.currentItemIndex;
            [self.carousel scrollToItemAtIndex:currentIndex+1 animated:YES];
            
        }
    }
    else{
        if(kDebugLog)NSLog(@"not visible");
    }
    
}

#pragma  mark --carousel

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [m_arrVideos count];
}

- (HomeFeaturedCollCell *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(HomeFeaturedCollCell *)view
{
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[HomeFeaturedCollCell alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.carousel.bounds), CGRectGetMaxY(self.carousel.bounds))];
    }
    else
    {
        //get a reference to the label in the recycled view
    }
    
    view.backgroundColor = [UIColor clearColor];
    
    ///
    NSDictionary *dict = [m_arrVideos objectAtIndex:index];
    [view setData:dict];
    return view;
}
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap)
    {
        return YES;
    }
    return value;
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    self.pageControl.currentPage = carousel.currentItemIndex;
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    int nIndex = (int)index;
    if (nIndex < m_arrVideos.count) {
        NSDictionary *dict = [m_arrVideos objectAtIndex:nIndex];
        NSString *type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
        if ([type isEqualToString:@"url"]) {
            
            NSString *strUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"value"]];
            if([strUrl rangeOfString:@"watchback://"].location != NSNotFound
               ){
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:nil];
                
            }
            else if([strUrl rangeOfString:@"leanplum://"].location != NSNotFound
                    ){
                strUrl = [strUrl stringByReplacingOccurrencesOfString:@"leanplum://" withString:@""];
                [[JLTrackers sharedTracker] trackLeanplumEvent:@"featured_url_tap" param:@{@"url":strUrl}];
            }
            else{
                RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
                NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
                nav.navigationBarHidden = FALSE;
                objRedeemWebVC.m_strUrl = strUrl;
                objRedeemWebVC.title = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
            }
            ///
            [[JLTrackers sharedTracker] trackFBEvent:@"featured_content_tap" params:@{@"url":strUrl}];
            ///
            return;
        }
    }
    ////
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];;
    @try {
        
        for(int i = 0; i < m_arrVideos.count; i++)
        {
            NSDictionary *dict = [m_arrVideos objectAtIndex:i];
            NSString *type = [NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
            if ([type isEqualToString:@"url"]) {
                
                if (index > i) {
                    nIndex--;
                }
            }
            else{
                [arrTemp addObject:dict];
            }
           
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    ////
    [[JLManager sharedManager] dismissPresentedControllerIfAny];
    VideoDetailsVC *objVideoDetailsVC = [[VideoDetailsVC alloc] initWithNibName:@"VideoDetailsVC" bundle:nil];
    objVideoDetailsVC.m_nCurrentIndex = nIndex;
    objVideoDetailsVC.m_arrPlaylistVideos = arrTemp;
    objVideoDetailsVC.m_strChannelName  = self.m_strChannelName;
    objVideoDetailsVC.m_bIsFeaturedContent = TRUE;
    NavPortrait *nav = [[NavPortrait alloc] initWithRootViewController:objVideoDetailsVC];
    ///
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[[JLManager sharedManager] topViewController].view.window.layer addAnimation:transition forKey:kCATransition];
    ///
    [[[JLManager sharedManager] topViewController] presentViewController:nav animated:NO completion:nil];
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Featured" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Video" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Featured" forKey:@"tve.contenthub"];
    [dictTrackingData setObject:[NSString stringWithFormat:@"home:1:%d",nIndex+1] forKey:@"tve.module"];
    ///
    NSDictionary *dictCurrentVideo = [arrTemp objectAtIndex:nIndex];
    BOOL bLongform = FALSE;
    NSString *content_provider = @"Undefined";
    NSString *program = @"Undefined";
    NSDictionary *custom_fields = [dictCurrentVideo objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            content_provider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            program = show;
        }
    }
    if (bLongform) {
        [dictTrackingData setObject:@"VOD Episode" forKey:@"tve.contenttype"];
    }
    else{
        [dictTrackingData setObject:@"VOD Clip" forKey:@"tve.contenttype"];
    }
    NSString *episode_title = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"name"]];
    [dictTrackingData setObject:content_provider forKey:@"tve.contentprovider"];
    [dictTrackingData setObject:program forKey:@"tve.program"];
    [dictTrackingData setObject:episode_title forKey:@"tve.episodetitle"];
    ///
    
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Video" data:dictTrackingData];
    ////////
    ///
    NSString *strVideoID = [NSString stringWithFormat:@"%@",[dictCurrentVideo objectForKey:@"id"]];
    [[JLTrackers sharedTracker] trackFBEvent:@"featured_content_tap" params:@{@"video_id":strVideoID}];
    [[JLTrackers sharedTracker] trackSingularEvent:@"featured_content_tap"];
    ///
    
    
}
- (void)carouselWillBeginDragging:(iCarousel *)carousel{
    [self stopAutoScrollTimer];
}
- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate{
    [self startAutoScrollTimer];
}
-(void)themeChanged{
    [self.carousel reloadData];
}
@end
