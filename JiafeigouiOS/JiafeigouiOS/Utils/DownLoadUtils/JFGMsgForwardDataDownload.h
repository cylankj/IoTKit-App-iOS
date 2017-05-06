//
//  JFGMsgForwardDataDownload.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGMsgRobotForwardDataModel.h"

typedef NS_ENUM(NSInteger,JFGMsgFwDlFailedType){
    
    JFGMsgFwDlFailedTypeNone,//没有错误
    JFGMsgFwDlFailedTypeSockDisconnect,//sock断开
    JFGMsgFwDlFailedTypeInvalidParameter,//无效参数
    JFGMsgFwDlFailedTypeUnKnow,//未知错误
    JFGMsgFwDlFailedTypeDownloading,//当前任务下载中
    JFGMsgFwDlFailedTypeOvertime,
    
};

@protocol JFGMsgForwardDataDownloadDelegate <NSObject>

//下载完成回调
-(void)downloadFinishedForCid:(NSString *)cid fileName:(NSString *)fileName filePath:(NSString *)filePath;

//下载失败回调
-(void)downloadFailedForCid:(NSString *)cid fileName:(NSString *)fileName errorType:(JFGMsgFwDlFailedType)errorType;

@end




@interface JFGMsgForwardDataDownload : NSObject

//当前正在下载的文件内容
@property (nonatomic,readonly)JFGMsgRobotForwardDataModel *currentModel;
//是否正在下载中
@property (nonatomic,readonly)BOOL isDownloading;
//下载回调代理
@property (nonatomic,weak)id <JFGMsgForwardDataDownloadDelegate> delegate;

/*
 开始下载某个文件
 只支持单下载，需要切换下载内容请调用#stopCurrentDownloading
 */
-(JFGMsgFwDlFailedType)downloadMsgForwardDataForCid:(NSString *)cid fileName:(NSString *)fileName md5:(NSString *)md5 fileSize:(int)fileSize;

//停止当前下载
-(void)stopCurrentDownloading;

//下载文件存储路径
-(NSString *)filePathForDownloadFinishedWithCid:(NSString *)cid fileName:(NSString *)fileName;

@end
