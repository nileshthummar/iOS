//
//  WebServices.m
//  appredeem
//
//  Created by Nilesh on 4/22/16.
//
//

#import "WebServices.h"
#import "UIView+Toast.h"
#import "NSMutableURLRequest+Additions.h"
#import "RefreshTokenCheck.h"
#import "JLManager.h"
#import "PerkoAuth.h"
@implementation WebServices
static WebServices *sWebServices;
+(WebServices *)sharedManager
{
    if (sWebServices == nil) {
        sWebServices  = [[WebServices alloc] init];
    }
    return sWebServices;
}
-(void)callAPI:(NSString *)strUrl params:(NSString *)params httpMethod:(NSString *)httpMethod check_for_refreshToken:(BOOL)check_for_refreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    if(check_for_refreshToken){
    [[RefreshTokenCheck sharedRefreshTokenCheck] checkForValidRefreshTokenAndProceedWithBlock:^(NSDictionary *dictResponse){
        NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURL:strUrl param:params httpMethod:httpMethod];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                              int responseStatusCode = (int)[httpResponse statusCode];
                                              NSDictionary *dict;
                                              if (data) {
                                                  dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                              }
                                              else{
                                                  dict = [NSDictionary new];
                                              }
                                              
                                              if (responseStatusCode <= 300 && data) {
                                                  if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                      handler(true,dict);
                                                      return;
                                                  }
                                                  
                                              }
                                              else{
                                                  [[JLManager sharedManager] checkForForceUpdate:data responseStatusCode:responseStatusCode];
                                              }
                                              
                                              if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
                                                  if (!self.m_bRetry) {
                                                      self.m_bRetry = true;
                                                      if(check_for_refreshToken){
                                                      [[RefreshTokenCheck sharedRefreshTokenCheck] foreceFetchRefreshTokenAndProceedWithBlock:^(NSDictionary* dictResponse){
                                                          [self callAPI:strUrl params:params httpMethod:httpMethod check_for_refreshToken : check_for_refreshToken handler:handler];
                                                          if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenIsBeingFetched"] isEqualToString:@"true"]){
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                     // [self callAPI:strUrl params:params httpMethod:httpMethod handler:handler];
                                                                  }];
                                                              });
                                                          }
                                                          else{
                                                              if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenValid"] isEqualToString:@"yes"]){
                                                                  //[self updateUserInfo:updateInfo];
                                                                  [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                      //[self callAPI:strUrl params:params httpMethod:httpMethod handler:handler];
                                                                  }];
                                                              }
                                                          }
                                                      }];
                                                      }
                                                  }
                                                  else{
                                                      self.m_bRetry = false;
                                                      [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                      handler(false,dict);
                                                      
                                                  }
                                              }
                                              else{
                                                  [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                  handler(false,dict);
                                              }
                                              
                                          });
                                          
                                          
                                      }];
        [task resume];
    }];
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURL:strUrl param:params httpMethod:httpMethod];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                              int responseStatusCode = (int)[httpResponse statusCode];
                                              NSDictionary *dict;
                                              if (data) {
                                                  dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                              }
                                              else{
                                                  dict = [NSDictionary new];
                                              }
                                              
                                              if (responseStatusCode <= 300 && data) {
                                                  if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                      handler(true,dict);
                                                      return;
                                                  }
                                                  
                                              }
                                              else{
                                                  [[JLManager sharedManager] checkForForceUpdate:data responseStatusCode:responseStatusCode];
                                              }
                                              
                                              if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
                                                  if (!self.m_bRetry && responseStatusCode != 401) {
                                                      self.m_bRetry = true;
                                                      [self callAPI:strUrl params:params httpMethod:httpMethod check_for_refreshToken:check_for_refreshToken handler:handler];
                                                  }
                                                  else{
                                                      self.m_bRetry = false;
                                                      [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                      handler(false,dict);
                                                      
                                                  }
                                              }
                                              else{
                                                  [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                  handler(false,dict);
                                              }
                                              
                                          });
                                          
                                          
                                      }];
        [task resume];
    }
    
}
-(void)callAPIJSON:(NSString *)strUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod check_for_refreshToken:(BOOL)check_for_refreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    if(check_for_refreshToken){
   [[RefreshTokenCheck sharedRefreshTokenCheck] checkForValidRefreshTokenAndProceedWithBlock:^(NSDictionary *dictResponse){
        NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURLJSON:strUrl param:params httpMethod:httpMethod];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                              int responseStatusCode = (int)[httpResponse statusCode];
                                              NSDictionary *dict;
                                              if (data) {
                                                  dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                              }
                                              else{
                                                  dict = [NSDictionary new];
                                              }
                                              
                                              if (responseStatusCode <= 300 && data) {
                                                  if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                      handler(true,dict);
                                                      return;
                                                  }
                                                  
                                              }else{
                                                  [[JLManager sharedManager] checkForForceUpdate:data responseStatusCode:responseStatusCode];
                                              }
                                              if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
                                                  
                                                  
                                                  if (!self.m_bRetry) {
                                                      self.m_bRetry = true;
                                                      if(check_for_refreshToken){
                                                      [[RefreshTokenCheck sharedRefreshTokenCheck] foreceFetchRefreshTokenAndProceedWithBlock:^(NSDictionary* dictResponse){
                                                          [self callAPIJSON:strUrl params:params httpMethod:httpMethod  check_for_refreshToken : check_for_refreshToken handler:handler];
                                                          if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenIsBeingFetched"] isEqualToString:@"true"]){
                                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                  [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                      
                                                                  }];
                                                              });
                                                          }
                                                          else{
                                                              if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenValid"] isEqualToString:@"yes"]){
                                                                  //[self updateUserInfo:updateInfo];
                                                                  [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                      
                                                                  }];
                                                              }
                                                          }
                                                      }];
                                                      }
                                                  }
                                                  else{
                                                      self.m_bRetry = false;
                                                      [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                      handler(false,dict);
                                                      
                                                  }
                                              }
                                              else if (responseStatusCode == 412)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSDictionary *dictBody =
                                                      @{ @"access_token":[PerkoAuth getPerkUser].accessToken};
                                                      [[WebServices sharedManager] callAPIJSON:LOGOUT_URL params:dictBody httpMethod:@"POST" check_for_refreshToken : check_for_refreshToken handler:^(BOOL success, NSDictionary *dict) {
                                                          if (success) {
                                                          }
                                                      }];
                                                  });
                                                  
