//
//  BrandPortalVC.m
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "BrandPortalVC.h"
#import "AppLabel.h"
#import "Constants.h"
#import "JLManager.h"
#import "SettingsVC.h"
#import "NavPortrait.h"
#import <SDWebImage/SDWebImage.h>
#import "BrandPortalCell.h"
#import "WebServices.h"
#import "BrandVideoCell.h"
#import "PerkoAuth.h"
#import "UIView+Toast.h"
#import "VideoDetailsVC.h"
#import "RequestMoreInfoVC.h"


@interface BrandPortalVC (){
    AppLabel * lblTitle;
    NSMutableArray * aryVideos;
    int video_limit, video_offset;
    CAGradientLayer *  gradientMask;
    int scroll_direction; //1-up, 2-down.
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tblBrand;
@property (weak, nonatomic) IBOutlet UIImageView *imv_background;

@end

@implementation BrandPortalVC

#pragma mark-
#pragma mark view life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefaultParameters];
    [self customizeScreenLayout];
    [self getChannelVideoswithOffset:video_offset limit:video_limit];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self customizeNavigationBar];

    if([_dict_channel_info valueForKey:@"uuid"] !=nil && [_dict_channel_info valueForKey:@"uuid"] != [NSNull null] &&
       [_dict_channel_info valueForKey:@"name"] !=nil && [_dict_channel_info valueForKey:@"name"] != [NSNull null]){
        NSMutableDictionary * dictTrackingParameters = [[NSMutableDictionary alloc] init];
        [dictTrackingParameters setValue:[NSString stringWithFormat:@"%@-%@",[_dict_channel_info valueForKey:@"uuid"],[_dict_channel_info valueForKey:@"name"]] forKey:@"provider"];
        
        [[JLTrackers sharedTracker] trackFBEvent:ProviderDetailScreenEvent params:dictTrackingParameters];
    }else{
        [[JLTrackers sharedTracker] trackFBEvent:ProviderDetailScreenEvent params:nil];
    }
    [self makeNavigationBarTransparent:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self makeNavigationBarTransparent:NO];
    [self resetNavigationBar];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if([JLManager sharedManager].needToRefreshChannels){
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGenresDataNotification object:nil];
        [JLManager sharedManager].needToRefreshChannels = false;
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reskinUIElements];
}

