//
//  WelcomeVC.m
//  Watchback
//
//  Created by Nilesh on 8/12/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "WelcomeVC.h"
#import "PerkoAuth.h"
#import "Constants.h"
#import "JLManager.h"

#import "LoginVC.h"
#import "SignUpWithEmailVC.h"

#import "NavPortrait.h"
#import <SDWebImage/SDWebImage.h>
#import "WebServices.h"
#import "TermsGateVC.h"
#import "RedeemWebVC.h"
#import "iCarousel.h"
#import "WelcomeCarouselCell.h"

@interface WelcomeVC ()<UIActionSheetDelegate>
{
    __weak IBOutlet UIImageView *imvBackground;
    __weak IBOutlet UIImageView *imvLogo;
    IBOutlet UIButton *m_btnSignup;
    IBOutlet UILabel *m_lblTitle;
    NSMutableArray *m_arrCarousel;
    __weak IBOutlet NSLayoutConstraint *logotopConstraint;

    
}


@end

@implementation WelcomeVC

#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self->logotopConstraint.constant = [UIScreen mainScreen].bounds.size.height / 7;
    self.view.backgroundColor = kPrimaryBGColorNight;
    
    ///
    [self.navigationController.navigationBar setTintColor:kPrimaryTextColorNight];
    [self.navigationController.navigationBar setBarTintColor:kPrimaryBGColorNight];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColorNight}];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kPrimaryTextColorNight,  NSFontAttributeName: kFontPrimary20}];
    
    ////
   
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self customizeScreenLayout];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    /* this code is added because sometimes, due to multiple devices detection, user can logout at any time..for eg. while just taping on movie play user can logout...after logging out user will come to this screen.
     although we have handler for movie stop at logout, but sometimes, movie starts after few seconds, so when logout is executing movie is just about to start, so stoping it may not work, as it hasn't started yet.
    */
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kStopVideoNotification object:nil];
    });
}
    
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)customizeScreenLayout{
    
    if (PerkoAuth.IsUserLogin) {       
        [self finished];
    }
    else
    {
      //  [self callAPIforGetBGImage];
        [self initTitle];
        [self callAPIforGetData];
       m_btnSignup.layer.cornerRadius = 8;
//        m_btnSignup.titleLabel.font = kFontBtn14;
        
        ////////////
        NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
        [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.userpath"];
        [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
        [[JLTrackers sharedTracker] trackAdobeStates:@"Sign-Up Fork" data:dictTrackingData];
        ////////
        
    }
    
    ///////
    
   
    
}

- (IBAction)btnLoginClicked {
    LoginVC *objLoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    objLoginVC.delegate = ^(BOOL finished){
                [self finished];
            };
    [self.navigationController pushViewController:objLoginVC animated:YES];
    
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Log-In" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Log-In" data:dictTrackingData];
    ////////
}

- (IBAction)btnSignupClicked{
    ////////////
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Sign-Up with Email" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Sign-Up with Email" data:dictTrackingData];
    ////////
    
    
    SignUpWithEmailVC *objSignUpWithEmailVC = [[SignUpWithEmailVC alloc] initWithNibName:@"SignUpWithEmailVC" bundle:nil];
    objSignUpWithEmailVC.delegate = ^(BOOL finished){
        [self finished];
    };
    [self.navigationController pushViewController:objSignUpWithEmailVC animated:YES];
    
}


-(void)loginSignupSuccessed
{
    [self finished];
    [[JLManager sharedManager] loginSignupSuccessed];
}

-(void)finished
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadHomePageNotification object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadHomePageNotification object:nil];
    }
}
- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    return NO;
}
-(IBAction)btnSkipClicked{
    ////////////
    [JLManager sharedManager].skip_registration = 1;
    NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
    [dictTrackingData setObject:@"true" forKey:@"tve.action"];
    [dictTrackingData setObject:@"Sign-Up Fork" forKey:@"tve.title"];
    [dictTrackingData setObject:@"Click:Skip" forKey:@"tve.userpath"];
    [dictTrackingData setObject:@"Sign-Up" forKey:@"tve.contenthub"];
    [[JLTrackers sharedTracker] trackAdobeActions:@"Click:Skip" data:dictTrackingData];
    ////////
    
    [[JLTrackers sharedTracker] trackSingularEvent:@"skip_registration"];
    [[JLTrackers sharedTracker] trackFBEvent:@"skip_registration" params:nil];
    [[JLTrackers sharedTracker] trackAppsFlyerEvent:@"skip_registration" withValues:nil];
    
     BOOL bTermsPrivacyAgreement = [[[JLManager sharedManager] getObjectuserDefault:kTermsPrivacyAgreement] boolValue];
    if (bTermsPrivacyAgreement) {
         [self finished];
    }
    else{         
        TermsGateVC *objTermsGateVC = [[TermsGateVC alloc] initWithNibName:@"TermsGateVC" bundle:nil];
        objTermsGateVC.delegate = ^(BOOL finished){
            [self finished];
        };
        [self.navigationController pushViewController:objTermsGateVC animated:YES];
    }
    
   
}

