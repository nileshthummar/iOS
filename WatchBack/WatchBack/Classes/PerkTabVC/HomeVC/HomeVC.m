//
//  HomeVC.m
//  Watchback
//
//  Created by Nilesh on 7/29/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "HomeVC.h"
#import "WebServices.h"
#import <SDWebImage/SDWebImage.h>
#import "JLManager.h"
#import "PlayerVC.h"
#import "NavBoth.h"
#import "NavLandscape.h"
#import "NavBoth.h"
#import "PerkoAuth.h"
#import "Constants.h"
#import "HomeCell.h"
#import "HomeFeaturedView.h"
#import "AppLabel.h"
#import "NavPortrait.h"
#import "HomeFeaturedCell.h"
#import "Leanplum.h"
#import "AccountVC.h"
#import "SettingsVC.h"
@interface HomeVC ()<UISearchBarDelegate,UITableViewDataSourcePrefetching>
{
    IBOutlet UITableView *m_tblView;
    NSMutableArray *m_arrPlaylistIds;
    
    UIImageView *m_imgHeaderLogo;
    AppLabel *m_lblTitle;
   // UIImageView *m_imgProfile;
//    UIButton *m_btnProfile;
    
    UIRefreshControl *m_refreshControl;
    NSArray *m_arrRecommendedForYou;
    NSTimeInterval m_lastRefreshTime;
    BOOL m_bIsHomeStateTracked;
    
    NSMutableDictionary *imageDownloadtasks;
}
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_tblView.backgroundView = nil;
   // m_tblView.backgroundColor = kPrimaryBGColor;
//    m_tblView.contentInset = UIEdgeInsetsZero;
//   self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 10.0, *)) {
        m_tblView.prefetchDataSource = self;
    }
    m_tblView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, m_tblView.bounds.size.width, 0.01f)];
    ///
   // [self callAPIForGetHomeScreenData];
   
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:kResetHeaderNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedUserSelection) name:kUpdatedUserSelectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kRefreshHomeDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWatchedLongformVideoNotification) name:kUserWatchedLongformVideoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForWatchedVideosNotification) name:kReloadDataForWatchedVideosNotification object:nil];
    
    if(kDebugLog)NSLog(@"postInterest From Home Screen viewDidLoad");
    [self resetData];
    
    
    ///
    m_refreshControl = [[UIRefreshControl alloc]init];
    [m_tblView addSubview:m_refreshControl];
    [m_refreshControl addTarget:self action:@selector(callAPIForGetHomeScreenData) forControlEvents:UIControlEventValueChanged];
    
    /////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Featured" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Featured" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Featured" forKey:@"tve.contenthub"];
    [dictTrackingData setObject:@"Portrait" forKey:@"tve.contentmode"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Featured" data:dictTrackingData];
    ////////
   // [self askForLocationPermission];
    NSString *strMarketingAgreement = [[JLManager sharedManager] getObjectuserDefault:kMarketingAgreement];
    [Leanplum setUserAttributes:@{@"Marketing Email Opt-in":strMarketingAgreement}];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [JLManager sharedManager].m_bIsTabbarVisible = TRUE;
    [self trackFirstHomeState];
    [[JLTrackers sharedTracker] trackFBEvent:@"visit_home_screen" params:nil];
    [[JLTrackers sharedTracker] trackFBEvent:DiscoverScreenEvent params:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [JLManager sharedManager].m_bIsTabbarVisible = FALSE;
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --table view delegate
#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return m_arrPlaylistIds.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   if(section < m_arrPlaylistIds.count){
        NSString *strTitle = @"";
        NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:section];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            //NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
            //if ([type isEqualToString:@"featured"]) {
           
            strTitle = [dict objectForKey:@"name"];
        }
        UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.bounds), 44)];
       
       //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor,  NSFontAttributeName: kFontPrimary20,NSKernAttributeName:@(0.5f)}];
       
        lblHeader.textAlignment = NSTextAlignmentLeft;
        lblHeader.textColor = kPrimaryTextColor;
        lblHeader.font =kFontPrimary16;
        lblHeader.backgroundColor = [UIColor clearColor];
