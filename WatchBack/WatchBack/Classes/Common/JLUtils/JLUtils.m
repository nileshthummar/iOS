//
//  JLUtils.m
//  Perk Browser
//
//  Created by Shanthi Vardhan on 19/10/13.
//  Copyright (c) 2013 Nilesh Thummar. All rights reserved.
//

#import "JLUtils.h"
#import "JLPerkUser.h"
#import "NSString+HMACString.h"
#import "NSMutableURLRequest+Additions.h"
#import <AdSupport/AdSupport.h>
#include <ifaddrs.h> 
#include <arpa/inet.h>
#import "JLManager.h"
#import "Constants.h"
#import "PerkoAuth.h"
#import <sys/utsname.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

static NSOperationQueue * _networkOperationQueue;

NSOperationQueue * GetNetworkOperationQueue() {

    if (_networkOperationQueue == nil) {
        
        _networkOperationQueue = [[NSOperationQueue alloc] init];
        [_networkOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    
    return _networkOperationQueue;
}

static dispatch_queue_t _dataWorkerQueue = nil;

dispatch_queue_t GetDataWorkerQueue(){
    
    if (_dataWorkerQueue == nil) {
        
        _dataWorkerQueue = dispatch_queue_create("Data Checker Queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _dataWorkerQueue;
}

NSString * getStringFromJSONValue(id jsonValue){
    
    NSString * objStr = nil;
    if ([jsonValue isKindOfClass:[NSString class]]) {
        
        objStr = jsonValue;
        
    }else if ([jsonValue isKindOfClass:[NSArray class]]) {
        
        NSArray * objArr  = (NSArray *) jsonValue;
        objStr = [objArr componentsJoinedByString:@","];
    }
    else if ([jsonValue isKindOfClass:[NSNumber class]]) {
        
        NSNumber * objNum  = (NSNumber *) jsonValue;
        objStr = [objNum stringValue];
    }
    else if ([jsonValue isKindOfClass:[NSDictionary class]]) {
        
        objStr = @"{}";
        
    }else {
        
    }
    
    return objStr;
}



static NSString * _defaultUserAgentStr;

NSString * GetDefaultUserAgent () {
    
    if (_defaultUserAgentStr == nil) {
        
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        _defaultUserAgentStr = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
    }
    return _defaultUserAgentStr;
}

static NSString * _perkUserAgentStr;

//NSString * GetPerkUserAgent () {
//
//    if (_perkUserAgentStr == nil) {
//
//        _perkUserAgentStr = GetDefaultUserAgent();
//
//        if([_perkUserAgentStr rangeOfString:@"Perk "].location == NSNotFound){
//
//           _perkUserAgentStr = [_perkUserAgentStr stringByAppendingFormat:@" Perk (%@)/%@",kDeviceUA,GetBuildVersion ()];
//
//        }
//    }
//    return _perkUserAgentStr;
//}

static NSString * _perkAPIUserAgentStr;

//NSString * GetPerkAPIUserAgent () {
//    
//    if (_perkAPIUserAgentStr == nil) {
//        
//        //{AppName}/AppVersion (Apple; {DeviceModel}; {Resolution}; iOS; {OsVersion}) Mobile/PTVIPD
//        
//        NSString *device = [NSString stringWithFormat:@"%@",[UIDevice currentDevice].model];
//        NSString *os_version = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]];
//        
//        CGRect rect = [UIScreen mainScreen].bounds;
//        NSString *resolution = [NSString stringWithFormat:@"%.0fx%.0f",rect.size.width,rect.size.height];
//        
//        NSString *app_version = [NSString stringWithFormat:@"%@",GetBuildVersion ()];
//        
//       // NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
//        
//        _perkAPIUserAgentStr = [NSString stringWithFormat:@"%@/%@ (Apple; %@; %@; iOS; %@) Mobile/%@ ",GetAppProductName (), app_version, device, resolution,os_version,kDeviceUA];
//        
//    }
//    return _perkAPIUserAgentStr;
//    
//    
//}
NSString * GetAppProductName ()
{
    NSString *result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    
    return result;
}

static NSString * _perkAPIDeviceInfoStr;

NSString * GetPerkAPIDeviceInfo () {
    
    if (_perkAPIDeviceInfoStr == nil) {
        
    
        
        _perkAPIDeviceInfoStr = [NSString stringWithFormat:@"app_name=%@",GetAppProductName ()];
        
         NSString *app_version = [NSString stringWithFormat:@"%@",GetBuildVersion ()];
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";app_version=%@",app_version];

        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";app_bundle_id=%@",bundleIdentifier];
        
         _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";product_identifier=%@",kDeviceType];
        
         _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";device_manufacturer=Apple"];
        

        NSString *device = [NSString stringWithFormat:@"%@",[UIDevice currentDevice].model];
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";device_model=%@",device];
        
        
        CGRect rect = [UIScreen mainScreen].bounds;
        NSString *resolution = [NSString stringWithFormat:@"%.0fx%.0f",rect.size.width,rect.size.height];
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";device_resolution=%@",resolution];
        
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";os_name=iOS"];
        

        NSString *os_version = [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]];
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";os_version=%@",os_version];
        
        _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";open_udid=%@",watchbackGetDeviceID()];
        
        
        
        NSString *ios_idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
         _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";ios_idfa=%@",ios_idfa];
        
        
        NSString *ios_idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
         _perkAPIDeviceInfoStr = [_perkAPIDeviceInfoStr stringByAppendingFormat:@";ios_idfv=%@",ios_idfv];
        
    }
    return _perkAPIDeviceInfoStr;
    
    
}



