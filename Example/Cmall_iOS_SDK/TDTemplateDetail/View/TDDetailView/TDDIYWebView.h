//
//  TDDIYWebView.h
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>
#import "CMDWBubbleMenuButton.h"
#import "TDSubSkuCell.h"
#import "TDDesignSKUCell.h"
#import "CMImageViewCell.h"

#import "TDSelectSkuAddCartView.h"

typedef NS_ENUM(NSInteger, TDDIYSourceType) {
    TDDIYSourceTypeGoodsList=1,
    TDDIYSourceTypeDesignList=2//暂不开发
};

typedef NS_ENUM(NSInteger, TDDIYTagType) {
    TDDIYTagTypeDesignGroupList=99800,
    TDDIYTagTypeDesignList=99801,
    TDDIYTagTypeDetailImgsList=99802,
    
    TDDIYTagTypeFirstSkuBtn = 99901,
    TDDIYTagTypeCartView = 99902,
    TDDIYTagTypeBuyBtn = 99903
};

static CGFloat const itemWidth = 80;

@interface TDDIYWebView : UIView

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIView *scrollContentView;

@property (assign, nonatomic) CGFloat productHeight;

@property (strong, nonatomic) CMDWBubbleMenuButton *menuButton;

@property (strong, nonatomic) UILabel *menuNameLabel;

@property (strong, nonatomic) UIImageView *colorBtn;

@property (copy, nonatomic)void (^backAction)();

- (void)needEnableBuyButton:(BOOL)need;

- (void)scrollViewCannotScroll;

- (void)updateContentSize:(CGFloat)height;

@end
