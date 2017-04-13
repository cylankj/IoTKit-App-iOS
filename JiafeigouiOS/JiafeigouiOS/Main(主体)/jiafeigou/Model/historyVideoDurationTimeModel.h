//
//  historyVideoDurationTimeModel.h
//  HorizontalTableView
//
//  Created by 杨利 on 16/6/24.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface historyVideoDurationTimeModel : NSObject

//历史视频开始时间戳
@property (nonatomic,assign)NSInteger startTimestamp;

//历史视频开始播放时间戳
@property (nonatomic,assign)NSInteger startPlayTimestamp;

//持续时长
@property (nonatomic,assign)NSInteger duration;

//以下方法的调取必须在以上两个属性值都正确赋值的情况下
/**
 *  在一个图片单位长度的刻度上的开始位置
 *
 *  @note camera_Timeline图片改变，方法内部计算数据也得修改
 */
-(float)startPosition;

/**
 *  在一个图片单位长度的刻度上的结束位置
 *
 *  @note camera_Timeline图片改变，方法内部计算数据也得修改
 */
-(float)endPosition;

/**
 *  在一个图片单位长度的刻度上的某点是否在历史视频区间
 *
 *  @note camera_Timeline图片改变，方法内部计算数据也得修改
 */
-(BOOL)isBetweenWithPosition:(float)position;

/**
 *  计算某个时间戳是否在这个model之间
 *
 *  @param timestamp 时间戳
 *
 *  @return YES NO
 */
-(BOOL)isBetweenWithPositionByTimestamp:(int64_t)timestamp;

//录像开始年份
-(NSInteger)startYear;

//录像开始月份
-(NSInteger)startMouth;

//录像开始日期
-(NSInteger)startDay;

//录像开始的小时
-(NSInteger)startHour;

//录像开始的分钟
-(NSInteger)startMin;

@end
