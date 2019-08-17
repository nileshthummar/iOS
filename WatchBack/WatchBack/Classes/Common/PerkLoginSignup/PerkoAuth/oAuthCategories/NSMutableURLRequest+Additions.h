//
//  NSMutableURLRequest+Additions.h
//  Perk
//
//  Created by Shanthi Vardhan on 13/11/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (Additions)

+ (id) defaultRequestWithURL:(NSString *) strUrl  param:(NSString *)strParam httpMethod:(NSString *)strHttpMethod;
+ (id) defaultRequestWithURLJSON:(NSString *) strUrl  param:(NSDictionary *)dictParam httpMethod:(NSString *)strHttpMethod;
+ (id) defaultRequestWithURL:(NSURL *) url;
+ (id) defaultRequestWithURLBR:(NSString *) strUrl  param:(NSString *)strParam httpMethod:(NSString *)strHttpMethod;
@end
