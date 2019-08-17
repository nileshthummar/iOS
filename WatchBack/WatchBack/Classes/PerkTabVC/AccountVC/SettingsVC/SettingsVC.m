

#import "SettingsVC.h"
#import "JLBtnCurrency.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "JLUtils.h"
#import "RedeemWebVC.h"
#import "Constants.h"
#import "PerkoAuth.h"
#import "JLManager.h"
#import "NavPortrait.h"
#import "DeveloperOptions.h"
#import "NielsenOptOutVC.h"
#import "SettingsTableViewCell.h"
#import "MyAccountViewController.h"
#import "AppLabel.h"

NSString *const MyAccountMenuItem = @"My Account";
NSString *const ShareWatchbackMenuItem = @"Share WatchBack";
NSString *const RateUsMenuItem = @"Rate Us";
NSString *const SupportCenterMenuItem = @"Support Center";
NSString *const TermsAndConditionsMenuItem = @"Terms & Conditions";
NSString *const PrivacyPolicyMenuItem = @"Privacy Policy";
NSString *const VideoViewingPolicyMenuItem = @"Video Viewing Policy";
NSString *const NielsenMeasurementMenuItem = @"About Nielsen Measurement";
NSString *const DeveloperOptionsMenuItem = @"Developer Options";

@interface SettingsVC (){
    IBOutlet UITableView *m_tblView;
    IBOutlet UIView *m_tblFooterView;
    IBOutlet UIButton *m_btnLogout;
    IBOutlet UILabel  *m_lblCopyright;
    
    
    ///
    UISwitch *m_switchTheme;
    
    NSMutableArray * arySettingsMenuItems;
    AppLabel * lblTitle;
}
@end

@implementation SettingsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //self.title= @"App Settings";
   // m_tblView.backgroundColor = kPrimaryBGColor;
    [self setCustomColor];
    [self initTheme];
    [self initMenuItems];
    [self setFooterView];
    [self customizeNavigationBar];

    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeStates:@"Settings" data:dictTrackingData];
    ////////
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
       
    [[JLTrackers sharedTracker] trackFBEvent:SettingsScreenEvent params:nil];

}
-(void)viewWillDisappear:(BOOL)animated{
   
    [super viewWillDisappear:animated];
}
#pragma mark-
#pragma mark ibaction or custom methods
-(void)resetNavigationBar{
    self.navigationItem.titleView = nil;
    [lblTitle removeFromSuperview];
    lblTitle = nil;
}

-(void)customizeNavigationBar{
    lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(0, 0, 250, 27)];
    lblTitle.textColor = kPrimaryTextColor;
    lblTitle.font = kFontPrimary20;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    NSString *strTitle = @"App Settings";
    lblTitle.text = strTitle;
    
   
    
    self.navigationItem.titleView = lblTitle;
    
}

-(void)GoToAccountScreen{
    if([PerkoAuth getPerkUser].IsUserLogin){
    [[JLTrackers sharedTracker] trackFBEvent:AccountScreenEvent params:nil];

    UIStoryboard * settingsStoryboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    MyAccountViewController * objMyAccountViewController = [settingsStoryboard instantiateViewControllerWithIdentifier:@"myaccount"];
    [self.navigationController pushViewController:objMyAccountViewController animated:YES];
    }
}

-(void)openNielsen{
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Settings:About Nielsen Measurement" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings:About Nielsen Measurement" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Settings:About Nielsen Measurement" data:dictTrackingData];
    ////////
    
    
    NielsenOptOutVC *objNielsenOptOutVC = [[NielsenOptOutVC alloc]initWithNibName:@"NielsenOptOutVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objNielsenOptOutVC];
    nav.navigationBarHidden = FALSE;
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)openVPPA{
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Settings:Video Viewing Policy" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings:Video Viewing Policy" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Settings:Video Viewing Policy" data:dictTrackingData];
    ////////
    
    
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kVPPA;
    objRedeemWebVC.title = @"Video Viewing Policy";
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)openPrivacyPolicy{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kPrivacyPolicy;
    objRedeemWebVC.title = @"Privacy Policy";
    [self presentViewController:nav animated:YES completion:nil];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Settings:Privacy Policy" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Settings:Privacy Policy" data:dictTrackingData];

}

