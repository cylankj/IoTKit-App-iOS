//
//  DeviceAutoPhotoViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "DeviceAutoPhotoViewModel.h"
#import "JfgLanguage.h"
#import "DeviceAutoModel.h"
#import "JfgTableViewCellKey.h"
#import "JfgGlobal.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"
#import "dataPointMsg.h"
#import <JFGSDK/JFGSDK.h>
#import <UIKit/UIKit.h>

@interface DeviceAutoPhotoViewModel()<JFGSDKCallbackDelegate>

@property (nonatomic, strong) NSMutableArray *dataSections;

@property (nonatomic, strong) DeviceAutoModel *autoModel;

@end


@implementation DeviceAutoPhotoViewModel

- (instancetype)init
{
    if (self = [super init])
    {
        [JFGSDK addDelegate:self];
    }
    
    return self;
}


#pragma mark  fetch

- (NSMutableArray *)fetchData
{
    [self.dataSections removeAllObjects];
    [self.dataSections addObjectsFromArray:[self autoPhotoInfos]];
    
    JFG_WS(weakSelf);
    
    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgVideo_recordWhenWatching), @(dpMsgBase_SDStatus), @(dpMsgCamera_WarnEnable), @(dpMsgVideo_autoRecord)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        
        [weakSelf initModel:dic];
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    
    return self.dataSections;
}

- (void)initModel:(NSDictionary *)dict
{
    @try {
        self.autoModel.isRecordWhenWatching = [[dict objectForKey:dpMsgVideoRecordWhenWatchingKey] boolValue];
        self.autoModel.isWarnEnable = [[dict objectForKey:dpMsgCameraWarnEnableKey] boolValue];
        self.autoModel.movetionDectrionType= [[dict objectForKey:dpMsgVideoAutoRecordKey] intValue];
        
        NSArray *sdInfos = [dict objectForKey:msgBaseSDStatusKey];
        if (sdInfos.count >= 4)
        {
            self.autoModel.sdCardError = [[sdInfos objectAtIndex:2] intValue];
            self.autoModel.isExistSDCard = [[sdInfos objectAtIndex:3] boolValue];
        }
        [self updateData];
        
    } @catch (NSException *exception) {
        
        self.autoModel.sdCardError = 0;
        self.autoModel.isExistSDCard = YES;
        [self updateData];
        [JFGSDK appendStringToLogFile:@"DeviceAutoPhotoViewModel:数据解析异常"];
        
    } @finally {
        
    }

    
}


// 自动录像
- (NSMutableArray *)autoPhotoInfos
{
    NSMutableArray *autoPhotoArray = [NSMutableArray arrayWithCapacity:5];
    
    switch (self.pType)
    {
        case productType_CatEye:
        {
            [autoPhotoArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [JfgLanguage getLanTextStrByKey:@"Record_Video"],cellTextKey,
                                                                 idCellMoveRecord, cellUniqueID,
                                                                 @"",cellDetailTextKey,
                                                                 @(self.autoModel.isRecordWhenWatching),isCellSwitchOn,
                                                                 [JfgLanguage getLanTextStrByKey:@"Record_Descript"],cellFootViewTextKey,
                                                                 @1, canClickCellKey,
                                                                 @(self.autoModel.isShowRecordRedDot), cellRedDotInRight,
                                                                 @1,cellshowSwitchKey, nil], nil]];
        }
            break;
        case productType_RSDoorBell:
        case productType_KKS_DoorBell:
        case productType_720:
        case productType_720p:
        {
            [autoPhotoArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [JfgLanguage getLanTextStrByKey:@"RECORD_MODE"],cellTextKey,
                                                                 idCellRecordWhenAbnormal, cellUniqueID,
                                                                 @"",cellDetailTextKey,
                                                                 @(self.autoModel.isOpenMovetionDection),isCellSwitchOn,
                                                                 [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_0"],cellFootViewTextKey,
                                                                 @1, canClickCellKey,
                                                                 @(self.autoModel.isShowRecordRedDot), cellRedDotInRight,
                                                                 @1,cellshowSwitchKey, nil], nil]];
        }
            break;
        default:
        {
            [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [JfgLanguage getLanTextStrByKey:@"RECORD_MODE"],cellTextKey,
                                        idCellAbnormalRecord,cellUniqueID,
                                        [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_0"],cellFootViewTextKey,
                                        @(UITableViewCellAccessoryCheckmark),cellAccessoryKey,
                                        nil],
                                       nil]];
            
            if (self.pType != productType_FreeCam)
            {
                [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_1"],cellTextKey,
                                            idCellAwaysRecord,cellUniqueID,
                                            [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_1"],cellFootViewTextKey,
                                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                            nil],
                                           nil]];
            }
            
            [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                       [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_2"],cellTextKey,
                                        idCellNeverReocrd,cellUniqueID,
                                        [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_2"],cellFootViewTextKey,
                                        @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                        nil],
                                       nil]];
            
        }
            break;
    }
    
    
    return autoPhotoArray;
}


