//
//  AccountVC.m
//  Watchback
//
//  Created by Nilesh on 1/17/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "AccountVC.h"
#import "JLManager.h"
#import <SDWebImage/SDWebImage.h>
#import "Constants.h"
#import "PerkoAuth.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "RedeemWebVC.h"
#import "NavPortrait.h"
#import "SettingsVC.h"
#import "PlayerVideoCell.h"
#import "NavBoth.h"
#import "WebServices.h"
#import "UINavigationController+TransparentNavigationController.h"
#import "GradientView.h"
#import "LogoutVC.h"
@interface AccountVC ()
{
    
    IBOutlet UITableView *m_tblView;
    IBOutlet UILabel *m_lblName;
    IBOutlet UIImageView *m_imgViewBackGround;
    IBOutlet UIImageView *m_imgViewRounded;
    IBOutlet UIButton *m_btnFBConnect;
    
    IBOutlet UIView *m_viewUsage;
    IBOutlet UISegmentedControl *m_segUsageHistory;
    IBOutlet UIView *m_viewHeader;
    
    ////
    IBOutlet UIButton *m_btnReferral;
    IBOutlet UIView *m_viewRferral;
    IBOutlet UILabel *m_lblPoints;
    ///
    
    NSMutableArray *m_arrPlaylistVideos;
    
    
    ///
    IBOutlet UILabel  *m_lblCopyright;
   // CAGradientLayer *  gradientMask;
    
    UIBarButtonItem *leftItem;
    UIBarButtonItem *rightItem;
    
    IBOutlet UIView *m_viewNavigationBackground;
    
    IBOutlet UILabel *m_lblProfileText1;
    IBOutlet UILabel *m_lblProfileText2;
    IBOutlet UILabel *m_lblProfileText4;
    IBOutlet UIButton *m_btnCableTV;
    IBOutlet UIButton *m_btnYidio;
    IBOutlet UIButton *m_btnDonate;
    BOOL m_bIsLoading;
    
    LogoutVC *m_objLogoutVC;
    
}
@property (nonatomic, strong)IBOutlet GradientView *gradientView;
@end