-(void)openTermsAndConditions{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kTermsAndConditionsLink;
    objRedeemWebVC.title = @"Terms & Conditons";
    [self presentViewController:nav animated:YES completion:nil];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"Settings:Terms & Conditions" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Settings:Terms & Conditions" data:dictTrackingData];

}

-(void)openSupportCenter{
    RedeemWebVC *objRedeemWebVC = [[RedeemWebVC alloc]initWithNibName:@"RedeemWebVC" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objRedeemWebVC];
    nav.navigationBarHidden = FALSE;
    objRedeemWebVC.m_strUrl = kHelpLink;
    objRedeemWebVC.title = @"Support Center";
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)rateWatchbackApp{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kAppStore_URL] options:@{} completionHandler:^(BOOL success) {
        
    }];
    
    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStore_URL]];
    //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStore_URL] options:UIApplicationOpenURLOptionsAnnotationKey completionHandler:nil];
    // [[UIApplication sharedApplication]openURL:[NSURL URLWithString:kAppStore_URL] options:UIApplicationOpenURLOptionsSourceApplicationKeyannotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Click:Rate Us" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Rate Us" data:dictTrackingData];
}

-(void)sharewatchbackApp{
    NSString *theMessage = @"https://go.onelink.me/7JBs/getWatchBack";
    NSArray *items = @[theMessage];
    
    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    // and present it
    [self presentActivityController:controller];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.share"];
    [dictTrackingData setObject:@"Click:Share" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Share" data:dictTrackingData];

}

-(void)initMenuItems{
    arySettingsMenuItems = [[NSMutableArray alloc] init];
    
    NSMutableArray * arySettingsMenuSubItems = [[NSMutableArray alloc] init];

     NSString *debug =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeDebug]];
    
    NSMutableDictionary * dict;
    
    if([PerkoAuth getPerkUser].IsUserLogin){
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"account-icon",@"image",MyAccountMenuItem,@"name",nil];
        [arySettingsMenuSubItems addObject:dict];
    }
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"share-icon",@"image",ShareWatchbackMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"rate-icon",@"image",RateUsMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];

    [arySettingsMenuItems addObject:arySettingsMenuSubItems];
    
    
    
    
    arySettingsMenuSubItems = nil;
    arySettingsMenuSubItems = [[NSMutableArray alloc] init];
    
    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:SupportCenterMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];
    

    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:TermsAndConditionsMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];
    

    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:PrivacyPolicyMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];

    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:VideoViewingPolicyMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];

    dict = nil;
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NielsenMeasurementMenuItem,@"name",nil];
    [arySettingsMenuSubItems addObject:dict];

    
    [arySettingsMenuItems addObject:arySettingsMenuSubItems];
    
    
    if(debug){
        arySettingsMenuSubItems = nil;
        arySettingsMenuSubItems = [[NSMutableArray alloc] init];

        dict = nil;
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:DeveloperOptionsMenuItem,@"name",nil];
        [arySettingsMenuSubItems addObject:dict];

        [arySettingsMenuItems addObject:arySettingsMenuSubItems];

    }

}


