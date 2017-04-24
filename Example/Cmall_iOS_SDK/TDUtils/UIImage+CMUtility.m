//
//  UIImage+CMUtility.m
//
//  Created by sho yakushiji on 2013/05/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "UIImage+CMUtility.h"

static NSCache *imageCache;


@implementation UIImage (CMUtility)

+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
    });
    
    UIImage *image = [imageCache objectForKey:color];
    if (image) {
        return image;
    }
    CGRect rect=CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [imageCache setObject:image forKey:color];
    return image;
}

@end
