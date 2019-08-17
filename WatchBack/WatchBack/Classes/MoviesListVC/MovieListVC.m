//
//  MovieListVC.m
//  Watchback
//
//  Created by perk on 16/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "MovieListVC.h"
#import "MovieListTableViewCell.h"
#import "Constants.h"
#import "JLManager.h"

#define MovieTicketHeaderHeight 470
#define CongratesHeaderHeight 490
#define YourWatchHistoryHeaderHeight 37
#define NoMoreMovieTicketHeaderHeight 200
#define NoHistoryHeaderHeight 200

#define TotalEpisodes 5

@interface MovieListVC ()

@end

@implementation MovieListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeScreenLayout];
    [self customizeNoHistoryPrompt];
    if(_option == kNoMoreMovieTicket){
        [self customizeNoMoreMovieTicketsPrompt];
    }else if(_option == kMovieTicket){
        [self customizeGetTicketsPrompt];
    }else if(_option == kCongrates){
        [self customizeCongratesPrompt];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reskinLayouts];
}

#pragma mark-
#pragma mark ibaction or custom methods
-(void)reskinLayouts{
    self.tableView.backgroundColor = kPrimaryBGColor;
    viewMovieTicket.backgroundColor = kPrimaryBGColor;
    lblTitle_viewMovieTicket.textColor = kPrimaryTextColor;
    lblTitle_noHistory.textColor = kPrimaryTextColor;
    lblTitle_congrates.textColor = kPrimaryTextColor;
    lblTitle_viewNoMoreMovieTicket.textColor = kPrimaryTextColor;
}
-(void)customizeScreenLayout{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 153;
}
-(void)customizeNoHistoryPrompt{
    btnStartWatching_noHistory.layer.cornerRadius = 8;
}
- (IBAction)btnStartWatchingwhenNoHistoryTabbed:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"0"];
    });
}
-(void)customizeCongratesPrompt{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM yyyy"];
    NSString * monthyear = [df stringFromDate:[NSDate date]];
    self->lblDate_congrates.text = monthyear;

    self->lblWatchedEpisodes_congrates.text = [NSString stringWithFormat:@"%d Episodes remaining",self->_total_videos_remaining];
    self->lblRemainingEpisodes_congrates.text = [NSString stringWithFormat:@"Watched %d Episodes",TotalEpisodes-self->_total_videos_remaining];
    
    int watched_videos_count = TotalEpisodes-self->_total_videos_remaining;
    
    switch (watched_videos_count) {
        case 0:
            imv_congrates.image = [UIImage imageNamed:@"progress-0"];
            break;
        case 1:
            imv_congrates.image = [UIImage imageNamed:@"progress-1"];
            break;
        case 2:
            imv_congrates.image = [UIImage imageNamed:@"progress-2"];
            break;
        case 3:
            imv_congrates.image = [UIImage imageNamed:@"progress-3"];
            break;
        case 4:
            imv_congrates.image = [UIImage imageNamed:@"progress-4"];
            break;
        case 5:
            imv_congrates.image = [UIImage imageNamed:@"progress-5"];
            break;
            
        default:
            break;
    }
}

-(void)customizeGetTicketsPrompt{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM yyyy"];
    NSString * monthyear = [df stringFromDate:[NSDate date]];
    self->lblDate_viewMovieTicket.text = monthyear;

    self->lblWatchedEpisodes_viewMovieTicket.text = [NSString stringWithFormat:@"%d Episodes remaining",self->_total_videos_remaining];
    self->lblRemainingEpisodes_viewMovieTicket.text = [NSString stringWithFormat:@"Watched %d Episodes",TotalEpisodes-self->_total_videos_remaining];
    
    int watched_videos_count = TotalEpisodes-self->_total_videos_remaining;

    switch (watched_videos_count) {
        case 0:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-0"];
            break;
        case 1:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-1"];
            break;
        case 2:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-2"];
            break;
        case 3:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-3"];
            break;
        case 4:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-4"];
            break;
        case 5:
            imv_viewMovieTicket.image = [UIImage imageNamed:@"progress-5"];
            break;
            
        default:
            break;
    }
}


