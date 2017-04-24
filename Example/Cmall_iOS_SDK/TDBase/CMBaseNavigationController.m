//
//  CMBaseNavigationController.m
//  LightBulb
//
//  Created by Moyun on 14/12/21.
//  Copyright © 2014年 Moyun. All rights reserved.
//

#import "CMBaseNavigationController.h"
#import <sys/timeb.h>

static long long tudeTheTime = 0;

@interface CMBaseNavigationController ()

@end

@implementation CMBaseNavigationController

+ (BOOL)tudeNavIsClickSoFast{
    struct timeb  nowTime;
    ftime(&nowTime);
    
    long long pushTime = nowTime.millitm + nowTime.time * 1000;
    
    BOOL isfast = (llabs(pushTime - tudeTheTime) < 500);
    
    tudeTheTime = pushTime;
    
    return isfast;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([CMBaseNavigationController tudeNavIsClickSoFast]) {
        return ;
    }
    if (!animated) {
        tudeTheTime = 0;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if ([CMBaseNavigationController tudeNavIsClickSoFast]) {
        return nil;
    }
    if (!animated) {
        tudeTheTime = 0;
    }
    UIViewController *v = [super popViewControllerAnimated:animated];
    return v;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([CMBaseNavigationController tudeNavIsClickSoFast]) {
        return nil;
    }
    if (!animated) {
        tudeTheTime = 0;
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([CMBaseNavigationController tudeNavIsClickSoFast]) {
        return nil;
    }
    if (!animated) {
        tudeTheTime = 0;
    }
    NSArray *arr = [super popToViewController:viewController animated:animated];
    return arr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
