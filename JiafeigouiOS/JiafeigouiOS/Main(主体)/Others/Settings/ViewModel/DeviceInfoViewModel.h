//
//  DeviceInfoViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"
#import "JfgTypeDefine.h"
#import "tableViewDelegate.h"
#import "JFGBoundDevicesMsg.h"
/**
 *  
 *  功能 设置  设备信息 页面
 *  
 *
 */

typedef NS_ENUM(NSInteger, DeviceInfoType)
{
    DeviceInfoTypeInfo, // 设备信息
    DeviceInfoTypeAutoPhoto, // 自动录像
};

@interface DeviceInfoViewModel : BaseViewModel

@property (assign, nonatomic) DeviceInfoType deviceInfoType;

@property (nonatomic,copy) NSString *alias;

@property (assign, nonatomic) id<tableViewDelegate> myDelegate;


- (NSArray *)dataArrayFromViewModelWithProductType:(productType)type Cid:(NSString *)cid;

- (void)updateTimeZone:(NSString *)zoneID timeZone:(int)zoneTime;

- (void)updateAliasWithString:(NSString *)newAlias;

- (void)clearSDCard;

- (BOOL)isClearingSDCard;
//- (void)removeDataPointReq;
@end
