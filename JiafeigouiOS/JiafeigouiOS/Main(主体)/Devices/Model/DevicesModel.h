//
//  DevicesModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDevicesModel.h"
#import "SafeProtectModel.h"
#import "DeviceSettingModel.h"
#import "DeviceInfoModel.h"

@interface DevicesModel : BaseDevicesModel

@property (nonatomic, assign) productType pType;

@property (nonatomic, strong) DeviceSettingModel *deviceSettingModel;

@property (nonatomic, strong) SafeProtectModel *safeProtectModel;

@property (nonatomic, strong) DeviceVoiceModel *deviceVoiceModel;

@property (nonatomic, strong) DeviceInfoModel *deviceInfoModel;

@property (nonatomic, assign, readonly) long timeZoneSecond;

@end
