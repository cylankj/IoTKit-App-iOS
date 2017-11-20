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
#import "MessageVCDateModel.h"
#import <JFGSDK/JFGSDKAcount.h>
#import "MsgForAIModel.h"

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

+(void)cachesfcParamModel:(SFCParamModel *)model
{
    dispatch_global_async(^{
        if (model == nil) {
            return;
        }
        NSArray *allArr = [[self class] getSfcParamModels];
        NSMutableArray *arr = [NSMutableArray new];
        if (allArr) {
            arr = [[NSMutableArray alloc]initWithArray:allArr];
        }
        [arr addObject:model];
        NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:[arr copy]];
        [keyValues writeToFile:[JfgCachePathManager sfcParamModelCachePath] atomically:YES];
    });
}

+(SFCParamModel *)getSfcPatamModelForCid:(NSString *)cid
{
    NSArray *allArr = [[self class] getSfcParamModels];
    if (allArr) {
        for (SFCParamModel *model in allArr) {
            if ([model.cid isEqualToString:cid]) {
                return model;
            }
        }
    }
    return nil;
}

+(void)updateLiveModel:(LiveTypeModel *)model
{
    NSArray *allArr = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager liveModelCachePath]];
    NSArray *keyValues = nil;
    if (allArr) {
        NSMutableArray *msgModelList = [LiveTypeModel mj_objectArrayWithKeyValuesArray:allArr];
        BOOL isExist = NO;
        for (LiveTypeModel *_model in [msgModelList copy]) {
            if([model.cid isEqualToString:_model.cid]){
                if ([msgModelList containsObject:_model]) {
                    [msgModelList removeObject:_model];
                    [msgModelList addObject:model];
                }
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            [msgModelList addObject:model];
        }
        keyValues = [LiveTypeModel mj_keyValuesArrayWithObjectArray:msgModelList];
        
    }else{
        keyValues = [LiveTypeModel mj_keyValuesArrayWithObjectArray:@[model]];
    }
    
    if (keyValues) {
        [keyValues writeToFile:[JfgCachePathManager liveModelCachePath] atomically:YES];
    }
}

+(LiveTypeModel *)liveModelForCid:(NSString *)cid
{
    NSArray *allArr = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager liveModelCachePath]];
    if (allArr) {
        NSArray *msgModelList = [LiveTypeModel mj_objectArrayWithKeyValuesArray:allArr];
        for (LiveTypeModel *model in msgModelList) {
            if([model.cid isEqualToString:cid]){
                return model;
            }
        }
    }
    return nil;
}

+(void)removeSfcPatamModelForCid:(NSString *)cid
{
    NSArray <SFCParamModel *>* arr = [[self class] getSfcParamModels];
    
    //需要使用mutableCopy将NSArray转换成NSMutableArray，不然使用removeObject等可变数组操作会引起崩溃
    NSMutableArray *muArr = [arr mutableCopy];
    
    for (SFCParamModel *model in arr) {
        
        if ([model.cid isEqualToString:cid]) {
            
            //这里为什么崩溃，没道理啊（崩溃原因如上）
            if ([muArr containsObject:model]) {
                [muArr removeObject:model];
                NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:muArr];
                [keyValues writeToFile:[JfgCachePathManager sfcParamModelCachePath] atomically:YES];
            }
            break;
        }
        
    }
}

+(NSArray <SFCParamModel *> *)getSfcParamModels
{
    NSArray *allArr = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager sfcParamModelCachePath]];
    if (allArr) {
        NSArray *msgModelList = [SFCParamModel mj_objectArrayWithKeyValuesArray:allArr];
        return msgModelList;
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
+(void)cacheWarnPicMsgList:(NSArray <MessageVCDateModel *>*)list forCid:(NSString *)cid
{
    dispatch_global_async(^{
        
        if (list.count) {
            NSArray *keyValues = [MessageVCDateModel mj_keyValuesArrayWithObjectArray:[list copy]];
            [keyValues writeToFile:[JfgCachePathManager warnPicMsgCachePathForCid:cid] atomically:YES];
        }else{
            
            NSFileManager *filemanager = [NSFileManager defaultManager];
            [filemanager removeItemAtPath:[JfgCachePathManager warnPicMsgCachePathForCid:cid] error:nil];
            
        }
        
    });
}

+(NSArray <MessageVCDateModel *>*)getCacheForWarnPicWithCid:(NSString *)cid
{
    NSArray *msgList = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager warnPicMsgCachePathForCid:cid]];
    NSArray *msgModelList = [MessageVCDateModel mj_objectArrayWithKeyValuesArray:msgList];
    
    for (MessageVCDateModel *mod in msgModelList) {
        
        NSMutableArray *messArr= [MessageModel mj_objectArrayWithKeyValuesArray:mod.messageDataArr];
        mod.messageDataArr = [[NSMutableArray alloc]initWithArray:messArr];
    }
    
    return msgModelList;
}

+(void)cacheMsgForAIDataCache:(NSDictionary *)dataDict cid:(NSString *)cid
{
    dispatch_global_async(^{
        
        if (dataDict) {
            
            NSMutableDictionary *keyValuesDict = [NSMutableDictionary new];
            
            for (NSString *key in dataDict.allKeys) {
                
                NSArray *arr = dataDict[key];
                if ([arr isKindOfClass:[NSArray class]]) {
                    
                    NSArray *keyValues = [MessageModel mj_keyValuesArrayWithObjectArray:[arr copy]];
                    [keyValuesDict setObject:keyValues forKey:key];
                }
                
            }
            
            [keyValuesDict writeToFile:[JfgCachePathManager msgForAIDataPathForCid:cid] atomically:YES];
            
        }
        
    });
}

