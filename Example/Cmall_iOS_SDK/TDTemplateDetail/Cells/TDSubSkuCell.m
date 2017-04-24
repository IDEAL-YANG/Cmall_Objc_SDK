//
//  TDSubSkuCell.m
//  DIYDemo
//
//  Created by IDEAL YANG on 2017/2/28.
//  Copyright © 2017年 IDEAL YANG. All rights reserved.
//

#import "TDSubSkuCell.h"

@interface TDSubSkuCell ()

@property (strong, nonatomic, readwrite) UIImageView *selectIconImgView;

@property (strong, nonatomic, readwrite) UILabel *nameLabel;

@end

@implementation TDSubSkuCell


- (void)selectedStyleWithSelected:(BOOL)selected{
    self.selectIconImgView.hidden = !selected;
    self.nameLabel.textColor = selected ? HEXCOLOR(0x2aca76): [UIColor grayColor];
}


@end
