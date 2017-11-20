//
//  timeChangeMonitor.h
//  JiafeigouiOS
//
//  Created by yangli on 16/5/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TimeChangeMonitorDelegate;

@interface TimeChangeMonitor : NSObject

+(instancetype)sharedManager;

/**
 *  开始时间监测（5分钟执行一次）
 */
-(void)starTimer;

/**
 *  停止定时器并销毁
 */
-(void)stopTimer;

/**
 *  定时器是否有效
 */
-(BOOL)isValid;

/**
 *  手动执行定时器操作
 */
-(void)timerAction;

-(void)addDelegate:(id<TimeChangeMonitorDelegate>)delegate;

-(void)removeDelegate:(id<TimeChangeMonitorDelegate>)delegate;

@end


@protocol TimeChangeMonitorDelegate <NSObject>

@optional

//时间改变代理（5分钟回调一次）
-(void)timeChangeWithCurrentYear:(NSInteger)year
                           month:(NSInteger)month
                             day:(NSInteger)day
                            hour:(NSInteger)hour
                          minute:(NSInteger)minute;


@end
