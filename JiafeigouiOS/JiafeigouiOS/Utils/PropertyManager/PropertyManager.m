//
//  PropertyManager.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "PropertyManager.h"
#import "NSDictionary+FLExtension.h"
#import <JFGSDK/JFGSDK.h>


NSString *const pPIDKey = @"PID";
NSString *const pCidKey = @"CID";
NSString *const pCidPrefixKey = @"CIDPREFIX";
NSString *const pOSKey = @"OS";
NSString *const pProductionKey = @"PRODUCT";
NSString *const pWifiKey = @"WIFI";     // wifi配置
NSString *const pWifiInfoKey = @"WIFI_INFO";
NSString *const pProtectionKey = @"PROTECTION";  // 安全防护
NSString *const pRecordSettingKey = @"AUTORECORD";
NSString *const pWatchVideo = @"VIDEO";     // 监看 录像
NSString *const pStandByKey = @"STANDBY";
NSString *const pRedSight = @"INFRAREDVISION";    // 红外夜视
NSString *const pHangUpKey = @"HANGUP";
NSString *const pNTSCKey = @"NTSC";
NSString *const pTimeZoneKey = @"TZ";
NSString *const pSDCardKey = @"SD";
NSString *const pDevUpgradeKey = @"FU";
NSString *const pSysVersionKey = @"SYSVERSION";
NSString *const pSoftVersionKey = @"SOFTVERSION";
NSString *const pMacKey = @"MAC";
NSString *const pUpTimeKey = @"UPTIME";
NSString *const pBatteryKey = @"BATTERY";
NSString *const pWariningVoiceKey = @"WARMSOUND";   // 报警 提示 音
NSString *const pRecord24Key = @"24RECORD";
NSString *const pLedKey = @"LED";
NSString *const pAngleKey = @"VIEWANGLE";
NSString *const pViewShapeKey = @"VIEW";
NSString *const pWiredModel = @"WIREDMODE";
NSString *const pIpAdress = @"IP";
NSString *const pHotWireless = @"AP";
NSString *const pDefinitionKey = @"SD/HD";  // 高清，标清
NSString *const pSN = @"SN";
NSString *const pSsidPrefix = @"SSID";
NSString *const pCallMsg = @"EMPTIED";
NSString *const pApConnectting = @"APCONNECTTING";
NSString *const pLowBattery = @"POWER";
NSString *const pAiRecognition = @"AI_RECOGNITION";
NSString *const pAlarmDuration = @"INTERVAL_ALARM";

@interface PropertyManager()

@property (nonatomic, strong) NSDictionary *propertyDict;

@end

@implementation PropertyManager

- (BOOL)showRowWithPid:(NSInteger)pID key:(NSString *)rowKey
{
    BOOL result = NO;
    NSArray *propertyArr = [self.propertyDict objectForKey:@"pList"];
    
    for (NSInteger i = 0; i < propertyArr.count; i ++)
    {
        NSDictionary *aproperty = [propertyArr objectAtIndex:i];
        
        if ([[aproperty objectForKey:pOSKey] integerValue] == pID || [[aproperty objectForKey:pPIDKey] integerValue] == pID)
        {
            if ([aproperty.allKeys containsObject:rowKey])
            {
                result = [[aproperty objectForKey:rowKey] boolValue];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"showKey:[%@]  showValue[%d]",rowKey, result]];
                return result;
            }
        }
    }
    
    return result;
}

+ (BOOL)showPropertiesRowWithPid:(NSInteger)pID key:(NSString *)rowKey
{
    return [self showRowWithPid:pID key:rowKey path:[[NSBundle mainBundle] pathForResource:@"properties" ofType:@"json"]];
}

+ (BOOL)showSharePropertiesRowWithPid:(NSInteger)pID key:(NSString *)rowKey
{
    return [self showRowWithPid:pID key:rowKey path:[[NSBundle mainBundle] pathForResource:@"properties_share" ofType:@"json"]];
}

+ (BOOL)showRowWithPid:(NSInteger)pID key:(NSString *)rowKey path:(NSString *)filePath
{
    BOOL result = NO;
    
    NSDictionary *propertyDict = [NSDictionary dictionaryWithJsonString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
    
    NSArray *propertyArr = [propertyDict objectForKey:@"pList"];
    
    for (NSInteger i = 0; i < propertyArr.count; i ++)
    {
        NSDictionary *aproperty = [propertyArr objectAtIndex:i];
        
        if ([[aproperty objectForKey:pOSKey] integerValue] == pID || [[aproperty objectForKey:pPIDKey] integerValue] == pID)
        {
            if ([aproperty.allKeys containsObject:rowKey])
            {
                result = [[aproperty objectForKey:rowKey] boolValue];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"showKey:[%@]  showValue[%d]",rowKey, result]];
                return result;
            }
        }
    }
    
    return result;
}

#pragma mark getter
- (NSDictionary *)propertyDict
{
    if (_propertyDict == nil)
    {
        NSDictionary *properties = nil;
        
        if (self.propertyFilePath != nil)
        {
            properties = [NSDictionary dictionaryWithJsonString:[NSString stringWithContentsOfFile:self.propertyFilePath encoding:NSUTF8StringEncoding error:nil]];
        }
        
        _propertyDict = [[NSDictionary alloc] initWithDictionary:properties];
    }
    
    return _propertyDict;
}


@end
