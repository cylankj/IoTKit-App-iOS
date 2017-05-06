//
//  Pano720PhotoViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/4/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720PhotoViewModel.h"
#import "JfgHttp.h"
#import "FileManager.h"
#import "JfgTimeFormat.h"
#import "DownloadUtils.h"
#import <JFGSDK/JFGSDK.h>

@interface Pano720PhotoViewModel()<JFGSDKCallbackDelegate>

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) DownloadUtils *downLoadMedia;
@property (nonatomic, strong) DownloadUtils *downloadThumbNail;
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation Pano720PhotoViewModel
NSString *const panoPhotoListKey = @"files";


- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

#pragma mark local or remoto data
// 本地数据
- (NSMutableArray *)localModels
{
    NSMutableArray *localModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *localArr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager jfgPano720PhotoDirPath:self.cid] error:nil]];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"local arr Data %@",localArr]];
    
    NSInteger limit = localArr.count>20?20:localArr.count; // limit 20
    
    for (int i = 0; i < limit; i ++)
    {
        NSString *fileName = [localArr objectAtIndex:i];
        if ([fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".mp4"])
        {
            Pano720PhotoModel *localModel = [[Pano720PhotoModel alloc] init];
            localModel.fileName = [localArr objectAtIndex:i];
            localModel.cid = self.cid;
            localModel.downLoadState = DownLoadStateFinished;
            [localModelArr addObject:localModel];
        }
        
    }
    
    return localModelArr;
}

// 本地 远程 数据
- (NSArray *)remoteLocalModels:(NSArray *)remoteModels
{
    NSArray *resultArr = [[NSMutableArray alloc] init];
    NSMutableArray *unSortedArr = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *localModels = [NSMutableArray arrayWithArray:[self localModels]]; // 本地数据
    NSMutableArray *sameModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    // 遍历 找到 相同 名字的元素
    for (int i = 0; i < remoteModels.count; i ++)
    {
        for (int j = 0; j < localModels.count; j ++)
        {
            Pano720PhotoModel *remoteModel = (Pano720PhotoModel *)[remoteModels objectAtIndex:i];
            Pano720PhotoModel *localModel = (Pano720PhotoModel *)[localModels objectAtIndex:j];
            
            if ([localModel.fileName isEqualToString:remoteModel.fileName])
            {
                [sameModelArr addObject:localModel];
            }
        }
    }
    
    [localModels removeObjectsInArray:sameModelArr];
    [unSortedArr addObjectsFromArray:localModels];
    [unSortedArr addObjectsFromArray:remoteModels];
    
    // 排序 数据处理 挑出时间
    
    return resultArr;
}

- (NSMutableArray *)handleModelData:(NSArray *)dataArr
{
    if (dataArr.count > 0)
    {
        NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:5];
        Pano720PhotoModel *model = [dataArr firstObject];
        
        NSString *aDay = [JfgTimeFormat transToyyyyMMddWithTime:model.fileTime];
        model.headerString = aDay;
        
        for (NSInteger i = 0; i < dataArr.count; i ++)
        {
            Pano720PhotoModel *model = [dataArr objectAtIndex:i];
            NSString *curDay = [JfgTimeFormat transToyyyyMMddWithTime:model.fileTime];
            [sectionArr addObject:model];
            
            if (![aDay isEqualToString:curDay])
            {
                // is aready next model remove lastObject, then add to resultArr
                [sectionArr removeLastObject];
                NSArray *tempSectionArr = [NSArray arrayWithArray:sectionArr];
                [resultArr addObject:tempSectionArr];
                
                [sectionArr removeAllObjects];
                [sectionArr addObject:model];
                
                aDay = curDay;
                model.headerString = curDay;
            }
        }
        if (sectionArr.count > 0)
        {
            [resultArr addObject:sectionArr];
        }
        
        return resultArr;
    }
    
    return nil;
}


#pragma mark
#pragma mark 删除
// delete file
- (void)deleteFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                 deleteModel:(DeleteModel)delModel
                     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    switch (self.fileExistType)
    {
        case FileExistTypeLocal:
        {
            [self deleteLocalFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(task, responseObject);
                    });
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        case FileExistTypeRemote:
        {
            [self deleteRemoteFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(task, responseObject);
                    });
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        case FileExistTypeBoth:
        {
            [self deleteBothFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(task, responseObject);
                    });
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        default:
            break;
    }
}