//                                                  NSDictionary *dict;
//                                                  if (data) {
//                                                      dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                                                  }
//                                                  else{
//                                                      dict = [NSDictionary new];
//                                                  }
//                                                  NSString *message = [dict valueForKey:@"message"];
//                                                  if(message != nil && [message isKindOfClass:[NSString class]])
//                                                  {
//                                                      // if ([message rangeOfString:@"Max number of devices detected"].location != NSNotFound)
//                                                      {
//                                                          UIAlertController * alert = [UIAlertController
//                                                                                       alertControllerWithTitle:@"Alert"
//                                                                                       message:message
//                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//
//                                                          UIAlertAction* btnOK = [UIAlertAction
//                                                                                  actionWithTitle:@"OK"
//                                                                                  style:UIAlertActionStyleDefault
//                                                                                  handler:^(UIAlertAction * action) {
//                                                                                       NSDictionary *dictBody =
//                                                                                       @{ @"access_token":[PerkoAuth getPerkUser].accessToken};
//                                                                                      [[WebServices sharedManager] callAPIJSON:LOGOUT_URL params:dictBody httpMethod:@"POST" check_for_refreshToken : check_for_refreshToken handler:^(BOOL success, NSDictionary *dict) {
//                                                                                           if (success) {
//                                                                                           }
//                                                                                       }];
//                                                                                      /*[[JLManager sharedManager] setLogoutStatus];
//                                                                                      [[JLManager sharedManager] closeAndClearFBTokenInformation];
//
//                                                                                      //Handle your yes please button action here
//                                                                                      [[[JLManager sharedManager] topViewController] dismissViewControllerAnimated:NO completion:nil];
//                                                                                      [[JLManager sharedManager] performSelector:@selector(loginAfterDelay) withObject:nil afterDelay:1];*/
//
//                                                                                  }];
//
//                                                          [alert addAction:btnOK];
//                                                          [[[JLManager sharedManager] topViewController] presentViewController:alert animated:YES completion:nil];
//
//
//                                                          return;
//                                                      }
//                                                  }
                                              }
                                              else{
                                                  [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                  handler(false,dict);
                                              }

                                          });
                                          
                                          
                                      }];
        [task resume];
    }];
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURLJSON:strUrl param:params httpMethod:httpMethod];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                              int responseStatusCode = (int)[httpResponse statusCode];
                                              NSDictionary *dict;
                                              if (data) {
                                                  dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                              }
                                              else{
                                                  dict = [NSDictionary new];
                                              }
                                              
                                              if (responseStatusCode <= 300 && data) {
                                                  if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                      handler(true,dict);
                                                      return;
                                                  }
                                                  
                                              }else{
                                                  [[JLManager sharedManager] checkForForceUpdate:data responseStatusCode:responseStatusCode];
                                              }
                                              if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
                                                  
                                                  
                                                  if (!self.m_bRetry && responseStatusCode != 401) {
                                                      self.m_bRetry = true;
                                                      
                                                          [self callAPIJSON:strUrl params:params httpMethod:httpMethod  check_for_refreshToken : check_for_refreshToken handler:handler];
                                                      
                                                  }
                                                  else{
                                                      self.m_bRetry = false;
                                                      [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                      handler(false,dict);
                                                      
                                                  }
                                              }
                                              else if (responseStatusCode == 412)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSDictionary *dictBody =
                                                      @{ @"access_token":[PerkoAuth getPerkUser].accessToken};
                                                      [[WebServices sharedManager] callAPIJSON:LOGOUT_URL params:dictBody httpMethod:@"POST" check_for_refreshToken : check_for_refreshToken handler:^(BOOL success, NSDictionary *dict) {
                                                          if (success) {
                                                          }
                                                      }];
                                                  });
                                                  
