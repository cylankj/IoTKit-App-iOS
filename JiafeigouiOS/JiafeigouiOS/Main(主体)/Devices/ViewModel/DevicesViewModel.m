//
//  DevicesViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DevicesViewModel.h"
#import "DevicesModel.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgMsgDefine.h"
#import "dataPointMsg.h"
#import "JfgGlobal.h"

@interface DevicesViewModel()

@property (nonatomic, strong) DevicesModel *devicesModel;
@property (nonatomic, strong) NSMutableArray<DataPointSeg *> *dps;

@end


@implementation DevicesViewModel

- (void)setDevicesDefaultDataWithCid:(NSString *)cid
{
    JFG_WS(weakSelf);
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"set default property ,pType %ld", (long)self.pType]];
    
    if (cid != nil && ![cid isEqualToString:@""])
    {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"set default property ,cid is %@",cid]];
        [[dataPointMsg shared] setdpDataWithCid:cid dps:self.dps success:^(NSMutableDictionary *dic) {
            [JFGSDK appendStringToLogFile:@"set default property success"];
        } failed:^(RobotDataRequestErrorType error) {
            [JFGSDK appendStringToLogFile:@"set default property failed"];
        }];
    }
    else
    {
        [JFGSDK appendStringToLogFile:@"set default property ,cid is null"];
    }
    
    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgBase_SDStatus)] withCid:cid SuccessBlock:^(NSMutableDictionary *dic)
     {
         
         NSArray *sdInfos = [dic objectForKey:msgBaseSDStatusKey];
         if (sdInfos.count >= 4)
         {
             int sdCardError = [[sdInfos objectAtIndex:2] intValue];
             BOOL isSDCardExist = [[sdInfos objectAtIndex:3] boolValue];
             NSInteger autoMotion = MotionDetectAbnormal;
             if (isSDCardExist && sdCardError == 0)
             {
                 DataPointSeg *seg = [[DataPointSeg alloc] init];
                 seg.msgId = dpMsgVideo_autoRecord;
                 switch (weakSelf.pType)
                 {
                     case productType_IPCam:
                     case productType_IPCam_V2:
                     {
                         autoMotion = MotionDetectNever;
                     }
                         break;
                         
                     default:
                     {
                         
                     }
                         break;
                 }
                 
                 seg.value = [MPMessagePackWriter writeObject:@(autoMotion) error:nil];
                 [[dataPointMsg shared] setdpDataWithCid:cid dps:@[seg] success:^(NSMutableDictionary *dic) {
                     [JFGSDK appendStringToLogFile:@"set auto abnormal"];
                 } failed:^(RobotDataRequestErrorType error) {
                     
                 }];
             }
             
         }
         
         
     } FailBlock:^(RobotDataRequestErrorType error) {
         
     }];
}

- (DevicesModel *)devicesModel
{
    if (_devicesModel == nil)
    {
        _devicesModel = [[DevicesModel alloc] init];
        _devicesModel.pType = self.pType;
    }
    
    return _devicesModel;
}

