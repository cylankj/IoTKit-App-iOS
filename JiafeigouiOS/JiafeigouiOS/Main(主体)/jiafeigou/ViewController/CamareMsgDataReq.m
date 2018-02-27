//
//  CamareMsgDataReq.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CamareMsgDataReq.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>


@implementation CamareMsgDataReq

-(void)getDataForCid:(NSString *)cid timestamp:(uint64_t)timestamp isRefresh:(BOOL)isRefresh
{
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:cid version:(timestamp<1000000000000)?timestamp*1000:timestamp dpids:@[@505,@222,@512,@401,@403] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        NSMutableArray *dataList = [NSMutableArray new];
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                [dataList addObject:seg];
            }
        }
        [weakSelf dealDataList:dataList cid:cid isRefresh:isRefresh];
        
    } failure:^(RobotDataRequestErrorType type) {
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestCamareFailedForCid:refresh:)]) {
            [weakSelf.delegate requestCamareFailedForCid:cid refresh:isRefresh];
        }
        
    }];
}


-(void)dealDataList:(NSArray *)dataList cid:(NSString *)cid isRefresh:(BOOL)isRefresh
{
    @try {
        
        NSMutableArray *dealDatArr = [NSMutableArray new];
        for (DataPointSeg *seg in dataList)
        {
            MessageModel *messageModel = [[MessageModel alloc] init];
            id obj =  [MPMessagePackReader readData:seg.value error:nil];
            
            switch (seg.msgId)
            {
                case 512:
                case 505:
                {
                    messageModel.msgID = 505;
                    messageModel.realyMsgID = seg.msgId;
                    messageModel.cid =cid;
                    messageModel._version = seg.version;
                    NSArray *values = [MPMessagePackReader readData:seg.value error:nil];
                    messageModel.timestamp = [[values objectAtIndex:0] doubleValue];
                    messageModel.is_record = [[values objectAtIndex:1] boolValue];
                    messageModel.flag = [[values objectAtIndex:3] intValue];
                    messageModel.imageNum = [[values objectAtIndex:2] intValue];
                    if (values.count>4) {
                        messageModel.tly = [values objectAtIndex:4];
                    }else{
                        messageModel.tly = @"1";
                    }
                    
                    if (values.count > 5) {
                        messageModel.objects = [values objectAtIndex:5];
                        //NSLog(@"renxingjiance:%@",messageModel.objects);
                    }else{
                        messageModel.objects = nil;
                    }
                    
                    if (values.count > 6) {
                        messageModel.manNum = [values[6] intValue];
                    }else{
                        messageModel.manNum = 0;
                    }
                    if (values.count>7) {
                        messageModel.face_idList = values[7];
                    }
                    if (seg.msgId == 512) {
                        messageModel.deviceVersion = 3;
                    }else{
                        messageModel.deviceVersion = 2;
                    }
                    
                }
                    break;
                    
                case 401:
                case 403:{
                    messageModel.msgID = 401;
                    messageModel.realyMsgID = seg.msgId;
                    messageModel.cid = cid;
                    messageModel._version = seg.version;
                    NSArray *values = [MPMessagePackReader readData:seg.value error:nil];
                    messageModel.isAnswer = [[values objectAtIndex:0] intValue];
                    messageModel.timestamp = [[values objectAtIndex:1] doubleValue];
                    messageModel.timeDuration =  [[values objectAtIndex:2] intValue];
                    messageModel.flag = [[values objectAtIndex:3] intValue];
                    messageModel.tly = @"1";
                    messageModel.imageNum = 0;
                    if (seg.msgId == 401) {
                        messageModel.deviceVersion = 2;
                    }else{
                        messageModel.deviceVersion = 3;
                    }
                    if (values.count>4) {
                        messageModel.is_record = [[values objectAtIndex:4] intValue];
                        if (values.count>5) {
                            messageModel.imageNum = [[values objectAtIndex:5] intValue];
                        }
                    }
                    
                }
                    break;
                    
                case 222:
                {
                    messageModel.msgID = 204;
                    messageModel.cid = cid;
                    messageModel.realyMsgID = seg.msgId;
                    messageModel._version = seg.version;
                    messageModel.timestamp = seg.version/1000;
                    if (obj && [obj isKindOfClass:[NSArray class]]) {
                        
                        NSArray *objArr = obj;
                        if (objArr.count >= 2) {
                            id obj1 = [objArr objectAtIndex:0];
                            id obj2 = [objArr objectAtIndex:1];
                            if ([obj1 isKindOfClass:[NSNumber class]]) {
                                messageModel.isSDCardOn = [obj1 boolValue];
                            }
                            if ([obj2 isKindOfClass:[NSNumber class]]) {
                                messageModel.sdcardErrorCode = [obj2 intValue];
                                if (messageModel.sdcardErrorCode != 0) {
                                    messageModel.isShowVideoBtn = YES;
                                }else{
                                    messageModel.isShowVideoBtn = NO;
                                }
                            }
                        }
                    }
                    
                }
                    break;
            }
            [dealDatArr addObject:messageModel];
            
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestCamareSuccess:forCid:refresh:)]) {
            [self.delegate requestCamareSuccess:dealDatArr forCid:cid refresh:isRefresh];
        }
        
    } @catch (NSException *exception) {
        
        //数据解析失败
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestCamareFailedForCid:refresh:)]) {
            [self.delegate requestCamareFailedForCid:cid refresh:isRefresh];
        }
        
    } @finally {
        
        
        
    }
}

