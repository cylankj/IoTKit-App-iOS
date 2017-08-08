//
//  JFGSDKCallbackDelegate.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/26.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGSDKAcount.h"
#import "JFGSDKMessage.h"
#import "JFGSDKDevice.h"
#import "JFGSDKUDPRespose.h"
#import "JFGSDKHistoryVideoTimeInfo.h"
#import "JFGSDKDataPointModel.h"

@protocol JFGSDKCallbackDelegate <NSObject>

@optional

#pragma mark - Account And connect
/*!
 *  登录结果
 *
 *  @param ssession  用户登录session,只在登录成功时有效
 *  @param errorType  可能的值为 JFGErrorTypeNone(登录成功), JFGErrorTypeLoginInvalidPass, JFGErrorTypeLoginInvalidSession
 */
-(void)jfgLoginResult:(JFGErrorType)errorType;


/**
 *  注册结果
 *
 *  @param errorType 注册错误类型
 */
-(void)jfgRegisterResult:(JFGErrorType)errorType;


/**
 *  发送验证码结果
 *
 *  @param errorType 错误码
 */
-(void)jfgSendSMSResult:(JFGErrorType)errorType token:(NSString *)token;

/**
 *  校验验证码结果
 *
 *  @param errorType 错误码
 */
-(void)jfgVerifySMSResult:(JFGErrorType)errorType;


/**
 *  第三方登录绑定手机号/邮箱，设置密码结果
 *
 *  @param errorType 错误码
 */
-(void)jfgSetPasswordForOpenLoginResult:(JFGErrorType)errorType;


/**
 *  修改邮箱密码
 *
 *  @param email     被修改邮箱
 *  @param errorType 错误码
 */
-(void)jfgForgetPassByEmail:(NSString *)email errorType:(JFGErrorType)errorType;


/**
 *  账号在线状态
 *
 *  @param online 在线状态
 */
-(void)jfgAccountOnline:(BOOL)online;


/**
 *  账号被服务器强制退出
 *
 *  @param errorType 退出原因
 */
-(void)jfgLoginOutByServerWithCause:(JFGErrorType)errorType;

/*!
 *  用户账号属性更新
 *
 *  @param account 账户信息
 */
-(void)jfgUpdateAccount:(JFGSDKAcount *)account;

#pragma mark - Device Message
/*!
 *  设备列表
 *
 *  @param deviceList 设备列表
 */
-(void)jfgDeviceList:(NSArray <JFGSDKDevice *> *)deviceList;

/**
 *  解除绑定结果
 *
 *  @param errorType 错误码
 */
-(void)jfgDeviceUnBind:(JFGErrorType)errorType;

/**
 *  设备版本信息
 *
 *  @param info 版本信息
 */
-(void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info;

/**
 *  局域网设备升级回调
 */
-(void)jfgDevUpgradeInfo:(JFGSDKDeviceUpgrade *)info;


/**
 *  设备分区块升级回调
 */
-(void)jfgDevMultPartsUpgradeInfos:(NSArray <JFGSDKDevUpgradeInfo *> *)infos
                               cid:(NSString *)cid
                         errorType:(JFGErrorType)errorType;

/**
 *  升级检测
 */
-(void)jfgDevCheckTagDeviceVersion:(NSString *)version
                          describe:(NSString *)describe
                          tagInfos:(NSArray <JFGSDKDevUpgradeInfoT *> *)infos
                               cid:(NSString *)cid
                         errorType:(JFGErrorType)errorType;

/**
 *  cylan
 */
-(void)jfgCheckClientVersionForErrorType:(JFGErrorType)errorType coerce_Upgrade:(int)coerce_Upgrade url:(NSString *)url;


/*!
 *  其他客户端已接听门铃的呼叫
 */
-(void)jfgOtherClientAnswerDoorbellForCid:(NSString *)cid;


/*!
 *  来自门铃的呼叫
 *
 *  @param call 呼叫门铃信息
 */
-(void)jfgDoorbellCall:(JFGSDKDoorBellCall *)call;


/**
 *  设备别名
 *
 *  @param alias     别名
 *  @param errorType 错误码
 */
-(void)jfgDeviceAlias:(NSString *)alias errorType:(JFGErrorType)errorType;


/**
 *  设置设备别名
 *
 *  @param errorType 错误码
 */
-(void)jfgSetDeviceAliasResult:(JFGErrorType)errorType;

#pragma mark - Server Message
/*!
 *  Http请求回调
 *
 *  @param ret       HTTP状态码, 200为成功,其余为失败
 *  @param requestID 请求标示,和 #HttpGet 或 #HttpPostFile 返回值对应
 *  @param result    服务器返回消息, 仅在 JFGMsgHttpResult::ret 为200时有效
 */
-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result;


-(void)jfgVideoShareUrl:(NSString *)url;


#pragma mark- UDP通信
/*!
 *  fping 回调
 */
-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask;

/**
 *  ping respose
 *
 *  @param ask ping msg
 */
-(void)jfgPingRespose:(JFGSDKUDPResposePing *)ask;

/**
 *  set wifi
 *
 *  @param ask setwifi msg
 */
-(void)jfgSetWifiRespose:(JFGSDKUDPResposeSetWifi *)ask;


/**
 * 软起AP回调
 *
 * 成功回复ask.ret = 0
 */
-(void)jfgSetAPRespose:(JFGSDKUDPResposeSetAP *)ask;


/**
 * 局域网设置速率回调
 *
 * @param cid 设备cid
 * @param ret 成功返回0
 */
-(void)jfgUdpSetBitrateResposeForCid:(NSString *)cid ret:(int)ret;

#pragma mark- robot
/*!
 *  收到萝卜头透传的消息
 */
-(void)jfgOnRobotTransmitMsg:(JFGSDKRobotMessage *)message;

/*!
 *  收到萝卜头透传的消息2
 */
-(void)jfgOnUniversalData:(NSData *)msgData msgID:(int)mid seq:(long)seq;


/*!
 *  萝卜头消息应答
 *
 *  @param sn 消息序列号
 */
-(void)jfgOnRobotMsgAck:(int)sn;


/**
 *  萝卜头DataPoint推送消息
 *
 *  @param peer    对端设备标示
 *  @param msgList 消息列表（最终数据类型DataPointSeg）
 */
-(void)jfgRobotPushMsgForPeer:(NSString *)peer msgList:(NSArray <NSArray <DataPointSeg *>*>*)msgList;


/**
 *  来自其他APP/设备 触发的DP同步消息
 *
 *  @param peer    数据所属对象
 *  @param isDev   YES:同步来自设备，NO:来自APP操作触发
 *  @param msgList DP数据列表
 */
-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray <DataPointSeg *> *)msgList;


