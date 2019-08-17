/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2015 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */
#define kTag @"[watchback_NielsenAdobeMediaHeartbeat]"

#import "VideoAnalyticsProvider.h"
#import "ADBMediaHeartbeat.h"
#import "ADBMediaHeartbeatConfig.h"
#import <ComScore/ComScore.h>
#import "Constants.h"

@interface VideoAnalyticsProvider () <ADBMediaHeartbeatDelegate>

@property(weak, nonatomic) id<VideoPlayerDelegate> playerDelegate;

@end


@implementation VideoAnalyticsProvider
{
	ADBMediaHeartbeat *_mediaHeartbeat;
    SCORReducedRequirementsStreamingAnalytics *streamingAnalytics;
    BOOL m_bIsSessionValid;
   
}

@synthesize playerDelegate = _playerDelegate;

#pragma mark Initializer & dealloc

- (instancetype)initWithPlayerDelegate:(id<VideoPlayerDelegate>)playerDelegate
{
    
    if (self = [super init])
    {
        _playerDelegate = playerDelegate;
		
		// Media Heartbeat Initialization
        // Media Heartbeat Initialization
        ADBMediaHeartbeatConfig *config = [[ADBMediaHeartbeatConfig alloc] init];
        
        // other MediaHeartbeat config parameters
        config.trackingServer = @"nbcume.hb.omtrdc.net";
        config.channel = @"On-Domain";
        config.ovp = @"iOS";
        config.appVersion = [NSString stringWithFormat:@"%@",[BCOVPlayerSDKManager version]];
        config.playerName = @"Brightcove iOS Player";
        config.ssl = YES; //debug NO
        config.debugLogging = NO; //debug YES
        config.nielsenConfigKey = @"922e1d53d3e10abdde5cbea1b55459f5bacc65d4/55ba372b3336330017000bbf";
		_mediaHeartbeat = [[ADBMediaHeartbeat alloc] initWithDelegate:self config:config];
		if(kDebugLog)NSLog(@"%@ -> ADBMediaHeartbeat initWithDelegate",kTag);
      //  [self setupPlayerNotifications];
        //////
        //streamingAnalytics = [[SCORReducedRequirementsStreamingAnalytics alloc] init];
    }

    return self;
}

- (void)dealloc
{
    //if(kDebugLog)NSLog(@"%@ -> dealloc",kTag);
   // [self destroy];
}

- (ADBMediaObject *)getQoSObject
{
	return [ADBMediaHeartbeat createQoSObjectWithBitrate:500000 startupTime:2 fps:24 droppedFrames:10];
}

- (NSTimeInterval)getCurrentPlaybackTime
{
    NSTimeInterval timeInterval =[_playerDelegate getCurrentPlaybackTime];
   // if(kDebugLog)NSLog(@"%@ -> getCurrentPlaybackTime : %f",kTag,timeInterval);
    return timeInterval;
}


#pragma mark Public methods

- (void)destroy
{
    
    // Detach from the notification center.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (m_bIsSessionValid && _mediaHeartbeat) {
        [self onMainVideoUnloaded];
         _mediaHeartbeat = nil;
    }
   
    if(kDebugLog)NSLog(@"%@ -> _mediaHeartbeat = nil",kTag);
}
#pragma mark VideoPlayer notification handlers

