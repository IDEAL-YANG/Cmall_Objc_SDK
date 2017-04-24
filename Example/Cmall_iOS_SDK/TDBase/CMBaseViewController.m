//
//  BaseViewController.m
//  ImageSuperstore
//
//  Created by Moyun on 14-2-12.
//  Copyright (c) 2014年 Moyun. All rights reserved.
//

#import "CMBaseViewController.h"
#import "CMBaseViewModel.h"
#import "CMLoadingView.h"

@interface CMBaseViewController ()

@property (strong, nonatomic) CMBaseViewModel *viewModel;

@end

@implementation CMBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewModel = [CMBaseViewModel new];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@已经释放" , self);
}

// 指示视图
- (CMLoadingView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[CMLoadingView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _loadingView.centerX = Main_Screen_Width/2;
        _loadingView.centerY = Main_Screen_Height/2;
    }
    return _loadingView;
}

- (void)startLoading{
    if (![self.view.subviews containsObject:self.loadingView]) {
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView startAnimation];
}

- (void)stopLoading{
    [self.loadingView stopAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    RAC(self,navigationItem.title) = RACObserve(self, viewModel.naviTitle);
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *back_img = [UIImage imageNamed:@"back"];
        [leftBtn setImage:back_img forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.frame = CGRectMake(0, 0, back_img.size.width, back_img.size.height);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
}

- (void)backHome:(UIButton *)button
{
    if (self.navigationController.viewControllers && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else{
        [self dismissViewControllerAnimated:true completion:^{
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel.willDisappearSignal sendNext:nil];
    [self stopLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.view.alpha < 1) {
        self.view.alpha = 1;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
