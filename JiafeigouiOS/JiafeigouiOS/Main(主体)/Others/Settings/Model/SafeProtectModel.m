//
//  SafeProtectModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SafeProtectModel.h"
#import "JfgTypeDefine.h"
#import "JfgDataTool.h"
#import "JfgLanguage.h"

@implementation SafeProtectModel

/**
 *  灵敏度
 */
- (NSString *)sensitiveStr
{
    switch (self.sensitive)
    {
        case sensitiveTypeLow:
            return [JfgLanguage getLanTextStrByKey:@"SENSITIVI_LOW"];
            break;
        case sensitiveTypeNormal:
            return [JfgLanguage getLanTextStrByKey:@"SENSITIVI_STANDARD"];
            break;
        case sensitiveTypeHigh:
            return [JfgLanguage getLanTextStrByKey:@"SENSITIVI_HIGHT"];
            break;
        default:
            break;
    }
    return @"";
}


/**
 *  设备 提示音
 */

- (NSString *)soundStr
{
    switch (self.soundType)
    {
        case soundTypeMute:
            return [JfgLanguage getLanTextStrByKey:@"MUTE"];
            break;
        case soundTypeBark:
            return [JfgLanguage getLanTextStrByKey:@"BARKING"];
            break;
        case soundTypeWarning:
            return [JfgLanguage getLanTextStrByKey:@"ALARM"];
            break;
        default:
            break;
    }
    return @"";
}

/**
 *  开始时间
 */
- (NSString *)beginTimeStr
{
    return [NSString stringWithFormat:@"%d:%02d", self.beginTime>>8&0xff, self.beginTime&0xff];
}

/**
 *  结束时间
 */
- (NSString *)endTimeStr
{
    return [NSString stringWithFormat:@"%d:%02d", self.endTime>>8&0xff, self.endTime&0xff];
}

/**
 *  重复 时间
 */
- (NSString *)repeatStr
{
    return [JfgDataTool repeatTimeStr:self.repeat];
}

@end


#pragma mark
#pragma mark  == DeviceVoiceModel ===
@implementation DeviceVoiceModel

- (BOOL)isMuteChecked
{
    if (self.soundType == soundTypeMute)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isBarkChecked
{
    if (self.soundType == soundTypeBark)
    {
        return YES;
    }
    return NO;
}

- (BOOL)isWarnChecked
{
    if (self.soundType == soundTypeWarning)
    {
        return YES;
    }
    return NO;
}

- (NSString *)voiceRepeatStr
{
    if (_voiceRepeatStr == nil)
    {
        _voiceRepeatStr = [NSString stringWithFormat:@"%d次",self.voiceRepeatTime];
    }
    return _voiceRepeatStr;
}

@end

#pragma mark
#pragma mark  == DeviceRepeatModel ===

@implementation DeviceRepeatModel

- (BOOL)isMonChecked
{
    if (self.repeatDate>>(6-0) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isTueChecked
{
    if (self.repeatDate>>(6-1) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isWedChecked
{
    if (self.repeatDate>>(6-2) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isThuChecked
{
    if (self.repeatDate>>(6-3) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isFriChecked
{
    if (self.repeatDate>>(6-4) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isSatChecked
{
    if (self.repeatDate>>(6-5) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}

- (BOOL)isSunChecked
{
    if (self.repeatDate>>(6-6) & 0x1) // indePath.row 下标
    {
        return YES;
    }
    return NO;
}


@end