-(void)btnClosedClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark --table view delegate
#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arySettingsMenuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 47.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[arySettingsMenuItems objectAtIndex:section] count];
    
}
            
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    SettingsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setData:[[arySettingsMenuItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * selectedItem = [[[arySettingsMenuItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(selectedItem){
            if([selectedItem isEqualToString:MyAccountMenuItem]){
                [self GoToAccountScreen];
            }else if([selectedItem isEqualToString:ShareWatchbackMenuItem]){
                [self sharewatchbackApp];
            }else if([selectedItem isEqualToString:RateUsMenuItem]){
                [self rateWatchbackApp];
            }else if([selectedItem isEqualToString:SupportCenterMenuItem]){
                [self openSupportCenter];
            }else if([ selectedItem isEqualToString:TermsAndConditionsMenuItem]){
                [self openTermsAndConditions];
            }else if([selectedItem isEqualToString:PrivacyPolicyMenuItem]){
                [self openPrivacyPolicy];
            }else if([selectedItem isEqualToString:VideoViewingPolicyMenuItem]){
                [self openVPPA];
            }else if([selectedItem isEqualToString:NielsenMeasurementMenuItem]){
                [self openNielsen];
            }else if([selectedItem isEqualToString:DeveloperOptionsMenuItem]){
                [self openDeveloperOptionsMenu];
            }
        }

    });
}


-(IBAction)btnLogOutClicked:(id)sender
{
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:@"Are you sure want to logout?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* btnOK = [UIAlertAction
                            actionWithTitle:@"Yes"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                //Handle your yes please button action here
                                [[JLManager sharedManager] showLoadingView:self.view];
                                [self performSelector:@selector(logout) withObject:nil afterDelay:1];
                                
                            }];
    UIAlertAction* btnNo = [UIAlertAction
                            actionWithTitle:@"No"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                //Handle your yes please button action here
                                
                            }];
    
    [alert addAction:btnOK];
    [alert addAction:btnNo];
    [self presentViewController:alert animated:YES completion:nil];
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.userid"];
    [dictTrackingData setObject:@"Not Logged In" forKey:@"tve.userstatus"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.registrationtype"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.usercat1"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.usercat2"];
    [dictTrackingData setObject:@"Click:Log-Out" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Log-Out" data:dictTrackingData];
    ////////
    
}
#pragma mark -
#pragma mark custom methods

-(void)logout
{
        [[JLManager sharedManager] hideLoadingView];
        [[JLManager sharedManager] setLogoutStatus];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.personalize"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.userid"];
    [dictTrackingData setObject:@"Not Logged In" forKey:@"tve.userstatus"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.registrationtype"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.usercat1"];
    [dictTrackingData setObject:@"unknown" forKey:@"tve.usercat2"];
    [dictTrackingData setObject:@"Event:Log-Out Success" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Settings" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Event:Log-Out Success" data:dictTrackingData];
    ////////
}
-(void)setFooterView{
    if([PerkoAuth IsUserLogin]){
        m_tblView.tableFooterView = m_tblFooterView;
    }
    
    m_btnLogout.layer.cornerRadius = 8;
//    m_btnLogout.titleLabel.font = kFontBtn14;
    //m_lblCopyright.font = kFontPrimary12;
    //m_lblCopyright.text = [NSString stringWithFormat:@"Copyright people are watching right now"];
    
    [m_tblView reloadData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

    
    m_lblCopyright.text = [NSString stringWithFormat:@"Copyright WatchBack %@\nVersion %@",yearString,version];
    
}
-(void)initTheme{
    
    
    m_switchTheme = [[UISwitch alloc] initWithFrame:CGRectZero];
    [m_switchTheme addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventValueChanged];
    ThemeType themeType = [[JLManager sharedManager] getAppTheme];
    switch (themeType) {
        case DayMode:
            [m_switchTheme setOn:FALSE];
            break;
            
        default:
            [m_switchTheme setOn:TRUE];
            break;
    }
}

#pragma mark --for Theme
- (IBAction)themeChanged:(id)sender {
    
    ThemeType themeType =0;
    if (!m_switchTheme.isOn) {
        themeType = 1;
    }
    
    [[JLManager sharedManager] setAppTheme:themeType];
    [m_tblView reloadData];
    [self setCustomColor];
    self.view.backgroundColor = kPrimaryBGColor;
    m_tblView.backgroundColor = kPrimaryBGColor;
    
    [self.navigationController.navigationBar setTintColor:kPrimaryTextColor];
    [self.navigationController.navigationBar setBarTintColor:kPrimaryBGColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColor}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeChangedNotification object:nil];
}

#pragma mark --
- (void)presentActivityController:(UIActivityViewController *)controller {
    
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            // user shared an item
            if(kDebugLog)NSLog(@"We used activity type%@", activityType);
        } else {
            // user cancelled
            if(kDebugLog)NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            if(kDebugLog)NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}
-(void)setCustomColor{
    [m_btnLogout setBackgroundColor:[UIColor colorWithWhite:255/255.0 alpha:0.5]];
    [m_btnLogout setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];
}
-(void)openDeveloperOptionsMenu
{    
    DeveloperOptions *objDeveloperOptions = [[DeveloperOptions alloc] initWithNibName:@"DeveloperOptions" bundle:nil];
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objDeveloperOptions];
    nav.navigationBarHidden = FALSE;
    [self presentViewController:nav animated:YES completion:nil];
    
}
@end