//delete local file
- (void)deleteLocalFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                      deleteModel:(DeleteModel)delModel
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    switch (delModel)
    {
        case DeleteModel_Keep:
        {
            
        }
            break;
        case DeleteModel_Delete:
        {
            // queue
            dispatch_queue_t serialQueue = dispatch_queue_create("_delete720panoList", DISPATCH_QUEUE_SERIAL);
            
            for (int i = 0; i < models.count; i ++)
            {
                dispatch_async(serialQueue, ^{
                    
                    Pano720PhotoModel *model = (Pano720PhotoModel *)[models objectAtIndex:i];
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"delete Local File %@", model.fileName]];
                    NSString *filePath = [[FileManager jfgPano720PhotoDirPath:self.cid] stringByAppendingPathComponent:model.fileName];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    }
                    
                });
                
                if (i == models.count - 1)
                {
                    if (success)
                    {
                        success(nil,nil);
                    }
                }
            }
            return;
        }
            break;
        case DeleteModel_DeleteAll:
        {
            NSString *fileDirString = [FileManager jfgPano720PhotoDirPath:self.cid];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fileDirString])
            {
                [[NSFileManager defaultManager] removeItemAtPath:fileDirString error:nil];
            }
        }
            break;
        default:
            break;
    }
    
    if (success)
    {
        success(nil,nil);
    }
}

// 删除 设备文件
- (void)deleteRemoteFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                       deleteModel:(DeleteModel)delModel
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    switch (delModel)
    {
        case DeleteModel_Keep:
        {
        }
            break;
        case DeleteModel_DeleteAll:
        {
            NSString *URLString = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=fileDelete&deltype=%ld",self.ipAddress,delModel];
            
            [[JfgHttp sharedHttp] get:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    success(task, responseObject);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        case DeleteModel_Delete:
        {
            NSMutableString *fileNameStr = [NSMutableString string];
            
            for (Pano720PhotoModel *model in models)
            {
                [fileNameStr appendString:[NSString stringWithFormat:@"&filename=%@",model.fileName]];
            }
            
            NSString *URLString = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=fileDelete&deltype=%ld%@",self.ipAddress,delModel, fileNameStr];
            
            [[JfgHttp sharedHttp] get:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    success(task, responseObject);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        default:
            break;
    }
    
    
    
}
//delete both local and remote file
- (void)deleteBothFileWithModels:(NSArray <Pano720PhotoModel *> *)models
                     deleteModel:(DeleteModel)delModel
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self deleteRemoteFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
        [self deleteLocalFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success)
            {
                success(task, responseObject);
            }
        } failure:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


#pragma mark download

- (void)downloadFileWithModel:(Pano720PhotoModel *)model
                        state:(void(^)(SRDownloadState state))aState
                     progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                   completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *desFilePath = [FileManager jfgPano720PhotoDirPath:self.cid];
        NSString *urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
        
        [self.downLoadMedia downloadWithUrl:urlString toDirectory:desFilePath state:^(SRDownloadState state) {
            if (aState)
            {
                aState(state);
            }
        } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
            if (aProgress)
            {
                aProgress(receivedSize, expectedSize, progress);
            }
        } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
            
        }];
        
        
        switch (model.panoFileType)
        {
            case FileTypePhoto:
            {
                
            }
                break;
            case FileTypeVideo:
            {
                NSString *thumbnailName = [model.fileName stringByDeletingPathExtension];
                
                if (thumbnailName != nil && ![thumbnailName isEqualToString:@""])
                {
                    NSString *thumbnailsPath = [FileManager jfgPano720PhotoThumbnailsPath:self.cid];
                    NSString *thumbNailsString = [NSString stringWithFormat:@"http://%@/thumb/%@",self.ipAddress,[NSString stringWithFormat:@"%@.thumb",[model.fileName stringByDeletingPathExtension]]];
                    
                    [self.downloadThumbNail downloadWithUrl:thumbNailsString toDirectory:thumbnailsPath state:^(SRDownloadState state) {
                        if (aState)
                        {
                            aState(state);
                        }
                    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                        if (aProgress)
                        {
                            aProgress(receivedSize, expectedSize, progress);
                        }
                    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
                        
                    }];
                }
                
                
            }
                break;
            default:
                break;
        }
        
        
        
    });
}

#pragma mark request

