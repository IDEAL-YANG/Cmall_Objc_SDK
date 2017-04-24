//
//  TDDIYWebViewModel.m
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "TDDIYWebViewModel.h"
#import "NSNumber+CMSetPriceShowRule.h"
#import "NSURL+CMAddImageBaseURL.h"
#import "CMNetworkManage.h"

#import <CmallSDK/CmallSDK.h>
#import "WKWebViewJavascriptBridge+CmallSDKDetailBridge.h"

@interface TDDIYWebViewModel ()

/// 详情来源
@property (nonatomic, assign) TDDIYSourceType sourceType;
/// 商品id
@property (nonatomic, strong) NSNumber *goodsId;
/** 产品设计id */
@property (nonatomic, strong) NSNumber *productId;
/** 模型分类id */
@property (nonatomic, strong) NSNumber *modelClassId;
/** 图片资源url */
@property (nonatomic, strong) NSString *autoImageUrlString;

/** 暂存数据，在页面重新刷新后，保持设计列表不变 */
@property (nonatomic, strong) NSNumber *ori_goodsId;
@property (nonatomic, strong) NSNumber *ori_modelClassId;


/// 获取的token，用于接口
@property (nonatomic, copy) NSString *token;
/// token的有效期，过期请重新获取
@property (nonatomic, strong) NSDate *tokenDeadline;

/// 商品名字
@property (nonatomic, copy)NSString *goodsName;
/// 售卖价格
@property (nonatomic, strong) NSNumber *salePrice;
/// 货币符号
@property (nonatomic, copy) NSString *symbol;

/** 记录下当前模型的所有编辑过得节点 */
@property (nonatomic, strong) NSMutableDictionary *allNodesDict;
/** 购买时，确定下要上传的图片节点 */
@property (nonatomic, strong) NSMutableDictionary *uploadImageDict;

@end

@implementation TDDIYWebViewModel

+ (instancetype)diyWebViewModelWithProductId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId
                        autoImageUrlString:(NSString*)autoImageUrlString{
    return [self diyWebViewModelWithGoodsId:@0 sourceType:TDDIYSourceTypeGoodsList productId:productId modelClassId:modelClassId autoImageUrlString:autoImageUrlString oriWidth:@0 oriHeight:@0];
}

+ (instancetype)diyWebViewModelWithProductId:(NSNumber*)productId
                                modelClassId:(NSNumber*)modelClassId
                          autoImageUrlString:(NSString*)autoImageUrlString
                                    oriWidth:(NSNumber*)oriWidth
                                   oriHeight:(NSNumber*)oriHeight{
    return [self diyWebViewModelWithGoodsId:@0 sourceType:TDDIYSourceTypeGoodsList productId:productId modelClassId:modelClassId autoImageUrlString:autoImageUrlString oriWidth:oriWidth oriHeight:oriHeight];
}

+ (instancetype)diyWebViewModelWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId{
    return [self diyWebViewModelWithGoodsId:goodsId sourceType:sourceType productId:productId modelClassId:modelClassId autoImageUrlString:@"" oriWidth:@0 oriHeight:@0];
}

+ (instancetype)diyWebViewModelWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId
                        autoImageUrlString:(NSString*)autoImageUrlString
                                  oriWidth:(NSNumber*)oriWidth
                                 oriHeight:(NSNumber*)oriHeight{
    
    TDDIYWebViewModel *vm = [[self alloc] init];
    vm.goodsId = goodsId;
    vm.sourceType = sourceType;
    vm.productId = productId;
    vm.modelClassId = modelClassId;
    vm.autoImageUrlString = autoImageUrlString;
    vm.autoImageWidth = oriWidth;
    vm.autoImageHeight = oriHeight;
    
    vm.ori_goodsId = goodsId;
    vm.ori_modelClassId = modelClassId;
    return vm;
}

