//
//  SubscribeVC.m
//  Watchback
//
//  Created by Nilesh on 4/2/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "SubscribeVC.h"
#import "Constants.h"
#import "JLTrackers.h"
#import "WebServices.h"
#import "PerkoAuth.h"
#import "ChannelsCell.h"
#import "AppLabel.h"
#import "SettingsVC.h"
#import "NavPortrait.h"
#import "BrandPortalVC.h"
#import "FavoriteCell.h"
#import "ChannelCell.h"

@interface SubscribeVC ()
{

    NSMutableArray *aryChannels;
    UIRefreshControl *refreshControl;
    BOOL IsLoading;
    ///search
    
    UISearchController *searchController;
    BOOL searchControllerWasActive;
    NSTimeInterval lastRefreshTime;
    AppLabel * lblTitle;
    BOOL is_favorite_show_available;
    NSMutableArray * ary_favorite_shows;
    UICollectionView *collection_favorites;

}
@property (weak, nonatomic) IBOutlet UITableView *tblChannels;

@end

@implementation SubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tblChannels.backgroundView = nil;
    self.tblChannels.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReloadGenresdata) name:kReloadGenresDataNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenChannelNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OpenChannel:)
                                                 name:kOpenChannelNotification object:nil];
    
    ary_favorite_shows = [[NSMutableArray alloc] init];
    lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 27)];
    lblTitle.textColor = kPrimaryTextColor;
    lblTitle.font = kFontPrimary20;
    NSString *strTitle = @"Channels";
    lblTitle.text = strTitle;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 27)];
    leftView.backgroundColor = [UIColor clearColor];
    [leftView addSubview:lblTitle];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
//    UIBarButtonItem *rightItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //aryGenres = [[NSMutableArray alloc] init];
    
    refreshControl = [[UIRefreshControl alloc]init];
//    [m_tblView addSubview:refreshControl];
    [self.tblChannels addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(pullToRefresh) forControlEvents:UIControlEventValueChanged];
