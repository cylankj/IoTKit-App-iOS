//
//  JFGDownLoadTool.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/31.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFGDownLoadSate) {
    JFGDownLoadSate_None,               // 未下载， 下载删除了
    JFGDownLoadSate_Ready,              // 准备下载
    JFGDownLoadSate_Running,            // 正在下载
    JFGDownLoadSate_Suspend,            // 暂停
    JFGDownLoadSate_Success,            // 完成
    JFGDownLoadSate_Failed,             // 失败
};


@interface JFGDownLoadTool : NSObject

- (void)downloadWithUrl:(NSString *)urlString
            toDirectory:(NSString *)directory
                  state:(void(^)(JFGDownLoadSate state))aState
               progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, float progress))aProgress
             completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion;

- (void)suspendWithDownloadModel:(NSString *)urlString;

- (BOOL)fileIsDownLoadComplete:(NSString *)urlString destinationDir:(NSString *)desDir;


- (NSMutableArray *)downloadingModels;

@end
