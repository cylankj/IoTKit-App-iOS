//
//  Pano720Socket.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720Socket.h"
#import <JFGSDK/JFGSDK.h>
#import "dataPointMsg.h"
#import <JFGSDK/MPMessagePackWriter.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "NetworkMonitor.h"

typedef NS_ENUM(NSInteger, socketConnectType){
    socketConnectType_None, // none connect. reconnect or disconnect
    socketConnectType_UDP, // udp network
    socketConnectType_TCP, // public network
};

@interface Pano720Socket()<JFGSDKCallbackDelegate>

@property (nonatomic, strong) NSHashTable *delegates;

@property (nonatomic, assign) socketConnectType socketType;
@property (nonatomic, copy) NSString *cid;

@end

@implementation Pano720Socket

+ (instancetype)sharedSocket
{
    static dispatch_once_t once = 0;
    static Pano720Socket *panoSocket;
    dispatch_once(&once, ^{
        panoSocket = [[Pano720Socket alloc] init];
    });
    
    return panoSocket;
}

- (void)setSocketType:(socketConnectType)socketType
{
    _socketType = socketType;
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"set socketType[%ld]",socketType]];
}

- (void)setSocketType_as_TcpType
{
    [JFGSDK appendStringToLogFile:@"udp timeout set socket as tcp "];
    [self setSocketType:socketConnectType_TCP];
    [self jfgSockConnect];
}

- (void)cancelSetSocketType_as_TcpType
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setSocketType_as_TcpType) object:nil];
}

#pragma mark
#pragma mark  代理 移除，添加
-(void)addDelegate:(id<Pano720SocketDelegate>)delegate
{
    if (!delegate)
    {
        return;
    }
    if (![self.delegates containsObject:delegate])
    {
        [self.delegates addObject:delegate];
    }
    [JFGSDK addDelegate:self];
    
}
-(void)removeDelegate:(id<Pano720SocketDelegate>)delegate
{
    [self.delegates removeObject:delegate];
    [JFGSDK removeDelegate:self];
}


#pragma mark
#pragma mark tcp 断开，连接
- (void)panoConnect:(NSString *)cid
{
    self.cid = cid;
    if ([[NetworkMonitor sharedManager] currentNetworkStatu] == ReachableViaWWAN)
    {
        [self setSocketType:socketConnectType_TCP];
        [self jfgSockConnect];
        return;
    }
    
    [self setSocketType:socketConnectType_None];
    [JFGSDK fping:@"255.255.255.255"];
    [self performSelector:@selector(setSocketType_as_TcpType) withObject:nil afterDelay:5.0f]; // timeout duration 5 second
}

//局域网 udp socket 连接
-(void)panoConnectIp:(NSString *)ip port:(short)port autoConnect:(BOOL)isAuto
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"udp connect ip[%@] port[%d] isAuto[%d]",ip, port, isAuto]];
}

//局域网 断开tcp连接
- (void)panoDisconnect
{
    [self setSocketType:socketConnectType_None];
    [JFGSDK appendStringToLogFile:@" disconnect"];
}

- (void)jfgNetworkChanged:(JFGNetType)netType
{
    switch (netType)
    {
        case JFGNetTypeWifi:
        {
            [self panoConnect:self.cid]; // reconnect jduge network is in udp or tcp
        }
            break;
        case JFGNetType2G:
        case JFGNetType3G:
        case JFGNetType4G:
        case JFGNetType5G:
        {
            [self setSocketType:socketConnectType_TCP];
        }
            break;
        case JFGNetTypeConnect:
        case JFGNetTypeOffline:
        {
            [self setSocketType:socketConnectType_None];
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark delegate callback
- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if (self.socketType == socketConnectType_TCP)
    {
        return;
    }
    
    if ([self.cid isEqualToString:ask.cid])
    {
        [self setSocketType:socketConnectType_UDP];
        [self panoConnectIp:ask.address port:ask.port autoConnect:YES];
    }
}

-(void)jfgSockConnect
{
    [self cancelSetSocketType_as_TcpType];
    [JFGSDK appendStringToLogFile:@"socket connectted"];

    for (id<Pano720SocketDelegate> delegate in [self.delegates copy])
    {
        if ([delegate respondsToSelector:@selector(panoConnectted)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate panoConnectted];
            });
        }
    }
}

-(void)jfgSockDisconnect
{
    [JFGSDK appendStringToLogFile:@"socket disConnectted"];
    for (id<Pano720SocketDelegate> delegate in [self.delegates copy])
    {
        if ([delegate respondsToSelector:@selector(panoDisconnectted)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate panoDisconnectted];
            });
        }
    }
}