//    m_tblView.backgroundView = nil;
    //self.collectionView.backgroundView = nil;
    //    m_tblView.backgroundColor = kPrimaryBGColor;
    IsLoading = NO;
    lastRefreshTime = [[NSDate date] timeIntervalSince1970];
    aryChannels = [NSMutableArray new];
    [self callAPIForGetGeneres];
    ////
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kRefreshChannelDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForWatchedVideosNotification) name:kReloadDataForWatchedVideosNotification object:nil];
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Channel Playlist" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Channel Playlist" data:dictTrackingData];
    ////////
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear: animated];
    [JLManager sharedManager].m_bIsTabbarVisible = TRUE;
    [self reskinUIElements];
    [[JLTrackers sharedTracker] trackFBEvent:SubscribeScreenEvent params:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [JLManager sharedManager].m_bIsTabbarVisible = FALSE;
    
}
-(void)viewDidDisappear:(BOOL)animated{
    if (searchControllerWasActive) {
        searchControllerWasActive = NO;
        [searchController dismissViewControllerAnimated:NO completion:nil];
        searchController.active = FALSE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark-
#pragma mark - UITableView datasource and delegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        return 2;
    }else if(ary_favorite_shows.count >0){
        return 1;
    }else if(aryChannels.count > 0){
        return 1;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        if(section == 0){
            return 1;
        }else{
            int quotient = floor(aryChannels.count/3);
            int reminder = (aryChannels.count % 3);
            if(reminder > 0){
                quotient += 1;
            }
            return quotient;
        }
    }else if(ary_favorite_shows.count > 0){
        // aryChannels.count = 0
        if(section == 0){
            return 1;
        }
    }else if(aryChannels.count > 0){
        if(section == 0){
            int quotient = floor(aryChannels.count/3);
            int reminder = (aryChannels.count % 3);
            if(reminder > 0){
                quotient += 1;
            }
            return quotient;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    NSString *strTitle = @"";
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 41)];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width-10, 41)];
    lblHeader.textAlignment = NSTextAlignmentLeft;
    lblHeader.textColor = kPrimaryTextColor;
    lblHeader.font =kFontPrimaryBold12;
    lblHeader.backgroundColor = [UIColor clearColor];
    [viewHeader addSubview:lblHeader];
    
    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        if(section == 0){
            strTitle = @"FAVORITE";
        }else{
            strTitle = @"CHANNELS";
        }
    }else if(ary_favorite_shows.count > 0){
        strTitle = @"FAVORITE";
    }else if(aryChannels.count > 0){
        strTitle = @"CHANNELS";
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strTitle];

    float spacing = 2.2f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [strTitle length])];

    lblHeader.attributedText = attributedString;
    
    return viewHeader;

    
}
-(NSString*)stringByAddingSpace:(NSString*)stringToAddSpace spaceCount:(NSInteger)spaceCount atIndex:(NSInteger)index{
    NSString *result = [NSString stringWithFormat:@"%@%@",[@" " stringByPaddingToLength:spaceCount withString:@" " startingAtIndex:0],stringToAddSpace];
    return result;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        return 41;
    }else if(ary_favorite_shows.count > 0){
            return 41;
        
    }else if(aryChannels.count > 0){
            return 41;
        
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        if(indexPath.section == 0){
            return 140;
        }else{
            return UITableViewAutomaticDimension;
        }
    }else if(ary_favorite_shows.count > 0){
       return 140;
        
    }else if(aryChannels.count > 0){
            return UITableViewAutomaticDimension;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if(ary_favorite_shows.count > 0 && aryChannels.count > 0){
        if(indexPath.section == 0){
          FavoriteCell * cell = (FavoriteCell *)[tableView dequeueReusableCellWithIdentifier:@"favorite_cell"];
            if(cell != nil){
            cell.ary_fav_items = ary_favorite_shows;
            [cell.fav_collectionview reloadData];
            return cell;
                
            }
            
        }else {
            ChannelCell * cell = (ChannelCell *)[tableView dequeueReusableCellWithIdentifier:@"channel_cell"];
            if(cell != nil){
            if((3 * indexPath.row) < aryChannels.count){
                [cell.channelA hideChannel:NO];
                cell.channelA.isfavorite = NO;
                [cell.channelA setChannel:[aryChannels objectAtIndex:(3 * indexPath.row)]];
            }else{
                cell.channelA.isfavorite = NO;
                [cell.channelA hideChannel:YES];
            }
            if((3 * indexPath.row + 1) < aryChannels.count){
                [cell.channelB hideChannel:NO];
                cell.channelB.isfavorite = NO;
                [cell.channelB setChannel:[aryChannels objectAtIndex:(3 * indexPath.row + 1)]];
            }else{
                cell.channelB.isfavorite = NO;
                [cell.channelB hideChannel:YES];
            }
            if((3 * indexPath.row + 2) < aryChannels.count){
                [cell.channelC hideChannel:NO];
                cell.channelC.isfavorite = NO;
                [cell.channelC setChannel:[aryChannels objectAtIndex:(3 * indexPath.row + 2)]];
            }else{
                cell.channelC.isfavorite = NO;
                [cell.channelC hideChannel:YES];
            }
            }
            return cell;
        }
    }else if(ary_favorite_shows.count > 0){
        if(indexPath.section == 0){
            FavoriteCell * cell = (FavoriteCell *)[tableView dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
            if(cell != nil){
            cell.ary_fav_items = ary_favorite_shows;
            [cell.fav_collectionview reloadData];
            return cell;
            }
        }
    }else if(aryChannels.count >0 ){
        if(indexPath.section == 0 ){
            ChannelCell * cell = (ChannelCell *)[tableView dequeueReusableCellWithIdentifier:@"channel_cell" forIndexPath:indexPath];
            if(cell != nil){
            if((3 * indexPath.row) < aryChannels.count){
                [cell.channelA hideChannel:NO];
                cell.channelA.isfavorite = NO;
                [cell.channelA setChannel:[aryChannels objectAtIndex:(3 * indexPath.row)]];
            }else{
                cell.channelA.isfavorite = NO;
                [cell.channelA hideChannel:YES];
            }
            if((3 * indexPath.row + 1) < aryChannels.count){
                [cell.channelB hideChannel:NO];
                cell.channelB.isfavorite = NO;
                [cell.channelB setChannel:[aryChannels objectAtIndex:(3 * indexPath.row + 1)]];
            }else{
                cell.channelB.isfavorite = NO;
                [cell.channelB hideChannel:YES];
            }
            if((3 * indexPath.row + 2) < aryChannels.count){
                [cell.channelC hideChannel:NO];
                cell.channelC.isfavorite = NO;
                [cell.channelC setChannel:[aryChannels objectAtIndex:(3 * indexPath.row + 2)]];
            }else{
                cell.channelC.isfavorite = NO;
                [cell.channelC hideChannel:YES];
            }
            }
            return cell;
        }
    }
    
    
    return nil;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}




#pragma mark-
#pragma mark ibaction or custom methods
-(NSMutableArray *)filterValidChannels:(NSArray *)ary{
   
    
    NSSet * unique_channels = [NSSet setWithArray:ary];
    
    NSArray * ary_unique_channels = [[NSMutableArray alloc] initWithArray:unique_channels.allObjects];
    
//    NSSortDescriptor *lastDescriptor =
//    //input a particular key in dictionary..eg: "date" here
//    [[NSSortDescriptor alloc] initWithKey:@"name"
//
//                                ascending:YES
//
//                                 selector:@selector(localizedCaseInsensitiveCompare:)];
//
//    NSArray *descriptors = [NSArray arrayWithObjects:lastDescriptor, nil];
//    //input array containing dictionaries
//    NSArray *arr = [ary_unique_channels sortedArrayUsingDescriptors:descriptors];
   // NSLog(@"sorted %@",arr);
    
    return ary_unique_channels;
}


-(void)ReloadGenresdata{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callAPIForGetGeneres];
    });
}

