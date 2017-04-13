//
//  JFGEquipmentAuthority.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//  设备权限判断

#import <Foundation/Foundation.h>

@interface JFGEquipmentAuthority : NSObject

//是否有麦克风权限
+(BOOL)canRecordPermission;

//是否有相机使用权限
+(BOOL)canCameraPermission;

//是否有相册权限
+(BOOL)canPhotoPermission;

//是否有通知权限
+ (BOOL)canNotificationPermission;

@end