BOOL isiOS7 () {
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

static NSNumber * _isDeviceTypeiPad = nil;

BOOL isDeviceiPad() {
    
    if (_isDeviceTypeiPad == nil) {
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                _isDeviceTypeiPad = [NSNumber numberWithBool:YES];
            }
            else{
                _isDeviceTypeiPad = [NSNumber numberWithBool:NO];
            }
        }
        else{
            
            _isDeviceTypeiPad = [NSNumber numberWithBool:NO];
        }
        
    }
    return [_isDeviceTypeiPad boolValue];
}

UIImage * maskImage(UIImage *_image , UIColor *color)
{
    CGRect rect = CGRectMake(0, 0, _image.size.width, _image.size.height);
    UIGraphicsBeginImageContextWithOptions(_image.size, NO, _image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [_image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

UIImage * CropImage(UIImage *_image , CGPoint cropStartPoint,  CGSize imageSize)
{
    UIGraphicsBeginImageContext(imageSize);
    CGRect imageRect = CGRectMake(cropStartPoint.x, cropStartPoint.y, imageSize.width, imageSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
	//CGImageRelease(imageRef);
    return img;
}

UIImage * ResizeImage(UIImage *_image , CGSize imageSize)
{
	CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContext(imageRect.size);
    [_image drawInRect:imageRect];
    _image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _image;
}

UIImage * ImageWithColor(UIColor *color ){
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


NSString * GetIPAddress() {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

static NSDateFormatter * _dateFormatterRFC2822 = nil;

NSDateFormatter * GetRFC2822DateFormatter () {

    if (_dateFormatterRFC2822 == nil) {
        
        _dateFormatterRFC2822 = [[NSDateFormatter alloc] init];
        _dateFormatterRFC2822.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[_dateFormatterRFC2822 setLocale:usLocale];

    }
    return _dateFormatterRFC2822;
}

NSString * GetRFC2822DateString() {

    NSDate * currentDate = [NSDate date];
    NSString * timestampStr = [GetRFC2822DateFormatter() stringFromDate:currentDate];
    return timestampStr;
}
UIImage* ImageWithView(UIView * view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


UIImage* RotateImage(UIImage* image, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(image.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orientation == UIImageOrientationRight) {
        
		CGContextRotateCTM (context, radians(90));
		
    } else if (orientation == UIImageOrientationLeft) {
       
		CGContextRotateCTM (context, radians(-90));
		
    } else if (orientation == UIImageOrientationDown) {

    } else if (orientation == UIImageOrientationUp) {
    
		CGContextRotateCTM (context, radians(90));
    }
	
    [image drawAtPoint:CGPointMake(0, 0)];
	
    return UIGraphicsGetImageFromCurrentImageContext();
}


BOOL isJailbroken ()
{
    return NO;// [PerkSecurity detectVM];
}

static NSString * letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

NSString * GetSessionID() {
	
	int len = 64;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
    for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
	
    return randomString;
}

BOOL isProxyConfigEnabled (){
	
	CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
	const CFStringRef autoConfigEnable = (const CFStringRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesProxyAutoConfigEnable);
	
	NSString * isAutoConfigEnable = (__bridge NSString *)autoConfigEnable;
	
	if (isAutoConfigEnable != nil && ![isAutoConfigEnable isEqual:[NSNull null]]) {
		
		return  [isAutoConfigEnable boolValue];
	}
	
	const CFStringRef httpProxyEnable = (const CFStringRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPEnable);
	
	NSString * isHTTPProxyEnable = (__bridge NSString *)httpProxyEnable;
	
	if (isHTTPProxyEnable != nil && ![isHTTPProxyEnable isEqual:[NSNull null]]) {
		
		return  [isHTTPProxyEnable boolValue];
	}
	
	return NO;
}

void CheckForAdBlockerWithBlock(NSString *strURL, AdblockerResponseBlockCompletionHandler completionHandler ){
    ///////
    
//   [PerkSecurity detectAdBlock:strURL completionHandler:^ (bool isAdblockerEnabled){
//        
//         completionHandler(isAdblockerEnabled);
//        
//    }];
    
}

NSString * GetUserCountry ()
{
    NSString *strCountry = [PerkoAuth getPerkUser].country;
    if (!strCountry || strCountry == nil || strCountry.length < 1) {
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [NSString stringWithFormat:@"%@",[currentLocale objectForKey:NSLocaleCountryCode]];
        // if(kDebugLog)NSLog(@"%@",countryCode);
        if (countryCode && ([countryCode isEqualToString:@"GB"] || [countryCode isEqualToString:@"EU"] || [countryCode isEqualToString:@"OC"] || [countryCode isEqualToString:@"IE"] || [countryCode isEqualToString:@"UK"])) {
            //return 'UK';
            strCountry = @"UK";
        }
        else
        {
            strCountry = @"US";
        }
        
    }
    return strCountry;
}
NSString * GetBuildVersion ()
{
    NSString *result = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([result length] == 0)
        result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    return result;
}
NSString * GetBuildIdentifier ()
{
    NSString *result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleIdentifierKey];
    
    return result;
}

NSString *getWatchbackWebDomain()
{

    NSString *debug =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeDebug]];

    if ([debug boolValue]) {
        
        NSString *retURL = @"https://";
        NSString *protocol =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeProtocol]];
        
        if ([protocol isEqualToString:@"Non-SSL"]) {
            retURL = @"http://";
        }
        else
        {
            retURL = @"https://";
        }
        
        NSString *api_endpoint =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeAPIEndpoint]];
        
        if ([api_endpoint isEqualToString:@"Custom"]) {
            retURL = [retURL stringByAppendingFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeAPIEndpointCustomWeb]];
        }
        else if([api_endpoint isEqualToString:@"Development"])
        {
            retURL = [retURL stringByAppendingFormat:@"%@",@"dev.watchback.com"];
        }
        else
        {
            retURL = [retURL stringByAppendingFormat:@"%@",@"watchback.com"];
        }
        return retURL;
    }
    else
    {
        return @"https://watchback.com";
    }
}
NSString *getWatchbackAPITVDomain()
{

    NSString *debug =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeDebug]];
    
    if ([debug boolValue]) {
        NSString *retURL = @"https://";
        NSString *protocol =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeProtocol]];
        
        if ([protocol isEqualToString:@"Non-SSL"]) {
            retURL = @"http://";
        }
        else
        {
            retURL = @"https://";
        }
        
        NSString *api_endpoint =  [NSString stringWithFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeAPIEndpoint]];
        
        if ([api_endpoint isEqualToString:@"Custom"]) {
            retURL = [retURL stringByAppendingFormat:@"%@",[[JLManager sharedManager] getObjectuserDefault:kDevModeAPIEndpointCustomAPITV]];
        }
        else if([api_endpoint isEqualToString:@"Development"])
        {
            retURL = [retURL stringByAppendingFormat:@"%@",@"api-dev.watchback.com"];
        }
        else
        {
            retURL = [retURL stringByAppendingFormat:@"%@",@"api.watchback.com"];
        }
        return retURL;
    }
    else
    {
        return @"https://api.watchback.com";
    }
}