- (void)onMainVideoLoaded:(id<BCOVPlaybackSession>)session
{
    if (m_bIsSessionValid) {
        [self onMainVideoUnloaded];
    }
    //streamingAnalytics = [[SCORReducedRequirementsStreamingAnalytics alloc] init];
    
    //if(kDebugLog)NSLog(@"%@ -> onMainVideoLoaded -> %@",session.video.properties);
    // detecting title, if not set by delegate
    NSString *videoname = [NSString stringWithFormat:@"%@",session.video.properties[kBCOVVideoPropertyKeyName]];
    
    NSString *videodescription = [session.video.properties objectForKey:@"description"];
    if (videodescription == nil || ![videodescription isKindOfClass:[NSString class]]) {
        videodescription = @"unknown";
    }
    // detecting assetid, if not set by delegate
    NSString *mediaId = [NSString stringWithFormat:@"%@",session.video.properties[kBCOVVideoPropertyKeyId]];
    
    NSString *length = @"-1";
    // if not live stream and time not set by delegator
    if (!CMTIME_IS_INDEFINITE(session.player.currentItem.duration)) {
        length = [NSString stringWithFormat:@"%f", CMTimeGetSeconds(session.player.currentItem.duration)];
    }
    ////
    ///////
    BOOL bLongform = FALSE;
    NSString *isfullepisode = @"";
    NSString *adloadtype = @"0";
    NSString *tv = @"false";
    NSString *datasource = @"CMS";
    NSString *mprovider = @"unknown";
    NSString *mshow = @"unknown";
  //  NSString *dayPart = @"";
    NSString *mepisodeNumber = @"unknown";
    NSString *mseasonNumber = @"unknown";
    NSString *mprogrammingType = @"unknown";
    NSString *madvertisingGenre = @"unknown";
    NSString *mguid = @"unknown";
    NSString *mstrGracenoteEpisodeID = @"unknown";
    NSDictionary *custom_fields = [session.video.properties objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *longform = [custom_fields objectForKey:@"longform"];
        if (longform != nil && [longform isKindOfClass:[NSString class]] && longform.length > 0) {
            bLongform = [longform boolValue];
        }
        NSString *provider = [custom_fields objectForKey:@"provider"];
        if (provider != nil && [provider isKindOfClass:[NSString class]] && provider.length > 0) {
            mprovider = provider;
        }
        NSString *show = [custom_fields objectForKey:@"show"];
        if (show != nil && [show isKindOfClass:[NSString class]] && show.length > 0) {
            mshow = show;
        }
        else{
            mshow = mprovider;
        }
        NSString *gracenote_ep_id = [custom_fields objectForKey:@"gracenote_ep_id"];
        if (gracenote_ep_id != nil && [gracenote_ep_id isKindOfClass:[NSString class]] && gracenote_ep_id.length > 0) {
            mstrGracenoteEpisodeID = gracenote_ep_id;
        }
        NSString *episodeNumber = [custom_fields objectForKey:@"episodeNumber"];
        if (episodeNumber != nil && [episodeNumber isKindOfClass:[NSString class]] && episodeNumber.length > 0) {
            mepisodeNumber = episodeNumber;
        }
        NSString *seasonNumber = [custom_fields objectForKey:@"seasonNumber"];
        if (seasonNumber != nil && [seasonNumber isKindOfClass:[NSString class]] && seasonNumber.length > 0) {
            mseasonNumber = seasonNumber;
        }
        NSString *programmingType = [custom_fields objectForKey:@"programmingType"];
        if (programmingType != nil && [programmingType isKindOfClass:[NSString class]] && programmingType.length > 0) {
            mprogrammingType = programmingType;
        }
        NSString *advertisingGenre = [custom_fields objectForKey:@"advertisingGenre"];
        if (advertisingGenre != nil && [advertisingGenre isKindOfClass:[NSString class]] && advertisingGenre.length > 0) {
            madvertisingGenre = advertisingGenre;
        }
        NSString *guid = [custom_fields objectForKey:@"guid"];
        if (guid != nil && [guid isKindOfClass:[NSString class]] && guid.length > 0) {
            mguid = guid;
        }
        else{
            mguid =[NSString stringWithFormat:@"%@",[session.video.properties objectForKey:@"id"]];
        }
        
    }
    if (bLongform) {
        isfullepisode = @"y";
        adloadtype = @"1";
        tv = @"true";
        datasource = @"ID3";
    }
    else{
         isfullepisode = @"n";
        adloadtype = @"2";
        tv = @"false";
        datasource = @"CMS";
    }
    NSString *airdate = [NSString stringWithFormat:@"%@",[session.video.properties objectForKey:@"published_at"]];
    if (airdate.length > 19) {
        airdate = [airdate substringToIndex:19];
    }
    
//    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
//    videoname = [[videoname componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
//    videodescription = [[videodescription componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
//    mshow = [[mshow componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
//    mprovider = [[mprovider componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
//    
    videoname =  [videoname stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    videodescription =   [videodescription stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    mshow =   [mshow stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    mprovider =   [mprovider stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    if(kDebugLog)NSLog(@"%@ -> title = %@",kTag,videoname);
    

	ADBMediaObject *mediaObject = [ADBMediaHeartbeat createMediaObjectWithName:videoname
																	   mediaId:mediaId
																		length:[length intValue]
                                                                    streamType:bLongform?ADBMediaHeartbeatStreamTypeLINEAR:ADBMediaHeartbeatStreamTypeVOD];
    
    
   
    
	[mediaObject setValue:@{@"clientid" : @"us-800148",
                            @"subbrand" : @"c05",
                            @"type": @"content",
							@"assetid": mediaId,
                            @"program": mshow,
							@"title": videoname,
                            @"length": length,
							@"isfullepisode":isfullepisode,
                            @"adloadtype":adloadtype,
                            @"adModel":adloadtype,
							@"airdate":airdate,
							@"tv":tv,
							@"datasource":datasource,
							@"crossId1":mstrGracenoteEpisodeID,
                            @"crossId2":mprovider,
                            @"hasAds":@"2",
                            @"segB":@"unknown",
                            @"segC":@"unknown"
                            
							}
                   forKey:ADBMediaObjectKeyNielsenContentMetadata];
	
	[mediaObject setValue:@{
							@"channelName": @"NBCUniversal Watchback Rewards",
							} forKey:ADBMediaObjectKeyNielsenChannelMetadata];

    NSDate * currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *videominute = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"hh:00"];
    NSString *videohour = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *videoday = [dateFormatter stringFromDate:currentDate];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *videodate = [dateFormatter stringFromDate:currentDate];
    
   // NSString *videodaypart = dayPart;
    NSString *videoepnumber = mepisodeNumber;
    NSString *videoseason = mseasonNumber;
    NSString *videocliptype = mprogrammingType;
    NSString *videosubcat1 = madvertisingGenre;
    
    NSArray *arrTags = [session.video.properties objectForKey:@"tags"];
    
    NSString *strTags = @"";
    if (arrTags != nil && [arrTags isKindOfClass:[NSArray class]]) {
        strTags = [arrTags componentsJoinedByString:@","];
    }
    
    
    [mediaObject setValue:@{@"videoprogram": mshow,
                            @"videotitle": videoname,
                          //@"videodaypart": videodaypart,
                            @"videominute": videominute,
                            @"videohour": videohour,
                            @"videoday": videoday,
                            @"videodate": videodate,
                            @"Videoplayertech": @"unknown",
                            @"videoplatform": @"iOS",
                            @"videonetwork": mprovider,
                            @"videoapp": @"NBCUniversal Watchback Rewards",
                            @"videoscreen": @"unknown",
                            @"videostatus": @"Unrestricted",
                            @"videocallsign": @"unknown",
                            @"videoepnumber": videoepnumber,
                            @"videoguid": mguid,
                            @"videoairdate": airdate,
                            @"videoseason": videoseason,
                            @"videocliptype": videocliptype,
                            @"videosubcat1": videosubcat1,
                            @"videosubcat2": strTags,
                            @"videodescription": videodescription
                            
                            } forKey:ADBMediaObjectKeyStandardVideoMetadata];
	
	[_mediaHeartbeat trackSessionStart:mediaObject
						  data:nil];
    m_bIsSessionValid = TRUE;
    if(kDebugLog)NSLog(@"%@ -> trackSessionStart",kTag);
    
    [self onPlay:session];
   
}

- (void)onMainVideoUnloaded
{
    if(kDebugLog)NSLog(@"%@ -> trackSessionEnd",kTag);
    [_mediaHeartbeat trackSessionEnd];
    m_bIsSessionValid = FALSE;
    
}

- (void)onPlay:(id<BCOVPlaybackSession>)session
{
    if(kDebugLog)NSLog(@"%@ -> onPlay",kTag);
    [_mediaHeartbeat trackPlay];
    
    /////
    NSString *title = [NSString stringWithFormat:@"%@",session.video.properties[kBCOVVideoPropertyKeyName]];
    
    NSString *airdate = [NSString stringWithFormat:@"%@",[session.video.properties objectForKey:@"published_at"]];
    if(airdate != nil && [airdate isKindOfClass:[NSString class]] && airdate.length >= 10){
        airdate = [airdate substringToIndex:10];
    }
    NSString *length = @"-1";
    // if not live stream and time not set by delegator
    if (!CMTIME_IS_INDEFINITE(session.player.currentItem.duration)) {
        length = [NSString stringWithFormat:@"%d",(int) CMTimeGetSeconds(session.player.currentItem.duration)*1000];
    }
    
    BOOL bLongform = FALSE;
    
    NSString *content_provider = @"*null";
    NSString *program = @"*null";
    
    NSString *episodeNumber = @"*null";
    NSString *seasonNumber = @"*null";
    NSString *advertisingGenre = @"*null";
    NSString *guid = @"*null";
    NSDictionary *custom_fields = [session.video.properties objectForKey:@"custom_fields"];
    if (custom_fields != nil && [custom_fields isKindOfClass:[NSDictionary class]]) {
        NSString *strTemp = [custom_fields objectForKey:@"longform"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            bLongform = [strTemp boolValue];
        }
        strTemp = [custom_fields objectForKey:@"provider"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            content_provider = strTemp;
        }
        strTemp = [custom_fields objectForKey:@"show"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            program = strTemp;
        }
        strTemp = [custom_fields objectForKey:@"episodeNumber"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            episodeNumber = strTemp;
        }
        strTemp = [custom_fields objectForKey:@"seasonNumber"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            seasonNumber = strTemp;
        }
        strTemp = [custom_fields objectForKey:@"advertisingGenre"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            advertisingGenre = strTemp;
        }
        
        strTemp = [custom_fields objectForKey:@"guid"];
        if (strTemp != nil && [strTemp isKindOfClass:[NSString class]] && strTemp.length > 0) {
            guid = strTemp;
        }
    }
    
    
    NSString *ns_st_ia = @"*null";
    NSString *ns_st_ce = @"*null";
    if (bLongform) {
        ns_st_ia = @"1";
        ns_st_ce = @"1";
    }
    else{
        ns_st_ia = @"0";
        ns_st_ce = @"0";
    }
    NSMutableDictionary *dictComScore = [[NSMutableDictionary alloc] init];
    [dictComScore setObject:content_provider forKey:@"ns_st_pu"];
    [dictComScore setObject:content_provider forKey:@"ns_st_st"];
    [dictComScore setObject:program forKey:@"ns_st_pr"];
    [dictComScore setObject:title forKey:@"ns_st_ep"];
    [dictComScore setObject:seasonNumber forKey:@"ns_st_sn"];
    [dictComScore setObject:episodeNumber forKey:@"ns_st_en"];
    [dictComScore setObject:advertisingGenre forKey:@"ns_st_ge"];
    [dictComScore setObject:guid forKey:@"ns_st_ci"];
    [dictComScore setObject:ns_st_ia forKey:@"ns_st_ia"];
    [dictComScore setObject:ns_st_ce forKey:@"ns_st_ce"];
    [dictComScore setObject:airdate forKey:@"ns_st_ddt"];
    [dictComScore setObject:airdate forKey:@"ns_st_tdt"];
    [dictComScore setObject:length forKey:@"ns_st_cl"];
    [dictComScore setObject:@"NBCUniversal Watchback Rewards" forKey:@"c3"];
    [dictComScore setObject:@"*null" forKey:@"c4"];
    [dictComScore setObject:program forKey:@"c6"];
    if (bLongform) {
        [streamingAnalytics playVideoContentPartWithMetadata:dictComScore andMediaType:SCORContentTypeLongFormOnDemand];
    }
    else{
        [streamingAnalytics playVideoContentPartWithMetadata:dictComScore andMediaType:SCORContentTypeShortFormOnDemand];
    }
    
    
    //////
}

- (void)onPause
{
    if(kDebugLog)NSLog(@"%@ -> onPause",kTag);
    [_mediaHeartbeat trackPause];
    [streamingAnalytics stop];
}

- (void)onSeekStart
{
    if(kDebugLog)NSLog(@"%@ -> onSeekStart",kTag);
	[_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventSeekStart mediaObject:nil data:nil];
}

- (void)onSeekComplete
{
    if(kDebugLog)NSLog(@"%@ -> onSeekComplete",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventSeekComplete mediaObject:nil data:nil];
}

- (void)onComplete
{
    if(kDebugLog)NSLog(@"%@ -> onComplete",kTag);
    [_mediaHeartbeat trackComplete];
    [streamingAnalytics stop];
}

- (void)onChapterStart:(id<BCOVPlaybackSession>)session
{
    if(kDebugLog)NSLog(@"%@ -> onChapterStart",kTag);
    // detecting title, if not set by delegate
    NSString *title = [NSString stringWithFormat:@"%@",session.video.properties[kBCOVVideoPropertyKeyName]];
    
    
    NSString *length = @"-1";
    // if not live stream and time not set by delegator
    if (!CMTIME_IS_INDEFINITE(session.player.currentItem.duration)) {
        length = [NSString stringWithFormat:@"%f", CMTimeGetSeconds(session.player.currentItem.duration)];
    }
    
    NSString *position = @"1";
    NSString *startTime = [NSString stringWithFormat:@"%f",[self getCurrentPlaybackTime]];
	id chapterInfo = [ADBMediaHeartbeat createChapterObjectWithName:title
														 position:[position doubleValue]
														   length:[length doubleValue]
														startTime:[startTime doubleValue]];
	
    
	[_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventChapterStart mediaObject:chapterInfo	data:nil];
}

- (void)onChapterComplete
{
    if(kDebugLog)NSLog(@"%@ -> onChapterComplete",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventChapterComplete mediaObject:nil data:nil];
    
    [streamingAnalytics stop];
}
- (void)onAdBreakStart:(id<BCOVPlaybackSession>)session didEnterAdSequence:(BCOVAdSequence *)adSequence{
     if(kDebugLog)NSLog(@"%@ -> onAdBreakStart",kTag);
    NSString *adType = @"midroll";
    if (!session.player || !session.player.currentItem) { // not initialized?
        adType= @"preroll";
    } else {
        //WORKAROUND: when the ad starts playing, the duration given by player.currentItem.duration
        // appears to be content + ad duration. This is incorrect (we may argue it's a buqg
        // on BCOV side) so here we simply subtract the ad duration from what's reported by
        // player.currentItem.duration to get the content duration. This is necessary to
        // correctly identify the position of ad (pre/mid/postroll)
        CMTime contentDuration = CMTIME_IS_INDEFINITE(session.player.currentItem.duration) ? session.player.currentItem.duration : CMTimeSubtract(session.player.currentItem.duration, adSequence.duration);
        adType= [_playerDelegate typeOfAdPlayingInContentTime:session.player.currentTime
                                              contentDuration:contentDuration];
    }
    NSString *position = @"1";
    NSString *startTime = [NSString stringWithFormat:@"%f",[self getCurrentPlaybackTime]];
    ADBMediaObject *adBreakInfo = [ADBMediaHeartbeat createAdBreakObjectWithName:adType
                                                                        position:[position doubleValue]
                                                                       startTime:[startTime doubleValue]];
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventAdBreakStart mediaObject:adBreakInfo data:nil];
}
- (void)onAdBreakComplete{
    if(kDebugLog)NSLog(@"%@ -> onAdBreakComplete",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventAdBreakComplete mediaObject:nil data:nil];
}
- (void)onAdStart:(id<BCOVPlaybackSession>)session didEnterAd:(BCOVAd *)ad
{
    
    if(kDebugLog)NSLog(@"%@ -> onAdStart",kTag);
    // detecting ad type:
    // * if the video or player is not initialized yet, consider it preroll
    // * otherwsie detect based on position (typeOfAdPlayingInContentTime:contentDuration)
    NSString *adType = @"midroll";
    if (!session.player || !session.player.currentItem) { // not initialized?
        adType= @"preroll";
    } else {
        //WORKAROUND: when the ad starts playing, the duration given by player.currentItem.duration
        // appears to be content + ad duration. This is incorrect (we may argue it's a buqg
        // on BCOV side) so here we simply subtract the ad duration from what's reported by
        // player.currentItem.duration to get the content duration. This is necessary to
        // correctly identify the position of ad (pre/mid/postroll)
        CMTime contentDuration = CMTIME_IS_INDEFINITE(session.player.currentItem.duration) ? session.player.currentItem.duration : CMTimeSubtract(session.player.currentItem.duration, ad.duration);
        adType= [_playerDelegate typeOfAdPlayingInContentTime:session.player.currentTime
                                                  contentDuration:contentDuration];
    }
   
    
    ////
    
    NSString *adName = [NSString stringWithFormat:@"%@",ad.title];
    NSString *adId = [NSString stringWithFormat:@"%@",ad.adId];
    NSString *indexPosition = @"1";
    
    
    float adDuration = CMTimeGetSeconds(ad.duration);
    
    /////
	
	
	ADBMediaObject *adInfo = [ADBMediaHeartbeat createAdObjectWithName:adName
												   adId:adId
											   position:[indexPosition doubleValue]
												 length:adDuration];
   
    [adInfo setValue:@{
                       @"assetid": adName,
                       @"type": adType,
                       @"length": [NSString stringWithFormat:@"%f",adDuration]
                       
                       } forKey:ADBMediaObjectKeyNielsenAdMetadata];
	
	
	[_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventAdStart mediaObject:adInfo data:nil];
    
    /////
    NSMutableDictionary *dictComScore = [[NSMutableDictionary alloc] init];
    [dictComScore setObject:[NSString stringWithFormat:@"%d",(int)adDuration*1000] forKey:@"ns_st_cl"];
    [streamingAnalytics playVideoAdvertisementWithMetadata:dictComScore andMediaType:SCORAdTypeLinearOnDemandPreRoll];
    
}

- (void)onAdComplete
{
    if(kDebugLog)NSLog(@"%@ -> onAdComplete",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventAdComplete mediaObject:nil data:nil];
    [streamingAnalytics stop];
}
-(void)onError:(NSString *)errorId{
    if(kDebugLog)NSLog(@"%@ -> onError",kTag);
    [_mediaHeartbeat trackError:errorId];
    [streamingAnalytics stop];
}
-(void)onBufferStart{
    if(kDebugLog)NSLog(@"%@ -> onBufferStart",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventBufferStart mediaObject:nil data:nil];
}
-(void)onBufferComplete{
    if(kDebugLog)NSLog(@"%@ -> onBufferComplete",kTag);
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventBufferComplete mediaObject:nil data:nil];
}

//#pragma mark - Private helper methods
//
//- (void)setupPlayerNotifications
//{
//
//
//   if(kDebugLog)NSLog(@"%@ -> setupPlayerNotifications");
//
//
//}


#pragma mark --
-(void)trackTimedMetaData:(NSString *)id3Tag{
    if(kDebugLog)NSLog(@"%@ -> trackTimedMetaData",kTag);
    ADBMediaObject *timeMetadataObject = [ADBMediaHeartbeat createTimedMetadataObject:id3Tag];
    [_mediaHeartbeat trackEvent:ADBMediaHeartbeatEventTimedMetadataUpdate mediaObject:timeMetadataObject    data:nil];
}
-(void)onChangedVideo{
    if (m_bIsSessionValid) {
        [self onMainVideoUnloaded];
    }
    streamingAnalytics = [[SCORReducedRequirementsStreamingAnalytics alloc] init];
}
- (void)onAdPause{
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        
        if(kDebugLog)NSLog(@"%@ Ad paused by pressing pause button",kTag);
    }
    else{
        if(kDebugLog)NSLog(@"%@ Ad paused by pressing Home button",kTag);
        [streamingAnalytics stop];
    }
}


@end