#pragma mark-
#pragma mark uitableview datasource & delegate methods
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (velocity.y > 0){
        NSLog(@"up");
        scroll_direction = 1;
    }
    if (velocity.y < 0){
        NSLog(@"down");
        scroll_direction = 2;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    // UITableView only moves in one direction, y axis
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    //NSInteger result = maximumOffset - currentOffset;
    
    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 10.0 && scroll_direction == 1) {
        //NSLog(@"load next data");
        [self getChannelVideoswithOffset:video_offset limit:video_limit];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(aryVideos.count > 0){
        return 2;
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(aryVideos.count > 0){
        if(section == 0){
            return 1;
        }else{
            return  aryVideos.count;
        }
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(aryVideos.count > 0){
        if(indexPath.section == 0){
            BrandPortalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
            cell.brand_info = _dict_channel_info;
            if([PerkoAuth IsUserLogin]){
                cell.is_favorite = self.isfavorite;
            }else{
                cell.is_favorite = false;
                // search a fav show locally and check that if it exits or not...
                if([_dict_channel_info valueForKey:@"uuid"] != nil &&
                   [_dict_channel_info valueForKey:@"uuid"] != [NSNull null]){
                        cell.is_favorite = [[JLManager sharedManager] checkFavoriteshowExistsLocally:[_dict_channel_info valueForKey:@"uuid"]];
                }
            }
            [cell checkFavorites];
            [cell setBranddetails:_dict_channel_info];
            return cell;
        }else{
            BrandVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"video" forIndexPath:indexPath];
            [cell setBrandVideo:[self->aryVideos objectAtIndex:indexPath.row]];
            return cell;
        }
    }else{
        BrandPortalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
        cell.brand_info = _dict_channel_info;
        if([PerkoAuth IsUserLogin]){
            cell.is_favorite = self.isfavorite;
        }else{
            cell.is_favorite = false;
                // search a fav show locally and check that if it exits or not...
            if([_dict_channel_info valueForKey:@"uuid"] != nil &&
               [_dict_channel_info valueForKey:@"uuid"] != [NSNull null]){
                cell.is_favorite = [[JLManager sharedManager] checkFavoriteshowExistsLocally:[_dict_channel_info valueForKey:@"uuid"]];
            }
        }
        [cell checkFavorites];
        [cell setBranddetails:_dict_channel_info];
        return cell;
    }
    return  nil;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(aryVideos.count > 0){
        if(indexPath.section == 0){
            return UITableViewAutomaticDimension;
        }else{
            return  185.0;
        }
    }else{
        return UITableViewAutomaticDimension;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(aryVideos.count > 0){
        if(indexPath.section == 1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[JLManager sharedManager] dismissPresentedControllerIfAny];
                VideoDetailsVC *objVideoDetailsVC = [[VideoDetailsVC alloc] initWithNibName:@"VideoDetailsVC" bundle:nil];
                objVideoDetailsVC.m_nCurrentIndex = (int)indexPath.row;
                objVideoDetailsVC.m_arrPlaylistVideos = [NSMutableArray arrayWithArray:self->aryVideos];
                if(self.dict_channel_info != nil && (id)self.dict_channel_info != [NSNull null]){
                    if([self.dict_channel_info valueForKey:@"name"] != nil &&
                       [self.dict_channel_info valueForKey:@"name"] != [NSNull null]){
                        objVideoDetailsVC.m_strChannelName = [self.dict_channel_info valueForKey:@"name"];
                    }
                }
                objVideoDetailsVC.m_bIsNotFromChannel = FALSE;
                objVideoDetailsVC.parent_channel = self.dict_channel_info;
                NavPortrait *nav = [[NavPortrait alloc] initWithRootViewController:objVideoDetailsVC];
                CATransition *transition = [[CATransition alloc] init];
                transition.duration = 0.5;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromRight;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [[[JLManager sharedManager] topViewController].view.window.layer addAnimation:transition forKey:kCATransition];
                [[[JLManager sharedManager] topViewController] presentViewController:nav animated:NO completion:nil];

                
                //======TRACKING DATA========
                NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
                [dictTrackingData setObject:@"true" forKey:@"tve.action"];
                
                [dictTrackingData setObject:@"Click:Video" forKey:@"tve.userpath"];
//                [dictTrackingData setObject:[NSString stringWithFormat:@"%@:%d:%d",@"channels", self.+1, nIndex+1] forKey:@"tve.module"];
                

                NSDictionary *dictCurrentVideo = [self->aryVideos objectAtIndex:indexPath.row];
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

                    [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.title"];
                    [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.contenthub"];
                [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Video" data:dictTrackingData];
                //======TRACKING DATA========
            });

        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(aryVideos.count > 0){
        if(section == 0){
            return nil;
        }else{
            UIView * viewheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
            viewheader.backgroundColor = [UIColor clearColor];
            
            UILabel * _lbltitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, viewheader.bounds.size.width-16, viewheader.bounds.size.height)];
            _lbltitle.backgroundColor = [UIColor clearColor];
            _lbltitle.font = kFontPrimaryBold14;
            _lbltitle.textColor = kThirdTextColor;
            
            NSString *string = @"AVAILABLE ON WATCHBACK";
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 2.2f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            _lbltitle.attributedText = attributedString;
            
            [viewheader addSubview:_lbltitle];
            
            return  viewheader;
        }
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(aryVideos.count > 0){
        if(section == 0){
            return 0;
        }else{
            return 30;
        }
    }else{
        return 0;
    }
}

#pragma mark-
#pragma mark ibaction or custom methods

-(void)addGradientOnImage{
    
    if (gradientMask == nil) {
        gradientMask = [CAGradientLayer layer];
        gradientMask.frame = _imv_background.bounds;
        gradientMask.colors = @[(id)[UIColor colorWithRed:27/255.0 green:27/255.0 blue:37/255.0 alpha:0.54].CGColor,
                                (id)[UIColor colorWithRed:27/255.0 green:27/255.0 blue:37/255.0 alpha:1].CGColor];
       // gradientMask.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0]];
        [_imv_background.layer addSublayer:gradientMask];
    }
    else{
        gradientMask.frame = _imv_background.bounds;
        gradientMask.colors = @[(id)[UIColor colorWithRed:27/255.0 green:27/255.0 blue:37/255.0 alpha:0.54].CGColor,
                                (id)[UIColor colorWithRed:27/255.0 green:27/255.0 blue:37/255.0 alpha:1].CGColor];
        
    }
}

-(void)makeNavigationBarTransparent:(BOOL)yesORno{
    if(yesORno){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationController.navigationBar.translucent = YES;
    }else{
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
    }
}

-(void)themeChanged{
    
    //    [m_tblView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblBrand reloadData];
        self->lblTitle.textColor = kPrimaryTextColor;
        self.view.backgroundColor = kPrimaryBGColor;
    });
    
}


-(void)showRequestMoreInfoLogoutPopUp{
    dispatch_async(dispatch_get_main_queue(), ^{
        RequestMoreInfoVC * objRequestMoreInfoVC = [[RequestMoreInfoVC alloc] initWithNibName:@"RequestMoreInfoVC" bundle:nil];
        objRequestMoreInfoVC.definesPresentationContext = YES;
        objRequestMoreInfoVC.view.backgroundColor = [UIColor clearColor];
        objRequestMoreInfoVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:objRequestMoreInfoVC animated:YES completion:^{
        }];
    });
}