- (instancetype)init{
    if (self = [super init]) {
        self.designGroupSelected = -1;
        self.designSelected = -1;
        self.skuSelected = -1;
        self.subSkuSelected = -1;
        self.goodsCount = 1;
        
        self.autoImageWidth = @0;
        self.autoImageHeight = @0;
        
        self.allNodesDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.uploadImageDict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        @weakify(self);
        [[RACObserve(self, purchaseSkuCode) skip:1] subscribeNext:^(id x) {
            
            NSDictionary *autoNode = self.allNodesDict[@"autoNode"];
            if (!autoNode) {
                self.allNodesDict = [NSMutableDictionary dictionaryWithCapacity:0];
            }
            self.uploadImageDict = [NSMutableDictionary dictionaryWithCapacity:0];
            
            //获取当前加载完成的模型设计的【sku列表】
            [self fetchModelSkuList];
        }];
        
        [[RACObserve(self, subSkuSelected) skip:1] subscribeNext:^(id x) {
            @strongify(self);
            if (self.subSkuList.count) {
                NSDictionary *dict = self.subSkuList[self.subSkuSelected];
                NSNumber *salePrice = dict[@"salePrice"];
                [self.webVC setUpSkuPrice:[[salePrice getPriceNumber] floatValue]];
            }
        }];
        
        [[[RACObserve(self, detailImageUrlString) skip:1] distinctUntilChanged] subscribeNext:^(NSString *urlString) {
            @strongify(self);
            if (!urlString || [urlString length] == 0) {
                [self.webVC.diyWebView scrollViewCannotScroll];
            }else{
                NSURL *imgUrl = [[[NSURL URLWithString:urlString] addImageBaseURL] addSuffixWithString:@"?imageInfo"];
                [[CMNetworkManage sharedInstance] getForSDKWithUrlString:imgUrl.absoluteString parameters:@{} success:^(NSDictionary *dic) {
                    @strongify(self);
                    if (dic && [dic isKindOfClass:[NSDictionary class]] && [[dic allKeys] containsObject:@"width"] && [[dic allKeys] containsObject:@"height"]) {
                        self.detail_Width = [dic[@"width"] floatValue];
                        self.detail_Height = [dic[@"height"] floatValue];
                        LBDispatch_main_async_safe(^(){
                            @strongify(self);
                            UICollectionView *detailCollectionView = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeDetailImgsList];
                            [detailCollectionView reloadData];
                        });
                    }else{
                        self.detail_Width = 0;
                        self.detail_Height = 0;
                        LBDispatch_main_async_safe(^(){
                            @strongify(self);
                            [self.webVC.diyWebView scrollViewCannotScroll];
                        });
                    }
                    CGFloat width = self.detail_Width;
                    CGFloat height = self.detail_Height;
                    
                    CGFloat reW = width > (Main_Screen_Width)?(Main_Screen_Width):width;
                    CGFloat reH = 0;
                    if (width > 0) {
                        reH = (Main_Screen_Width) * height/width;
                    }else{
                        reH = reW;
                    }
                    LBDispatch_main_async_safe(^(){
                        @strongify(self);
                        [self.webVC.diyWebView updateContentSize:reH];
                    });
                    
                } failure:^(NSError *error) {
                    @strongify(self);
                    LBDispatch_main_async_safe(^(){
                        @strongify(self);
                        [self.webVC.diyWebView scrollViewCannotScroll];
                    });
                }];
            }
        }];
    }
    return self;
}

#pragma mark - Public

- (void)loadedProcess{
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self fetchTokenWithSuccess:^{
            @strongify(self);
            //获取默认的模型，展示默认的模型。
            [self fetchGoodsIdByModelClassId:self.modelClassId];
        }];
    });
}