@implementation AccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    m_tblView.backgroundView = nil;
    m_arrPlaylistVideos = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserHeader) name:kResetHeaderNotification object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kRefreshMyAccountDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForWatchedVideosNotification) name:kReloadDataForWatchedVideosNotification object:nil];
    m_tblView.tableHeaderView = m_viewHeader;
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
//        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//            case 2436:
//                printf("iPhone X");
//                break;
//            default:
//                navigationBarHeight += 30;
//                printf("other");
//        }
        
    }
    
    m_tblView.contentInset = UIEdgeInsetsMake(-navigationBarHeight,0,0,0);
    
    ////
    CGRect rect = m_viewNavigationBackground.frame;
    rect.size.height =navigationBarHeight;
    m_viewNavigationBackground.frame = rect;
    
    ////
    
    [self loadData];
    [self customizeScreenLayout];
    [self setFooterView];
    [self setUpNavigationBar];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Profile:Your Watchback" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Profile:Your Watchback" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Profile" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Profile:Your Watchback" data:dictTrackingData];
    ////////
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
    [m_tblView setContentOffset:CGPointZero animated:NO];
    //[m_segUsageHistory setSelectedSegmentIndex:0];
    
    [JLManager sharedManager].m_bIsTabbarVisible = TRUE;
    
    [self checkForLogOut];

    [self callAPIGetVideoHistory];
    [self.navigationController showTransparentNavigationBar];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [JLManager sharedManager].m_bIsTabbarVisible = FALSE;
    [self.navigationController showNonTransparentNavigationBar];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setUserHeader{
    //////
    JLPerkUser * user = [PerkoAuth getPerkUser];
    NSString *strFirstName = user.firstname;
    NSString *strLastName = user.lastname;
    NSString *strName = @"";
    
    if (strFirstName != nil && [strFirstName isKindOfClass:[NSString class]] && strFirstName.length > 0) {
        strName = strFirstName;
    }
    if (strLastName != nil && [strLastName isKindOfClass:[NSString class]] && strLastName.length > 0) {
        strName = [NSString stringWithFormat:@"%@ %@", strName, strLastName];
    }
    strName = [strName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (strName != nil && [strName isKindOfClass:[NSString class]] && strName.length > 0) {
       m_lblName.text = strName;
        m_lblName.hidden = FALSE;
    }
    else{
        m_lblName.hidden = TRUE;
        CGRect rect = m_btnFBConnect.frame;
        rect.origin.y = m_lblName.frame.origin.y;
        m_btnFBConnect.frame = rect;
        
        rect = m_viewRferral.frame;
        rect.origin.y = CGRectGetMaxY(m_btnFBConnect.frame);
        m_viewRferral.frame = rect;
    }
    CGRect rectHeaderView = m_viewHeader.frame;
    rectHeaderView.size.height = CGRectGetMaxY(m_viewRferral.frame)+ 20;
    m_viewHeader.frame = rectHeaderView;
    
    ////
    NSString *strReferralCode = user.referralCode;
    if (strReferralCode == nil || ![strReferralCode isKindOfClass:[NSString class]]) {
        strReferralCode = @"";
    }
    //m_lblReferral.text = [strReferralCode uppercaseString];
    [m_btnReferral setTitle:[strReferralCode uppercaseString] forState:UIControlStateNormal];
    /////
    int points = [user.perkPoint.availableperks intValue]; // +[user.perkPoint.pendingperks intValue];
    NSString *strPoints = @"";
    if (points > 0) {
        NSNumberFormatter *num = [[NSNumberFormatter alloc] init];
        [num setNumberStyle: NSNumberFormatterDecimalStyle];
        NSString *numberAsString = [num stringFromNumber:[NSNumber numberWithInt:points]];
        
        strPoints  = [NSString stringWithFormat:@"%@",numberAsString];;
    }
    else{
        strPoints  = @"0";
    }
    
    m_lblPoints.text = strPoints;
    
    /////
    
    [self performSelectorInBackground:@selector(loadNextPicture) withObject:nil];
    
    
    
    m_imgViewBackGround.clipsToBounds = TRUE;
    ///
   
    
    ////
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self checkForLogOut];    
    [self callAPIGetVideoHistory];
    
}
-(void)loadNextPicture{
    JLPerkUser * user = [PerkoAuth getPerkUser];
    
    NSString *strProfileImage = [NSString stringWithFormat:@"%@",user.profile_image];
    
    __block UIImage *imgProfile = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strProfileImage]]];
    if (imgProfile == nil || ![imgProfile isKindOfClass:[UIImage class]]) {
        
            imgProfile = getProfileFromText(self->m_imgViewRounded);
        
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self->m_imgViewRounded.image = imgProfile;
        
        if ([FBSDKAccessToken currentAccessToken]) {
            self->m_btnFBConnect.hidden = FALSE;
            [self->m_btnFBConnect setTitle:@"Facebook Connected" forState:UIControlStateNormal];
            [self->m_btnFBConnect setImage:[UIImage imageNamed:@"fb-icon-white.png"] forState:UIControlStateNormal];
            // User is logged in, do work such as go to next view controller.
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id, cover, picture" forKey:@"fields"];
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                           parameters:parameters];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    if(kDebugLog)NSLog(@"%@",result);
                    NSDictionary *cover = [result objectForKey:@"cover"];
                    if (cover != nil && [cover isKindOfClass:[NSDictionary class]]) {
                        NSString *strCover = [NSString stringWithFormat:@"%@",[cover objectForKey:@"source"]];
//                        self->m_imgViewBackGround.imageURL = [NSURL URLWithString:strCover];
                        [self->m_imgViewBackGround sd_setImageWithURL:[NSURL URLWithString:strCover] placeholderImage:nil];
                    }
                    else{
                        self->m_imgViewBackGround.image = [UIImage imageNamed:@"watchback_bg"];
                    }
                }
            }];
        }
        else{
            self->m_btnFBConnect.hidden = FALSE;
            [self->m_btnFBConnect setTitle:[NSString stringWithFormat:@"%@",user.email] forState:UIControlStateNormal];
            [self->m_btnFBConnect setImage:nil forState:UIControlStateNormal];
            self->m_imgViewBackGround.image = [UIImage imageNamed:@"watchback_bg"];
        }
        
    });
    
    
}

