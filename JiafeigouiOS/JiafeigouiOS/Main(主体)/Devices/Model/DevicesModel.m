//
//  DevicesModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DevicesModel.h"
#import "JfgTypeDefine.h"
#import "dataPointMsg.h"
#import "JfgGlobal.h"

@interface DevicesModel()

@property (nonatomic, assign,) long timeZoneSecond;

@end


@implementation DevicesModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.timeZoneSecond = [NSTimeZone defaultTimeZone].secondsFromGMT;
    }
    return self;
}

- (DeviceSettingModel *)deviceSettingModel
{
    if (_deviceSettingModel == nil)
    {
        _deviceSettingModel = [[DeviceSettingModel alloc] init];
        _deviceSettingModel.isStandby = NO;
        _deviceSettingModel.isOpenIndicator = YES;
        _deviceSettingModel.isRotate = NO;
        _deviceSettingModel.isNTSC = NO;
        _deviceSettingModel.isMobile = NO;
        _deviceSettingModel.angleType = angleType_Front;
        
        switch (self.pType)
        {
            case productType_IPCam_V2:
            case productType_IPCam:
            {
                _deviceSettingModel.autoPhotoOrigin = MotionDetectNever;
            }
                break;
                
            default:
            {
                _deviceSettingModel.autoPhotoOrigin = MotionDetectNone;
            }
                break;
        }
        
    }
    
    return _deviceSettingModel;
}

- (SafeProtectModel *)safeProtectModel
{
    if (_safeProtectModel == nil)
    {
        _safeProtectModel = [[SafeProtectModel alloc] init];
        //        相同属性 赋值
        _safeProtectModel.sensitive = sensitiveTypeNormal;
        _safeProtectModel.repeat = 127;
        _safeProtectModel.beginTime = 0;
        _safeProtectModel.endTime = 5947;
        
        switch (self.pType)
        {
            case productType_IPCam:
            case productType_IPCam_V2:
            {
                _safeProtectModel.isWarnEnable = NO;
            }
                break;
                
            default:
            {
                _safeProtectModel.isWarnEnable = YES;
            }
                break;
        }
        
        
    }
    return _safeProtectModel;
}

- (DeviceVoiceModel *)deviceVoiceModel
{
    if (_deviceVoiceModel == nil)
    {
        _deviceVoiceModel = [[DeviceVoiceModel alloc] init];
        _deviceVoiceModel.soundType = soundTypeMute;
        _deviceVoiceModel.voiceRepeatTime = 1;
    }
    
    return _deviceVoiceModel;
}

- (DeviceInfoModel *)deviceInfoModel
{
    if (_deviceInfoModel == nil)
    {
        _deviceInfoModel = [[DeviceInfoModel alloc] init];
        _deviceInfoModel.timeZoneOrigin = [[NSTimeZone localTimeZone] name];
        
    }
    
    return _deviceInfoModel;
}

@end