//                                                  NSDictionary *dict;
//                                                  if (data) {
//                                                      dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                                                  }
//                                                  else{
//                                                      dict = [NSDictionary new];
//                                                  }
//                                                  NSString *message = [dict valueForKey:@"message"];
//                                                  if(message != nil && [message isKindOfClass:[NSString class]])
//                                                  {
//                                                      // if ([message rangeOfString:@"Max number of devices detected"].location != NSNotFound)
//                                                      {
//                                                          UIAlertController * alert = [UIAlertController
//                                                                                       alertControllerWithTitle:@"Alert"
//                                                                                       message:message
//                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//
//                                                          UIAlertAction* btnOK = [UIAlertAction
//                                                                                  actionWithTitle:@"OK"
//                                                                                  style:UIAlertActionStyleDefault
//                                                                                  handler:nil];
//
//                                                          [alert addAction:btnOK];
//                                                          [[[JLManager sharedManager] topViewController] presentViewController:alert animated:YES completion:nil];
//
//
//                                                          return;
//                                                      }
//                                                  }
                                              }
                                              else{
                                                  [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:check_for_refreshToken];
                                                  handler(false,dict);
                                              }
                                              
                                          });
                                          
                                          
                                      }];
        [task resume];
    }
        
    
}
- (void) handleCommonErrorResponse:(NSData *)data response:(NSURLResponse *)response error:(NSError *)connectionError check_for_refreshToken:(BOOL)check_for_refreshToken{
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = (int)[httpResponse statusCode];
    if (responseStatusCode <= 300 || responseStatusCode == 404)
    {
        
    }
    ///////
    else if(responseStatusCode == 429){
        
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //if(kDebugLog)NSLog(@"%@",dict);
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                
                NSString *strStoreURL = [[[[dict valueForKey:@"data"] valueForKey:@"error"] valueForKey:@"app"] valueForKey:@"store_url"];
                
                if(strStoreURL!=nil && strStoreURL.length>2 && ![strStoreURL isEqualToString:@"<null>"] && ![strStoreURL isEqualToString:@"(null)"]){
                    
                    [[JLManager sharedManager] showPerkUpdateRibbon:true url:strStoreURL];
                }
            }
        }
    }
    else if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
        
        if(!check_for_refreshToken){
            if([PerkoAuth IsUserLogin] && responseStatusCode == 401)
            {
                    [[JLManager sharedManager] logoutUserWithAlert:LogoutModeDefault];
                
            }
            return;
        }
        [[RefreshTokenCheck sharedRefreshTokenCheck] foreceFetchRefreshTokenAndProceedWithBlock:^(NSDictionary* dictResponse){
            if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenIsBeingFetched"] isEqualToString:@"true"]){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                        
                    }];
                    //[self updateUserInfo:updateInfo];
                });
            }
            else{
                if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenValid"] isEqualToString:@"yes"]){
                    //[self updateUserInfo:updateInfo];
                    [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                        
                    }];
                }
            }
        }];
        
    }
    else if(responseStatusCode == 403){
        /*
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [[JLManager sharedManager] logoutUserWithSuspendedAccountWithMessage:[NSString stringWithFormat:@"%@",[dict valueForKey:@"message"]]];
                        
                        [[JLManager sharedManager] logoutUserWithAlert];
                    });
                }
            }
        }*/
            [[JLManager sharedManager] logoutUserWithAlert:LogoutModeNoWatchbackAvailable];
    }
    /*else{
     if (data) {
     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
     if(kDebugLog)NSLog(@"%@",dict);
     }
     }
     */
    /////
    else if(responseStatusCode >= 500 && responseStatusCode <= 599)
    {
        [self showAPIResponseError:@"App is not responding. Please try again."];
        ////////////
        NSMutableDictionary *dictTrackingData = [[NSMutableDictionary alloc] init];
        //[dictTrackingData setObject:@"true" forKey:@"tve.error"];
        [dictTrackingData setObject:@"Error" forKey:@"tve.userpath"];
        [dictTrackingData setObject:@"Error" forKey:@"tve.title"];
        [dictTrackingData setObject:@"Error" forKey:@"tve.contenthub"];
        [dictTrackingData setObject:[NSString stringWithFormat:@"%@",[connectionError localizedDescription]] forKey:@"tve.error"];
        [[JLTrackers sharedTracker] trackAdobeStates:@"Error" data:dictTrackingData];
        ////////

    }
    else
    {
        if (responseStatusCode == 401 || responseStatusCode == 403)
        {
            if([PerkoAuth IsUserLogin])
            {
                
                    if(responseStatusCode == 401){
                        [[JLManager sharedManager] logoutUserWithAlert:LogoutModeDefault];
                    }else{
                        [[JLManager sharedManager] logoutUserWithAlert:LogoutModeNoWatchbackAvailable];
                    }
                
            }
        }
        
        if (connectionError) {
            long errorCode = connectionError.code;
            //if(kDebugLog)NSLog(@"%ld",errorCode);
            if (errorCode == -1012) {
                if ([PerkoAuth IsUserLogin]) {
                        [[JLManager sharedManager] logoutUserWithAlert:LogoutModeDefault];
                }
                
            }
        }
        if(data)
        {
            NSDictionary *serverResponseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (serverResponseDict && [serverResponseDict isKindOfClass:[NSDictionary class]]) {
                
                if (serverResponseDict != nil) {
                    
                    NSString *message = [serverResponseDict valueForKey:@"message"];
                    if(message != nil && [message isKindOfClass:[NSString class]])
                    {
                        if ([message rangeOfString:@"user already exists"].location == NSNotFound)
                        {
                            [self showAPIResponseError:[NSString stringWithFormat:@"%@",message]];
                        }
                    }
                }
                
            }
        }
        
    }
    ////
}
- (void) showAPIResponseError:(NSString *) errorMessage{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (errorMessage != nil && ![errorMessage isEqual:[NSNull null]] && [errorMessage isKindOfClass:[NSString class]] && [errorMessage length] > 0) {
//            UIViewController *vc = [[JLManager sharedManager] topViewController];
//            UIView *view = vc.view;
//            if (view && view.window != nil) {
//                [view makeToast:errorMessage duration:5.0 position:@"center"];
//            }
            //[[UIApplication sharedApplication].keyWindow makeToast:errorMessage duration:1.0 position:@"center"];
            [[UIApplication sharedApplication].keyWindow makeToast:@"" duration:1.0 position:CSToastPositionCenter title:errorMessage image:nil style:nil completion:nil];
           
        }
    });
}

