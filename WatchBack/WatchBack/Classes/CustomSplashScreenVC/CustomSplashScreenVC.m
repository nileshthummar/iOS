//
//  CustomSplashScreenVC.m
//  Watchback
//
//  Created by perk on 13/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "CustomSplashScreenVC.h"
#import "Constants.h"
#import "WebServices.h"
#import <SDWebImage/SDWebImage.h>
#import "PerkoAuth.h"
#import "JLManager.h"


@interface CustomSplashScreenVC (){
    NSArray * ary_carousel_data;
    dispatch_group_t dispatchGroup;
    __weak IBOutlet UIActivityIndicatorView *loadingIndicator;
}

@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imvBackground;

@end


@implementation CustomSplashScreenVC

#pragma mark-
#pragma mark view life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customizeScreenUI];
    [self getsplashScreenAssets];
}

#pragma mark-
#pragma mark ibaction or custom methods
-(void)customizeScreenUI{
    [loadingIndicator startAnimating];
    
    
}
-(void)getsplashScreenAssets{
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
                        self->ary_carousel_data  = [NSArray arrayWithArray:arr];
                    }
                    
                }
            }
        }
        [self setsplashScreenAssetsfromCarouselData];

    }];
}
-(void)setImageforImageView:(UIImageView *)imageview withImageURL:(NSString *)url{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
        if (data == nil){
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            imageview.image = [UIImage imageWithData:data];
        });
    });
}

- (void)groupNotifier {
    dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSLog(@"Does this only print once?");
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->loadingIndicator stopAnimating];
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self GoToFirstScreen];
            });
        });
    });
}

-(void)setsplashScreenAssetsfromCarouselData{
    if(ary_carousel_data != nil && ary_carousel_data.count > 0){
        // if more then one object then consider first object only..
        NSDictionary * dict_assets = ary_carousel_data.firstObject;
        if (dict_assets != nil && (id)dict_assets != [NSNull null]){

            
            self->dispatchGroup = dispatch_group_create();
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_group_enter(self->dispatchGroup);
                dispatch_async(dispatch_get_main_queue(), ^{

                    if([dict_assets valueForKey:@"image"] != nil &&  [dict_assets valueForKey:@"image"] != [NSNull null]){
                        NSURL * imageURL = [NSURL URLWithString:[dict_assets valueForKey:@"image"]];
                        if(imageURL && imageURL.scheme && imageURL.host){
                        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                                       downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                           NSData * data =  [NSData dataWithContentsOfURL:location];
                                                                           if (data != nil && !error){
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   self.imvLogo.image = [UIImage imageWithData:data];
                                                                                   //NSLog(@"logo has been set");
                                                                                   dispatch_group_leave(self->dispatchGroup);
                                                                                   [self groupNotifier];
                                                                               });
                                                                           }else{
                                                                               dispatch_group_leave(self->dispatchGroup);
                                                                               [self groupNotifier];
                                                                           }

                                                                       }];
                        [downloadPhotoTask resume];
                        }else{
                            dispatch_group_leave(self->dispatchGroup);
                            [self groupNotifier];
                        }
                    }else{
                        dispatch_group_leave(self->dispatchGroup);
                        [self groupNotifier];
                    }
                });
            });
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_group_enter(self->dispatchGroup);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if([dict_assets valueForKey:@"image2"] != nil &&  [dict_assets valueForKey:@"image2"] != [NSNull null]){
                        NSURL * imageURL = [NSURL URLWithString:[dict_assets valueForKey:@"image2"]];
                        if(imageURL && imageURL.scheme && imageURL.host){
                        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                                       downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                           NSData * data =  [NSData dataWithContentsOfURL:location];
                                                                           if (data != nil && !error){
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   self.imvBackground.image = [UIImage imageWithData:data];
                                                                                   //NSLog(@"logo has been set");
                                                                                   dispatch_group_leave(self->dispatchGroup);
                                                                                   [self groupNotifier];
                                                                               });
                                                                           }else{
                                                                               dispatch_group_leave(self->dispatchGroup);
                                                                               [self groupNotifier];
                                                                           }
                                                                           
                                                                       }];
                        [downloadPhotoTask resume];
                        }else{
                            dispatch_group_leave(self->dispatchGroup);
                            [self groupNotifier];
                        }
                    }else{
                        dispatch_group_leave(self->dispatchGroup);
                        [self groupNotifier];
                    }
                });
            });
            
        }else{
            [self->loadingIndicator stopAnimating];
            [self GoToFirstScreen];
        }
    }else{
        [self->loadingIndicator stopAnimating];
        [self GoToFirstScreen];
    }
}



-(void)GoToFirstScreen{
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadWelcomePageNotification object:nil];
//    });
    
    if (PerkoAuth.IsUserLogin) {
        [[JLManager sharedManager] getUserInfo:^(BOOL successUserInfo) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
        }];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetUserLoginSignupNotification object:nil];
    }

    
}


@end
