//
//  WKWebViewJavascriptBridge+CmallSDKDetailBridge.h
//  Pods
//
//  Created by IDEAL YANG on 2017/4/19.
//
//

#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@interface WKWebViewJavascriptBridge (CmallSDKDetailBridge)

/**
 给H5页面的配置信息。
 
 @param handler 回调处理
 */
- (void)cmall_callGlobalConfig:(WVJBHandler)handler;

/**
 加载过程中，H5中断，抛出异常
 
 @param handler 回调处理
 */
- (void)cmall_needBackPreviewAndReLogin:(WVJBHandler)handler;

/**
 点击模型某一区域，取回该区域的编辑原始信息，可以用来进入编辑界面
 
 @param handler 回调处理
 */
- (void)cmall_goToEditCutPieces:(WVJBHandler)handler;


/**
 点击模型某一区域，取回该区域的编辑原始信息，可以用来进入编辑界面
 
 @param data 参数 非必填
 @param handler 回调处理
 */
- (void)cmall_acsToken:(id)data handler:(WVJBResponseCallback)handler;

/**
 点击模型某一区域，取回该区域的编辑原始信息，可以用来进入编辑界面
 
 @param data 参数 必填 NSDictionary类型
                @{
                    @"modelClassId":modelClassId,
                    @"source":source,
                    @"token":self.token,
                    @"originalUrl":originalUrl
                }
 @param handler 回调处理
 */
- (void)cmall_getGoodsIdByModelClassId:(id)data handler:(WVJBResponseCallback)handler;

/**
 获取相关的其他设计列表，用于切换设计时使用
 
 @param data 参数 必填 NSDictionary类型
                 @{
                     @"productId":self.productId,
                     @"goodsId":self.goodsId,
                     @"token":self.token,
                     @"picWidth":self.autoImageWidth,
                     @"picHeight":self.autoImageHeight
                 }
 @param handler 回调处理
 */
- (void)cmall_getModelDesignList:(id)data handler:(WVJBResponseCallback)handler;

/**
 获取相关的sku列表，用于切换sku时使用，包含sku的层级结构。
 不同的商品，所包含的sku层级不同，主要有以下四类：
    1.没有sku的商品。
    2.只有一级sku的商品。
    3.只有二级sku的商品。
    4.同时有一二级sku的商品。
    注意：sku的级别由level字段决定。
 
 @param data 参数 必填 NSDictionary类型
                 @{
                     @"modelClassId":self.modelClassId,
                     @"token":self.token,
                     @"productCode":self.productId,
                     @"goodsId":self.goodsId
                 }
 @param handler 回调处理
 */
- (void)cmall_getGoodsSkuList:(id)data handler:(WVJBResponseCallback)handler;

/**
 获取模型的预览视图，可以用于在加购车弹出视图上的商品图使用，同时可以为下单商品在其订单列表里的图标使用。
 
 @param data 参数 非必填
 @param handler 回调处理
 */
- (void)cmall_didGetImage:(id)data handler:(WVJBResponseCallback)handler;

/**
 将编辑过得视图截图，以base64的形式给H5，以便在模型上预览。
 
 @param data 参数 必填 NSString类型，图片的base64字符串
 @param handler 回调处理
 */
- (void)cmall_didSetInitImageSrc:(id)data handler:(WVJBResponseCallback)handler;

/**
 将编辑过得区域信息，给H5。
 
 @param data 参数 必填 NSDictionary类型，区域编辑过的返回信息，直接把sdk的返回jsonData放入即可。
 @param handler 回调处理
 */
- (void)cmall_didCompleteEditCutPieces:(id)data handler:(WVJBResponseCallback)handler;


/**
 切换相关的其他设计
 
 @param data 参数 必填 NSDictionary类型
                 @{
                     @"token":self.token,
                     @"goodsId":design[@"goodsId"],
                     @"source":source
                 }
 @param handler 回调处理
 */
- (void)cmall_switchModelGoodsDesign:(id)data handler:(WVJBResponseCallback)handler;

/**
 切换sku，切换一级sku时使用。一级sku会影响模型变化
 
 @param data 参数 必填 NSDictionary类型
                 @{
                     @"skuType":sku[@"skuType"]?:@"",
                     @"skuValue":sku[@"modelShowValue"]?:@""
                 }
 @param handler 回调处理
 */
- (void)cmall_didSelectSku:(id)data handler:(WVJBResponseCallback)handler;

/**
 获取加入购物车或者下单时使用的modelJson数据
 
 @param data 参数 非必填
 @param handler 回调处理
 */
- (void)cmall_didAddToShopCart:(id)data handler:(WVJBResponseCallback)handler;


@end