//        NSString *spaceAddedText = [[self stringByAddingSpace:strTitle spaceCount:5 atIndex:0] uppercaseString];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strTitle];
       
        float spacing = 0.5f;
        [attributedString addAttribute:NSKernAttributeName
                                value:@(spacing)
                                range:NSMakeRange(0, [strTitle length])];
       
        lblHeader.attributedText = attributedString;
       
        
        return lblHeader;
    }
    return nil;
}
-(NSString*)stringByAddingSpace:(NSString*)stringToAddSpace spaceCount:(NSInteger)spaceCount atIndex:(NSInteger)index{
    NSString *result = [NSString stringWithFormat:@"%@%@",[@" " stringByPaddingToLength:spaceCount withString:@" " startingAtIndex:0],stringToAddSpace];
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:section];
    NSString *strTitle = @"";
    if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
        strTitle = [dict objectForKey:@"name"];
    }
    if (strTitle != nil && strTitle.length > 0) {
       // NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
       // if ([type isEqualToString:@"featured"]) {
        
        return 44;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section < m_arrPlaylistIds.count){
        NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:indexPath.section];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            //NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
            //if ([type isEqualToString:@"featured"]) {
                NSArray *arr = [dict objectForKey:@"videos"];
                if (arr != nil && [arr isKindOfClass:[NSDictionary class]]) {
                    arr = @[arr];
                }
                if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                    arr = [NSArray new];
                }
                NSMutableArray *arrFeatured = [NSMutableArray arrayWithArray:arr];
                
                float fHeightCarousel = (self.view.bounds.size.width *9 /16)+20;
                
                CGFloat fMargin = 2;
                CGFloat fWidthImage = self.view.frame.size.width- (fMargin * 2);
                CGFloat fHeightImage = fWidthImage*9/16;
                CGFloat fBrandImageWidthHeight = 33;
                ///
                if (arrFeatured.count > indexPath.row) {
                    NSDictionary *dict = [arrFeatured objectAtIndex:indexPath.row];
                    if(indexPath.section == 0){
                        int nIndex = 0;
                        int nLength = 0;
                        for (int i = 0; i < arrFeatured.count; i++) {
                            NSDictionary *dc = [arrFeatured objectAtIndex:i];
                            NSString *strTitle = [NSString stringWithFormat:@"%@",[dc objectForKey:@"name"]];
                            NSString *strSubtitle = @"";
                            //if (strSubtitle == nil || [strSubtitle isEqualToString:@"(null)"] || [strSubtitle isEqualToString:@"<null>"]) {
                            if(strTitle.length + strSubtitle.length > nLength){
                                nLength = (int)(strTitle.length + strSubtitle.length);
                                nIndex = i;
                            }
                            
                        }
                        dict = [arrFeatured objectAtIndex:nIndex];
                        
                    }
                    BOOL bLongform = FALSE;
                    NSDictionary *custom_fields = [dict objectForKey:@"custom_fields"];
                    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
                        NSString *longform = [custom_fields objectForKey:@"longform"];
                        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
                            bLongform = [longform boolValue];
                        }
                    }
                    
                    NSString *strTitle = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                    NSString *strSubtitle = @"";
                    //if (strSubtitle == nil || [strSubtitle isEqualToString:@"(null)"] || [strSubtitle isEqualToString:@"<null>"]) {
                    if (strSubtitle == nil || [strSubtitle isEqualToString:@"(null)"] || [strSubtitle isEqualToString:@"<null>"] || [strSubtitle isEqualToString:@"unknown"]) {
                        strSubtitle = @"";
                    }
                    
                    CGRect imgRect =CGRectMake(fMargin,fMargin, fWidthImage, fHeightImage);
                    CGRect rectTitle;
                    CGRect rectSubTitle;
                    
                    NSString *image_url = [dict objectForKey:@"details_screen_logo_url"];
                    
                    // if (bLongform)
                    if (image_url && [image_url isKindOfClass:[NSString class]] && image_url.length > 0)
                        // if (bLongform)
                    {
                        
                        rectTitle = CGRectMake(CGRectGetMinX(imgRect)+40,CGRectGetMaxY(imgRect)+fMargin, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)+40), 50);
                        rectSubTitle = CGRectMake(CGRectGetMinX(imgRect)+40,CGRectGetMaxY(rectTitle), CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)+40), 30);
                        
                        
                    }
                    else{
                        rectTitle = CGRectMake(CGRectGetMinX(imgRect),CGRectGetMaxY(imgRect)+fMargin, CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)), 50);
                        rectSubTitle = CGRectMake(CGRectGetMinX(imgRect),CGRectGetMaxY(rectTitle), CGRectGetMaxX(imgRect)-(CGRectGetMinX(imgRect)), 30);
                        
                        
                    }
                    CGSize labelTitleStringSize = [strTitle boundingRectWithSize:CGSizeMake(CGRectGetWidth(rectTitle), CGFLOAT_MAX)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      attributes:@{NSFontAttributeName:[[JLManager sharedManager] getVideoLargeTitleFont]}
                                                                         context:nil].size;
                    CGSize labelSubTitleStringSize = [strSubtitle boundingRectWithSize:CGSizeMake(CGRectGetWidth(rectSubTitle), CGFLOAT_MAX)
                                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                            attributes:@{NSFontAttributeName:[[JLManager sharedManager] getSubTitleFont]}
                                                                               context:nil].size;
                    
                    fHeightCarousel = fHeightCarousel + labelTitleStringSize.height + labelSubTitleStringSize.height+15;
                   
                }
                if (fHeightCarousel < (fBrandImageWidthHeight + (2*fMargin))) {
                    fHeightCarousel =(fBrandImageWidthHeight + (2*fMargin));
                }
                //if (arrFeatured.count > 1) {
