//
//  TDQuntityView.m
//  Cmall
//
//  Created by IDEAL YANG on 16/11/7.
//  Copyright © 2016年 Moyun. All rights reserved.
//

#import "TDQuntityView.h"
#import "UIImage+CMUtility.h"

@interface TDQuntityView ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *quantityTextField;
@property (strong, nonatomic) UIButton *decreaseButton;
@property (strong, nonatomic) UIButton *increaseButton;
@property (strong, nonatomic) UIToolbar *accessoryView;
@end

@implementation TDQuntityView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.decreaseButton];
        [self addSubview:self.quantityTextField];
        [self addSubview:self.increaseButton];
        
        [self.decreaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(0);
        }];
        [self.increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.bottom.mas_equalTo(0);
            make.width.equalTo(self.decreaseButton);
        }];
        [self.quantityTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.leading.equalTo(self.decreaseButton.mas_trailing);
            make.trailing.equalTo(self.increaseButton.mas_leading);
            make.width.equalTo(self.increaseButton);
        }];
        
        self.quantityTextField.text = @"1";
        self.quantityTextField.delegate = self;
        self.decreaseButton.enabled = NO;
        
        self.minQuantity = 1;
        self.maxQuantity = 999;
        
        @weakify(self);
        [[self.increaseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            self.decreaseButton.enabled = YES;
            NSUInteger count = [self.quantityTextField.text integerValue];
            count += 1;
            //if (count > self.maxQuantity) {
            //   count = self.maxQuantity;
            //}
            self.quantityTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
            if (self.getQuantityBlock) {
                self.getQuantityBlock(count);
            }
        }];
        [[self.decreaseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            NSUInteger count = [self.quantityTextField.text integerValue];
            count -= 1;
            if (count <= self.minQuantity) {
                count = self.minQuantity;
                self.decreaseButton.enabled = NO;
            }
            self.quantityTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
            if (self.getQuantityBlock) {
                self.getQuantityBlock(count);
            }
        }];
        [[self.quantityTextField.rac_textSignal skip:1] subscribeNext:^(NSString *value) {
            @strongify(self);
            if (value.length) {
                NSUInteger count = [value integerValue];
                self.decreaseButton.enabled = count>1;
                //if (count > self.maxQuantity) {
                //    count = self.maxQuantity;
                //}
                self.quantityTextField.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
                if (self.getQuantityBlock) {
                    self.getQuantityBlock(count);
                }
            }else{
                self.decreaseButton.enabled = NO;
                self.quantityTextField.text = @"0";
                if (self.getQuantityBlock) {
                    self.getQuantityBlock(0);
                }
            }
        }];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    DLog(@"==action:%@",NSStringFromSelector(action));
    if (action == @selector(paste:))//禁止粘贴
        return NO;
    return [super canPerformAction:action withSender:sender];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSUInteger count = [textField.text integerValue];
    //if (count > self.maxQuantity) {
    //    count = self.maxQuantity;
    //}else
    if (count < self.minQuantity){
        count = self.minQuantity;
    }
    textField.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    if (self.getQuantityBlock) {
        self.getQuantityBlock(count);
    }
}

#pragma mark -

- (UIButton *)decreaseButton{
    if (!_decreaseButton) {
        _decreaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_decreaseButton setTitle:@"-" forState:UIControlStateNormal];
        [_decreaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_decreaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_decreaseButton setBackgroundImage:[UIImage createImageWithColor:[UIColor grayColor] size:CGSizeMake(1, CGRectGetHeight(self.frame))] forState:UIControlStateDisabled];
    }
    return _decreaseButton;
}

- (UIButton *)increaseButton{
    if (!_increaseButton) {
        _increaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_increaseButton setTitle:@"+" forState:UIControlStateNormal];
        [_increaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_increaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_increaseButton setBackgroundImage:[UIImage createImageWithColor:[UIColor grayColor] size:CGSizeMake(1, CGRectGetHeight(self.frame))] forState:UIControlStateDisabled];
    }
    return _increaseButton;
}

- (UITextField *)quantityTextField{
    if (!_quantityTextField) {
        _quantityTextField = [[UITextField alloc] init];
        _quantityTextField.textColor = [UIColor blackColor];
        _quantityTextField.font = THEMEFONT(18);
        _quantityTextField.textAlignment = NSTextAlignmentCenter;
        _quantityTextField.backgroundColor = [UIColor whiteColor];
        _quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
        _quantityTextField.inputAccessoryView = self.accessoryView;
    }
    return _quantityTextField;
}

- (UIToolbar *)accessoryView
{
    if (!_accessoryView) {
        _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, Main_Screen_Width, 44)];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        [_accessoryView setItems:@[btnSpace,rightItem]];
    }
    return _accessoryView;
}


- (void)doneAction:(UIBarButtonItem *)item
{
    [self endEditing:true];
}

@end