- (void)modelLoadedWithData:(id)data{
    if (![self checkResponseData:data]) {
        
        NSNumber *code = data[@"code"];
        switch ([code integerValue]) {
//            case 100001:
//            case 100002:
            case 100003:
            {
                self.purchaseSkuCode = [[data[@"result"] firstObject] valueForKey:@"skuCode"];
                break;
            }
            default:
            {
                @weakify(self);
                LBDispatch_main_async_safe((^(){
                    @strongify(self);
                    [self.webVC.navigationController popViewControllerAnimated:true];
                    [self.webVC alertDataWithDict:data bridge:@"cmall_needBackPreviewAndReLogin"];
                }));
                break;
            }
        }
    }
}

- (void)previewEditInfoWithBase64PreviewImageString:(NSString*)base64ImageString jsonData:(NSDictionary*)jsonData autoType:(BOOL)isAutoNode imageInfo:(NSDictionary*)imageInfo{
    
    if (isAutoNode) {
        [self.allNodesDict setValue:imageInfo forKey:@"autoNode"];
    }else{
        [self.allNodesDict setValue:imageInfo forKey:imageInfo[kCmallSDKNodeName]];
    }
    
    NSString *imageSource = base64ImageString;
    DLog(@"==开始传编辑过的截图==");
    @weakify(self);
    [self.webVC.bridge cmall_didSetInitImageSrc:imageSource handler:^(id responseData) {
        DLog(@"==传图片完毕，准备给数据==");
        @strongify(self);
        
        NSDictionary *dict = jsonData;
        
#if DEBUG
        @try {
            NSString *jsonDict = [NSString dictionaryToJson:dict];
            DLog(@"==编辑过，回到模型的数据：jsonDict:%@",jsonDict);
        } @catch (NSException *exception) {
            DLog(@"===编辑过信息异常：%@",exception);
        }
#endif
        [self.webVC.bridge cmall_didCompleteEditCutPieces:dict handler:^(id responseData) {
            DLog(@"==cmall_didCompleteEditCutPieces:OC发到H5的数据成功了==");
        }];
    }];
}

- (void)switchModelGoodsDesign:(NSDictionary*)design{
    
    /*设计列表
     {
     goodsId = 1093;
     goodsImagePath = "diyrelease/319627/148827857329344641.jpg";
     goodsType = 0;
     modelClassId = 1397;
     productId = 50011;
     }
     */
    
    self.modelLoading = true;
    
    NSString *source = [NSString stringWithFormat:@"%ld",(long)self.sourceType];
    
    NSDictionary *dict = @{
                           @"token":self.token,
                           @"goodsId":design[@"goodsId"],
                           @"source":source
                           };
    
    @weakify(self);
    [self.webVC.bridge cmall_switchModelGoodsDesign:dict handler:^(NSDictionary *responseData) {
        DLog(@"===获取cmall_switchModelGoodsDesign：%@",responseData);
        @strongify(self);
        if ([self checkResponseData:responseData]) {
            self.goodsId = responseData[@"result"][@"goodsId"]?:@0;
            self.goodsName = responseData[@"result"][@"goodsName"]?:@"未知商品";
            self.detailImageUrlString = responseData[@"result"][@"detailImagePath"];
            self.symbol = responseData[@"result"][@"currencySymbol"];
            self.salePrice = responseData[@"result"][@"salePrice"];
            
            self.modelClassId = design[@"modelClassId"]?:@0;
            
            NSLog(@"goodsId:%@",self.goodsId);
            NSLog(@"modelClassId:%@",self.modelClassId);
            
        }else{
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC alertDataWithDict:responseData bridge:@"cmall_switchModelGoodsDesign"];
            }));
        }
    }];
}

