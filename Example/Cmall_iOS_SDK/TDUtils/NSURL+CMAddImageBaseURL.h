//
//  NSURL+CMAddImageBaseURL.h
//  LightBulb
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Moyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CMAddImageBaseURL)

-(NSURL*)addImageBaseURL;

-(NSURL*)addSuffixWithString:(NSString*)string;

- (NSURL*)addImageDominURL;

@end
