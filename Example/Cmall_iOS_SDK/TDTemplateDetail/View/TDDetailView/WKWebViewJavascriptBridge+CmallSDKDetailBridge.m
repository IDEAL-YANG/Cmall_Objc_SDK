//
//  WKWebViewJavascriptBridge+CmallSDKDetailBridge.m
//  Pods
//
//  Created by IDEAL YANG on 2017/4/19.
//
//

#import "WKWebViewJavascriptBridge+CmallSDKDetailBridge.h"
#import <CmallSDK/CmallSDK.h>

@implementation WKWebViewJavascriptBridge (CmallSDKDetailBridge)

- (void)cmall_callGlobalConfig:(WVJBHandler)handler{
    [self registerHandler:@"cmall_callGlobalConfig" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *params = @{@"imageServer":[kCmallImageBaseUrl stringByAppendingString:@"/"],@"cmallHost":kTudeSDKApiDomainBaseUrl,@"cmallThumbil":@"?imageView2/2/q/75",@"abbr":@"CN"};
        responseCallback(params);
    }];
}
- (void)cmall_needBackPreviewAndReLogin:(WVJBHandler)handler{
    [self registerHandler:@"cmall_needBackPreviewAndReLogin" handler:handler];
}

- (void)cmall_goToEditCutPieces:(WVJBHandler)handler{
    [self registerHandler:@"cmall_goToEditCutPieces" handler:handler];
}

- (void)cmall_acsToken:(id)data handler:(WVJBResponseCallback)handler{
    NSString *redirectUri = @"";
    NSString *noncStr = @"";
    
    NSDictionary *params = @{
                             @"redirectUri":redirectUri,
                             @"noncStr":noncStr
                             };
    
    [self callHandler:@"cmall_acsToken" data:[CmallSDK signedParamsWithNeedSignParams:params] responseCallback:handler];
}

- (void)cmall_getGoodsIdByModelClassId:(id)data handler:(WVJBResponseCallback)handler{
    
    NSString *imgUrlString = [data valueForKey:@"originalUrl"];
    NSNumber *modelClassId = [data valueForKey:@"modelClassId"];
    NSNumber *source = [data valueForKey:@"source"];
    NSString *token = [data valueForKey:@"token"];
    
    if (!imgUrlString || !modelClassId || !source || !token) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    imgUrlString = [imgUrlString copy];
    
    NSMutableDictionary *mtlParams = [NSMutableDictionary dictionaryWithDictionary:data];
    
    [mtlParams removeObjectForKey:@"originalUrl"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[CmallSDK signedParamsWithNeedSignParams:mtlParams]];
    [params setObject:imgUrlString forKey:@"originalUrl"];
    [params setObject:@0 forKey:@"tips"];
    
    [self callHandler:@"cmall_getGoodsIdByModelClassId" data:params responseCallback:handler];
}


- (void)cmall_getModelDesignList:(id)data handler:(WVJBResponseCallback)handler{
    
    NSNumber *productId = [data valueForKey:@"productId"];
    NSNumber *goodsId = [data valueForKey:@"goodsId"];
    NSString *token = [data valueForKey:@"token"];
    NSNumber *picWidth = [data valueForKey:@"picWidth"];
    NSNumber *picHeight = [data valueForKey:@"picHeight"];
    
    if (!productId || !goodsId || !token || !picWidth || !picHeight) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    
    
    NSDictionary *params = data;
    
    [self callHandler:@"cmall_getModelDesignList" data:[CmallSDK signedParamsWithNeedSignParams:params] responseCallback:handler];
}

- (void)cmall_getGoodsSkuList:(id)data handler:(WVJBResponseCallback)handler{
    
    NSNumber *modelClassId = [data valueForKey:@"modelClassId"];
    NSNumber *goodsId = [data valueForKey:@"goodsId"];
    NSString *productCode = [data valueForKey:@"productCode"];
    NSString *token = [data valueForKey:@"token"];
    
    if (!modelClassId || !goodsId || !productCode || !token) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    
    NSDictionary *params = data;
    
    [self callHandler:@"cmall_getGoodsSkuList" data:[CmallSDK signedParamsWithNeedSignParams:params] responseCallback:handler];
}

- (void)cmall_didGetImage:(id)data handler:(WVJBResponseCallback)handler{
    NSDictionary *params = @{};
    
    [self callHandler:@"cmall_didGetImage" data:params responseCallback:handler];
}
- (void)cmall_didSetInitImageSrc:(id)data handler:(WVJBResponseCallback)handler{
    NSString *base64String = data;
    
    [self callHandler:@"cmall_didSetInitImageSrc" data:base64String responseCallback:handler];
}
- (void)cmall_didCompleteEditCutPieces:(id)data handler:(WVJBResponseCallback)handler{
    NSDictionary *params = data;
    
    [self callHandler:@"cmall_didCompleteEditCutPieces" data:params responseCallback:handler];
}

- (void)cmall_switchModelGoodsDesign:(id)data handler:(WVJBResponseCallback)handler{
    
    NSNumber *source = [data valueForKey:@"source"];
    NSNumber *goodsId = [data valueForKey:@"goodsId"];
    NSString *token = [data valueForKey:@"token"];
    
    if (!source || !goodsId || !token) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    
    NSDictionary *params = data;
    
    [self callHandler:@"cmall_switchModelGoodsDesign" data:[CmallSDK signedParamsWithNeedSignParams:params] responseCallback:handler];
}
- (void)cmall_didSelectSku:(id)data handler:(WVJBResponseCallback)handler{

    NSString *skuType = [data valueForKey:@"skuType"];
    NSString *skuValue = [data valueForKey:@"skuValue"];
    
    if (!skuType || !skuValue) {
        DLog(@"%s:参数不正确",__FUNCTION__);
        return;
    }
    
    NSDictionary *params = data;
    
    [self callHandler:@"cmall_didSelectSku" data:params responseCallback:handler];
}

- (void)cmall_didAddToShopCart:(id)data handler:(WVJBResponseCallback)handler{
    NSDictionary *params = @{};
    
    [self callHandler:@"cmall_didAddToShopCart" data:params responseCallback:handler];
}


@end
