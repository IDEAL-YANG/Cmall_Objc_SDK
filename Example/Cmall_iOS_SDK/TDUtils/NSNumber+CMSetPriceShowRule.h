//
//  NSNumber+CMSetPriceShowRule.h
//  Cmall
//
//  Created by ideal on 2016/7/22.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  设置价格的一些显示规则，后端控制的，非要放前端
 */
@interface NSNumber (CMSetPriceShowRule)

- (NSNumber *)getPriceNumber;

@end
