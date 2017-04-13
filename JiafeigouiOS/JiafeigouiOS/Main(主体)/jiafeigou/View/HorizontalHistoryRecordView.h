//
//  HorizontalHistoryRecordView.h
//  HorizontalTableView
//
//  Created by 杨利 on 16/6/24.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "historyVideoDurationTimeModel.h"
#import "HistoryVideoDayModel.h"
@protocol HorizontalHistoryRecordViewDelegate;

typedef NS_ENUM(NSInteger,ViewType){
    ViewTypeFullMode,
    ViewTypeSmallMode,
};

static CGFloat markImageWidth = 3360/2;

@interface HorizontalHistoryRecordView : UIView

@property (nonatomic,copy)NSString *cid;

@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong)UITableView *horizontalTableView;

@property (nonatomic,assign)ViewType viewType;

@property (nonatomic,assign)BOOL isSelectedHistory;

//滚动条指示所在历史视频
@property (nonatomic,strong)historyVideoDurationTimeModel *currentHistoryVideoModel;

@property (nonatomic,assign)id<HorizontalHistoryRecordViewDelegate>delegate;

@property (nonatomic,assign)CGFloat fristRowHeight;

-(instancetype)initWithFrame:(CGRect)frame forCid:(NSString *)cid;

-(void)startHistoryVideoFromDay:(HistoryVideoDayModel *)dayModel;

/**
 *  根据时间戳设置偏移量
 *
 *  @param timeStamp 时间戳
 *
 *  @return 自动播放是否超出当前选定的日期 YES：是，停止自动播放  NO：否，继续播放
 */
-(BOOL)setHistoryTableViewOffsetByTimeStamp:(int64_t)timeStamp;

-(void)reloadData;

-(void)requestData;

@end


@protocol HorizontalHistoryRecordViewDelegate <NSObject>

//当前滚动条标记的历史视频
-(void)currentHistoryVideoModel:(historyVideoDurationTimeModel *)model;

//所有历史视频范围（天数）
-(void)historyVideoDateLimits:(NSArray <HistoryVideoDayModel *> *)limits;

//所有历史记录
-(void)historyVideoAllList:(NSArray <NSArray <historyVideoDurationTimeModel *>*>*)list;

//视频直播，历史切换按钮回调
-(void)transionHistoryVideo:(BOOL)isHistory;

-(void)historyBarStartScroll;

-(void)historyBarEndScroll;

@end