/**
 *  网络变化
 *
 *  @param netType 网络类型（WWAN网络,返回3G）
 */
-(void)jfgNetworkChanged:(JFGNetType)netType;

/**
 *  加好友请求列表
 *
 *  @param list      列表数据
 *  @param errorType 错误码
 */
-(void)jfgFriendRequestList:(NSArray <JFGSDKFriendRequestInfo *>*)list error:(JFGErrorType)errorType;

/**
 *  好友列表
 *
 *  @param list      列表数据
 *  @param errorType 错误码
 */
-(void)jfgFriendList:(NSArray *)list error:(JFGErrorType)errorType;

/**
 *  获取好友备注
 *
 *  @param remark  备注名
 *  @param account 好友账号
 */
-(void)jfgGetFriendInfo:(JFGSDKFriendInfo *)info error:(JFGErrorType)errorType;

/**
 *  好友请求相关回调
 *
 *  @param type      返回类型
 *  @param errorType 结果
 */
-(void)jfgResultIsRelatedToFriendWithType:(JFGFriendResultType)type error:(JFGErrorType)errorType;

/**
 *  账号请求相关回调
 *
 *  @param type      返回类型
 *  @param errorType 结果
 */
-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType;


/**
 *  判断账号是否是好友，同时在登录状态下判断账号是否已经注册
 *
 *  @param account 被检查的账号
 *  @param isExist 是否是好友
 *  @param errorType 账号是否注册（0：已注册  240：未注册）
 */
-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist errorType:(JFGErrorType)errorType;



/**
 *  分享设备结果
 *
 *  @param ret     结果
 *  @param cid     分享的设备标示
 *  @param account 分享给的账号
 */
-(void)jfgShareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account;


-(void)jfgMultiShareDeviceResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account;

/**
 *  取消分享
 *
 *  @param ret     结果
 *  @param cid     同上
 *  @param account 同上
 */
-(void)jfgUnshareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account;


/**
 *  设备分享列表
 *
 *  @param friendList 分享列表
 */
-(void)jfgDeviceShareList:(NSDictionary <NSString *,NSArray <JFGSDKFriendInfo *>*> *)friendList;

/**
 *  某设备未分享好友列表
 *
 *  @param errorType 结果
 *  @param list      好友列表
 */
-(void)jfgUnshareFriendListByCidResult:(JFGErrorType)errorType list:(NSArray <JFGSDKFriendInfo *>*)list;

/**
 *  NTP时间更新
 *
 *  @param unixTimestamp unix时间戳
 */
-(void)jfgOnUpdateNTP:(uint32_t)unixTimestamp;


/**
 *  中控消息回调
 *
 *  @param msg msgpack解析后消息
 */
-(void)jfgEfamilyMsg:(id)msg;


/**
 *  获取反馈消息回调
 *
 *  @param infoList  消息列表
 *  @param errorType 错误码
 */
-(void)jfgFeedBackWithInfoList:(NSArray <JFGSDKFeedBackInfo *> *)infoList errorType:(JFGErrorType)errorType;


/**
 *  发送反馈意见结果
 *
 *  @param errorType 错误码
 */
-(void)jfgSendFeedBackResult:(JFGErrorType)errorType;


/**
 *  upload device token result
 *
 *  @param errorType  error type
 */
-(void)jfgUploadDeviceTokenResult:(JFGErrorType)errorType;


/**
 ad policy rsp
 */
-(void)jfgGetAdpolicyResult:(JFGErrorType)errorType endTime:(uint32_t)endtime picUrl:(NSString *)picUrl tagUrl:(NSString *)tagUrl;


-(void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                             mSeq:(uint64_t)mSeq
                                              cid:(NSString *)cid
                                             type:(int)type
                                     isInitiative:(BOOL)initiative
                                          msgData:(NSData *)msgData;

-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                                mSeq:(uint64_t)mSeq
                                                 cid:(NSString *)cid
                                                type:(int)type
                                        isInitiative:(BOOL)initiative
                                            dpMsgArr:(NSArray *)dpMsgArr;

@end
