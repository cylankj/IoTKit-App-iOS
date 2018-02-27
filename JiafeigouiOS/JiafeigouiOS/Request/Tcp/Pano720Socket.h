//
//  Pano720Socket.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Pano720SocketDelegate <NSObject>

@optional

-(void)panoConnectted;

-(void)panoDisconnectted;

-(void)receivePanoDataMsgID:(NSString *)msgID sequence:(uint64_t)mSeq cid:(NSString *)cid reponseType:(int)reponseType msgContent:(id)msgContent;

- (void)receivepanoDataPointmsgID:(NSString *)msgID sequence:(uint64_t)mSeq cid:(NSString *)cid reponseType:(int)reponseType dpMsgDict:(NSDictionary *)dpData;

@end

@interface Pano720Socket : NSObject

+ (instancetype)sharedSocket;

//添加/移除 代理
-(void)addDelegate:(id<Pano720SocketDelegate>)delegate;
-(void)removeDelegate:(id<Pano720SocketDelegate>)delegate;

- (void)panoConnect:(NSString *)cid;
//局域网 tcp 连接
//-(void)panoConnectIp:(NSString *)ip port:(short)port autoConnect:(BOOL)isAuto;
//局域网 断开tcp连接
-(void)panoDisconnect;

//send msg named 20006
-(uint64_t)sendMsgWithCids:(NSArray <NSString *>*)cids isCallBack:(BOOL)isCallBack requestType:(int)requestType requestData:(NSArray *)requestArr;
// send dp msg
//- (uint64_t)sendDataPointMsg:(NSString *)cid dpMsgSegs:(NSArray <DataPointSeg *> *)segs;

// 专门下载 消息
- (uint64_t)sendDownloadMsgWithCids:(NSArray <NSString *>*)cids fileName:(NSString *)fileName md5:(NSString *)md5 begin:(int)begin offset:(int)offset;

@end
