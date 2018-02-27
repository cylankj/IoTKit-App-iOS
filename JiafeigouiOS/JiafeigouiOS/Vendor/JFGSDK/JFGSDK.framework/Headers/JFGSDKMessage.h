//
//  JFGSDKMessage.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/28.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGTypeDefine.h"


/*!
 *  门铃呼叫消息
 */
@interface JFGSDKDoorBellCall : NSObject

/*!
 *  来自此cid的呼叫
 */
@property (nonatomic,copy)NSString *cid;
/*!
 *  呼叫时间
 */
@property (nonatomic,assign)int time;
/*!
 *  门铃地址
 */
@property (nonatomic,assign)int regionType;
/*!
 *  是否已经接听
 */
@property (nonatomic,assign)BOOL isAnswer;

/*!
 *  upd呼叫地址
 */
@property (nonatomic,copy)NSString *ipAddr;

@end

@interface JFGSDKRobotMessage : NSObject

/*!
 *  需要将消息发送的目标
 */
@property (strong,nonatomic) NSArray <NSString *> * targets;

/*!
 *  是否需要回应
 */
@property (nonatomic,assign) BOOL isAck;

/*!
 *  此消息的序列号
 */
@property (nonatomic,assign) int sn;


/*!
 *  消息内容，最大长度为64k
 */
@property (nonatomic,strong) NSData *msg;


/**
 *  消息发送者
 */
@property (nonatomic,copy) NSString *caller;

@end



@interface JFGSDKFeedBackInfo : NSObject

/**
 *  消息内容
 */
@property (nonatomic,copy)NSString *msg;

/**
 *  消息时间
 */
@property (nonatomic,assign)int64_t timestamp;

@end
