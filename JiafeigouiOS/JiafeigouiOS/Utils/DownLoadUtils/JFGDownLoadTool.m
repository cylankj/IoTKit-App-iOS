//
//  JFGDownLoadTool.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/31.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGDownLoadTool.h"
#import "JfgGlobal.h"
#import "FileManager.h"
#import "TYDownloadSessionManager.h"
#import "TYDownLoadDataManager.h"

@interface JFGDownLoadTool()

@property (nonatomic, strong) TYDownloadModel *downloadModel;


@end


@implementation JFGDownLoadTool


#pragma mark 公开方法

- (void)downloadWithUrl:(NSString *)urlString
            toDirectory:(NSString *)directory
                  state:(void(^)(JFGDownLoadSate state))aState
               progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, float progress))aProgress
             completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
    
    TYDownloadSessionManager *manager = [TYDownloadSessionManager manager];
//    manager.isBatchDownload = YES;
    manager.maxDownloadCount = 5;
    
    NSArray *downloadArr = [[TYDownloadSessionManager manager] downloadingModels];
    
    for (NSInteger i = 0; i < downloadArr.count; i ++)
    {
        TYDownloadModel *model = [downloadArr objectAtIndex:i];
        JFGLog(@"__downloading model url [%@]",model.downloadURL);
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download URLString [%@]", urlString]];
    // manager里面是否有这个model是正在下载
    self.downloadModel = [manager downLoadingModelForURLString:urlString];
    
    if (self.downloadModel == nil)
    {
        TYDownloadModel *model = [[TYDownloadModel alloc]initWithURLString:urlString filePath:[directory stringByAppendingPathComponent:[[NSURL URLWithString:urlString] lastPathComponent]]];
        self.downloadModel = model;
    }
    
    [manager startWithDownloadModel:self.downloadModel progress:^(TYDownloadProgress *progress) {
        
        if (aProgress)
        {
            aProgress(progress.totalBytesExpectedToWrite, progress.totalBytesWritten, progress.progress);
        }
        
    } state:^(TYDownloadState state, NSString *filePath, NSError *error) {
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"URLString [%@] state changed [%ld]", urlString, state]];
        
        switch (state)
        {
            case TYDownloadStateCompleted:
            {
                if (aState)
                {
                    aState(JFGDownLoadSate_Success);
                }
                
                if (aCompletion)
                {
                    aCompletion(YES, filePath, error);
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"URLString [%@] download success", urlString]];
            }
                break;
            case TYDownloadStateFailed:
            {
                if (aState)
                {
                    aState(JFGDownLoadSate_Failed);
                }
                
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"URLString [%@] download failed", urlString]];
            }
                break;
            default:
                break;
        }
        
    }];
}

- (void)suspendWithDownloadModel:(NSString *)urlString
{
    TYDownloadSessionManager *manager = [TYDownloadSessionManager manager];
    TYDownloadModel *download = [manager downLoadingModelForURLString:urlString];
    [manager suspendWithDownloadModel:download];
}

- (BOOL)fileIsDownLoadComplete:(NSString *)urlString destinationDir:(NSString *)desDir
{
    TYDownloadSessionManager *manager = [TYDownloadSessionManager manager];
    TYDownloadModel *model = [manager downLoadingModelForURLString:urlString];
    
    if (model == nil)
    {
        model = [[TYDownloadModel alloc] initWithURLString:urlString filePath:[desDir stringByAppendingPathComponent:[[NSURL URLWithString:urlString] lastPathComponent]]];
    }
    
    return [manager isDownloadCompletedWithDownloadModel:model];
}

- (NSMutableArray *)downloadingModels
{
    return [[TYDownloadSessionManager manager] downloadingModels];
}
#pragma  私有方法




@end