-(void)callAPIforGetData{

    NSString *strURL = [NSString stringWithFormat:@"%@/%@",API_CAROUSELS,@"Splash Screen"] ;
    NSString *params = @"";
    [[WebServices sharedManager] callAPI:strURL params:params httpMethod:@"GET" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
      
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                dict = [dict objectForKey:@"data"];
                if(kDebugLog)NSLog(@"%@",dict);
                if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                    
                    dict = [dict objectForKey:@"carousel"];
                    if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                        NSArray *arr = [dict objectForKey:@"items"];
                        if (arr == nil || ![arr isKindOfClass:[NSArray class]]) {
                            arr = [NSArray new];
                        }
                        self->m_arrCarousel = [NSMutableArray arrayWithArray:arr];
                        
                    }
                    
                }
            }
            [self updateWelcomeScreenData];
            
        }
        
    }];
}

-(void)updateWelcomeScreenData{
    
    if(self->m_arrCarousel != nil && self->m_arrCarousel.count > 0){
        // if more then one object then consider first object only..
        NSDictionary * dict_assets = self->m_arrCarousel.firstObject;
        if (dict_assets != nil && (id)dict_assets != [NSNull null]){
            
            if([dict_assets valueForKey:@"fields"] != nil && [dict_assets valueForKey:@"fields"] != [NSNull null]){
                if([[dict_assets valueForKey:@"fields"] isKindOfClass:[NSDictionary class]]){
                    if([[dict_assets valueForKey:@"fields"] valueForKey:@"txt1"] != nil &&
                       [[dict_assets valueForKey:@"fields"] valueForKey:@"txt1"] != [NSNull null]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self->m_lblTitle.text = [[dict_assets valueForKey:@"fields"] valueForKey:@"txt1"];
                        });
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if([dict_assets valueForKey:@"image"] != nil &&  [dict_assets valueForKey:@"image"] != [NSNull null]){
                    
                    NSURL * imageURL = [NSURL URLWithString:[dict_assets valueForKey:@"image"]];
                    if(imageURL && imageURL.scheme && imageURL.host){
                        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                                       downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                           NSData * data =  [NSData dataWithContentsOfURL:location];
                                                                           if (data != nil && !error){
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   self->imvLogo.image = [UIImage imageWithData:data];
                                                                               });
                                                                           }else{
                                                                               
                                                                           }
                                                                           
                                                                       }];
                        [downloadPhotoTask resume];
                    }
                    
                }
                
                if([dict_assets valueForKey:@"image2"] != nil &&  [dict_assets valueForKey:@"image2"] != [NSNull null]){
                    NSURL * imageURL = [NSURL URLWithString:[dict_assets valueForKey:@"image2"]];
                    if(imageURL && imageURL.scheme && imageURL.host){
                        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                                       downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                           NSData * data =  [NSData dataWithContentsOfURL:location];
                                                                           if (data != nil && !error){
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   self->imvBackground.image = [UIImage imageWithData:data];
                                                                               });
                                                                           }else{
                                                                               
                                                                           }
                                                                           
                                                                       }];
                        [downloadPhotoTask resume];
                    }
                }
            });
            
        }
    }
}

-(void)GoToWelcomeScreen{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadWelcomePageNotification object:nil];
    });
}


-(void)initTitle
{
//    m_lblTitle.font = kFontPrimary18;
    m_lblTitle.numberOfLines = 0;
    m_lblTitle.textColor = kPrimaryTextColorNight;
    m_lblTitle.textAlignment = NSTextAlignmentCenter;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
