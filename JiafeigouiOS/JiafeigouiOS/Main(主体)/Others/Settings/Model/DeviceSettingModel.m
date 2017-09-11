//
//  DeviceSettingModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceSettingModel.h"
#import "JfgTypeDefine.h"
#import "JfgLanguage.h"
#import "UIColor+HexColor.h"
#import "JfgUserDefaultKey.h"
#import "JfgConstKey.h"
#import "CommonMethod.h"
#import "JfgProductJduge.h"
#import "SDImageCache.h"
#import "JfgDataTool.h"
#import "CommonMethod.h"
#import "AuthorizedMethod.h"

@implementation DeviceSettingModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

//设备信息
- (NSString *)info
{
    if (_info == nil)
    {
        _info = @"";
    }
    
    if (self.pType != productType_720 && self.pType != productType_720p)
    {
        if (self.isShare)
        {
            _detailTextColor = [UIColor colorWithHexString:@"#888888"];
            return _info;
        }
    }
    
    
    if (self.sdCardError != 0 && self.isExistSDCard == YES)
    {
        _detailTextColor = [UIColor colorWithHexString:@"#ff3d32"];
//        _info = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SD_INIT_ERR"],self.sdCardError];
    }
    else
    {
        _detailTextColor = [UIColor colorWithHexString:@"#888888"];
        
    }
    return _info;
}

/*
 *  SD卡
 */

- (NSString *)SDCardInfo
{
    if (!self.isExistSDCard) // 不存在 SDCard
    {
        _SDCardInfo = [JfgLanguage getLanTextStrByKey:@"SD_NO"];
    }
    else if (self.sdCardError == 0) // 存在SDcard 正常使用
    {
        _SDCardInfo = [JfgLanguage getLanTextStrByKey:@"SD_NORMAL"];
    }
    else if (self.sdCardError != 0)
    {
        _SDCardInfo = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SD_INIT_ERR"],self.sdCardError];
    }
    
    return _SDCardInfo;
}

- (SDCardType)sdCardType
{
    
    if (self.isExistSDCard)
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

- (NSString *)safe
{
    if (self.isWarnEnable)
    {
        NSString *repeatStr = [JfgDataTool repeatTimeStr:self.safeOrigin];
        
        if (self.beginTime == 0 && self.endTime == 5947)
        {
            _safe = [NSString stringWithFormat:@"%@ %@",repeatStr, [JfgLanguage getLanTextStrByKey:@"ALLDAY"]];
        }
        else
            
        {
            NSString *beginTimeStr = [NSString stringWithFormat:@"%d:%02d", self.beginTime>>8&0xff, self.beginTime&0xff];
            NSString *endTimeStr = [NSString stringWithFormat:@"%@%d:%02d",self.beginTime>=self.endTime?[JfgLanguage getLanTextStrByKey:@"TOW"]:@"", self.endTime>>8&0xff, self.endTime&0xff];
            
            _safe = [NSString stringWithFormat:@"%@ %@~%@",repeatStr,beginTimeStr,endTimeStr];
        }
        
    }
    else
    {
        _safe = [JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"];
    }
    return _safe;
}

- (NSString *)delayPhoto
{
    if (self.isOpenDelayPhoto)
    {
        if ([[NSDate date] timeIntervalSince1970] < self.delayPhotoBeginTime)
        {
            return [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_NotStart"];
        }
        else
        {
            return [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Filming"];
        }
    }
    else
    {
        return [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Unopened"];
    }
    
    return @"";
}

- (NSString *)wifi
{
    switch (self.pType)
    {
        case productType_720p:
        case productType_720:
        {
            if (_wifi == nil || [_wifi isEqualToString:@""] || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
            {
                return [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Unopened"];
            }
        }
            break;
            
        default:
        {
            if (_wifi == nil || (self.SIMCardType == SIMType_Using && self.isMobile == YES) || self.deviceNetType ==  DeviceNetType_Wired)
            {
                return @"";
            }
        }
            break;
    }
    
    return _wifi;
}

/**
 * 自动录像
 */
- (NSInteger)autoPhotoOrigin
{
    if (!self.isExistSDCard)
    {
        return -1;
    }
    
    return _autoPhotoOrigin;
}

- (NSString *)autoPhoto
{
    
    if ([JfgProductJduge isAutoRecordSwitch:self.pType])
    {
        switch (self.pType)
        {
            case productType_CatEye:
            {
                return @"";
            }
                break;
                
            default:
            {
                return [JfgLanguage getLanTextStrByKey:(self.autoPhotoOrigin == MotionDetectAbnormal)?@"OPEN":@"MAGNETISM_OFF"];
                
            }
                break;
        }
        
    }
    switch (self.autoPhotoOrigin)
    {
        case MotionDetectNever:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_2"];
        }
            break;
        case MotionDetectAllDay:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_1"];
        }
            break;
        case MotionDetectAbnormal:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE"];
        }
            break;
        case MotionDetectNone:
        default:
            return @"";
            break;
    }
}

// 设备指示灯
- (BOOL)isOpenIndicator
{
    if (self.isStandby == YES)
    {
        return NO;
    }
    
    return _isOpenIndicator;
}

/*
 * 视角
 */
- (NSString *)angleStr
{
    switch (self.angleType)
    {
        case angleType_Over:
        {
            _angleStr = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Overlook"];
        }
            break;
        default:
        case angleType_Front:
        {
            _angleStr = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Front"];
        }
            break;
    }
    
    return _angleStr;
}

/**
 *  是否开启 通知
 */
- (BOOL)isOpenNotifi
{
    if ([AuthorizedMethod isOpenSystemNotification])
    {
        return _isOpenNotifi;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isShowSafeRedDot
{
    return [JfgDataTool isShowRedDotInSafeProColumn:self.cid pid:self.pType];
}

- (BOOL)isShowAutoPhotoRedDot
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowAutoPhotoRedDot(self.cid)];
}
- (BOOL)isShowDelayPhotoRedDot
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowDelayPhotoRedDot(self.cid)];
}

-(BOOL)isShowDeepSleepRedDot
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowDeepSleepRedDot(self.cid)];
}

