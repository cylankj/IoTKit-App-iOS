//
//  HorizontalHistoryRecordView+DataDeal.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "HorizontalHistoryRecordView.h"
@class JFGSDKHistoryVideoInfo;
@class historyVideoDurationTimeModel;

@interface HorizontalHistoryRecordView (DataDeal)
/**
 *  数据处理
 *
 *  @param list 所有历史记录数据
 *
 *  @return 按时间顺序排好序，并按每天分好组的历史记录
 */
-(NSArray *)dataDeal:(NSArray<JFGSDKHistoryVideoInfo *> *)list;


/**
 *  查找标杆最近的历史记录
 *
 *  @param diff      距离0：00的距离
 *  @param mouthList 按时间顺序排好序的一天时间内所有历史记录
 *
 *  @return 距标杆最近的历史记录
 */
-(historyVideoDurationTimeModel *)nearestHistoryModel:(CGFloat)diff mouthList:(NSArray <historyVideoDurationTimeModel *>*)mouthList;

/**
 *  查找标杆右边最近的历史记录
 *
 *  @param diff      距离0：00的距离
 *  @param mouthList 同上
 *
 *  @return 标杆右边最近的历史记录
 */
-(historyVideoDurationTimeModel *)rightNearestHistoryModel:(CGFloat)diff mouthList:(NSArray <historyVideoDurationTimeModel *>*)mouthList;

/**
 *  获取有历史视频的日期
 *
 *  @param list 按时间顺序排好序，并按每天分好组的历史记录
 *
 *  @return 有历史视频的日期模型数组
 */
-(NSArray <HistoryVideoDayModel *>*)historyVideoLimistForDayFromAllDataArr:(NSArray <NSArray <historyVideoDurationTimeModel *> *> *)list;



@end
