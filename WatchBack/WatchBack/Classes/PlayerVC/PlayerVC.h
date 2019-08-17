//
//  PlayerVC.h
//  Watchback
//
//  Created by Nilesh on 1/19/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerVC : UIViewController
@property(atomic,strong) NSMutableArray * m_arrPlaylistVideos;
@property(assign) int m_nCurrentIndex;
@property(strong) NSString *m_strChannelName;
@property(assign) BOOL m_bIsBar;
@property(assign) BOOL m_bIsNotFromChannel;
@property(assign) BOOL m_bIsFeaturedContent;
@property (nonatomic, weak) IBOutlet UIView *videoContainer;
@end
