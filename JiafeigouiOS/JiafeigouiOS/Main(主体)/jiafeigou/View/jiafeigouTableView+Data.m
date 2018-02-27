//
//  jiafeigouTableView+Data.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "jiafeigouTableView+Data.h"
#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgMsgDefine.h"
#import "LoginManager.h"
#import "NetworkMonitor.h"
#import "JfgLanguage.h"
#import "jfgConfigManager.h"


@implementation jiafeigouTableView (Data)

-(void)addDataDelegate
{
    [JFGSDK appendStringToLogFile:@"addDataDelegate"];
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUnreadCount:) name:@"JFGClearUnReadCount" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoRecordFor720:) name:@"DevFor720VideoStatues" object:nil];
}

-(void)becomeActive
{
    [JFGSDK refreshDeviceList];
}

-(void)upDataDevList
{
    [JFGSDK appendStringToLogFile:@"upDataDevList"];
//    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
//        [self deviceList];
//    }
}

-(void)videoRecordFor720:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    NSNumber *num = dict[@"videoType"];
    NSString *uuid = dict[@"uuid"];
    int videoType = [num intValue];
    JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:uuid];
    if (videoType == -1) {
        //无录像
        mode.delayCamera = NO;
    }else if(videoType == 1){
        //短视频
        mode.delayCamera = YES;
    }else if (videoType == 2){
        //长视频
        mode.delayCamera = YES;
    }
    [self reloadData];
}


-(void)jfgSetDeviceAliasResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        [JFGSDK refreshDeviceList];
    }
}


-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    JiafeigouDevStatuModel *model = [self.dataDict objectForKey:peer];
    for (DataPointSeg *seg in msgList) {
        
        if (seg.msgId == 201) {
            [self deviceNetworkState:seg devModel:[self.dataDict objectForKey:peer]];
        }else if (seg.msgId == 505 || seg.msgId == 512 || seg.msgId == 222 || seg.msgId == 526){
            
            //被分享设备不处理报警消息
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:peer];
            BOOL isDoorBell = [jfgConfigManager devIsDoorBellForPid:mode.pid];
            if (mode.shareState == DevShareStatuOther && !isDoorBell) {
                return;
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:seg.version/1000];
            NSTimeInterval time= fabs([[NSDate date] timeIntervalSinceDate:confromTimesp]);
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
            NSDateComponents *components2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:confromTimesp];
            
            if (components.day != components2.day) {
                
                [formatter setDateFormat:@"YY/MM/dd"];
                NSString *t = [formatter stringFromDate:confromTimesp];
                model.lastMsgTime = t;
                
            }else{
                
                if (time<=60*5) {
                    model.lastMsgTime = [JfgLanguage getLanTextStrByKey:@"JUST_NOW"];
                }else if (time <= 60*60*24){
                    [formatter setDateFormat:@"HH:mm"];
                    NSString *t = [formatter stringFromDate:confromTimesp];
                    model.lastMsgTime = t;
                }else{
                    [formatter setDateFormat:@"YY/MM/dd"];
                    NSString *t = [formatter stringFromDate:confromTimesp];
                    model.lastMsgTime = t;
                }
                
            }
            
            [[JFGSDKDataPoint sharedClient] robotCountDataWithPeer:peer dpIDs:@[@222,@505,@512,@526] success:^(NSString *identity, NSArray<DataPointCountSeg *> *dataList) {
                
                NSInteger allCount = 0;
                for (DataPointCountSeg *seg in dataList) {
                    if (seg.count>0) {
                        allCount = allCount+seg.count;
                    }
                }
                JiafeigouDevStatuModel *model = [self.dataDict objectForKey:identity];
                model.unReadMsgCount = allCount;
                [self reloadData];
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
            
            
        }else if(seg.msgId == dpMsgBase_Battery){
            
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            if ([obj isKindOfClass:[NSNumber class]]) {
                model.Battery = [obj intValue];
            }
//            if (model.deviceType == JFGDeviceTypeDoorBell || model.deviceType == JFGDeviceTypeCamera3G || [model.pid isEqualToString:@"17"] ) {
//                
//            }else{
//                model.Battery = 100;
//                model.isPower = YES;
//            }
            [self reloadData];
            
            
        }else if (seg.msgId == 401 || seg.msgId == 403){
            
            //门铃未读消息
            
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:peer];
            BOOL isDoorBell = [jfgConfigManager devIsDoorBellForPid:mode.pid];
            if (mode.shareState == DevShareStatuOther && !isDoorBell) {
                return;
            }
            [[JFGSDKDataPoint sharedClient] robotCountDataWithPeer:peer dpIDs:@[@401,@403,@222] success:^(NSString *identity, NSArray<DataPointCountSeg *> *dataList) {
                
                JiafeigouDevStatuModel *model = [self.dataDict objectForKey:identity];
                NSInteger allCount = 0;
                
                for (DataPointCountSeg *seg in dataList) {
                    
                    if (seg.count>0) {
                        allCount = allCount+seg.count;
                    }
                    
                }
                model.unReadMsgCount = allCount;
                if (model.unReadMsgCount < 0) {
                    model.unReadMsgCount  = 0;
                }
                
                [self reloadData];
                
                
            } failure:^(RobotDataRequestErrorType type) {
                
                
                
            }];
        }else if(seg.msgId == dpMsgCamera_isLive){
            
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            if (obj == nil) {
                model.safeIdle = NO;
                return ;
            }
            
            if ([obj isKindOfClass:[NSNumber class]] && [obj boolValue]) {
                model.safeIdle = YES;
            }else if([obj isKindOfClass:[NSArray class]]){
                NSArray *arr = obj;
                if (arr.count>0) {
                    
                    if ([arr[0] isKindOfClass:[NSNumber class]]) {
                        model.safeIdle = [arr[0] boolValue];
                    }
                }
            }else{
                model.safeIdle = NO;
            }
            
            [self reloadData];
        }else if (seg.msgId == 404){
            
        
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            if ([obj isKindOfClass:[NSArray class]]) {
                
                NSArray *sourceArr = obj;
                if (sourceArr.count) {
                    model.deepSleep = [[sourceArr objectAtIndex:0] boolValue];
                }
                
            }
        
           
            
        }
        
    }
    
    [self reloadData];
}


