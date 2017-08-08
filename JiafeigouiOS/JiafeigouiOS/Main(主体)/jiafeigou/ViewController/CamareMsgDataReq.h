//
//  CamareMsgDataReq.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "MessageVCDateModel.h"

@protocol CamareMsgDataReqDelegate <NSObject>

@optional
//数据请求成功
-(void)requestCamareSuccess:(NSArray <MessageModel *> *)dataList forCid:(NSString *)cid refresh:(BOOL)refresh;

//数据请求失败
-(void)requestCamareFailedForCid:(NSString *)cid refresh:(BOOL)refresh;

//请求当前时间点前15天，哪天有数据处理完成
-(void)dateModelIsHasDataDealSuccess;

//请求当前时间点前15天，哪天有数据处理失败
-(void)dateModelIsHasDataDealFailer;

@end


/**
 * 摄像头报警消息请求类
 */
@interface CamareMsgDataReq : NSObject


@property (nonatomic,weak)id <CamareMsgDataReqDelegate> delegate;

/**
 * 请求摄像头报警图片
 * @param timestamp  数据最近时间点，倒叙查询
 */
-(void)getDataForCid:(NSString *)cid
           timestamp:(uint64_t)timestamp
           isRefresh:(BOOL)isRefresh;


/**
 * 获取当前十五天（包括今天）原始数据模型（MessageVCDateModel）
 */
-(NSArray <MessageVCDateModel *> *)getDateModelsBefore15DayWithNow;

/**
 * 所给数据模型当天是否有报警数据(摄像头505，222，512)
 */
-(void)dateModelForCamareIsHasDataForDateModels:(NSArray <MessageVCDateModel *> *)dateModels cid:(NSString *)cid;


/**
 * 所给数据模型当天是否有报警数据(门铃401，403)
 */
-(void)dateModelForDoorBellIsHasDataForDateModels:(NSArray <MessageVCDateModel *> *)dateModels cid:(NSString *)cid;

@end
