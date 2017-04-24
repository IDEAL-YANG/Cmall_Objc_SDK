//
//  TDDesignSKUCell.h
//  DIYDemo
//
//  Created by IDEAL YANG on 2017/2/24.
//  Copyright © 2017年 IDEAL YANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDDesignSKUCell : UICollectionViewCell


@property (strong, nonatomic, readonly) UIImageView *imgView;

@property (strong, nonatomic, readonly) UIImageView *selectIconImgView;

@property (strong, nonatomic, readonly) UILabel *nameLabel;


- (void)configCellWithImageUrl:(NSString*)imgUrlString;

- (void)configCellWithImageUrl:(NSString*)imgUrlString selected:(BOOL)selected;

- (void)configCellWithName:(NSString*)name selected:(BOOL)selected;

@end
