//
//  subSafeProtectViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "tableViewDelegate.h"

typedef NS_ENUM(NSInteger, SafeProtectType)
{
    SafeProtectTypeDeviceVoice, // 设备提示音
    SafeProtectTypeProtectTime, // 报警时间段
    SafeProtectTypeAngleSetting, // 全景视角 设置
};


@interface subSafeProtectViewModel : BaseViewController

- (NSArray *)requestData;

@property (assign, nonatomic) SafeProtectType safeProtectType;
@property (assign, nonatomic) id<tableViewDelegate> myDelegate;

#pragma mark
#pragma mark  ==== 设备提示音====
- (void)initDataWithSelected:(int)soundType time:(int)voiceRepeatTime;
- (void)updatevoiceType:(int)soundType time:(int)repeatTime;

#pragma mark
#pragma mark  ==== 重复 ====
- (void)initRepeatModel:(int)repeatDate;
- (int)updateDayChecked:(NSIndexPath *)indexPath;

#pragma mark 
#pragma mark ==== 全景 ===

@end