//                if (indexPath.section == 0) {
//                    fHeightCarousel = fHeightCarousel + 10;
//                }
                return fHeightCarousel;
                
            }
        //}
    }
    return 145;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   //return 1;
    if(section == 0) return 1;
    else if(section < m_arrPlaylistIds.count){
        NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:section];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            NSArray *arr = [dict objectForKey:@"videos"];
            if (arr != nil && [arr isKindOfClass:[NSDictionary class]]) {
                arr = @[arr];
            }
            if (arr == nil) arr = @[];
            return arr.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(indexPath.section < m_arrPlaylistIds.count){
        NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:indexPath.section];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            //NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
            //if ([type isEqualToString:@"featured"]) {
           // if (indexPath.section == 0) {
                
                NSString *CellIdentifierFeatured =[NSString stringWithFormat:@"CellFeaturedHome%d",(int)indexPath.section];
                HomeFeaturedCell * homeFeaturedCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierFeatured];
                
                
                if (!homeFeaturedCell)
                {
                    [tableView registerNib:[UINib nibWithNibName:@"HomeFeaturedCell" bundle:nil] forCellReuseIdentifier:CellIdentifierFeatured];
                    homeFeaturedCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierFeatured];
                    
                }
                
                homeFeaturedCell.selectionStyle  = UITableViewCellSelectionStyleNone;
                
                NSArray *arr = [dict objectForKey:@"videos"];
                if (arr != nil && [arr isKindOfClass:[NSDictionary class]]) {
                    arr = @[arr];
                }
            
                if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
                    if(indexPath.section == 0){
                        [homeFeaturedCell updateData:arr];
                    }
                    else if(indexPath.row < arr.count){
                        NSDictionary *dictVideo = [arr objectAtIndex:indexPath.row];
                        [homeFeaturedCell updateData:@[dictVideo]];
                    }
                }
            
                
                return homeFeaturedCell;
            }
       /* }
        
        NSString *CellIdentifier =[NSString stringWithFormat:@"CellHome%d",(int)indexPath.section];
        HomeCell * homeCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        homeCell.mFromType = kFromHome;
        homeCell.m_nIndexPathSection = (int)indexPath.section + 1;
        if (!homeCell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
            homeCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        }
        homeCell.m_collView.tag = indexPath.section;
        homeCell.m_collView.contentOffset = CGPointZero;
        homeCell.backgroundColor = [UIColor clearColor];
        homeCell.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        NSArray *arr = [dict objectForKey:@"videos"];
        if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
            [homeCell updateData:arr];
        }
        NSString *strTitle = [dict objectForKey:@"name"];
        homeCell.m_strChannelName = [NSString stringWithFormat:@"%@",strTitle];
        
        
        return homeCell;*/
    }

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark -- UITableViewDataSourcePrefetching

