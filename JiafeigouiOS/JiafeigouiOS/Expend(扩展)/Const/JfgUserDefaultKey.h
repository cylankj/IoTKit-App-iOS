//
//  JfgUserDefaultKey.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/*
    持久化数据 NSUserDefault

*/

#ifndef JfgUserDefaultKey_h
#define JfgUserDefaultKey_h

// 可用的wifi
NSString *const availableWIFI = @"_availableWIFI";

// 是否 弹 低电量 提示
#define areadyShowLowBatteryView(cid) [NSString stringWithFormat:@"_areadyShowLowBatteryView_%@",cid]

// 是否显示 功能设置红点
#define isShowSafeRedDot(cid) [NSString stringWithFormat:@"_isShowSafeRedDot_%@",cid]  // 安全防护
#define isShowAutoPhotoRedDot(cid) [NSString stringWithFormat:@"_isAutoPhotoSafeRedDot_%@",cid]  // 自动录像
#define isShowDelayPhotoRedDot(cid) [NSString stringWithFormat:@"_isDelayPhotoSafeRedDot_%@",cid]  // 延迟摄影

#pragma mark 功能设置 缓存
// 功能设置
#define jfgDeviceSettingCache(cid) [NSString stringWithFormat:@"_deviceSettingCache_%@",cid]  // 功能设置 Cache
#define jfgDeviceInfoCache(cid) [NSString stringWithFormat:@"_jfgDeviceInfoCache_%@",cid]  // 设备信息 Cache
#define jfgSafeProtectCache(cid) [NSString stringWithFormat:@"_jfgSafeProtectCache_%@",cid]  // 设备信息 Cache

#endif /* JfgUserDefaultKey_h */
