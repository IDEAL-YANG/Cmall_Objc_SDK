//
//  CMNetworkManage.h
//  CMDIYSDK
//
//  Created by Moyun on 16/8/23.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CMCompletioBlock)(NSDictionary *dic);
typedef void (^CMSuccessBlock)(NSDictionary *data);
typedef void (^CMFailureBlock)(NSError *error);

@interface CMNetworkManage : NSObject<NSURLSessionDelegate>

+ (CMNetworkManage *)sharedInstance;

- (void)getForSDKWithUrlString:(NSString *)urlString
                  parameters:(NSDictionary *)parameters
                     success:(CMCompletioBlock)success
                     failure:(CMFailureBlock)failure;

- (void)postForSDKUseWithUrlString:(NSString *)url parameters:(id)parameters success:(CMCompletioBlock)successBlock failure:(CMFailureBlock)failureBlock;

@end

