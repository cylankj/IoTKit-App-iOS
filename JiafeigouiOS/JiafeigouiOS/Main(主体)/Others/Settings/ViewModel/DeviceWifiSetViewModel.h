//
//  DeviceWifiSetViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
/**
 *  是否 加锁
 */
NSString *const isLocked = @"_isLocked";
/**
 *  信号 强度
 */
NSString *const signalStrength = @"_signalStrength";


@protocol DeviceWifiSetVMDelegate <NSObject>

- (void)fetchData:(NSDictionary *)dataDict;
- (void)updatedData:(NSDictionary *)updateDict;

@end

@interface DeviceWifiSetViewModel : BaseViewModel

@property (weak, nonatomic) id<DeviceWifiSetVMDelegate> deviceWifiSetdelegate;

- (void)requestDataWithCid:(NSString *)cid connectedWifi:(NSString *)connecttedWifi;
@end
