//
//  MovieListVC.h
//  Watchback
//
//  Created by perk on 16/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum {
    kNoMoreMovieTicket = 1,
    kMovieTicket = 2,
    kCongrates = 3
}kOptions;

@interface MovieListVC : UITableViewController{
    __weak IBOutlet UILabel *lblRemainingEpisodes_viewMovieTicket;
    __weak IBOutlet UILabel *lblWatchedEpisodes_viewMovieTicket;
    __weak IBOutlet UIImageView *imv_viewMovieTicket;
    __weak IBOutlet UILabel *lblTitle_viewMovieTicket;
    __weak IBOutlet UILabel *lblDate_viewMovieTicket;
    IBOutlet UIView *viewMovieTicket;
    __weak IBOutlet UIView *viewNoMoreMovieTicket;
    __weak IBOutlet UILabel *lblTitle_viewNoMoreMovieTicket;
    __weak IBOutlet UILabel *lblDate_viewNoMoreMovieTicket;

    IBOutlet UIView *view_congrates;
    __weak IBOutlet UILabel *lblRemainingEpisodes_congrates;
    __weak IBOutlet UILabel *lblWatchedEpisodes_congrates;
    __weak IBOutlet UIImageView *imv_congrates;
    __weak IBOutlet UILabel *lblTitle_congrates;
    __weak IBOutlet UILabel *lblDate_congrates;
    
    __weak IBOutlet UIButton *btnStartWatching_noHistory;
    __weak IBOutlet UILabel *lblTitle_noHistory;
    IBOutlet UIView *view_noHistory;
    
}
@property (atomic, readwrite) kOptions option;
@property (atomic,strong) NSArray * ary_movies;
@property (atomic, readwrite) int total_videos_remaining;

@end

NS_ASSUME_NONNULL_END
