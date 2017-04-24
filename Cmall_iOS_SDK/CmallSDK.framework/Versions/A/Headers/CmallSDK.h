//
//  TudeSDK.h
//  TudeSDK version 1.0
//
//  Created by Moyun on 2017/3/24.
//
//  Copyright (c) 2017 Cmall. All rights reserved.
//  ----------------------------------------------
//  -------------current Version : 2.0.0----------
//  ----------------------------------------------

#import <UIKit/UIKit.h>
#import "CmallSDKProtocol.h"


extern NSString *_Nonnull const kCmallSDKNodeName;
extern NSString *_Nonnull const kCmallSDKPreviewImage;
extern NSString *_Nonnull const kCmallSDKUserImage;
extern NSString *_Nonnull const kCmallSDKPreviewImageUrl;
extern NSString *_Nonnull const kCmallSDKUserImageUrl;

@interface CmallSDK : NSObject

/**
 SDK初始化方法,clientId和clientSecret在Cmall开放平台申请
 
 @param clientId 在开放平台注册应用分配的clientId
 @param clientSecret 在开放平台注册应用分配的clientSecret
 */
+ (void)startWithClientId:(NSString*_Nonnull)clientId
             clientSecret:(NSString*_Nonnull)clientSecret;

/** 设置是否打印log信息, 默认NO(不打印log).
 @param value 设置为YES,会输出log信息可供调试参考,建议在发布的时候改为No
 */
+ (void)setLogEnabled:(BOOL)value;

/**
 设置你的app所用的图片域名前缀prefix。
 例如：
     https://image.cmall.com/imgsrv/hahha/heihei/123456765432.jpg
     prefix为：https://image.cmall.com/imgsrv
 @param prefix 图片域名前缀。默认为官方前缀：https://image.cmall.com/imgsrv
 */
+ (void)setImagePrefix:(NSString*_Nonnull)prefix;

/** 进入编辑界面
 @param editorInfo 进入编辑前的预设信息
 @param curViewController 当前视图控制器
 */
+ (void)showSDKEditorViewControllerWithEditorInfo:(NSDictionary* _Nonnull )editorInfo
                            currentViewController:(UIViewController*_Nonnull)curViewController;
/**
 进入编辑界面

 @param editorInfo 进入编辑前的预设信息
 @param curViewController 当前视图控制器
 @param implementProtocolClass 需要自定义CmallSDKProtocol协议，实现协议里对应方法的接受者
 */
+ (void)showSDKEditorViewControllerWithEditorInfo:(NSDictionary* _Nonnull )editorInfo
                            currentViewController:(UIViewController<CmallSDKProtocol>*_Nonnull)curViewController
                            implmentProtocolClass:(NSObject<CmallSDKProtocol> *_Nullable)implementProtocolClass;

/**
 点击【完成】操作后获取相关数据
 
 @param callBack 完成回调
 previewImageBase64StringOfPng 编辑截图的base64字符串，用于返回给H5的3D渲染器【注意，必须是png格式】
 jsonData 编辑过的字典信息，用于返回给H5
 isAutoNode 当前编辑节点是否是自动套版节点
 imageInfo 保存该节点相关的图片信息
 */
+ (void)setEditCompletedCallBack:(void (^_Nullable)(NSString* _Nonnull previewImageBase64StringOfPng,NSDictionary* _Nonnull jsonData,BOOL isAutoNode,NSDictionary* _Nonnull imageInfo))callBack;

/**
 点击【取消】操作后获取相关数据
 
 @param callBack 取消回调
 */
+ (void)setEditCancelledCallBack:(void (^_Nullable)())callBack;

/**
 第三方触发 点击【完成】操作
 */
+ (void)editCompletedAction:(id _Nullable )sender;

/**
 第三方触发 点击【取消】操作
 */
+ (void)editCancelledAction:(id _Nullable )sender;

/**
 可自己定义加载样式，如果未实现该方法，默认使用SDK提供的加载样式

 @param show show
 */
+ (void)showWithUserDefined:(void (^_Nullable) (NSInteger code, NSString * _Nullable infoDes))show;

/**
 自定义关闭加载样式，须和showWithUserDefined成对出现

 @param dismiss dismiss
 */
+ (void)dismissWithUserDefined:(void (^_Nullable) (void))dismiss;

/**
 sdk普通错误回调

 @param callBack 包括：错误码、错误描述 详见TDError.h
 */
+ (void)setNormalErrorCallBack:(void (^_Nullable)(NSInteger code,NSString* _Nullable errorDesc,NSDictionary * _Nullable errInfo))callBack;

/**
 清除WKWebView缓存
 */
+ (void)cleanCache;

/**
 定制页面 提供第三方添加自定义字体
 例如：
     添加Daniel.otf,并把它放在mainBundle下
         NSMutableArray *paths = [NSMutableArray array];
         NSString *fontFilePath = [[NSBundle mainBundle] pathForResource:@"Daniel" ofType:@"otf"];
         [paths addObject:fontFilePath];
         if (paths) {
            [TudeSDK registerFontWithFilePaths:[paths copy]];
         }
 */
+ (void)registerFontWithFilePaths:(NSArray<NSString*>*_Nonnull)paths;

+ (NSDictionary*_Nonnull)signedParamsWithNeedSignParams:(NSDictionary*_Nonnull)needSignParams;

@end
