//
//  dataPointMsg.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "dataPointMsg.h"
#import "JfgMsgDefine.h"
#import <JFGSDK/JFGSDK.h>

@implementation dataPointMsg

- (id)init{
    if (self = [super init]) {
        
    }
    return self;
}
+ (dataPointMsg *)shared{
    static dispatch_once_t once = 0;
    static dataPointMsg * dpMsg;
    dispatch_once(&once, ^{
        dpMsg = [[dataPointMsg alloc] init];
    });
    
    return dpMsg;
}

#pragma mark 
#pragma mark  == dp request ==
//获取单条dp
- (void)packSingleDataPointMsg:(NSArray <NSNumber *>*)msgIdArr withCid:(NSString *)cid SuccessBlock:(aSuccessBlock)sBlock FailBlock:(aFailBlock)fBlock{
    
    if (cid == nil)
    {
        [JFGSDK appendStringToLogFile:@"error: dp request cid is null"];
        return;
    }
    [[JFGSDKDataPoint sharedClient]robotGetSingleDataWithPeer:cid msgIds:msgIdArr success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        
        for (NSArray * subArr in idDataList)
        {
            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error && obj)
                {
                    [dataDict setValue:obj forKey:[self dpKeyWithMsgID:(NSInteger)seg.msgId]];
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"  getdp cid:%@ dpID[%llu] “%@”   dpValue[%@]",cid,seg.msgId, [self dpKeyWithMsgID:(NSInteger)seg.msgId], obj]];
                }
                else
                {
                    
                }
            }
        }
        
        if (sBlock != nil)
        {
            sBlock(dataDict);
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        fBlock(type);
    }];
}
//获取多条dp
- (void)packMutableDataPointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessBlock:(aSuccessBlock)sBlock FailBlock:(aFailBlock)fBlock {
    
    if (cid == nil) {
        return;
    }
    [[JFGSDKDataPoint sharedClient]robotGetDataWithPeer:cid msgIds:msgIdArr asc:asc limit:limit success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        int msgID = -1;
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        
        for (NSArray * subArr in idDataList)
        {
            NSMutableArray *values = [NSMutableArray array];
            
            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                msgID = (NSInteger)seg.msgId;
                
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error)
                {
                    [values addObject:obj];
                }
            }
            [dataDict setValue:values forKey:[self dpKeyWithMsgID:msgID]];
        }
        sBlock(dataDict);
    } failure:^(RobotDataRequestErrorType type) {
        fBlock(type);
    }];
}

- (void)packMutableDataPointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessArrBlock:(aSuccessArrBlock)sBlock FailBlock:(aFailBlock)fBlock
{
    if (cid == nil) {
        return;
    }
    [[JFGSDKDataPoint sharedClient] robotGetDataWithPeer:cid msgIds:msgIdArr asc:asc limit:limit success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList)
    {
        NSMutableArray *dataArr = [NSMutableArray array];
        
        for (NSArray * subArr in idDataList)
        {
            NSMutableArray *elementArr = [NSMutableArray array];

            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                
                if (!error)
                {
                    [elementDict setObject:@(seg.version) forKey:dpTimeKey];
                    [elementDict setValue:obj forKey:dpValueKey];
                    [elementDict setValue:@(seg.msgId) forKey:dpIdKey];
                    [elementArr addObject:elementDict]; // error 不为nil 添加数组
                }
                else
                {
                    NSLog(@"___error %@",error);
                }
            }
            [dataArr addObject:elementArr];
        }
        sBlock(dataArr);
    } failure:^(RobotDataRequestErrorType type) {
        fBlock(type);
    }];
}

