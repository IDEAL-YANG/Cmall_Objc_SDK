//
//  TDDIYWebViewController.h
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "CMBaseViewController.h"
#import "TDDIYWebView.h"

#import "WKWebViewJavascriptBridge.h"

@class TDDIYWebViewModel;
@interface TDDIYWebViewController : CMBaseViewController

/// WKWebView桥
@property (strong, nonatomic, readonly) WKWebViewJavascriptBridge *bridge;
/// viewModel
@property (nonatomic, strong, readonly) TDDIYWebViewModel *viewModel;
/// 自定义View
@property (strong, nonatomic, readonly) TDDIYWebView *diyWebView;


/// 自动套版的 详情试图控制器 初始方法，直接调用这个就行了
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewControllerWithProductId:(NSNumber*)productId
                                modelClassId:(NSNumber*)modelClassId
                          autoImageUrlString:(NSString*)autoImageUrlString;

/// 自动套版的 详情试图控制器 初始方法，直接调用这个就行了
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewControllerWithProductId:(NSNumber*)productId
                                     modelClassId:(NSNumber*)modelClassId
                               autoImageUrlString:(NSString*)autoImageUrlString
                                         oriWidth:(NSNumber*)oriWidth
                                        oriHeight:(NSNumber*)oriHeight;

/// 普通详情的 详情试图控制器 初始方法，直接调用这个就行了。在sdk里，禁用哟！
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewControllerWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId;




/// 隐藏添加购物车视图
- (void)cancelAdd;

/// 设置去购买sku选择视图
/// @param imageUrl 图片url
/// @param previewImage 本地图片
/// @param goodsName 商品名
/// @param currencySymbol 货币符号
/// @param price 价格
/// @param skuTypeName 展示的sku的类型名
/// @param skuNames 展示的sku列表的值
/// @param index 默认选中的小标
- (void)setupSkuListWithImageUrl:(NSString *)imageUrl
                    previewImage:(UIImage *)previewImage
                       goodsName:(NSString *)goodsName
                  currencySymbol:(NSString *)currencySymbol
                           price:(CGFloat)price
                     skuTypeName:(NSString *)skuTypeName
                        skuNames:(NSArray*)skuNames
                    currentIndex:(NSInteger)index;

- (void)setUpSkuPrice:(CGFloat)price;

- (void)loadWebViewFailed;

- (void)alertDataWithDict:(id)data bridge:(NSString*)bridge;

- (void)beginRequestData;


@end
