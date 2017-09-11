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
// 显示 VR tip
NSString *const isAlreadyShowTip = @"_isAlreadyShowTip";

// 广告显示的次数
NSString *const adShowTimeKey = @"_adShowTime";

// 是否 弹 低电量 提示
#define areadyShowLowBatteryView(cid) [NSString stringWithFormat:@"_areadyShowLowBatteryView_%@",cid]
// 弹出 升级提示 时间
#define showUpgradeViewTime(cid) [NSString stringWithFormat:@"_showUpgradeViewTime_%@",cid]

#define jfgDomianURL @"_jfg_changedDomain_"

// 是否显示 功能设置红点
#define isShowAutoPhotoRedDot(cid) [NSString stringWithFormat:@"_isAutoPhotoSafeRedDot_%@",cid]  // 自动录像
#define isShowDelayPhotoRedDot(cid) [NSString stringWithFormat:@"_isDelayPhotoSafeRedDot_%@",cid]  // 延迟摄影
#define isShowRecordRedDot(cid) [NSString stringWithFormat:@"_isShowRecordRedDot_%@",cid]
#define isShowDeepSleepRedDot(cid) [NSString stringWithFormat:@"_isShowDeepSleepRedDot_%@",cid]

// 安全防护 AI 小红点
#define isShowSafeAIRedDot(cid)  [NSString stringWithFormat:@"_isShowSafeAIRedDot_%@",cid]

#pragma mark 功能设置 缓存
// 功能设置
#define jfgDeviceSettingCache(cid) [NSString stringWithFormat:@"_deviceSettingCache_%@",cid]  // 功能设置 Cache
#define jfgDeviceInfoCache(cid) [NSString stringWithFormat:@"_jfgDeviceInfoCache_%@",cid]  // 设备信息 Cache
#define jfgSafeProtectCache(cid) [NSString stringWithFormat:@"_jfgSafeProtectCache_%@",cid]  // 设备信息 Cache

#endif /* JfgUserDefaultKey_h */
