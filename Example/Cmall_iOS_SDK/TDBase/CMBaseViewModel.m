//
//  LBBaseViewModel.m
//  LightBulb
//
//  Created by Moyun on 15/4/9.
//  Copyright (c) 2015年 Moyun. All rights reserved.
//

#import "CMBaseViewModel.h"

@interface CMBaseViewModel ()

@property (strong, nonatomic) RACSubject *errors;

@end

@implementation CMBaseViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (RACSubject *)errors {
    if (!_errors) {
        _errors = [RACSubject subject];
    }
    return _errors;
}

- (RACSubject *)willDisappearSignal
{
    if (!_willDisappearSignal) {
        _willDisappearSignal = [RACSubject subject];
    }
    return _willDisappearSignal;
}

- (void)dealloc
{
    [_errors sendCompleted];
}

@end

