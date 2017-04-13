//
//  JFGSDKSock.h
//  JFGSDK
//
//  Created by 杨利 on 2017/3/16.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGSDKSockCBDelegate.h"
#import "JFGSDKDataPointModel.h"

@interface JFGSDKSock : NSObject

/**
 * 是否已经连接
 */
@property (nonatomic,readonly)BOOL isConnected;

/**
 * sock连接的ip地址
 */
@property (nonatomic,readonly)NSString *connectIpAddr;

/**
 * 端口
 */
@property (nonatomic,readonly)short port;

//获取实例
+(instancetype)sharedClient;

//连接
-(void)connectWithIp:(NSString *)ip port:(short)port autoReconnect:(BOOL)autoReconnect;

//断开连接
-(void)disconnect;

//发送20006消息
-(uint64_t)sendMsgForSockWithDst:(NSArray <NSString *>*)dst isAck:(BOOL)isAck fileType:(int)fileType msg:(NSData *)msg;

//dp
-(uint64_t)sendDPDataMsgForSockWithPeer:(NSString *)peer dpMsgIDs:(NSArray <DataPointSeg *>*)dpMsgIDs;

//下载专用接口
-(uint64_t)sendMsgForSockDownloadWithDst:(NSArray <NSString *>*)dst fileName:(NSString *)fileName md5:(NSString *)md5 begin:(int)begin offset:(int)offset;

//添加代理
-(void)addDelegate:(id<JFGSDKSockCBDelegate>)delegate;

//移除代理
-(void)removeDelegate:(id<JFGSDKSockCBDelegate>)delegate;

@end
