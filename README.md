# Cmall_iOS_SDK

[![CI Status](http://img.shields.io/travis/momo605654602@gmail.com/Cmall_iOS_SDK.svg?style=flat)](https://travis-ci.org/momo605654602@gmail.com/Cmall_iOS_SDK)
[![Version](https://img.shields.io/cocoapods/v/Cmall_iOS_SDK.svg?style=flat)](http://cocoapods.org/pods/Cmall_iOS_SDK)
[![License](https://img.shields.io/cocoapods/l/Cmall_iOS_SDK.svg?style=flat)](http://cocoapods.org/pods/Cmall_iOS_SDK)
[![Platform](https://img.shields.io/cocoapods/p/Cmall_iOS_SDK.svg?style=flat)](http://cocoapods.org/pods/Cmall_iOS_SDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Cmall_iOS_SDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Cmall_iOS_SDK"
```

## Usage

1.在AppDelegate中导入头文件 #import <CmallSDK/CmallSDK.h>
2.在 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 方法中添加初始化代码
    // 账号请移步到 https://open.cmall.com/ 处注册
    [CmallSDK startWithClientId:kTudeClientId clientSecret:kTudeClientSecret];

    // 开启SDK的日志打印
    [CmallSDK setLogEnabled:true];

    // 开发者可以根据自己需求自己添加字体
    // 添加SDK内部定制界面的自定义字体方式
    NSArray *filePaths = @[@"BrushScriptStd.ttf",@"Daniel.otf"];
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:filePaths.count];
    for (NSString *filePath in filePaths) {
        NSString *fontFilePath = [[NSBundle mainBundle] pathForResource:filePath ofType:nil];
        [paths addObject:fontFilePath];
    }
    if (paths) {
        [CmallSDK registerFontWithFilePaths:[paths copy]];
    }
3.参考Example，开启自动套版。
    

## Author

momo605654602@gmail.com, moyunmo@hotmail.com

## License

Cmall_iOS_SDK is available under the MIT license. See the LICENSE file for more info.
