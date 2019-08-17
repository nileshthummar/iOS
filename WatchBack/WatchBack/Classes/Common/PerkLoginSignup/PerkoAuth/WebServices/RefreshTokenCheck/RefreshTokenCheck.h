//
//  RefreshTokenCheck.h
//  LIVETV
//
//  Created by Goutham Devaraju on 07/11/16.
//  Copyright © 2016 Perk.com. All rights reserved.
//

//RefreshTokenCheck Class
//Version: 1.1.1
//Refer to the documentation for changes and upgrades.

#import <Foundation/Foundation.h>

@interface RefreshTokenCheck : NSObject
{
    //For handling multiple force fetch accessToken calls being made.
    BOOL isRefreshTokenIsBeignFetched;
}

@property(nonatomic, strong) dispatch_queue_t referral_queue;

//Shared signleTon object
+ (RefreshTokenCheck *)sharedRefreshTokenCheck;

//Checks for accessToken validity based on expire_in time received.
- (void)checkForValidRefreshTokenAndProceedWithBlock:(void (^)(NSDictionary *dictJSONResp))block;

//Fetches new accessToken using refreshToken when current login time is greater then the expire_in time recevied.
- (void)callAPIRefreshTokenWithBlock:(void (^)(NSDictionary *dictJSONResponse))block;

//Force fetches a new acessToken using refreshToken. Can be used when API returns 401/400 and make a recursive call to same API call which returned 401/400.
- (void)foreceFetchRefreshTokenAndProceedWithBlock:(void (^)(NSDictionary *dictJSONResp))blockIs;


@end
