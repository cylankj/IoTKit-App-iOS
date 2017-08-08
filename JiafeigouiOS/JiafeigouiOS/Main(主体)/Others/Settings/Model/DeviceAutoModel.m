//
//  DeviceAutoModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "DeviceAutoModel.h"
#import "JfgUserDefaultKey.h"

@implementation DeviceAutoModel


- (BOOL)isRecordWhenWatching
{
    if (!self.isExistSDCard)
    {
        return NO;
    }
    
    return _isRecordWhenWatching;
}

- (BOOL)isOpenMovetionDection
{
    if (!self.isExistSDCard)
    {
        return NO;
    }
    else
    {
        _isOpenMovetionDection = (self.movetionDectrionType == MotionDetectAbnormal);
    }
    
    return _isOpenMovetionDection;
}

- (BOOL)isShowRecordRedDot
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isShowRecordRedDot(self.cid)];
}

@end