- (void)switchModelGoodsSku:(NSDictionary*)sku{
    
    /*sku列表
     {
     childsInfoApiVos = "<null>";
     currencySymbol = "$";
     defaultSel = 0;
     embroideryPrice = 15;
     levelVal = 1;
     modelType = 3D;
     productCode = 70001;
     productDetailCode = 70001100;
     salePrice = 25;
     showType = COLOR;
     skuCode = 10001;
     skuName = White;
     skuType = OPTION;
     skuValue = "/impdata/skuColor/M001.png";
     }
     */
    
    self.modelLoading = true;
    
    NSDictionary *dict = @{
                           @"skuType":sku[@"skuType"]?:@"",
                           @"skuValue":sku[@"modelShowValue"]?:@""};
    @weakify(self);
    [self.webVC.bridge cmall_didSelectSku:dict handler:^(NSDictionary *responseData) {
        DLog(@"===获取cmall_didSelectSku：%@",responseData);
        @strongify(self);
        self.purchaseSkuCode = [sku valueForKey:@"skuCode"];
        LBDispatch_main_async_safe((^(){
            @strongify(self);
            [self.webVC stopLoading];
        }));
    }];
}

- (void)clickPurchaseGoods{
    
    [self.webVC startLoading];
    
    @weakify(self);
    [self fetch3DPreviewImageWithSuccess:^(NSDictionary *params) {
        @strongify(self);
        [self.webVC stopLoading];
        
        UIImage *image = params[@"thumbnilImage"];
        NSString *fileExtension = params[@"fileExtension"];
        
        [self.uploadImageDict setObject:@{
                                          @"image":image,
#warning !!! 这里的上传key，由第三方决定。
                                          @"uploadKey":[NSString stringWithFormat:@"https://%@/img/1234565432345654.%@",@"第三方图片域名前缀",fileExtension],
                                          } forKey:@"preview3dImage"];
        
        /*
         childsInfoApiVos = "<null>";
         currencySymbol = "$";
         defaultSel = 0;
         embroideryPrice = 15;
         levelVal = 1;
         modelType = 3D;
         productCode = 70001;
         productDetailCode = 70001100;
         salePrice = 25;
         showType = COLOR;
         skuCode = 10001;
         skuName = White;
         skuType = OPTION;
         skuValue = "/impdata/skuColor/M001.png";
         */
        NSNumber *salePrice;
        
        NSDictionary *sku;
        NSArray *subSkuList;
        if (self.skuList.count) {
            sku = self.skuList[self.skuSelected];
            subSkuList = (sku[@"childsInfoApiVos"] && ![sku[@"childsInfoApiVos"] isEqual:[NSNull null]])?sku[@"childsInfoApiVos"]:[NSArray array];
            if (self.subSkuSelected >= 0 && self.subSkuSelected < subSkuList.count) {
                sku = [subSkuList objectAtIndex:self.subSkuSelected];
            }
            
            salePrice = [[sku objectForKey:@"salePrice"] getPriceNumber];
        }else if (self.subSkuList.count){
            sku = self.subSkuList[self.subSkuSelected];
            subSkuList = [self.subSkuList copy];
            
            salePrice = [[sku objectForKey:@"salePrice"] getPriceNumber];
        }else{
            salePrice = [self.salePrice getPriceNumber];
        }
        
        [self.webVC setupSkuListWithImageUrl:nil previewImage:image goodsName:self.goodsName currencySymbol:self.symbol price:[salePrice floatValue] skuTypeName:(sku && [sku[@"levelVal"] integerValue] == 2) ? [sku objectForKey:@"skuType"]:@"" skuNames:[subSkuList valueForKey:@"skuCode"] currentIndex:self.subSkuSelected];
        
        __block TDSelectSkuAddCartView *cartView = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeCartView];
        [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            cartView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(cartView.frame));
        } completion:^(BOOL finished) {
            cartView.alphaiView.alpha = 0.2;
        }];
    }];
}

