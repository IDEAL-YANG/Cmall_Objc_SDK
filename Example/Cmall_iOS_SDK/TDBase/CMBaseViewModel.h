//
//  LBBaseViewModel.h
//  LightBulb
//
//  Created by Moyun on 15/4/9.
//  Copyright (c) 2015年 Moyun. All rights reserved.
//

#import "RACSubject.h"

@interface CMBaseViewModel : NSObject

@property (assign, nonatomic) BOOL requestError;
@property (assign, nonatomic) BOOL parserError;
@property (assign, nonatomic) BOOL isLoading;
@property (copy,   nonatomic) NSString *errorInfo;
@property (copy,   nonatomic) NSString *naviTitle;
@property (strong, nonatomic, readonly) RACSubject *errors;

@property (strong, nonatomic) RACSubject *willDisappearSignal;

@end
