//
//  MovieTicketsVC.m
//  Watchback
//
//  Created by perk on 16/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "MovieTicketsVC.h"
#import "AppLabel.h"
#import "Constants.h"
#import "JLManager.h"
#import "PerkoAuth.h"
#import "WebServices.h"
#import "MovieListVC.h"
#import "SettingsVC.h"
#import "NavPortrait.h"
#import "LoginVC.h"
#import "SignUpWithEmailVC.h"

/*********logic******
 +     when user taps on movie tickets tab,
 +     1) check if user is login or not.
 +        1.a) if user is not logged in, show logout UI. - done
 +        1.b) if user is logged in,
 +            b.x) check total_rewards_remaining = true / false.
 +                x.p) if total_rewards_remaining = false
 +                    p.-) show 'no more movie tickets screen' - done.
 +                x.q) if total_rewards_remaining = true
 +                    q.-) check video_ramaining value
 +                        -.+) if video_remaining = 0
 +                            +.) show congrates screen.
 +                        -.+) if video_remaining > 0
 +                            +.) show 'watch xx episodes to get movie tickets' screen.
 +     *********************/

@interface MovieTicketsVC (){
    AppLabel * lblTitle;
    __weak IBOutlet UILabel *lbltitle2_viewlogout;
    __weak IBOutlet UILabel *lblTitle_logout;
    __weak IBOutlet UIButton *btnLogin_viewlogout;
    __weak IBOutlet UIButton *btnSignup_logoutview;
    __weak IBOutlet UIView *viewLogout;
    __weak IBOutlet UILabel *lblSubtitle_logoutview;
    NSArray * arymovies;
    int total_videos_remaining;
    

}

@end

@implementation MovieTicketsVC

#pragma mark-
#pragma mark view lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeNavigationBar];
    [self customizeScrenLayout];
    [self hideAllUIPrompts];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[JLTrackers sharedTracker] trackFBEvent:MovieTicketScreenEvent params:nil];
    
   // [self reskinLayout];

    
    if([[PerkoAuth getPerkUser] IsUserLogin]){
        [[JLManager sharedManager] showLoadingView:self.view];
        [[WebServices sharedManager] callAPI:GET_REWARS_URL params:[NSString stringWithFormat:@"access_token=%@",[PerkoAuth getPerkUser].accessToken] httpMethod:@"GET" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
            [[JLManager sharedManager] hideLoadingView];
            if(success){
                //NSLog(@"%@",dict);
                if(dict != nil && (id)dict != [NSNull null]){
                    if([dict valueForKey:@"data"] != nil && (id)[dict valueForKey:@"data"] != [NSNull null]){
                        
                        if([[dict valueForKey:@"data"] valueForKey:@"videos"] !=nil &&
                           [[dict valueForKey:@"data"] valueForKey:@"videos"] != [NSNull null]){
                            self->arymovies = [NSArray arrayWithArray:[[dict valueForKey:@"data"] valueForKey:@"videos"]];
                            
//                            //======for testing only..remove this from live build.=========
//                            NSString *filepath = [[NSBundle mainBundle] pathForResource:@"SampleMovies" ofType:nil];
//                            NSError *error;
//                            NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
//
//                            if (error)
//                                NSLog(@"Error reading file: %@", error.localizedDescription);
//
//                            // maybe for debugging...
//                            NSLog(@"contents: %@", fileContents);
//
//                            NSString *strJson = fileContents;
//                            id jsonObj = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding]
//                                                                         options:NSJSONReadingMutableContainers error:nil];
//                            self->arymovies = [jsonObj valueForKey:@"videos"];
//                            //======for testing only..remove this from live build.=========
                            
                        }
                        if(![[[dict valueForKey:@"data"] valueForKey:@"rewarded"] boolValue]){
                            if([[[dict valueForKey:@"data"] valueForKey:@"total_rewards_remaining"] boolValue]){
                                if([[dict valueForKey:@"data"] valueForKey:@"videos_remaining"] != nil &&
                                   (id)[[dict valueForKey:@"data"] valueForKey:@"videos_remaining"] != [NSNull null]){
                                    self->total_videos_remaining = [(id)[[dict valueForKey:@"data"] valueForKey:@"videos_remaining"] intValue];
                                    
                                    if(self->total_videos_remaining > 0){
                                        [self showGetMovieTicketsPrompt];
                                    }else{
                                        [self showCongratesPrompt];
                                    }
                                }
                            }else{
                                [self showNoMoreMovieTicktsPrompt];
                            }
                        }else{
                            self->total_videos_remaining = 0;
                            [self showCongratesPrompt];
                        }
                    }
                }
            }else{
                
            }
        }];
    }else{
        [self showLogoutUIPrompt];
    }
}

