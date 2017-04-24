//
//  CMImageViewCell.m
//  Meituxiuxiu
//
//  Created by Moyun on 2016/12/28.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import "CMImageViewCell.h"
#import "NSURL+CMAddImageBaseURL.h"

@implementation CMImageViewCell

- (NSURL*)imageUrlWithString:(NSString*)imgUrlString{
    NSURL *imgUrl = [[[NSURL URLWithString:imgUrlString] addImageBaseURL] addSuffixWithString:[NSString stringWithFormat:@"?imageView2/0/q/60"]];
    return imgUrl;
}

@end
