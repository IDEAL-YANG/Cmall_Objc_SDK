//
//  UIImage+CMUtility.h
//
//  Created by sho yakushiji on 2013/05/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CMUtility)

/**
 *  UIColor生成UIImage
 *
 *  @param color     生成的颜色
 *  @param imageSize 生成的图片大小
 *
 *  @return 生成后的图片
 */

+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize;

@end
