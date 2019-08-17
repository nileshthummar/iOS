//
//  JLPerkPoint.h
//  Perk Search
//
//  Created by Nilesh on 2/5/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLPerkPoint : NSObject
@property(atomic,strong) NSNumber * availableperks;
@property(atomic,strong) NSNumber * availableTokens;
@property(atomic,strong) NSNumber * pendingperks;
@property(atomic,strong) NSNumber * lifetimeperks;
@property(atomic,strong) NSNumber * searchperks;
@property(atomic,strong) NSNumber * shoppingperks;
@property(atomic,strong) NSNumber * miscperks;
@property(atomic,strong) NSNumber * redeemedperks;
@property(atomic,strong) NSNumber * cancelledperks;
@property(atomic,strong) NSNumber * unread_notifications;
@end