-(void)jfgRobotPushMsgForPeer:(NSString *)peer msgList:(NSArray<NSArray<DataPointSeg *> *> *)msgList
{
    NSLog(@"主动推送消息%@",peer);
}

-(void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                             mSeq:(uint64_t)mSeq
                                              cid:(NSString *)cid
                                             type:(int)type
                                     isInitiative:(BOOL)initiative
                                          msgData:(NSData *)msgData
{
    if (type == 14){
        //视频录制情况
        [self videoRecordDeal:msgData forCid:cid];
    }else if (type == 10){
        //录制视频请求回调
        [self videoDataDeal:msgData forCid:cid];
    }
}


-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    for (DataPointSeg *seg in dpMsgArr) {
        
        NSLog(@"%@",seg.value);
        if (seg.msgId == 204) {
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            if (obj) {
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",obj]];
            }
            NSLog(@"%@",obj);
        }else if (seg.msgId == 206 || seg.msgId == dpMsgBase_Power){
            [self baratyDeal:seg forCid:cid];
        }
    }
}

-(void)baratyDeal:(DataPointSeg *)seg forCid:(NSString *)cid
{
    
    if (seg.msgId == 206){
        
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if (obj) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",obj]];
        }
        if ([obj isKindOfClass:[NSNumber class]]) {
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:cid];
            mode.Battery = [obj intValue];
            NSLog(@"barrty:%d",[obj intValue]);
        }
    
    }else if (seg.msgId == dpMsgBase_Power){
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if (obj) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",obj]];
        }
        if ([obj isKindOfClass:[NSNumber class]]) {
            int power  = [obj intValue];
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:cid];
            if (power == 1) {
               mode.isPower = YES;
            }else{
               mode.isPower = NO;
            }
        }
    }
    [self reloadData];
}