#pragma mark
#pragma mark 发送 消息
//send msg named 20006 in udp&tcp
-(uint64_t)sendMsgWithCids:(NSArray <NSString *>*)cids isCallBack:(BOOL)isCallBack requestType:(int)requestType requestData:(NSArray *)requestArr
{
    uint64_t result = -1;
    NSMutableData *requestData = [MPMessagePackWriter writeObject:requestArr error:nil];
    NSString *socketTypeStr = @"";
    
    switch (self.socketType)
    {
        case socketConnectType_UDP:
        {
            socketTypeStr = @"udp";
        }
            break;
        case socketConnectType_TCP:
        {
            socketTypeStr = @"tcp";
            result = [JFGSDK sendMsgForTcpWithDst:cids isAck:YES fileType:isCallBack msg:requestData];
        }
            break;
        default:
            break;
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@ send 20006 requestType[%d] content[%@]",socketTypeStr, requestType,requestArr]];
    
    return result;
}

// send dp msg
- (uint64_t)sendDataPointMsg:(NSString *)cid dpMsgSegs:(NSArray <DataPointSeg *> *)segs
{
    uint64_t result = -1;
    
    switch (self.socketType)
    {
        case socketConnectType_TCP:
        {
            result = [JFGSDK sendDPDataMsgForSockWithPeer:cid dpMsgIDs:segs];
        }
            break;
        case socketConnectType_UDP:
        {
            //result = [[JFGSDKSock sharedClient] sendDPDataMsgForSockWithPeer:cid dpMsgIDs:segs];
        }
            break;
        default:
            break;
    }
    
    return result;
}

// only for download use
- (uint64_t)sendDownloadMsgWithCids:(NSArray <NSString *>*)cids fileName:(NSString *)fileName md5:(NSString *)md5 begin:(int)begin offset:(int)offset
{
    uint64_t result = -1;
    
    switch (self.socketType)
    {
        case socketConnectType_TCP:
        {
            result = [JFGSDK sendMsgForTcpDownloadWithDst:cids fileName:fileName md5:md5 begin:begin offset:offset];
        }
            break;
        case socketConnectType_UDP:
        {
            //result = [[JFGSDKSock sharedClient] sendMsgForSockDownloadWithDst:cids fileName:fileName md5:md5 begin:begin offset:offset];
        }
            break;
        default:
            break;
    }
    return result;
}

#pragma mark udp callback
// socket udp callback
-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID
                                              mSeq:(uint64_t)mSeq
                                               cid:(NSString *)cid
                                              type:(int)type
                                           msgData:(NSData *)msgData
{
    [self receivePanoDataMsg:msgID sequence:mSeq cid:cid responseType:type msgData:msgData];
}

// udp dp callback used in push and response
- (void)jfgDPMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type dpMsgArr:(NSArray *)dpMsgArr
{
    [self receivePanoDataPointDpID:msgID sequence:mSeq cid:cid type:type dpMsgArr:dpMsgArr];
}
#pragma mark tcp callback
// socket tcp callback
- (void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type msgData:(NSData *)msgData
{
    [self receivePanoDataMsg:msgID sequence:mSeq cid:cid responseType:type msgData:msgData];
}
//tcp dp callback used in push and response
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    [self receivePanoDataPointDpID:msgID sequence:mSeq cid:cid type:type dpMsgArr:dpMsgArr];
}

#pragma mark
#pragma mark  callback selector
// receive udp socket msg callback
- (void)receivePanoDataMsg:(NSString *)msgID sequence:(uint64_t)mSeq cid:(NSString *)cid responseType:(int)type msgData:(NSData *)msgData
{
    for (id<Pano720SocketDelegate> delegate in [self.delegates copy])
    {
        if ([delegate respondsToSelector:@selector(receivePanoDataMsgID:sequence:cid:reponseType:msgContent:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                id content = [MPMessagePackReader readData:msgData error:nil];
                [delegate receivePanoDataMsgID:msgID sequence:mSeq cid:cid reponseType:type msgContent:content];
                
            });
        }
    }
}

// receive datapoint msg callback eg:msgid 204 205 206
- (void)receivePanoDataPointDpID:(NSString *)dpID sequence:(uint64_t)mSeq cid:(NSString *)cid type:(int)type dpMsgArr:(NSArray *)dpMsgArr
{
    for (id<Pano720SocketDelegate> delegate in [self.delegates copy])
    {
        if ([delegate respondsToSelector:@selector(receivepanoDataPointmsgID:sequence:cid:reponseType:dpMsgDict:)])
        {
            NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
            
            for (DataPointSeg *seg in dpMsgArr)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error && obj)
                {
                    [dataDict setValue:obj forKey:[[dataPointMsg shared] dpKeyWithMsgID:(NSInteger)seg.msgId]];
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"pano720  getdp cid:%@ dpID[%llu] “%@”   dpValue[%@]",cid,seg.msgId, [[dataPointMsg shared] dpKeyWithMsgID:seg.msgId], obj]];
                }
            }
            
            [delegate receivepanoDataPointmsgID:dpID sequence:mSeq cid:cid reponseType:type dpMsgDict:dataDict];
        }
    }
}

#pragma mark getter

- (NSHashTable *)delegates
{
    if (_delegates == nil)
    {
        _delegates = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return _delegates;
}

@end