// indexPaths are ordered ascending by geometric distance from the table view
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    /////
    
}

// indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -tableView:prefetchRowsAtIndexPaths:
- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
}
-(void)callAPIForGetHomeScreenData
{
    if (kDebugLog) NSLog(@"callAPIForGetHomeScreenData");
    
    m_lastRefreshTime = [[NSDate date] timeIntervalSince1970];
    [[JLManager sharedManager] showLoadingViewHome:self.view];
    NSString *strURL = [NSString stringWithFormat:@"%@",GET_HOMESCREEN2_URL] ;
   
    NSString *params = @"";//[NSString stringWithFormat:@"interests=%@",strInterests];
    if ([PerkoAuth IsUserLogin]) {
        params = [params stringByAppendingFormat:@"&access_token=%@",[PerkoAuth getPerkUser].accessToken]; 
    }

    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        [[JLManager sharedManager] hideLoadingViewHome];
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                NSArray *arr = [dict objectForKey:@"data"];
                if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                    arr = [NSArray new];
                }
                self->m_arrPlaylistIds = [NSMutableArray arrayWithArray:arr];
                self->m_arrPlaylistIds = [[JLManager sharedManager] removedWatchedLongformVideos:self->m_arrPlaylistIds];
                self->m_arrPlaylistIds = [self FiltervalidPlaylists];
            }

            [self checkForUserSelectionLoggedOutUser];
        }
        [self->m_refreshControl endRefreshing];
        [self setHeader];
    }];
}
-(NSMutableArray *)FiltervalidPlaylists{
    NSMutableArray * arytemp = [[NSMutableArray alloc] init];
    
    for (id obj in self->m_arrPlaylistIds){
        if ([obj isKindOfClass:[NSDictionary class]]){
            if([obj valueForKey:@"videos"] != nil && [obj valueForKey:@"videos"] != [NSNull null]){
                if([[obj valueForKey:@"videos"] isKindOfClass:[NSArray class]]){
                    if([[obj valueForKey:@"videos"] count] > 0){
                        [arytemp addObject:obj];
                    }
                }
            }
        }
    }
    return arytemp;
}

-(void)resetData
{
    if(kDebugLog)NSLog(@"postInterest resetData call");
    
    ///left menu
    m_imgHeaderLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 27)];
    m_imgHeaderLogo.contentMode = UIViewContentModeScaleAspectFit;
    m_imgHeaderLogo.image = [UIImage imageNamed:@"header-logo"];
    
    m_lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(35, 0, 200, 27)];
    m_lblTitle.textColor = kPrimaryTextColor;
    m_lblTitle.font = kFontPrimary18;
    
    float spacing = 3.2f;
    NSString *strTitle = @"WATCHBACK";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strTitle];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [strTitle length])];
    m_lblTitle.attributedText = attributedString;
    //m_lblTitle.text = strTitle;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 27)];
    leftView.backgroundColor = [UIColor clearColor];
    [leftView addSubview:m_imgHeaderLogo];
    [leftView addSubview:m_lblTitle];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftItem;
    //////
   /*
    m_btnProfile = [[UIButton alloc] initWithFrame:CGRectMake(38, 0, 28, 28)];
    if (@available(iOS 9, *)) {
        [m_btnProfile.widthAnchor constraintEqualToConstant:28].active = YES;
        [m_btnProfile.heightAnchor constraintEqualToConstant:28].active = YES;
    }
    [m_btnProfile addTarget:self action:@selector(btnProfileClicked) forControlEvents:UIControlEventTouchUpInside];
    m_btnProfile.contentMode = UIViewContentModeScaleAspectFit;
    m_btnProfile.layer.cornerRadius = m_btnProfile.frame.size.width / 2;
    m_btnProfile.clipsToBounds = YES;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 28)];
    if (@available(iOS 9, *)) {
        [rightView.widthAnchor constraintEqualToConstant:66].active = YES;
        [rightView.heightAnchor constraintEqualToConstant:28].active = YES;
    }
    rightView.backgroundColor = [UIColor clearColor];
     UIImage *image = nil;
    if([PerkoAuth IsUserLogin]){
        JLPerkUser * loginuser = PerkoAuth.getPerkUser;
        if (loginuser.profile_image != nil && [loginuser.profile_image isKindOfClass:[NSString class]] && loginuser.profile_image.length > 0) {
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:loginuser.profile_image]]];
            
        }
        if (image == nil) {
            image = getProfileFromText(self->m_btnProfile);           
        }
        
        [m_btnProfile setImage:image forState:UIControlStateNormal];
        
        [rightView addSubview:m_btnProfile];
    }
    else{        
        [m_btnProfile setImage:nil forState:UIControlStateNormal];
        
    }
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
    self.navigationItem.rightBarButtonItem = rightItem ;
    */
