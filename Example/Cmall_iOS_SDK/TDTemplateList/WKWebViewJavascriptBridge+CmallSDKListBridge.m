//
//  WKWebViewJavascriptBridge+CmallSDKListBridge.m
//  Pods
//
//  Created by IDEAL YANG on 2017/4/19.
//
//

#import "WKWebViewJavascriptBridge+CmallSDKListBridge.h"
#import <CmallSDK/CmallSDK.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation WKWebViewJavascriptBridge (CmallSDKListBridge)


- (void)cmall_callGlobalConfig:(WVJBHandler)handler{
    
    [self registerHandler:@"cmall_callGlobalConfig" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *params = @{@"imageServer":[kThirdPartImageBaseUrl stringByAppendingString:@"/"] ,@"cmallHost":kTudeSDKApiDomainBaseUrl,@"cmallThumbil":@"?imageView2/2/q/75",@"abbr":@"CN"};
        responseCallback(params);
    }];
}

- (void)cmall_callCategories:(WVJBHandler)handler{
    [self registerHandler:@"cmall_callCategories" handler:handler];
}

- (void)cmall_callcurrentcategory:(WVJBHandler)handler{
    [self registerHandler:@"cmall_callcurrentcategory" handler:handler];
}

- (void)cmall_callgetuserimg:(id)data handler:(WVJBHandler)handler{
    
    NSString *picUrl = [data valueForKey:@"picUrl"];
    NSNumber *picWidth = [data valueForKey:@"picWidth"];
    NSNumber *picHeight = [data valueForKey:@"picHeight"];
    
    if (!picUrl || !picWidth || !picHeight) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[CmallSDK signedParamsWithNeedSignParams:data]];
    
    [params setValue:@([self checkNetworkConnection]) forKey:@"online"];
    
    [self registerHandler:@"cmall_callgetuserimg" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(params);
    }];
}

- (void)cmall_callrModel3d:(WVJBHandler)handler{
    [self registerHandler:@"cmall_callrModel3d" handler:handler];
}

- (void)cmall_needBackPreviewAndReLogin:(WVJBHandler)handler{
    [self registerHandler:@"cmall_needBackPreviewAndReLogin" handler:handler];
}

- (void)cmall_getcategory:(id)data handler:(WVJBResponseCallback)handler{
    
    NSNumber *index = [data valueForKey:@"index"];
    NSNumber *modelTypeId = [data valueForKey:@"modelTypeId"];
    
    if (!index || !modelTypeId) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    [self callHandler:@"cmall_getcategory" data:data responseCallback:handler];
}

- (BOOL)checkNetworkConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        DLog(@"Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
