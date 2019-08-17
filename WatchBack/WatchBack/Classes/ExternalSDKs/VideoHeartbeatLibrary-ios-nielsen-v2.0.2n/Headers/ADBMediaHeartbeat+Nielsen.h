/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2016 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 *
 **************************************************************************/

#import "ADBMediaHeartbeat.h"
#import "ADBMediaHeartbeatConfig.h"

#define kNielsenWebClose @"nielsen://close"

FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyNielsenContentMetadata;
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyNielsenAdMetadata;
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyNielsenChannelMetadata;

@interface ADBMediaHeartbeatConfig ()

/**
 * An Adobe provided unique key to configure Nielsen tracking. This is a required property.
 */
@property (nonatomic, strong) NSString * __nonnull nielsenConfigKey;

@end


@interface ADBMediaHeartbeat (ADBMediaHeartbeat_Nielsen)

/**
 * Configure the Nielsen SDK API with the required Application Info
 * This method should be called early in the app initialization life cycle and before any video playback begins.
 * @param appInfo Application info (appid, appname, sfcode etc) used to initialize Nielsen measurement.
 */
+ (void)nielsenConfigure:(nullable NSDictionary *)appInfo;

/**
 * Get the URL of the web page that is used for giving user a chance to
 * opt out from Nielsen measurement. Returns nil if there is no valid Nielsen tracker instance.
 */
+ (nonnull NSString *)nielsenOptOutURLString;

/**
 * Disable metering for the app due to user opt out.
 * Returns YES if the opt out is handled and NO otherwise.
 * @param optOut string to disable or enable
 */
+ (BOOL)nielsenUserOptOut:(nonnull NSString *)optOut;

/**
 * Enable / Disable Nielsen metering for the app.
 * @param disable YES to disable and NO to enable.
 */
+ (void)nielsenDisable:(BOOL)disable;

/**
 * Load metadata for Ad ocr tracking
 * @param metadata A dictionary of metadata that needs to be provided for ocr tracking
 * Ex: {@"ocrtag":url}
 */
- (void)nielsenLoadMetadata:(nonnull NSDictionary *)metadata;

@end
