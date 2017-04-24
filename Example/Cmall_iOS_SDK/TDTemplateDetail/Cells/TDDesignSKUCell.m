//
//  TDDesignSKUCell.m
//  DIYDemo
//
//  Created by IDEAL YANG on 2017/2/24.
//  Copyright © 2017年 IDEAL YANG. All rights reserved.
//

#import "TDDesignSKUCell.h"
#import "NSURL+CMAddImageBaseURL.h"
#import "UIImageView+CMUIActivityIndicatorForSDWebImage.h"

@interface TDDesignSKUCell ()

@property (strong, nonatomic, readwrite) UIImageView *imgView;

@property (strong, nonatomic, readwrite) UIImageView *selectIconImgView;

@property (strong, nonatomic, readwrite) UILabel *nameLabel;

@end

@implementation TDDesignSKUCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commitInitViews];
    }
    return self;
}

-(void)commitInitViews{
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectIconImgView];
    [self layoutByCustom];
}

#pragma mark - 子类可以重载这些方法，自定义布局和数据加工，不需要调用super

-(void)layoutByCustom{
    [self layoutImageView];
    [self layoutNameLabel];
    [self layoutSelectIconImgView];
}

-(void)layoutImageView{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)layoutNameLabel{
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)layoutSelectIconImgView{
    [self.selectIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.top.trailing.mas_equalTo(0);
    }];
}

- (NSURL*)imageUrlWithString:(NSString*)imgUrlString{
    NSURL *imgURL = [[[NSURL URLWithString:imgUrlString?:@""] addImageBaseURL] addSuffixWithString:[NSString stringWithFormat:@"?imageView2/0/w/%.0f",80 * Main_Screen_Scale]];
    return imgURL;
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle{
    return UIActivityIndicatorViewStyleGray;
}

- (void)selectedStyleWithSelected:(BOOL)selected{
    self.selectIconImgView.hidden = !selected;
    ViewBorderRadius(self, 0, 1.0, selected ? HEXCOLOR(0x2aca76):[UIColor groupTableViewBackgroundColor]);
}

#pragma mark -

- (void)configCellWithImageUrl:(NSString*)imgUrlString{
    [self configCellWithImageUrl:imgUrlString selected:false];
}

- (void)configCellWithImageUrl:(NSString*)imgUrlString selected:(BOOL)selected{
    [self configCellWithImageUrl:imgUrlString name:nil selected:selected];
}

- (void)configCellWithName:(NSString*)name selected:(BOOL)selected{
    [self configCellWithImageUrl:nil name:name selected:selected];
}

- (void)configCellWithImageUrl:(NSString*)imgUrlString name:(NSString*)name selected:(BOOL)selected{
    if (imgUrlString) {
        [self.imgView setImageWithURL:[self imageUrlWithString:imgUrlString] usingActivityIndicatorStyle:[self activityIndicatorViewStyle]];
    }
    if (name) {
        self.nameLabel.text = name;
    }
    [self selectedStyleWithSelected:selected];
}

#pragma mark -

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (UIImageView *)selectIconImgView{
    if (!_selectIconImgView) {
        _selectIconImgView = [UIImageView new];
        _selectIconImgView.image = [UIImage imageNamed:@"list_border_checkMark.png"];
    }
    return _selectIconImgView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.numberOfLines = 0;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = FONT(kTudeThemFont, 15);
    }
    return _nameLabel;
}

@end
