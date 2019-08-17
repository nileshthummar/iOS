//
//  PerkoAuth.m
//  Watchback
//
//  Created by Nilesh on 10/24/16.
//  Copyright © 2016 Nilesh. All rights reserved.
//

#import "PerkoAuth.h"
#import "UIView+Toast.h"
#import "JLPerkUser.h"
#import "JLUtils.h"
#import "Constants.h"
#import "JLTrackers.h"
#import "WebServices.h"
@implementation PerkoAuth
+(void)setDevMode:(BOOL)isDev
{
    //sIsDev = isDev;
}
#pragma mark-
#pragma mark login with email methods
+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+(NSString *)inValidateEmail:(NSString *)strEmail
{
    strEmail = [strEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * strErrorMessage = nil;
    
    if (strEmail == nil || [strEmail isEqualToString:@""]) {
        strErrorMessage = @"Please enter Email";
    }else if (![self validateEmailWithString:strEmail]) {
        strErrorMessage = @"Please enter Valid Email";
    }
    if(strErrorMessage==nil){
        if([strEmail rangeOfString:@"perk.com"].location==NSNotFound && [strEmail rangeOfString:@"jutera.com"].location==NSNotFound){
            if([strEmail rangeOfString:@"+"].location!=NSNotFound){
                strErrorMessage = @"Emails with '+' sign are not allowed.";
            }
        }
    }
    
    return strErrorMessage;
    
}
+(NSString *)inValidatePassword:(NSString *)strPassword isSignup:(BOOL)isSignup
{
    NSString * strErrorMessage = nil;
    strPassword = [strPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (strPassword == nil || [strPassword isEqualToString:@""]) {
        strErrorMessage = @"Please enter Password";
    }
    else if ([strPassword rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
        strErrorMessage = @"The Password field must be at least 1 number.";
    }
    else{
        if (isSignup) {
            if([strPassword length]< 8){
                strErrorMessage = @"The Password field must be at least 8 characters in length.";
            }
            else{
                int uppercaseCount = 0;
                int lowerCount = 0;
                for (int i = 0; i < [strPassword length]; i++) {
                    BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[strPassword characterAtIndex:i]];
                    if (isUppercase == YES){
                        uppercaseCount++;
                    }
                    BOOL isLowercase = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[strPassword characterAtIndex:i]];
                    if (isLowercase == YES){
                        lowerCount++;
                    }
                }
                if (uppercaseCount == 0 || lowerCount == 0) {
                    strErrorMessage = @"The Password field must be at least 1 uppercase and lowercase.";
                }
            }
            
        }
        else{
            if([strPassword length]< 6){
                strErrorMessage = @"The Password field must be at least 6 characters in length.";
            }
        }
        
    }
    
    return strErrorMessage;
}


+(void)CreateAndUpdatePerkUserwithAttributes:(NSDictionary*)dictPerkUserAttributes{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(CreateAndUpdatePerkUserwithAttributes:) withObject:dictPerkUserAttributes waitUntilDone:NO];
        return;
    }
    JLPerkUser * user = [PerkoAuth getPerkUser];
    
    if(dictPerkUserAttributes==nil){
        user.perkPoint.lifetimeperks=[NSNumber numberWithInt:50];
    }
    user.email = [dictPerkUserAttributes valueForKey:@"email"];
    user.IsUserLogin = [dictPerkUserAttributes valueForKey:@"IsUserLogin"];
    user.loginType = [dictPerkUserAttributes valueForKey:@"type"];
    
    //user.userId  = [dictPerkUserAttributes valueForKey:@"user_id"];
    user.refreshToken = [dictPerkUserAttributes valueForKey:@"refresh_token"];
    user.accessToken = [dictPerkUserAttributes valueForKey:@"access_token"];
    user.expires_in = [dictPerkUserAttributes valueForKey:@"expires_in"];
    
    
    NSDate *loginSystemDate = [NSDate date];
    NSString *loginDate = [[NSString alloc] initWithFormat:@"%lf",[loginSystemDate timeIntervalSince1970]];
    user.clientLoginTime = loginDate;
    
    
    
    user.sessionId = GetSessionID();
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:perkUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[JLTrackers sharedTracker] setCrashlyticsDataForCurrentUser];
    
    [self assignDeviceToUser];
    
}
+(void)assignDeviceToUser
{
    
    ///
//    NSString *device_model = [NSString stringWithFormat:@"%@",[UIDevice currentDevice].model];
//    NSString *app_version = GetBuildVersion ();
//    NSMutableString *postString = [[NSMutableString alloc] initWithFormat:@"device_id=%@",watchbackGetDeviceID()];
//    [postString appendFormat:@"&product_identifier=%@",kDeviceType];
//    [postString appendFormat:@"&device_model=%@",device_model];
//    [postString appendFormat:@"&version=%@",app_version];
    
   // NSString * postString = [NSString stringWithFormat:@"access_token=%@",[PerkoAuth getPerkUser].accessToken];
    
    NSString *strURL = API_AssingUnAssingDeviceUser;
    
    /*
     this api returns 204 as status code and nothing as response, because of the code in callapi method, if it doesn't return anything it is considering as success = 'no', thats why not going into success block...
     */
    [[WebServices sharedManager] callAPIJSON:strURL params:[NSDictionary dictionaryWithObjectsAndKeys:[PerkoAuth getPerkUser].accessToken,@"access_token", nil] httpMethod:@"PUT" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
        
    }];
    
}
+(void)unAssignDeviceFromUser
{
    ///
    
    NSString * accessToken = [PerkoAuth getPerkUser].accessToken ;
    if ((id)accessToken == [NSNull null] || accessToken == nil || accessToken.length < 1) {
        return;
    }
//    NSString *device_model = [NSString stringWithFormat:@"%@",[UIDevice currentDevice].model];
//    NSString *app_version = GetBuildVersion ();
//    NSMutableString *postString = [[NSMutableString alloc] initWithFormat:@"device_id=%@",watchbackGetDeviceID()];
//    [postString appendFormat:@"&product_identifier=%@",kDeviceType];
//    [postString appendFormat:@"&device_model=%@",device_model];
//    [postString appendFormat:@"&version=%@",app_version];
    ////
   // NSString * postString = @"";
    NSString *strURL = [NSString stringWithFormat:@"%@?access_token=%@",API_AssingUnAssingDeviceUser,[PerkoAuth getPerkUser].accessToken];
    /*
     this api returns 204 as status code and nothing as response, because of the code in callapi method, if it doesn't return anything it is considering as success = 'no', thats why not going into success block...
     */
    [[WebServices sharedManager] callAPIJSON:strURL params:nil httpMethod:@"DELETE" check_for_refreshToken:NO handler:^(BOOL success, NSDictionary *dict) {
        if (success) {
            
        }
        [self resetUserInfo];
        [[JLManager sharedManager] resetDefaults];
        
        [[JLManager sharedManager] closeAndClearFBTokenInformation];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSetSelectedTabIndexNotification object:@"0"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetHeaderNotification object:nil];
    }];
}
+(void)resetUserInfo{
    JLPerkUser * user =[self getPerkUser];
    user.total_videos_watched = [NSNumber numberWithLong:0];
    user.session_videos_watched = [NSNumber numberWithInt:0];
    user.userId = nil;
    user.email = nil;
    user.firstname = nil;
    user.lastname = nil;
    user.refreshToken = nil;
    user.accessToken = nil;
    user.IsUserLogin = @"NO";
    user.loginType= nil;
    user.country = nil;
    user.referralCode = nil;
    user.email_confirmed = nil;
    user.expires_in = nil;
    user.clientLoginTime = nil;
    user.perkPoint.pendingperks = [NSNumber numberWithInt:0];
    user.perkPoint.availableperks = [NSNumber numberWithInt:0];
    user.perkPoint.availableTokens = [NSNumber numberWithInt:0];
    user.perkPoint.lifetimeperks = [NSNumber numberWithInt:0];
    user.perkPoint.searchperks = [NSNumber numberWithInt:0];
    user.perkPoint.shoppingperks = [NSNumber numberWithInt:0];
    user.perkPoint.miscperks = [NSNumber numberWithInt:0];
    user.perkPoint.redeemedperks = [NSNumber numberWithInt:0];
    user.perkPoint.cancelledperks = [NSNumber numberWithInt:0];
    user.perkPoint.unread_notifications = [NSNumber numberWithInt:1];
    user.isOver21 = [NSNumber numberWithBool:YES];
    user.userUUID  = nil;
    user.profile_image = nil;
    user.birthday = nil;
    user.gender = nil;
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:user] forKey:perkUserKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[JLManager sharedManager] showLoginSignUpwithUserAction:0];
    
    [[JLTrackers sharedTracker] setCrashlyticsDataForCurrentUser];
}
+(void)setLogoutStatus{
    
    [self unAssignDeviceFromUser];
    
}
+(JLPerkUser *)getPerkUser{
    
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:perkUserKey];
    JLPerkUser * perkuser;
    if (userData != nil){
        perkuser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
    if(perkuser==nil){
        perkuser = [[JLPerkUser alloc] init];
    }
    return perkuser;
}

