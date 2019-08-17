//
//  RefreshTokenCheck.m
//  LIVETV
//
//  Created by Goutham Devaraju on 07/11/16.
//  Copyright © 2016 Perk.com. All rights reserved.
//

//RefreshTokenCheck Class
//Version: 1.1.1
//Refer to the documentation for changes and upgrades.

#import "RefreshTokenCheck.h"
#import "NSString+HMACString.h"
#import "NSMutableURLRequest+Additions.h"
#import "JLPerkUser.h"
#import "JLManager.h"
#import "PerkoAuth.h"
#import "Constants.h"
@implementation RefreshTokenCheck

RefreshTokenCheck *sharedRefreshTokenCheck;

+ (RefreshTokenCheck *)sharedRefreshTokenCheck
{
    static dispatch_once_t pred;
    static RefreshTokenCheck *shared = nil;
    
    //Creating signle object
    dispatch_once(&pred, ^{
        shared = [[RefreshTokenCheck alloc] init];
        shared -> _referral_queue = dispatch_queue_create("refeshToken_check", DISPATCH_QUEUE_CONCURRENT);
    });
    return shared;
}

#pragma mark - Refresh Token Related
- (void)checkForValidRefreshTokenAndProceedWithBlock:(void (^)(NSDictionary *dictJSONResp))blockIs{
    
    if (![PerkoAuth IsUserLogin]) {
        NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
        [dictMessage setValue:@"yes" forKey:@"isRefreshTokenValid"];
        [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
        [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
        [dictMessage setObject:@"" forKey:@"newTokenDetails"];
        
        NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
        [dictItem setObject:dictMessage forKey:@"data"];
        
        blockIs(dictItem);
        return ;
    }
    dispatch_barrier_async(self.referral_queue, ^{
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        JLPerkUser *perkUser = [PerkoAuth getPerkUser];
        
        NSString *lgTime = perkUser.clientLoginTime;
        NSNumber * expires_in = perkUser.expires_in;
        
        NSDate *presentDate = [NSDate date];
        NSDate *loginDate = [NSDate dateWithTimeIntervalSince1970:[lgTime doubleValue]];
        NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:[presentDate timeIntervalSince1970]];
        NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calender components:NSCalendarUnitSecond fromDate:loginDate toDate:currentTime options:0];
        NSInteger seconds = [components second];
        
        currentTime = nil;
        components = nil;
        presentDate = nil;
        loginDate = nil;
        calender = nil;
        
        //Checking if time passed so far is greater than the expire_in time
        if (seconds >= [expires_in intValue] || expires_in == nil || [expires_in isEqual:[NSNull null]])
        {
            //Token expired getting new accesstoken
            [self callAPIRefreshTokenWithBlock:^(NSDictionary *dictJSONResp){
                
                NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
                [dictMessage setValue:@"yes" forKey:@"isRefreshTokenValid"];
                [dictMessage setValue:@"yes" forKey:@"didFetchNewToken"];
                [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
                [dictMessage setObject:dictJSONResp forKey:@"newTokenDetails"];
                
                NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
                [dictItem setObject:dictMessage forKey:@"data"];
                
                dispatch_semaphore_signal(semaphore);
                blockIs(dictItem);
            }];
        }
        else
        {
            //Token valid. Proceed normal.
            NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
            [dictMessage setValue:@"yes" forKey:@"isRefreshTokenValid"];
            [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
            [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
            [dictMessage setObject:@"" forKey:@"newTokenDetails"];
            
            NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
            [dictItem setObject:dictMessage forKey:@"data"];
            
            dispatch_semaphore_signal(semaphore);
            blockIs(dictItem);
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    
}

#pragma mark - Refresh Token Related
- (void)foreceFetchRefreshTokenAndProceedWithBlock:(void (^)(NSDictionary *dictJSONResp))blockForceUpdateIs{
    
    dispatch_barrier_async(self.referral_queue, ^{
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        //Force fetching new accesstoken
        [self callAPIRefreshTokenWithBlock:^(NSDictionary *dictJSONResp){
            
            NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
            
            //If accesstoken is beign fetched already returns 'isRefreshTokenValid:no'.
            if([dictJSONResp objectForKey:@"isRefreshTokenIsBeingFetchedTrue"]){
                
                [dictMessage setValue:@"no" forKey:@"isRefreshTokenValid"];
                [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
                [dictMessage setObject:@"true" forKey:@"isRefreshTokenIsBeingFetched"];
                [dictMessage setObject:dictJSONResp forKey:@"newTokenDetails"];
            }
            else{
                
                if([[[dictJSONResp valueForKey:@"data"] valueForKey:@"isRefreshTokenValid"] isEqualToString:@"no"]){
                    
                    [dictMessage setValue:@"no" forKey:@"isRefreshTokenValid"];
                    [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
                    [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
                    [dictMessage setObject:@"" forKey:@"newTokenDetails"];
                }
                else{
                    [dictMessage setValue:@"yes" forKey:@"isRefreshTokenValid"];
                    [dictMessage setValue:@"yes" forKey:@"didFetchNewToken"];
                    [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
                    [dictMessage setObject:dictJSONResp forKey:@"newTokenDetails"];
                }
            }
            
            NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
            [dictItem setObject:dictMessage forKey:@"data"];
            
            dispatch_semaphore_signal(semaphore);
            blockForceUpdateIs(dictItem);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}


- (void)callAPIRefreshTokenWithBlock:(void (^)(NSDictionary *dictJSONResponse))block{
    
    //Checking for a working internetConnection
    if([[JLManager sharedManager] isInternetConnected]){
        
        //Making sure the AccessToken and RefershToken are available
        if([PerkoAuth getPerkUser].refreshToken != nil && [PerkoAuth getPerkUser].refreshToken.length > 5 && [PerkoAuth getPerkUser].accessToken != nil && [PerkoAuth getPerkUser].accessToken.length > 5){
            
            //Checking if accessToken is being not fetched already
            if(!isRefreshTokenIsBeignFetched){
                
                isRefreshTokenIsBeignFetched = YES;
                
                NSString *strUrl = [NSString stringWithFormat:@"%@",LOGIN_OAUTH_URL];
                
                //strURL_ = [strURL_ stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                

                NSDictionary *dictBody = @{
                                           @"client_id":kDeviceType,
                                           @"client_secret":kPerkSecret,
                                           @"product_identifier":kDeviceType
                                           };
                
                NSDictionary *params = @{
                                         @"refresh_token": [PerkoAuth getPerkUser].refreshToken,
                                         @"device_id":watchbackGetDeviceID(),
                                         @"grant_type": @"refresh_token"
                                         };
                
                NSMutableDictionary *reqParams = [dictBody mutableCopy];
                [reqParams addEntriesFromDictionary:params];
                
                
                if(kDebugLog)NSLog(@"%@",reqParams);
                NSError * createJSONError = nil;
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:reqParams
                                                                   options:NSJSONWritingPrettyPrinted error:&createJSONError];
                
                NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURL:strUrl param:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] httpMethod:@"POST"];
                
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setHTTPBody:jsonData];
                
                __block BOOL isAccessTokenFetched_Successfully = NO;
                NSURLSession *session = [NSURLSession sharedSession];
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                        completionHandler:
                                              ^(NSData *data, NSURLResponse *response, NSError *error){
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                                      
                                                      int responseStatusCode = (int)[httpResponse statusCode];
                                                      
                                                      if (responseStatusCode == 200 || responseStatusCode == 201) {
                                                          
                                                          if (data) {
                                                              
                                                              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                              
                                                              if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                                  
                                                                  JLPerkUser * perkUser = [PerkoAuth getPerkUser];
                                                                  
                                                                  NSDictionary *dictToken = [[dict valueForKey:@"data"] valueForKey:@"token"];
                                                                  
                                                                  if ([dictToken valueForKey:@"refresh_token"] != nil  &&
                                                                      [dictToken valueForKey:@"refresh_token"] != [NSNull null]) {
                                                                      
                                                                      perkUser.refreshToken = [dictToken valueForKey:@"refresh_token"];
                                                                  }
                                                                  if ( [dictToken valueForKey:@"access_token"] != nil  &&
                                                                      [dictToken valueForKey:@"access_token"] != [NSNull null]) {
                                                                      
                                                                      perkUser.accessToken = [dictToken valueForKey:@"access_token"];
                                                                  }
                                                                  if ( [dictToken valueForKey:@"expires_in"] != nil  &&
                                                                      [dictToken valueForKey:@"expires_in"] != [NSNull null]) {
                                                                      
                                                                      perkUser.expires_in = [dictToken valueForKey:@"expires_in"];
                                                                      
                                                                      //Updating current user loginDate
                                                                      NSDate *loginSystemDate = [NSDate date];
                                                                      NSString *loginDate = [[NSString alloc] initWithFormat:@"%lf",[loginSystemDate timeIntervalSince1970]];
                                                                      perkUser.clientLoginTime = loginDate;
                                                                  }
                                                                  
                                                                  //Updating UserDefaults with new values received
                                                                  [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:perkUser] forKey:perkUserKey];
                                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                                  
                                                                  //Making YES as we have got the dictionary that is required.
                                                                  isAccessTokenFetched_Successfully = YES;
                                                                  
                                                                  //Logout user if the user
                                                                  if ([dict valueForKey:@"status"] != nil  &&
                                                                      [dict valueForKey:@"status"] != [NSNull null]) {
                                                                      id value = [dict valueForKey:@"status"];
                                                                      if (value != nil && ![value isEqual:[NSNull null]]) {
                                                                          if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"error"])
                                                                              isAccessTokenFetched_Successfully = NO;
                                                                      }
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      else if(responseStatusCode == 500) {
                                                          
                                                          //Making NO as we have not got the dictionary that is required.
                                                          isAccessTokenFetched_Successfully = NO;
                                                      }
                                                      else if (responseStatusCode == 501){
                                                          
                                                          //Making NO as we have not got the dictionary that is required.
                                                          isAccessTokenFetched_Successfully = NO;
                                                      }
                                                      else if (responseStatusCode == 401 || responseStatusCode == 400){
                                                          
                                                          //Making NO as we have not got the dictionary that is required.
                                                          isAccessTokenFetched_Successfully = NO;
                                                      }
                                                      else if(responseStatusCode == 403){
                                                          
                                                          if (data && data.length > 0) {
                                                              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                              
                                                              if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                                  NSDictionary *dataDict = [dict objectForKey:@"data"];
                                                                  if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                                                                      
                                                                          //[[JLManager sharedManager] logoutUserWithSuspendedAccountWithMessage:[NSString stringWithFormat:@"%@",[dict valueForKey:@"message"]]];
                                                                          [[JLManager sharedManager] logoutUserWithAlert:LogoutModeDefault];
                                                                     
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      else if(responseStatusCode == 429){
                                                          
                                                          //Making NO as we have not got the dictionary that is required.
                                                          isAccessTokenFetched_Successfully = NO;
                                                          
                                                          if (data && data.length > 0) {
                                                              //Force update check
                                                              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                              if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                                  
                                                                  NSString *strStoreURL = [[[[dict valueForKey:@"data"] valueForKey:@"error"] valueForKey:@"app"] valueForKey:@"store_url"];
                                                                  
                                                                  if(strStoreURL!=nil && strStoreURL.length>2 && ![strStoreURL isEqualToString:@"<null>"] && ![strStoreURL isEqualToString:@"(null)"]){
                                                                      
                                                                      [[JLManager sharedManager] showPerkUpdateRibbon:true url:strStoreURL];
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      else{
                                                          //Making NO as we have not got the dictionary that is required.
                                                          isAccessTokenFetched_Successfully = NO;
                                                      }
                                                      
                                                      //If isAccessTokenFetched_Successfully is YES then return recevied dictionary else logout the user, because at this point the accesstoken is expired
                                                      if(isAccessTokenFetched_Successfully){
                                                          
                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                              self->isRefreshTokenIsBeignFetched = NO;
                                                          });
                                                          
                                                          NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                          block(dictResponse);
                                                      }
                                                      else{
                                                          
                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                              self->isRefreshTokenIsBeignFetched = NO;
                                                          });
                                                          
                                                          //Accesstoken is expired currently and failed to fetch a new refreshtoken/accesstoken. So logout the user.
                                                          //Modify the logout code based on your current implementation
                                                          [self logOutUser];
                                                          
                                                          
                                                          //Passing back a invalid response so that user can handle recursive calls.
                                                          //Stop making recursive call if 'isRefreshTokenValid:no' when a force fetch accessToken call is made.
                                                          NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
                                                          [dictMessage setValue:@"no" forKey:@"isRefreshTokenValid"];
                                                          [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
                                                          [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
                                                          [dictMessage setObject:@"" forKey:@"newTokenDetails"];
                                                          
                                                          NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
                                                          [dictItem setObject:dictMessage forKey:@"data"];
                                                          
                                                          block(dictItem);
                                                      }
                                                  });
                                              }];
                [task resume];
                
            }
            else
            {
                if(kDebugLog)NSLog(@"Refreshtoken is beign fetched already. Please retry the same call recursively.");
                
                NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
                [dictMessage setObject:@"true" forKey:@"isRefreshTokenIsBeingFetchedTrue"];
                block(dictMessage);
            }
            
        }
        else{
            if(kDebugLog)NSLog(@"No refresh access token present");
            
            //Refresh token is currently invalid and there is no refresh token present. So logout the user.
            //            [self logOutUser];
            
            NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
            [dictMessage setValue:@"no" forKey:@"isRefreshTokenValid"];
            [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
            [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
            [dictMessage setObject:@"" forKey:@"newTokenDetails"];
            
            NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
            [dictItem setObject:dictMessage forKey:@"data"];
            
            block(dictItem);
        }
        
    }
    else{
        if(kDebugLog)NSLog(@"No working internet connection found");
        
        //Refresh token is currently invalid and there is no internet connection. So logout the user.
        [self logOutUser];
        
        NSMutableDictionary *dictMessage = [[NSMutableDictionary alloc] init];
        [dictMessage setValue:@"no" forKey:@"isRefreshTokenValid"];
        [dictMessage setValue:@"no" forKey:@"didFetchNewToken"];
        [dictMessage setObject:@"false" forKey:@"isRefreshTokenIsBeingFetched"];
        [dictMessage setObject:@"" forKey:@"newTokenDetails"];
        
        NSMutableDictionary *dictItem = [[NSMutableDictionary alloc] init];
        [dictItem setObject:dictMessage forKey:@"data"];
        
        block(dictItem);
    }
    
}

-(void)logOutUser{
    
    //Modify the logout code based on your current implementation
    [[JLManager sharedManager] logoutUserWithAlert:LogoutModeDefault];
    
}

@end
