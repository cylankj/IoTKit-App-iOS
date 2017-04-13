//
//  subSafeProtectVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 *  设备提示音，
 *  时间重复     共用此界面
 */

#import "BaseViewController.h"
#import "subSafeProtectViewModel.h"

@protocol subSafeProtectDelegate <NSObject>

@optional
- (void)updateDeviceVoice:(int)voiccType duration:(int)repeatTime;

- (void)updateRepeatDate:(int)repeatDate;

@end

@interface subSafeProtectVC : BaseViewController

@property (assign, nonatomic) SafeProtectType protectType;
@property (assign, nonatomic) id<subSafeProtectDelegate> myDelegate;

#pragma mark
#pragma mark  === 设备提示音 ====
@property (assign, nonatomic) soundType oldVoiceType;
@property (assign, nonatomic) int oldRepeatTime;

#pragma mark
#pragma mark  === 重复时间 ====
@property (assign, nonatomic) int oldRepeatDate;


@end
