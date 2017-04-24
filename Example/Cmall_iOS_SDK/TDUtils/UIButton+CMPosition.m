
//
//  UIButton+CMPosition.m
//  Cmall
//
//  Created by Moyun on 16/4/18.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "UIButton+CMPosition.h"

#import <objc/runtime.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define SS_SINGLELINE_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;
#else
#define SS_SINGLELINE_TEXTSIZE(text, font) [text length] > 0 ? [text sizeWithFont:font] : CGSizeZero;
#endif

@implementation UIButton (CMPosition)

-(void)setTitleLabelTapTarget:(id)target action:(SEL)sel{
    if (target && sel) {
        self.titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = self.titleLabelTapGesture;
        if (!tap) {
            tap = [[UITapGestureRecognizer alloc]initWithTarget:target action:sel];
            [self.titleLabel addGestureRecognizer:tap];
        }else{
            [tap addTarget:target action:sel];
        }
    }
    
}

-(UITapGestureRecognizer *)titleLabelTapGesture{
    return objc_getAssociatedObject(self, "titleLabelTapGesture");
}

- (void)setImagePosition:(CMImagePosition)imagePosition spacing:(CGFloat)spacing
{
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    CGSize titleSize = SS_SINGLELINE_TEXTSIZE([self titleForState:UIControlStateNormal], self.titleLabel.font);
    
    switch (imagePosition) {
        case CMImagePositionLeft: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
            break;
        }
        case CMImagePositionRight: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, 0, imageSize.width + spacing);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width + spacing, 0, - titleSize.width);
            break;
        }
        case CMImagePositionTop: {
            // lower the text and push it left so it appears centered
            //  below the image
            self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (imageSize.height + spacing), 0);
            
            // raise the image and push it right so it appears centered
            //  above the text
            self.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0, 0, - titleSize.width);
            break;
        }
        case CMImagePositionBottom: {
            self.titleEdgeInsets = UIEdgeInsetsMake(- (imageSize.height + spacing), - imageSize.width, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, - (titleSize.height + spacing), - titleSize.width);
            break;
        }
    }
}

@end