-(void)OpenChannel:(id)sender{

    if ([[sender object] isKindOfClass:[NSDictionary class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JLTrackers sharedTracker] trackFBEvent:DiscoverThumbnailEvent params:nil];
            UIStoryboard * subscribestoryboard = [UIStoryboard storyboardWithName:@"Subscribe" bundle:nil];
            BrandPortalVC * objBrandPortalVC = [subscribestoryboard instantiateViewControllerWithIdentifier:@"brandportal"];
            objBrandPortalVC.dict_channel_info = [sender object];
            if([objBrandPortalVC.dict_channel_info valueForKey:@"favorite"] !=nil && [objBrandPortalVC.dict_channel_info valueForKey:@"favorite"] != [NSNull null]){
                objBrandPortalVC.isfavorite = [[objBrandPortalVC.dict_channel_info valueForKey:@"favorite"] boolValue];
            }

            [self.navigationController pushViewController:objBrandPortalVC animated:YES];
        });
    }
}

-(void)reskinUIElements{
    self->lblTitle.textColor = kPrimaryTextColor;
    self.view.backgroundColor = kPrimaryBGColor;

}

//-(void)btnSettingClicked{
//    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
//    SettingsVC * objSettingsVC = [settingsStoryboard instantiateViewControllerWithIdentifier:@"settings"];
//
//    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSettingsVC];
//    nav.navigationBarHidden = FALSE;
//    [self presentViewController:nav animated:YES completion:nil];
//
//    [[JLTrackers sharedTracker] trackFBEvent:@"settings_tap" params:nil];
//}

-(void)pullToRefresh{
    IsLoading = NO;
    lastRefreshTime = [[NSDate date] timeIntervalSince1970];
//    [aryGenres removeAllObjects];
//    [m_tblView reloadData];
//    [self.tableView reloadData];
    [self callAPIForGetGeneres];
}

-(void)callAPIforFavoriteShows:(void (^) (BOOL success))handler{
    if(![[PerkoAuth getPerkUser] IsUserLogin]){
        id ary_local_fav = [[JLManager sharedManager] getObjectuserDefault:kFavoriteChannels];
        self->is_favorite_show_available = false;
        
        if ([ary_local_fav isKindOfClass:[NSArray class]]){
            if(((NSArray *)ary_local_fav).count > 0 && ary_local_fav){
                self->is_favorite_show_available = true;
            }
        }
        
        if(self->is_favorite_show_available){
//            NSMutableArray * ary_data = [[NSMutableArray alloc] init];
//
//            NSMutableDictionary * dict_channels = [[NSMutableDictionary alloc] init];
//            [dict_channels setValue:ary_local_fav forKey:@"channels"];
//            [ary_data addObject:dict_channels];
                [self->ary_favorite_shows removeAllObjects];
                [self->ary_favorite_shows addObjectsFromArray:ary_local_fav];
        }else{
            [self->ary_favorite_shows removeAllObjects];
        }

        return handler(YES);
    }
    NSString *strURL = [NSString stringWithFormat:@"%@",GET_FAVORITES_URL] ;
    NSString * params = [NSString stringWithFormat:@"access_token=%@",[PerkoAuth getPerkUser].accessToken];
    
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {

        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                NSArray * ary_data = [dict objectForKey:@"data"];
                if (ary_data == nil || ![ary_data isKindOfClass:[NSArray class]]) {
                    if(ary_data !=nil && [ary_data isKindOfClass:[NSDictionary class]]){
                        NSMutableArray * temp_ary = [[NSMutableArray alloc] init];
                        NSDictionary * dict_data = (id)ary_data; // because ary_data is of kind dictionary...
                        [temp_ary addObject:dict_data];
                        ary_data = nil;
                        ary_data = temp_ary;
                    }else{
                        ary_data = [NSArray new];
                    }
                }
                [self->ary_favorite_shows removeAllObjects];
                if([ary_data count] > 0){
                    if([[ary_data objectAtIndex:0] valueForKey:@"channels"] != nil &&
                       [[ary_data objectAtIndex:0] valueForKey:@"channels"] != [NSNull null]){
                        
                    if([[[ary_data objectAtIndex:0] valueForKey:@"channels"] isKindOfClass:[NSArray class]]){

                        if( ((NSArray *)[[ary_data objectAtIndex:0] valueForKey:@"channels"]).count > 0){
                            self->is_favorite_show_available = true;
                            
                            [self->ary_favorite_shows addObjectsFromArray:((NSArray *)[[ary_data objectAtIndex:0] valueForKey:@"channels"])];
                            //                        [self->m_tblView reloadData];
                            
                            //self->IsLoading = NO;

                        }
                    }
                }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                return handler(YES);
            });
            
            //            [self->m_tblView reloadData];
            //            self->IsLoading = NO;
        }else{
             [self->ary_favorite_shows removeAllObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                return handler(YES);
            });
        }
    }];

}

