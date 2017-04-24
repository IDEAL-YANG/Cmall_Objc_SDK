//
//  CMLoadingView.m
//  LightBulb
//
//  Created by Moyun on 15/5/23.
//  Copyright (c) 2015年 Moyun. All rights reserved.
//

#import "CMLoadingView.h"

@interface CMLoadingView ()

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation CMLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imgView];
    }
    return self;
}

- (void)startAnimation
{
    if (!self.imgView.isAnimating) {
        [self.imgView startAnimating];
    }
}

- (void)stopAnimation
{
    if (self.imgView.isAnimating) {
        [self.imgView stopAnimating];
    }
    [self removeFromSuperview];
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.frame];
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:6];
        for (NSUInteger index = 1; index < 7; index++) {
            @autoreleasepool {
                UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"loading%lu",(unsigned long)index]];
                if (img) {
                    [imgs addObject:img];
                }
            }
        }
        _imgView.animationImages = imgs;
        _imgView.animationDuration = 3;
    }
    return _imgView;
}

- (instancetype)init
{
    NSAssert(NO, @"Please use initWithFrame");
    return nil;
}

@end
