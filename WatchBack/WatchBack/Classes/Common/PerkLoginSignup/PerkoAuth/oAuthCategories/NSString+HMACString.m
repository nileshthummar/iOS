//
//  NSString+HMACString.m
//  Perk
//
//  Created by Shanthi Vardhan on 03/03/14.
//  Copyright (c) 2014 Nilesh. All rights reserved.
//

#import "NSString+HMACString.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Constants.h"
@implementation NSString (HMACString)

- (NSString *) getHMACString {

    NSData *saltData = [HMAC_SALT dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    
    NSString *base64Hash = [self hexadecimalStringWithData:hash];
    
    
    return base64Hash;
}

- (NSString *)hexadecimalStringWithData:(NSData *) hash {
    
    const unsigned char *dataBuffer = (const unsigned char *)[hash bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [hash length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
