//
//  DeviceSettingViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewModel.h"
#import "JfgTypeDefine.h"

@protocol DeviceSettingVMDelegate <NSObject>

- (void)fetchDataArray:(NSArray *)fetchArray;
- (void)updatedDataArray:(NSArray *)updatedArray;

@end

@interface DeviceSettingViewModel : BaseViewModel
{}


@property (weak, nonatomic) id<DeviceSettingVMDelegate> delegate;

@property (copy, nonatomic) NSString * alias;

@property (weak,nonatomic)UIViewController *fwVC;

- (NSArray *)dataArrayFromViewModelWithProductType:(productType)type Cid:(NSString *)cid;

- (void)updateDataWithIndexPath:(NSIndexPath *)indexPath changedValue:(id)changedValue;
- (void)updateDataWithCelluuid:(NSString *)cellUniqueID changedValue:(id)changedValue;

- (void)updateMotionDection:(NSInteger)dectionType;
- (void)updateMotionDection:(NSInteger)dectionType tipShow:(BOOL)isShow;

- (void)updateTime:(int)repeatDate;

- (void)updateAliasWithString:(NSString *)newAlias;

- (void)updateSafeProtectStr:(BOOL)warnEnable repeatTime:(int)repeat begin:(int)beginTime end:(int)endTime;
- (void)updateWarnEnable:(BOOL)isOpen;

// 无网络请求  更新数据
- (void)updateSettingsWithType:(productType)type cid:(NSString *)cid;

- (void)deleteMsg;

// 更新 全景视角
- (void)updatePanoAngle:(int)angleType;
// 开启 热点
- (void)openHotWired;
- (void)sendOpenHotWireMsg;

// 清空 SDcard
- (void)clearSDCard;
- (void)clearSDCardFinish;
- (BOOL)isClearingSDCard;
@end