-(void)customizeNoMoreMovieTicketsPrompt{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM yyyy"];
    NSString * monthyear = [df stringFromDate:[NSDate date]];
    self->lblDate_viewNoMoreMovieTicket.text = monthyear;

}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(_option == kNoMoreMovieTicket){
        float total_header_height;
        if(_ary_movies.count > 0){
            total_header_height = NoMoreMovieTicketHeaderHeight+YourWatchHistoryHeaderHeight;
        }else{
            total_header_height = NoMoreMovieTicketHeaderHeight+YourWatchHistoryHeaderHeight+NoHistoryHeaderHeight;
        }
    UIView * viewheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.bounds.size.width, total_header_height)];

    viewheader.backgroundColor = [UIColor clearColor];
    
        
        CGRect frame = viewNoMoreMovieTicket.frame;
        frame.origin.x = 20;
        frame.size.width = viewheader.bounds.size.width - 40;
        frame.size.height = NoMoreMovieTicketHeaderHeight;
        viewNoMoreMovieTicket.frame = frame;
        
    [viewheader addSubview:viewNoMoreMovieTicket];
        
    UILabel * lblheader = [[UILabel alloc]initWithFrame:CGRectMake(16, NoMoreMovieTicketHeaderHeight, tableView.bounds.size.width-16,21)];
    lblheader.backgroundColor = [UIColor clearColor];
    lblheader.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:12];
    lblheader.textColor = kPrimaryTextColor;
    
    
    NSString *string = @"YOUR WATCH HISTORY";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 2.2f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    lblheader.attributedText = attributedString;
        if(_ary_movies.count == 0){
            lblheader.hidden = true;
        }
    [viewheader addSubview:lblheader];
        
                if(_ary_movies.count == 0){
        frame = view_noHistory.frame;
        frame.origin.x = 20;
        frame.origin.y = NoMoreMovieTicketHeaderHeight + YourWatchHistoryHeaderHeight;
        frame.size.width = viewheader.bounds.size.width - 40;
        frame.size.height = NoHistoryHeaderHeight;
        view_noHistory.frame = frame;
    
        [viewheader addSubview:view_noHistory];
        
                }
    return  viewheader;
    }else if(_option == kMovieTicket){
        float total_header_height;
        if(_ary_movies.count > 0){
            total_header_height = MovieTicketHeaderHeight+YourWatchHistoryHeaderHeight;
        }else{
            total_header_height = MovieTicketHeaderHeight+YourWatchHistoryHeaderHeight+NoHistoryHeaderHeight;
        }
        UIView * viewheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.bounds.size.width, total_header_height)];

        
        viewheader.backgroundColor = [UIColor clearColor];
        
        
        
        CGRect frame = viewMovieTicket.frame;
        frame.origin.x = 0;
        frame.size.width = viewheader.bounds.size.width;
        frame.size.height = MovieTicketHeaderHeight;
        viewMovieTicket.frame = frame;
        
        [viewheader addSubview:viewMovieTicket];
        
        
        UILabel * lblheader = [[UILabel alloc]initWithFrame:CGRectMake(16, 490, tableView.bounds.size.width-16,21)];
        lblheader.backgroundColor = [UIColor clearColor];
        lblheader.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:12];
        lblheader.textColor = kPrimaryTextColor;
        
        
        NSString *string = @"YOUR WATCH HISTORY";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        
        float spacing = 2.2f;
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(spacing)
                                 range:NSMakeRange(0, [string length])];
        
        lblheader.attributedText = attributedString;
        if(_ary_movies.count == 0){
            lblheader.hidden = true;
        }
        [viewheader addSubview:lblheader];
        
        if(_ary_movies.count == 0){
        frame = view_noHistory.frame;
        frame.origin.x = 20;
        frame.origin.y = MovieTicketHeaderHeight + YourWatchHistoryHeaderHeight;
        frame.size.width = viewheader.bounds.size.width - 40;
        frame.size.height = NoHistoryHeaderHeight;
        view_noHistory.frame = frame;
        
        [viewheader addSubview:view_noHistory];
        }
        
        return viewheader;
    }else if(_option == kCongrates){
        float total_header_height;
        if(_ary_movies.count > 0){
            total_header_height = CongratesHeaderHeight+YourWatchHistoryHeaderHeight;
        }else{
            total_header_height = CongratesHeaderHeight+YourWatchHistoryHeaderHeight+NoHistoryHeaderHeight;
        }
        UIView * viewheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tableView.bounds.size.width, total_header_height)];
        
        viewheader.backgroundColor = [UIColor clearColor];
        
        
        
        CGRect frame = view_congrates.frame;
        frame.origin.x = 0;
        frame.size.width = viewheader.bounds.size.width;
        frame.size.height = CongratesHeaderHeight;
        view_congrates.frame = frame;
        
        [viewheader addSubview:view_congrates];
        
        
        UILabel * lblheader = [[UILabel alloc]initWithFrame:CGRectMake(16, CongratesHeaderHeight+20, tableView.bounds.size.width-16,21)];
        lblheader.backgroundColor = [UIColor clearColor];
        lblheader.font = [UIFont fontWithName:@"SFProDisplay-Bold" size:12];
        lblheader.textColor = kPrimaryTextColor;
        
        
        NSString *string = @"YOUR WATCH HISTORY";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        
        float spacing = 2.2f;
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(spacing)
                                 range:NSMakeRange(0, [string length])];
        
        lblheader.attributedText = attributedString;
        if(_ary_movies.count == 0){
            lblheader.hidden = true;
        }
        [viewheader addSubview:lblheader];
        
                if(_ary_movies.count == 0){
        frame = view_noHistory.frame;
        frame.origin.x = 20;
        frame.origin.y = MovieTicketHeaderHeight + YourWatchHistoryHeaderHeight;
        frame.size.width = viewheader.bounds.size.width - 40;
        frame.size.height = NoHistoryHeaderHeight;
        view_noHistory.frame = frame;
        
        [viewheader addSubview:view_noHistory];
                }
        
        return viewheader;
    }
    else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if( _option == kNoMoreMovieTicket){
        if(_ary_movies.count>0){
            return NoMoreMovieTicketHeaderHeight+YourWatchHistoryHeaderHeight;
        }else{
            return NoMoreMovieTicketHeaderHeight+YourWatchHistoryHeaderHeight+NoHistoryHeaderHeight;
        }
    }else if(_option == kMovieTicket){
        if(_ary_movies.count>0){
            return MovieTicketHeaderHeight+YourWatchHistoryHeaderHeight+20;
        }else{
            return MovieTicketHeaderHeight+YourWatchHistoryHeaderHeight+NoHistoryHeaderHeight+20;
        }
    }else if(_option == kCongrates){
        if(_ary_movies.count>0){
            return CongratesHeaderHeight + YourWatchHistoryHeaderHeight + 20;
        }else{
            return CongratesHeaderHeight + YourWatchHistoryHeaderHeight + NoHistoryHeaderHeight + 20;
        }
    }
    else{
        return YourWatchHistoryHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _ary_movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movie_cell" forIndexPath:indexPath];
    NSDictionary * dictmovie = [_ary_movies objectAtIndex:indexPath.row];
    [cell setMovie:dictmovie];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
