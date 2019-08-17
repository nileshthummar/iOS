//
//  BrandPortalCell.m
//  Watchback
//
//  Created by perk on 20/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "BrandPortalCell.h"
#import "JLTrackers.h"
#import "PerkoAuth.h"
#import "UIView+Toast.h"
#import "WebServices.h"
#import "JLManager.h"
#import "Constants.h"

@implementation BrandPortalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _btnAddFavorite.layer.cornerRadius = _btnRequestMoreInfo.layer.cornerRadius = 8.0;
    self.backgroundView = nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    _imvBrandLogo.layer.cornerRadius = (_imvBrandLogo.bounds.size.width)/2.0;
    _imvBrandLogo.layer.masksToBounds = true;
    
}

-(void)checkFavorites{
    if(_is_favorite){
        [self.btnAddFavorite setTitle:@"Remove from My Favorites" forState:UIControlStateNormal];
        [self.btnAddFavorite setBackgroundColor:kRedColorDisabled2];
    }else{
        [self.btnAddFavorite setTitle:@"Add to My Favorites" forState:UIControlStateNormal];
        [self.btnAddFavorite setBackgroundColor:kRedColor];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnRequestMoreInfoTapped:(id)sender {
    
    if([_brand_info valueForKey:@"uuid"] !=nil && [_brand_info valueForKey:@"uuid"] != [NSNull null] &&
       [_brand_info valueForKey:@"name"] !=nil && [_brand_info valueForKey:@"name"] != [NSNull null]){
        NSMutableDictionary * dictTrackingParameters = [[NSMutableDictionary alloc] init];
        [dictTrackingParameters setValue:[NSString stringWithFormat:@"%@-%@",[_brand_info valueForKey:@"uuid"],[_brand_info valueForKey:@"name"]] forKey:@"provider"];
    
        [[JLTrackers sharedTracker] trackFBEvent:ProviderDetailsRequestMoreInfoEvent params:dictTrackingParameters];
    }else{
        [[JLTrackers sharedTracker] trackFBEvent:ProviderDetailsRequestMoreInfoEvent params:nil];
    }
    
    if([PerkoAuth getPerkUser].IsUserLogin){
        _btnRequestMoreInfo.userInteractionEnabled = false;
        [_btnRequestMoreInfo setTitle:@"Email Sent" forState:UIControlStateNormal];
        [_btnRequestMoreInfo setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:78/255.0 alpha:1]];
        
        if(_brand_info != nil && (id)_brand_info != [NSNull null]){
            if([_brand_info valueForKey:@"uuid"] !=nil &&
               [_brand_info valueForKey:@"uuid"] != [NSNull null]){
                [[JLTrackers sharedTracker] trackLeanplumEvent:@"request_channel_info" param:@{@"Channel":[_brand_info valueForKey:@"uuid"]}];
            }
        }
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRequestMoreInfoLogoutNotification object:nil];
    }
}

-(void)AddFavoriteAPI:(void (^) (BOOL success))handler{
    
    if(![PerkoAuth getPerkUser].IsUserLogin){
        return;
    }
    
    NSString *strURL = ADD_FAVORITES_URL;
    strURL = [strURL stringByReplacingOccurrencesOfString:@"<uuid_value>" withString:[_brand_info valueForKey:@"uuid"]];
    NSDictionary * dictParameters = [NSDictionary dictionaryWithObjectsAndKeys:[PerkoAuth getPerkUser].accessToken,@"access_token", nil];
    [[JLManager sharedManager] showLoadingView:self];
    
    [[WebServices sharedManager] callAPIJSON:strURL params:dictParameters httpMethod:@"POST" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
        [[JLManager sharedManager] hideLoadingView];
        
        if (success) {
            if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
                if([dict valueForKey:@"message"] != nil &&
                   [dict valueForKey:@"message"] != [NSNull null]
                   ){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:2.0 position:CSToastPositionCenter title:[dict valueForKey:@"message"] image:nil style:nil completion:nil];
                    });
                }
            }
            handler(true);
        }else{
            handler(false);
        }
        
    }];
}


- (IBAction)btnAddFavoriteTapped:(id)sender {
    [JLManager sharedManager].needToRefreshChannels = true;
    if([PerkoAuth IsUserLogin]){
        [self AddFavoriteAPI:^(BOOL success) {
            if(success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.is_favorite = !self.is_favorite;
                    [self checkFavorites];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGenresDataNotification object:nil];
                });
            }
        }];
    }else{
        // add favoties locally...
        if(!self.is_favorite){
            [[JLManager sharedManager] AddToFavoriteshowsLocally:_brand_info];
        }else{
            if([_brand_info valueForKey:@"uuid"] != nil && [_brand_info valueForKey:@"uuid"] != [NSNull null]){
                [[JLManager sharedManager] removeFavoriteshowWithUUIDLocally:[_brand_info valueForKey:@"uuid"]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.is_favorite = !self.is_favorite;
            [self checkFavorites];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadGenresDataNotification object:nil];
        });
        
    }
}

-(void)setBranddetails:(NSDictionary *)brand_details{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(brand_details !=nil && (id)brand_details != [NSNull null]){
            if([brand_details valueForKey:@"list_screen_logo_url"] != nil &&
               [brand_details valueForKey:@"list_screen_logo_url"] != [NSNull null]){
                NSURL * imageURL = [NSURL URLWithString:[brand_details valueForKey:@"list_screen_logo_url"]];
                if(imageURL){
//                    [self.imvBrandLogo setImageURL:imageURL];
                    [self.imvBrandLogo sd_setImageWithURL:imageURL placeholderImage:nil];
                }
            }
            if([brand_details valueForKey:@"description"] != nil &&
               [brand_details valueForKey:@"description"] != [NSNull null]){
                self.lblBranddetail.text = [brand_details valueForKey:@"description"];
                self.lblBranddetail.textColor = kPrimaryTextColor;
            }
        }
    });
}

@end
