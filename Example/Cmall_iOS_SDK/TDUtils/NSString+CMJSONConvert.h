//
//  NSString+CMJSONConvert.h
//  LightBulb
//
//  Created by apple on 15/9/24.
//  Copyright © 2015年 Moyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CMJSONConvert)

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSArray *)arrayWithJsonString:(NSString *)jsonString;

@end
