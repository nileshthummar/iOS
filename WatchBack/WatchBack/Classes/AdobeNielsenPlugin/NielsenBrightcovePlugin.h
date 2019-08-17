/**
 * App SDK Plugin
 * Copyright (C) 2016, The Nielsen Company (US) LLC. All Rights Reserved.
 *
 * Software contains the Confidential Information of Nielsen and is subject to your relevant agreements with Nielsen.
 */

@import Foundation;
@import UIKit;

#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>

@class NielsenBrightcovePlugin;

@protocol NielsenBrightcoveDataSource<NSObject>
//- (NSDictionary *)contentMetadataForVideo:(BCOVVideo *)video;
//- (NSMutableDictionary *)adMetadataForVideo:(BCOVAd *)ad;
@optional
- (NSDictionary *)channelInfoForVideo:(BCOVVideo *)video;

@end
@protocol NielsenBrightcoveDelegate<NSObject>
-(void)didCompletePlaylist;
-(void)videoPlaying:(id<BCOVPlaybackSession>)session;
-(void)videoPlay;
-(void)didProgressTo:(long long )previousContentPosition position:(long long) position duration:(long long)duration;
-(void)didVideoReady:(id<BCOVPlaybackSession>)session;
@end

@interface NielsenBrightcovePlugin : NSObject<BCOVPlaybackSessionConsumer, BCOVPlaybackControllerDelegate>
@property (nonatomic, weak) id<NielsenBrightcoveDataSource> dataSource;
@property (nonatomic, weak) id<NielsenBrightcoveDelegate> delegate;
-(instancetype)init;
-(void)onError:(NSString *)errorId;
-(void)onChangedVideo:(NSDictionary *)currentVideoData;
-(void)onDestroy;
/*-(NSString *)optOutURLString;
-(BOOL)userOptOut:(NSString *)optOut;
-(BOOL)optOutStatus;
- (void)updateOTT:(id)ottInfo;
*/

@end