#pragma mark-
#pragma mark custom or ibaction methods
//-(void)reskinLayout{
//    lblTitle.textColor = kPrimaryTextColor;
//    viewLogout.backgroundColor = kSecondBGColor;
//
//    lblTitle_logout.textColor = kPrimaryTextColor;
//    lblSubtitle_logoutview.textColor = kPrimaryTextColor;
//    self.view.backgroundColor = kPrimaryBGColor;
//    [btnLogin_viewlogout setTitleColor:kPrimaryTextColor forState:UIControlStateNormal];
//
//    lbltitle2_viewlogout.textColor = kSecondaryTextColor;
//
//}
- (IBAction)btnSignup_logoutviewTabbed:(id)sender {
    SignUpWithEmailVC *objSignUpWithEmailVC = [[SignUpWithEmailVC alloc] initWithNibName:@"SignUpWithEmailVC" bundle:nil];
    objSignUpWithEmailVC.delegate = ^(BOOL finished){
        [self finished];
    };
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objSignUpWithEmailVC];
    nav.navigationBarHidden = FALSE;
    nav.navigationBar.tintColor = kPrimaryTextColorNight;
    nav.navigationBar.barTintColor = kPrimaryBGColorNight;
    
    
    [self presentViewController:nav animated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:objSignUpWithEmailVC action:@selector(btnClosedClicked)];
            
            objSignUpWithEmailVC.navigationItem.leftBarButtonItem = btnClose;
        });
    }];
    
}

- (IBAction)btnLogin_logoutviewTabbed:(id)sender {
    LoginVC *objLoginVC = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    objLoginVC.delegate = ^(BOOL finished){
        [self finished];
    };
    NavPortrait * nav = [[NavPortrait alloc] initWithRootViewController:objLoginVC];
    nav.navigationBarHidden = FALSE;
    nav.navigationBar.tintColor = kPrimaryTextColorNight;
    nav.navigationBar.barTintColor = kPrimaryBGColorNight;

    
    [self presentViewController:nav animated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIBarButtonItem *btnClose =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:objLoginVC action:@selector(btnClosedClicked)];
            
            objLoginVC.navigationItem.leftBarButtonItem = btnClose;
        });
    }];
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


-(void)GotoMoviesListwithOption:(kOptions) option {
    dispatch_async(dispatch_get_main_queue(), ^{

    UIStoryboard * movieliststoryboard = [UIStoryboard storyboardWithName:@"MovieList" bundle:nil];
    MovieListVC * objMovieListVC = [movieliststoryboard instantiateViewControllerWithIdentifier:@"movielist"];
        
    objMovieListVC.ary_movies = self->arymovies;
    objMovieListVC.option = option;
    objMovieListVC.total_videos_remaining = self->total_videos_remaining;
    objMovieListVC.view.frame = self.view.bounds;
    [self addChildViewController:objMovieListVC];
    [self.view addSubview:objMovieListVC.view];
    });

}

-(void)showNoMoreMovieTicktsPrompt{
    [self GotoMoviesListwithOption:kNoMoreMovieTicket];
}

-(void)showGetMovieTicketsPrompt{
    [self GotoMoviesListwithOption:kMovieTicket];
}

-(void)showCongratesPrompt{
    [self GotoMoviesListwithOption:kCongrates];
}

-(void)showLogoutUIPrompt{
    viewLogout.hidden = false;
    
}

-(void)hideAllUIPrompts{
    viewLogout.hidden = true;
}

-(void)customizeScrenLayout{
    viewLogout.layer.cornerRadius = 12;
    btnSignup_logoutview.layer.cornerRadius = 8.0;
}

-(void)customizeNavigationBar{
    lblTitle = [[AppLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 27)];
    lblTitle.textColor = kPrimaryTextColor;
    lblTitle.font = kFontPrimary18;
    NSString *strTitle = @"Movie Tickets";
    lblTitle.text = strTitle;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 27)];
    leftView.backgroundColor = [UIColor clearColor];
    [leftView addSubview:lblTitle];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftItem;

    
//    UIBarButtonItem *rightItem =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(btnSettingClicked)];
//    self.navigationItem.rightBarButtonItem = rightItem;

    
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

@end
