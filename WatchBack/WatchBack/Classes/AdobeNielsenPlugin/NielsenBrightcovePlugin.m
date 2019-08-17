/**
 * App SDK Plugin
 * Copyright (C) 2016, The Nielsen Company (US) LLC. All Rights Reserved.
 *
 * Software contains the Confidential Information of Nielsen and is subject to your relevant agreements with Nielsen.
 */
#define kTag @"[watchback_NielsenBrightcovePlugin]"

#import "NielsenBrightcovePlugin.h"
#import "NSDictionary+JSONString.h"
#import "ADBMediaHeartbeat+Nielsen.h"
#import "VideoAnalyticsProvider.h"
#import "Constants.h"
typedef enum{
    AD_STOP=0,
    AD_PAUSED,
    AD_BUFFERING,
    AD_PROGRESS
} adState;
typedef enum{
    ADBREAK_STOP=0,
    ADBREAK_PAUSED,
    ADBREAK_BUFFERING,
    ADBREAK_PROGRESS
} adBreakState;
@interface NielsenBrightcovePlugin ()<VideoPlayerDelegate>{
    adState mAdState;
    adBreakState mAdBreakState;
    BCOVAdSequence *m_adSequence;
}
@property (nonatomic, assign) long long previousContentPosition;
@property (nonatomic, assign) long long previousAdPosition;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL shouldLoadContentMetadata;
@property (nonatomic, assign) BOOL isFirstPlayheadAfterStopEvent;
@property (nonatomic, assign) BOOL isPlayingAd;
@property (nonatomic, assign) BOOL isPlayingPostroll;
@property (nonatomic, assign) BOOL contentEndCheck;
@property (nonatomic, assign) BOOL logsEnabled;
@property (nonatomic, assign) BOOL m_bIsLongform;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSTimer *stopTimer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSURL *contentURL;
@property (strong) VideoAnalyticsProvider *videoAnalyticsProvider;
@property (nonatomic, strong)id<BCOVPlaybackSession> m_session;
@end


@implementation NielsenBrightcovePlugin
- (instancetype)init
{
    if(kDebugLog)NSLog(@"Adobe -> init");
    if (self = [super init]) {
        self.shouldLoadContentMetadata = YES;        
        if (!self.videoAnalyticsProvider)
        {
            self.videoAnalyticsProvider = [[VideoAnalyticsProvider alloc] initWithPlayerDelegate:self];
        }
       
        
    }
    return self;
}

#pragma mark Content events
- (void)playbackController:(id<BCOVPlaybackController>)controller didCompletePlaylist:(id<NSFastEnumeration>)playlist{
    if(kDebugLog)NSLog(@"%@ playbackController",kTag);
    if([self.delegate respondsToSelector:@selector(didCompletePlaylist)]) [self.delegate didCompletePlaylist];
    
    [self.videoAnalyticsProvider onChapterComplete];
    [self.videoAnalyticsProvider onComplete];
    [self.videoAnalyticsProvider onMainVideoUnloaded];
    self.shouldLoadContentMetadata = YES;
}

- (void)playbackSession:(id<BCOVPlaybackSession>)session didReceiveLifecycleEvent:(BCOVPlaybackSessionLifecycleEvent *)lifecycleEvent
{
    _m_session = session;
    if(kDebugLog)NSLog(@"%@ playbackSession %@",kTag,lifecycleEvent.eventType);
    [self logMessageFormat:@"event %@", lifecycleEvent.eventType];

    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventPlay]) {
        if (self.stopTimer) {
            [self stop];
            [self clearPendingStop];
        }
        [self play:session];
        //[self.videoAnalyticsProvider onPlay];
        return;
    }
    
    // We delay the stop event as we don't consider content as stopped unless it's not receiving
    // playheads for at least 5 seconds.
    // For example, Brightcove SDK will call stop when an ad is about to play but this is incorrect as
    // we consider such events as continuos runnig
    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventPause]) {
       [self scheduleStop];
       //[self.videoAnalyticsProvider onPause];
        return;
    }
    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventReady])
    {
        if([self.delegate respondsToSelector:@selector(didVideoReady:)]) [self.delegate didVideoReady:session];
    }
    // content ending, failing, terminating, stop immideately
    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventEnd] ||
        [lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventFail] ||
        [lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventResumeFail] ||
        [lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventTerminate]) {
        [self stop];
        return;
    }
    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventPlaybackBufferEmpty]) {//Buffer start
        [self.videoAnalyticsProvider onBufferStart];
    }
    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventPlaybackLikelyToKeepUp]) { //Buffer End
        [self.videoAnalyticsProvider onBufferComplete];
    }