+(BOOL)IsUserLogin{
    JLPerkUser * objuser= [self getPerkUser];
    return    [objuser.IsUserLogin boolValue];
}
+(void)loginWithEmail:(NSString *)username password:(NSString *)password passwordcheck:(BOOL)passwordcheck handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    NSString *strEmailError = [PerkoAuth inValidateEmail:username];
    if(strEmailError){
        handler(false,@{@"data":@{@"message":strEmailError}});
        [[WebServices sharedManager] showAPIResponseError:strEmailError];
        return;
    }
    NSString *strPasswordError;
    if(passwordcheck){
        strPasswordError = [PerkoAuth inValidatePassword:password isSignup:FALSE];
    }
    
    if(strPasswordError){
        handler(false,@{@"data":@{@"message":strPasswordError}});
        [[WebServices sharedManager] showAPIResponseError:strPasswordError];
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@",LOGIN_OAUTH_URL];
   // strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSDictionary *dict = @{@"email":username,@"password":password};
    
    [[WebServices sharedManager] callAPIJSON:strUrl params:dict httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        
        if (success) {
            
            NSDictionary *userDict = [dict objectForKey:@"data"];
            if (userDict != nil && [userDict isKindOfClass:[NSDictionary class]]) {
                userDict = [userDict objectForKey:@"token"];
            }
            
            NSMutableDictionary *dicLoginStatus = [NSMutableDictionary dictionaryWithDictionary:userDict];
            
            
            [dicLoginStatus setValue:username forKey:@"email"];
            [dicLoginStatus setValue:@"YES" forKey:@"IsUserLogin"];
            [dicLoginStatus setValue:@"email" forKey:@"type"];
            
            [self CreateAndUpdatePerkUserwithAttributes:dicLoginStatus];
            
            
            [[JLManager sharedManager] getUserInfo:^(BOOL successUserInfo) {
                handler(success,dict);
                
            }];
            
        }
        else{
            handler(success,dict);
        }
    }];
}
+(void)loginWithFB:(NSString *)fb_accesstoken handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    NSString *strUrl = [NSString stringWithFormat:@"%@",LOGIN_OAUTH_URL];
   // strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSDictionary *dict = @{@"client_id":kDeviceType,@"client_secret":kPerkSecret,
                           @"grant_type":@"social",@"network":@"facebook",@"product_identifier":kDeviceType,
                           @"access_token":fb_accesstoken};
    
    
    [[WebServices sharedManager] callAPIJSON:strUrl params:dict httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        
        if (success) {
            
            NSDictionary *userDict = [dict objectForKey:@"data"];
            if (userDict != nil && [userDict isKindOfClass:[NSDictionary class]]) {
                userDict = [userDict objectForKey:@"token"];
            }
            
            NSMutableDictionary *dicLoginStatus = [NSMutableDictionary dictionaryWithDictionary:userDict];
            
            
            //[dicLoginStatus setValue:username forKey:@"email"];
            [dicLoginStatus setValue:@"YES" forKey:@"IsUserLogin"];
            [dicLoginStatus setValue:@"facebook" forKey:@"type"];
            
            [self CreateAndUpdatePerkUserwithAttributes:dicLoginStatus];
            [[JLManager sharedManager] getUserInfo:^(BOOL successUserInfo) {
                handler(success,dict);
            }];
            
        }
        else{
            handler(success,dict);
        }
    }];
}
+(void)singupWithEmail:(NSString *)username firstName:(NSString *)firstName lastName:(NSString *)lastName  password:(NSString *)password gender:(NSString *)gender dob:(NSString *)dob phoneno: (NSString *)phoneno  handler:(void (^) (BOOL success, NSDictionary *dict))handler
{
    NSString *strEmailError = [PerkoAuth inValidateEmail:username];
    if(strEmailError){
        handler(false,@{@"data":@{@"message":strEmailError}});
        [[WebServices sharedManager] showAPIResponseError:strEmailError];
        return;
    }
    NSString *strPasswordError = [PerkoAuth inValidatePassword:password isSignup:TRUE];
    if(strPasswordError){
        handler(false,@{@"data":@{@"message":strPasswordError}});
        [[WebServices sharedManager] showAPIResponseError:strPasswordError];
        return;
    }
    
    if(dob.length>0){
        // change format from dd/MM/yyyy to yyyy/MM/dd
        NSString *dateString = dob;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [format dateFromString:dateString];
        [format setDateFormat:@"yyyy/MM/dd"];
        NSString* finalDateString = [format stringFromDate:date];
        dob = finalDateString;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@",REGISTER_OAUTH_URL];
   // strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSDictionary *dict = @{@"email":username,
                           @"password":password,
                           @"gender":gender,
                           @"birth_date":dob,
                           @"phone" : phoneno
                          // @"first_name":firstName,
                          // @"last_name":lastName
                           };
    
    
    [[WebServices sharedManager] callAPIJSON:strUrl params:dict httpMethod:@"POST" check_for_refreshToken : NO handler:^(BOOL success, NSDictionary *dict) {
        
        if (success) {
            [[JLTrackers sharedTracker] trackLeanplumEvent:@"registration_success"];
            [self loginWithEmail:username password:password passwordcheck:true handler:^(BOOL success, NSDictionary *dict) {
                handler(success,dict);
            }];
                    }
        else{
            handler(success,dict);
        }
        
    }];
}
+(BOOL) lookForRefreshToken
{
    JLPerkUser * perkUser = [PerkoAuth getPerkUser];
    
    NSString *lgTime = perkUser.clientLoginTime;
    NSNumber * expires_in = perkUser.expires_in;
    
    if (expires_in == nil || [expires_in isEqual:[NSNull null]]) {
        
        return YES;
    }
    
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
    if (seconds >= [expires_in intValue] -  259200)//259200 is 3X24X60X60  //432000 is 5x24x60x60 Seconds for 6days
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
