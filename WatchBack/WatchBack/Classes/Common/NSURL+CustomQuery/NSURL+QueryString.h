//
//  NSURL+QueryString.h
//  Watchback
//
//  Created by perk on 25/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (QueryString)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;
@end

NS_ASSUME_NONNULL_END
