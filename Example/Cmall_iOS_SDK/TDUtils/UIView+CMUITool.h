//
//  UIView+CMUITool.h
//  BeeLoveds
//
//  Created by Moyun on 14-1-7.
//  Copyright (c) 2014年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CMUITool)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

- (CABasicAnimation *)fadeIn;

- (CABasicAnimation *)fadeOut;
/**
 *  View 截图
 *
 *  @return UIImage
 */
- (UIImage *)screenshot;

- (UIViewController *) containingViewController;

+ (UIView*)createALineViewWithLineColor:(UIColor*)lineColor
                              lineWidth:(CGFloat)lineWidth;
+ (void)drawLineDashWithFirstPoint:(CGPoint)firstPoint endPoint:(CGPoint)endPoint;

- (void)setTapAction:(void(^)(void))block;

- (UIView *)findSuperViewWithClass:(Class)superViewClass;

/**
 *  根据给定数值设置宽
 *
 *  @param width width
 *
 *  @return NSLayoutConstraint
 */
- (NSLayoutConstraint *)constraintWidth:(CGFloat)width;
/**
 *  根据给定数值设置高
 *
 *  @param height height
 *
 *  @return NSLayoutConstraint
 */
- (NSLayoutConstraint *)constraintHeight:(CGFloat)height;
/**
 *  设置中心X位置
 *
 *  @param view view
 *
 *  @return NSLayoutConstraint
 */
- (NSLayoutConstraint *)constraintCenterXEqualToView:(UIView *)view;
/**
 *  设置中心Y位置
 *
 *  @param view view
 *
 *  @return NSLayoutConstraint
 */
- (NSLayoutConstraint *)constraintCenterYEqualToView:(UIView *)view;
/**
 *  根据其他View的位置来设置长和宽
 *
 *  @param view view
 *
 *  @return NSLayoutConstraint
 */
- (NSLayoutConstraint *)constraintHeightEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintWidthEqualToView:(UIView *)view;


/* 上下左右与其它view对齐 */
- (NSLayoutConstraint *)constraintTopEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintBottomEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintLeftEqualToView:(UIView *)view;
- (NSLayoutConstraint *)constraintRightEqualToView:(UIView *)view;

/* 横向或纵向填充整个屏幕 */
- (NSArray *)constraintArrayFillHeightInSuperview;
- (NSArray *)constraintArrayFillWidthInSuperview;



@end
