//
//  JFGLogUploadManager.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/4/20.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,JFGLogUploadErrorType){
    JFGLogUploadErrorTypeUploading,//上传中...
    JFGLogUploadErrorTypeEarly,//时间间隔太近
    JFGLogUploadErrorTypeUnKnow,//未知原因
};

@protocol JFGLogUploadManagerDelegate <NSObject>

-(void)logUploadSuccessForTimestamp:(uint64_t)timestamp;
-(void)logUploadFailedForTimestamp:(uint64_t)timestamp errorType:(JFGLogUploadErrorType)errorType;


@end

@interface JFGLogUploadManager : NSObject

@property (nonatomic,readonly)BOOL isUploading;//是否有日志在上传
@property (nonatomic,readonly)uint64_t curTimestamp;//正在上传的日志时间戳
@property (nonatomic,readonly)NSMutableArray <NSNumber *>*uploadSuccessList;//上传成功日志时间戳列表
@property (nonatomic,readonly)NSMutableArray <NSNumber *>*uploadFailedList;

+(instancetype)shareLogUpload;
-(void)addDelegate:(id<JFGLogUploadManagerDelegate>)delegate;
-(BOOL)uploadLogFileForTimestamp:(uint64_t)timestamp;

@end
