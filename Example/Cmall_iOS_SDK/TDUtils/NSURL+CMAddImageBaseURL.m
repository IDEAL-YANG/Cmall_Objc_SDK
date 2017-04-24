//
//  NSURL+CMAddImageBaseURL.m
//  LightBulb
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Moyun. All rights reserved.
//

#import "NSURL+CMAddImageBaseURL.h"

@implementation NSURL (CMAddImageBaseURL)

-(NSURL*)addImageBaseURL{
    if (self == nil) {
        return nil;
    }
    NSString *string = self.absoluteString;
    if ([string hasPrefix:@"http://"] || [string hasPrefix:@"https://"]) {

    }else{
        string = [string stringByReplacingOccurrencesOfString:@"imgsrv" withString:@""];
        if ([string hasPrefix:@"/"]) {
            string = [NSString stringWithFormat:@"%@%@",kCmallImageBaseUrl,string];
        }else{
            string = [NSString stringWithFormat:@"%@/%@",kCmallImageBaseUrl,string];
        }
    }
    return [NSURL URLWithString:string];
}

-(NSURL*)addSuffixWithString:(NSString*)string{
    if (self == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.absoluteString,string?:@""]];
}

- (NSURL*)addImageDominURL{
    if (self == nil) {
        return nil;
    }
    return [self.absoluteString hasPrefix:@"http://"] || [self.absoluteString hasPrefix:@"https://"] ? self:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",kCmallImageDomainBaseUrl,self.absoluteString]];
}

@end
