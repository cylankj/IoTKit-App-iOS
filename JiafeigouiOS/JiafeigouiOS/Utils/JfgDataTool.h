//
//  JfgDataTool.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JfgTypeDefine.h"

@interface JfgDataTool : NSObject

+ (NSString *)repeatTimeStr:(long)repeatTime;
+ (NSString *)autoPhotoStr:(int)autoPhoto;

+ (NSDictionary *)timeZoneDict;
+ (NSString *)timeZoneForKey:(NSString *)key;

// 判断设备 在线离线
+ (BOOL)deviceIsOnline:(DeviceNetType)netType;


// 获取 图片URL
+ (NSString *)getCloudUrlForCid:(NSString *)cid timestamp:(uint64_t)timestamp order:(int)order flag:(int)flag;

+ (NSString *)getTimeLapseForCid:(NSString *)cid timestamp:(uint64_t)timestamp vid:(NSString *)vid flag:(int)flag fileType:(NSString *)type;

@end
