//
//  Pano720PhotoModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//


#import "BaseModel.h"

typedef NS_ENUM(NSInteger, FileType) {
    FileTypePhoto,
    FileTypeVideo
};

typedef NS_ENUM(NSInteger, DownLoadState)
{
    DownLoadStateWaitLoad, // 等待下载
    DownLoadStateRunning,
    DownLoadStateFinished,
    DownLoadStateFailed,
};

typedef NS_ENUM(NSInteger, fileLocaiton) {
    fileInLocal,
    fileInRemote,
    fileInBoth
};

@interface Pano720PhotoModel : BaseModel

@property (nonatomic, copy) NSString *fileName; // 文件名
@property (nonatomic, assign, readonly) FileType panoFileType;     // 文件类型

@property (nonatomic, copy) NSString *urlString; // file url
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) NSString *thumbNailFilePath; // thumbNail

@property (nonatomic, assign) DownLoadState downLoadState;
@property (nonatomic, assign) long long  fileTime;
@property (nonatomic, copy, readonly) NSString *videoDurationStr;
@property (nonatomic, copy) NSString *headerString;

@property (nonatomic, copy) NSString *downloadProgressStr;

@property (nonatomic, assign) fileLocaiton location;
@end
