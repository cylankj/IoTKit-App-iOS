//
//  JfgCachePathManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JfgCachePathManager : NSObject

//AI相关消息缓存地址
+(NSString *)msgForAIDataPathForCid:(NSString *)cid;

/**
 * 熟人头像数据
 */
+(NSString *)msgForAIDataFamiliarHeaderForCid:(NSString *)cid;

/**
 * 陌生人头像数据
 */
+(NSString *)msgForAIDataUnfamiliarHeaderForCid:(NSString *)cid;

//缓存账号信息地址
+(NSString *)accountMsgCachePathWithAccount:(NSString *)account;

//缓存报警图片信息
+(NSString *)warnPicMsgCachePathForCid:(NSString *)cid;

//鱼眼配置路径
+(NSString *)sfcParamModelCachePath;

//无网络状态下删除报警图片缓存
+(NSString *)warnPicForDelCachePathForCid:(NSString *)cid;

//每日精彩缓存地址
+(NSString *)dayJingCaiMsgCachePath;

//门铃呼叫记录缓存
+(NSString *)doorBellCallRecordCachePathForCid:(NSString *)cid;

//本客户端自己删除的设备记录
+(NSString *)delDeviceCachePath;

//已读添加好友消息列表
+(NSString *)readAddFriendReqListCachePath;

//Live推流平台数据模型存储地址
+(NSString *)liveModelCachePath;

//Youtube
+(NSString *)youtubeModelPath;

//主目录
+(NSString *)cylanDic;

@end