-(void)setDefaultParameters{
    video_limit = 10;
    video_offset = 0;
    self->aryVideos = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRequestMoreInfoLogoutNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRequestMoreInfoLogoutPopUp)
                                                 name:kRequestMoreInfoLogoutNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    
    self.navigationController.navigationBar.backIndicatorImage = kPrimaryBackImage;
    
    _tblBrand.rowHeight = UITableViewAutomaticDimension;
    _tblBrand.estimatedRowHeight = 999;
    _tblBrand.backgroundView = nil;
    _tblBrand.backgroundColor = [UIColor clearColor];
}

-(void)getChannelVideoswithOffset:(int)offset limit:(int)limit{
    
    if(!_dict_channel_info){
        return;
    }
    
    if(![_dict_channel_info valueForKey:@"uuid"]){
        return;
    }
    NSString *strURL = [NSString stringWithFormat:@"%@/%@",GET_CHANNEL_VIDEOS,[_dict_channel_info valueForKey:@"uuid"]];
    NSMutableString * params = [[NSMutableString alloc] init];
    if([PerkoAuth getPerkUser].IsUserLogin){
        [params appendString:[NSString stringWithFormat:@"%@=%@",@"access_token",[PerkoAuth getPerkUser].accessToken]];
        [params appendString:@"&"];
    }
    [params appendString:[NSString stringWithFormat:@"%@=%@",@"limit",[NSString stringWithFormat:@"%d",limit]]];
    [params appendString:@"&"];
    [params appendString:[NSString stringWithFormat:@"%@=%@",@"offset",[NSString stringWithFormat:@"%d",offset]]];
    [params appendString:@"&"];
    [params appendString:@"sort=popular"];

    
    
    [[JLManager sharedManager] showLoadingView:self.view];
    
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
        [[JLManager sharedManager] hideLoadingView];
        
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                if([dict valueForKey:@"data"] != nil &&
                   [dict valueForKey:@"data"] != [NSNull null]
                   ){
                    NSDictionary * data = [dict valueForKey:@"data"];
                    if(data !=nil && (id)data != [NSNull null]){
                        if([data valueForKey:@"videos"] != nil &&
                           [data valueForKey:@"videos"] != [NSNull null]){
                            NSMutableArray * arytemp =  [[NSMutableArray alloc] initWithArray:[data valueForKey:@"videos"]];
                            [self->aryVideos addObjectsFromArray:arytemp];
                            
                            if(arytemp.count > 0){
                                self->video_offset = self->video_offset + self->video_limit;
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tblBrand reloadData];
                            });
                        }
                    }
                }
            }
        }
        
    }];
}

-(void)customizeScreenLayout{
    if(_dict_channel_info != nil && (id)_dict_channel_info != [NSNull null]){
        if([_dict_channel_info valueForKey:@"background_image_url"] != nil &&
           [_dict_channel_info valueForKey:@"background_image_url"] != [NSNull null]){
            NSURL * image_url = [NSURL URLWithString:[_dict_channel_info valueForKey:@"background_image_url"]];
            if(image_url){
                [_imv_background sd_setImageWithURL:image_url placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self addGradientOnImage];
                        // if we don't give delay, then UI issue of gradient frame not maching image frame may arrise.
                    });
                }];
            }
        }
    }
    
}

//-(void)btnSettingClicked{
//    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
//    SettingsVC * objSettingsVC = [settingsStoryboard instantiateViewControllerWithIdentifier:@"settings"];
//    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSettingsVC];
//    nav.navigationBarHidden = FALSE;
//    [self presentViewController:nav animated:YES completion:nil];
//}
-(void)resetNavigationBar{
    [lblTitle removeFromSuperview];
}

-(void)customizeNavigationBar{
    lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(44, 0, [UIScreen mainScreen].bounds.size.width-88, 44)];
    lblTitle.textColor = kPrimaryTextColor;
    lblTitle.font = kFontPrimary36;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.adjustsFontSizeToFitWidth = true;
    NSString *strTitle = @"";
    if(_dict_channel_info != nil && (id)_dict_channel_info != [NSNull null]){
        if([_dict_channel_info valueForKey:@"name"] != nil &&
           [_dict_channel_info valueForKey:@"name"] != [NSNull null]){
            strTitle = [_dict_channel_info valueForKey:@"name"];
        }
    }
    lblTitle.text = strTitle;
    [self.navigationController.navigationBar addSubview:lblTitle];
    
    
    
//    UIBarButtonItem *rightItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
//    self.navigationItem.rightBarButtonItem = nil;

}

-(void)reskinUIElements{
    self.view.backgroundColor = kPrimaryBGColor;
    self->lblTitle.textColor = kPrimaryTextColor;
    self.navigationController.navigationBar.backIndicatorImage = kPrimaryBackImage;
    
}

@end