-(void)addGradientOnImage{
    self.gradientView.layer.colors = @[(id)[kPrimaryBGColor colorWithAlphaComponent:0.5].CGColor,
                            (id)[kPrimaryBGColor colorWithAlphaComponent:0.8].CGColor,
                            (id)[kPrimaryBGColor colorWithAlphaComponent:1.0].CGColor];
    self.gradientView.layer.locations = @[[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:1.0]];
    
}

-(void)btnSettingClicked{
    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    SettingsVC * objSettingsVC = [settingsStoryboard instantiateViewControllerWithIdentifier:@"settings"];
    
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSettingsVC];
    nav.navigationBarHidden = FALSE;    
    [self presentViewController:nav animated:YES completion:nil];
    
    [[JLTrackers sharedTracker] trackFBEvent:@"settings_tap" params:nil];
}
-(void)btnEditClicked{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    JLPerkUser * user = [PerkoAuth getPerkUser];
    objRedeemWebVC.m_strUrl = [NSString stringWithFormat:@"%@?access_token=%@",kMyAccountWebpage,user.accessToken];
    objRedeemWebVC.title = @"My Account";
    [self presentViewController:nav animated:YES completion:nil];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Profile:Edit" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Profile:Edit" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Profile" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Profile:Edit" data:dictTrackingData];
    ////////
    
    [[JLTrackers sharedTracker] trackFBEvent:@"edit_profile_tap" params:nil];
}
-(IBAction)segmentValueChanged:(id)sender{
    
    [m_tblView reloadData];
    
    
    if (m_segUsageHistory.selectedSegmentIndex == 0) {
        ////////////
        NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
        [dictTrackingData setObject:@"Profile:Your History" forKey:@"tve.userpath"];
        [dictTrackingData setObject:@"Profile:Your History" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Profile" forKey:@"tve.contenthub"];
        [[JLTrackers sharedTracker] trackAdobeStates:@"Profile:Your History" data:dictTrackingData];
        ////////
        
        [[JLTrackers sharedTracker] trackFBEvent:@"your_history_tap" params:nil];
    }
    else{
        [[JLTrackers sharedTracker] trackFBEvent:@"your_profile_tap" params:nil];
    }
    
}
#pragma mark --Tableview
#pragma mark --table view delegate
#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(![PerkoAuth IsUserLogin] || m_bIsLoading){
        return 0;
    }
    if (m_segUsageHistory.selectedSegmentIndex == 1) {
        return 1;
    }
    else{
        if (m_arrPlaylistVideos.count > 0) {
            return 1;
        }
        return 1;
    }
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (m_segUsageHistory.selectedSegmentIndex == 1) {
        return 466;
    }
    else{
        if (m_arrPlaylistVideos.count > 0)
        {
            return 0;
        }
        else if(section == 0){
            return 70;
        }
       
        return 0;
        
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (m_segUsageHistory.selectedSegmentIndex == 1) {
        return m_viewUsage;
    }
    else{
        if (m_arrPlaylistVideos.count > 0)
        {
            return nil;
        }
        else if(section == 0){
            UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 70)];
            viewHeader.backgroundColor = [UIColor clearColor];
            viewHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, CGRectGetMaxX(self.view.bounds)-32, 70)];
            lblHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            lblHeader.numberOfLines = 0;
            lblHeader.textAlignment = NSTextAlignmentCenter;
            lblHeader.textColor = kCommonColor;
            lblHeader.font = [UIFont fontWithName:@"SFProDisplay-Regular" size:17]; //kFontPrimary18;
            lblHeader.backgroundColor = [UIColor clearColor];
            lblHeader.text = @"You haven't watched any videos yet.";
            [viewHeader addSubview:lblHeader];
            return viewHeader;
        }
        
        return nil;
        
    }
}
-(NSString*)stringByAddingSpace:(NSString*)stringToAddSpace spaceCount:(NSInteger)spaceCount atIndex:(NSInteger)index{
    NSString *result = [NSString stringWithFormat:@"%@%@",[@" " stringByPaddingToLength:spaceCount withString:@" " startingAtIndex:0],stringToAddSpace];
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (m_segUsageHistory.selectedSegmentIndex == 1) {
        return 0;
    }
    else{
        if (m_arrPlaylistVideos.count > 0) {
            return m_arrPlaylistVideos.count;
        }
        else if(section == 0){
            return 0;
        }
        
        return 0;        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (m_arrPlaylistVideos.count > 0 || indexPath.section == 1) {
        PlayerVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CellPlayerVideoCell"];
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"PlayerVideoCell" bundle:nil] forCellReuseIdentifier:@"CellPlayerVideoCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellPlayerVideoCell"];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"No results found";
    
    cell.textLabel.textColor = kPrimaryTextColor;
    cell.textLabel.font = kFontPrimary20;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_arrPlaylistVideos.count <= 0 && indexPath.section != 1) {
        return;
    }
    
    
    PlayerVideoCell *cellPlayerVideoCell = (PlayerVideoCell *)cell;
    
    NSDictionary *dict;
    
        if (indexPath.row < m_arrPlaylistVideos.count) {
            dict= [m_arrPlaylistVideos objectAtIndex:indexPath.row];
        }
        else{
            return;
        }
    
    //////
    NSString *strTitle = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    NSString *strSubTitle = @"";
    NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            strSubTitle = provider;
        }
    }
    [cellPlayerVideoCell setTitle:strTitle subTitle:strSubTitle];
    [cellPlayerVideoCell setData:dict];
    /////
    
    /////
    
    // Check scrolled percentage
    CGFloat yOffset = tableView.contentOffset.y;
    CGFloat height = tableView.contentSize.height - tableView.frame.size.height;
    CGFloat scrolledPercentage = yOffset / height;
    // Check if all the conditions are met to allow loading the next page
    //
    if (scrolledPercentage > .6f && !m_bIsLoading)
    {
        //[self callAPIGetVideoHistory];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (m_arrPlaylistVideos.count <= 0 && indexPath.section != 1) {
        return;
    }
    NSMutableArray *arrTemp;
    arrTemp= [NSMutableArray arrayWithArray:m_arrPlaylistVideos];
    
    
    int nIndex = (int)indexPath.row;
    [[JLManager sharedManager] dismissPresentedControllerIfAny];
    PlayerVC *objPlayerVC = [[PlayerVC alloc] initWithNibName:@"PlayerVC" bundle:nil];
    objPlayerVC.m_nCurrentIndex = nIndex;
    objPlayerVC.m_arrPlaylistVideos =arrTemp;
    objPlayerVC.m_strChannelName  = @"";
    NavBoth *nav = [[NavBoth alloc] initWithRootViewController:objPlayerVC];
    [[[JLManager sharedManager] topViewController] presentViewController:nav animated:YES completion:nil];
    ////
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Click:Video" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Click:Video" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Profile" forKey:@"tve.contenthub"];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:[NSString stringWithFormat:@"%@:%d:%d",@"account", 1, nIndex+1] forKey:@"tve.module"];
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
}
-(void)callAPIGetVideoHistory{
    
    if (![PerkoAuth IsUserLogin]) {
        [m_tblView reloadData];
        return;
    }
    
    if (m_bIsLoading) return;
    m_bIsLoading = YES;
   // [[JLManager sharedManager] showLoadingViewPlayer:m_tblView];
    int nTop = CGRectGetMaxY(m_viewHeader.bounds);
    if ( m_tblView.contentOffset.y > nTop ) {
         CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
        nTop = navigationBarHeight;
    }
    
     [[JLManager sharedManager] showLoadingViewSearch:self.view top:nTop];
    NSString *strURL = [NSString stringWithFormat:@"%@",VIEW_VIDEO_URL] ;
   
    NSMutableString *postString = [[NSMutableString alloc] initWithFormat:@"access_token=%@",[PerkoAuth getPerkUser].accessToken];
    [[WebServices sharedManager] callAPI:strURL params:postString  httpMethod:@"GET" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
         self->m_bIsLoading = NO;
        [[JLManager sharedManager] hideLoadingViewSearch];
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if(kDebugLog)NSLog(@"%@",dict);
                if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    NSArray *arr = [dict objectForKey:@"videos"];
                    if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                        arr = [NSArray new];
                    }
                    self->m_arrPlaylistVideos = [NSMutableArray arrayWithArray:arr];
                    
                }
            }
            
        }
        
        [self->m_tblView reloadData];
        
    }];
}
#pragma mark --logout
-(void)checkForLogOut{
    
    
    if ([PerkoAuth IsUserLogin]) {
        [self removeLogoutView];
        [m_tblView reloadData];        
        
        ///
        m_tblView.tableHeaderView = m_viewHeader;
        
        self.navigationItem.rightBarButtonItem = rightItem;
        self.navigationItem.titleView = m_segUsageHistory;
        
        ////
        [self.navigationController.navigationBar setTintColor:kPrimaryTextColor];
        [self.navigationController.navigationBar setBarTintColor:kPrimaryBGColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor}];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor,  NSFontAttributeName: kFontPrimary20}];
        ///
        m_tblView.scrollEnabled = TRUE;
    }
    else{
       [self addLogoutView];
        
        ///
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.titleView = nil;
        
        ////
        [self.navigationController.navigationBar setTintColor:kPrimaryTextColorNight];
        [self.navigationController.navigationBar setBarTintColor:kPrimaryBGColorNight];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColorNight}];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColorNight,  NSFontAttributeName: kFontPrimary20}];
        
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}
-(void)addLogoutView{
    [self removeLogoutView];
    m_objLogoutVC = [[LogoutVC alloc] initWithNibName:@"LogoutVC" bundle:nil];
    [self addChildViewController:m_objLogoutVC];
    m_objLogoutVC.view.frame = self.view.bounds;
    [self.view addSubview:m_objLogoutVC.view];
}
-(void)removeLogoutView{
    if (m_objLogoutVC) {
        [m_objLogoutVC removeFromParentViewController];
        [m_objLogoutVC.view removeFromSuperview];
        m_objLogoutVC = nil;
    }
}