- (void)purchaseGoods{
    
    NSDictionary *dict = @{};
    @weakify(self);
    [self.webVC.bridge cmall_didAddToShopCart:dict handler:^(id data) {
        DLog(@"===获取clickPurchaseGoods：%@",data);
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            
            @strongify(self);
            NSString *allNodesJsonString = data[@"modelJson"];
            
            NSNumber *skuCode;
            if (self.skuList.count) {
                NSDictionary *dict = self.skuList[self.skuSelected];
                if (self.subSkuSelected >= 0) {
                    dict = [dict[@"childsInfoApiVos"] objectAtIndex:self.subSkuSelected];
                }
                skuCode = dict[@"productDetailCode"];
            }else if (self.subSkuList.count){
                skuCode = [self.subSkuList[self.subSkuSelected] objectForKey:@"productDetailCode"];
            }else{
                skuCode = @0;
            }
            
            NSDictionary *dict = self.designList[self.designSelected > -1?self.designSelected:0];
            NSNumber *goodsType = dict[@"goodsType"];
            
            NSNumber *productId = self.productId;
            NSNumber *goodsId = self.goodsId;
            NSNumber *modelClassId = self.modelClassId;
            
            NSDictionary *modelJsonDict = @{
                                            @"productDetailId":skuCode,
                                            @"goodsType":goodsType,
                                            @"clientType":@"01",//00表示android手机端，01标识ios手机端
                                            @"productId":productId,
                                            @"goodsId":goodsId,
                                            @"moudleId":modelClassId,
                                            @"svgInfo":allNodesJsonString
                                            };
            
            [self generateUploadImagesInfo];
            
            
            //下单的时候，把modelJsonDict转成json字符串,当做tepComInfo的参数值使用。
            NSString *tepComInfo = [NSString dictionaryToJson:modelJsonDict];
        
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC stopLoading];
                [self.webVC cancelAdd];
                
                [self.webVC dismissViewControllerAnimated:true completion:^{
                    @strongify(self);
#warning !!! 这里的需要上传的图片信息，请确保下单的这个信息中的图片已按uploadKey上传！！！
                    /** 注意 */
                    NSLog(@"==需要上传的原图信息：%@",self.uploadImageDict);
                    
                    /** 注意 */
                    NSLog(@"==下单使用的信息:>>>>>");
                    
                    NSLog(@"==goodsId:%@",goodsId);
                    NSLog(@"==goodsQuantity:%ld",self.goodsCount);
                    NSLog(@"==goodsType:%@",goodsType);
                    NSLog(@"==goodsName:%@",self.goodsName);
                    NSLog(@"==tepComInfo:%@",tepComInfo);
                    
                    NSLog(@"<<<<<<下单使用的信息==");
                    
                    /** 注意 */
#warning !!! 下单接口请参考开放平台文档。
                }];
            }));
            
        }else{
            LBDispatch_main_async_safe(^(){
                @strongify(self);
                [self.webVC alertDataWithDict:data bridge:@"cmall_didAddToShopCart"];
            });
        }
    }];
}

- (void)generateUploadImagesInfo{
    NSMutableArray *uploadImages = [NSMutableArray arrayWithCapacity:self.allNodesDict.count];
    NSArray *allKeys = self.allNodesDict.allKeys;
    for (NSString *key in allKeys) {
        NSDictionary *imageInfo = [self.allNodesDict objectForKey:key];
        
        [uploadImages addObject:@{
                                  @"image":[imageInfo valueForKey:@"previewImage"],
                                  @"uploadKey":[imageInfo valueForKey:@"imageUrl"],
                                  }];
        
        if ([imageInfo valueForKey:@"userImage"] && [imageInfo valueForKey:@"userImageUrl"]) {
            [uploadImages addObject:@{
                                      @"image":[imageInfo valueForKey:@"userImage"],
                                      @"uploadKey":[imageInfo valueForKey:@"userImageUrl"],
                                      }];
        }
    }
    [self.uploadImageDict setObject:uploadImages forKey:@"nodes"];
}

#pragma mark -

- (NSInteger)numberOfRowsWithTag:(NSInteger)tag{
    NSInteger count = 0;
    switch (tag) {
        case TDDIYTagTypeDesignGroupList:
        {
            count = self.designGroupList.count;
            break;
        }
        case TDDIYTagTypeDesignList:
        {
            count = self.designList.count;
            break;
        }
        case TDDIYTagTypeDetailImgsList:
        {
            count = self.detailImageUrlString && [self.detailImageUrlString length]?1:0;
            break;
        }
        default:
            break;
    }
    return count;
}

