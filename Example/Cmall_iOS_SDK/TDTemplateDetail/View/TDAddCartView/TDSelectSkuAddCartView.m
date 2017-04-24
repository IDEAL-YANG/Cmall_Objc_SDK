//
//  TDSelectSkuAddCartView.m
//  Cmall
//
//  Created by IDEAL YANG on 16/11/4.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "TDSelectSkuAddCartView.h"
#import "UIImage+CMUtility.h"
#import "TDQuntityView.h"
#import "NSURL+CMAddImageBaseURL.h"
#import "NSNumber+CMSetPriceShowRule.h"

@interface TDSelectSkuAddCartView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UICollectionView *skuCollectionView;
@property (nonatomic, strong) TDQuntityView *quntityView;

@end

@implementation TDSelectSkuAddCartView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.currentSelectIndex = -1;
        self.currentCount = 1;
        
        //半透明视图
        self.alphaiView = [[UIView alloc] init];
        self.alphaiView.backgroundColor = [UIColor blackColor];
        self.alphaiView.alpha = 0.0;
        [self addSubview:self.alphaiView];
        [self.alphaiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        //装载商品信息的视图
        self.whiteView = [[UIView alloc] init];
        self.whiteView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.whiteView];
        [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(0);
            make.height.mas_equalTo(300);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = HEXCOLOR(0xCCCCCC);
        [self.whiteView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(0);
            make.height.mas_equalTo(1/Main_Screen_Scale);
        }];
        
        [self.whiteView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(18);
            make.top.mas_equalTo(15);
            make.width.height.mas_equalTo(70);
        }];
        
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"diy_list_backg"];
        [self.imageView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        
        [self.whiteView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.imageView.mas_trailing).mas_offset(10);
            make.top.equalTo(self.imageView);
            make.height.mas_equalTo(45);
            make.trailing.mas_equalTo(-8);
        }];
        
        [self.whiteView addSubview:self.priceLabel];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.height.mas_equalTo(25);
        }];
        
        [self.whiteView addSubview:self.quntityView];
        
        [self.whiteView addSubview:self.addCartBtn];
        [self.addCartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15);
            make.trailing.mas_equalTo(-20);
            make.width.mas_equalTo(CGRectGetWidth(frame)*0.5 - 20);
            make.height.mas_equalTo(40);
        }];
        
        [self.whiteView addSubview:self.skuCollectionView];
        [self.skuCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(8);
            make.trailing.mas_equalTo(-8);
            make.top.equalTo(self.imageView.mas_bottom).mas_offset(8);
            make.bottom.equalTo(self.addCartBtn.mas_top).mas_offset(-8);
        }];
        
        @weakify(self);
        self.quntityView.getQuantityBlock = ^(NSUInteger quantity){
            @strongify(self);
            if (quantity == 0) {
                self.addCartBtn.enabled = false;
            }else{
                self.currentCount = quantity;
                self.addCartBtn.enabled = true;
            }
        };
        /*
        [self.imageView setTapAction:^{
            @strongify(self);
            IDMPhoto *phonto;
            if (self.imageUrlString) {
                phonto = [[IDMPhoto alloc] initWithURL:[[NSURL URLWithString:self.imageUrlString] addImageBaseURL]];
                phonto.placeholderImage = self.imageView.image;
            }else{
                phonto = [[IDMPhoto alloc] initWithImage:self.previewImage];
            }
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[phonto] animatedFromView:self.imageView];
            browser.displayToolbar = NO;
            browser.displayDoneButton = NO;
            browser.usePopAnimation = YES;
            browser.forceHideStatusBar = YES;
            browser.dismissOnTouch = true;
            browser.useWhiteBackgroundColor = true;
            [[[self fetchCurrentNavigationController] topViewController] presentViewController:browser animated:YES completion:nil];
        }];
         */
    }
    return self;
}

- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex{
    _currentSelectIndex = currentSelectIndex;
    
    [self.skuCollectionView reloadData];
}

- (void)setSkuTypeName:(NSString *)skuTypeName{
    _skuTypeName = skuTypeName;
    
    [self.skuCollectionView reloadData];
}

- (void)setSkuNames:(NSArray<NSString *> *)skuNames{
    _skuNames = skuNames;
    
    [self.skuCollectionView reloadData];
}

- (void)setPreviewImage:(UIImage *)previewImage{
    _previewImage = previewImage;
    if (previewImage) {
        self.imageView.image = previewImage;
    }
}

