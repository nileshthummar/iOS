/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2015 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

#import <Foundation/Foundation.h>
#import "ADBMediaHeartbeat.h"
#import "ADBMediaHeartbeat+Nielsen.h"
@import BrightcovePlayerSDK;
@protocol VideoPlayerDelegate <NSObject>

@required

- (NSTimeInterval)getCurrentPlaybackTime;
- (NSString *)typeOfAdPlayingInContentTime:(CMTime)time contentDuration:(CMTime)duration;
@end

@interface VideoAnalyticsProvider : NSOrderedSet <ADBMediaHeartbeatDelegate>

/**
 * Initialization
 */
- (instancetype)initWithPlayerDelegate:(id<VideoPlayerDelegate>)playerDelegate;

/**
 * Release the resources
 */

///////////
-(void)trackTimedMetaData:(NSString *)id3Tag;
- (void)onPlay:(id<BCOVPlaybackSession>)session;
- (void)onPause;
- (void)onMainVideoLoaded:(id<BCOVPlaybackSession>)session;
- (void)onMainVideoUnloaded;
- (void)onComplete;
- (void)onAdBreakStart:(id<BCOVPlaybackSession>)session didEnterAdSequence:(BCOVAdSequence *)adSequence;
- (void)onAdBreakComplete;
- (void)onAdStart:(id<BCOVPlaybackSession>)session didEnterAd:(BCOVAd *)ad;
- (void)onAdComplete;

- (void)onChapterStart:(id<BCOVPlaybackSession>)session;
- (void)onChapterComplete;
-(void)onError:(NSString *)errorId;
-(void)onBufferStart;
-(void)onBufferComplete;
- (void)onSeekStart;
- (void)onSeekComplete;
///////////
-(void)onChangedVideo;
- (void)onAdPause;
- (void)destroy;
@end
