//
//  LFCache.h
//  Watchback
//
//  Created by Nilesh on 11/13/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFCache : NSObject
{
    
}
+(LFCache *)sharedManager;
-(void )setCapacity:(int)capacity;
-(NSString *) get:(NSString *) key;
-(void) set:(NSString *)key value:(NSString *)value;
-(void) remove:(NSString *) key;
-(void)saveData;
-(void)resetData;
@end

NS_ASSUME_NONNULL_END
