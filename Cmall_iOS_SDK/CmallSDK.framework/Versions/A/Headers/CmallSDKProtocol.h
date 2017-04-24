//
//  CmallSDKProtocol.h
//  Pods
//
//  Created by Moyun on 2017/4/18.
//
//

#ifndef CmallSDKProtocol_h
#define CmallSDKProtocol_h

@protocol CmallSDKProtocol <NSObject>

@optional
/**
 开发者可自行遵循该协议，实现该方法，来替换编辑页面上方显示

 @return UIView
 */
- (UIView *)customNavibarView;

@end

#endif /* CmallSDKProtocol_h */
