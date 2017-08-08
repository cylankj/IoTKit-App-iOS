 //
//  SafeProtectViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SafeProtectViewModel.h"
#import "JfgGlobal.h"
#import "SafeProtectModel.h"
#import "JfgTableViewCellKey.h"
#import "JfgUserDefaultKey.h"
#import "JfgMsgDefine.h"
#import "dataPointMsg.h"
#import "ProgressHUD.h"
#import "PropertyManager.h"
#import <JFGSDK/JFGSDK.h>

@interface SafeProtectViewModel()

@property (strong, nonatomic) NSMutableArray *groupArray; // 分组 数据
@property (strong, nonatomic) NSMutableArray *dpsArray;   //请求ID 数组

@property (strong, nonatomic) SafeProtectModel *safeProtectmodel;

@end


@implementation SafeProtectViewModel

#pragma mark 外部接口
#pragma mark 安全防护 设备提示音

- (void)updatevoiceType:(int)soundType time:(int)repeatTime
{
    
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_WarnSound;
    seg.value = [MPMessagePackWriter writeObject:@[@(soundType),@(repeatTime)] error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.soundType = soundType;
        self.safeProtectmodel.soundTime = repeatTime;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

#pragma mark 重复日期
- (void)updateRepeatDate:(int)repeatDate
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_WarnTime;
    seg.value = [MPMessagePackWriter writeObject:@[@(self.safeProtectmodel.beginTime),@(self.safeProtectmodel.endTime),@(repeatDate)] error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.repeat = repeatDate;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

- (void)updatebeginTime:(int)beginTime endTime:(int)endTime
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_WarnTime;
    seg.value = [MPMessagePackWriter writeObject:@[@(beginTime),@(endTime),@(self.safeProtectmodel.repeat)] error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.beginTime = beginTime;
        self.safeProtectmodel.endTime = endTime;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

#pragma mark 安全防护
- (void)requestDataWithCid:(NSString *)cid
{
    if ([_delegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [self initModel:[self getJfgSafeProtectCache]];
        [_delegate fetchDataArray:[self createData]];
    }
    
    [[dataPointMsg shared] packSingleDataPointMsg:self.dpsArray withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        if (dic != nil)
        {
            [self setJfgSafeProtectCache:dic];
        }
        
        [self initModel:dic];
        [self update];
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    
}

- (void)updateMoveDection:(BOOL)isOpen
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_WarnEnable;
    seg.value = [MPMessagePackWriter writeObject:@(isOpen) error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.isWarnEnable = isOpen;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
        [JFGSDK refreshDeviceList];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

- (void)updateSensitive:(NSInteger)sensitiveType
{
    if (sensitiveType != self.safeProtectmodel.sensitive)
    {
        DataPointSeg * seg = [[DataPointSeg alloc]init];
        NSError * error = nil;
        seg.msgId = dpMsgCamera_WarnSenitivity;
        seg.value = [MPMessagePackWriter writeObject:@(sensitiveType) error:&error];
        NSArray * dps = @[seg];
        
        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
            self.safeProtectmodel.sensitive = sensitiveType;
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            [self update];
        } failed:^(RobotDataRequestErrorType error) {
            
        }];
    }
}
- (void)updateWarnDuration:(int)warnDur
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_WarnDuration;
    seg.value = [MPMessagePackWriter writeObject:@(warnDur) error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.alramDuration = warnDur;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

- (void)updateAIRecgnition:(NSArray *)aiTypes
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_AIRecgnition;
    seg.value = [MPMessagePackWriter writeObject:aiTypes error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.safeProtectmodel.aiRecognitions = aiTypes;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];

}

- (void)update
{
    if ([_delegate respondsToSelector:@selector(updatedDataArray:)])
    {
        [_delegate updatedDataArray:[self createData]];
    }
}

- (void)initModel:(NSDictionary *)dict
{
    @try {
        
        self.safeProtectmodel.isWarnEnable = [[dict objectForKey:dpMsgCameraWarnEnableKey] boolValue];
        self.safeProtectmodel.sensitive = [[dict objectForKey:dpMsgCameraWarnSenKey] intValue];
        
        NSArray *soundArray = [dict objectForKey:dpMsgCameraWarnSoundKey];
        if (soundArray.count >= 2)
        {
            self.safeProtectmodel.soundType = [[soundArray objectAtIndex:0] intValue];
            self.safeProtectmodel.soundTime = [[soundArray objectAtIndex:1] intValue];
        }
        
        NSArray *warnTimeArr = [dict objectForKey:dpMsgCameraWarnTimeKey];
        if (warnTimeArr.count >= 3)
        {
            self.safeProtectmodel.beginTime = [[warnTimeArr objectAtIndex:0] intValue];
            self.safeProtectmodel.endTime = [[warnTimeArr objectAtIndex:1] intValue];
            self.safeProtectmodel.repeat = [[warnTimeArr objectAtIndex:2] intValue];
        }
        
        
        self.safeProtectmodel.autoPhotoType = [[dict objectForKey:dpMsgVideoAutoRecordKey] intValue];
        
        if ([[dict objectForKey:msgBaseSDCardListKey] isKindOfClass:[NSArray class]])
        {
            NSArray *sdCardInfos = [dict objectForKey:msgBaseSDCardListKey];
            self.safeProtectmodel.isExistSDCard = [[sdCardInfos objectAtIndex:0] boolValue];
        }
        self.safeProtectmodel.aiRecognitions = [dict objectForKey:dpMsgCameraAIRecgnitionKey];
        
        self.safeProtectmodel.alramDuration = [[dict objectForKey:dpMsgCameraWarnDurKey] intValue];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

// 关门 造 数据
- (NSArray *)createData
{
    [self.groupArray removeAllObjects];
    
    
    if (self.safeProtectmodel.isWarnEnable)
    {
        
        NSArray *safePro = [self safeProctection];
        NSArray *warnSound = [self warnSoundRow];
        
        if (safePro.count > 0)
        {
            [self.groupArray addObject:safePro];
        }
        
        if (warnSound.count > 0)
        {
            [self.groupArray addObject:warnSound];
        }
        
        [self.groupArray addObject:[NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",cellIconImageKey,
                                     idCellWarnBeginTime, cellUniqueID,
                                     [JfgLanguage getLanTextStrByKey:@"FROME"],cellTextKey,
                                     self.safeProtectmodel.beginTimeStr,cellDetailTextKey,
                                     @(self.safeProtectmodel.beginTime), cellHiddenText,
                                     @0,cellshowSwitchKey,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",cellIconImageKey,
                                     [JfgLanguage getLanTextStrByKey:@"TO"],cellTextKey,
                                     idCellWarnEndTime, cellUniqueID,
                                     self.safeProtectmodel.endTimeStr,cellDetailTextKey,
                                     @(self.safeProtectmodel.endTime), cellHiddenText,
                                     @0,cellshowSwitchKey,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",cellIconImageKey,
                                     [JfgLanguage getLanTextStrByKey:@"REPEAT"],cellTextKey,
                                     idCellRepeatTime, cellUniqueID,
                                     self.safeProtectmodel.repeatStr,cellDetailTextKey,
                                     @(self.safeProtectmodel.repeat), cellHiddenText,
                                     @0,cellshowSwitchKey,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     nil], nil]];
    }
    else
    {
        [self.groupArray addObject:[NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"",cellIconImageKey,
                                     [JfgLanguage getLanTextStrByKey:@"SECURE_TYPE"],cellTextKey,
                                     idCellWarnEnable, cellUniqueID,
                                     [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                     @(self.safeProtectmodel.isWarnEnable),isCellSwitchOn,
                                     @1,cellshowSwitchKey,
                                     @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                     nil], nil]];
    }

    return self.groupArray;
}

// 报警 提示音
- (NSMutableArray *)warnSoundRow
{
    if ([PropertyManager showPropertiesRowWithPid:self.pType key:pWariningVoiceKey])
    {
        NSMutableArray *warnSound = [NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                      @"",cellIconImageKey,
                                                                      [JfgLanguage getLanTextStrByKey:@"SOUNDS"],cellTextKey,
                                                                      idCellWarnSound, cellUniqueID,
                                                                      self.safeProtectmodel.soundStr,cellDetailTextKey,
                                                                      self.safeProtectmodel,cellHiddenText,
                                                                      @0,cellshowSwitchKey,
                                                                      @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                                                      nil], nil];
        
        
        return warnSound;
    }
    
    return nil;
}

// 移动侦测  section 0
- (NSMutableArray *)safeProctection
{
    NSMutableArray *safes = [NSMutableArray arrayWithCapacity:5];
    
    [safes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                     @"",cellIconImageKey,
                     [JfgLanguage getLanTextStrByKey:@"SECURE_TYPE"],cellTextKey,
                     idCellWarnEnable, cellUniqueID,
                     [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                     @(self.safeProtectmodel.isWarnEnable),isCellSwitchOn,
                     @1,cellshowSwitchKey,
                     @(UITableViewCellAccessoryNone),cellAccessoryKey,
                      nil]];
    
    if ([PropertyManager showSharePropertiesRowWithPid:self.pType key:pAiRecognition])
    {
        [safes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          @"",cellIconImageKey,
                          [JfgLanguage getLanTextStrByKey:@"AI识别"],cellTextKey,
                          idCellAIRecognition, cellUniqueID,
                          self.safeProtectmodel.aiRecognitionStr,cellDetailTextKey,
                          self.safeProtectmodel.aiRecognitions, cellHiddenText,
                          @(self.safeProtectmodel.isShowAIRedDot), cellRedDotInRight,
                          @0,cellshowSwitchKey,
                          @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                          nil]];
    }
    
    if ([PropertyManager showSharePropertiesRowWithPid:self.pType key:pAlarmDuration])
    {
        [safes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          @"",cellIconImageKey,
                          [JfgLanguage getLanTextStrByKey:@"报警间隔"],cellTextKey,
                          idCellAlramDutaion, cellUniqueID,
                          self.safeProtectmodel.alramDurStr, cellDetailTextKey,
                          @(self.safeProtectmodel.alramDuration), cellHiddenText,
                          @0,cellshowSwitchKey,
                          @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                          nil]];
    }
    
    
    [safes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                     @"",cellIconImageKey,
                     [JfgLanguage getLanTextStrByKey:@"SECURE_SENSITIVITY"],cellTextKey,
                     idCellSensitive, cellUniqueID,
                     self.safeProtectmodel.sensitiveStr,cellDetailTextKey,
                     @(self.safeProtectmodel.sensitive), cellHiddenText,
                     @0,cellshowSwitchKey,
                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                      nil]];
    
    
    
    
    return safes;
}


#pragma mark
#pragma mark  安全防护 缓存 存取
- (void)setJfgSafeProtectCache:(NSDictionary *)dict
{
    if (dict != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:jfgSafeProtectCache(self.cid)];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (NSMutableDictionary *)getJfgSafeProtectCache
{
    NSMutableDictionary *dictCache = [[NSUserDefaults standardUserDefaults] objectForKey:jfgSafeProtectCache(self.cid)];
    return dictCache;
}


#pragma mark
#pragma mark property
- (SafeProtectModel *)safeProtectmodel
{
    if (_safeProtectmodel == nil)
    {
        _safeProtectmodel = [[SafeProtectModel alloc] init];
        _safeProtectmodel.cid = self.cid;
        _safeProtectmodel.pType = self.pType;
    }
    return _safeProtectmodel;
}


- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

- (NSMutableArray *)dpsArray
{
    if (_dpsArray == nil)
    {
        _dpsArray = [[NSMutableArray alloc] initWithCapacity:5];
        [_dpsArray addObjectsFromArray:@[@(dpMsgCamera_WarnEnable),
                                         @(dpMsgCamera_WarnSenitivity),
                                         @(dpMsgCamera_WarnSound),
                                         @(dpMsgCamera_WarnTime),
                                         @(dpMsgVideo_autoRecord),
                                         @(dpMsgBase_SDCardInfoList),
                                         @(dpMsgCamera_WarnDuration),
                                         @(dpMsgCamera_AIRecgnition)
                                         ]];
        
    }
    return _dpsArray;
}
- (int)beginTime
{
    return self.safeProtectmodel.beginTime;
}

- (int)endTime
{
    return self.safeProtectmodel.endTime;
}

- (int)repeat
{
    return self.safeProtectmodel.repeat;
}

- (BOOL)isWarnEnable
{
    return self.safeProtectmodel.isWarnEnable;
}

- (BOOL)isMotionDetectAbnormal
{
    if (self.safeProtectmodel.isExistSDCard == NO)
    {
        return NO;
    }
    return (self.safeProtectmodel.autoPhotoType == MotionDetectAbnormal);
}

@end
