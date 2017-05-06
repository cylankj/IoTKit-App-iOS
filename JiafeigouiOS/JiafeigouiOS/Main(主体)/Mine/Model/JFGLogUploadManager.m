//
//  JFGLogUploadManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/20.
//  Copyright © 2017年 lirenguang. All rights reserved.
//
/*
 如果当前有文件传输任务,则不发送日志
 如果用户上次传输日志距离现在 < 12h, 不发送日志
 日志传输失败重试 3次
 传输日志成功后,停止日志,删除文件,重新开启日志
 SDK 将日志限定在5M
 尽量在系统空闲,没有在看直播时上传
 */

#import "JFGLogUploadManager.h"
#import <ZipArchive/ZipArchive.h>
#import "LoginManager.h"
#import "CommonMethod.h"
#import "JfgCachePathManager.h"

@interface JFGLogUploadManager()<JFGSDKCallbackDelegate>
{
    NSHashTable *obsevers;
    BOOL uploadCount;
}
@property (nonatomic,assign)BOOL isUploading;
@property (nonatomic,assign)uint64_t curTimestamp;
@property (nonatomic,assign)uint64_t curSeq;
@property (nonatomic,strong)NSMutableDictionary *segDict;
@property (nonatomic,strong)NSMutableArray <NSNumber *>*uploadSuccessList;
@property (nonatomic,strong)NSMutableArray <NSNumber *>*uploadFailedList;
//
@end

@implementation JFGLogUploadManager

static JFGLogUploadManager *_instance;
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    //    @synchronized (self) {
    //        // 为了防止多线程同时访问对象，造成多次分配内存空间，所以要加上线程锁
    //        if (_instance == nil) {
    //            _instance = [super allocWithZone:zone];
    //        }
    //        return _instance;
    //    }
    // 也可以使用一次性代码
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

// 为了使实例易于外界访问 我们一般提供一个类方法
// 类方法命名规范 share类名|default类名|类名
+(instancetype)shareLogUpload
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
    if(_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
    
}

// 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

-(instancetype)init
{
    self = [super init];
    self.segDict = [NSMutableDictionary new];
    self.isUploading = NO;
    [self cacheList];
    [JFGSDK addDelegate:self];
    obsevers = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    return self;
}

-(void)addDelegate:(id<JFGLogUploadManagerDelegate>)delegate
{
    if (!delegate) {
        return;
    }
    if (![obsevers containsObject:delegate]) {
        [obsevers addObject:delegate];
    }
}

-(BOOL)uploadLogFileForTimestamp:(uint64_t)timestamp
{
    if ([self timeCompare] && !self.isUploading) {
        
        self.isUploading = YES;
        self.curTimestamp = timestamp;
        uploadCount = 0;
        [self uploadFile];
        return YES;
    }
    return NO;
}

-(void)uploadFile
{
    uploadCount ++;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path1 = [path stringByAppendingPathComponent:@"jfgworkdic"];
    NSString *path2 = [path1 stringByAppendingPathComponent:@"smartCall_t.txt"];
    NSString *path3 = [path1 stringByAppendingPathComponent:@"smartCall_w.txt"];
    NSString *path4 = [path1 stringByAppendingPathComponent:@"userCall_t.txt"];
    NSString *path5 = [path1 stringByAppendingPathComponent:@"smartCall_t_1.txt"];
    NSString *path6 = [path1 stringByAppendingPathComponent:@"smartCall_w_1.txt"];
    NSString *path7 = [path1 stringByAppendingPathComponent:@"userCall_t_1.txt"];
    
    [SSZipArchive createZipFileAtPath:[path stringByAppendingPathComponent:@"jfgworkdic.zip"] withFilesAtPaths:@[path2,path3,path4,path5,path6,path7]];
    JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
    NSString *account = acc.account;
    self.curSeq = [JFGSDK uploadFile:[path stringByAppendingPathComponent:@"jfgworkdic.zip"] toCloudFolderPath:[CommonMethod uplodUrlForLogWithAccount:account timestamp:self.curTimestamp]];
    [self.segDict setObject:[NSNumber numberWithUnsignedLongLong:self.curTimestamp] forKey:[NSString stringWithFormat:@"%lld",self.curSeq]];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"uploadLogStartForTime:%lld seq:%lld",self.curTimestamp,self.curSeq]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadOvertime) object:nil];
    [self performSelector:@selector(uploadOvertime) withObject:nil afterDelay:120];
}

