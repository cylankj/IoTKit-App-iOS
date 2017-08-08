//
//  JFGMsgForwardDataDownload.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGMsgForwardDataDownload.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKSock.h>
#import <JFGSDK/MPMessagePackReader.h>
#import <JFGSDK/MPMessagePackWriter.h>
#import "JfgGlobal.h"
#import "FileManager.h"

@interface JFGMsgForwardDataDownload()<JFGSDKSockCBDelegate,JFGSDKCallbackDelegate>
{
    JFGMsgRobotForwardDataModel *currentModel2;
    BOOL isDownloading;
}

@property (nonatomic,strong)JFGMsgRobotForwardDataModel *currentModel;
@property (nonatomic,assign)BOOL isDownloading;

@end

@implementation JFGMsgForwardDataDownload

@synthesize isDownloading = _isDownloading;

-(instancetype)init
{
    self = [super init];
    isDownloading = NO;
    [self addNotification];
    return self;
}

-(void)addNotification
{
    [JFGSDK addDelegate:self];
    [[JFGSDKSock sharedClient] addDelegate:self];
}



-(JFGMsgFwDlFailedType)downloadMsgForwardDataForCid:(NSString *)cid fileName:(NSString *)fileName md5:(NSString *)md5 fileSize:(int)fileSize
{
    if (isDownloading) {
        return JFGMsgFwDlFailedTypeDownloading;
    }
    
    if (!cid || fileSize <=0 || !fileName || !md5) {
        return JFGMsgFwDlFailedTypeInvalidParameter;
    }
    
    NSData *fiata = [NSData dataWithContentsOfFile:[self msgForwardDataFilePathForFileName:fileName cid:cid]];
    NSMutableData *fileData = [[NSMutableData alloc]init];
    if (fiata && fiata.length > 0) {
        fileData = [[NSMutableData alloc]initWithData:fiata];
    }
    
   
    
    if (self.currentModel) {
        if ([self.currentModel.cid isEqualToString:cid] && [self.currentModel.fileName isEqualToString:fileName]) {
            
            if (isDownloading) {
                return JFGMsgFwDlFailedTypeDownloading;
            }
            
        }else{
            
            currentModel2 = [[JFGMsgRobotForwardDataModel alloc]init];
            currentModel2.cid = self.currentModel.cid;
            currentModel2.fileName = self.currentModel.fileName;
            currentModel2.fileSize = self.currentModel.fileSize;
            currentModel2.fileData = self.currentModel.fileData;
            currentModel2.currentFileLength =  self.currentModel.currentFileLength;
            currentModel2.md5 = self.currentModel.md5;
            
            self.currentModel.cid = cid;
            self.currentModel.fileName = fileName;
            self.currentModel.fileSize = fileSize;
            self.currentModel.fileData = fileData;
            self.currentModel.md5 = md5;
            self.currentModel.currentFileLength = fileData.length;
        }
    }else{
        
        self.currentModel = [[JFGMsgRobotForwardDataModel alloc]init];
        self.currentModel.cid = cid;
        self.currentModel.fileName = fileName;
        self.currentModel.fileSize = fileSize;
        self.currentModel.fileData = fileData;
        self.currentModel.md5 = md5;
        self.currentModel.currentFileLength = fileData.length;
        
    }
    
    if (fiata && fiata.length >= fileSize) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFinishedForCid:fileName:filePath:)]) {
            [self.delegate downloadFinishedForCid:self.currentModel.cid fileName:self.currentModel.fileName filePath:[self msgForwardDataFilePathForFileName:fileName cid:cid]];
            return JFGMsgFwDlFailedTypeNone;
        }
    }
    
    NSData *reqData = [MPMessagePackWriter writeObject:@[self.currentModel.fileName,self.currentModel.md5,@(self.currentModel.fileData.length),@(50*1024)] error:nil];
    if ([JFGSDKSock sharedClient].isConnected) {
        [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.currentModel.cid] isAck:YES fileType:1 msg:reqData];
    }else{
        [JFGSDK sendMsgForTcpWithDst:@[self.currentModel.cid] isAck:YES fileType:1 msg:reqData];
    }
    isDownloading = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqOvertime) object:nil];
    [self performSelector:@selector(reqOvertime) withObject:nil afterDelay:30];
    
    return JFGMsgFwDlFailedTypeNone;
}

-(void)stopCurrentDownloading
{
    isDownloading = NO;
    self.currentModel.fileName = @"";
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqOvertime) object:nil];
}

-(void)jfgSockConnect
{
    
}

-(void)jfgSockDisconnect
{

}

