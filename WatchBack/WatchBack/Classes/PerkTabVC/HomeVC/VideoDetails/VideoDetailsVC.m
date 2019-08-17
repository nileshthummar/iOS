//
//  VideoDetailsVC.m
//  Watchback
//
//  Created by Nilesh on 6/14/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "VideoDetailsVC.h"
#import <SDWebImage/SDWebImage.h>
#import "UINavigationController+TransparentNavigationController.h"
#import "AppLabel.h"
#import "JLManager.h"
#import "Constants.h"
#import "PlayerVC.h"
#import "NavBoth.h"
#import "LFCache.h"

@interface VideoDetailsVC ()
{

    IBOutlet UIImageView *m_imgViewBackGround;
    IBOutlet UIImageView *m_imgView;
    IBOutlet UIImageView *m_imgViewBrand;
    IBOutlet AppLabel *m_lblTitle;
    IBOutlet AppLabel *m_lblProvider;
    IBOutlet AppLabel *m_lblSubTitle;
    IBOutlet AppLabel *m_lblSubTitle2;
    IBOutlet AppLabel *m_lblSubTitle3;
    IBOutlet UIView *m_viewChannel;
    IBOutlet UIView *m_viewProgress;
    IBOutlet UIProgressView *m_progressView;
    IBOutlet UIButton *m_btnVisitBrand;
    IBOutlet UIButton *m_btnPlayResume;
    IBOutlet UILabel *m_lblProgress;
    CAGradientLayer *  gradientMask;
    __weak IBOutlet NSLayoutConstraint *leadingconstraint_lblTitle;
    UIVisualEffectView *visualEffectView;
    __weak IBOutlet UIScrollView *objScrollview;
}
@end

@implementation VideoDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpNavigationBar];
    [self loadData];
    [self addGradientOnImage];
    [self customizeScreenLayout];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController showTransparentNavigationBar];
    
    NSDictionary *dict_video_info = [self getDictForCurrentIndex];
    
    if(dict_video_info != nil && (id)dict_video_info != [NSNull null]){
        if([dict_video_info valueForKey:@"id"] != nil &&
           [dict_video_info valueForKey:@"id"] != [NSNull null]){
            NSDictionary * dictTrackingParameters = [[NSDictionary alloc]initWithObjectsAndKeys:[dict_video_info valueForKey:@"id"],@"Video ID", nil];
            [[JLTrackers sharedTracker] trackFBEvent:VideoDetailScreenEvent params:dictTrackingParameters];
        }
    }

    [self checkSetResumeProgress];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)setUpNavigationBar{
    self.navigationController.navigationBarHidden = FALSE;
    UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(btnCloseClicked)];
    self.navigationItem.rightBarButtonItem = btnClose;
    
    ///
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect rectImage = m_imgViewBackGround.frame;
    rectImage.origin.y = - navigationBarHeight;
    m_imgViewBackGround.frame = rectImage;
   /* m_tblView.contentInset = UIEdgeInsetsMake(-navigationBarHeight,0,0,0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForWatchedVideosNotification) name:kReloadDataForWatchedVideosNotification object:nil];
    ////
    CGRect rect = m_viewNavigationBackground.frame;
    rect.size.height =navigationBarHeight;
    m_viewNavigationBackground.frame = rect;
    */
    
}
-(void)customizeScreenLayout{
}

