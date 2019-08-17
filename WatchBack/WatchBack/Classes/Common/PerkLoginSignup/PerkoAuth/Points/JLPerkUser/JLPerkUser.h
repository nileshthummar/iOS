//
//  JLPerkUser.h
//  Perk Search
//
//  Created by Nilesh on 2/5/13.
//  Copyright (c) 2013 Nilesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLPerkPoint.h"
#define kPERK_ACCESS_TOKEN @"kPERK_ACCESS_TOKEN"
@interface JLPerkUser : NSObject<NSCoding>
@property(atomic,retain) NSString * userId;
@property(atomic,retain) NSString * email;
@property(atomic,retain) NSString * firstname;
@property(atomic,retain) NSString * lastname;
@property(atomic,retain) NSString * refreshToken;
@property(atomic,retain) NSString * accessToken;
@property(atomic,retain) NSNumber * expires_in;
@property(atomic,retain) NSString * clientLoginTime;
@property(atomic,retain) JLPerkPoint * perkPoint;
@property(atomic,retain) NSString * referralCode;
@property(atomic,retain) NSString * email_confirmed;
@property(atomic,retain) NSString * IsUserLogin;
@property(atomic,retain) NSString * loginType;
@property(atomic,retain) NSString * country;
@property(atomic,retain) NSString * sessionId;
@property(atomic,retain) NSNumber * session_videos_watched;
@property(atomic,retain) NSNumber * total_videos_watched;
@property(atomic,retain) NSNumber * video_views;
@property(atomic,retain) NSNumber * video_views_required;
@property(atomic,retain) NSNumber * next_level_percentage;
@property(atomic,retain) NSNumber * current_user_level;
@property(atomic,retain) NSNumber * next_user_level;
@property(atomic,retain) NSNumber * isOver21;
@property(atomic,retain) NSString * userUUID;
@property(atomic,retain) NSString * profile_image;
@property(atomic,retain) NSString * birthday;
@property(atomic,retain) NSString * gender;
@property(atomic,retain) NSString * email_verified_at;
@property(atomic,retain) NSString * phone_verified_at;
@property(atomic,retain) NSString * phoneno;
@end