-(void)callAPIForGetGeneres
{
    is_favorite_show_available = false;
    [[JLManager sharedManager] showLoadingViewChannel:self.view];
    [self callAPIforFavoriteShows:^(BOOL success) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *strURL = [NSString stringWithFormat:@"%@",GET_CHANNELS_URL] ;
            if([PerkoAuth getPerkUser].IsUserLogin){
                
            }else{
               
            }
        NSString * params = @"";
            if([PerkoAuth getPerkUser].IsUserLogin){
                params = [NSString stringWithFormat:@"access_token = %@",[PerkoAuth getPerkUser].accessToken];
            }
        
        [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
            
            if (success) {
                if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    NSDictionary * dict_data = [dict objectForKey:@"data"];
                    if(dict_data != nil && (id)dict_data !=[NSNull null]){
                        NSArray * arr = [dict_data valueForKey:@"channels"];
                   
                    if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                        arr = [NSArray new];
                    }
                    //arr = [self filterValidChannels:arr];
                    
                    if (arr.count > 0) {
                        [self->aryChannels removeAllObjects];
                        [self->aryChannels addObjectsFromArray:arr];
                        
                        //                        [self->m_tblView reloadData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tblChannels reloadData];
                            
                        });
                        self->IsLoading = NO;
                    }else{
                        [self->aryChannels removeAllObjects];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tblChannels reloadData];
                            
                        });
                        self->IsLoading = NO;
                    }
                    // self->aryGenres = [NSMutableArray arrayWithArray:arr];
                    // }
                }
                }
                //            [self->m_tblView reloadData];
                //            self->IsLoading = NO;
                [self->refreshControl endRefreshing];
                [[JLManager sharedManager] hideLoadingViewChannel];
            }else{
                [self->aryChannels removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblChannels reloadData];
                    
                });
                self->IsLoading = NO;
                [self->refreshControl endRefreshing];

                [[JLManager sharedManager] hideLoadingViewChannel];
            }
        }];
            
        });

    }];
    
    
//    if (IsLoading) return;
//    IsLoading = YES;
//    if (aryGenres.count < 3) {
//        [[JLManager sharedManager] showLoadingViewChannel:self.view];
//    }
    
    
}


-(void)themeChanged{
    
//    [m_tblView reloadData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tblChannels reloadData];
        self->lblTitle.textColor = kPrimaryTextColor;
        
        self->searchController.view.backgroundColor = kSecondBGColor;
        UITextField *txfSearchField = [self->searchController.searchBar valueForKey:@"_searchField"];
        if (txfSearchField != nil) {
            txfSearchField.backgroundColor = kSecondBGColor;
            txfSearchField.textColor = kPrimaryTextColor;
            txfSearchField.tintColor = kPrimaryTextColor;
        }
        self.view.backgroundColor = kPrimaryBGColor;
    });
    
}
-(void)refreshData{
//    [m_tblView setContentOffset:CGPointZero animated:NO];
//    [self.tableView setContentOffset:CGPointZero animated:NO];
////    [m_tblView reloadData];
//    [self.tableView reloadData];
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval fDiffrent = currentTime - lastRefreshTime;
    if(kDebugLog)NSLog(@"%f %f",currentTime, fDiffrent);
    if (fDiffrent > kAPICacheTime) {
        IsLoading = NO;
        lastRefreshTime = [[NSDate date] timeIntervalSince1970];
//        [aryGenres removeAllObjects];
//        [m_tblView reloadData];
//        [self.tableView reloadData];
        [self callAPIForGetGeneres];
    }
    
}
-(void)reloadDataForWatchedVideosNotification{
    // [m_tblView reloadData];
    [self pullToRefresh];
}
@end
