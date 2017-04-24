//
//  TDError.h
//  Pods
//
//  Created by IDEAL YANG on 2017/3/29.
//
//

#ifndef TDError_h
#define TDError_h

typedef NS_ENUM(NSInteger , TDErrCode){
    Tude_Err_ApiErr = -1,// 内部接口错误，请提供errInfo给官方后台人员请求协助
    Tude_Err_NetworkErr = -2,// 网络错误
    Tude_Err_PhotoSaveErr = -3,// 相机照片存储错误，请检查磁盘容量
};

#endif /* TDError_h */
