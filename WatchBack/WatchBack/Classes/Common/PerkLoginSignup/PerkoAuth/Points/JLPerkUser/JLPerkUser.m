//
//  JLPerkUser.m
//  Perk Search
//
//  Created by Nilesh on 2/5/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import "JLPerkUser.h"

@implementation JLPerkUser

#define userIdKey @"userIdKey"
#define emailKey @"emailKey"
#define firstnameKey @"firstnameKey"
#define lastnameKey @"lastnameKey"
#define passwordKey @"passwordKey"
#define refreshTokenKey @"refreshTokenKey"
#define accessTokenKey @"accessTokenKey"
#define perkPointKey @"perkPointKey"
#define IsUserLoginKey @"IsUserLoginKey"
#define loginTypeKey @"type"
#define uCountry @"uCountry"
#define sessionIdKey @"sessionIdKey"
#define session_videos_watchedKey @"session_videos_watchedKey"
#define total_videos_watchedKey @"total_videos_watchedKey"
#define video_viewsKey @"video_viewsKey"
#define video_views_requiredKey @"video_views_requiredKey"
#define next_level_percentage_key @"next_level_percentage_key"
#define current_user_level_key @"current_user_level_key"
#define next_user_level_key @"next_user_level_key"
#define kReferralCodeKey @"kReferralCodeKey"
#define kemail_confirmedKey @"kemail_confirmedKey"
#define kExpiresInKey @"kExpiresInKey"
#define kClientLoginTimeKey @"kClientLoginTimeKey"
#define kIsOver21 @"kIsOver21"
#define kuserUUID @"kuserUUID"
#define kprofile_image @"kprofile_image"
#define genderKey @"genderKey"
#define birthdayKey @"birthdayKey"
#define phoneverifyKey @"phoneverifyKey"
#define emailverifyKey @"emailverifyKey"
#define phonenoKey @"phonenoKey"

-(id) init{
    if(self=[super init]){
        _perkPoint = [[JLPerkPoint alloc] init];
        return self;
    }
    return nil;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.userId = [decoder decodeObjectForKey:userIdKey];
        self.email = [decoder decodeObjectForKey:emailKey];
        self.firstname =[decoder decodeObjectForKey:firstnameKey];
        self.lastname = [decoder decodeObjectForKey:lastnameKey];
        self.refreshToken = [decoder decodeObjectForKey:refreshTokenKey];
        self.accessToken = [decoder decodeObjectForKey:accessTokenKey];
        self.perkPoint = [decoder decodeObjectForKey:perkPointKey];
        self.IsUserLogin = [decoder decodeObjectForKey:IsUserLoginKey];
        self.loginType = [decoder decodeObjectForKey:loginTypeKey];
        self.country = [decoder decodeObjectForKey:uCountry];
        self.sessionId = [decoder decodeObjectForKey:sessionIdKey];
        self.session_videos_watched = [decoder decodeObjectForKey:session_videos_watchedKey];
        self.total_videos_watched = [decoder decodeObjectForKey:total_videos_watchedKey];
        self.video_views = [decoder decodeObjectForKey:video_viewsKey];
        self.video_views_required = [decoder decodeObjectForKey:video_views_requiredKey];
        self.next_level_percentage = [decoder decodeObjectForKey:next_level_percentage_key];
        self.current_user_level = [decoder decodeObjectForKey:current_user_level_key];
        self.next_user_level = [decoder decodeObjectForKey:next_user_level_key];
        self.referralCode = [decoder decodeObjectForKey:kReferralCodeKey];
        self.email_confirmed = [decoder decodeObjectForKey:kemail_confirmedKey];
		self.expires_in = [decoder decodeObjectForKey:kExpiresInKey];
		self.clientLoginTime = [decoder decodeObjectForKey:kClientLoginTimeKey];
		self.isOver21 = [decoder decodeObjectForKey:kIsOver21];
        self.userUUID = [decoder decodeObjectForKey:kuserUUID];
        self.profile_image = [decoder decodeObjectForKey:kprofile_image];
        self.birthday =[decoder decodeObjectForKey:birthdayKey];
        self.gender =[decoder decodeObjectForKey:genderKey];
        self.phone_verified_at = [decoder decodeObjectForKey:phoneverifyKey];
        self.email_verified_at = [decoder decodeObjectForKey:emailverifyKey];
        self.phoneno = [decoder decodeObjectForKey:phonenoKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	
    [encoder encodeObject:self.userId forKey:userIdKey];
    [encoder encodeObject:self.email forKey:emailKey];
    [encoder encodeObject:self.firstname forKey:firstnameKey];
    [encoder encodeObject:self.lastname forKey:lastnameKey];
    [encoder encodeObject:self.refreshToken forKey:refreshTokenKey];
    [encoder encodeObject:self.accessToken forKey:accessTokenKey];
    [encoder encodeObject:self.perkPoint forKey:perkPointKey];
    [encoder encodeObject:self.IsUserLogin forKey:IsUserLoginKey];
    [encoder encodeObject:self.loginType forKey:loginTypeKey];
    [encoder encodeObject:self.country forKey:uCountry];
    [encoder encodeObject:self.sessionId forKey:sessionIdKey];
    [encoder encodeObject:self.session_videos_watched forKey:session_videos_watchedKey];
    [encoder encodeObject:self.total_videos_watched forKey:total_videos_watchedKey];
    [encoder encodeObject:self.video_views forKey:video_viewsKey];
    [encoder encodeObject:self.video_views_required forKey:video_views_requiredKey];
    [encoder encodeObject:self.next_level_percentage forKey:next_level_percentage_key];
    [encoder encodeObject:self.current_user_level forKey:current_user_level_key];
    [encoder encodeObject:self.next_user_level forKey:next_user_level_key];
    [encoder encodeObject:self.referralCode forKey:kReferralCodeKey];
    [encoder encodeObject:self.email_confirmed forKey:kemail_confirmedKey];
	[encoder encodeObject:self.expires_in forKey:kExpiresInKey];
	[encoder encodeObject:self.clientLoginTime forKey:kClientLoginTimeKey];
	[encoder encodeObject:self.isOver21 forKey:kIsOver21];
    [encoder encodeObject:self.userUUID forKey:kuserUUID];
    [encoder encodeObject:self.profile_image forKey:kprofile_image];
    [encoder encodeObject:self.birthday forKey:birthdayKey];
    [encoder encodeObject:self.gender forKey:genderKey];
    [encoder encodeObject:self.phone_verified_at forKey:phoneverifyKey];
    [encoder encodeObject:self.email_verified_at forKey:emailverifyKey];
    [encoder encodeObject:self.phoneno forKey:phonenoKey];
}


@end
