//
//  PerkTabVC.m
//  Watchback
//
//  Created by Nilesh on 7/29/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "PerkTabVC.h"
#import "HomeVC.h"
#import "SubscribeVC.h"
#import "RewardsVC.h"
#import "JLBtnCurrency.h"
#import "Constants.h"
#import "JLManager.h"
#import "NavPortrait.h"
#import "PerkoAuth.h"
#import "MovieTicketsVC.h"
#import "SettingsVC.h"

@interface PerkTabVC ()<UITabBarControllerDelegate>

@end

@implementation PerkTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.tabBar.translucent = TRUE;
    self.tabBar.backgroundColor = [UIColor clearColor];
    /////
    [self createTabbar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setSelectedTabIndex:)
                                                 name:kSetSelectedTabIndexNotification
                                               object:nil];
    
   self.navigationController.navigationBarHidden = FALSE;
    
   // [self performSelector:@selector(trackFirstHomeState) withObject:nil afterDelay:2];
    
}

-(void)setSelectedTabIndex:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    int nIndex = [[sender object] intValue];
    self.selectedIndex = nIndex;
    [self refreshData];
   
    
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
-(void)createTabbar
{
    
    
    NSMutableArray *arrTabs = [[NSMutableArray alloc] initWithCapacity:5];
    
    //Tab 1
    HomeVC *objHomeVC = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
   // objHomeVC.tabBarItem.title = @"Home";
    objHomeVC.tabBarItem.image = [[UIImage imageNamed: @"discover-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objHomeVC.tabBarItem.selectedImage = [[UIImage imageNamed: @"discover-on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objHomeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    NavPortrait *navHome = [[NavPortrait alloc] initWithRootViewController:objHomeVC];
    //navHome.tabBarItem.title = @"Discover";
    navHome.navigationBarHidden = NO;
    [arrTabs addObject:navHome];
    
    
    //Tab 2

    UIStoryboard * subscribestoryboard = [UIStoryboard storyboardWithName:@"Subscribe" bundle:nil];
    SubscribeVC * objSubscribeVC = [subscribestoryboard instantiateViewControllerWithIdentifier:@"subscribe"];

    objSubscribeVC.tabBarItem.image = [[UIImage imageNamed: @"channel-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objSubscribeVC.tabBarItem.selectedImage = [[UIImage imageNamed: @"channel-on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objSubscribeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    NavPortrait *navPlaylist = [[NavPortrait alloc] initWithRootViewController:objSubscribeVC];
    //navPlaylist.tabBarItem.title = @"Channels";
    navPlaylist.navigationBarHidden = NO;
    [arrTabs addObject:navPlaylist];
    
    
    //Tab 3
    MovieTicketsVC * objMovieTicketsVC= [[MovieTicketsVC alloc] initWithNibName:@"MovieTicketsVC" bundle:nil];
    objMovieTicketsVC.tabBarItem.image = [[UIImage imageNamed: @"movie-tickets-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objMovieTicketsVC.tabBarItem.selectedImage = [[UIImage imageNamed: @"movie-tickets-on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objMovieTicketsVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    NavPortrait *navMovieTickets = [[NavPortrait alloc] initWithRootViewController:objMovieTicketsVC];
    //navMovieTickets.tabBarItem.title = @"Movie Tickets";
    navMovieTickets.navigationBarHidden = NO;
    [arrTabs addObject:navMovieTickets];
    
    
    //Tab 4
    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    SettingsVC * objSettingsVC = [settingsStoryboard instantiateViewControllerWithIdentifier:@"settings"];
    objSettingsVC.tabBarItem.image = [[UIImage imageNamed: @"settings-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objSettingsVC.tabBarItem.selectedImage = [[UIImage imageNamed: @"settings-on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    objSettingsVC.tabBarItem.imageInsets = UIEdgeInsetsMake(12, 0, -12, 0);
    NavPortrait *navSettings = [[NavPortrait alloc] initWithRootViewController:objSettingsVC];
//    navSettings.tabBarItem.title = @"App Settings";
    navSettings.navigationBarHidden = NO;
    [arrTabs addObject:navSettings];
    
//    //Tab 4
//    CalendarVC *objCalendarVC = [[CalendarVC alloc] initWithNibName:@"CalendarVC" bundle:nil];
//    objCalendarVC.tabBarItem.image = [[UIImage imageNamed: @"tab-4-calendar-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    objCalendarVC.tabBarItem.selectedImage = [[UIImage imageNamed: @"tab-4-calendar-on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    objCalendarVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    NavPortrait *navAccount = [[NavPortrait alloc] initWithRootViewController:objCalendarVC];
//   // navAccount.tabBarItem.title = @"My Account";
//    navAccount.navigationBarHidden = NO;
//    [arrTabs addObject:navAccount];
    

    ////
     
    self.viewControllers = arrTabs;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[JLManager sharedManager] updatePlayerBarLayout];
//   [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
//
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[JLManager sharedManager] updatePlayerBarLayout];

}
- (BOOL)tabBarController:(UITabBarController *)atabBarController shouldSelectViewController:(UIViewController *)viewController
{
//    self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.rightBarButtonItem = nil;
//    self.navigationItem.title = @"";
    
    return true;
}
- (void)tabBarController:(UITabBarController *)atabBarController didSelectViewController:(UIViewController *)viewController
{
//    if (!PerkoAuth.IsUserLogin) {
//        if (atabBarController.selectedIndex == 2 || atabBarController.selectedIndex == 3) {
//            [[JLManager sharedManager] showLoginSignUpwithUserAction:0];
//            self.selectedIndex = 0;
//        }
//    }
    [self refreshData];
    
}
#pragma mark --Orientation
-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)refreshData{
    if (self.selectedIndex == 0){ //Home
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshHomeDataNotification object:nil];
        [[JLTrackers sharedTracker] trackLeanplumState:@"Home"];
    }
    else if (self.selectedIndex == 1){ //Channels
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshChannelDataNotification object:nil];
        [[JLTrackers sharedTracker] trackLeanplumState:@"Channels"];
    }
    else if(self.selectedIndex == 2){
        
    }else if(self.selectedIndex == 3){
        [[JLTrackers sharedTracker] trackFBEvent:@"settings_tap" params:nil];
    }
//    else if (self.selectedIndex == 2){ //Thank you
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshThankyouDataNotification object:nil];
//        [[JLTrackers sharedTracker] trackLeanplumState:@"Sweepstakes"];
//        [[JLTrackers sharedTracker] trackSingularEvent:@"visit_tysweeps_screen"];
//        [[JLTrackers sharedTracker] trackFBEvent:@"visit_tysweeps_screen" params:nil];
//
//    }
//    else if (self.selectedIndex == 3){ //Account
//        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshMyAccountDataNotification object:nil];
//        [[JLTrackers sharedTracker] trackLeanplumState:@"Account"];
//    }
    
    [[JLManager sharedManager] updatePlayerBarLayout];
}
@end
