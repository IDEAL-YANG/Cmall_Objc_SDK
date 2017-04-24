//
//  TDDIYWebViewDatasource.h
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "TDDIYWebViewController.h"

@interface TDDIYWebViewDatasource : NSObject<UICollectionViewDelegate,UICollectionViewDataSource,WKUIDelegate,UIScrollViewDelegate,WKNavigationDelegate>

@property (weak, nonatomic) TDDIYWebViewController *webVC;

@end
