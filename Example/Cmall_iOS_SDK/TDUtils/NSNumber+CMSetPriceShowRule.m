//
//  NSNumber+CMSetPriceShowRule.m
//  Cmall
//
//  Created by ideal on 2016/7/22.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "NSNumber+CMSetPriceShowRule.h"

@implementation NSNumber (CMSetPriceShowRule)

- (NSNumber *)getPriceNumber{
    if (![self isKindOfClass:[NSNumber class]]) {
        return self;
    }
    CGFloat priceFloat = [self floatValue];
    NSInteger priceInt = [self integerValue];
    
    if (priceFloat == priceInt) {
        return [NSNumber numberWithInteger:priceInt];
    }else{
        return [NSNumber numberWithFloat:priceFloat];
    }
}

@end