//    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventAdPause]) {
//
//    }
//    if ([lifecycleEvent.eventType isEqual:kBCOVPlaybackSessionLifecycleEventAdProgress]) {
//        
//    }
}

- (void)playbackSession:(id<BCOVPlaybackSession>)session didProgressTo:(NSTimeInterval)progress
{
    _m_session = session;
    if(kDebugLog)NSLog(@"%@ didProgressTo %f",kTag, progress);
    if (!self.isPlaying) {
        return;
    }
    
    if (self.isPlayingPostroll) {
        return;
    }
    
    [self loadContentMetadataForSession:session];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlaying:)]) {
        [self.delegate videoPlaying:session];
    }
    // if live stream, position is UTC, else seconds in video
    
    
    long long position = CMTIME_IS_INDEFINITE(session.player.currentItem.duration) ? [[NSDate date] timeIntervalSince1970] : progress;
    //////
    BOOL bLongform = FALSE;
    NSDictionary *custom_fields = [session.video.properties objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
    }
    self.m_bIsLongform = bLongform;
//    if (self.m_bIsLongform) {
//        position =[[NSDate date] timeIntervalSince1970];
//    }
    
    // is it value position?
    if (position < 0 || position == INFINITY || position == LLONG_MAX) {
        return;
    }

    // Sometimes SDK has to load content metadata while playing.
    // for example when content resums after ad was shown
    // After resuming content we need to call stop / loadmetadata
    // for content as soon as possible, that is why we include
    // the case when (position == self.previousContentPosition)
    

    // has it been a second?
    if ((position - self.previousContentPosition) == 1) {
        if (self.isFirstPlayheadAfterStopEvent) {
            self.isFirstPlayheadAfterStopEvent = NO;
        } else {
            [self clearPendingStop];
        }
        
     //   [self.api playheadPosition:position];
    }
    [self logMessageFormat:@"content playheadPosition %lld", position];
    
    if (llabs(position-self.previousContentPosition) > 3) {
        [self.videoAnalyticsProvider onSeekStart];
        [self.videoAnalyticsProvider onSeekComplete];
    }
    
    if (self.delegate) {
        long long duration = 0;
        if (!CMTIME_IS_INDEFINITE(session.player.currentItem.duration)) {
            duration = CMTimeGetSeconds(session.player.currentItem.duration);
        }        
        [self.delegate didProgressTo:self.previousContentPosition position:position duration:duration];
    }
    self.previousContentPosition = position;
}

- (void)play:(id<BCOVPlaybackSession>)session
{
    //[self loadContentMetadataForSession:session];
    _m_session = session;
    if(kDebugLog)NSLog(@"%@ play",kTag);
    [self clearPendingStop]; // no
    [self stop];
    if (self.delegate) {
        [self.delegate videoPlay];
    }
    if (self.isPlaying) {
        if(kDebugLog)NSLog(@"%@ isPlaying",kTag);
        return;
    }
    
    self.isPlaying = YES;
    self.contentEndCheck = YES;
    
    
    self.contentURL = session.source.url;
    
    //Adding observer to detect content end
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    // register observers for id3 metadata
    [self registerObserversForPlayer:session.player];
    
    // send play event - ask delegate for channel name
    NSString *channelInfo = [self.dataSource respondsToSelector:@selector(channelInfoForVideo:)] ?
    [self.dataSource channelInfoForVideo:session.video].JSONString: @"{}";
    
    
    [self logMessageFormat:@"play %@", channelInfo];
   // [self.api play:channelInfo];
    [self.videoAnalyticsProvider onPlay:session];
    
    // load metadata
    
  //  [self loadContentMetadataForSession:session];
    
    // reset content position
    
  //  _previousContentPosition = 0;
    
   
}