- (void)requestURL:(NSString *)urlString
        parameters:(id)parameters
          progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
     downloadSuccess:(void (^)(Pano720PhotoModel *dlModel, int result))downloadTask
           success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    self.urlString = urlString;
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:5];
    
    switch (self.fileExistType) {
        case FileExistTypeLocal:
        {
            if (success)
            {
                [models addObjectsFromArray:[self handleModelData:[self localModels]]];
                success(nil, models);
            }
        }
            break;
        case FileExistTypeRemote:
        {
            [[JfgHttp sharedHttp] get:self.urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
                if (responseObject != nil)
                {
                    NSArray *serverArr = [responseObject objectForKey:panoPhotoListKey];
                    
                    for (NSInteger i = 0; i < serverArr.count; i ++)
                    {
                        Pano720PhotoModel *model = [[Pano720PhotoModel alloc] init];
                        model.cid = self.cid;
                        model.fileName = [serverArr objectAtIndex:i];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
                        
                        if (model.downLoadState == DownLoadStateWaitLoad)
                        {
                            [self downloadFileWithModel:model state:^(SRDownloadState state) {
                                switch (state)
                                {
                                    case SRDownloadStateFailed:
                                        
                                        break;
                                    case SRDownloadStateCompleted:
                                    {
                                        model.downLoadState = DownLoadStateFinished;
                                        if (downloadTask)
                                        {
                                            downloadTask(model, 0);
                                        }
                                        
                                    }
                                        break;
                                    default:
                                        break;
                                }
                                
                            } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                                if (aProgress)
                                {
                                    aProgress(receivedSize, expectedSize, progress);
                                }
                            } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
                                
                            }];
                        }
                    }
                    
                    if (success)
                    {
                        success(task, [self handleModelData:models]);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        case FileExistTypeBoth:
        {
            [[JfgHttp sharedHttp] get:self.urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject){
                if (responseObject != nil)
                {
                    NSArray *datas = [responseObject objectForKey:panoPhotoListKey];
                    
                    for (NSInteger i = 0; i < datas.count; i ++)
                    {
                        Pano720PhotoModel *model = [[Pano720PhotoModel alloc] init];
                        model.cid = self.cid;
                        model.fileName = [datas objectAtIndex:i];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
                        
                        if (model.downLoadState == DownLoadStateWaitLoad)
                        {
                            [self downloadFileWithModel:model state:^(SRDownloadState state) {
                                switch (state)
                                {
                                    case SRDownloadStateFailed:
                                        
                                        break;
                                    case SRDownloadStateCompleted:
                                    {
                                        model.downLoadState = DownLoadStateFinished;
                                        if (downloadTask)
                                        {
                                            downloadTask(model, 0);
                                        }
                                    }
                                        break;
                                    default:
                                        break;
                                }
                                
                            } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
                                if (aProgress)
                                {
                                    aProgress(receivedSize, expectedSize, progress);
                                }
                            } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
                                
                            }];
                        }
                    }
                    
                    if (success)
                    {
                        success(task, [self handleModelData:models]);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (failure)
                {
                    failure(task, error);
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)getMoreLocalDataWithBeginTime:(long long)beginTime
                                count:(int)count
                              success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSMutableArray *localModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *localArr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager jfgPano720PhotoDirPath:self.cid] error:nil]];
    int limitCount = 0;
    
    for (int i = 0; i < localArr.count; i ++)
    {
        NSString *fileName = [localArr objectAtIndex:i];
        
        if ([fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".mp4"])
        {
            if (fileName.length >= 10)
            {
                long long modelTime = [[[localArr objectAtIndex:i] substringToIndex:10] longLongValue];
                
                if (beginTime < modelTime)
                {
                    Pano720PhotoModel *localModel = [[Pano720PhotoModel alloc] init];
                    localModel.fileName = [localArr objectAtIndex:i];
                    localModel.cid = self.cid;
                    localModel.downLoadState = DownLoadStateFinished;
                    [localModelArr addObject:localModel];
                    limitCount ++;
                    
                    if (limitCount == count)
                    {
                        success(nil, [self handleModelData:localModelArr]);
                        return;
                    }
                }
            }
        }
    }
    
    if (limitCount < count) // less than count
    {
        success(nil, [self handleModelData:localModelArr]);
    }
    
}

#pragma mark getter
- (void)setFileExistType:(FileExistType)fileExistType
{
    _fileExistType = fileExistType;
}

- (NSMutableArray *)sections
{
    if (_sections == nil)
    {
        _sections = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _sections;
}

- (DownloadUtils *)downLoadMedia
{
    if (_downLoadMedia == nil)
    {
        _downLoadMedia = [[DownloadUtils alloc] init];
        _downLoadMedia.pType = self.pType;
    }
    
    return _downLoadMedia;
}

- (DownloadUtils *)downloadThumbNail
{
    if (_downloadThumbNail == nil)
    {
        _downloadThumbNail = [[DownloadUtils alloc] init];
        _downloadThumbNail.pType = self.pType;
    }
    return _downloadThumbNail;
}

@end
