//
//  TDDIYWebView.m
//  Cmall
//
//  Created by Moyun on 2017/2/15.
//  Copyright © 2017年 Moyun. All rights reserved.
//

#import "TDDIYWebView.h"
#import "UIButton+CMPosition.h"

@interface TDDIYWebView ()

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UILabel *tipsLabel;

/**
 素材分组列表
 */
@property (strong, nonatomic) UICollectionView *materialGroupCollectionView;

/**
 素材列表
 */
@property (strong, nonatomic) UICollectionView *materialCollectionView;

/**
 商品详情
 */
@property (strong, nonatomic) UICollectionView *detailCollectionView;

@end

@implementation TDDIYWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.scrollContentView];

        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(@0);
            make.bottom.equalTo(@(-kArtBulbTabbarHeight-6));
        }];
        
        [self addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.leading.top.equalTo(@10);
        }];
        
        UIView *bottomView = [[UIView alloc] init];
        [self addSubview:bottomView];
        bottomView.layer.shadowOffset = CGSizeMake(0, -4);
        bottomView.layer.shadowOpacity = 0.2f;
        bottomView.layer.shadowRadius = 4;
        bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(@0);
            make.height.equalTo(@50);
        }];
        
//        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [saveButton setTitle:@"保存/分享" forState:UIControlStateNormal];
//        [saveButton setTitleColor:HEXCOLOR(0x4a4a4a) forState:UIControlStateNormal];
//        saveButton.titleLabel.font = THEMEFONT(13);
//        [saveButton setImage:[UIImage imageNamed:@"DIY_share_small_gray.png"] forState:UIControlStateNormal];
//        [saveButton setImagePosition:CMImagePositionLeft spacing:10];
//        [bottomView addSubview:saveButton];
        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyButton setTitle:LocalString(@"Buy") forState:UIControlStateNormal];
        buyButton.backgroundColor = HEXCOLOR(0x2aca76);
        buyButton.titleLabel.font = THEMEFONT(13);
        buyButton.tag = TDDIYTagTypeBuyBtn;
        [buyButton setImage:[UIImage imageNamed:@"tabbar_cart_active.png"] forState:UIControlStateNormal];
        [buyButton setImagePosition:CMImagePositionLeft spacing:10];
        [bottomView addSubview:buyButton];

//        [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.top.bottom.equalTo(@0);
//            make.width.equalTo(@(Main_Screen_Width*2/5));
//        }];
        [buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.leading.equalTo(@0);
            make.top.equalTo(@-1);
        }];
        
        UIView *overlayView = [[UIView alloc] init];
        overlayView.tag = 'over';
        overlayView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
        [self addSubview:overlayView];
        [overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(buyButton);
        }];

        CGFloat productHeight = 40 + Main_Screen_Width+ 30 + 5 +itemWidth+10 + 40;
        
        self.productHeight = productHeight;
        //self.productHeight = productHeight < Main_Screen_Height - 50 ? Main_Screen_Height - 50 : productHeight;
        
        [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(@0);
            make.bottom.equalTo(@-1);
            make.centerX.equalTo(@0);
            make.height.equalTo(@(self.productHeight));
        }];
        
        [self.scrollContentView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.leading.trailing.equalTo(@0);
            make.height.equalTo(@(Main_Screen_Width + 40 + 30));
        }];
        /*
        [self.scrollContentView addSubview:self.colorBtn];
        [self.colorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@50);
            make.trailing.equalTo(@-10);
            make.bottom.equalTo(self.webView.mas_bottom).offset(-10);
        }];
        */
        
        UIView *bView = [[UIView alloc] initWithFrame:CGRectMake(Main_Screen_Width-60, Main_Screen_Width-20, 50, 50)];
        bView.layer.shadowOffset = CGSizeMake(0, 2);
        bView.layer.shadowColor = HEXCOLOR(0xe7e7e7).CGColor;
        bView.layer.shadowOpacity = 1.0f;
        //bView.layer.shadowRadius = 10;
        bView.layer.cornerRadius = 25.0f;
        bView.backgroundColor = [UIColor whiteColor];
        bView.layer.borderColor = HEXCOLOR(0xe7e7e7).CGColor;
        bView.layer.borderWidth = .5f;
        bView.tag = 'bvie';
        bView.hidden = true;
        [self.scrollContentView addSubview:bView];
        
        [self.scrollContentView addSubview:self.materialGroupCollectionView];
        [self.materialGroupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.top.equalTo(self.webView.mas_bottom).offset(5);
            make.height.mas_equalTo(50);
        }];
        
        [self.scrollContentView addSubview:self.materialCollectionView];
        [self.materialCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.top.equalTo(self.materialGroupCollectionView).offset(50-1);
            make.height.equalTo(@(itemWidth+10));
        }];
        
        self.tipsLabel = [UILabel new];
        _tipsLabel.text = LocalString(@"上滑查看详情");
        _tipsLabel.font = THEMEFONT(15);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.backgroundColor = [UIColor whiteColor];
        _tipsLabel.textColor = HEXCOLOR(0x6d7989);
        [self.scrollContentView addSubview:_tipsLabel];
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.height.equalTo(@30);
            make.top.equalTo(self.materialCollectionView.mas_bottom).offset(5);
        }];
        
        
        [self.scrollContentView addSubview:self.detailCollectionView];
        [self.detailCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.top.equalTo(@(self.productHeight));
            make.height.equalTo(@(Main_Screen_Height - 50));
        }];
        
        TDSelectSkuAddCartView *cartView = [[TDSelectSkuAddCartView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height, Main_Screen_Width, Main_Screen_Height)];
        cartView.tag = TDDIYTagTypeCartView;
        [self addSubview:cartView];
        
        
        [self.scrollContentView addSubview:self.menuButton];
        
        [self.scrollContentView addSubview:self.menuNameLabel];
        [self.menuNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.menuButton);
            make.bottom.equalTo(self.webView.mas_bottom).offset(-15);
        }];
    }
    return self;
}

