//
//  Pano720PhotoViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720PhotoViewModel.h"
#import "Pano720PhotoModel.h"
#import "FileManager.h"
#import <JFGSDK/JFGSDK.h>
#import "JFGMsgForwardDataDownload.h"
#import "FileManager.h"
#import "JfgGlobal.h"

@interface Pano720PhotoViewModel()<JFGSDKCallbackDelegate, Pano720SocketDelegate, JFGMsgForwardDataDownloadDelegate>

@property (nonatomic, strong) NSMutableArray *groupArray;

@property (nonatomic, assign) int beginTime;
@property (nonatomic, assign) int entTime;
@property (nonatomic, assign) int maxCount; //请求最多条数

@property (nonatomic, strong) JFGMsgForwardDataDownload *panoDownLoad;

@end

@implementation Pano720PhotoViewModel

- (void)dealloc
{
    [JFGSDK removeDelegate:self];
    [[Pano720Socket sharedSocket] removeDelegate:self];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [JFGSDK addDelegate:self];
        [[Pano720Socket sharedSocket] addDelegate:self];
    }
    
    return self;
}

#pragma mark
#pragma mark action
// 根据 名字 获取 Model
- (Pano720PhotoModel *)modelByFileName:(NSString *)fileName
{
    for (NSInteger i = 0; i < self.groupArray.count ; i ++)
    {
        Pano720PhotoModel *model = [self.groupArray objectAtIndex:i];
        if ([fileName isEqualToString:model.fileName])
        {
            return model;
        }
    }
    
    return nil;
}

// 本地数据
- (NSMutableArray *)localModels
{
    NSMutableArray *localModelArr = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSArray *localArr = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FileManager jfgPano720PhotoDirPath:self.cid] error:nil]];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"local arr Data %@",localArr]];
    
    for (int i = 0; i < localArr.count; i ++)
    {
        Pano720PhotoModel *localModel = [[Pano720PhotoModel alloc] init];
        localModel.fileName = [localArr objectAtIndex:i];
        localModel.filePath = [[FileManager jfgPano720PhotoDirPath:self.cid] stringByAppendingPathComponent:[localArr objectAtIndex:i]];
        localModel.downLoadState = DownLoadStateFinished;
        localModel.fileType = [[localArr objectAtIndex:i] hasSuffix:@"jpg"]?FileTypePhoto:FileTypeVideo;
        [localModelArr addObject:localModel];
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
            
            JFGLog(@"localModel name:%@  remoteModel name:%@",localModel.fileName, remoteModel.fileName);
            
            if ([localModel.fileName isEqualToString:remoteModel.fileName])
            {
                [sameModelArr addObject:localModel];
            }
        }
    }
    
    [localModels removeObjectsInArray:sameModelArr];
    [unSortedArr addObjectsFromArray:localModels];
    [unSortedArr addObjectsFromArray:remoteModels];
    
    // 排序
    
    return resultArr;
}



#pragma mark
#pragma mark 私有 接口
- (void)downLoadWithModel:(Pano720PhotoModel *)model
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download fileName %@",model.fileName]];
    [self.panoDownLoad downloadMsgForwardDataForCid:self.cid fileName:model.fileName md5:model.MD5 fileSize:model.fileZise];
}

#pragma mark
#pragma mark 公开 接口
// 获取 照片列表
- (void)getPhotoListBeginTime:(int)beginTime endTime:(int)endTime count:(int)count
{
    switch (self.fileExistType) {
        case FileExistTypeLocal:
        {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(unHandledPhotoList:)])
            {
                [self.delegate unHandledPhotoList:[self localModels]];
            }
        }
            break;
        case FileExistTypeRemote:
        case FileExistTypeBoth:
        {
            self.beginTime = beginTime;
            self.entTime = endTime;
            self.maxCount = count;
            
            [JFGSDK fping:@"255.255.255.255"];
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark downLoad Delegate
- (void)downloadFinishedForCid:(NSString *)cid fileName:(NSString *)fileName filePath:(NSString *)filePath
{
    if ([self.cid isEqualToString:cid])
    {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"finished fileName  %@", filePath]];
        Pano720PhotoModel *model = [self modelByFileName:fileName];
        model.filePath = filePath;
        model.downLoadState = DownLoadStateFinished;
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(updateDownloadedList:)])
        {
            [_delegate updateDownloadedList:self.groupArray];
        }
        
        for (Pano720PhotoModel *model in self.groupArray)
        {
            if (model.downLoadState == DownLoadStateWaitLoad)
            {
                model.downLoadState = DownLoadStateRunning;
                [self downLoadWithModel:model];
                
                break;
            }
        }
        
    }
}

#pragma mark
#pragma mark socket Delegate
-(void)receivePanoDataMsgID:(NSString *)msgID sequence:(uint64_t)mSeq cid:(NSString *)cid reponseType:(int)reponseType msgContent:(id)msgContent
{
    if ([msgContent isKindOfClass:[NSArray class]])
    {
        if ([(NSArray *)msgContent count] > 0)
        {
            switch (reponseType)
            {
                case JfgPanoMsgType_LIST_RSP:
                {
                    NSArray *groupArr = [msgContent objectAtIndex:0];
                    
                    for (NSInteger i = 0; i < groupArr.count; i ++)
                    {
                        NSArray *rowArr = [groupArr objectAtIndex:i];
                        
                        Pano720PhotoModel *photoModel = [[Pano720PhotoModel alloc] init];
                        photoModel.cid =  self.cid;
                        photoModel.fileName = [rowArr objectAtIndex:0];
                        photoModel.fileZise = [[rowArr objectAtIndex:1] intValue];
                        photoModel.MD5 = [rowArr objectAtIndex:2];
                        [self.groupArray addObject:photoModel];
                    }
                    
                    
                    if (self.groupArray.count > 0)
                    {
                        Pano720PhotoModel *model = (Pano720PhotoModel *)[self.groupArray firstObject];
                        [self downLoadWithModel:model];
                    }
                    
                    switch (self.fileExistType)
                    {
                        case FileExistTypeBoth:
                        {
                            if (self.delegate && [self.delegate respondsToSelector:@selector(unHandledPhotoList:)])
                            {
                                [self.delegate unHandledPhotoList:[self remoteLocalModels:self.groupArray]];
                            }
                            
                        }
                            break;
                        case FileExistTypeRemote:
                        {
                            if (self.delegate && [self.delegate respondsToSelector:@selector(unHandledPhotoList:)])
                            {
                                [self.delegate unHandledPhotoList:self.groupArray];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
            
            
        }
    }
}

- (void)downloadFailedForCid:(NSString *)cid fileName:(NSString *)fileName errorType:(JFGMsgFwDlFailedType)errorType
{
    
}

- (void)panoConnectted
{
    [[Pano720Socket sharedSocket] sendMsgWithCids:@[self.cid] isCallBack:YES requestType:JfgPanoMsgType_LIST_REQ requestData:@[@(self.beginTime),@(self.entTime),@(self.maxCount)]];
}

- (void)panoDisconnectted
{
    
}

#pragma mark
#pragma mark JFGSDK Delegate
- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([self.cid isEqualToString:ask.cid])
    {
        [[Pano720Socket sharedSocket] panoConnectIp:ask.address port:ask.port autoConnect:YES];
    }
}


#pragma mark
#pragma mark getter
- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

- (JFGMsgForwardDataDownload *)panoDownLoad
{
    if (_panoDownLoad == nil)
    {
        _panoDownLoad = [[JFGMsgForwardDataDownload alloc] init];
        _panoDownLoad.delegate = self;
    }
    
    return _panoDownLoad;
}

@end
