//
//  DeviceInfoModel.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceInfoModel.h"
#import "JfgDataTool.h"
#import "JfgLanguage.h"
#import "CommonMethod.h"
#import "JfgTypeDefine.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>

@implementation DeviceInfoModel

/**
 *  时区
 */

- (NSString *)timeZone
{
    return [JfgDataTool timeZoneForKey:self.timeZoneOrigin];
}

/*
 * ipAddress
 */
- (NSString *)ipAddress
{
    if ([JfgDataTool deviceIsOnline:(DeviceNetType)self.netType])
    {
        return _ipAddress;
    }
    
    return @"";
}
/*
 * 电量
 */
- (NSString *)battery
{
    NSString *retStr = @"";
    
    switch (self.pType)
    {
        case productType_720p:
        case productType_720:
        {
            if ([JfgDataTool deviceIsOnline:(DeviceNetType)self.netType] || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
            {
                if (self.isCharging)
                {
                    retStr = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"CHARGING"],[_battery intValue]];
                }
                else
                {
                    if (_battery != nil)
                    {
                        retStr = [NSString stringWithFormat:@"%@%%",_battery];
                    }
                }
            }
            
        }
            break;
            
        default:
        {
            if (self.netType == DeviceNetType_Offline || self.netType == DeviceNetType_Connetct)
            {
                retStr = @"";
            }
            else if (self.isCharging)
            {
                retStr = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"CHARGING"],[_battery intValue]];
            }
            else
            {
                if (_battery != nil)
                {
                    retStr = [NSString stringWithFormat:@"%@%%",_battery];
                }
            }
        }
            break;
    }
    
    
    
    return retStr;
}

/**
 *  移动网络
 */
- (NSString *)net
{
    switch (self.netType) {
        case JFGNetTypeWifi:
        {
            _net = @"WIFI";
        }
            break;
        case JFGNetType2G:
        {
            _net = @"2G";
        }
            break;
        case JFGNetType3G:
        {
            _net = @"3G";
        }
            break;
        case JFGNetType4G:
        {
            _net = @"4G";
        }
            break;
        case JFGNetType5G:
        {
            _net = @"5G";
        }
            break;
        case JFGNetTypeConnect:
        case  JFGNetTypeOffline:
        {
            _net = [JfgLanguage getLanTextStrByKey:@"OFF"];
        }
            break;
        default:
            break;
    }
    
    return _net;
}

/*
 * Wi-Fi
 */
- (NSString *)wifi
{
    switch (self.netType)
    {
        case DeviceNetType_Offline:
        case DeviceNetType_Connetct:
        {
            _wifi = [JfgLanguage getLanTextStrByKey:@"OFF"];
        }
            break;
        case DeviceNetType_2G:
        case DeviceNetType_3G:
        case DeviceNetType_4G:
        case DeviceNetType_5G:
        {
            _wifi = [JfgLanguage getLanTextStrByKey:@"OFF"];
        }
            break;
        default:
            break;
    }
    return _wifi;
}

- (NSString *)mobileNet
{
    switch (self.netType)
    {
        case DeviceNetType_Wifi:
        case DeviceNetType_Offline:
        case DeviceNetType_Connetct:
        {
            _mobileNet = [JfgLanguage getLanTextStrByKey:@"OFF"];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    return _mobileNet;
}


- (NSString *)SDCardSpace
{
    if (self.isSDCardExist)
    {
        CGFloat userfulSpace = (self.totalSpace - self.usedSpace)/1024.0/1024.0/1024.0;
        
        if (self.sdCardError == 0)
        {
            _SDCardSpace = [NSString stringWithFormat:@"%.1fGB%@",userfulSpace,[JfgLanguage getLanTextStrByKey:@"Sdcard_AvailableCapacity"]];
        }
        else
        {
            _SDCardSpace = [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_UninitializedTips"];
        }
    }
    else
    {
        _SDCardSpace = [NSString stringWithFormat:@"0GB%@",[JfgLanguage getLanTextStrByKey:@"Sdcard_AvailableCapacity"]];
    }
    return _SDCardSpace;
}

- (SDCardType)sdCardType
{
    
    if (self.isSDCardExist)
    {
        if (self.sdCardError == 0)
        {
            _sdCardType = SDCardType_Using;
        }
        else
        {
            _sdCardType = SDCardType_Error;
        }
    }
    else
    {
        _sdCardType = SDCardType_None;
    }
    
    return _sdCardType;
}

- (UIColor *)detailTextColor
{
    if (self.isSDCardExist && self.sdCardError != 0)
    {
        _detailTextColor = [UIColor colorWithHexString:@"#ff3d32"];
    }
    else
    {
        _detailTextColor = [UIColor colorWithHexString:@"#888888"];
    }
    
    return _detailTextColor;
}

/*
 *
 */
- (NSString *)lastingUseTime
{
    if (self.updateTime > 0 && (self.netType != DeviceNetType_Offline && self.netType != DeviceNetType_Connetct))
    {
        int seconds = [[NSDate date] timeIntervalSince1970] - self.updateTime;
        _lastingUseTime = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"STANBY_TIME"],seconds/3600/24, seconds/3600%24, (seconds/60)%60];
    }
    else
    {
        _lastingUseTime = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"STANBY_TIME"],0,0,0];
    }
    
    return _lastingUseTime;
}

/*
 *  新固件
 */
//- (NSString *)newPackageStr
//{
//    if (self.hasNewPackage == YES)
//    {
//        _newPackageStr = [JfgLanguage getLanTextStrByKey:@"Tap1_NewFirmware"];
//    }
//    else
//    {
//        _newPackageStr = @"";
//    }
//    return self.softVersion;
//}

@end