-(void)customizeScreenLayout{
   
    [m_btnFBConnect setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];
    m_lblCopyright.font = kFontPrimary12;
    m_lblName.font = kFontPrimary24;
    m_btnFBConnect.titleLabel.font = kFontBtn14;
}
#pragma mark --logout
-(void)setFooterView{
    
    
    
    m_lblCopyright.text = [NSString stringWithFormat:@"Copyright %@ 2018 \nVersion %@",GetAppProductName (),GetBuildVersion ()];
}

-(void)setUpNavigationBar{
    leftItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(btnEditClicked)];
    self.navigationItem.rightBarButtonItem = rightItem ;
    
    self.navigationItem.titleView = m_segUsageHistory;
}
#pragma mark --scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset = m_tblView.contentOffset.y;
    //  if(kDebugLog)NSLog(@"yOffset -> %f",yOffset);
    if(yOffset > 55){
        // [self.navigationController showNonTransparentNavigationBar];
        m_viewNavigationBackground.hidden = FALSE;
    }
    else{
        // [self.navigationController showTransparentNavigationBar];
        m_viewNavigationBackground.hidden = TRUE;
    }
    
}
-(void)themeChanged{
    self.gradientView.layer.colors = @[(id)[kPrimaryBGColor colorWithAlphaComponent:0.5].CGColor,
                            (id)[kPrimaryBGColor colorWithAlphaComponent:0.8].CGColor,
                            (id)[kPrimaryBGColor colorWithAlphaComponent:1.0].CGColor];
    
    [self customizeScreenLayout];
}
#pragma mark --text with links
- (void)tapOnTermsOfServiceLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        if(kDebugLog)NSLog(@"User tapped on the Terms of Service link");
    }
}


- (void)tapOnPrivacyPolicyLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        if(kDebugLog)NSLog(@"User tapped on the Privacy Policy link");
    }
}

-(void)loadData{
    m_imgViewRounded.layer.cornerRadius = m_imgViewRounded.frame.size.width / 2;
    m_imgViewRounded.clipsToBounds = YES;
    
    
    [self addGradientOnImage];
    
    /////
    [self setUserHeader];
    
    
    
    
    NSString *strTemp1 = @"Continue watching the shows you love with a cable subscription!";
    NSString *strTemp2 = @"Find availability in your area at";
  //  NSString *strTemp3 = @"CableTV.com";
    NSString *strTemp4 = @"Learn where to watch more episodes of your favorite shows at";
   // NSString *strTemp5 = @"Yidio.com";
    
    
    
    ///
    UIFont *font = [UIFont fontWithName:@"SFProDisplay-Regular" size:15];
    NSDictionary *dictFontNormal = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                               NSFontAttributeName:font,NSForegroundColorAttributeName:kCommonColor};
   // NSDictionary *dictFontLink = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone), NSFontAttributeName:font,NSForegroundColorAttributeName:kCommonColor};
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setMinimumLineHeight:21];
    
    
    NSMutableAttributedString *attString1 = [[NSMutableAttributedString alloc] init];
    [attString1 appendAttributedString:[[NSAttributedString alloc] initWithString:strTemp1    attributes:dictFontNormal]];
   
    [attString1 addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, strTemp1.length)];
    m_lblProfileText1.attributedText = attString1;
     m_lblProfileText1.textAlignment = NSTextAlignmentCenter;
    ///
    NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] init];
    [attString2 appendAttributedString:[[NSAttributedString alloc] initWithString:strTemp2    attributes:dictFontNormal]];
    
    [attString2 addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, strTemp2.length)];
    m_lblProfileText2.attributedText = attString2;
    m_lblProfileText2.textAlignment = NSTextAlignmentCenter;
    
    ////
    
    
    ///
    ////
    NSMutableAttributedString *attString4 = [[NSMutableAttributedString alloc] init];
    [attString4 appendAttributedString:[[NSAttributedString alloc] initWithString:strTemp4    attributes:dictFontNormal]];
    
    [attString4 addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, strTemp4.length)];
    m_lblProfileText4.attributedText = attString4;
    m_lblProfileText4.textAlignment = NSTextAlignmentCenter;
    
    ///
    ////
    m_btnCableTV.layer.cornerRadius = m_btnYidio.layer.cornerRadius = m_btnDonate.layer.cornerRadius =  8;
    ///
    
    
}
-(IBAction)cableTVTap{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = @"https://www.cabletv.com";
    objRedeemWebVC.title = @"CableTV.com";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(IBAction)yidioTap{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = @"https://www.yidio.com";
    objRedeemWebVC.title = @"Yidio.com";
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(IBAction)donateTap{
    
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [PerkoAuth getPerkUser].accessToken;
    }
    NSString *strUrl = @"http://watchback.com/reward/detail/144ab899-5e5a-4805-a4bb-b60dd901f4c6?access_token={access_token}&safari=1";
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"{access_token}" withString:accessToken];
    if ([strUrl rangeOfString:@"safari=1"].location == NSNotFound) {
        RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
        NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
        nav.navigationBarHidden = FALSE;
        objRedeemWebVC.m_strUrl = strUrl;
        objRedeemWebVC.title = @"DONATE";
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:nil];
    }
}
-(IBAction)bgcaTap{
    
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [PerkoAuth getPerkUser].accessToken;
    }
    NSString *strUrl = @"https://www.bgca.org/?safari=1";
    strUrl = [strUrl stringByReplacingOccurrencesOfString:@"{access_token}" withString:accessToken];
    if ([strUrl rangeOfString:@"safari=1"].location == NSNotFound) {
        RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
        NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
        nav.navigationBarHidden = FALSE;
        objRedeemWebVC.m_strUrl = strUrl;
        objRedeemWebVC.title = @"BGCA.ORG";
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:nil];
    }
}
-(void)refreshData{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->m_segUsageHistory.selectedSegmentIndex = 0;
        
        [self->m_tblView reloadData];
        
        [self setUserHeader];
    });
    
}
-(IBAction)btnReferral_Click{
    [[JLTrackers sharedTracker] trackLeanplumEvent:@"code_info_tap"];
}
-(IBAction)btnRedeem_Click{
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [PerkoAuth getPerkUser].accessToken;
    }
    //self.m_strUrl = [self.m_strUrl stringByReplacingOccurrencesOfString:@"{access_token}" withString:accessToken];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://watchback.com?access_token=%@",accessToken]] options:@{} completionHandler:nil];
}
-(void)reloadDataForWatchedVideosNotification{
    //[m_tblView reloadData];
    [self callAPIGetVideoHistory];
}
@end
