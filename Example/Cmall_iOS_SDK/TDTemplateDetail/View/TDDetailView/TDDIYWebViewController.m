//
//  TDDIYWebViewController.m
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "TDDIYWebViewController.h"
#import "TDDIYWebViewModel.h"
#import "CMLoadingView.h"
#import "TDDIYWebViewDatasource.h"
#import "UIAlertController+CMCreate.h"
#import "NSURL+CMAddImageBaseURL.h"

#define kTUDEDIYWebAppPath @"/open/source/openapi.html"

#import <CmallSDK/CmallSDK.h>
#import "WKWebViewJavascriptBridge+CmallSDKDetailBridge.h"

@interface TDDIYWebViewController ()

@property (strong, nonatomic) TDDIYWebViewDatasource *dataSource;
/// WKWebView桥
@property (strong, nonatomic, readwrite) WKWebViewJavascriptBridge *bridge;
/// viewModel
@property (nonatomic, strong, readwrite) TDDIYWebViewModel *viewModel;
/// 自定义View
@property (strong, nonatomic, readwrite) TDDIYWebView *diyWebView;

@property (assign, nonatomic) BOOL currentActive;

@end

@implementation TDDIYWebViewController

+ (instancetype)diyWebViewControllerWithProductId:(NSNumber*)productId
                                modelClassId:(NSNumber*)modelClassId
                          autoImageUrlString:(NSString*)autoImageUrlString{
    return [self diyWebViewControllerWithProductId:productId modelClassId:modelClassId autoImageUrlString:autoImageUrlString oriWidth:@0 oriHeight:@0];
}

+ (instancetype)diyWebViewControllerWithProductId:(NSNumber*)productId
                                     modelClassId:(NSNumber*)modelClassId
                               autoImageUrlString:(NSString*)autoImageUrlString
                                         oriWidth:(NSNumber*)oriWidth
                                        oriHeight:(NSNumber*)oriHeight{
    return [self diyWebViewControllerWithGoodsId:@0 sourceType:TDDIYSourceTypeGoodsList productId:productId modelClassId:modelClassId autoImageUrlString:autoImageUrlString oriWidth:oriWidth oriHeight:oriHeight];
}

+ (instancetype)diyWebViewControllerWithGoodsId:(NSNumber*)goodsId
                                sourceType:(TDDIYSourceType)sourceType
                                 productId:(NSNumber*)productId
                              modelClassId:(NSNumber*)modelClassId{
    NSAssert(nil, @"该方法目前禁用！！！");
    return [self diyWebViewControllerWithGoodsId:goodsId sourceType:sourceType productId:productId modelClassId:modelClassId autoImageUrlString:@"" oriWidth:@0 oriHeight:@0];
}

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}

- (void)loadView{
    self.view = self.diyWebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    [self registerBridge];
    [self addBindViewModel];
    [self beginRequestData];
    [self addCmallSDKCallBack];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentActive = true;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
}

#pragma mark - 初始化顺序调用

- (void)commonInit{
    self.dataSource = [[TDDIYWebViewDatasource alloc] init];
    self.dataSource.webVC = self;
    
    self.diyWebView.webView.navigationDelegate = _dataSource;
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.diyWebView.webView];
    [self.bridge setWebViewDelegate:_dataSource];
    
    self.diyWebView.scrollView.delegate = _dataSource;
    
    UICollectionView *materialGroupCollectionView = [self.diyWebView viewWithTag:TDDIYTagTypeDesignGroupList];
    materialGroupCollectionView.dataSource = _dataSource;
    materialGroupCollectionView.delegate = _dataSource;
    
    UICollectionView *materialCollectionView = [self.diyWebView viewWithTag:TDDIYTagTypeDesignList];
    materialCollectionView.dataSource = _dataSource;
    materialCollectionView.delegate = _dataSource;
    
    UICollectionView *detailCollectionView = [self.diyWebView viewWithTag:TDDIYTagTypeDetailImgsList];
    detailCollectionView.dataSource = _dataSource;
    detailCollectionView.delegate = _dataSource;
    
    [self.diyWebView addSubview:self.loadingView];
    
    @weakify(self);
    self.diyWebView.backAction = ^(){
        @strongify(self);
        [self backPreview:nil];
    };
}