//    UIBarButtonItem *rightItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self refreshData];
}



-(void)btnProfileClicked{
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"3"];
    
    
    AccountVC *objAccountVC = [[AccountVC alloc] initWithNibName:@"AccountVC" bundle:nil];
    NavPortrait *navAccount = [[NavPortrait alloc] initWithRootViewController:objAccountVC];
    navAccount.navigationBarHidden = NO;
    [self presentViewController:navAccount animated:YES completion:nil];
}

-(void)checkForUserSelectionLoggedOutUser{
   
    //////////////////
   
    if (m_arrPlaylistIds.count > 0) {
        
        /////
        
        /*for (NSDictionary *dict in m_arrPlaylistIds) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                NSString *type = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]] lowercaseString];
                if ([type isEqualToString:@"featured"]) {
                    m_dictFeatured = dict;
                    NSArray *arr = [dict objectForKey:@"featured"];
                    if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                        arr = [NSArray new];
                    }
                    NSMutableArray *arrFeatured = [NSMutableArray arrayWithArray:arr];
                    float fWidth = self.view.bounds.size.width;
                    float fHeight = (fWidth *9 /16)+76+10;
                    if (arrFeatured.count < 2) {
                        fHeight = (fWidth *9 /16)+76+10-10;
                    }
                    mHomeFeaturedCell = [[HomeFeaturedCell alloc] initWithFrame:CGRectMake(0, 0, fWidth, fHeight)] ;
                    NSString *strTitle = [dict objectForKey:@"name"];
                    mHomeFeaturedCell.m_strChannelName = [NSString stringWithFormat:@"%@",strTitle];
                    
                    if (arrFeatured != nil && [arrFeatured isKindOfClass:[NSArray class]] && arrFeatured.count > 0 ) {
                         m_tblView.tableHeaderView = mHomeFeaturedCell;
                        [mHomeFeaturedCell updateData:arrFeatured];
                       
                    }
                    break;
                }
            }
        }
        if (m_dictFeatured != nil) {
            [m_arrPlaylistIds removeObject:m_dictFeatured];
        }*/
        /////
         [m_tblView reloadData];
    }
}
-(void)updatedUserSelection{
    [self callAPIForGetHomeScreenData];
}
-(void)themeChanged{
     m_lblTitle.textColor = kPrimaryTextColor;
    [m_tblView reloadData];

}



#pragma mark --search end
-(void)refreshData{
    [m_tblView setContentOffset:CGPointZero animated:NO];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fDiffrent = currentTime - m_lastRefreshTime;
    if(kDebugLog)NSLog(@"%f %f",currentTime, fDiffrent);
    if (fDiffrent > kAPICacheTime) {
        [self callAPIForGetHomeScreenData];
    }
    
    
}

-(void)checkforDOB{
    if (![PerkoAuth IsUserLogin]) {
        
    }
}
-(void)trackFirstHomeState{
    if (!m_bIsHomeStateTracked) {
        m_bIsHomeStateTracked = TRUE;
       [[JLTrackers sharedTracker] trackLeanplumState:@"Home"];
    }
    
}
-(void)userWatchedLongformVideoNotification{
    NSMutableArray *arr = [[JLManager sharedManager] removedWatchedLongformVideos:self->m_arrPlaylistIds];
    if (m_arrPlaylistIds != nil && [m_arrPlaylistIds isKindOfClass:[NSArray class]]) {
        NSSet *set1 = [NSSet setWithArray:m_arrPlaylistIds];
        NSSet *set2 = [NSSet setWithArray:arr];
        
        if ([set1 isEqualToSet:set2]) {
            return;
        }
    }
    
    m_arrPlaylistIds = arr;
    [m_tblView reloadData];
}
-(void)reloadDataForWatchedVideosNotification{
    [m_tblView reloadData];
}

