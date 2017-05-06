//
//  LSChatDataManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/21.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "LSChatDataManager.h"
#import "JfgCachePathManager.h"
#import <MJExtension/MJExtension.h>
#import "JFGLogUploadManager.h"
#import "JfgConfig.h"

@interface LSChatDataManager()<JFGLogUploadManagerDelegate>

@property (nonatomic,strong)NSMutableArray <LSChatModel *> *chatModelList;

@end

@implementation LSChatDataManager

static LSChatDataManager *_instance;
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
+(instancetype)shareChatDataManager
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
    [[JFGLogUploadManager shareLogUpload] addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterbackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginout) name:JFGAccountLoginOutKey object:nil];
    //
    return self;
}

-(void)didEnterbackground
{
    [self saveChatList];
}

-(void)willTerminate
{
    for (LSChatModel *model in self.chatModelList) {
        if (model.sendStatue == LSSendStatueSending) {
            model.sendStatue = LSSendStatueFailed;
        }
    }
    [self saveChatList];
}

-(void)didReceiveMemoryWarning
{
    [self saveChatList];
    [self.chatModelList removeAllObjects];
    self.chatModelList = nil;
}

-(void)loginout
{
    [self saveChatList];
    [self.chatModelList removeAllObjects];
    self.chatModelList = nil;
}

-(void)logUploadSuccessForTimestamp:(uint64_t)timestamp
{
    for (LSChatModel *model in self.chatModelList) {
        if (timestamp == model.timestamp) {
            model.sendStatue = LSSendStatueSuccess;
            break;
        }
    }
}

-(void)logUploadFailedForTimestamp:(uint64_t)timestamp errorType:(JFGLogUploadErrorType)errorType
{
    for (LSChatModel *model in self.chatModelList) {
        if (timestamp == model.timestamp) {
            model.sendStatue = LSSendStatueFailed;
            break;
        }
    }
}

-(void)saveChatList
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:@"chatList.plist"];
    if (self.chatModelList.count) {
        NSArray *arr = [LSChatModel mj_keyValuesArrayWithObjectArray:self.chatModelList];
        [arr writeToFile:path atomically:YES];
    }else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
    }
}

-(NSArray *)getCacheChatList
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:@"chatList.plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:path];
    if (arr) {
        NSArray *chatArr = [LSChatModel mj_objectArrayWithKeyValuesArray:arr];
        return chatArr;
    }
    return nil;
}

-(NSMutableArray *)chatModelList
{
    if (_chatModelList == nil) {
        NSArray *arr = [self getCacheChatList];
        for (LSChatModel *model in arr) {
            if (model.sendStatue == LSSendStatueSending) {
                model.sendStatue = LSSendStatueFailed;
            }
        }
        if (arr) {
            _chatModelList = [[NSMutableArray alloc]initWithArray:arr];
        }else{
            _chatModelList = [[NSMutableArray alloc]init];
        }
    }
    return _chatModelList;
}

-(void)replaceChatModel:(LSChatModel *)chatModel
{
    for (LSChatModel *model in [self.chatModelList copy]) {
        //去重
        if (model.timestamp == chatModel.timestamp) {
            NSInteger index = [self.chatModelList indexOfObject:model];
            if (index>0 && index<self.chatModelList.count) {
                [self.chatModelList replaceObjectAtIndex:index withObject:chatModel];
            }
            
        }
    }
}

-(void)addChatModel:(LSChatModel *)chatModel
{
    for (LSChatModel *model in self.chatModelList) {
        //去重
        if (model.timestamp == chatModel.timestamp) {
            return;
        }
    }
    [self.chatModelList addObject:chatModel];
}

-(void)removeChatModel:(LSChatModel *)chatModel
{
    if (chatModel) {
        for (LSChatModel *model in [self.chatModelList copy]) {
            if (model.timestamp == chatModel.timestamp) {
                [self.chatModelList removeObject:model];
                break;
            }
        }
    }
}

-(void)removeAllChatModel
{
    NSString *path = [JfgCachePathManager cylanDic];
    path = [path stringByAppendingPathComponent:@"chatList.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

@end
