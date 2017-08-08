//
//  DownloadUtils.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DownloadUtils.h"
#import "SRDownloadManager.h"
#import <JFGSDK/JFGSDK.h>

#define eTagUserDefaultKey(fileName)  [NSString stringWithFormat:@"_eTagUserKey_%@",fileName]

void (^downLoadBlock)(DownLoadModel *dlModel);

@interface DownloadUtils()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *duSession;

@property (nonatomic, strong) SRDownloadManager *downLoadManager;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, copy) NSString *eTagString;

@end

@implementation DownloadUtils

NSString *const eTagKey = @"Etag";


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}


#pragma mark public

- (void)checkUrl:(NSString *)url downLoadAction:(downLoadFile)downLoadActionBlock
{
    self.urlString = url;
    
    NSURLSessionTask *task = [self.duSession dataTaskWithURL:[NSURL URLWithString:url]];
    [task resume];
    
    downLoadBlock = [downLoadActionBlock copy];
}

- (void)downloadWithUrl:(NSString *)urlString
            toDirectory:(NSString *)directory
                  state:(void(^)(SRDownloadState state))aState
               progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
             completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
//    SRDownloadManager *downLoadManager = [SRDownloadManager sharedManager];
    self.downLoadManager.downloadedFilesDirectory = directory;
    
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download Url [%@]",urlString]];
    
    [self.downLoadManager downloadFile:[NSURL URLWithString:urlString] state:^(SRDownloadState state) {
        aState(state);
        if (state == SRDownloadStateCompleted)
        {
            [self keeEtagString];
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        if (aProgress)
        {
            aProgress(receivedSize, expectedSize, progress);
        }
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        if (aCompletion != nil)
        {
            aCompletion(isSuccess, filePath, error);
        }
        
        if (isSuccess)
        {
            [self keeEtagString];
        }
    }];
    
}

- (void)setDirectory:(NSString *)dirPath
{
    self.downLoadManager.downloadedFilesDirectory = dirPath;
}

- (BOOL)isDownloadFileCompleted:(NSString *)URLString
{
    if (URLString != nil)
    {
        return [self.downLoadManager isDownloadFileCompleted:[NSURL URLWithString:URLString]];
    }
    return NO;
}

#pragma mark private

- (void)keeEtagString
{
    if (self.eTagString != nil && ![self.eTagString isEqualToString:@""])
    {
        [[NSUserDefaults standardUserDefaults] setValue:self.eTagString forKey:eTagUserDefaultKey([[NSURL URLWithString:self.urlString] lastPathComponent])];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)removeEtagString
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:eTagUserDefaultKey([[NSURL URLWithString:self.urlString] lastPathComponent])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)downLoadAction:(NSHTTPURLResponse *)response state:(downloadState)state
{
    DownLoadModel *dlModel = [[DownLoadModel alloc] init];
    dlModel.dlState = state;
    dlModel.totalSize = [response.allHeaderFields objectForKey:@"Content-Length"];
    
    if (state != downloadStateDownloaded)
    {
        // 需要重新下载，则删除原来的包
        [self.downLoadManager deleteFile:[NSURL URLWithString:self.urlString]];
        [self removeEtagString];
    }
    
    if (downLoadBlock != nil)
    {
        downLoadBlock(dlModel);
    }
}


#pragma mark property
- (NSURLSession *)duSession
{
    if(_duSession == nil)
    {
        _duSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _duSession;
}

- (SRDownloadManager *)downLoadManager
{
    if (_downLoadManager == nil)
    {
        _downLoadManager = [[SRDownloadManager alloc] init];
    }
    return _downLoadManager;
}

#pragma mark delegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    NSUserDefaults *stdDefault = [NSUserDefaults standardUserDefaults];
    NSString *eTag = [stdDefault valueForKey:eTagUserDefaultKey([[NSURL URLWithString:self.urlString] lastPathComponent])];
    self.eTagString = [response.allHeaderFields objectForKey:eTagKey];
    
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"temp Etag[%@]  response Etag[%@]", eTag, self.eTagString]];
    
    if (eTag != nil)
    {
        if (![eTag isEqualToString:[response.allHeaderFields objectForKey:eTagKey]])
        {
            [self downLoadAction:response state:downloadStateReLoad];
        }
        else
        {
            [self downLoadAction:response state:downloadStateDownloaded];
        }
    }
    else
    {
        [self downLoadAction:response state:downloadStateNeedDownload];
    }
}

@end

@implementation DownLoadModel


@end

