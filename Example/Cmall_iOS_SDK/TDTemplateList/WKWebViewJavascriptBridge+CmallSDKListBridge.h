//
//  WKWebViewJavascriptBridge+CmallSDKListBridge.h
//  Pods
//
//  Created by IDEAL YANG on 2017/4/19.
//
//

#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@interface WKWebViewJavascriptBridge (CmallSDKListBridge)

/**
 给H5页面的配置信息。
 
 @param handler 回调处理
 */
- (void)cmall_callGlobalConfig:(WVJBHandler)handler;

/**
 获取分类标签
 
 @param handler 回调处理
 */
- (void)cmall_callCategories:(WVJBHandler)handler;

/**
 获取当前分类
 
 @param handler 回调处理
 */
- (void)cmall_callcurrentcategory:(WVJBHandler)handler;

/**
 给H5配置初始套版图片信息
 
 @param data 必填，NSDictionary
             @{
                 @"picUrl":@"",
                 @"picWidth":@34,
                 @"picHeight":@4565
             }
 @param handler 回调处理
 */
- (void)cmall_callgetuserimg:(id)data handler:(WVJBHandler)handler;

/**
 点选某一套版图，返回其productId和modelClassId，可用于看其详情
 
 @param handler 回调处理
 */
- (void)cmall_callrModel3d:(WVJBHandler)handler;

/**
 加载过程中，H5中断，抛出异常
 
 @param handler 回调处理
 */
- (void)cmall_needBackPreviewAndReLogin:(WVJBHandler)handler;

/**
 点击分类时，更改H5页面停留位置
 
 @param data 必填，NSDictionary
                @{
                     @"index":@(index),
                     @"modelTypeId":infoDic[@"modelTypeId"]
                 }
 @param handler 回调处理
 */
- (void)cmall_getcategory:(id)data handler:(WVJBResponseCallback)handler;


@end
