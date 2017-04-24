//
//  UIImageView+CMUIActivityIndicatorForSDWebImage.m
//  UIActivityIndicator for SDWebImage
//
//  Created by Giacomo Saccardo.
//  Copyright (c) 2014 Giacomo Saccardo. All rights reserved.
//

#import "UIImageView+CMUIActivityIndicatorForSDWebImage.h"
#import <objc/runtime.h>

static char TAG_ACTIVITY_INDICATOR;

@interface UIImageView (ActivityCategory)

-(void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) activityStyle;

@end

@implementation UIImageView (CMUIActivityIndicatorForSDWebImage)

@dynamic activityIndicator;

- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)activityStyle {
    
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
        
        self.activityIndicator.autoresizingMask = UIViewAutoresizingNone;
        
        [self updateActivityIndicatorFrame];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self addSubview:self.activityIndicator];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.activityIndicator startAnimating];
    });
    
}

-(void)updateActivityIndicatorFrame {
    if (self.activityIndicator) {
        CGRect activityIndicatorBounds = self.activityIndicator.bounds;
        float x = (self.frame.size.width - activityIndicatorBounds.size.width) / 2.0;
        float y = (self.frame.size.height - activityIndicatorBounds.size.height) / 2.0;
        self.activityIndicator.frame = CGRectMake(x, y, activityIndicatorBounds.size.width, activityIndicatorBounds.size.height);
    }
}

- (void)removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];

    [self updateActivityIndicatorFrame];
}

#pragma mark - Methods

- (void)setImageWithURL:(NSURL *)url usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:nil usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStye {
    [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:nil usingActivityIndicatorStyle:activityStye];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:nil options:0 completed:completedBlock usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock usingActivityIndicatorStyle:activityStyle];

}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock usingActivityIndicatorStyle:activityStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle {
    
    [self addActivityIndicatorWithStyle:activityStyle];
    
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url
         placeholderImage:placeholder
                  options:options
                 progress:progressBlock
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageUrl) {
                    if (completedBlock) {
                        completedBlock(image, error, cacheType, imageUrl);
                    }
                    [weakSelf removeActivityIndicator];
                }
     ];
}

NSData *kCmallPNGSignatureData = nil;

- (BOOL) imageHavePNGPrefixx:(NSData *)data{
    NSUInteger pngSignatureLength = [kCmallPNGSignatureData length];
    if ([data length] >= pngSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngSignatureLength)] isEqualToData:kCmallPNGSignatureData]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setImageWithURL:(NSURL *)url customPath:(NSString *)customPath placeholderImage:(UIImage *)placeholder usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle{
    if (customPath && customPath.length) {

        SDImageCache *cache = [SDWebImageManager sharedManager].imageCache;
        [cache addReadOnlyCachePath:customPath];
        
        BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:[cache cachePathForKey:url.absoluteString inPath:customPath]];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(SDImageCache) *weakCache = cache;
        if (isExit) {
            [cache queryDiskCacheForKey:url.absoluteString done:^(UIImage *image, SDImageCacheType cacheType) {
                weakSelf.image = image;
            }];
        }else{
            [self setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                dispatch_queue_t ioQueue = dispatch_queue_create("com.tuchaoshi.CMCustomCache", DISPATCH_QUEUE_SERIAL);
                dispatch_async(ioQueue, ^{
                    NSData *imageData = nil;
                    NSData *data = imageData;
                    
                    if (image && !data) {
#if TARGET_OS_IPHONE
                        // We need to determine if the image is a PNG or a JPEG
                        // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
                        // The first eight bytes of a PNG file always contain the following (decimal) values:
                        // 137 80 78 71 13 10 26 10
                        
                        // We assume the image is PNG, in case the imageData is nil (i.e. if trying to save a UIImage directly),
                        // we will consider it PNG to avoid loosing the transparency
                        BOOL imageIsPng = YES;
                        
                        // But if we have an image data, we will look at the preffix
                        if ([imageData length] >= [kCmallPNGSignatureData length]) {
                            imageIsPng = [self imageHavePNGPrefixx:imageData];
                        }
                        
                        if (imageIsPng) {
                            data = UIImagePNGRepresentation(image);
                        }
                        else {
                            data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
                        }
#else
                        data = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
                    }
                    
                    if (data) {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:customPath]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:customPath withIntermediateDirectories:YES attributes:nil error:NULL];
                        }
                        
                        [[NSFileManager defaultManager] createFileAtPath:[weakCache cachePathForKey:url.absoluteString inPath:customPath] contents:data attributes:nil];
                    }
                });
            } usingActivityIndicatorStyle:activityStyle];
        }
    }
}

- (void)setImageWithURL:(NSURL *)url useCustomPath:(BOOL)useCustomPath usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle{
    if (useCustomPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *customPath = [paths[0] stringByAppendingPathComponent:@"com.tuchaoshi.CMCustomCache"];
        [self setImageWithURL:url customPath:customPath placeholderImage:nil usingActivityIndicatorStyle:activityStyle];
    }else{
        [self setImageWithURL:url usingActivityIndicatorStyle:activityStyle];
    }
}

- (void)setImageWithURL:(NSURL *)url useCustomPath:(BOOL)useCustomPath placeholderImage:(UIImage *)placeholder usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityStyle{
    if (useCustomPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *customPath = [paths[0] stringByAppendingPathComponent:@"com.tuchaoshi.CMCustomCache"];
        [self setImageWithURL:url customPath:customPath placeholderImage:placeholder usingActivityIndicatorStyle:activityStyle];
    }else{
        [self setImageWithURL:url usingActivityIndicatorStyle:activityStyle];
    }
}

@end