- (void)updateContentSize:(CGFloat)height
{
    [self.detailCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
    }];
    [self.scrollContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.productHeight+height));
    }];
}

- (CMDWBubbleMenuButton *)menuButton
{
    if (!_menuButton) {
        _menuButton = [[CMDWBubbleMenuButton alloc] initWithFrame:CGRectMake(Main_Screen_Width-60, Main_Screen_Width-20, 50, 50) expansionDirection:DirectionUp];
        _menuButton.homeButtonView = self.colorBtn;
        _menuButton.backgroundColor = [UIColor whiteColor];
        _menuButton.layer.cornerRadius = 25.0f;
        _menuButton.hidden = true;
        __weak typeof(self) weakSelf = self;
        _menuButton.haveShowed = ^{
            [weakSelf needEnableBuyButton:false];
            UIView *aView = [[UIView alloc] initWithFrame:weakSelf.bounds];
            aView.tag = 'moyu';
            aView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
            [aView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
            [weakSelf.scrollContentView insertSubview:aView belowSubview:weakSelf.menuButton];
            if (weakSelf.scrollView.contentOffset.y > 0) {
                [weakSelf.scrollView setContentOffset:CGPointZero animated:true];
            }
           // [weakSelf.scrollContentView bringSubviewToFront:weakSelf.menuButton];
        };
        _menuButton.haveDissmiss = ^{
            UIView *aView = [weakSelf.scrollContentView viewWithTag:'moyu'];
            [aView removeFromSuperview];
            [weakSelf needEnableBuyButton:true];
        };
    }
    return _menuButton;
}

- (void)needEnableBuyButton:(BOOL)need
{
    UIView *bView = [self viewWithTag:'over'];
    bView.hidden = need;
}

- (void)tapAction:(UIView *)view
{
    [self.menuButton dismissButtons];
}

- (UILabel *)menuNameLabel{
    if (!_menuNameLabel) {
        _menuNameLabel = [[UILabel alloc] init];
        _menuNameLabel.textColor = [UIColor blackColor];
        [_menuNameLabel setFont:SYSTEMFONT(15)];
        _menuNameLabel.hidden = true;
    }
    return _menuNameLabel;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.alwaysBounceVertical = true;
        _scrollView.tag = 'deta';
        _scrollView.backgroundColor = HEXCOLOR(0xe7e7e7);
        _scrollView.showsVerticalScrollIndicator = false;
    }
    return _scrollView;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"DIY_back.png"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backToPrepage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIImageView *)colorBtn
{
    if (!_colorBtn) {
        _colorBtn = [[UIImageView alloc] init];
//        _colorBtn.backgroundColor = [UIColor yellowColor];
        _colorBtn.frame = CGRectMake(10, 10, 30, 30);
        _colorBtn.layer.cornerRadius = 15.0f;
        _colorBtn.layer.masksToBounds = true;
        _colorBtn.layer.hidden = true;
    }
    return _colorBtn;
}

- (void)backToPrepage
{
    if (self.backAction) {
        self.backAction();
    }
//    [[self fetchCurrentNavigationController] popViewControllerAnimated:true];
}

- (UIView *)scrollContentView
{
    if (!_scrollContentView) {
        _scrollContentView = [UIView new];
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollContentView;
}

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
    }
    return _webView;
}

- (UICollectionView *)materialGroupCollectionView{
    if (!_materialGroupCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(80, 25);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        
        _materialGroupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _materialGroupCollectionView.layer.borderColor = HEXCOLOR(0xeef1f8).CGColor;
        _materialGroupCollectionView.layer.borderWidth = 1.0f;
        _materialGroupCollectionView.backgroundColor = [UIColor whiteColor];
        _materialGroupCollectionView.tag = TDDIYTagTypeDesignGroupList;
        [_materialGroupCollectionView registerClass:[TDSubSkuCell class] forCellWithReuseIdentifier:NSStringFromClass([TDSubSkuCell class])];
    }
    return _materialGroupCollectionView;
}

- (UICollectionView *)materialCollectionView
{
    if (!_materialCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = 5.0f;
        layout.minimumInteritemSpacing = 5.0f;
        layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _materialCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        _materialCollectionView.tag = 'mate';
        _materialCollectionView.tag = TDDIYTagTypeDesignList;
        _materialCollectionView.layer.borderColor = HEXCOLOR(0xeef1f8).CGColor;
        _materialCollectionView.layer.borderWidth = 1.0f;
        _materialCollectionView.backgroundColor = [UIColor whiteColor];
        _materialCollectionView.alwaysBounceHorizontal = true;
        [_materialCollectionView registerClass:[TDDesignSKUCell class] forCellWithReuseIdentifier:NSStringFromClass([TDDesignSKUCell class])];
    }
    return _materialCollectionView;
}

- (UICollectionView *)detailCollectionView
{
    if (!_detailCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _detailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _detailCollectionView.backgroundColor = HEXCOLOR(0xe7e7e7);
        _detailCollectionView.alwaysBounceVertical = true;
        _detailCollectionView.tag = TDDIYTagTypeDetailImgsList;
        [_detailCollectionView registerClass:[CMImageViewCell class] forCellWithReuseIdentifier:NSStringFromClass([CMImageViewCell class])];
        
    }
    return _detailCollectionView;
}

#pragma mark - Public method

- (void)scrollViewCannotScroll
{
    self.tipsLabel.hidden = true;
    self.scrollView.scrollEnabled = false;
}

@end
