//
//  JfgCachePathManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JfgCachePathManager : NSObject

//缓存账号信息地址
+(NSString *)accountMsgCachePathWithAccount:(NSString *)account;

//缓存报警图片信息
+(NSString *)warnPicMsgCachePathForCid:(NSString *)cid;

//无网络状态下删除报警图片缓存
+(NSString *)warnPicForDelCachePathForCid:(NSString *)cid;

//每日精彩缓存地址
+(NSString *)dayJingCaiMsgCachePath;

//门铃呼叫记录缓存
+(NSString *)doorBellCallRecordCachePathForCid:(NSString *)cid;

//本客户端自己删除的设备记录
+(NSString *)delDeviceCachePath;

//主目录
+(NSString *)cylanDic;

@end