+(NSDictionary *)getCacheForAIMsgWithCid:(NSString *)cid
{
    NSMutableDictionary *modelDict = [NSMutableDictionary new];
    NSDictionary *keyValuesDict = [[NSDictionary alloc]initWithContentsOfFile:[JfgCachePathManager msgForAIDataPathForCid:cid]];
    for (NSString *key in keyValuesDict) {
        NSArray *keyValue = [keyValuesDict objectForKey:key];
        NSArray *msgModelList = [MessageModel mj_objectArrayWithKeyValuesArray:keyValue];
        [modelDict setObject:msgModelList forKey:key];
    }
    return modelDict;
}

+(void)removeCacheForAIMsgWithCid:(NSString *)cid
{
    if (!cid) {
        return;
    }
    NSString *path = [JfgCachePathManager msgForAIDataPathForCid:cid];
    
    NSString *familuarHeaderPath = [JfgCachePathManager msgForAIDataFamiliarHeaderForCid:cid];
    
    NSString *unfamiluarHeaderPath = [JfgCachePathManager msgForAIDataUnfamiliarHeaderForCid:cid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    if ([fileManager fileExistsAtPath:familuarHeaderPath]) {
        [fileManager removeItemAtPath:familuarHeaderPath error:nil];
    }
    if ([fileManager fileExistsAtPath:unfamiluarHeaderPath]) {
        [fileManager removeItemAtPath:unfamiluarHeaderPath error:nil];
    }
}

+(NSArray <MsgAIheaderModel *>*)getCacheMsgForAIIsFamiliarHeader:(BOOL)familiar cid:(NSString *)cid
{
    NSString *path  = nil;
    if (familiar) {
        path = [JfgCachePathManager msgForAIDataFamiliarHeaderForCid:cid];
    }else{
        path = [JfgCachePathManager msgForAIDataUnfamiliarHeaderForCid:cid];
    }
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:path];
    NSArray *msgModelList = [MsgAIheaderModel mj_objectArrayWithKeyValuesArray:arr];
    if (msgModelList == nil) {
        msgModelList = [NSArray new];
    }
    return msgModelList;
}

+(void)cacheMsgForAIIsFamiliarHeader:(BOOL)familiar data:(NSArray <MsgAIheaderModel *> *)dataList cid:(NSString *)cid
{
    dispatch_global_async(^{
        
        if (dataList && cid) {
            
            NSArray *keyValues = [MsgAIheaderModel mj_keyValuesArrayWithObjectArray:[dataList copy]];
            NSString *path = @"";
            if (familiar) {
                path = [JfgCachePathManager msgForAIDataFamiliarHeaderForCid:cid];
            }else{
                path = [JfgCachePathManager msgForAIDataUnfamiliarHeaderForCid:cid];
            }
            [keyValues writeToFile:path atomically:YES];
            
        }
        
    });
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

+(void)cacheReadAddFriendReqList:(NSArray <JFGSDKFriendRequestInfo *> *)list
{
    if (list.count) {
        
        NSMutableArray *accountList = [NSMutableArray new];
        for (JFGSDKFriendRequestInfo *info in list) {
            if ([info isKindOfClass:[JFGSDKFriendRequestInfo class]]) {
                [accountList addObject:info.account];
            }
        }
        [accountList writeToFile:[JfgCachePathManager readAddFriendReqListCachePath] atomically:YES];
    }else{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[JfgCachePathManager readAddFriendReqListCachePath] error:nil];
    }
   
}

+(NSArray <NSString *> *)getCacheReadAddFriendReqAccountList
{
    NSArray *accountList = [[NSArray alloc]initWithContentsOfFile:[JfgCachePathManager readAddFriendReqListCachePath]];
    return accountList;
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

+(YoutubeLiveStreamsModel *)youtubeModelForCid:(NSString *)cid
{
    NSArray *arr = [[NSArray array]initWithContentsOfFile:[JfgCachePathManager youtubeModelPath]];
    NSArray *modelList = [YoutubeLiveStreamsModel mj_objectArrayWithKeyValuesArray:arr];
    for (YoutubeLiveStreamsModel *model in modelList) {
        if ([model.cid isEqualToString:cid]) {
            return model;
        }
    }
    return nil;
}

+(void)updateYoutubeModel:(YoutubeLiveStreamsModel *)model
{
    NSArray *arr = [[NSArray array]initWithContentsOfFile:[JfgCachePathManager youtubeModelPath]];
    NSMutableArray *modelList = [YoutubeLiveStreamsModel mj_objectArrayWithKeyValuesArray:arr];
    for (YoutubeLiveStreamsModel *_model in [modelList copy]) {
        if ([model.cid isEqualToString:_model.cid]) {
            if ([modelList containsObject:_model]) {
                [modelList removeObject:_model];
                break;
            }
        }
    }
    if (!modelList) {
        modelList = [NSMutableArray new];
    }
    [modelList addObject:model];
    arr = [YoutubeLiveStreamsModel mj_keyValuesArrayWithObjectArray:modelList];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [arr writeToFile:[JfgCachePathManager youtubeModelPath] atomically:YES];
    });
}

@end
