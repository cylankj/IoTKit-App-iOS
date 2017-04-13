//
//  JfgQRCodeVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>


@protocol jfgQRCodeDelegate <NSObject>

@optional

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection;

@end


@interface JfgQRCodeVC : BaseViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<jfgQRCodeDelegate> QRDelegate;

// 扫描可视区域
@property (nonatomic, assign) CGRect scanRect;

/**
 *  开启二维码扫描
 */
- (void)openQRCodeScan;
/**
 *  关闭 二维码扫描
 */
- (void)closeQRCodeScan;


/**
 *  生成二维码 图片
 *
 *  @return
 */
- (CIImage *)createQRCodeCIImageWithStr:(NSString *)codeStr;
- (UIImage *)createQRCodeUIImageWithStr:(NSString *)codeStr;


@end
