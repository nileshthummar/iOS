//
//  PerkoAuth.h
//  Watchback
//
//  Created by Nilesh on 10/24/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPerkUser.h"


@interface PerkoAuth : NSObject
+(void)setDevMode:(BOOL)isDev;
+(NSString *)inValidateEmail:(NSString *)strEmail;
+(NSString *)inValidatePassword:(NSString *)strPassword isSignup:(BOOL)isSignup;
+(JLPerkUser *)getPerkUser;
+(BOOL)IsUserLogin;
+(void)setLogoutStatus;

+(void)loginWithEmail:(NSString *)username password:(NSString *)password passwordcheck:(BOOL)passwordcheck handler:(void (^) (BOOL success, NSDictionary *dict))handler;
+(void)loginWithFB:(NSString *)fb_accesstoken handler:(void (^) (BOOL success, NSDictionary *dict))handler;

+(void)singupWithEmail:(NSString *)username firstName:(NSString *)firstName lastName:(NSString *)lastName  password:(NSString *)password gender:(NSString *)gender dob:(NSString *)dob phoneno: (NSString *)phoneno  handler:(void (^) (BOOL success, NSDictionary *dict))handler;
//+(void)callAPIForRefreshToken;

@end
