//
//  JLUtils.h
//  Perk Browser
//
//  Created by Shanthi Vardhan on 19/10/13.
//  Copyright (c) 2013 Nilesh Thummar. All rights reserved.
//
#import <UIKit/UIKit.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^ AdblockerResponseBlockCompletionHandler)(bool isAdblockerEnabled);
#endif


@class JLPerkUser;


NSOperationQueue * GetNetworkOperationQueue(void);

dispatch_queue_t GetDataWorkerQueue(void);

NSString * getStringFromJSONValue(id jsonValue);


NSString * GetDefaultUserAgent(void);

BOOL isiOS7 (void);

BOOL isDeviceiPad (void);

UIImage * maskImage(UIImage *_image , UIColor *color);

UIImage * ImageWithColor(UIColor *color );

NSString * GetIPAddress(void);

//NSString * GetPerkUserAgent (void);

NSDateFormatter * GetRFC2822DateFormatter (void);

//NSString * GetHMACAuthrizationHeader(NSString * requestParams);

NSString * GetRFC2822DateString(void);

UIImage * ResizeImage(UIImage *_image , CGSize imageSize);

//NSString * GetPerkAPIUserAgent (void);
NSString * GetPerkAPIDeviceInfo (void);

UIImage* ImageWithView(UIView * view);

UIImage* RotateImage(UIImage* image, UIImageOrientation orientation);

BOOL isJailbroken (void);
void CheckForAdBlockerWithBlock(NSString *strURL, AdblockerResponseBlockCompletionHandler completionHandler );

NSString * GetSessionID(void);

UIImage * CropImage(UIImage *_image , CGPoint cropStartPoint,  CGSize imageSize);

BOOL isProxyConfigEnabled (void);

NSString * GetUserCountry (void);
NSString * GetBuildVersion (void);
NSString *GetBuildIdentifier (void);


//NSString *getPerkWebDomain(void);
NSString *getWatchbackWebDomain(void);
NSString *getWatchbackAPITVDomain(void);

NSString * GetAppProductName (void);

UIImage * getProfileFromText(id imgView);
NSString * encodeString(NSString *str);
NSString* WatchbackGetDeviceName(void);
NSString *watchbackGetDeviceID(void);
