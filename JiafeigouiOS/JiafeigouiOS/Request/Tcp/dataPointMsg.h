//
//  dataPointMsg.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFGSDK/JFGSDKDataPoint.h>

typedef void (^aSuccessBlock)(NSMutableDictionary * dic);
typedef void (^aSuccessArrBlock)(NSMutableArray *arr);
typedef void (^aFailBlock)(RobotDataRequestErrorType error);

@interface dataPointMsg : NSObject

+ (dataPointMsg *)shared;

// 获取某些消息id的最新一条数据
- (void)packSingleDataPointMsg:(NSArray *)msgIdArr withCid:(NSString *)cid SuccessBlock:(aSuccessBlock)sBlock FailBlock:(aFailBlock)fBlock;

// 设置设备 DataPoint
- (void)setdpDataWithCid:(NSString *)cid dps:(NSArray <DataPointSeg *>*)dps success:(aSuccessBlock)success failed:(aFailBlock)failed;

- (void)packMutableDataPointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessBlock:(aSuccessBlock)sBlock FailBlock:(aFailBlock)fBlock;

- (void)packMutableDataPointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessArrBlock:(aSuccessArrBlock)sBlock FailBlock:(aFailBlock)fBlock;


- (void)packMutableDataCachePointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessBlock:(aSuccessBlock)sBlock;

// 组合查询
- (void)packMixDataPoint:(NSString *)cid version:(uint64_t)version dps:(NSArray<NSNumber *> *) dps asc:(BOOL)asc success:(aSuccessArrBlock)sBlock failed:(aFailBlock)fBlock;

@end
