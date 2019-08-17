/**
 * App SDK Plugin
 * Copyright (C) 2016, The Nielsen Company (US) LLC. All Rights Reserved.
 *
 * Software contains the Confidential Information of Nielsen and is subject to your relevant agreements with Nielsen.
 */


#import <Foundation/Foundation.h>

@interface NSDictionary (NielsenBrightcove)
@property (readonly) NSString *JSONString;
- (NSDictionary *)mergeDictionary:(NSDictionary *)dictionary;
@end
