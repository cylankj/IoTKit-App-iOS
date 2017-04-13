//
//  QRViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
// 没借口 ，暂时不处理

#import "BaseViewModel.h"

typedef NS_ENUM(NSUInteger, QRReustType)
{
    QRReustTypeSuccess, // 绑定成功
    QRReustTypePushGuideDoor, // 跳转 门铃 引导界面
    QRReustTypePUshGuideCamera, // 跳转 摄像头 引导页面
    QRReustTypePUshGuideCameraFor720, // 跳转 720摄像头 引导页面
    QRReustTypeUnSupport, // 不支持 扫码设备
    QRReustTypeBinded, // 已绑定
    QRReustTypeOthersBinded, // 被他人绑定
    QRReustTypeError,   // 无效的二维码
    QRReustTypeFailed, //绑定失败
};

@protocol QRVMDelegate <NSObject>

@optional
- (void)QRScanDidFinished:(QRReustType)resultType;

@end

@interface QRViewModel : BaseViewModel

- (BOOL)requestWithString:(NSString *)qrResult;

@property (nonatomic, assign) id<QRVMDelegate> vmDelegate;

@end