- (void)registerBridge{
    @weakify(self);
    [self.bridge cmall_callGlobalConfig:nil];
    
    [self.bridge cmall_needBackPreviewAndReLogin:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        DLog(@"==cmall_needBackPreviewAndReLogin:%@==",data);
        [self.viewModel modelLoadedWithData:data];
        responseCallback(@"==cmall_needBackPreviewAndReLogin_response_from_ios==");
    }];
    
    [self.bridge cmall_goToEditCutPieces:^(id data, WVJBResponseCallback responseCallback) {
        DLog(@"==cmall_goToEditCutPieces==");
        @strongify(self);
        [self handleReceivedEditData:data];
        responseCallback(@"==cmall_goToEditCutPieces_response_from_ios==");
    }];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        @strongify(self);
    //        [self localDataTest];
    //    });
}

- (void)addBindViewModel
{
    @weakify(self);
    [[[RACObserve(self,diyWebView.webView.URL) skip:1] deliverOnMainThread] subscribeNext:^(NSURL *value) {
        @strongify(self);
        NSLog(@"==******url:%@",value);
        if (!value && ![[self generateUrl] hasPrefix:@"http://"]) {
            [self.viewModel setInitParams];
            [self beginRequestData];
        }
    }];
    
    TDSelectSkuAddCartView *cartView = [self.diyWebView viewWithTag:TDDIYTagTypeCartView];
    cartView.clickAddToCartBtn = ^(){
        @strongify(self);
        [self startLoading];
        [self.viewModel purchaseGoods];
    };
    [RACObserve(cartView,currentCount) subscribeNext:^(NSNumber *value) {
        @strongify(self);
        self.viewModel.goodsCount = [value integerValue];
    }];
    [RACObserve(cartView,currentSelectIndex) subscribeNext:^(NSNumber *value) {
        @strongify(self);
        self.viewModel.subSkuSelected = [value integerValue];
    }];
    
    [[RACObserve(self, viewModel.skuList) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        NSArray *array = (NSArray *)x;
        if ([array isKindOfClass:[NSArray class]] && array.count > 1) {
            NSArray *array1 = [array valueForKeyPath:@"skuValue"];
            NSMutableArray *temp = [NSMutableArray array];
            for (NSString *str in array1) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                [imageView setImageWithURL:[[NSURL URLWithString:(str && ![str isEqual:[NSNull null]])?str:@""] addImageBaseURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageView.layer.cornerRadius = 15.0f;
                imageView.layer.masksToBounds = true;
                [imageView setTapAction:^{
                    @strongify(self);
                    NSInteger index = [array1 indexOfObject:str];
                    self.viewModel.skuSelected = index >= 0 && index < self.viewModel.skuList.count ? index : -1;
                    NSDictionary *dict = self.viewModel.skuList[index];
                    
                    if ([dict[@"levelVal"] integerValue] == 1) {
                        self.viewModel.subSkuList = ![dict[@"childsInfoApiVos"] isEqual:[NSNull null]]?dict[@"childsInfoApiVos"]:[NSArray array];
                    }
                    [self.viewModel switchModelGoodsSku:dict];
                    DLog(@"===选中1级sku：%@",dict);
                    [self.diyWebView.menuButton dismissButtons];
                    [self.diyWebView.colorBtn setImageWithURL:[[NSURL URLWithString:(str && ![str isEqual:[NSNull null]])?str:@""] addImageBaseURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                }];
                [temp addObject:imageView];
            }
            [self.diyWebView.menuButton addButtons:temp];
            if (!self.diyWebView.menuButton.hidden) {
                [self.diyWebView.menuButton dismissButtons];
            }
            
            UIView *aview = [self.diyWebView viewWithTag:'bvie'];
            aview.hidden = false;
            self.diyWebView.menuButton.hidden = false;
            self.diyWebView.menuNameLabel.hidden = false;
            self.diyWebView.colorBtn.hidden = false;
        } else {
            UIView *aview = [self.diyWebView viewWithTag:'bvie'];
            aview.hidden = true;
            self.diyWebView.menuButton.hidden = true;
            self.diyWebView.menuNameLabel.hidden = true;
            self.diyWebView.colorBtn.hidden = true;
        }
    }];
    
    [cartView.alphaiView setTapAction:^{
        @strongify(self);
        [self cancelAdd];
    }];
    
    UIButton *buyBtn = [self.diyWebView viewWithTag:TDDIYTagTypeBuyBtn];
    [[buyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel clickPurchaseGoods];
    }];
    
    [[RACObserve(self, viewModel.modelLoading) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.diyWebView needEnableBuyButton:![x boolValue]];
    }];
}

- (void)beginRequestData{
    [self startLoading];
    NSString *urlString = [self generateUrl];
    [self loadWebViewWithUrl:urlString];
}

- (void)addCmallSDKCallBack{
    /*
     [CmallSDK showWithUserDefined:^(NSInteger code, NSString *infoDes) {
     NSLog(@"要开始转菊花了");
     }];
     
     [CmallSDK dismissWithUserDefined:^{
     NSLog(@"关闭菊花");
     }];
     */
    
    __weak typeof(self) weakSelf = self;
    [CmallSDK setEditCompletedCallBack:^(NSString* _Nonnull previewImageBase64StringOfPng,NSDictionary* _Nonnull jsonData,BOOL isAutoNode,NSDictionary* _Nonnull imageInfo) {
        NSLog(@"====TudeSDK编辑完成====");
        NSLog(@"====裁片图的base64字符串====");
        NSLog(@"%ld",(unsigned long)previewImageBase64StringOfPng.length);
        NSLog(@"====裁片图片====");
        NSLog(@"%@==url:%@",[imageInfo valueForKey:kCmallSDKPreviewImage],[imageInfo valueForKey:kCmallSDKPreviewImageUrl]);
        NSLog(@"====用户图片====");
        NSLog(@"%@==url:%@",[imageInfo valueForKey:kCmallSDKUserImage],[imageInfo valueForKey:kCmallSDKUserImageUrl]);
        NSLog(@"====返回数据====");
        NSLog(@"%@",jsonData);
        
        
        [weakSelf.viewModel previewEditInfoWithBase64PreviewImageString:previewImageBase64StringOfPng jsonData:jsonData autoType:isAutoNode imageInfo:imageInfo];
        
    }];
    
    [CmallSDK setEditCancelledCallBack:^{
        NSLog(@"====TudeSDK编辑取消====");
    }];
    
    [CmallSDK setNormalErrorCallBack:^(NSInteger code,NSString* errorDesc,NSDictionary * _Nullable errInfo){
        NSLog(@"====TudeSDK普通错误====");
        NSLog(@"====错误码：%ld，错误原因：%@，错误info：%@",(long)code,errorDesc,errInfo);
        NSString *message = [NSString stringWithFormat:@"TudeSDK普通错误\n错误码：%ld，错误原因：%@，错误信息：%@",(long)code,errorDesc,errInfo];
        [weakSelf alertDataWithDict:@{@"mes":message} bridge:@"SDK普通错误"];
    }];
}

#pragma mark - Public method

- (void)cancelAdd{
    [self.view endEditing:YES];
    TDSelectSkuAddCartView *cartView = [self.diyWebView viewWithTag:TDDIYTagTypeCartView];
    cartView.alphaiView.alpha = 0.0;
    [UIView animateWithDuration:0.35 animations:^{
        cartView.transform = CGAffineTransformIdentity;
    }];
}

- (void)setupSkuListWithImageUrl:(NSString *)imageUrl
                    previewImage:(UIImage *)previewImage
                       goodsName:(NSString *)goodsName
                  currencySymbol:(NSString *)currencySymbol
                           price:(CGFloat)price
                     skuTypeName:(NSString *)skuTypeName
                        skuNames:(NSArray*)skuNames
                    currentIndex:(NSInteger)index{
    TDSelectSkuAddCartView *cartView = [self.view viewWithTag:TDDIYTagTypeCartView];
    cartView.imageUrlString = imageUrl;
    cartView.previewImage = previewImage;
    cartView.name = goodsName;
    cartView.currencySymbol = currencySymbol;
    cartView.price = price;
    cartView.skuTypeName = skuTypeName;
    cartView.skuNames = skuNames;
    cartView.currentSelectIndex = index;
}

- (void)setUpSkuPrice:(CGFloat)price{
    TDSelectSkuAddCartView *cartView = [self.diyWebView viewWithTag:TDDIYTagTypeCartView];
    cartView.price = price;
}

- (void)loadWebViewFailed
{
}

- (void)alertDataWithDict:(id)data bridge:(NSString*)bridge{
    [self stopLoading];
    NSString *responseDataString;
    @try {
        responseDataString = [data isKindOfClass:[NSDictionary class]] ?[NSString dictionaryToJson:data]:data;
    } @catch (NSException *exception) {
        responseDataString = @"数据不是json";
    } @finally {
        DLog(@"Api错误");
        [UIAlertController alertWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@\nresp:%@",bridge,responseDataString] cancelTitle:@"朕知道了" inViewCtl:self];
    }
}

#pragma mark - Private Methods
#pragma mark - 节点交互

- (void)handleReceivedEditData:(id)data{
    @weakify(self);
#if DEBUG
    @try {
        NSString *jsonDict = [NSString dictionaryToJson:data];
        DLog(@"==从模型来的数据：jsonDict:%@",jsonDict);
    } @catch (NSException *exception) {
        DLog(@"==从h5来的数据不是json==");
        LBDispatch_main_async_safe((^(){
            @strongify(self);
            [self alertDataWithDict:data bridge:@"cmall_goToEditCutPieces"];
        }));
        return;
    }
#endif
    if (data) {
        [CmallSDK showSDKEditorViewControllerWithEditorInfo:data currentViewController:self];
    }
}

#pragma mark - 其他方法

- (NSString *)generateUrl{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",kTudeSDKDomainBaseUrl,kTUDEDIYWebAppPath];
    return [urlString copy];
}

-(void)loadWebViewWithUrl:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    //    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:kCmallMobileHost]];
    //    if (cookies && cookies.count) {
    //        NSDictionary *requestCookie = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    //        [request addValue:[requestCookie valueForKey:@"Cookie"] forHTTPHeaderField:@"Set-Cookie"];
    //    }
    [self.diyWebView.webView loadRequest:request];
}

- (void)needBackPreviewAndReLogin{
    
}

- (void)backPreview:(UIButton *)button{
    [self.navigationController popViewControllerAnimated:true];
}

//- (void)willScrollToBottom{
//    [self.diyWebView willScrollToBottom];
//}

- (void)popToHome{
    [self.tabBarController setSelectedIndex:0];
    if (self.navigationController.childViewControllers.count > 2) {
        [self.navigationController popToRootViewControllerAnimated:false];
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

#pragma mark - 本地数据测试

- (void)localDataTest{
    NSString *data = @"{\"outLineMaskUrl\":\"https://image.cmall.com/imgsrv/model/upload/Pillow001_3D/Temp/JCQM001.png\",\"nodeName\":\"JCQM001\",\"thumbilFilePath\":\"/storage/emulated/0/Android/data/com.tude.android/cache/1480486797402.png\",\"nodeDesc\":\"JCQM001\",\"materials\":[],\"slitTypeMap\":{\"xaxis\":1,\"picHeight\":510,\"picWidth\":510,\"yaxis\":1,\"isAllowedMask\":false},\"backgroundColor\":\"http://image.cmall.com/imgsrv/impdata/skuColor/M001.png\",\"editorRegionHeight\":512,\"backgroundImageUrl\":null,\"userImage\":{\"matrix\":{\"translateY\":-63.95132258331651,\"translateX\":-1.775479411451379,\"rotate\":0,\"scale\":0.6853889694439955},\"orig_height\":1000,\"useMatrix\":true,\"orig_width\":747,\"remoteImageUrl\":\"diy/320591/1483090923757.png\",\"remoteOriginalImageUrl\":\"diy/320591/1483090923370.png\",\"matrixString\":\"matrix(0.6854,0.0000,0.0000,0.6854,-1.7755,-63.9513)\"},\"mask\":null,\"locationMap\":null,\"editorRegionWidth\":512,\"id\":0,\"texts\":[],\"overranging\":true,\"usePrintingProcess\":false,\"editable\":true,\"thumbilUrl\":\"diy/320591/14832838779648.png\",\"isEditor\":true}";    
    [self handleReceivedEditData:[NSString dictionaryWithJsonString:data]];
}

#pragma mark - Getters And Setters

- (TDDIYWebView *)diyWebView{
    if (!_diyWebView) {
        _diyWebView = [[TDDIYWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _diyWebView;
}

- (BOOL)prefersStatusBarHidden{
    return self.currentActive;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - Private Private

///  详情试图控制器 初始方法.
/// @param goodsId 商品id。自动套版时，该字段为@0。
/// @param sourceType 数据来源。自动套版时，该字段为 TDDIYSourceTypeGoodsList = 1。
/// @param productId 产品id。
/// @param modelClassId 故名思意，模型分类id。
/// @param autoImageUrlString 故名思意，自动套版时的源图url。
/// @param oriWidth 故名思意，自动套版时的源图oriWidth。
/// @param oriHeight 故名思意，自动套版时的源图oriHeight。
+ (instancetype)diyWebViewControllerWithGoodsId:(NSNumber*)goodsId
                                     sourceType:(TDDIYSourceType)sourceType
                                      productId:(NSNumber*)productId
                                   modelClassId:(NSNumber*)modelClassId
                             autoImageUrlString:(NSString*)autoImageUrlString
                                       oriWidth:(NSNumber*)oriWidth
                                      oriHeight:(NSNumber*)oriHeight{
    
    TDDIYWebViewController *vc = [[self alloc] init];
    vc.viewModel = [TDDIYWebViewModel diyWebViewModelWithProductId:productId modelClassId:modelClassId autoImageUrlString:autoImageUrlString oriWidth:oriWidth oriHeight:oriHeight];
    vc.viewModel.webVC = vc;
    return vc;
}

@end