// 组合查询
- (void)packMixDataPoint:(NSString *)cid version:(uint64_t)version dps:(NSArray<NSNumber *> *) dps asc:(BOOL)asc success:(aSuccessArrBlock)sBlock failed:(aFailBlock)fBlock
{
    if (cid == nil) {
        return;
    }
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:cid version:version dpids:dps asc:asc success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        NSMutableArray *dataArr = [NSMutableArray array];
        
        for (NSArray * subArr in idDataList)
        {
            NSMutableArray *elementArr = [NSMutableArray array];
            
            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error)
                {
                    [elementDict setObject:@(seg.version) forKey:dpTimeKey];
                    [elementDict setValue:obj forKey:dpValueKey];
                    [elementDict setValue:@(seg.msgId) forKey:dpIdKey];
                    [elementArr addObject:elementDict]; // error 不为nil 添加数组
                }
            }
            
            [dataArr addObject:elementArr];
        }
        
        sBlock(dataArr);
    } failure:^(RobotDataRequestErrorType type) {
        fBlock(type);
    }];
}

//获取多条dp cache
- (void)packMutableDataCachePointMsg:(NSArray <DataPointIDVerSeg *> *)msgIdArr withCid:(NSString *)cid isAsc:(BOOL)asc countLimit:(int)limit SuccessBlock:(aSuccessBlock)sBlock {
    
    if (cid == nil) {
        return;
    }
    [[JFGSDKDataPoint sharedClient]robotGetDataForCacheWithPeer:cid msgIds:msgIdArr asc:asc limit:limit success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
        
        for (NSArray * subArr in idDataList)
        {
            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error)
                {
                    [dataDict setValue:obj forKey:[self dpKeyWithMsgID:(NSInteger)seg.msgId]];
                }
            }
        }
        sBlock(dataDict);
    }];
}
// 设置dp 数据
- (void)setdpDataWithCid:(NSString *)cid dps:(NSArray <DataPointSeg *>*)dps success:(aSuccessBlock)success failed:(aFailBlock)failed
{
    if (cid == nil) {
        return;
    }
    for (DataPointSeg *seg in dps)
    {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"  setdp cid:%@ dpID[%llu] “%@”  dpValue[%@]",cid, seg.msgId, [self dpKeyWithMsgID:(NSInteger)seg.msgId], [MPMessagePackReader readData:seg.value error:nil]]];
    }
    
    
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:cid dps:dps success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
        for (DataPointIDVerRetSeg * seg in dataList)
        {
            if (seg.ret == 0)
            {
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"  setdp cid:%@ dpID[%llu] “%@” successful",cid, seg.msgId, [self dpKeyWithMsgID:(NSInteger)seg.msgId]]];
                success(nil);
            }
            else
            {
                failed(RobotDataRequestErrorTypeRequestFailed);
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"  setdp cid:%@ dpID[%llu] “%@” failed retType:[%d]",cid, seg.msgId, [self dpKeyWithMsgID:(NSInteger)seg.msgId], seg.ret]];
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        failed(type);
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"  setdp cid:%@  errorType:[%ld]",cid, (long)type]];
    }];
}

#pragma mark
#pragma mark == key ==
- (NSString *)dpKeyWithMsgID:(NSInteger)msgID
{
    
    if (msgID >= dpBaseBegin && msgID < dpVideoBegin)  // dp Base Key
    {
        return [self dpBaseKeyWithMsgID:msgID];
    }
    else if (msgID >= dpVideoBegin && msgID < dpBellBegin) // dp video key
    {
        return [self dpVideoKeyWithMsgID:msgID];
    }
    else if (msgID >= dpBellBegin && msgID < dpCameraBegin) //dp bell key
    {
        return [self dpBellKeyWithMsgID:msgID];
    }
    else if (msgID >= dpCameraBegin && msgID < dpAccountBegin)  // dp camera key
    {
        return [self dpCameraKeyWithMsgID:msgID];
    }
    else // dp account key
    {
        return [self dpAccountKeyWithMsgID:msgID];
    }
    
    return @"";
}

