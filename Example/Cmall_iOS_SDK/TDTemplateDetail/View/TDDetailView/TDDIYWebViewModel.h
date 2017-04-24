//
//  TDDIYWebViewModel.h
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "CMBaseViewModel.h"
#import "TDDIYWebViewController.h"
#import "NSString+CMJSONConvert.h"
#import "UIImageView+CMUIActivityIndicatorForSDWebImage.h"

@interface TDDIYWebViewModel : CMBaseViewModel

/// viewModel对相应vc的弱引用
@property (weak, nonatomic) TDDIYWebViewController *webVC;

/// 详情图片url
@property (nonatomic, strong) NSString *detailImageUrlString;
/** 详情图片宽度 */
@property (nonatomic, assign) CGFloat detail_Width;
/** 详情图片高度 */
@property (nonatomic, assign) CGFloat detail_Height;

/** 购买的skuCode */
@property (nonatomic, copy)NSString *purchaseSkuCode;
/** 购买的数量 */
@property (nonatomic, assign) NSUInteger goodsCount;


/** 设计分了组的列表 */
@property (nonatomic, strong) NSArray *designGroupList;
/** 设计每一组的列表 */
@property (nonatomic, strong) NSArray *designList;
/** 一级sku列表 */
@property (nonatomic, strong) NSArray *skuList;
/** 二级sku列表 */
@property (nonatomic, strong) NSArray *subSkuList;

/** 设计分了组的选中下标 */
@property (nonatomic, assign) NSInteger designGroupSelected;
/** 设计每一组的选中下标 */
@property (nonatomic, assign) NSInteger designSelected;
/** 一级sku选中下标 */
@property (nonatomic, assign) NSInteger skuSelected;
/** 二级sku选中下标 */
@property (nonatomic, assign) NSInteger subSkuSelected;


/// 可以用来提示价格显示
@property (nonatomic, copy) NSString *showPriceString;

/// 标识模型正在加载中，可能是模型初始加载，也可能是切换一级sku导致的模型加载
@property (nonatomic, assign) BOOL modelLoading;

@property (nonatomic, strong) NSNumber *autoImageWidth;
@property (nonatomic, strong) NSNumber *autoImageHeight;


/// 自动套版的viewModel初始方法，直接调用这个就行了
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewModelWithProductId:(NSNumber*)productId
                                modelClassId:(NSNumber*)modelClassId
                          autoImageUrlString:(NSString*)autoImageUrlString;

/// 自动套版的viewModel初始方法，直接调用这个就行了
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewModelWithProductId:(NSNumber*)productId
                                modelClassId:(NSNumber*)modelClassId
                          autoImageUrlString:(NSString*)autoImageUrlString
                                    oriWidth:(NSNumber*)oriWidth
                                   oriHeight:(NSNumber*)oriHeight;

/// 普通详情的viewModel初始方法，直接调用这个就行了
/// - 特别注意，参数都是必填项
+ (instancetype)diyWebViewModelWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId;

/// viewModel初始方法.
/// @param goodsId 商品id。自动套版时，该字段为@0。
/// @param sourceType 数据来源。自动套版时，该字段为 TDDIYSourceTypeGoodsList = 1。
/// @param productId 产品id。
/// @param modelClassId 故名思意，模型分类id。
/// @param autoImageUrlString 故名思意，自动套版时的源图url。
/// @param oriWidth 故名思意，自动套版时的源图oriWidth。
/// @param oriHeight 故名思意，自动套版时的源图oriHeight。
+ (instancetype)diyWebViewModelWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId
                        autoImageUrlString:(NSString*)autoImageUrlString
                                  oriWidth:(NSNumber*)oriWidth
                                 oriHeight:(NSNumber*)oriHeight;

/// 开始加载进程，在webview的dom元素加载完成以后调用
- (void)loadedProcess;

/// 模型加载完成以后.
/// @param data 加载完成后返回的参数。
- (void)modelLoadedWithData:(id)data;

/// 每次编辑裁片后，点击完成后调用.
/// @param model 编辑完成后的model。
- (void)previewEditInfoWithBase64PreviewImageString:(NSString*)base64ImageString jsonData:(NSDictionary*)jsonData autoType:(BOOL)isAutoNode imageInfo:(NSDictionary*)imageInfo;

/// 点击切换模型设计.
/// @param design 切换的设计信息。
- (void)switchModelGoodsDesign:(NSDictionary*)design;

/// 点击切换模型一级分类sku.
/// @param design 切换的一级分类sku信息。
- (void)switchModelGoodsSku:(NSDictionary*)sku;

/// 点击去购买按钮.
- (void)clickPurchaseGoods;

/// 点击立即购买按钮.
- (void)purchaseGoods;

/// 确定列表元素个数.
- (NSInteger)numberOfRowsWithTag:(NSInteger)tag;

/// 确定列表项尺寸.
- (CGSize)sizeForItemWithTag:(NSInteger)tag;

- (void)setInitParams;

@end