- (void)setImageUrlString:(NSString *)imageUrlString{
    _imageUrlString = imageUrlString;
    if (imageUrlString) {
    }
}

- (void)setName:(NSString *)name{
    _name = name;
    self.nameLabel.text = name?:@"";
}

- (void)setPrice:(CGFloat)price{
    _price = price;
    [self setupPrice];
}

- (void)setCurrencySymbol:(NSString *)currencySymbol{
    _currencySymbol = currencySymbol;
    [self setupPrice];
}

- (void)setupPrice{
    self.priceLabel.text = [NSString stringWithFormat:@"%@ %@",_currencySymbol,[[NSNumber numberWithFloat:_price] getPriceNumber]];
}

- (void)addToCartBtnAction{
    BLOCK_EXEC(self.clickAddToCartBtn);
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.skuNames?self.skuNames.count:0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TDSkuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TDSkuCell class]) forIndexPath:indexPath];
    
    [cell configCellWithText:self.skuNames[indexPath.item] selected:self.currentSelectIndex == indexPath.item];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    TDSkuTypeRV *typeRV = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([TDSkuTypeRV class]) forIndexPath:indexPath];
    [typeRV configTypeRVWithText:self.skuTypeName];
    return typeRV;
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize stringSize = [self.skuNames[indexPath.item] sizeWithAttributes:@{NSFontAttributeName:THEMEFONT(15)}];
    CGSize size = CGSizeMake(stringSize.width + 35, 30);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return self.skuTypeName ? CGSizeMake(CGRectGetWidth(collectionView.frame), 40) : CGSizeZero;
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item != self.currentSelectIndex) {
        self.currentSelectIndex = indexPath.item;
        [collectionView reloadData];
    }
}

#pragma mark - 

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = THEMEFONT(18);
    }
    return _nameLabel;
}

- (UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = THEMEFONT(18);
    }
    return _priceLabel;
}

- (UIButton *)addCartBtn{
    if (!_addCartBtn) {
        _addCartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCartBtn.titleLabel setFont:THEMEFONT(17)];
        [_addCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addCartBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_addCartBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor blackColor] size:CGSizeMake(1, 40)] forState:UIControlStateNormal];
        ViewRadius(_addCartBtn, 20);
        [_addCartBtn setTitle:LocalString(@"去购买") forState:UIControlStateNormal];
        [_addCartBtn addTarget:self action:@selector(addToCartBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addCartBtn;
}

- (UICollectionView *)skuCollectionView{
    if (!_skuCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 8.0f;
        layout.minimumLineSpacing = 10.0f;
        
        _skuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _skuCollectionView.backgroundColor = [UIColor whiteColor];
        [_skuCollectionView registerClass:[TDSkuCell class] forCellWithReuseIdentifier:NSStringFromClass([TDSkuCell class])];
        [_skuCollectionView registerClass:[TDSkuTypeRV class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([TDSkuTypeRV class])];
        _skuCollectionView.dataSource = self;
        _skuCollectionView.delegate = self;
    }
    return _skuCollectionView;
}

- (TDQuntityView *)quntityView{
    if (!_quntityView) {
        _quntityView = [[TDQuntityView alloc] initWithFrame:CGRectMake(18, 300 - 40 - 15, Main_Screen_Width * 0.5 - 36, 40)];
        ViewBorderRadius(_quntityView, 20, 1.0/Main_Screen_Scale, [UIColor blackColor]);
        _quntityView.backgroundColor = [UIColor blackColor];
    }
    return _quntityView;
}

@end


@interface TDSkuCell ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TDSkuCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)configCellWithText:(NSString *)text selected:(BOOL)selected{
    self.textLabel.text = text;
    if (selected) {
        self.textLabel.backgroundColor = [UIColor blackColor];
        self.textLabel.textColor = [UIColor whiteColor];
    }else{
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - 

- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = THEMEFONT(15);
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        ViewBorderRadius(_textLabel, CGRectGetHeight(self.frame)*0.5, 1.0/Main_Screen_Scale, [UIColor blackColor]);
    }
    return _textLabel;
}

@end

@interface TDSkuTypeRV ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TDSkuTypeRV

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)configTypeRVWithText:(NSString *)text{
    self.textLabel.text = text;
}

#pragma mark -

- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = THEMEFONT(15);
        _textLabel.textColor = [UIColor blackColor];
    }
    return _textLabel;
}

@end