-(IBAction)btnCloseClicked{
    
    ///
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    ///
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


-(void)loadData{
    
    m_btnPlayResume.layer.cornerRadius = m_btnVisitBrand.layer.cornerRadius = 8;
    m_btnVisitBrand.layer.borderWidth  = 1;
    m_btnVisitBrand.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:0 blue:53/255.0 alpha:1].CGColor;
    m_imgViewBrand.layer.cornerRadius = m_imgViewBrand.bounds.size.width/2.0;
    m_imgViewBrand.clipsToBounds = true;
   
    NSDictionary *dict = [self getDictForCurrentIndex];
    NSString *strBGImageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"poster"]];
   // m_imgViewBackGround.imageURL = [NSURL URLWithString:strBGImageUrl];
    //m_imgView.imageURL = [NSURL URLWithString:strBGImageUrl];
    [m_imgViewBackGround sd_setImageWithURL:[NSURL URLWithString:strBGImageUrl] placeholderImage:nil];
    [m_imgView sd_setImageWithURL:[NSURL URLWithString:strBGImageUrl] placeholderImage:nil];
    ////
    
    BOOL bLongform = FALSE;
    //NSString *content_provider = @"";
    NSString *strProvider = @"";
    NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            strProvider = provider;
        }
        //season_number
        //episode_number
        //S#, E#"
        NSString *strSE = @"";
        NSString *season_number = [custom_fields objectForKey:@"season_number"];
        if (season_number != nil && [season_number isKindOfClass:[NSString class]] && season_number.length > 0 && ![season_number isEqualToString:@"unknown"]) {
            strSE = [NSString stringWithFormat:@"- S%@",season_number];
        }
        NSString *episode_number = [custom_fields objectForKey:@"episode_number"];
        if (episode_number != nil && [episode_number isKindOfClass:[NSString class]] && episode_number.length > 0 && ![season_number isEqualToString:@"unknown"]) {
            if (strSE.length > 0) {
                strSE = [NSString stringWithFormat:@"%@, E%@",strSE, episode_number];
            }
            else{
                strSE = [NSString stringWithFormat:@"- E%@",episode_number];
            }
        }
        strProvider = [NSString stringWithFormat:@"%@ %@",strProvider,strSE];
    }
    //    view.m_imgView.image = nil;
    //    view.m_imgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"poster"]]];
    m_lblTitle.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    //m_lblTitle.textColor = kPrimaryTextColor;
    NSString * strDuration;
    if([dict objectForKey:@"duration"] != nil && [dict objectForKey:@"duration"] != [NSNull null]){
        float milliseconds = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"duration"]] floatValue];
            float time = milliseconds / 1000;
            if (time <= 0) {
                // do nothing...
            }
            int hours = (int)(time / (60*60))%24;
            int minutes = (int)(time / 60)%60;
            int seconds = ((int)time) % 60;
            if (hours > 0) {
                strDuration = [NSString stringWithFormat:@"%d:%02d:%02d",hours, minutes, seconds];
            }
            else{
                strDuration = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
            }
    }
    if(strDuration){
        m_lblProvider.text = [NSString stringWithFormat:@"%@ - %@",strProvider,strDuration];
    }else{
        m_lblProvider.text = strProvider;
    }
    ///
    
    NSString *long_description = [NSString stringWithFormat:@"%@",[dict objectForKey:@"long_description"]];
    if (long_description == nil || [long_description isEqualToString:@"(null)"] || [long_description isEqualToString:@"<null>"] || [long_description isEqualToString:@"unknown"]) {
        long_description = @"";
    }else{
        long_description = [NSString stringWithFormat:@"\n%@",long_description];
    }
    m_lblSubTitle.text = long_description;
    
    NSString *description = [NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
    if (description == nil || [description isEqualToString:@"(null)"] || [description isEqualToString:@"<null>"] || [description isEqualToString:@"unknown"]) {
        description = @"";
    }else{
        description = [NSString stringWithFormat:@"\n%@",description];
    }
    m_lblSubTitle2.text = description;
    ////
    NSDictionary *schedule = [dict objectForKey:@"schedule"];
    NSString *strSchedule = @"";
     if (schedule && [schedule isKindOfClass:[NSDictionary class]]) {
         NSString *ends_at = [NSString stringWithFormat:@"%@",[schedule objectForKey:@"ends_at"]];
         if (ends_at == nil || [ends_at isEqualToString:@"(null)"] || [ends_at isEqualToString:@"<null>"] || [ends_at isEqualToString:@"unknown"]) {
             ends_at = @"";
         }
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
         NSDate *recDate = [dateFormatter dateFromString:ends_at];
         if (recDate != nil) {
             [dateFormatter setDateFormat:@"MMM dd, yyyy h:mm a zzzz"];
             strSchedule = [NSString stringWithFormat:@"Available until %@",[dateFormatter stringFromDate:recDate]];
         }
     }
    
    m_lblSubTitle3.text = [NSString stringWithFormat:@"\n%@",strSchedule];
    ////
   // CGFloat fMargin = 16;
    NSDictionary *dictChannel = [dict objectForKey:@"channel"];
    NSString *image_url = @"";
    if (dictChannel && [dictChannel isKindOfClass:[NSDictionary class]]) {
        
        if([dictChannel objectForKey:@"details_screen_logo_url"] != nil &&
           [dictChannel objectForKey:@"details_screen_logo_url"] != [NSNull null]){
            image_url = [dictChannel objectForKey:@"details_screen_logo_url"];
        }else if([dictChannel objectForKey:@"list_screen_logo_url"] != nil &&
                 [dictChannel objectForKey:@"list_screen_logo_url"] != [NSNull null]){
            image_url = [dictChannel objectForKey:@"list_screen_logo_url"];
        }
            
        [m_btnVisitBrand setTitle:[NSString stringWithFormat:@"%@",[dictChannel objectForKey:@"button_text"]] forState:UIControlStateNormal];
    }else if(_parent_channel != nil){
        if([_parent_channel objectForKey:@"details_screen_logo_url"] != nil &&
           [_parent_channel objectForKey:@"details_screen_logo_url"] != [NSNull null]){
            image_url = [_parent_channel objectForKey:@"details_screen_logo_url"];
        }else if([_parent_channel objectForKey:@"list_screen_logo_url"] != nil &&
                 [_parent_channel objectForKey:@"list_screen_logo_url"] != [NSNull null]){
            image_url = [_parent_channel objectForKey:@"list_screen_logo_url"];
        }
        
        [m_btnVisitBrand setTitle:[NSString stringWithFormat:@"%@",[_parent_channel objectForKey:@"button_text"]] forState:UIControlStateNormal];
    }else{
        m_viewChannel.hidden = YES;
    }
    //CGRect imgRect = m_imgView.frame;
    // if (bLongform)
    if (image_url && [image_url isKindOfClass:[NSString class]] && image_url.length > 0)
    {
        //m_imgViewBrand.hidden = FALSE;
//        m_imgViewBrand.imageURL = [NSURL URLWithString:image_url];
        [m_imgViewBrand sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:nil];
    }
    else{
        leadingconstraint_lblTitle.constant = 20.0;
        //m_imgViewBrand.hidden = TRUE;
    }
    ////
    
    m_viewProgress.hidden = YES;
}
-(NSDictionary *)getDictForCurrentIndex
{
    NSArray *aryVideos = self.m_arrPlaylistVideos;
    if (aryVideos != nil && [aryVideos isKindOfClass:[NSArray class]] && aryVideos.count > 0) {
        if (self.m_nCurrentIndex < [aryVideos count] ) {
            return [aryVideos objectAtIndex:self.m_nCurrentIndex];
        }
        else{
            self.m_nCurrentIndex = 0;
            return [aryVideos objectAtIndex:self.m_nCurrentIndex];
        }
    }
    else{
        return [NSMutableDictionary new];
    }
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    // Your layout logic here
    if(visualEffectView){
        visualEffectView.frame = m_imgViewBackGround.bounds;
    }
    if(gradientMask){
        gradientMask.frame = m_imgViewBackGround.bounds;
    }
}
-(void)addGradientOnImage{
    m_imgViewBackGround.layer.cornerRadius = 8.0;
    m_imgView.layer.cornerRadius = 8.0;
    if(visualEffectView == nil){
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = m_imgViewBackGround.bounds;
        [m_imgViewBackGround addSubview:visualEffectView];
    }
    
    if (gradientMask == nil) {
        gradientMask = [CAGradientLayer layer];
        gradientMask.frame = m_imgViewBackGround.bounds;
        gradientMask.colors = @[(id)[kPrimaryBGColor colorWithAlphaComponent:0.1].CGColor,
                                (id)kPrimaryBGColor.CGColor];
        //gradientMask.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0]];
        
        [m_imgViewBackGround.layer addSublayer:gradientMask];
    }
    else{
        gradientMask.frame = m_imgViewBackGround.bounds;
        gradientMask.colors = @[(id)[kPrimaryBGColor colorWithAlphaComponent:0.1].CGColor,
                                (id)kPrimaryBGColor.CGColor];
        
    }
}
-(IBAction)btnPlayResumeClick{
    NSDictionary * video_dict = [self getDictForCurrentIndex];
    if(video_dict != nil && (id)video_dict != [NSNull null]){
        if([video_dict valueForKey:@"id"] != nil &&
           (id)[video_dict valueForKey:@"id"] != [NSNull null]){
            NSString *strPosition = [[LFCache sharedManager] get:[NSString stringWithFormat:@"%@",[video_dict valueForKey:@"id"]]];
            if(kDebugLog)NSLog(@"strPosition -> %@",strPosition);
            long long position = [strPosition longLongValue];
            if(position > 0){
                [[JLTrackers sharedTracker] trackFBEvent:VideoDetailsResumeEvent params:nil];
            }
        }
    }
    [[JLTrackers sharedTracker] trackFBEvent:VideoDetailsPlayEvent params:nil];
    
    PlayerVC *objPlayerVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
    objPlayerVC.m_nCurrentIndex = 0;//self.m_nCurrentIndex;
    objPlayerVC.m_arrPlaylistVideos = [NSMutableArray arrayWithArray:@[[self getDictForCurrentIndex]]]; //self.m_arrPlaylistVideos;
    objPlayerVC.m_strChannelName  = self.m_strChannelName;
    objPlayerVC.m_bIsNotFromChannel = self.m_bIsNotFromChannel;
    NavBoth *nav = [[NavBoth alloc] initWithRootViewController:objPlayerVC];
    
    [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
    
}
-(IBAction)btnVistiBrandClick{
    NSDictionary *dict = [self getDictForCurrentIndex];
    NSDictionary *dictChannel = [dict objectForKey:@"channel"];

    
    if([dictChannel valueForKey:@"uuid"] !=nil && [dictChannel valueForKey:@"uuid"] != [NSNull null] &&
       [dictChannel valueForKey:@"name"] !=nil && [dictChannel valueForKey:@"name"] != [NSNull null]){
        NSMutableDictionary * dictTrackingParameters = [[NSMutableDictionary alloc] init];
        [dictTrackingParameters setValue:[NSString stringWithFormat:@"%@-%@",[dictChannel valueForKey:@"uuid"],[dictChannel valueForKey:@"name"]] forKey:@"provider"];
        
        [[JLTrackers sharedTracker] trackFBEvent:VideoDetailsWatchProviderEvent params:dictTrackingParameters];
    }else{
        [[JLTrackers sharedTracker] trackFBEvent:VideoDetailsWatchProviderEvent params:nil];
    }
    

    
    if (dictChannel && [dictChannel isKindOfClass:[NSDictionary class]]) {
        NSString *destination_url = [dictChannel objectForKey:@"destination_url"];
        if (destination_url && [destination_url isKindOfClass:[NSString class]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:destination_url] options:@{} completionHandler:nil];
        }
    }
}
-(void)checkSetResumeProgress{
        NSDictionary * video_dict = [self getDictForCurrentIndex];
    if(video_dict != nil && (id)video_dict != [NSNull null]){
        if([video_dict valueForKey:@"id"] != nil &&
           (id)[video_dict valueForKey:@"id"] != [NSNull null]){
            NSString *strPosition = [[LFCache sharedManager] get:[NSString stringWithFormat:@"%@",[video_dict valueForKey:@"id"]]];
            if(kDebugLog)NSLog(@"strPosition -> %@",strPosition);
            long long position = [strPosition longLongValue];
            if(position > 0){
                [m_btnPlayResume setTitle:@"Resume" forState:UIControlStateNormal];
                [m_btnPlayResume setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 170)];
                if([video_dict valueForKey:@"duration"] != nil &&
                   [video_dict valueForKey:@"duration"] != [NSNull null]){
                    float progress = position  *  1000.0 / [[video_dict valueForKey:@"duration"] floatValue];
                    NSLog(@"%f",progress);
                    [m_progressView setProgress:progress];
                    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
                    m_progressView.transform = transform;
                    
                    m_viewProgress.hidden = NO;
                    float remaining_time = [[video_dict valueForKey:@"duration"] floatValue] - (position * 1000.0);
                    long seconds = (remaining_time / 1000);
                    int hours = seconds / 3600;
                    int remainder = seconds % 3600;
                    int minutes = remainder / 60;
                    m_lblProgress.text = [NSString stringWithFormat:@"%dhr %dm remaining",hours,minutes];
                }
            }else{
                [m_btnPlayResume setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 230)];
                [m_btnPlayResume setTitle:@"Play Episode" forState:UIControlStateNormal];
                    m_viewProgress.hidden = YES;
            }

        }
    }

}
@end
