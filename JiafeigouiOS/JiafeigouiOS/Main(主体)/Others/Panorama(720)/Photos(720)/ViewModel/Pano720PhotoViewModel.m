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
#import "JfgGlobal.h"
#import "JfgConfig.h"
#import "JFGDownLoadTool.h"
#import <JFGSDK/JFGSDK.h>

#define maxCount 20

@interface Pano720PhotoViewModel()<JFGSDKCallbackDelegate>

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) DownloadUtils *downLoadMedia;
@property (nonatomic, strong) DownloadUtils *downloadThumbNail;
@property (nonatomic, strong) JFGDownLoadTool *downloadTool;

@property (nonatomic, strong) NSMutableArray *downloadArr;

@property (nonatomic, strong) NSMutableArray *remoteArray;
@property (nonatomic, strong) NSMutableArray *localArray;

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
    
    NSInteger limit = localArr.count>20?localArr.count - 20:0; // limit 20
    
    for (NSInteger i = localArr.count - 1; i >= limit; i --)
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
    
    [self.localArray removeAllObjects];
    [self.localArray addObjectsFromArray:localModelArr];
    
    return localModelArr;
}

- (NSMutableArray *)getMoreLocalModels:(long long)beginTime count:(int)count
{
    NSMutableArray *localModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *localArr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager jfgPano720PhotoDirPath:self.cid] error:nil]];
    int limitCount = 0;
    
    for (NSInteger i = localArr.count - 1; i >= 0 ; i --)
    {
        NSString *fileName = [localArr objectAtIndex:i];
        
        if ([fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".mp4"])
        {
            if (fileName.length >= 10)
            {
                long long modelTime = [[[localArr objectAtIndex:i] substringToIndex:10] longLongValue];
                
                if (beginTime > modelTime)
                {
                    Pano720PhotoModel *localModel = [[Pano720PhotoModel alloc] init];
                    localModel.fileName = [localArr objectAtIndex:i];
                    localModel.cid = self.cid;
                    localModel.downLoadState = DownLoadStateFinished;
                    [localModelArr addObject:localModel];
                    limitCount ++;
                    
                    if (limitCount == count)
                    {
                        return localModelArr;
                    }
                }
            }
        }
    }
    
    if (limitCount < count) // less than count
    {
        return localModelArr;
    }
    
    return nil;
}
#pragma mark
// 本地 远程 数据
- (NSArray *)handleRemoteModels:(NSMutableArray *)remoteModels localModels:(NSMutableArray *)localModels
{
    NSMutableArray *resultArr = nil;
    NSMutableArray *unSortedArr = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *sameModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    // 遍历 找到 相同 名字的元素
    for (int i = 0; i < remoteModels.count; i ++)
    {
        Pano720PhotoModel *remoteModel = (Pano720PhotoModel *)[remoteModels objectAtIndex:i];
        remoteModel.location = fileInRemote;
        
        for (int j = 0; j < localModels.count; j ++)
        {
            Pano720PhotoModel *localModel = (Pano720PhotoModel *)[localModels objectAtIndex:j];
            localModel.location = fileInLocal;
            
            if ([localModel.fileName isEqualToString:remoteModel.fileName])
            {
                remoteModel.location = fileInBoth;
                [sameModelArr addObject:localModel];
                
                goto continueLabel; // 结束当前循环，进入下一个循环
            }
        }
        continueLabel: continue;
    }
    
    [localModels removeObjectsInArray:sameModelArr];
    [unSortedArr addObjectsFromArray:localModels];
    [unSortedArr addObjectsFromArray:remoteModels];
    
    // 排序 数据处理 挑出时间
    NSArray *sortArr = [unSortedArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        Pano720PhotoModel *model1 = obj1;
        Pano720PhotoModel *model2 = obj2;
        
        return [model2.fileName compare:model1.fileName];
    }];
    
    resultArr = [NSMutableArray arrayWithArray:sortArr];
    
    if (resultArr.count > maxCount)
    {
        [resultArr removeObjectsInRange:NSMakeRange(maxCount+1, resultArr.count - maxCount - 1 )];
    }
    
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

- (NSArray *)deleteModelsWithoutKeep:(NSArray *)keepModels
{
    NSMutableArray *localModelArr = [self localModels];
    
    for (int i = 0; i < localModelArr.count; i ++)
    {
        Pano720PhotoModel *localModel = [localModelArr objectAtIndex:i];
        
        for (int j = 0; j < keepModels.count; j ++)
        {
            Pano720PhotoModel *keepModel = [keepModels objectAtIndex:j];
            
            if ([keepModel.fileName isEqualToString:localModel.fileName])
            {
                [localModelArr removeObject:localModel];
            }
        }
    }

    return localModelArr;
}