-(void)callAPIBR:(NSString *)strUrl params:(NSString *)params httpMethod:(NSString *)httpMethod checkforRefreshToken:(BOOL)checkforRefreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest defaultRequestWithURLBR:strUrl param:params httpMethod:httpMethod];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                          int responseStatusCode = (int)[httpResponse statusCode];
                                          NSDictionary *dict;
                                          if (data) {
                                              dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                          }
                                          else{
                                              dict = [NSDictionary new];
                                          }
                                          
                                          if (responseStatusCode <= 300 && data) {
                                              if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                                                  handler(true,dict);
                                                  return;
                                              }
                                              
                                          }
                                          else{
                                              [[JLManager sharedManager] checkForForceUpdate:data responseStatusCode:responseStatusCode];
                                          }
                                          if((responseStatusCode == 401 || responseStatusCode == 400) && [PerkoAuth IsUserLogin]){
                                              if (!self.m_bRetry) {
                                                  self.m_bRetry = true;
                                                  if(checkforRefreshToken){
                                                  [[RefreshTokenCheck sharedRefreshTokenCheck] foreceFetchRefreshTokenAndProceedWithBlock:^(NSDictionary* dictResponse){
                                                      [self callAPIBR:strUrl params:params httpMethod:httpMethod checkforRefreshToken:checkforRefreshToken handler:handler];
                                                      if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenIsBeingFetched"] isEqualToString:@"true"]){
                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                              [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                  // [self callAPI:strUrl params:params httpMethod:httpMethod handler:handler];
                                                              }];
                                                          });
                                                      }
                                                      else{
                                                          if([[[dictResponse valueForKey:@"data"] valueForKey:@"isRefreshTokenValid"] isEqualToString:@"yes"]){
                                                              //[self updateUserInfo:updateInfo];
                                                              [[JLManager sharedManager] getUserInfo:^(BOOL success) {
                                                                  //[self callAPI:strUrl params:params httpMethod:httpMethod handler:handler];
                                                              }];
                                                          }
                                                      }
                                                  }];
                                                  }
                                              }
                                              else{
                                                  self.m_bRetry = false;
                                                  [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:NO];
                                                  handler(false,dict);
                                                  
                                              }
                                          }
                                          else{
                                              [self handleCommonErrorResponse:data response:response error:error check_for_refreshToken:NO];
                                              handler(false,dict);
                                          }
                                          
                                      });
                                      
                                      
                                  }];
    [task resume];
    
    
    
}
@end
