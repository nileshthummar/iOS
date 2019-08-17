//
//  VideoDetailsVC.h
//  Watchback
//
//  Created by Nilesh on 6/14/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoDetailsVC : UIViewController
@property(atomic,strong) NSMutableArray * m_arrPlaylistVideos;
@property(assign) int m_nCurrentIndex;
@property(strong) NSString *m_strChannelName;
@property(assign) BOOL m_bIsBar;
@property(assign) BOOL m_bIsNotFromChannel;
@property(assign) BOOL m_bIsFeaturedContent;
@property(atomic, strong) NSDictionary * parent_channel;

@end

NS_ASSUME_NONNULL_END