- (CGSize)sizeForItemWithTag:(NSInteger)tag{
    CGSize size = CGSizeZero;
    switch (tag) {
            
        case TDDIYTagTypeDesignGroupList:
        {
            size = CGSizeMake(80, 25);
            break;
        }
        case TDDIYTagTypeDesignList:
        {
            size = CGSizeMake(80, 80);
            break;
        }
        case TDDIYTagTypeDetailImgsList:
        {
            CGFloat width = self.detail_Width;
            CGFloat height = self.detail_Height;
            
            CGFloat reW = width > (Main_Screen_Width)?(Main_Screen_Width):width;
            CGFloat reH = 0;
            if (width > 0) {
                reH = (Main_Screen_Width) * height/width;
            }else{
                reH = reW;
            }
            return CGSizeMake(reW, reH);
        }
        default:
            break;
    }
    return size;
}

- (void)setInitParams{
    self.goodsId = self.ori_goodsId;
    self.modelClassId = self.ori_modelClassId;
    self.allNodesDict = [NSMutableDictionary dictionaryWithCapacity:0];
    self.uploadImageDict = [NSMutableDictionary dictionaryWithCapacity:0];
}

#pragma mark - Private
#pragma mark 初始化调用

- (void)fetchToken{
    [self fetchTokenWithSuccess:nil];
}

- (void)fetchTokenWithSuccess:(void(^)())successToken{
    NSString *redirectUri = @"";
    NSString *noncStr = @"";
    
    NSDictionary *dict = @{
                           @"redirectUri":redirectUri,
                           @"noncStr":noncStr
                           };
    
    @weakify(self);
    [self.webVC.bridge cmall_acsToken:dict handler:^(NSDictionary *responseData) {
        DLog(@"==调用cmall_acsToken桥，返回数据：%@",responseData);
        @strongify(self);
        if ([self checkResponseData:responseData]) {
            self.token = responseData[@"result"][@"token"];
            NSString *time = responseData[@"result"][@"expiresIn"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            self.tokenDeadline = [dateFormatter dateFromString:time];
            
            if (successToken) {
                successToken();
            }
        }else{
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC alertDataWithDict:responseData bridge:@"cmall_acsToken"];
            }));
        }
    }];
    
}

- (void)fetchGoodsIdByModelClassId:(NSNumber*)modelClassId{
    
    NSString *source = [NSString stringWithFormat:@"%ld",(long)self.sourceType];
    
    NSDictionary *dict = @{
                           @"modelClassId":modelClassId,
                           @"source":source,
                           @"token":self.token,
                           @"originalUrl":self.autoImageUrlString
                           };
    @weakify(self);
    DLog(@"==获取默认的goodsId前参数：%@",dict);
    [self.webVC.bridge cmall_getGoodsIdByModelClassId:dict handler:^(NSDictionary *responseData) {
        DLog(@"==调用cmall_getGoodsIdByModelClassId桥，返回数据：%@",responseData);
        @strongify(self);
        if ([self checkResponseData:responseData]) {
            self.goodsId = responseData[@"result"][@"goodsId"];
            self.goodsName = responseData[@"result"][@"goodsName"]?:@"未知商品";
            self.detailImageUrlString = responseData[@"result"][@"detailImagePath"];
            self.symbol = responseData[@"result"][@"currencySymbol"];
            self.salePrice = responseData[@"result"][@"salePrice"];
            
            //获取该模型【设计列表】
            [self fetchModelDesignList];
        }
    }];
}