- (BOOL)isShowWxRedDot
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:JFGIsAlwaysShowWebchatRedPointKey];;
}

- (BOOL)isShowOthersRedDot
{
    return NO;
}

- (BOOL)isStandByCanClick
{
    return [JfgDataTool deviceIsOnline:self.deviceNetType];
}
- (BOOL)isMobileCanClick
{
    if (self.isStandby == YES)
    {
        return NO;
    }
    
    return [JfgDataTool deviceIsOnline:self.deviceNetType];
}
- (BOOL)isDelayPhotoCanClick
{
    if (self.isStandby == YES)
    {
        return NO;
    }
    
    return [JfgDataTool deviceIsOnline:self.deviceNetType];
}

- (BOOL)isWifiConfigCanClick
{
    switch (self.pType) {
        case productType_IPCam:
        case productType_IPCam_V2:
        {
            if (self.isUsingWiredNet)
            {
                return NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    
    return YES;
}

- (BOOL)isHotWiredCanClick
{
    if (self.isStandby) // 待机 不可点击
    {
        return NO;
    }
    
    if ((self.isInLocalNet == YES && ![CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid]) || [JfgDataTool deviceIsOnline:self.deviceNetType])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isWiredNetAvailalbe
{
    if (self.isStandby) // 待机 不可点击
    {
        return NO;
    }
    
    if (![JfgDataTool deviceIsOnline:self.deviceNetType])
    {
        return NO;
    }
    
    return _isWiredNetAvailalbe;
}

// 所有的cell
- (BOOL)isCellCanClick
{
    if (self.isStandby == YES)
    {
        return NO;
    }
    
    return YES;
}


- (NSString *)outdoorString
{
    if ([CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
    {
        return [JfgLanguage getLanTextStrByKey:@"OPEN"];
    }
    else
    {
        return [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Unopened"];
    }

}

- (NSString *)cacheString
{
//    NSInteger diskSize = [[SDImageCache sharedImageCache] getSize];
//    NSString *cacheStr = [NSString stringWithFormat:@"%.1fM",diskSize/1024.0/1024.0];
    
    return @"";
}

@end
