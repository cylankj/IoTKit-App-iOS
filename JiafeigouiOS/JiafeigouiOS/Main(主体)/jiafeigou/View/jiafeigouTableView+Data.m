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
@implementation jiafeigouTableView (Data)

-(void)addDataDelegate
{
    [JFGSDK appendStringToLogFile:@"addDataDelegate"];
    [JFGSDK addDelegate:self];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceList) name:BoundDevicesRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUnreadCount:) name:@"JFGClearUnReadCount" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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



-(void)jfgDeviceShareList:(NSDictionary<NSString *,NSArray<JFGSDKFriendRequestInfo *> *> *)friendList
{
    for (NSString *key in friendList.allKeys) {
        
        JiafeigouDevStatuModel *model = [self.dataDict objectForKey:key];
        if (model) {
            NSArray *arr = friendList[key];
            if (arr && arr.count>0) {
                
                if (model.shareState != DevShareStatuOther) {
                    model.shareState = DevShareStatuAlready;
                }
            }
        }
        
    }
    [self reloadData];
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    JiafeigouDevStatuModel *model = [self.dataDict objectForKey:peer];
    for (DataPointSeg *seg in msgList) {
        
        if (seg.msgId == 201) {
            [self deviceNetworkState:seg devModel:[self.dataDict objectForKey:peer]];
        }else if (seg.msgId == 505){
            
            //被分享设备不处理报警消息
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:peer];
            if (mode.shareState == DevShareStatuOther) {
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
            
            [[JFGSDKDataPoint sharedClient] robotCountDataWithPeer:peer dpIDs:@[[NSNumber numberWithInt:505]] success:^(NSString *identity, NSArray<DataPointCountSeg *> *dataList) {
                
                JiafeigouDevStatuModel *model = [self.dataDict objectForKey:identity];
                if (dataList.count>0) {
                    
                    DataPointCountSeg *seg = dataList[0];
                    model.unReadMsgCount = seg.count;
                    
                }
                
                
                [self reloadData];
                
                
            } failure:^(RobotDataRequestErrorType type) {
                
               
                
            }];
        }else if(seg.msgId == dpMsgBase_Battery){
            if (model.deviceType == JFGDeviceTypeDoorBell) {
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if ([obj isKindOfClass:[NSNumber class]]) {
                    model.Battery = [obj intValue];
                }
            }else{
                model.Battery = 200;
            }
            [self reloadData];
        }else if (seg.msgId == 401 || seg.msgId == 403){
            
            //门铃未读消息
            JiafeigouDevStatuModel *mode = [self.dataDict objectForKey:peer];
            if (mode.shareState == DevShareStatuOther) {
                return;
            }
            [[JFGSDKDataPoint sharedClient] robotCountDataWithPeer:peer dpIDs:@[[NSNumber numberWithInt:401],[NSNumber numberWithInt:403]] success:^(NSString *identity, NSArray<DataPointCountSeg *> *dataList) {
                
                JiafeigouDevStatuModel *model = [self.dataDict objectForKey:identity];
                if (dataList.count == 1) {
                    DataPointCountSeg *seg = dataList[0];
                    model.unReadMsgCount = seg.count;
                    
                    
                    
                }else if(dataList.count == 2){
                    
                    DataPointCountSeg *seg = dataList[0];
                    DataPointCountSeg *seg1 = dataList[1];
                    if (seg.count > seg1.count) {
                        model.unReadMsgCount = seg.count;
                    }else{
                        model.unReadMsgCount = seg1.count;
                    }
                }
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
        }
        
    }
    
    [self reloadData];
}


-(void)jfgRobotPushMsgForPeer:(NSString *)peer msgList:(NSArray<NSArray<DataPointSeg *> *> *)msgList
{
    NSLog(@"主动推送消息%@",peer);
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
                    default:
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

//-(void)jfgMessageList:(NSArray<JFGSDKMessageDevice *> *)list
//{
//    for (JiafeigouDevStatuModel *model in self.dataArray) {
//
//        for (JFGSDKMessageDevice *msg in list) {
//
//            if ([msg.cid isEqualToString:model.cid]) {
//                NSString *lastMsg;
//                switch (msg.type) {
//                    case 0:
//                        lastMsg = @"未知消息";
//                        break;
//                    case 1:
//                        lastMsg = @"版本更新";
//                        break;
//                    case 2:
//                        lastMsg = @"开启警报";
//                        break;
//                    case 3:
//                        lastMsg = @"触发警报";
//                        break;
//                    case 4:
//                        lastMsg = @"关闭警报";
//                        break;
//                    case 5:
//                        lastMsg = @"低电量";
//                        model.lowBattery = YES;
//                        break;
//                    case 6:
//                        lastMsg = @"SD卡弹出";
//                        break;
//                        
//                    case 7:
//                        lastMsg = @"SD卡接入";
//                        break;
//                    case 8:
//                        lastMsg = @"移除绑定";
//                        break;
//                        
//                    case 9:
//                        lastMsg = @"绑定成功";
//                        break;
//                        
//                    case 10:
//                        lastMsg = @"重复绑定";
//                        break;
//                        
//                    case 11:
//                        lastMsg = @"分享成功";
//                        break;
//                        
//                    case 12:
//                        lastMsg = @"取消分享";
//                        break;
//                        
//                    case 13:
//                        lastMsg = @"门磁打开";
//                        model.doorcOpen = YES;
//                        break;
//                        
//                    case 14:
//                        lastMsg = @"门磁关闭";
//                        model.doorcOpen = NO;
//                        break;
//                        
//                    default:
//                        break;
//                }
//                model.lastMsg = lastMsg;
//                model.lastMsgTime = [self lastTimeFromTimestamp:(long)msg.time];
//                model.unReadMsgCount = msg.unReadCount;
//                
//                break;
//            }
//            
//        }
//        
//    }
//    [self reloadData];
//}


-(void)clearUnreadCount:(NSNotification *)notification
{
    if (notification) {
        
        NSString *cid = notification.object;
        [[JFGSDKDataPoint sharedClient] robotCountDataClear:cid dpIDs:@[@505,@222,@512] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
  
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
        
        JiafeigouDevStatuModel *model = [self.dataDict objectForKey:cid];
        model.unReadMsgCount = 0;
        [self reloadData];
    
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