-(void)playerItemDidReachEnd:(NSNotification *)Notification
{
    if(kDebugLog)NSLog(@"%@ playerItemDidReachEnd",kTag);
    AVPlayerItem *item = ((AVPlayerItem *)Notification.object);
    AVURLAsset *urlAsset = (AVURLAsset *)item.asset;

    [self logMessageFormat:@"AVURLAsset of NSNotification %@", urlAsset.URL];
    //Adding check to see if player Item Did reach end of the content or ad
    
    if ([urlAsset.URL isEqual:self.contentURL]) {
        [self endNielsenMeasurement];
    }

}
- (void)loadContentMetadataForSession:(id<BCOVPlaybackSession>)session
{
   
    if (self.shouldLoadContentMetadata)
    {
        if(kDebugLog)NSLog(@"%@ loadContentMetadataForSession",kTag);
        self.shouldLoadContentMetadata = NO;
        _previousContentPosition = 0;
        [self.videoAnalyticsProvider onMainVideoLoaded:session];
        [self.videoAnalyticsProvider onChapterStart:session];
    }
    
}

- (void)stop
{
    if(kDebugLog)NSLog(@"%@ stop",kTag);
    if (!self.isPlaying || self.isPlayingAd) {
        return;
    }
    
    self.isPlayingPostroll = NO;
    
    self.isPlaying = NO;
    
    [self unregisterObservers];
    
    [self clearPendingStop]; // no
    
    [self logMessageFormat:@"stop"];
  //  [self.api stop];
    
    [self.videoAnalyticsProvider onPause];
    
}

- (void)registerObserversForPlayer:(AVPlayer *)player
{
    if(kDebugLog)NSLog(@"%@ registerObserversForPlayer",kTag);
    if (self.player) {
        return;
    }
    
    [player addObserver:self
             forKeyPath:@"currentItem.timedMetadata"
                options:NSKeyValueObservingOptionNew
                context:nil];
    
    self.player = player;
}

- (void)unregisterObservers
{
    if(kDebugLog)NSLog(@"%@ unregisterObservers",kTag);
    if (!self.player) {
        return;
    }
    
    [self.player removeObserver:self
                     forKeyPath:@"currentItem.timedMetadata"
                        context:nil];
    
    self.player = nil;
}


# pragma mark ID3 extraction

- (void)observeValueForKeyPath:(NSString*)path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if(kDebugLog)NSLog(@"%@ observeValueForKeyPath",kTag);
    if (!self.player) {
        return;
    }
    
    if ([path isEqualToString:@"currentItem.timedMetadata"]) {
        NSArray *metadata = change[NSKeyValueChangeNewKey];
        if (!metadata || ![metadata isKindOfClass:[NSArray class]]) {
            return;
        }
        
        for (AVMetadataItem *item in metadata) {
            [self handleTimedMetadata:item];
        }
    }
}

- (void)handleTimedMetadata:(AVMetadataItem*)timedMetadata
{
    if(kDebugLog)NSLog(@"%@ handleTimedMetadata",kTag);
    id extraAttributeType = [timedMetadata extraAttributes];
    
    NSString *extraString= nil;
    if ([extraAttributeType isKindOfClass:[NSDictionary class]]) {
        extraString = [extraAttributeType valueForKey:@"info"];
    } else if ([extraAttributeType isKindOfClass:[NSString class]]){
        extraString = extraAttributeType;
    }
    
    if ([(NSString *)[timedMetadata key] isEqualToString:@"PRIV"] &&
        [extraString rangeOfString:@"www.nielsen.com"].length > 0 &&
        [[timedMetadata value] isKindOfClass:[NSData class]])
    {
        [self logMessageFormat:@"sendID3: %@", extraString];
       // [self.api sendID3:extraString];
     //   [_playerPlugin trackTimedMetadata:id3Tag];
       // [_playerPlugin trackTimedMetadata:extraString];
        if(_m_session)[self loadContentMetadataForSession:_m_session];
        [self.videoAnalyticsProvider trackTimedMetaData:extraString];
    }
}

