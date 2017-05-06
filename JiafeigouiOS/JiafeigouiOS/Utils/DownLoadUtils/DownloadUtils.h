//
//  DownloadUtils.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRDownloadModel.h"

@class DownLoadModel;

typedef NS_ENUM(NSInteger, downloadState) {
    downloadStateDownloaded, //文件 不需要 下载
    downloadStateReLoad, // 文件 需要 重新下载
    downloadStateNeedDownload, // 文件 需要下载
};

typedef void (^downLoadFile)(DownLoadModel *dlModel);





@interface DownloadUtils : NSObject

@property (nonatomic, assign) int pType;

// 检查url，是否需要下载
- (void)checkUrl:(NSString *)url downLoadAction:(downLoadFile)downLoadActionBlock;

- (void)downloadWithUrl:(NSString *)urlString
            toDirectory:(NSString *)directory
                  state:(void(^)(SRDownloadState state))aState
               progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
             completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion;

- (BOOL)isDownloadFileCompleted:(NSString *)URLString;

@end







@interface DownLoadModel : NSObject

@property (nonatomic, assign) NSNumber *totalSize;

@property (nonatomic, assign) downloadState dlState;

@end
