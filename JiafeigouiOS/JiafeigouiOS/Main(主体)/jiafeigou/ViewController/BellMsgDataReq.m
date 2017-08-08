//
//  BellMsgDataReq.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BellMsgDataReq.h"
#import <JFGSDK/JFGSDKDataPoint.h>


@implementation BellMsgDataReq

-(void)getDataForCid:(NSString *)cid timestamp:(uint64_t)timestamp isRefresh:(BOOL)isRefresh
{
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:cid version:(timestamp<1000000000000)?timestamp*1000:timestamp dpids:@[@401,@403,@222] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        NSMutableArray *dataList = [NSMutableArray new];
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                [dataList addObject:seg];
            }
        }
        [weakSelf dealDataList:dataList cid:cid isRefresh:isRefresh];
        
    } failure:^(RobotDataRequestErrorType type) {
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestBellFailedForCid:refresh:)]) {
            [weakSelf.delegate requestBellFailedForCid:cid refresh:isRefresh];
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
            
            if (seg.msgId == 401 || seg.msgId == 403) {
                messageModel.msgID = 401;
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
            }else if (seg.msgId == 222){
                
                id obj =  [MPMessagePackReader readData:seg.value error:nil];
                messageModel.msgID = 204;//便于消息页面按消息号统一处理
                messageModel.cid = cid;
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
            [dealDatArr addObject:messageModel];
            
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestBellSuccess:forCid:refresh:)]) {
            [self.delegate requestBellSuccess:dealDatArr forCid:cid refresh:isRefresh];
        }
        
    } @catch (NSException *exception) {
        
        //数据解析失败
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestBellFailedForCid:refresh:)]) {
            [self.delegate requestBellFailedForCid:cid refresh:isRefresh];
        }
        
    } @finally {
        
        
        
    }
}

@end
