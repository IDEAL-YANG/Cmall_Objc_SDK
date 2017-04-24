//
//  CMBaseWebViewController.h
//  Cmall
//
//  Created by IDEAL YANG on 16/9/19.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "CMBaseViewController.h"

@interface CMTemplateListViewController : CMBaseViewController

@property (nonatomic, strong) NSDictionary *imgInfoDict;


+ (CMTemplateListViewController *)webViewControllerWithURLString:(NSString *)urlString;

@end
