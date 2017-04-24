//
//  TDQuntityView.h
//  Cmall
//
//  Created by IDEAL YANG on 16/11/7.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetQuantity)(NSUInteger quantity);

@interface TDQuntityView : UIView

@property (strong, nonatomic) GetQuantity getQuantityBlock;

@property (assign, nonatomic) NSUInteger minQuantity;
@property (assign, nonatomic) NSUInteger maxQuantity;

@end
