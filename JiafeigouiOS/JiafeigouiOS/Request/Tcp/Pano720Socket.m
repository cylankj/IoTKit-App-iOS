//
//  Pano720Socket.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720Socket.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/MPMessagePackWriter.h>
#import <JFGSDK/MPMessagePackReader.h>

@interface Pano720Socket()

@property (nonatomic, strong) NSHashTable *delegates;

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
    
    [[JFGSDKSock sharedClient] addDelegate:self];
    
}
-(void)removeDelegate:(id<Pano720SocketDelegate>)delegate
{
    [self.delegates removeObject:delegate];
    [[JFGSDKSock sharedClient] removeDelegate:self];
}

#pragma mark
#pragma mark tcp 断开，连接
//局域网 tcp 连接
-(void)panoConnectIp:(NSString *)ip port:(short)port autoConnect:(BOOL)isAuto
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"connect ip[%@] port[%d] isAuto[%d]",ip, port, isAuto]];
    [[JFGSDKSock sharedClient] connectWithIp:ip port:port autoReconnect:isAuto];
}
//局域网 断开tcp连接
-(void)panoDisconnect
{
    [JFGSDK appendStringToLogFile:@" disconnect"];
    [[JFGSDKSock sharedClient] disconnect];
}

#pragma mark
#pragma mark 发送 消息
//发送 20006 消息
-(uint64_t)sendMsgWithCids:(NSArray <NSString *>*)cids isCallBack:(BOOL)isCallBack requestType:(int)requestType requestData:(NSArray *)requestArr
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"send 20006 requestType[%d] content[%@]",requestType,requestArr]];
    NSMutableData *requestData = [MPMessagePackWriter writeObject:requestArr error:nil];
    return [[JFGSDKSock sharedClient] sendMsgForSockWithDst:cids isAck:isCallBack fileType:requestType msg:requestData];
}

- (uint64_t)sendDownloadMsgWithCids:(NSArray <NSString *>*)cids fileName:(NSString *)fileName md5:(NSString *)md5 begin:(int)begin offset:(int)offset
{
    return [[JFGSDKSock sharedClient] sendMsgForSockDownloadWithDst:cids fileName:fileName md5:md5 begin:begin offset:offset];
}

#pragma mark
#pragma mark 回调
-(void)jfgSockConnect
{
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

-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID
                                              mSeq:(uint64_t)mSeq
                                               cid:(NSString *)cid
                                              type:(int)type
                                           msgData:(NSData *)msgData
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

- (NSHashTable *)delegates
{
    if (_delegates == nil)
    {
        _delegates = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return _delegates;
}

@end
