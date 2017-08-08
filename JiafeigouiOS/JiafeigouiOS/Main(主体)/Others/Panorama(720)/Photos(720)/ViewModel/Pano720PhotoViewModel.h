//
//  Pano720PhotoViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/4/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
#import "Pano720PhotoModel.h"
#import "DownloadUtils.h"

typedef NS_ENUM(NSInteger, DeleteModel) {
    DeleteModel_Keep = -1,
    DeleteModel_DeleteAll,
    DeleteModel_Delete
};

@interface Pano720PhotoViewModel : BaseViewModel
@property (nonatomic, assign) FileExistType fileExistType;
@property (nonatomic, copy) NSString *ipAddress;


#pragma mark request data
- (void)requestURL:(NSString *)urlString
        parameters:(id)parameters
          progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
   downloadSuccess:(void (^)(Pano720PhotoModel *dlModel, int result))downloadTask
           success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)requestMoreURL:(NSString *)urlString
            parameters:(id)parameters
              progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
       downloadSuccess:(void (^)(Pano720PhotoModel *dlModel, int result))downloadTask
               success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


- (void)getMoreLocalDataWithBeginTime:(long long)beginTime
                                count:(int)count
                              success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark download
// download image
- (void)downloadImageWithModel:(Pano720PhotoModel *)model
                        state:(void(^)(SRDownloadState state))aState
                     progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                   completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion;

// download video
- (void)downloadVideoWithModel:(Pano720PhotoModel *)model
                         state:(void(^)(SRDownloadState state))aState
                      progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                    completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion;

// download thumbnail in image's and video's
- (void)downloadThumbNailWhithModel:(Pano720PhotoModel *)model
                              state:(void(^)(SRDownloadState state))aState
                           progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                         completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion;

- (BOOL)downloadIsCompleteWithURL:(NSString *)URLString;

#pragma mark delete
// delete file
- (void)deleteFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                 deleteModel:(DeleteModel)delModel
                     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


//delete local file
- (void)deleteLocalFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                      deleteModel:(DeleteModel)delModel
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// delete remote file
- (void)deleteRemoteFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                       deleteModel:(DeleteModel)delModel
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
// delete both file
- (void)deleteBothFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                     deleteModel:(DeleteModel)delModel
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