- (NSMutableArray *)dps
{
    if (_dps == nil)
    {
        NSArray *msgIds = [NSArray arrayWithObjects:@(dpMsgCamera_WarnEnable),
                                                    @(dpMsgCamera_WarnTime),
                                                    @(dpMsgCamera_isLive),
                                                    @(dpMsgBase_LED),
                                                    @(dpMsgVideo_diretion),
                                                    @(dpMsgBase_NTSC),
                                                    @(dpMsgBase_Mobile),
                                                    @(dpMsgCamera_WarnSound),
                                                    @(dpMsgCamera_WarnSenitivity),
                                                    @(dpMsgBase_Timezone),
                                                    @(dpMsgVideo_autoRecord),
                                                    @(dpMsgCamera_Angle),
                                                    @(dpMsgVideo_recordWhenWatching),
                                                    @(dpMsgCamera_WarnDuration),
                                                    @(dpMsgCamera_AIRecgnition),
                           nil];

        
        _dps = [[NSMutableArray alloc] initWithCapacity:5];
        
        for (NSInteger i = 0; i < msgIds.count; i ++)
        {
            DataPointSeg *seg = [[DataPointSeg alloc] init];
            seg.msgId = [[msgIds objectAtIndex:i] intValue];
            
            switch (seg.msgId)
            {
                case dpMsgCamera_WarnEnable:
                {
                    switch (self.pType)
                    {
                        case productType_RSDoorBell:
                        {
                            seg.value = [MPMessagePackWriter writeObject:@0 error:nil];
                        }
                            break;
                            
                        default:
                        {
                            seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.safeProtectModel.isWarnEnable) error:nil];
                        }
                            break;
                    }
                    
                }
                    break;
                case dpMsgCamera_WarnTime:
                {
                    seg.value = [MPMessagePackWriter writeObject:@[@(self.devicesModel.safeProtectModel.beginTime),@(self.devicesModel.safeProtectModel.endTime),@(self.devicesModel.safeProtectModel.repeat)] error:nil];
                }
                    break;
                case dpMsgCamera_isLive:
                {
                    seg.value = [MPMessagePackWriter writeObject:@[@(self.devicesModel.deviceSettingModel.isStandby),@1,@1,@0] error:nil];
                }
                    break;
                case dpMsgBase_LED:
                {
                    
                    seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.deviceSettingModel.isOpenIndicator) error:nil];
                }
                    break;
                case dpMsgVideo_diretion:
                {
                    seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.deviceSettingModel.isRotate) error:nil];
                }
                    break;
                case dpMsgBase_NTSC:
                {
                    seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.deviceSettingModel.isNTSC) error:nil];
                }
                    break;
                case dpMsgBase_Mobile:
                {
                    seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.deviceSettingModel.isMobile) error:nil];
                }
                    break;
                case dpMsgCamera_WarnSound:
                {
                    seg.value = [MPMessagePackWriter writeObject:@[@(self.devicesModel.deviceVoiceModel.soundType),@(self.devicesModel.deviceVoiceModel.voiceRepeatTime)] error:nil];
                }
                    break;
                case dpMsgCamera_WarnSenitivity:
                {
                    seg.value = [MPMessagePackWriter writeObject:@(self.devicesModel.safeProtectModel.sensitive) error:nil];
                }
                    break;
                case dpMsgBase_Timezone:
                {
                    seg.value = [MPMessagePackWriter writeObject:@[self.devicesModel.deviceInfoModel.timeZoneOrigin,@(self.devicesModel.timeZoneSecond)] error:nil];
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"timeZone %@: %ld",self.devicesModel.deviceInfoModel.timeZoneOrigin,self.devicesModel.timeZoneSecond]];
                }
                    break;
                case dpMsgVideo_autoRecord:
                {
                    NSInteger autoMotion = self.devicesModel.deviceSettingModel.autoPhotoOrigin;
                    
                    switch (self.pType)
                    {
                        case productType_IPCam_V2:
                        case productType_IPCam:
                        {
                            autoMotion = MotionDetectNever;
                        }
                            break;
                            
                        default:
                            break;
                    }
                    seg.value = [MPMessagePackWriter writeObject:@(autoMotion) error:nil];
                }
                    break;
                case dpMsgCamera_Angle:
                {
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"dps______%d", self.devicesModel.deviceSettingModel.angleType]];
                    seg.value = [MPMessagePackWriter writeObject:[NSString stringWithFormat:@"%d",self.devicesModel.deviceSettingModel.angleType] error:nil];
                }
                    break;
                case dpMsgVideo_recordWhenWatching:
                {
                    seg.value = [MPMessagePackWriter writeObject:@1 error:nil];
                }
                    break;
                case dpMsgCamera_WarnDuration:
                {
                    seg.value = [MPMessagePackWriter writeObject:@60 error:nil];
                }
                    break;
                case dpMsgCamera_AIRecgnition:
                {
                    seg.value = [MPMessagePackWriter writeObject:@[] error:nil];
                }
                    break;
                default:
                    break;
            }
            
            [_dps addObject:seg];
        }
        
    }

    return _dps;
}




@end
