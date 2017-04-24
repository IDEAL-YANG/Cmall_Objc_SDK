//
//  CMNetworkManage.m
//  CMDIYSDK
//
//  Created by Moyun on 16/8/23.
//  Copyright © 2016年 Cmall. All rights reserved.
//

#import "CMNetworkManage.h"

@interface CMNetworkManage ()

@end

@implementation CMNetworkManage

+ (CMNetworkManage *)sharedInstance
{
    static CMNetworkManage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMNetworkManage alloc] init];
    });
    return instance;
}

- (void)getForSDKWithUrlString:(NSString *)urlString
                    parameters:(NSDictionary *)parameters
                       success:(CMCompletioBlock)success
                       failure:(CMFailureBlock)failure{
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:urlString];
    if ([parameters allKeys]) {
        [mutableUrl appendString:@"?"];
        for (id key in parameters) {
            @autoreleasepool {
                NSString *keyString = [parameters objectForKey:key];
                if ([keyString isKindOfClass:[NSNumber class]]) {
                    keyString = [NSString stringWithFormat:@"%@",keyString];
                }
                if ([keyString isKindOfClass:[NSString class]]) {
                    NSString *value = [keyString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
                }
            }
        }
    }
    NSString *urlEnCode = [[mutableUrl substringToIndex:mutableUrl.length - 1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failure(error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            success(dic);
        }
    }];
    [dataTask resume];
}

- (void)postForSDKUseWithUrlString:(NSString *)url parameters:(id)parameters success:(CMCompletioBlock)successBlock failure:(CMFailureBlock)failureBlock{
    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    //设置请求方式
    request.HTTPMethod = @"POST";
    NSString *postStr = [CMNetworkManage parseParams:parameters];
    //设置请求体
    request.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            successBlock(dic);
        }
    }];
    [dataTask resume];
}

//把NSDictionary解析成post格式的NSString字符串
+ (NSString *)parseParams:(NSDictionary *)params
{
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    NSMutableArray *array = [NSMutableArray new];
    //实例化一个key枚举器用来存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&", key, [params valueForKey:key]];
        [result appendString:keyValueFormat];
        [array addObject:keyValueFormat];
    }
    return result;
}

@end
