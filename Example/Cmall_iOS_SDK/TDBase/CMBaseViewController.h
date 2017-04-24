//
//  BaseViewController.h
//  ImageSuperstore
//
//  Created by Moyun on 14-2-12.
//  Copyright (c) 2014年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMLoadingView;
@interface CMBaseViewController : UIViewController

@property (strong, nonatomic) CMLoadingView *loadingView;

- (void)startLoading;

- (void)stopLoading;


@end