-(NSArray <MessageVCDateModel *> *)getDateModelsBefore15DayWithNow
{
    NSArray *timestamps = [MessageVCDateModel timestampsBefore15DayWithTimestamp:[[NSDate date] timeIntervalSince1970]];
    
    NSMutableArray *messageDataArray = [[NSMutableArray alloc]init];
    for (NSNumber *num in [[timestamps reverseObjectEnumerator] allObjects]) {
        
        int64_t timestamp = [num longLongValue];
        MessageVCDateModel *model = [[MessageVCDateModel alloc]init];
        model.isHasMessage = NO;
        model.startTimestamp = timestamp;
        model.lastestTimestamp = timestamp + 24*60*60;
        model.year = [MessageVCDateModel yearFromTimestamp:timestamp];
        model.mounth = [MessageVCDateModel monthFromTimestamp:timestamp];
        model.day = [MessageVCDateModel dayFromTimestamp:timestamp];
        [messageDataArray addObject:model];
        
    }
    return messageDataArray;
}

-(void)dateModelForCamareIsHasDataForDateModels:(NSArray <MessageVCDateModel *> *)dateModels cid:(NSString *)cid
{
    if (!cid) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableArray *segArr = [[NSMutableArray alloc]init];
    for (MessageVCDateModel *model in dateModels) {
        
        DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = 505;
        seg.version = model.startTimestamp * 1000;
        [segArr addObject:seg];
        
        DataPointIDVerSeg *seg2 = [[DataPointIDVerSeg alloc]init];
        seg2.msgId = 222;
        seg2.version = model.startTimestamp * 1000;
        [segArr addObject:seg2];
        
        DataPointIDVerSeg *seg3 = [[DataPointIDVerSeg alloc]init];
        seg3.msgId = 512;
        seg3.version = model.startTimestamp * 1000;
        [segArr addObject:seg3];
        
        DataPointIDVerSeg *seg4 = [[DataPointIDVerSeg alloc]init];
        seg4.msgId = 401;
        seg4.version = model.startTimestamp * 1000;
        [segArr addObject:seg4];
        
        DataPointIDVerSeg *seg5 = [[DataPointIDVerSeg alloc]init];
        seg5.msgId = 403;
        seg5.version = model.startTimestamp * 1000;
        [segArr addObject:seg5];
        
    }
    [[JFGSDKDataPoint sharedClient] robotGetDataWithPeer:cid msgIds:segArr asc:YES limit:1 success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                int64_t _version = seg.version/1000;
                
                for (MessageVCDateModel *model in dateModels) {
                    
                    int64_t startVersion = model.startTimestamp;
                    int64_t endVersion = startVersion + 24*60*60;
                    if (_version >= startVersion && _version < endVersion) {
                        model.isHasMessage = YES;
                        break;
                    }
                    
                }
            }
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(dateModelIsHasDataDealSuccess)]) {
            [weakSelf.delegate dateModelIsHasDataDealSuccess];
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(dateModelIsHasDataDealFailer)]) {
            [weakSelf.delegate dateModelIsHasDataDealFailer];
        }
    }];

}

-(void)dateModelForDoorBellIsHasDataForDateModels:(NSArray <MessageVCDateModel *> *)dateModels cid:(NSString *)cid
{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *segArr = [[NSMutableArray alloc]init];
    for (MessageVCDateModel *model in dateModels) {
        
        DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = 401;
        seg.version = model.startTimestamp * 1000;
        [segArr addObject:seg];
        
        DataPointIDVerSeg *seg2 = [[DataPointIDVerSeg alloc]init];
        seg2.msgId = 403;
        seg2.version = model.startTimestamp * 1000;
        [segArr addObject:seg2];
        
        DataPointIDVerSeg *seg3 = [[DataPointIDVerSeg alloc]init];
        seg3.msgId = 222;
        seg3.version = model.startTimestamp * 1000;
        [segArr addObject:seg3];
        
    }
    [[JFGSDKDataPoint sharedClient] robotGetDataWithPeer:cid msgIds:segArr asc:YES limit:1 success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                int64_t _version = seg.version/1000;
                
                for (MessageVCDateModel *model in dateModels) {
                    
                    int64_t startVersion = model.startTimestamp;
                    int64_t endVersion = startVersion + 24*60*60;
                    if (_version >= startVersion && _version < endVersion) {
                        model.isHasMessage = YES;
                        break;
                    }
                    
                }
            }
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(dateModelIsHasDataDealSuccess)]) {
            [weakSelf.delegate dateModelIsHasDataDealSuccess];
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(dateModelIsHasDataDealFailer)]) {
            [weakSelf.delegate dateModelIsHasDataDealFailer];
        }
    }];
    
}

@end
