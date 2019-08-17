/**
 * App SDK Plugin
 * Copyright (C) 2016, The Nielsen Company (US) LLC. All Rights Reserved.
 *
 * Software contains the Confidential Information of Nielsen and is subject to your relevant agreements with Nielsen.
 */


#import "NSDictionary+JSONString.h"

@implementation NSDictionary (JSONString)
- (NSString *)JSONString
{
    NSData *JSON = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return [[NSString alloc] initWithBytes:[JSON bytes] length:[JSON length] encoding:NSUTF8StringEncoding];
}
@end
