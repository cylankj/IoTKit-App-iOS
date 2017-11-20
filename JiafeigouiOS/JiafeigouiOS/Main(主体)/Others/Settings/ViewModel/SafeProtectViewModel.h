//
//  SafeProtectViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
#import "tableViewDelegate.h"

@interface SafeProtectViewModel : BaseViewModel

@property (weak, nonatomic) id<tableViewDelegate> delegate;

@property (nonatomic, assign, readonly) int beginTime;
@property (nonatomic, assign, readonly) int endTime;
@property (nonatomic, assign, readonly) int repeat;
@property (nonatomic, assign, readonly) BOOL isWarnEnable;
@property (nonatomic, assign, readonly) BOOL isMotionDetectAbnormal;

- (void)requestDataWithCid:(NSString *)cid;
// 移动侦测开关
- (void)updateMoveDection:(BOOL)isOpen;
//红外增强
-(void)updateInfraredStrengthen:(BOOL)isOpen;
// 更改 灵敏度
- (void)updateSensitive:(NSInteger)sensitiveType;
// 修改 报警时间 间隔
- (void)updateWarnDuration:(int)warnDur;
// 更改 AI 人形
- (void)updateAIRecgnition:(NSArray *)aiTypes;

#pragma mark 
#pragma mark  设备提示音 
- (void)updatevoiceType:(int)soundType time:(int)repeatTime;

#pragma mark
#pragma mark  重组 日期
- (void)updateRepeatDate:(int)repeatDate;
- (void)updatebeginTime:(int)beginTime endTime:(int)endTime;
@end