- (void)fetchModelDesignList{
    NSDictionary *dict = @{@"productId":self.productId,
                           @"goodsId":self.goodsId,
                           @"token":self.token,
                           @"picWidth":self.autoImageWidth,
                           @"picHeight":self.autoImageHeight};
    
    NSLog(@"goodsId:%@",self.goodsId);
    NSLog(@"modelClassId:%@",self.modelClassId);
    
    @weakify(self);
    [self.webVC.bridge cmall_getModelDesignList:dict handler:^(NSDictionary *responseData) {
        DLog(@"===获取cmall_getModelDesignList：%@",responseData);
        @strongify(self);
        if ([self checkResponseData:responseData]) {
            
            self.designGroupList = [responseData[@"result"] isEqual:[NSNull null]]?[NSArray array]:responseData[@"result"];
            
            if (self.designGroupList.count) {
                
                NSDictionary *group;
                for (NSDictionary *tempGroup in self.designGroupList) {
                    group = [tempGroup copy];
                    NSArray *tempDesignList = [tempGroup objectForKey:@"goodsInfoVos"];
                    NSLog(@"goodsIdOrderList:%@",[tempDesignList valueForKey:@"goodsId"]);
                    for (NSDictionary *design in tempDesignList) {
                        if ([design[@"modelClassId"] integerValue] == [self.modelClassId integerValue]) {
                            self.designSelected = [tempDesignList indexOfObject:design];
                            self.designList = [tempDesignList copy];
                            
                            self.designGroupSelected = [self.designGroupList indexOfObject:tempGroup];
                            break;
                        }
                    }
                }
                
                UICollectionView *groupCollectionView = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeDesignGroupList];
                
                UICollectionView *collectionView = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeDesignList];
                if (![[group objectForKey:@"hasGroup"] boolValue]) {
                    //                        CGFloat productHeight = 40 + Main_Screen_Width + 30 + 5 +itemWidth+10 + 5 + 40 + 5;
                    //                        self.webVC.diyWebView.productHeight = productHeight < Main_Screen_Height - 50 ? Main_Screen_Height - 50 : productHeight;
                    
                    [collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(groupCollectionView);
                    }];
                    
                } else {
                    UICollectionView *collectionView1 = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeDetailImgsList];
                    [collectionView1 mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(@(self.webVC.diyWebView.productHeight+50));
                    }];
                }
                
                LBDispatch_main_async_safe((^(){
                    [groupCollectionView reloadData];
                    [collectionView reloadData];
                    [groupCollectionView setContentOffset:CGPointZero animated:true];
                    [collectionView setContentOffset:CGPointZero animated:true];
                }));
                
            }
        }else{
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC alertDataWithDict:responseData bridge:@"cmall_getModelDesignList"];
            }));
        }
    }];
    
}