- (long long)beginTimeFromUrl:(NSString *)urlStr
{
    
    NSArray *urlElements = [urlStr componentsSeparatedByString:@"&"];
    
    for (NSInteger i = 0; i < urlElements.count; i ++)
    {
        NSString *argumentStr = [urlElements objectAtIndex:i];
        
        if ([argumentStr containsString:@"="])
        {
            NSArray *arguments = [argumentStr componentsSeparatedByString:@"="];
            
            if (arguments.count > 0)
            {
                NSString *argumentKey = [arguments objectAtIndex:0];
                
                if ([argumentKey isEqualToString:@"endtime"])
                {
                    return [[arguments objectAtIndex:1] longLongValue];
                }
            }
        }
        
    }
    
    
    return 0;
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
            NSArray *localFileArr = [self deleteModelsWithoutKeep:models];
            
            for (int i = 0; i < localFileArr.count; i ++)
            {
                Pano720PhotoModel *model = (Pano720PhotoModel *)[localFileArr objectAtIndex:i];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"delete Local File %@", model.fileName]];
                NSString *filePath = [[FileManager jfgPano720PhotoDirPath:self.cid] stringByAppendingPathComponent:model.fileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                
                if (i == localFileArr.count - 1)
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
            NSMutableString *fileNameStr = [NSMutableString string];
            
//            NSArray *deleteArr = [self deleteModelsWithoutKeep:models];
            
            for (Pano720PhotoModel *model in models)
            {
                [fileNameStr appendString:[NSString stringWithFormat:@"&filename=%@",model.fileName]];
            }
            
            NSString *URLString = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=fileDelete&enwarn=0&deltype=%ld%@",self.ipAddress,delModel, fileNameStr];
            
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
        case DeleteModel_DeleteAll:
        {
            NSString *URLString = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=fileDelete&enwarn=0&deltype=%ld",self.ipAddress,delModel];
            
            [[JfgHttp sharedHttp] get:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if (success)
                {
                    success(task, responseObject);
                    [[NSNotificationCenter defaultCenter] postNotificationName:JFG720DevDelAllPhotoNotificationKey object:nil];
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
            
            NSString *URLString = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=fileDelete&enwarn=0&deltype=%ld%@",self.ipAddress,delModel, fileNameStr];
            
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
    JFG_WS(weakSelf);
    
    [self deleteRemoteFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf deleteLocalFileWithModels:models deleteModel:delModel success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success)
            {
                success(task, responseObject);
            }
        } failure:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}


#pragma mark download

- (void)downloadImageWithModel:(Pano720PhotoModel *)model
                        state:(void(^)(SRDownloadState state))aState
                     progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                   completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        switch (model.panoFileType)
        {
            case FileTypePhoto:
            {
                
                NSString *desFilePath = [FileManager jfgPano720PhotoDirPath:self.cid];
                NSString *urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                
                
                
                /*
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
                */
                
                [self.downloadTool downloadWithUrl:urlString toDirectory:desFilePath state:^(JFGDownLoadSate state) {
                    
                    switch (state)
                    {
                        case JFGDownLoadSate_Success:
                        {
                            if (aState)
                            {
                                aState(SRDownloadStateCompleted);
                            }
                        }
                            break;
                            
                        case JFGDownLoadSate_None:
                        case JFGDownLoadSate_Failed:
                        {
                            if (aState)
                            {
                                aState(SRDownloadStateFailed);
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    
                } progress:^(NSInteger receivedSize, NSInteger expectedSize, float progress) {
                    if (aProgress)
                    {
                        aProgress(receivedSize, expectedSize, progress);
                    }
                    
                    JFGLog(@"download image progress %f", progress);
                } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
                }];
                
            }
                break;
            case FileTypeVideo:
            {
                
            }
                break;
            default:
                break;
        }
    });
}

- (void)downloadVideoWithModel:(Pano720PhotoModel *)model
                        state:(void(^)(SRDownloadState state))aState
                     progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                   completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        switch (model.panoFileType)
        {
            case FileTypePhoto:
            {
                
            }
                break;
            case FileTypeVideo:
            {
                NSString *desFilePath = [FileManager jfgPano720PhotoDirPath:self.cid];
                NSString *urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                
                [self.downloadTool downloadWithUrl:urlString toDirectory:desFilePath state:^(JFGDownLoadSate state) {
                    if (aState)
                    {
                 
                        aState(SRDownloadStateCompleted);
                    }
                } progress:^(NSInteger receivedSize, NSInteger expectedSize, float progress) {
                    if (aProgress)
                    {
                        aProgress(receivedSize, expectedSize, progress);
                    }
                } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
                    
                }];
                
                
                /*
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
                */
            }
                break;
            default:
                break;
        }
    });
    
    /*
    NSString *desFilePath = [FileManager jfgPano720PhotoDirPath:self.cid];
    
    // http://yf.cylan.com.cn:82/Garfield/cylan/iOS/2017052720-318/JiaFeiGou%28cylan%29-3.2.0.318-2017052720-%28test1.jfgou.com%29-Inhouse.ipa
    //[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]
    NSString *urlString = @"http://yf.cylan.com.cn:82/Garfield/cylan/iOS/2017052720-318/JiaFeiGou%28cylan%29-3.2.0.318-2017052720-%28test1.jfgou.com%29-Inhouse.ipa";
    
    [self.downloadTool downloadWithUrl:urlString toDirectory:desFilePath state:^(JFGDownLoadSate state) {
        if (aState)
        {
            aState(SRDownloadStateCompleted);
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, float progress) {
        if (aProgress)
        {
            aProgress(receivedSize, expectedSize, progress);
        }
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        
    }];
    */
}

