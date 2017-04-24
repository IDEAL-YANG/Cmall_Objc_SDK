//
//  CMViewController.m
//  Cmall_iOS_SDK
//
//  Created by momo605654602@gmail.com on 04/10/2017.
//  Copyright (c) 2017 momo605654602@gmail.com. All rights reserved.
//

#import "CMViewController.h"
#import "CMBaseNavigationController.h"

#import "CMTemplateListViewController.h"

@interface CMViewController ()

@end

@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDIYAction:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示",@"") message:NSLocalizedString(@"请确保所填图片url是允许跨域的！！！",@"") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"自定义图片url(以http打头的全路径)";
    }];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"使用自定义图片URL，宽高未知",@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *imgUrl = alertController.textFields.firstObject.text;
        if (imgUrl.length && [imgUrl hasPrefix:@"http"]) {
            [weakSelf showAutoListViewControllerWithKey:imgUrl imageWidth:0 imageHeight:0];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"使用预设图片，宽高已知",@"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showAutoListViewControllerWithKey:@"https://image.cmall.com/imgsrv/artsrelease/322891/o_1ajl81bmh1iaq15rhtj113ao1r309.jpg" imageWidth:3000 imageHeight:2002];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消",@"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAutoListViewControllerWithKey:(NSString*)key imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight{
    NSDictionary *imgInfoDict = @{
                                  @"picUrl":key,
                                  @"picWidth":[NSNumber numberWithFloat:imageWidth],
                                  @"picHeight":[NSNumber numberWithFloat:imageHeight]
                                  };
    DLog(@"==imgInfoDict:%@",imgInfoDict);
    @weakify(self);
    LBDispatch_main_async_safe((^(){
        @strongify(self);
        CMTemplateListViewController *webViewVC = [CMTemplateListViewController webViewControllerWithURLString:[NSString stringWithFormat:@"%@/open/source/autotmp.html",kTudeSDKDomainBaseUrl]];
        [webViewVC setValue:imgInfoDict forKey:@"imgInfoDict"];
        [self presentViewController:[[CMBaseNavigationController alloc] initWithRootViewController:webViewVC] animated:true completion:^{
            
        }];
    }));
}

@end
