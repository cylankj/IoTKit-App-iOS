//
//  JfgConstKey.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef JfgConstKey_h
#define JfgConstKey_h


#pragma mark
#pragma mark 文件 路径
//NSString *const docmentStr = @"Documents";
NSString *const jfgWorkDocment = @"jfgworkdic";         // 日志 文件 路径
NSString *const pano720MediaPath = @"Pano720File";       // 720 摄像头 路径
NSString *const pano720VideoThumbnailsDir = @"thumbnails";
NSString *const pano720MediaDir = @"file";

#pragma mark
#pragma mark Notification
NSString *const updateAliasNotification = @"_updateAliasNotification";
NSString *const deleteDeviceNotification = @"_deleteDeviceNotification";
NSString *const angleChangedNotification = @"_angleChangedNotification"; // 角度 发生变化
#pragma mark --videoNotification


#pragma mark
#pragma mark 设备 视频 返回消息Key
NSString *const videoErrorKey = @"error";
NSString *const videoRemoteKey = @"remote";

#pragma mark
#pragma mark advertisement key
NSString *const adDictKey = @"adDictKey";
NSString *const adPicURLKey = @"adPicURL";
NSString *const adTagURLKey = @"adTagURL";
NSString *const adEndTimeKey = @"adEndTime";

#pragma mark
#pragma mark 长度 常量

// 注册，登录，修改密码 密码长度
int const pwMinLength = 6;
int const pwMaxLength = 32;

// 账号 长度
int const accountMaxLength = 65;

// 验证码长度
int const smsMaxLength = 6;

#pragma mark
#pragma mark Panorama720 Key
NSString *const panoSdCardExistKey = @"sdIsExist";
NSString *const panoSdCardTotalStorage = @"storage";
NSString *const panoSdCardUsedStorage = @"storage_used";
NSString *const panoSdCardError = @"sdcard_recogntion";

NSString *const devName = @"devname";
NSString *const sdCardIsExist = @"sdIsExist";
NSString *const totalSpace = @"storage";
NSString *const usedSpace = @"storage_used";
NSString *const ssid = @"SSID";
NSString *const mac = @"Mac";
NSString *const sysVersion = @"sysver";
NSString *const panoBattery = @"battery";
NSString *const panoUptime = @"uptime";
NSString *const panoIsCharging = @"powerline";

#pragma mark
#pragma mark oem Key
NSString *const oemNameKey = @"oemname";

#endif /* JfgConstKey_h */