#pragma mark ad events
- (void)playbackSession:(id<BCOVPlaybackSession>)session didEnterAdSequence:(BCOVAdSequence *)adSequence{
    if(kDebugLog)NSLog(@"%@ didEnterAdSequence",kTag);
    m_adSequence = adSequence;
    //[self loadContentMetadataForSession:session];
    //[self.videoAnalyticsProvider onAdBreakStart:session didEnterAdSequence:adSequence];
}
- (void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didEnterAd:(BCOVAd *)ad
{
    if(kDebugLog)NSLog(@"%@ didEnterAd",kTag);
    // just in case play wasn't call before that
   // [self play:session];
    
    self.isPlayingAd = YES; 
    
    
    [self logMessageFormat:@"stop: entering Ad"];
    _previousAdPosition = 0; // reset playhead position
    //[self.videoAnalyticsProvider onAdStart:session didEnterAd:ad];
}

-(void)playbackSession:(id<BCOVPlaybackSession>)session didExitAd:(BCOVAd *)ad
{
    if(kDebugLog)NSLog(@"%@ didExitAd",kTag);
    self.isPlayingAd = NO;
    if (mAdState == AD_PROGRESS) {
        [self.videoAnalyticsProvider onAdComplete];
    }
    mAdState = AD_STOP;
    
}

-(void)playbackSession:(id<BCOVPlaybackSession>)session didExitAdSequence:(BCOVAdSequence *)adSequence
{
    if(kDebugLog)NSLog(@"%@ didExitAdSequence",kTag);
    // check playbackSession:didProgressTo for explanation
    if (mAdBreakState == ADBREAK_PROGRESS) {
        [self.videoAnalyticsProvider onAdBreakComplete];
    }
    mAdBreakState = ADBREAK_STOP;
    
    if (self.isPlaying) {
        [session.player play];
    }
}
- (void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didPauseAd:(BCOVAd *)ad{
    if(kDebugLog)NSLog(@"%@ didPauseAd",kTag);
    [self.videoAnalyticsProvider onAdPause];
}

- (void)playbackSession:(id<BCOVPlaybackSession>)session ad:(BCOVAd *)ad didProgressTo:(NSTimeInterval)progress
{
    
    if(kDebugLog)NSLog(@"%@ didProgressTo Ad %f",kTag, progress);
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlaying:)]) {
        [self.delegate videoPlaying:session];
    }
    if (!self.isPlayingAd) {
        return;
    }
    [self loadContentMetadataForSession:session];
    if (mAdBreakState != ADBREAK_PROGRESS) {
        mAdBreakState = ADBREAK_PROGRESS;
        //////
        
        [self.videoAnalyticsProvider onAdBreakStart:session didEnterAdSequence:m_adSequence];
    }
    
    if (mAdState != AD_PROGRESS) {
        mAdState = AD_PROGRESS;
        //////
        [self.videoAnalyticsProvider onAdStart:session didEnterAd:ad];
    }
    
    
    long long position = (long long)progress;
    if (position < 0 || position == INFINITY || position == LLONG_MAX) {
        return;
    }
    
    // has it been a second
    if ((position - self.previousAdPosition) == 1) {
        [self clearPendingStop]; // no
        
        [self logMessageFormat:@"ad playheadPosition %lld", position];
      //  [self.api playheadPosition:position];
    }
    
    self.previousAdPosition = position;
}
// Detects ad type (pre/mid/postroll) based on time the ad is playing. Takes
// content playing time and duration as arguments.
// - if an ad starts playing before video or within 3 seconds* of playing time - it's a preroll
// - if an ad starts playing after a video or within last 3 seconds of playing time - it's postroll
// - anything in between is midroll
// - live steam has no postroll
// * why 3 seconds? it's just a grace period as ads sometime start playing near the end,
// and we don't want them identified as midroll, when there's just a second left.
- (NSString *)typeOfAdPlayingInContentTime:(CMTime)time contentDuration:(CMTime)duration
{
    if(kDebugLog)NSLog(@"%@ typeOfAdPlayingInContentTime",kTag);
    long timeSec = CMTimeGetSeconds(time);
    // [self logMessageFormat:@"timeSec: %ld duration: %f", timeSec, CMTimeGetSeconds(duration)];
    
    if (timeSec < 3) {
        return @"preroll";
    } else if (CMTIME_IS_INDEFINITE(duration)) { // live stream
        return @"midroll";
    } else if (timeSec >= CMTimeGetSeconds(duration) - 3) {
        self.isPlayingPostroll = YES;
        if(self.contentEndCheck){
            [self endNielsenMeasurement];
        }
        self.contentEndCheck = NO;
        return @"postroll";
    }
    return @"midroll";
}
# pragma mark utils
/*
-(NSString *)optOutURLString
{
    return self.api.optOutURL;
}

-(BOOL)userOptOut:(NSString *)optOut
{
    return [self.api userOptOut:optOut];
}

-(BOOL)optOutStatus
{
    return self.api.optOutStatus;
}

- (void)updateOTT:(id)ottInfo
{
    return [self.api updateOTT:ottInfo];
}
*/
- (void)dealloc
{
    if(kDebugLog)NSLog(@"%@ dealloc",kTag);
    // call any pendings stop
    if (self.stopTimer) {
        [self stop];
        [self clearPendingStop];
    }
    
    [self unregisterObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)scheduleStop
{
    if(kDebugLog)NSLog(@"%@ scheduleStop",kTag);
    self.isFirstPlayheadAfterStopEvent = YES;
    if([self.stopTimer isValid]){
        [self.stopTimer invalidate];
    }
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(stop)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)clearPendingStop
{
  //  if(kDebugLog)NSLog(@"Adobe -> BC clearPendingStop");
    if (self.stopTimer) {
        [self.stopTimer invalidate];
        self.stopTimer = nil;
        [self logMessageFormat:@"cleared pending stop"];
    }
}

-(void)endNielsenMeasurement
{
    if(kDebugLog)NSLog(@"%@ endNielsenMeasurement",kTag);
    [self logMessageFormat:@"end"];
   // [self.api end];
}

// method takes variable numbers of arguments, the format string and the variable arguments are expected
- (void)logMessageFormat:(NSString *)format, ...
{
   // if(kDebugLog)NSLog(@"Adobe -> BC logMessageFormat");
    if (self.logsEnabled)
    {
        va_list argumentList;
        va_start(argumentList, format);

        NSString *message = [[NSString alloc] initWithFormat:format arguments:argumentList];
        if(kDebugLog)NSLog(@"%@: %@",kTag, message);

        va_end(argumentList);
    }
}

#pragma mark -- delegate
- (NSTimeInterval)getCurrentPlaybackTime{
//    if (self.m_bIsLongform) {
//        return [[NSDate date] timeIntervalSince1970];
//    }
    return self.previousContentPosition;
}
-(void)onError:(NSString *)errorId{
    if(kDebugLog)NSLog(@"%@ onError",kTag);
    [self.videoAnalyticsProvider onError:errorId];
}
-(void)onChangedVideo:(NSDictionary *) currentVideoData{
  //  self.mCurrentVideoData = currentVideoData;
     [self.videoAnalyticsProvider onChangedVideo];
    _previousContentPosition = 0;
    self.shouldLoadContentMetadata = YES;
}
-(void)onDestroy{
    if (self.videoAnalyticsProvider) {
        [self.videoAnalyticsProvider destroy];
    }
}
@end
