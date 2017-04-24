//
//  UIButton+CMPosition.h
//  Cmall
//
//  Created by Moyun on 16/4/18.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMImagePosition) {
    CMImagePositionLeft = 0,              //图片在左，文字在右，默认
    CMImagePositionRight = 1,             //图片在右，文字在左
    CMImagePositionTop = 2,               //图片在上，文字在下
    CMImagePositionBottom = 3,            //图片在下，文字在上
};

@interface UIButton (CMPosition)

/**
 *  设置Button图片和文字的位置关系
 *
 *  @param imagePosition imagePosition
 *  @param spacing       图片和文字的间距
 */
- (void)setImagePosition:(CMImagePosition)imagePosition spacing:(CGFloat)spacing;

/**
 *  title label 的点击事件
 *  default is nil, call setTitleLabelTapTarget:action:
 */
@property(nonatomic, strong, readonly)UITapGestureRecognizer * titleLabelTapGesture;


/**
 *  设置titlelabel点击事件的接收者和事件
 */
-(void)setTitleLabelTapTarget:(id)target action:(SEL)sel;

@end
