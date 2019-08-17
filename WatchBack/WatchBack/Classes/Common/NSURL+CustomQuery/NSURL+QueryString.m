//
//  NSURL+QueryString.m
//  Watchback
//
//  Created by perk on 25/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "NSURL+QueryString.h"

@implementation NSURL (QueryString)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
}
@end
