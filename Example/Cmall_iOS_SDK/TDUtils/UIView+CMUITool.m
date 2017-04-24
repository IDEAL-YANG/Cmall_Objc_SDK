//
//  UIView+CMUITool.m
//  BeeLoveds
//
//  Created by Moyun on 14-1-7.
//  Copyright (c) 2014年 Moyun. All rights reserved.
//

#import "UIView+CMUITool.h"
#import <objc/runtime.h>

static char kMoyunTapActionKey;
static char kMoyunTapBlockKey;

@implementation UIView (CMUITool)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


- (CABasicAnimation *)fadeIn
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.35;
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:0.8f];
    return animation;
}

- (CABasicAnimation *)fadeOut
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.2;
    animation.fromValue = [NSNumber numberWithFloat:0.8f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    return animation;
}

- (UIViewController *) containingViewController {
    UIView * target = self.superview ? self.superview : self;
    return (UIViewController *)[target traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    BOOL isViewController = [nextResponder isKindOfClass:[UIViewController class]];
    BOOL isTabBarController = [nextResponder isKindOfClass:[UITabBarController class]];
    if (isViewController && !isTabBarController) {
        return nextResponder;
    } else if(isTabBarController){
        UITabBarController *tabBarController = nextResponder;
        return [tabBarController selectedViewController];
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}


- (UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(Main_Screen_Width, [UIScreen mainScreen].bounds.size.height), NO, [UIScreen mainScreen].scale);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:false];
//        NSInvocation* invoc = [NSInvocation invocationWithMethodSignature:
//                               [self methodSignatureForSelector:
//                                @selector(drawViewHierarchyInRect:afterScreenUpdates:)]];
//        [invoc setTarget:self];
//        [invoc setSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)];
//        CGRect arg2 = self.bounds;
//        BOOL arg3 = YES;
//        [invoc setArgument:&arg2 atIndex:2];
//        [invoc setArgument:&arg3 atIndex:3];
//        [invoc invoke];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIView*)createALineViewWithLineColor:(UIColor*)lineColor
                             lineWidth:(CGFloat)lineWidth
{
    UIView * lineView = [[UIView alloc] init];
    lineView.layer.borderColor = lineColor.CGColor;
    lineView.layer.borderWidth = lineWidth;
    return lineView;
}

+ (void)drawLineDashWithFirstPoint:(CGPoint)firstPoint endPoint:(CGPoint)endPoint
{
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    CGContextBeginPath(contextRef);
//    CGContextSetLineWidth(contextRef, 1.0f);
//    CGContextSetStrokeColorWithColor(contextRef, RGBCOLOR(200, 200, 200).CGColor);
//    float lengths[] = {5,5};
//    CGContextSetLineDash(contextRef, 0, lengths, 5);
//    CGContextMoveToPoint(contextRef, firstPoint.x, firstPoint.y);
//    CGContextAddLineToPoint(contextRef, endPoint.x, endPoint.y);
//    CGContextStrokePath(contextRef);
//    CGContextClosePath(contextRef);
}

- (void)setTapAction:(void(^)(void))block
{
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &kMoyunTapActionKey);
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, &kMoyunTapActionKey, tap, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &kMoyunTapBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        void (^action)(void) = objc_getAssociatedObject(self, &kMoyunTapBlockKey);
        if (action) {
            action();
        }
    }
}

- (UIView *)findSuperViewWithClass:(Class)superViewClass
{
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    while (superView != nil && foundSuperView == nil) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}

- (NSLayoutConstraint *)constraintWidth:(CGFloat)width
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:0
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1.0f
                                         constant:width];
}

- (NSLayoutConstraint *)constraintHeight:(CGFloat)height
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:0
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1.0f
                                         constant:height];
}


- (NSLayoutConstraint *)constraintCenterYEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeCenterY
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeCenterY
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintCenterXEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeCenterX
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeCenterX
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintHeightEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeHeight
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintWidthEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeWidth
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintTopEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeTop
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintBottomEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeBottom
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeBottom
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintLeftEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeLeft
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeLeft
                                       multiplier:1.0f
                                         constant:0.0f];
}

- (NSLayoutConstraint *)constraintRightEqualToView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:NSLayoutAttributeRight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:view
                                        attribute:NSLayoutAttributeRight
                                       multiplier:1.0f
                                         constant:0.0f];
}



- (NSArray *)constraintArrayFillHeightInSuperview
{
    UIView *view = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                   options:0
                                                   metrics:nil
                                                     views:NSDictionaryOfVariableBindings(view)];
}

- (NSArray *)constraintArrayFillWidthInSuperview
{
    UIView *view = self;
    return [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
                                                   options:0
                                                   metrics:nil
                                                     views:NSDictionaryOfVariableBindings(view)];
}





@end
