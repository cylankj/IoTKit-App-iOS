//
//  JfgCacheManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"
#import "JfgCachePathManager.h"
#import <JFGSDK/JFGSDKAcount.h>
#import "BellModel.h"
#import "SFCParamModel.h"

@class MessageModel;
@class ExploreModel;

@interface JfgCacheManager : NSObject

#pragma mark- 账号信息缓存
/**
 *  缓存账号信息
 *
 *  @param account 账号信息对象
 */
+(void)cacheAccountMsg:(JFGSDKAcount *)account;

/**
 *  获取账号信息对象
 *
 *  @param account 账号
 *
 *  @return 账号对象
 */
+(JFGSDKAcount *)getCacheForAccountWithAccountNumber:(NSString *)account;


#pragma mark- 报警图片缓存
//缓存报警图片到本地
+(void)cacheWarnPicMsgList:(NSArray <MessageModel *>*)list forCid:(NSString *)cid;

//获取本地缓存报警图片
+(NSArray <MessageModel *>*)getCacheForWarnPicWithCid:(NSString *)cid;

//缓存无网络状态下删除的报警图片
+(void)cacheWarnPicForDelMsgList:(NSArray <MessageModel *>*)list forCid:(NSString *)cid;

//获取无网络状态下删除的报警图片
+(NSArray <MessageModel *>*)getCacheForWarnPicForDelWithCid:(NSString *)cid;

+(void)cacheDoorbellCallRecordMsgList:(NSArray <BellModel *> *)list forCid:(NSString *)cid;

+(NSArray <BellModel *>*)getDoorbellCallRecordWithCid:(NSString *)cid;

//获取全景设备直播视图属性
+(SFCParamModel *)getSfcPatamModelForCid:(NSString *)cid;

//缓存直播视图属性
+(void)cachesfcParamModel:(SFCParamModel *)model;

//删除直播视图属性
+(void)removeSfcPatamModelForCid:(NSString *)cid;


#pragma mark- 好友相关
//缓存已读添加好友消息
+(void)cacheReadAddFriendReqList:(NSArray <JFGSDKFriendRequestInfo *> *)list;

//获取已读添加好友消息
+(NSArray <NSString *> *)getCacheReadAddFriendReqAccountList;

#pragma mark- 每日精彩
//每日精彩数据缓存
+(void)cacheDayJingcaiMsgList:(NSArray <ExploreModel *> *)list;
//获取每日精彩本地缓存数据
+(NSArray <ExploreModel *> *)getCacheForDayJingcai;


@end