-(void)videoRecordDeal:(NSData *)msgData forCid:(NSString *)cid
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"videoRecordDeal:%@",obj]];
    if (obj) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",obj]];
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count >= 3) {
            
            @try {
                /*
                 int，     ret       错误码
                 int，     secends   视频录制的时长,单位秒
                 int,      videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频；
                 */
                 JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:cid];
                
//                int ret = [sourceArr[0] intValue];
//                int secouds = [sourceArr[1] intValue];
                int videoType = [sourceArr[2] intValue];
                if (videoType == 2 ) {
                    //长视频
                    mode.delayCamera = YES;
                }else{
                    //没有录像
                    mode.delayCamera = NO;
                }
                [self reloadData];
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            
            
        }
        
    }
}

-(void)videoDataDeal:(NSData *)msgData forCid:(NSString *)cid
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if (obj) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",obj]];
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        int ret = [obj intValue];
        if (ret == 0) {
            NSLog(@"录像成功");
            //[ProgressHUD showText:@"录像成功"];
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:cid];
            mode.delayCamera = YES;
            [self reloadData];
        }else{
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:cid];
            mode.delayCamera = NO;
            [self reloadData];
        }
    }
}



//根据数据修改设备网络状况
-(void)deviceNetworkState:(DataPointSeg *)seg devModel:(JiafeigouDevStatuModel *)model
{
    NSError *error = nil;
    id obj = [MPMessagePackReader readData:seg.value error:&error];
    if (error == nil) {
        
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *objArr = obj;
            
            if (objArr.count>0) {
                
                int netType = [[objArr objectAtIndex:0] intValue];
                //NSLog(@"dp:uuid:%@ netType:%d",model.uuid,netType);
                
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"dp:uuid:%@ netType:%d",model.uuid,netType]];
                
                switch (netType) {
                    case -1:
                        model.netType = JFGNetTypeConnect;
                        break;
                    case 0:
                        model.netType = JFGNetTypeOffline;
                        break;
                    case 1:
                        model.netType = JFGNetTypeWifi;
                        break;
                    case 2:
                        model.netType = JFGNetType2G;
                        break;
                    case 3:
                        model.netType = JFGNetType3G;
                        break;
                    case 4:
                        model.netType = JFGNetType4G;
                        break;
                    case 5:
                        model.netType = JFGNetType5G;
                        break;
                    case 10:
                        model.netType = JFGNetTypeWired; // 10 是有线网络
                        break;
                    default:
                        model.netType = JFGNetTypeWifi;
                        break;
                }
            }
        }else{
            model.netType = JFGNetTypeOffline;
        }
        
    }else{
        model.netType = JFGNetTypeOffline;
    }
    
        
    
}


-(void)clearUnreadCount:(NSNotification *)notification
{
    if (notification) {
        
        NSString *cid = notification.object;
        if (cid) {
            JiafeigouDevStatuModel *model = [self.dataDict objectForKey:cid];
            [[JFGSDKDataPoint sharedClient] robotCountDataClear:cid dpIDs:@[@401,@222,@403,@505,@512,@526] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
            
            model.unReadMsgCount = 0;
            [self reloadData];
        }
        
    }
}


-(NSString *)lastTimeFromTimestamp:(long)stamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:stamp];
    NSTimeInterval tim = [[NSDate date] timeIntervalSinceDate:date];
    if (tim<=60*5) {
        return [JfgLanguage getLanTextStrByKey:@"JUST_NOW"];;
    }else if(tim<=60*60*24){
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc]init];
        dataFormatter.dateFormat = @"HH:mm";
        return [dataFormatter stringFromDate:date];
    }
    
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc]init];
    dataFormatter.dateFormat = @"yy/MM/dd";
    return [dataFormatter stringFromDate:date];

}

@end