// 返回 DataPoint 基础功能 Key
- (NSString *)dpBaseKeyWithMsgID:(NSInteger)msgID
{
    NSArray *baseKeys = [NSArray arrayWithObjects:
                         msgBaseBeginKey,
                         msgBaseNetKey,
                         msgBaseMacKey,
                         msgBaseSDCardFormat,
                         msgBaseSDStatusKey,
                         msgBasePowerKey,
                         msgBaseBatteryKey,
                         msgBaseVersionKey,
                         msgBaseSysVersionKey,
                         msgBaseLEDKey,
                         msgBaseUptimeKey,
                         msgBaseClinetLogKey,
                         msgBaseCidLogKey,
                         msgBaseP2PVersionKey,
                         msgBaseTimeZoneKey,
                         msgBasePushFlowKey,
                         msgBaseNTSCKey,
                         msgBaseMobileKey,
                         msgBaseFormatSDKey,
                         msgBaseBindKey,
                         msgBaseSdkVersionKey,
                         msgBaseCtrlLogKey,
                         msgBaseSDCardListKey,
                         msgBaseSIMInfoKey,
                         msgBaseCtrlLogUploadKey,
                         msgBaseWiredNetAvailableKey,
                         msgBaseUsingWiredNetKey,
                         msgBaseIpAdressKey,
                         msgBaseUpgradeStatusKey,
                         nil];
    
    return [baseKeys objectAtIndex:msgID - dpBaseBegin];
}

// 返回 DataPoint 视频功能  key
- (NSString *)dpVideoKeyWithMsgID:(NSInteger)msgID
{
    NSArray *videoKeys = [NSArray arrayWithObjects:
                          dpMsgVideoBeginKey,
                          dpMsgVideoMicKey,
                          dpMsgVideoSpeakerKey,
                          dpMsgVideoAutoRecordKey,
                          dpMsgVideoDiretionKey,
                          dpMsgVideoRecordWhenWatchingKey,
                          nil];
    return [videoKeys objectAtIndex:msgID - dpVideoBegin];
}

// 返回 DataPoint 门铃功能  key
- (NSString *)dpBellKeyWithMsgID:(NSInteger)msgID
{
    NSArray *videoKeys = [NSArray arrayWithObjects:
                          dpMsgBellBeginKey,
                          dpMsgBellCallMsgKey,
                          dpMsgBellLeaveMsgKey,
                          nil];
    return [videoKeys objectAtIndex:msgID - dpBellBegin];
}

// 返回 DataPoint 摄像头功能 key
- (NSString *)dpCameraKeyWithMsgID:(NSInteger)msgID
{
    NSArray *cameraKeys = [NSArray arrayWithObjects:
                           dpMsgCameraBeginKey,
                           dpMsgCameraWarnEnableKey,
                           dpMsgCameraWarnTimeKey,
                           dpMsgCameraWarnSenKey,
                           dpMsgCameraWarnSoundKey,
                           dpMsgCameraWarnMsgKey,
                           dpMsgCameraTimeLapseKey,
                           dpMsgCameraWonderKey,
                           dpMsgCameraisLiveKey,
                           dpMsgCameraAngleKey,
                           dpMsgCameraCameraCoord,
                           dpMsgCameraWarnAndWonder,
                           dpMsgCameraWarnMSGV3,
                           dpMsgCameraBitRateKey,
                           dpMsgCameraWarnDurKey,
                           dpMsgCameraAIRecgnitionKey,
                           nil];
    
    return [cameraKeys objectAtIndex:msgID - dpCameraBegin];
}

// 返回 DataPoint 账号功能 key
- (NSString *)dpAccountKeyWithMsgID:(NSInteger)msgID
{
    NSArray *cameraKeys = [NSArray arrayWithObjects:
                           dpMsgAccountBeginKey,
                           dpMsgAccountBindKey,
                           dpMsgAccountWonderKey,
                           nil];
    
    return [cameraKeys objectAtIndex:msgID - dpAccountBegin];
}

@end
