//
//  JfgCachePathManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgCachePathManager.h"
#import "LoginManager.h"

@implementation JfgCachePathManager

//账号信息缓存地址
+(NSString *)accountMsgCachePathWithAccount:(NSString *)account
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"jfgfile"];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"accountMsg_%@.db",account]];
    return path;
}

+(NSString *)warnPicMsgCachePathForCid:(NSString *)cid
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:[NSString stringWithFormat:@"WarnPic_%@.db",cid]];
    return homeDic;
}

+(NSString *)doorBellCallRecordCachePathForCid:(NSString *)cid
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:[NSString stringWithFormat:@"DoorBellCallRecord_%@.db",cid]];
    return homeDic;
}

+(NSString *)sfcParamModelCachePath
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:[NSString stringWithFormat:@"sfcParamModelCachePath_%@.db",@"all"]];
    return homeDic;
}

+(NSString *)warnPicForDelCachePathForCid:(NSString *)cid
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:[NSString stringWithFormat:@"WarnPicDel_%@.db",cid]];
    return homeDic;
}

+(NSString *)dayJingCaiMsgCachePath
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:@"dayJingcai.db"];
    return homeDic;
}

+(NSString *)delDeviceCachePath
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:@"delDevice.db"];
    return homeDic;
}

+(NSString *)readAddFriendReqListCachePath
{
    NSString *homeDic = [[self class] cylanDic];
    homeDic = [homeDic stringByAppendingPathComponent:@"readAddFriendReq.list"];
    return homeDic;
}

//主目录
+(NSString *)cylanDic
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"jfgfile"];
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    NSString *accNum;
    if (account) {
        accNum = account.account;
    }else{
        accNum = @"namal";
    }
    path = [path stringByAppendingPathComponent:accNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

@end
