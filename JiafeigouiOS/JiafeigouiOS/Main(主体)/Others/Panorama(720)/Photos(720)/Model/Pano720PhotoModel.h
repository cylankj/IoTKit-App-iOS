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

@interface Pano720PhotoModel : BaseModel

@property (nonatomic, copy) NSString *fileName; // 文件名
@property (nonatomic, assign) FileType fileType;     // 文件类型
@property (nonatomic, copy) NSString *MD5;
@property (nonatomic, assign) int fileZise; // 总大小 字节
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) DownLoadState downLoadState;
@end