-(void)uploadOvertime
{
    if (uploadCount>3) {
        self.isUploading = NO;
        NSNumber *va = [self.segDict objectForKey:[NSString stringWithFormat:@"%llu",self.curSeq]];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"uploadLogOvertimeForSeq:%lld",[va longLongValue]]];
        [self.uploadFailedList addObject:va];
        for (id <JFGLogUploadManagerDelegate> delegate in [obsevers copy]) {
            if ([delegate respondsToSelector:@selector(logUploadFailedForTimestamp:errorType:)]) {
                [delegate logUploadFailedForTimestamp:[va longLongValue] errorType:JFGLogUploadErrorTypeUnKnow];
            }
        }
    }else{
        [self uploadFile];
    }
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (!online && self.isUploading) {
        self.isUploading = NO;
        NSNumber *va = [self.segDict objectForKey:[NSString stringWithFormat:@"%llu",self.curSeq]];
        [self.uploadFailedList addObject:va];
        for (id <JFGLogUploadManagerDelegate> delegate in [obsevers copy]) {
            if ([delegate respondsToSelector:@selector(logUploadFailedForTimestamp:errorType:)]) {
                [delegate logUploadFailedForTimestamp:[va longLongValue] errorType:JFGLogUploadErrorTypeUnKnow];
            }
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"uploadLogFailedForSeq:%lld",[va longLongValue]]];
    }
}

-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    NSNumber *va = [self.segDict objectForKey:[NSString stringWithFormat:@"%d",requestID]];
    if (va) {
        
        if (requestID == self.curSeq) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadOvertime) object:nil];
            
            if (ret == 200) {
                self.isUploading = NO;
                for (id <JFGLogUploadManagerDelegate> delegate in [obsevers copy]) {
                    
                    if ([delegate respondsToSelector:@selector(logUploadSuccessForTimestamp:)]) {
                        [delegate logUploadSuccessForTimestamp:[va longLongValue]];
                    }
                }
                
                [self.uploadSuccessList addObject:va];
                [self saveCacheList];
                JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
                NSString *key = [NSString stringWithFormat:@"JFGLogUploadLastTimeKey_%@",account.account?account.account:@"namal"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
                [JFGSDK resetLog];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"uploadLogSuccessForSeq:%lld",[va longLongValue]]];
                
                
            }else{
                
                if (uploadCount>3) {
                    self.isUploading = NO;
                    [self.uploadFailedList addObject:va];
                    for (id <JFGLogUploadManagerDelegate> delegate in [obsevers copy]) {
                        if ([delegate respondsToSelector:@selector(logUploadFailedForTimestamp:errorType:)]) {
                            [delegate logUploadFailedForTimestamp:[va longLongValue] errorType:JFGLogUploadErrorTypeUnKnow];
                        }
                    }
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"uploadLogFailedForSeq:%lld",[va longLongValue]]];
                }else{
                    [self uploadFile];
                }
               
            }
        }
    }
    
}

-(BOOL)timeCompare
{
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    NSString *key = [NSString stringWithFormat:@"JFGLogUploadLastTimeKey_%@",account.account?account.account:@"namal"];
    NSDate *lastTimeDate = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (lastTimeDate == nil) {
        return YES;
    }
    NSTimeInterval lastTimeInterval = [lastTimeDate timeIntervalSince1970];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (currentTimeInterval - lastTimeInterval >= 60*5) {
        return YES;
    }
    return NO;
}

-(void)cacheList
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:@"logSuccessList.plist"];
    
    NSMutableArray *dict = [[NSMutableArray alloc]initWithContentsOfFile:path];
    if (dict) {
        self.uploadSuccessList = [[NSMutableArray alloc]initWithArray:dict];
    }else{
        self.uploadSuccessList = [NSMutableArray new];
    }
}

-(void)saveCacheList
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:@"logSuccessList.plist"];
    if (self.uploadSuccessList) {
        [self.uploadSuccessList writeToFile:path atomically:YES];
    }
}

@end
