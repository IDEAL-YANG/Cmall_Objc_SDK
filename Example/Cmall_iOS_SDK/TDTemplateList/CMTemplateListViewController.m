//
//  CMBaseWebViewController.m
//  Cmall
//
//  Created by IDEAL YANG on 16/9/19.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "CMTemplateListViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"

#import "UIAlertController+CMCreate.h"

#import "CMTabbarView.h"
#import "CMLoadingView.h"

#import "TDDIYWebViewController.h"

#import "NSString+CMJSONConvert.h"

#import "WKWebViewJavascriptBridge+CmallSDKListBridge.h"

@interface CMTemplateListViewController ()<WKNavigationDelegate,WKUIDelegate,CMTabbarViewDelegate,CMTabbarViewDatasouce>

@property (strong, nonatomic) CMTabbarView *tabbarView;
@property (strong, nonatomic) NSArray *datas;
@property (assign, nonatomic) NSInteger currentSelected;

@property (strong, nonatomic) WKWebView *webView;

@property (nonatomic,strong) NSString *url;

@property (strong, nonatomic) WKWebViewJavascriptBridge *bridge;

@end

@implementation CMTemplateListViewController

+ (CMTemplateListViewController *)webViewControllerWithURLString:(NSString *)urlString{
    CMTemplateListViewController *webViewController = [CMTemplateListViewController new];
    webViewController.url = urlString;
    return webViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    [self commontUI];
    
    [self registerBridge];
    
    [self bindViewModel];
    
    [self loadWebView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopLoading];
    [self.bridge setWebViewDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)commontUI{
    self.title = LocalString(@"照片定制");
    [self.view setBackgroundColor:HEXCOLOR(0xf4f4f4)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"tude_sdk_diy_list_left_navigation_item_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backHome:)];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.tabbarView];
    [self.view addSubview:self.loadingView];
}

- (void)registerBridge{
    
    @weakify(self);
    
    [self.bridge cmall_callGlobalConfig:nil];
    
    [self.bridge cmall_callCategories:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        [self stopLoading];
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.imgInfoDict];
            [dict setValue:[data valueForKey:@"picWidth"] forKey:@"picWidth"];
            [dict setValue:[data valueForKey:@"picHeight"] forKey:@"picHeight"];
            self.imgInfoDict = [dict copy];
            
            self.datas = [data valueForKey:@"items"];
            
            LBDispatch_main_async_safe(^{
                [self.tabbarView reloadData];
                [UIView animateWithDuration:0.5 animations:^{
                    self.webView.scrollView.contentInset = UIEdgeInsetsMake(kNavigationBarHeight+kStatusBarHeight+kArtBulbTabbarHeight, 0, 0, 0);
                    self.webView.scrollView.contentOffset = CGPointMake(0, -(kNavigationBarHeight+kStatusBarHeight+kArtBulbTabbarHeight));
                }];
            });
        }else{
            DLog(@"Api错误");
        }
    }];
    [self.bridge cmall_callcurrentcategory:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        if ([data isKindOfClass:[NSDictionary class]]) {
            LBDispatch_main_async_safe(^{
                NSInteger index = [[data valueForKey:@"index"] integerValue];
                if (self.currentSelected != index) {
                    self.currentSelected = index;
                    [self.tabbarView setTabIndex:index animated:true];
                }
            });
        }else{
            DLog(@"Api错误");
        }
    }];
    
    [self.bridge cmall_callgetuserimg:self.imgInfoDict handler:nil];
    
    [self.bridge cmall_callrModel3d:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSNumber *haveGoods = data[@"isCreateGoods"];
            if ([haveGoods integerValue] != 1) {
                [UIAlertController alertWithTitle:@"温馨提示" message:@"该模型下无对应商品" cancelTitle:@"好哒" inViewCtl:self];
                return;
            }
            NSNumber *productId = data[@"productId"];
            NSNumber *modelClassId = data[@"modelClassId"];
            
            LBDispatch_main_async_safe(^{
                @strongify(self);
                TDDIYWebViewController *vc = [TDDIYWebViewController diyWebViewControllerWithProductId:productId modelClassId:modelClassId autoImageUrlString:self.imgInfoDict[@"picUrl"] oriWidth:self.imgInfoDict[@"picWidth"] oriHeight:self.imgInfoDict[@"picHeight"]];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }else{
            DLog(@"Api错误");
        }
    }];
    
    [self.bridge cmall_needBackPreviewAndReLogin:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        [self stopLoading];
        DLog(@"==cmall_needBackPreviewAndReLogin:%@==",data);
        [self modelLoadedWithData:data];
        responseCallback(@"==cmall_needBackPreviewAndReLogin_response_from_ios==");
    }];
}

- (void)bindViewModel{
    @weakify(self);
    [[[RACObserve(self, webView.URL) skip:1] deliverOnMainThread] subscribeNext:^(NSURL *value) {
        @strongify(self);
        NSLog(@"==******url:%@",value);
        if (!value && ![self.url hasPrefix:@"http://"]) {
            [self loadWebView];
        }
    }];
}

- (void)loadWebView{
    [self loadURL];
}

#pragma mark - CMTabbarView Delegate & dataSource

- (NSArray<NSString *> *)tabbarTitlesForTabbarView:(CMTabbarView *)tabbarView
{
    return [self.datas valueForKey:@"name"];
}

- (void)tabbarView:(CMTabbarView *)tabbarView didSelectedAtIndex:(NSInteger)index
{
    NSDictionary *infoDic = self.datas[index];
    NSDictionary *param = @{@"index":@(index),@"modelTypeId":infoDic[@"modelTypeId"]};
    [self.bridge cmall_getcategory:param handler:nil];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if (![[webView.URL host] containsString:@".cmall.com"]) {
        [UIAlertController alertWithTitle:@"温馨提示" message:@"你当前访问的网址非法" cancelTitle:@"好哒" inViewCtl:self];
    }
    decisionHandler([[webView.URL host] containsString:@".cmall.com"]);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    DLog(@"==error:%@",error);
    [self stopLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    DLog(@"==error:%@",error);
    [self stopLoading];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"将要白屏了，这里reload一下webView");
}

#pragma mark - Methods

-(void)loadURL
{
    [self startLoading];
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (BOOL)checkResponseData:(id)data{
    if(data && [data isKindOfClass:[NSDictionary class]] && data[@"code"] && [data[@"code"] integerValue] == 200){
        return true;
    }
    return false;
}

- (void)modelLoadedWithData:(id)data{
    if (![self checkResponseData:data]) {
        @weakify(self);
        LBDispatch_main_async_safe((^(){
            @strongify(self);
            [self alertDataWithDict:data bridge:@"cmall_needBackPreviewAndReLogin"];
        }));
    }
}

- (void)alertDataWithDict:(id)data bridge:(NSString*)bridge{
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


#pragma mark - Getters And Setters

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, Main_Screen_Height)];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.bounces = true;
        _webView.scrollView.directionalLockEnabled = true;
    }
    return _webView;
}

- (CMTabbarView *)tabbarView
{
    if (!_tabbarView) {
        _tabbarView = [[CMTabbarView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+kStatusBarHeight, Main_Screen_Width, kArtBulbTabbarHeight)];
        _tabbarView.dataSource = self;
        _tabbarView.delegate = self;
    }
    return _tabbarView;
}


@end
