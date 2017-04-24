//
//  TDSelectSkuAddCartView.h
//  Cmall
//
//  Created by IDEAL YANG on 16/11/4.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSelectSkuAddCartView : UIView

@property(nonatomic, retain)UIView *alphaiView;
@property (nonatomic, strong) UIButton *addCartBtn;

@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, copy) NSString *imageUrlString;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *currencySymbol;
@property (nonatomic, assign) CGFloat price;

@property (nonatomic, assign) NSInteger currentSelectIndex;
@property (nonatomic, assign) NSUInteger currentCount;

@property (nonatomic, copy) NSString *skuTypeName;
@property (nonatomic, strong) NSArray<NSString*> *skuNames;

@property (nonatomic, copy) void (^clickAddToCartBtn)();

@end

@interface TDSkuCell : UICollectionViewCell

- (void)configCellWithText:(NSString *)text selected:(BOOL)selected;

@end

@interface TDSkuTypeRV : UICollectionReusableView

- (void)configTypeRVWithText:(NSString *)text;

@end
