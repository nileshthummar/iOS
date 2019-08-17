//
//  WebServices.h
//  appredeem
//
//  Created by Nilesh on 4/22/16.
//
//

#import <Foundation/Foundation.h>

@interface WebServices : NSObject
+(WebServices *)sharedManager;

-(void)callAPI:(NSString *)strUrl params:(NSString *)params httpMethod:(NSString *)httpMethod check_for_refreshToken:(BOOL)check_for_refreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler;
-(void)callAPIJSON:(NSString *)strUrl params:(NSDictionary *)params httpMethod:(NSString *)httpMethod check_for_refreshToken:(BOOL)check_for_refreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler;
- (void) showAPIResponseError:(NSString *) errorMessage;
-(void)callAPIBR:(NSString *)strUrl params:(NSString *)params httpMethod:(NSString *)httpMethod checkforRefreshToken:(BOOL)checkforRefreshToken handler:(void (^) (BOOL success, NSDictionary *dict))handler;
@property(assign)BOOL m_bRetry;
@end
