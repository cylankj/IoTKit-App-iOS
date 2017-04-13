//
//  JfgCacheManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgCacheManager.h"
#import "MessageModel.h"
#import "ExploreModel.h"


@implementation JfgCacheManager

#define dispatch_global_async(block)\
       dispatch_async(dispatch_get_global_queue(0, 0),block);


#pragma mark- 账号信息缓存（JFGSDKAcount）
//保存账号信息
+(void)cacheAccountMsg:(JFGSDKAcount *)account
{
    dispatch_global_async(^{
        NSDictionary *dict = [account mj_keyValues];
        [dict writeToFile:[JfgCachePathManager accountMsgCachePathWithAccount:account.account] atomically:YES];
    });
}

//获取账号信息
+(JFGSDKAcount *)getCacheForAccountWithAccountNumber:(NSString *)account
{
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:[JfgCachePathManager accountMsgCachePathWithAccount:account]];
    if (dict) {
        JFGSDKAcount *account = [JFGSDKAcount mj_objectWithKeyValues:dict];
        return account;
    }
    return nil;
}


+(void)cacheDoorbellCallRecordMsgList:(NSArray <BellModel *> *)list forCid:(NSString *)cid
{
    dispatch_global_async(^{
        
        if (list.count) {
            NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:[list copy]];
            [keyValues writeToFile:[JfgCachePathManager doorBellCallRecordCachePathForCid:cid] atomically:YES];
        }else{
            
            NSFileManager *filemanager = [NSFileManager defaultManager];
            [filemanager removeItemAtPath:[JfgCachePathManager doorBellCallRecordCachePathForCid:cid] error:nil];
            
        }
        
        
    });
}

+(NSArray <BellModel *>*)getDoorbellCallRecordWithCid:(NSString *)cid
{
    NSArray *msgList = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager doorBellCallRecordCachePathForCid:cid]];
    NSArray *msgModelList = [BellModel mj_objectArrayWithKeyValuesArray:msgList];
    return msgModelList;
}

#pragma mark- 报警图片缓存
+(void)cacheWarnPicMsgList:(NSArray <MessageModel *>*)list forCid:(NSString *)cid
{
    dispatch_global_async(^{
        
        if (list.count) {
            NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:[list copy]];
            [keyValues writeToFile:[JfgCachePathManager warnPicMsgCachePathForCid:cid] atomically:YES];
        }else{
            
            NSFileManager *filemanager = [NSFileManager defaultManager];
            [filemanager removeItemAtPath:[JfgCachePathManager warnPicMsgCachePathForCid:cid] error:nil];
            
        }
        
        
    });
}

+(NSArray <MessageModel *>*)getCacheForWarnPicWithCid:(NSString *)cid
{
    NSArray *msgList = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager warnPicMsgCachePathForCid:cid]];
    NSArray *msgModelList = [MessageModel mj_objectArrayWithKeyValuesArray:msgList];
    return msgModelList;
}

+(void)cacheWarnPicForDelMsgList:(NSArray <MessageModel *>*)list forCid:(NSString *)cid
{
    dispatch_global_async(^{
        if (list.count) {
            NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:[list copy]];
            [keyValues writeToFile:[JfgCachePathManager warnPicForDelCachePathForCid:cid] atomically:YES];
        }else{
            NSFileManager *filemanager = [NSFileManager defaultManager];
            [filemanager removeItemAtPath:[JfgCachePathManager warnPicForDelCachePathForCid:cid]  error:nil];
        }
        
    });
}

+(NSArray <MessageModel *>*)getCacheForWarnPicForDelWithCid:(NSString *)cid
{
    NSArray *msgList = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager warnPicForDelCachePathForCid:cid]];
    NSArray *msgModelList = [MessageModel mj_objectArrayWithKeyValuesArray:msgList];
    return msgModelList;
}

#pragma mark- 每日精彩
+(void)cacheDayJingcaiMsgList:(NSArray <ExploreModel *> *)list
{
    dispatch_global_async(^{
    
        
        if (list.count) {
             NSArray *keyValues = [ExploreModel mj_keyValuesArrayWithObjectArray:[list copy]];
             [keyValues writeToFile:[JfgCachePathManager dayJingCaiMsgCachePath] atomically:YES];
        }else{
            NSFileManager *filemanager = [NSFileManager defaultManager];
            [filemanager removeItemAtPath:[JfgCachePathManager dayJingCaiMsgCachePath] error:nil];
        }
    
    });
    
}

+(NSArray <ExploreModel *> *)getCacheForDayJingcai
{
    NSArray *listArr = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager dayJingCaiMsgCachePath]];
    NSArray *modelList = [ExploreModel mj_objectArrayWithKeyValuesArray:listArr];
    return modelList;
}
@end