- (void)fetchModelSkuList{
    NSDictionary *dict = @{
                           @"modelClassId":self.modelClassId,
                           @"token":self.token,
                           @"productCode":self.productId,
                           @"goodsId":self.goodsId
                           };
    DLog(@"==获取sku前：%@",dict);
    @weakify(self);
    [self.webVC.bridge cmall_getGoodsSkuList:dict handler:^(NSDictionary *responseData) {
        DLog(@"===获取cmall_getGoodsSkuList：%@",responseData);
        @strongify(self);
        if ([self checkResponseData:responseData]) {
            
            self.modelLoading = false;
            
            self.skuList = [responseData[@"result"] isEqual:[NSNull null]]?[NSArray array]:responseData[@"result"];
            for (NSDictionary *dict in self.skuList) {
                if ([dict[@"levelVal"] integerValue] != 1) {
                    
                    self.subSkuList = [self.skuList copy];
                    self.subSkuSelected = 0;
                    
                    NSNumber *salePrice = [self.subSkuList firstObject][@"salePrice"];
                    NSString *symbol = [self.subSkuList firstObject][@"currencySymbol"]?:@"";
                    self.showPriceString = [NSString stringWithFormat:@"%@ %@",symbol,[salePrice getPriceNumber]];
                    
                    self.skuList = [NSArray array];
                    LBDispatch_main_async_safe((^(){
                        @strongify(self);
                        [self.webVC stopLoading];
                        UIView *aview = [self.webVC.diyWebView viewWithTag:'bvie'];
                        aview.hidden = true;
                    }));
                    return;
                }
                
                UIButton *button = [self.webVC.diyWebView viewWithTag:TDDIYTagTypeFirstSkuBtn];
                [button setTitle:[dict objectForKey:@"showType"] forState:UIControlStateNormal];
                button.hidden = false;
                
                if ([dict[@"skuCode"] integerValue] == [self.purchaseSkuCode integerValue]) {
                    self.skuSelected = [self.skuList indexOfObject:dict];
                    
                    NSURL *imgURL = [[[NSURL URLWithString:([dict[@"skuValue"] isEqual:[NSNull null]]?@"":dict[@"skuValue"])] addImageBaseURL] addSuffixWithString:[NSString stringWithFormat:@"?imageView2/0/w/%.0f",30 * Main_Screen_Scale]];
                    [self.webVC.diyWebView.colorBtn setImageWithURL:imgURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    
                    self.webVC.diyWebView.menuNameLabel.text = dict[@"showType"] ?:@"";
                }
                
                if (dict[@"childsInfoApiVos"] && ![dict[@"childsInfoApiVos"] isEqual:[NSNull null]] && [dict[@"childsInfoApiVos"] count] && self.subSkuSelected == -1) {
                    self.subSkuSelected = 0;
                }
            }
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC stopLoading];
            }));
        }
        else{
            LBDispatch_main_async_safe((^(){
                @strongify(self);
                [self.webVC alertDataWithDict:responseData bridge:@"cmall_getGoodsSkuList"];
            }));
        }
    }];
    
}

- (void)fetch3DPreviewImageWithSuccess:(void(^)(NSDictionary*))success{
    @weakify(self);
    DLog(@"===准备获取3d预览视图==");
    [self.webVC.bridge cmall_didGetImage:@{} handler:^(NSDictionary *responseData) {
        DLog(@"===cmall_didGetImage==");
        if (responseData && [responseData[@"imageData"] isKindOfClass:[NSString class]] && [(NSString*)responseData[@"imageData"] containsString:@";base64,"]) {
            NSArray *dataArr = [responseData[@"imageData"] componentsSeparatedByString:@";base64,"];
            
            NSString *dataString = [dataArr lastObject];
            NSData *thumbnilData = [[NSData alloc] initWithBase64EncodedString:dataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *thumbnilImage = [UIImage imageWithData:thumbnilData];
            DLog(@"==获取3d预览图成功:%@==",thumbnilImage);
            
            NSString *fileExtension = [dataArr.firstObject lastPathComponent];
            
            if (success) {
                success(@{@"thumbnilImage":thumbnilImage,@"fileExtension":fileExtension});
            }
        }else{
            LBDispatch_main_async_safe(^(){
                @strongify(self);
                [self.webVC alertDataWithDict:@{@"errorMsg":@"返回的不是base64字符串"} bridge:@"cmall_didGetImage"];
            });
        }
    }];
}

#pragma mark - Private Private

- (BOOL)checkResponseData:(id)data{
    if(data && [data isKindOfClass:[NSDictionary class]] && data[@"code"] && [data[@"code"] integerValue] == 200){
        return true;
    }
    return false;
}

#pragma mark - Getters and Setters

- (NSArray *)designGroupList{
    if (!_designGroupList) {
        _designGroupList = [NSArray array];
    }
    return _designGroupList;
}

- (NSArray *)designList{
    if (!_designList) {
        _designList = [NSArray array];
    }
    return _designList;
}

- (NSArray *)skuList{
    if (!_skuList) {
        _skuList = [NSArray array];
    }
    return _skuList;
}

- (NSArray *)subSkuList{
    if (!_subSkuList) {
        _subSkuList = [NSArray array];
    }
    return _subSkuList;
}

@end