- (void)downloadThumbNailWhithModel:(Pano720PhotoModel *)model
                              state:(void(^)(SRDownloadState state))aState
                           progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
                         completion:(void(^)(BOOL isSuccess, NSString *filePath, NSError *error))aCompletion
{
    NSString *thumbnailName = [model.fileName stringByDeletingPathExtension];
    
    if (thumbnailName != nil && ![thumbnailName isEqualToString:@""])
    {
        NSString *thumbnailsPath = [FileManager jfgPano720PhotoThumbnailsPath:self.cid];
        NSString *thumbNailsString = [NSString stringWithFormat:@"http://%@/thumb/%@",self.ipAddress,[NSString stringWithFormat:@"%@.thumb",[model.fileName stringByDeletingPathExtension]]];
        
        [self.downloadTool downloadWithUrl:thumbNailsString toDirectory:thumbnailsPath state:^(JFGDownLoadSate state) {
            if (aState)
            {
                aState(SRDownloadStateCompleted);
            }
        } progress:^(NSInteger receivedSize, NSInteger expectedSize, float progress) {
            if (aProgress)
            {
                aProgress(receivedSize, expectedSize, progress);
            }
        } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
            
        }];
        
        /*
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
            if (aCompletion)
            {
                aCompletion(isSuccess, filePath, error);
            }
        }];
         */
    }
}

- (BOOL)downloadIsCompleteWithURL:(NSString *)URLString
{
    
    return NO;
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
                        model.urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
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
                        model.urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
                        
                    }
                    
                    if (success)
                    {
                        NSArray *handleMixedData = [self handleRemoteModels:models localModels:[self localModels]];
                        NSArray *handleTimeData = [self handleModelData:handleMixedData];
                        
                        success(task, [NSMutableArray arrayWithArray:handleTimeData]);
                    }
                    
                    [self.remoteArray removeAllObjects];
                    [self.remoteArray addObjectsFromArray:models];
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

- (void)requestMoreURL:(NSString *)urlString
            parameters:(id)parameters
              progress:(void (^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))aProgress
       downloadSuccess:(void (^)(Pano720PhotoModel *dlModel, int result))downloadTask
               success:(void (^)(NSURLSessionDataTask *task, NSMutableArray <Pano720PhotoModel *> *models))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    self.urlString = urlString;
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:5];
    JFG_WS(weakSelf);

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
                        model.urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
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
                        model.urlString = [NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName];
                        model.downLoadState = [self.downLoadMedia isDownloadFileCompleted:[NSString stringWithFormat:@"http://%@/images/%@",self.ipAddress,model.fileName]]?DownLoadStateFinished:DownLoadStateWaitLoad;
                        [models addObject:model];
                        
                    }
                    
                    if (success)
                    {
                        long long beginTime = [weakSelf beginTimeFromUrl:weakSelf.urlString];
                        
                        NSArray *handleMixedData = [weakSelf handleRemoteModels:models localModels:[weakSelf getMoreLocalModels:beginTime count:maxCount]];

                        success(task, [weakSelf handleModelData:handleMixedData]);
                        
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
    /*NSMutableArray *localModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *localArr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager jfgPano720PhotoDirPath:self.cid] error:nil]];
    int limitCount = 0;
    
    for (NSInteger i = localArr.count - 1; i >= 0 ; i --)
    {
        NSString *fileName = [localArr objectAtIndex:i];
        
        if ([fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".mp4"])
        {
            if (fileName.length >= 10)
            {
                long long modelTime = [[[localArr objectAtIndex:i] substringToIndex:10] longLongValue];
                
                if (beginTime > modelTime)
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
    }*/
    NSArray *localArr = [self getMoreLocalModels:beginTime count:count];
    
    if (success)
    {
        success(nil, [self handleModelData:localArr]);
    }
}

#pragma mark getter
- (void)setFileExistType:(FileExistType)fileExistType
{
    _fileExistType = fileExistType;
}

- (JFGDownLoadTool *)downloadTool
{
    if (_downloadTool == nil)
    {
        _downloadTool = [[JFGDownLoadTool alloc] init];
    }
    return _downloadTool;
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

- (NSMutableArray *)remoteArray
{
    if (_remoteArray == nil)
    {
        _remoteArray = [[NSMutableArray alloc] init];
    }
    return _remoteArray;
}

- (NSMutableArray *)localArray
{
    if (_localArray == nil)
    {
        _localArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _localArray;
}

@end
