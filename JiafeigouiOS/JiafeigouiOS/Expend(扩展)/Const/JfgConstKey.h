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
#pragma mark oem Key
NSString *const oemNameKey = @"oemname";

#endif /* JfgConstKey_h */
