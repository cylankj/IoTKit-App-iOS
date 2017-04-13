//
//  Pano720PhotoViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
#import "Pano720Socket.h"
#import "Pano720PhotoModel.h"

@protocol Pano720PhotoDelegate <NSObject>

@optional

// 原始 数据
- (void)unHandledPhotoList:(NSArray *)photoList;

// 更新数据
- (void)updateDownloadedList:(NSArray <Pano720PhotoModel*>*)downloadedModel;

@end


typedef NS_ENUM(NSInteger, FileExistType) {
    FileExistTypeLocal,                 //本地 有
    FileExistTypeRemote,                //远程 有
    FileExistTypeBoth     //本地，远程 都有
};

@interface Pano720PhotoViewModel : BaseViewModel

@property (nonatomic, assign) id<Pano720PhotoDelegate> delegate;

@property (nonatomic, assign) FileExistType fileExistType;

// 获取 照片列表
- (void)getPhotoListBeginTime:(int)beginTime endTime:(int)endTime count:(int)count;

@end