-(void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                             mSeq:(uint64_t)mSeq
                                              cid:(NSString *)cid
                                             type:(int)type
                                     isInitiative:(BOOL)initiative
                                          msgData:(NSData *)msgData
{
    if (type == 2) {
        [self robotForwardDataDealForCid:cid msgData:msgData];
    }
}

-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type msgData:(NSData *)msgData
{
    if (type == 2) {
        [self robotForwardDataDealForCid:cid msgData:msgData];
    }
}

-(void)robotForwardDataDealForCid:(NSString *)cid msgData:(NSData *)msgData
{
    /*
     int，     ret       错误码
     string，  fileName  文件名, 注：根据后缀区分是图片或视频
     int，     begin     起始位置
     int，     offset    偏移量
     byte[],   buffer    文件内容
     */
    JFGMsgRobotForwardDataModel *tempModel = nil;
    if ([self.currentModel.cid isEqualToString:cid]) {
        tempModel = self.currentModel;
    }else if ([currentModel2.cid isEqualToString:cid]){
        tempModel = currentModel2;
    }
    if (!tempModel) {
        return;
    }
    
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count >= 5) {
            
            id obj1 = sourceArr[0];
            id obj2 = sourceArr[1];
            id obj3 = sourceArr[2];
            id obj4 = sourceArr[3];
            id obj5 = sourceArr[4];
            if ([obj1 isKindOfClass:[NSNumber class]]) {
                
                int ret = [obj1 intValue];
                if (ret == 0) {
                   //成功
                    NSString *fileName = @"";
                    int begin = 0;
                    int offset = 0;
                    if ([obj2 isKindOfClass:[NSString class]]) {
                        fileName  = obj2;
                    }
                    if ([obj3 isKindOfClass:[NSNumber class]]) {
                        begin = [obj3 intValue];
                    }
                    if ([obj4 isKindOfClass:[NSNumber class]]) {
                        offset = [obj4 intValue];
                    }
                    
                    JFGMsgRobotForwardDataModel *temp = nil;
                    if ([self.currentModel.cid isEqualToString:cid] && [self.currentModel.fileName isEqualToString:fileName]) {
                        temp = self.currentModel;
                       
                    }
                    
                    if (currentModel2 && [currentModel2.cid isEqualToString:cid] && [currentModel2.fileName isEqualToString:fileName]) {
                        temp = currentModel2;
                    }
                    
                    NSData *data = obj5;
                    
                    if (temp) {
                        
                        
                        NSData *fiata = [NSData dataWithContentsOfFile:[self msgForwardDataFilePathForFileName:fileName cid:cid]];
                        if (fiata.length > temp.fileData.length) {
                            temp.fileData = [[NSMutableData alloc]initWithData:fiata];
                        }
                        
                        if (data && data.length > 0) {
                            [temp.fileData appendData:data];
                            [temp.fileData writeToFile:[self msgForwardDataFilePathForFileName:temp.fileName cid:temp.cid] atomically:YES];
                        }

                        NSLog(@"[reciverLength:%lu fileSize:%d]",(unsigned long)temp.fileData.length,temp.fileSize);
                        
                        if (temp.fileData.length >= temp.fileSize) {
                            
                            isDownloading = NO;
                            JFGLog(@"下载完成");
                            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqOvertime) object:nil];
                            if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFinishedForCid:fileName:filePath:)]) {
                                
                                [self.delegate downloadFinishedForCid:temp.cid fileName:temp.fileName filePath:[self msgForwardDataFilePathForFileName:fileName cid:cid]];
                            }
                            return;
                        }
                        
                        if (![self.currentModel.fileName isEqualToString:@""]) {
                            NSData *reqData = [MPMessagePackWriter writeObject:@[self.currentModel.fileName,self.currentModel.md5,@(self.currentModel.fileData.length),@(50*1024)] error:nil];
                            if ([JFGSDKSock sharedClient].isConnected) {
                                [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.currentModel.cid] isAck:YES fileType:1 msg:reqData];
                            }else{
                                [JFGSDK sendMsgForTcpWithDst:@[self.currentModel.cid] isAck:YES fileType:1 msg:reqData];
                            }
                           
                        }
                        
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqOvertime) object:nil];
                        [self performSelector:@selector(reqOvertime) withObject:nil afterDelay:30];
                        
                    }
                    JFGLog(@"下载中...");
                }
            }
        }
    }
}

-(void)reqOvertime
{
    isDownloading = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFailedForCid:fileName:errorType:)]) {
        [self.delegate downloadFailedForCid:self.currentModel.cid fileName:self.currentModel.fileName errorType:JFGMsgFwDlFailedTypeOvertime];
    }
}

-(NSString *)filePathForDownloadFinishedWithCid:(NSString *)cid fileName:(NSString *)fileName
{
    return [self msgForwardDataFilePathForFileName:fileName cid:cid];
}

-(NSString *)msgForwardDataFilePathForFileName:(NSString *)fileName cid:(NSString *)cid
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [FileManager jfgPano720PhotoDirPath:cid];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:fileName];
    return path;
}

@end