#pragma mark
UIImage * getProfileFromText(id imgView) {
   
    ////
    NSString *firstLetter = @"";
    NSString *strName = @"";
    NSString *strEmail = @"";
    
    //
    
    
    CGFloat fontSize = CGRectGetWidth([imgView bounds]) * 0.42f;
   
    UIFont *font =  [UIFont systemFontOfSize:fontSize];
    NSDictionary *textAttributes =  @{
                                     NSFontAttributeName:font ,
                                     NSForegroundColorAttributeName:kPrimaryBGColorNight
                                     };
    
    JLPerkUser * user = [PerkoAuth getPerkUser];
    strName = user.firstname;
    strEmail = user.email;
    if (strEmail == nil || ![strEmail isKindOfClass:[NSString class]]) {
        strEmail = @"";;
    }
    
    if (strName != nil && [strName isKindOfClass:[NSString class]] && strName.length > 0) {
        firstLetter = [strName substringToIndex:1];
    }
    else if (strEmail.length > 0) {
        strName = strEmail;
        firstLetter = [strName substringToIndex:1];
    }
    firstLetter = [firstLetter uppercaseString];
    
    /////
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = [imgView bounds].size;
    if ([imgView contentMode] == UIViewContentModeScaleToFill ||
        [imgView contentMode] == UIViewContentModeScaleAspectFill ||
        [imgView contentMode] == UIViewContentModeScaleAspectFit ||
        [imgView contentMode] == UIViewContentModeRedraw)
    {
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //if (isCircular)
    {
        //
        // Clip context to a circle
        //
        CGPathRef path = CGPathCreateWithEllipseInRect([imgView bounds], NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    //
    // Fill background of context
    //
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    //
    // Draw text in the context
    //
    CGSize textSize = [firstLetter sizeWithAttributes:textAttributes];
    CGRect bounds = [imgView bounds];
    
    [firstLetter drawInRect:CGRectMake(bounds.size.width/2 - textSize.width/2,
                                bounds.size.height/2 - textSize.height/2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //imgView.image = snapshot;
    return snapshot;
}

NSString * encodeString(NSString *str){
  /*  return  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)str,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
    */
    //return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
//    NSString *unreserved = @"!*'();:@&=+$,/?%#[]";
//    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
//                                      URLQueryAllowedCharacterSet];
//    //[allowed addCharactersInString:unreserved];
//    [allowed removeCharactersInString:unreserved];
//    return [str stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    
    NSCharacterSet * queryKVSet = [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"].invertedSet;
    NSString * valueSafe = [str stringByAddingPercentEncodingWithAllowedCharacters:queryKVSet];
    return valueSafe;
}

NSString* WatchbackGetDeviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

NSString *watchbackGetDeviceID()
{
    NSString *ios_idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return ios_idfv;
}
