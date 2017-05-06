//
//  DeviceInfoModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JfgTypeDefine.h"

@interface DeviceInfoModel : NSObject
/**
 *  设备名称
 */
@property (nonatomic, copy) NSString * deviceName;
/**
 *  时区
 */
@property (nonatomic, copy) NSString * timeZoneOrigin;
@property (nonatomic, copy) NSString * timeZone;
/**
 *  Micro SD卡
 */
@property (nonatomic, assign) BOOL isSDCardExist;
@property (nonatomic, assign) int sdCardError;
@property (nonatomic, copy) NSString *SDCardInfo;       //SDCard 是否存在，报错等 信息
@property (nonatomic, assign) BOOL isClearingSDCard; // is clearing sdCard now ?

@property (nonatomic, assign) long long totalSpace;     //总容量
@property (nonatomic, assign) long long usedSpace;      //已使用 容量
@property (nonatomic, copy) NSString *SDCardSpace; // 存储空间

@property (nonatomic, assign) SDCardType sdCardType; // 是否需要 格式化 SD卡

/**
 *  移动网络
 */
@property (nonatomic, assign) int netType;
@property (nonatomic, copy) NSString * net;
/**
 *  WiFi
 */
@property (nonatomic, copy) NSString * wifi;
@property (nonatomic, copy) NSString *mobileNet;
/**
 *  CID编号
 */
@property (nonatomic, copy) NSString * cid;
/**
 *  MAC
 */
@property (nonatomic, copy) NSString * MAC;
/**
 *  系统版本
 */
@property (nonatomic, copy) NSString * sysVersion;
/**
 *  软件版本
 */
@property (nonatomic, copy) NSString * version;
/**
 *  电池电量
 */
@property (nonatomic, copy) NSString *battery;
/**
 *  开机时间
 */
@property (nonatomic, assign) long long updateTime;
@property (nonatomic, copy) NSString *lastingUseTime;

/*
 * 是否 通电
 */
@property (nonatomic, assign) BOOL isCharging;

@property (nonatomic,assign) int sdCardErrorCode;

/*
 * 新固件
 */
@property (nonatomic, assign) BOOL hasNewPackage;
@property (nonatomic, copy) NSString *newPackageStr;
@end