//-(void)btnSettingClicked{
//    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
//    SettingsVC * objSettingsVC = [settingsStoryboard instantiateViewControllerWithIdentifier:@"settings"];
//
//    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSettingsVC];
//    nav.navigationBarHidden = FALSE;
//    [self presentViewController:nav animated:YES completion:nil];
//
//}

// MARK: - Image downloading
-(void)downloadImage:(NSString *)url imgView:(UIImageView *)imgView
{
    if (imageDownloadtasks == nil) {
        imageDownloadtasks = [NSMutableDictionary new];
    }
    //NSURLSessionDataTask *task = [tasks objectForKey:strUrl];
    NSMutableDictionary *dict = [imageDownloadtasks objectForKey:url];
    if (dict != nil && [dict isKindOfClass:[NSMutableDictionary class]]) {
        UIImage *image = [dict objectForKey:@"image"];
        if (image != nil && [image isKindOfClass:[UIImage class]]) {
            imgView.image = image;
            return;
        }
        // We're already downloading the image.
        NSMutableArray *arr = [dict objectForKey:@"imgViews"];
        if (arr == nil || ![arr isKindOfClass:[NSMutableArray class]]) {
            arr = [NSMutableArray new];
        }
        [arr addObject:imgView];
        [dict setObject:arr forKey:@"imgViews"];
        [imageDownloadtasks setObject:dict forKey:url];
    }
    else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
        ///
        dict = [NSMutableDictionary new];
        ////
        NSMutableArray *arr = [NSMutableArray new];
        [arr addObject:imgView];
        [dict setObject:arr forKey:@"imgViews"];
        [imageDownloadtasks setObject:dict forKey:url];

        ////
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                               completionHandler:
                ^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (data != nil) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image != nil && [image isKindOfClass:[UIImage class]]) {
//                                [[self->m_arrData objectAtIndex:indexPath.row] setObject:image forKey:@"image"];
//                                if ([[self->m_tblView indexPathsForVisibleRows] containsObject:indexPath]) {
//                                    [self->m_tblView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                                }
                                NSMutableDictionary *dict = [self->imageDownloadtasks objectForKey:url];
                                if (dict != nil && [dict isKindOfClass:[NSMutableDictionary class]]) {
                                    [dict setObject:image forKey:@"image"];
                                    // We're already downloading the image.
                                    NSMutableArray *arr = [dict objectForKey:@"imgViews"];
                                    if (arr != nil && [arr isKindOfClass:[NSMutableArray class]]) {
                                        for(UIImageView *imgView in arr){
                                            if (imgView != nil && [imgView isKindOfClass:[UIImageView class]]) {
                                                imgView.image = image;
                                            }
                                        }
                                    }
                                    [arr removeAllObjects];
                                    [self->imageDownloadtasks setObject:dict forKey:url];
                                }
                                
                            }
                        }
                        
                        
                    });
                    
                    
                }];
        [task resume];
    }
//    //////////////
//    if (task != nil && [task isKindOfClass:[NSURLSessionDataTask class]]) {
//        // We're already downloading the image.
//        return;
//    }
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
//    task = [[NSURLSession sharedSession] dataTaskWithRequest:request
//                                           completionHandler:
//            ^(NSData *data, NSURLResponse *response, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    if (data != nil) {
//                        UIImage *image = [UIImage imageWithData:data];
//                        if (image != nil && [image isKindOfClass:[UIImage class]]) {
//                            [[self->m_arrData objectAtIndex:indexPath.row] setObject:image forKey:@"image"];
//                            if ([[self->m_tblView indexPathsForVisibleRows] containsObject:indexPath]) {
//                                [self->m_tblView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                            }
//                        }
//                    }
//
//
//                });
//
//
//            }];
//    [task resume];
//    [tasks setObject:task forKey:indexPath];
    
}
-(void)setHeader{
    /*NSString *strTitle = @"";
    if(m_arrPlaylistIds.count > 0){
        
        NSDictionary *dict = [m_arrPlaylistIds objectAtIndex:0];
        if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            strTitle = [dict objectForKey:@"name"];
            
        }
    }
    m_lblTitle.text = strTitle;*/
}
@end
