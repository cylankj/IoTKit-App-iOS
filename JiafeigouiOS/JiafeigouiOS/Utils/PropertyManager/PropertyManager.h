//
//  PropertyManager.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"

extern NSString *const pPIDKey;
extern NSString *const pCidKey;
extern NSString *const pCidPrefixKey;
extern NSString *const pOSKey;
extern NSString *const pProductionKey;
extern NSString *const pWifiKey;
extern NSString *const pWifiInfoKey;    // 设备信息 wifi信息
extern NSString *const pProtectionKey;  // 安全防护
extern NSString *const pRecordSettingKey;
extern NSString *const pWatchVideo;     // 监看 录像
extern NSString *const pStandByKey;
extern NSString *const pRedSight;    // 红外夜视
extern NSString *const pHangUpKey;
extern NSString *const pNTSCKey;
extern NSString *const pTimeZoneKey;
extern NSString *const pSDCardKey;
extern NSString *const pDevUpgradeKey;
extern NSString *const pSysVersionKey;
extern NSString *const pSoftVersionKey;
extern NSString *const pMacKey;
extern NSString *const pUpTimeKey;
extern NSString *const pBatteryKey;
extern NSString *const pWariningVoiceKey;   // 报警 提示 音
extern NSString *const pRecord24Key;
extern NSString *const pLedKey;
extern NSString *const pAngleKey;
extern NSString *const pViewShapeKey;
extern NSString *const pWiredModel;
extern NSString *const pIpAdress;
extern NSString *const pHotWireless;
extern NSString *const pDefinitionKey;  // 高清，标清
extern NSString *const pSN;
extern NSString *const pSsidPrefix;
extern NSString *const pCallMsg;
extern NSString *const pApConnectting;
extern NSString *const pLowBattery;
extern NSString *const pAiRecognition;      // AI 识别
extern NSString *const pAlarmDuration;      // 报警时间  间隔

@interface PropertyManager : BaseViewModel

@property (nonatomic, copy) NSString *propertyFilePath;

+ (BOOL)showPropertiesRowWithPid:(NSInteger)pID key:(NSString *)rowKey;

+ (BOOL)showSharePropertiesRowWithPid:(NSInteger)pID key:(NSString *)rowKey;

- (BOOL)showRowWithPid:(NSInteger)pID key:(NSString *)rowKey;

@end
