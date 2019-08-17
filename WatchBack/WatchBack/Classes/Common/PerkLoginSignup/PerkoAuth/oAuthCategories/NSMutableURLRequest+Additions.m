//
//  NSMutableURLRequest+Additions.m
//  Perk
//
//  Created by Shanthi Vardhan on 13/11/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "NSMutableURLRequest+Additions.h"
#import "JLUtils.h"
#import "PerkoAuth.h"
#import "JLPerkUser.h"
#import "NSString+HMACString.h"
@implementation NSMutableURLRequest (Additions)

+ (id) defaultRequestWithURL:(NSString *) strUrl  param:(NSString *)strParam httpMethod:(NSString *)strHttpMethod
{

   /* NSString * strTimeStamp = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)GetRFC2822DateString(),
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
    
    */
    NSString * strTimeStamp = encodeString(GetRFC2822DateString());

    if (strParam == nil || ![strParam isKindOfClass:[NSString class]] || strParam.length < 1) {
        strParam = [NSString stringWithFormat:@"timestamp=%@",strTimeStamp];
    }
    else{
        strParam = [strParam stringByAppendingFormat:@"&timestamp=%@",strTimeStamp];
    }
    ////
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [NSString stringWithFormat:@"%@",[PerkoAuth getPerkUser].accessToken];
        if ([strParam rangeOfString:kPERK_ACCESS_TOKEN].location == NSNotFound) {
            strParam = [strParam stringByAppendingFormat:@"&access_token=%@",kPERK_ACCESS_TOKEN];
        }
    }
    strUrl = [strUrl stringByReplacingOccurrencesOfString:kPERK_ACCESS_TOKEN withString:accessToken];
    strParam = [strParam stringByReplacingOccurrencesOfString:kPERK_ACCESS_TOKEN withString:accessToken];
    ////
    NSMutableURLRequest * newRequest;
    if ([strHttpMethod isEqualToString:@"POST"]) {
        
       // strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:strUrl];
        newRequest = [NSMutableURLRequest requestWithURL:url];
        [newRequest setHTTPBody:[strParam dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        if ([strUrl rangeOfString:@"?"].location != NSNotFound) {
            strUrl = [strUrl stringByAppendingFormat:@"&%@",strParam];
        }
        else{
            strUrl = [strUrl stringByAppendingFormat:@"?%@",strParam];
        }
        
       // strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:strUrl];
        newRequest = [NSMutableURLRequest requestWithURL:url];
        
    }
    [newRequest setHTTPMethod:strHttpMethod];
    //[newRequest setValue:GetPerkAPIUserAgent() forHTTPHeaderField:@"User-Agent"];
    [newRequest setValue:GetPerkAPIDeviceInfo() forHTTPHeaderField:@"Device-Info"];
     NSString *strAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    [newRequest addValue:[NSString stringWithFormat:@"%@ %@",strAppName, [strParam getHMACString]] forHTTPHeaderField:@"Authorization"];
    return newRequest;
}
+ (id) defaultRequestWithURLJSON:(NSString *) strUrl  param:(NSDictionary *)dictParam httpMethod:(NSString *)strHttpMethod
{
    NSMutableDictionary *dictBody = [NSMutableDictionary dictionaryWithDictionary:dictParam];
    [dictBody setObject:GetRFC2822DateString() forKey:@"timestamp"];
    /////
    NSString *accessToken = @"";
    if ([PerkoAuth IsUserLogin]) {
        accessToken = [PerkoAuth getPerkUser].accessToken;
    }
    strUrl = [strUrl stringByReplacingOccurrencesOfString:kPERK_ACCESS_TOKEN withString:accessToken];
    
    //////////
    NSMutableURLRequest * newRequest;
    
        
      //  strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:strUrl];
        newRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSError * createJSONError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictBody
                                                       options:NSJSONWritingPrettyPrinted error:&createJSONError];
    ////
    NSString *jsonString = @"";
    if (! jsonData) {
        jsonString = @"[]";
    } else {
        jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString =[jsonString stringByReplacingOccurrencesOfString:kPERK_ACCESS_TOKEN withString:accessToken];
    jsonData =  [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    /////
    [newRequest setHTTPBody:jsonData];
    
    [newRequest setHTTPMethod:strHttpMethod];
    [newRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   // [newRequest setValue:GetPerkAPIUserAgent() forHTTPHeaderField:@"User-Agent"];
    [newRequest setValue:GetPerkAPIDeviceInfo() forHTTPHeaderField:@"Device-Info"];
    NSString *strAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    
    NSString *strParam = @"";
    if (jsonData) {
        strParam = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    [newRequest addValue:[NSString stringWithFormat:@"%@ %@",strAppName, [strParam getHMACString]] forHTTPHeaderField:@"Authorization"];
    return newRequest;
}
+ (id) defaultRequestWithURL:(NSURL *) url {
    
    NSMutableURLRequest * newRequest = [NSMutableURLRequest requestWithURL:url];
    [newRequest setValue:GetPerkAPIDeviceInfo() forHTTPHeaderField:@"Device-Info"];
    return newRequest;
}
+ (id) defaultRequestWithURLBR:(NSString *) strUrl  param:(NSString *)strParam httpMethod:(NSString *)strHttpMethod
{
    
    
    NSMutableURLRequest * newRequest;
    if ([strHttpMethod isEqualToString:@"POST"]) {
        
        //strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:strUrl];
        newRequest = [NSMutableURLRequest requestWithURL:url];
        [newRequest setHTTPBody:[strParam dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
      //  strUrl = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        strUrl = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        if ([strUrl rangeOfString:@"?"].location != NSNotFound) {
            strUrl = [strUrl stringByAppendingFormat:@"&%@",strParam];
        }
        else{
            strUrl = [strUrl stringByAppendingFormat:@"?%@",strParam];
        }
        
        NSURL *url = [NSURL URLWithString:strUrl];
        newRequest = [NSMutableURLRequest requestWithURL:url];
        
    }
    [newRequest setHTTPMethod:strHttpMethod];
    
   // [newRequest setValue:@"application/json;pk=BCpkADawqM34qZK0FVZiqjW1d48fSZ2VmagDAjA_jVTXIRDfHKQLFNSzR7j9rSmPlg5HIzqnMlPvMxWUjonLpBbUXEaj3Nv1UGeQ-OyTgAc0ZfjXZbCj9LG3HE1xagNU9HYC3AJHkIvK3Nff" forHTTPHeaderField:@"Accept"];
    [newRequest setValue:@"application/json;pk=BCpkADawqM13REHugUCxg4AdyCPW0v68B04eqOfQ4N5KXiVQqUgdmJtJa65DTmF-2QXmT3xWBZQiWmP8KnoPRipaL6k1GGbEvrdmS3T5P2Ekwn6C3ECtQauvGmJbrdzVoUbMqWD8um1Sdfia" forHTTPHeaderField:@"Accept"]; 
    
    return newRequest;
}
@end
