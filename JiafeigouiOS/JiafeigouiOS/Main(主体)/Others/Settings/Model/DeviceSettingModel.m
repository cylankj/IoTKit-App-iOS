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
#import "JfgDataTool.h"
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
    
    
    if (self.sdCardError != 0 && self.isExistSDCard == YES)
    {
        _detailTextColor = [UIColor colorWithHexString:@"#ff3d32"];
        _info = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SD_INIT_ERR"],self.sdCardError];
    }
    else
    {
        _detailTextColor = [UIColor colorWithHexString:@"#888888"];
        
    }
    return _info;
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
    if (_wifi == nil || (self.SIMCardType == SIMType_Using && self.isMobile == YES))
    {
        return @"";
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
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowSafeRedDot(self.cid)];
}

- (BOOL)isShowAutoPhotoRedDot
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowAutoPhotoRedDot(self.cid)];
}
- (BOOL)isShowDelayPhotoRedDot
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:isShowDelayPhotoRedDot(self.cid)];
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


// 所有的cell
- (BOOL)isCellCanClick
{
    if (self.isStandby == YES)
    {
        return NO;
    }
    
    return YES;
}

@end