#pragma mark change

- (void)updateSwitchWithCellID:(NSString *)cellID changedValue:(id)changedValue
{
    if ([cellID isEqualToString:idCellMoveRecord])
    {
        if (!self.autoModel.isExistSDCard)
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
            [self updateData];
            return;
        }
        else if (self.autoModel.sdCardError != 0)
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"]];
            [self updateData];
            return;
        }
        
        [self updateMoveRecord:changedValue];
    }
    else if ([cellID isEqualToString:idCellRecordWhenAbnormal])
    {
        if (self.autoModel.isExistSDCard)
        {
            BOOL isOpen = [changedValue boolValue];
            
            if (!self.autoModel.isWarnEnable && isOpen)
            {
                JFG_WS(weakSelf);
                
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"RECORD_ALARM_OPEN"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OPEN"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf updateWarnEnable:YES];
                }];
            }
            else
            {
                [self updateMotionDection:isOpen];
            }
        }
        else
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
            [self updateData];
        }
    }
}

#pragma mark private

// 更新 移动侦测 猫眼
- (void)updateMoveRecord:(id)isOpen
{
    JFG_WS(weakSelf);
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:isOpen error:&error];
    
    seg.msgId = dpMsgVideo_recordWhenWatching;
    dpSegs = @[seg];
    
    if (!error)
    {
        [[dataPointMsg shared] setdpDataWithCid:weakSelf.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
            weakSelf.autoModel.isRecordWhenWatching = [isOpen boolValue];
            [weakSelf updateData];
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            
        } failed:^(RobotDataRequestErrorType error) {
            
        }];
    }
}

// 服务器 更新 自动录像
- (void)updateMotionDection:(BOOL)isOpen
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgVideo_autoRecord;
    NSInteger dectionType = isOpen?MotionDetectAbnormal:MotionDetectNever;
    seg.value = [MPMessagePackWriter writeObject:@(dectionType) error:&error];
    NSArray * dps = @[seg];
    
    __weak typeof(self) weakSelf = self;
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        weakSelf.autoModel.movetionDectrionType = (int)dectionType;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [weakSelf updateData];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

// 开关 侦测报警
- (void)updateWarnEnable:(BOOL)isOpen
{
    DataPointSeg *seg = [[DataPointSeg alloc]init];
    seg.version = 0;
    seg.msgId = dpMsgCamera_WarnEnable;
    seg.value =[MPMessagePackWriter writeObject:[NSNumber numberWithBool:isOpen] error:nil];
    
    JFG_WS(weakSelf);
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:@[seg] success:^(NSMutableDictionary *dic) {
        weakSelf.autoModel.isWarnEnable = isOpen;
        [weakSelf updateMotionDection:YES];
    } failed:^(RobotDataRequestErrorType error) {
        weakSelf.autoModel.isWarnEnable = !isOpen;
    }];
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray <DataPointSeg *> *)msgList
{
    for (DataPointSeg *seg in msgList)
    {
        if ([peer isEqualToString:self.cid])
        {
            NSError *error = nil;
            id obj = [MPMessagePackReader readData:seg.value error:&error];
            if (error == nil)
            {
                switch (seg.msgId)
                {

                    case dpMsgBase_SDCardInfoList:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                            
                            self.autoModel.isExistSDCard = isExistSDCard;
                            self.autoModel.sdCardError = [[obj objectAtIndex:1] intValue];
                            
                            if (self.autoModel.isWarnEnable)
                            {
                                if (isExistSDCard)
                                {
                                    [self updateMotionDection:NO];
                                }
                            }
                            
                            [self updateData];
                            
                        }
                        
                    }
                        break;
                    default:
                        break;
                }
            }
            
            
        }
    }
}


#pragma mark update
- (void)updateData
{
    
    if (_delegate != nil)
    {
        if ([_delegate respondsToSelector:@selector(updatedDataArray:)])
        {
            [_delegate updatedDataArray:[self autoPhotoInfos]];
        }
    }
}

#pragma mark getter
- (NSMutableArray *)dataSections
{
    if (_dataSections == nil)
    {
        _dataSections = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataSections;
}

- (DeviceAutoModel *)autoModel
{
    if (_autoModel == nil)
    {
        _autoModel = [[DeviceAutoModel alloc] init];
        _autoModel.pType = self.pType;
        _autoModel.cid = self.cid;
        
    }
    
    return _autoModel;
}

@end
