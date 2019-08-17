//
//  JLPerkPoint.m
//  Perk Search
//
//  Created by Nilesh on 2/5/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "JLPerkPoint.h"
#define availableperksKey @"availableperksKey"
#define availableTokensKey @"availableTokensKey"
#define pendingperksKey @"pendingperksKey"
#define lifetimeperksKey @"lifetimeperksKey"
#define searchperksKey @"searchperksKey"
#define shoppingperksKey @"shoppingperksKey"
#define miscperksKey @"miscperksKey"
#define redeemedperksKey @"redeemedperksKey"
#define cancelledperksKey @"cancelledperksKey"
#define unread_notificationsKey @"unread_notificationsKey"
#define store_notificationsKey @"store_notificationsKey"

@implementation JLPerkPoint
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.availableperks = [decoder decodeObjectForKey:availableperksKey];
        self.pendingperks = [decoder decodeObjectForKey:pendingperksKey];
        self.lifetimeperks =[decoder decodeObjectForKey:lifetimeperksKey];
        self.searchperks = [decoder decodeObjectForKey:searchperksKey];
        self.shoppingperks = [decoder decodeObjectForKey:shoppingperksKey];
        self.miscperks = [decoder decodeObjectForKey:miscperksKey];
        self.redeemedperks = [decoder decodeObjectForKey:redeemedperksKey];
        self.cancelledperks = [decoder decodeObjectForKey:cancelledperksKey];
        self.unread_notifications = [decoder decodeObjectForKey:unread_notificationsKey];
		self.availableTokens = [decoder decodeObjectForKey:availableTokensKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.availableperks forKey:availableperksKey];
    [encoder encodeObject:self.pendingperks forKey:pendingperksKey];
    [encoder encodeObject:self.lifetimeperks forKey:lifetimeperksKey];
    [encoder encodeObject:self.searchperks forKey:searchperksKey];
    [encoder encodeObject:self.shoppingperks forKey:shoppingperksKey];
    [encoder encodeObject:self.miscperks forKey:miscperksKey];
    [encoder encodeObject:self.redeemedperks forKey:redeemedperksKey];
    [encoder encodeObject:self.cancelledperks forKey:cancelledperksKey];
    [encoder encodeObject:self.unread_notifications forKey:unread_notificationsKey];
    [encoder encodeObject:self.availableTokens forKey:availableTokensKey];
    
}

@end
