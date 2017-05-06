//
//  DeviceSettingViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceSettingViewModel.h"
#import "JfgTableViewCellKey.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "DeviceSettingModel.h"
#import "JfgTypeDefine.h"
#import "JfgMsgDefine.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "dataPointMsg.h"
#import "SDImageCache.h"
#import "JfgConfig.h"
#import "LoginManager.h"
#import "JFGEquipmentAuthority.h"
#import "JfgUserDefaultKey.h"
#import "OemManager.h"


@interface DeviceSettingViewModel()<JFGSDKCallbackDelegate>

@property (strong, nonatomic) NSMutableArray *groupArray; // 分组 数据
@property (strong, nonatomic) NSMutableArray *dpsArray; //dps 数组

@property (strong, nonatomic) DeviceSettingModel *settingModel;

@end

@implementation DeviceSettingViewModel

- (id)init
{
    self = [super init];
    if (self)
    {
        [JFGSDK addDelegate:self];
    }
    
    return self;
}

- (void)updateSettingsWithType:(productType)type cid:(NSString *)cid
{
    if ([_delegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [self initModel:[self jfgDeviceSettingCahche]];
        [_delegate fetchDataArray:[self createDataWithProductType:type Cid:cid]]; //获取 初始数据
    }
}

- (NSArray *)dataArrayFromViewModelWithProductType:(productType)type Cid:(NSString *)cid
{
    self.cid = cid;
    self.pType = type;
    
    if ([_delegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [self initModel:[self jfgDeviceSettingCahche]];
        [_delegate fetchDataArray:[self createDataWithProductType:type Cid:cid]]; //获取 初始数据
    }
    
    if (self.pType == productType_Mine)
    {
        return [self createDataWithProductType:type Cid:cid];
    }
    
    [[dataPointMsg shared] packSingleDataPointMsg:self.dpsArray withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        if (dic == nil)
        {
            dic = [self jfgDeviceSettingCahche];
        }
        
        [self initModel:dic];
        [self update];
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    
    return [self createDataWithProductType:type Cid:cid];
}

- (void)update
{
    if ([_delegate respondsToSelector:@selector(updatedDataArray:)])
    {
        [_delegate updatedDataArray:[self createDataWithProductType:self.pType Cid:self.cid]];
    }
}

- (void)initModel:(NSMutableDictionary *)dict
{
    @try {
        [self setJfgDeviceSettingCache:dict];
        
        self.settingModel.info = self.alias;
        
        NSArray *wifiArray = [dict objectForKey:msgBaseNetKey];
        if (wifiArray.count >= 2)
        {
            self.settingModel.deviceNetType = (DeviceNetType)[[wifiArray objectAtIndex:0] integerValue];
            self.settingModel.wifi = [wifiArray objectAtIndex:1];
        }
        
        self.settingModel.isMobile = [[dict objectForKey:msgBaseMobileKey] boolValue];
        self.settingModel.isWarnEnable = [[dict objectForKey:dpMsgCameraWarnEnableKey] boolValue];
        
        NSArray *safeArray = [dict objectForKey:dpMsgCameraWarnTimeKey];
        if (safeArray.count >= 3)
        {
            self.settingModel.beginTime = [[safeArray objectAtIndex:0] intValue];
            self.settingModel.endTime = [[safeArray objectAtIndex:1] intValue];
            self.settingModel.safeOrigin = [[safeArray objectAtIndex:2] longValue];
        }
        
        self.settingModel.autoPhotoOrigin = [[dict objectForKey:dpMsgVideoAutoRecordKey] intValue];
        
        NSArray * delayArr = [dict objectForKey:dpMsgCameraTimeLapseKey];
        if (delayArr.count > 4)
        {
            self.settingModel.isOpenDelayPhoto = [[delayArr objectAtIndex:3] boolValue];
            self.settingModel.delayPhotoBeginTime = [[delayArr objectAtIndex:0] longLongValue];
        }
        
        NSArray *sdInfos = [dict objectForKey:msgBaseSDStatusKey];
        if (sdInfos.count >= 4)
        {
            self.settingModel.sdCardError = [[sdInfos objectAtIndex:2] intValue];
            self.settingModel.isExistSDCard = [[sdInfos objectAtIndex:3] boolValue];
        }
        
        self.settingModel.isOpenIndicator = [[dict objectForKey:msgBaseLEDKey] boolValue];
        self.settingModel.isRotate = [[dict objectForKey:dpMsgVideoDiretionKey] boolValue];
        self.settingModel.isNTSC = [[dict objectForKey:msgBaseNTSCKey] boolValue];
        self.settingModel.SIMCardType = [[dict objectForKey:msgBaseSIMInfoKey] intValue];
        self.settingModel.angleType = [[dict objectForKey:dpMsgCameraAngleKey] intValue];
        
        
        
        id obj = [dict objectForKey:dpMsgCameraisLiveKey];
        if ([obj isKindOfClass:[NSArray class]]) {
            
            self.settingModel.isStandby = [[[dict objectForKey:dpMsgCameraisLiveKey] objectAtIndex:0] boolValue];
            
        }else{
            self.settingModel.isStandby = [[dict objectForKey:dpMsgCameraisLiveKey] boolValue];
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

// 关门 造 数据
- (NSArray *)createDataWithProductType:(productType)type Cid:(NSString *)cid
{
    [self.groupArray removeAllObjects];
    
    if (self.isShare)
    {
        [self.groupArray addObjectsFromArray:[self shareSettingsArray]];
    }
    else
    {
        switch (type)
        {
            case productType_3G:
            case productType_3G_2X:
            case productType_4G:
            {
                [self.groupArray addObjectsFromArray:[self mobileDogSettingsArray]];
            }
                break;
            case productType_DoorBell:
            {
                [self.groupArray addObjectsFromArray:[self doorBellSettingsArray]];
                
            }
                break;
            case productType_Mag:
            {
                [self.groupArray addObjectsFromArray:[self magSettingsArray]];
            }
                break;
            case productType_Mine:
            {
                [self.groupArray addObjectsFromArray:[self mineSettingsArray]];
            }
                break;
            case productType_Efamily:
            {
                [self.groupArray addObjectsFromArray:[self efamilySettingsArray]];
            }
                break;
            case productType_Camera_HS:
            case productType_Camera_ZY:
            case productType_Camera_GK:
            {
                [self.groupArray addObjectsFromArray:[self panoramaDogSettingsArray]];
            }
                break;
            case productType_FreeCam:
            {
                [self.groupArray addObjectsFromArray:[self freeCamSettingsArray]];
            }
                break;
            case productType_720:
            {
                [self.groupArray addObjectsFromArray:[self ap720CameraSettingArray]];
            }
                break;
            case productType_RS_180:
            {
                [self.groupArray addObjectsFromArray:[self rsSettingsArray]];
            }
                break;
            case productType_RS_120:
            case productType_IPCam:
            default:
            {
                [self.groupArray addObjectsFromArray:[self dogSettingsArray]];
                
            }
                break;
        }
    }
    
    return self.groupArray;
}

#pragma mark 获取数据方法
// 来自分享(FromOthers) 功能设置 数据
- (NSMutableArray *)shareSettingsArray
{
    NSMutableArray *shareSettings = [NSMutableArray array];
    
    [shareSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_info",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil], nil]];
    
    return shareSettings;
}

// 摄像头 功能设置 数据获取
- (NSMutableArray *)dogSettingsArray
{
    NSMutableArray *dogSettings = [NSMutableArray array];
    
    
    [dogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_info",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 self.settingModel.detailTextColor, detailTextColorKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil], nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"set_con_wifi",cellIconImageKey,
                                   [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                   self.settingModel.wifi,cellDetailTextKey,
                                   @0,cellshowSwitchKey,
                                   @(self.settingModel.isCellCanClick), canClickCellKey,
                                   nil],
                                  nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_safe",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                                 self.settingModel.safe,cellDetailTextKey,
                                 @(self.settingModel.safeOrigin),cellHiddenText,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                                 nil],
                                
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_recording",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                                 self.settingModel.autoPhoto,cellDetailTextKey,
                                 @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                                 nil],nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_standby",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
                                 @(self.settingModel.isStandby),isCellSwitchOn,
                                 @(self.settingModel.isStandByCanClick),canClickCellKey,
                                 @1,cellshowSwitchKey, nil], nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_light",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"LED"],cellTextKey,
                                 @"",cellDetailTextKey,
                                 @(self.settingModel.isOpenIndicator),isCellSwitchOn,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_overturn",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_VideoDirection"],cellTextKey,
                                 @"",cellDetailTextKey,
                                 @(self.settingModel.isRotate),isCellSwitchOn,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_fute",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"HZ_VOTE"],cellTextKey,
                                 @(self.settingModel.isNTSC),isCellSwitchOn,
                                 [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
                                 @1,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil],
                                nil]];  
    
    return dogSettings;
}
- (NSMutableArray *)freeCamSettingsArray
{
    NSMutableArray *freeCamArray = [NSMutableArray arrayWithCapacity:5];
    
    [freeCamArray addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_info",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                             self.settingModel.info,cellDetailTextKey,
                             self.settingModel.detailTextColor, detailTextColorKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil], nil]];
    [freeCamArray addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_con_wifi",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                             self.settingModel.wifi,cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil],
                            nil]];
    [freeCamArray addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_safe",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                             self.settingModel.safe,cellDetailTextKey,
                             @(self.settingModel.safeOrigin),cellHiddenText,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_recording",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                             self.settingModel.autoPhoto,cellDetailTextKey,
                             @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                             nil],nil]];
//    [freeCamArray addObject:[NSArray arrayWithObjects:
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"set_icon_standby",cellIconImageKey,
//                             [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
//                             @(self.settingModel.isStandby),isCellSwitchOn,
//                             @(self.settingModel.isStandByCanClick),canClickCellKey,
//                             @1,cellshowSwitchKey, nil], nil]];
    [freeCamArray addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_overturn",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_VideoDirection"],cellTextKey,
                             @"",cellDetailTextKey,
                             @(self.settingModel.isRotate),isCellSwitchOn,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @1,cellshowSwitchKey, nil],
//                            [NSDictionary dictionaryWithObjectsAndKeys:
//                             @"set_icon_fute",cellIconImageKey,
//                             [JfgLanguage getLanTextStrByKey:@"HZ_VOTE"],cellTextKey,
//                             @(self.settingModel.isNTSC),isCellSwitchOn,
//                             [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
//                             @1,cellshowSwitchKey,
//                             @(self.settingModel.isCellCanClick), canClickCellKey,
//                             nil],
                            nil]];

    
    return freeCamArray;
}
// 全景摄像头 功能设置 数据获取
- (NSMutableArray *)panoramaDogSettingsArray
{
    NSMutableArray *dogSettings = [NSMutableArray array];
    
    
    [dogSettings addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_info",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                             self.settingModel.info,cellDetailTextKey,
                             self.settingModel.detailTextColor, detailTextColorKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil], nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_con_wifi",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                             self.settingModel.wifi,cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil],
                            nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_safe",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                             self.settingModel.safe,cellDetailTextKey,
                             @(self.settingModel.safeOrigin),cellHiddenText,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_recording",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                             self.settingModel.autoPhoto,cellDetailTextKey,
                             @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                             nil],nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_standby",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
                             @(self.settingModel.isStandby),isCellSwitchOn,
                             @(self.settingModel.isStandByCanClick),canClickCellKey,
                             @1,cellshowSwitchKey, nil], nil]];
    [dogSettings addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"install_icon_angle",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_ViewAngle"],cellTextKey,
                             self.settingModel.angleStr,cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.angleType), cellHiddenText,
                              nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_light",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"LED"],cellTextKey,
                             @"",cellDetailTextKey,
                             @(self.settingModel.isOpenIndicator),isCellSwitchOn,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @1,cellshowSwitchKey, nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_fute",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"HZ_VOTE"],cellTextKey,
                             @(self.settingModel.isNTSC),isCellSwitchOn,
                             [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
                             @1,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil],
                            nil]];
    
    return dogSettings;
}
// 门铃 功能设置 数据获取
- (NSMutableArray *)doorBellSettingsArray
{
    NSMutableArray *doorBellSettings = [NSMutableArray array];
    
    [doorBellSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_info",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil], nil]];
    if (!self.isShare)
    {
        [doorBellSettings addObject:[NSArray arrayWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"set_con_wifi",cellIconImageKey,
                                     @(self.settingModel.isCellCanClick), canClickCellKey,
                                     [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                     self.settingModel.wifi,cellDetailTextKey,
                                     @0,cellshowSwitchKey,nil],
                                    nil]];
        [doorBellSettings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [JfgLanguage getLanTextStrByKey:@"DOOR_CLEAR_REOCRD"],cellTextKey,
                                                              @0,cellshowSwitchKey,
                                                              @(self.settingModel.isCellCanClick), canClickCellKey,
                                                              @(UITableViewCellAccessoryNone),cellAccessoryKey, nil], nil]];
    }
    
    return doorBellSettings;
}
// 3G、4G 狗 功能设置 数据获取
- (NSMutableArray *)mobileDogSettingsArray
{
    NSMutableArray *mobileDogSettings = [NSMutableArray array];
    
    [mobileDogSettings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_info",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,nil], nil]];
    if (self.settingModel.SIMCardType == SIMType_Using)
    {
        [mobileDogSettings addObject:[NSArray arrayWithObjects:
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"set_con_wifi",cellIconImageKey,
                                       [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                       self.settingModel.wifi,cellDetailTextKey,
                                       @(self.settingModel.isCellCanClick), canClickCellKey,
                                       @0,cellshowSwitchKey,nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"set_icon_3g",cellIconImageKey,
                                       [JfgLanguage getLanTextStrByKey:@"MOBILE_DATA"],cellTextKey,
                                       @"",cellDetailTextKey,
                                       @(self.settingModel.isMobile),isCellSwitchOn,
                                       @(self.settingModel.isMobileCanClick), canClickCellKey,
                                       @1,cellshowSwitchKey, nil],nil]];
    }
    else
    {
        [mobileDogSettings addObject:[NSArray arrayWithObjects:
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"set_con_wifi",cellIconImageKey,
                                       [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                       self.settingModel.wifi,cellDetailTextKey,
                                       @(self.settingModel.isCellCanClick), canClickCellKey,
                                       @0,cellshowSwitchKey,nil],
                                       nil]];
    }
    
    [mobileDogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_safe",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                                 self.settingModel.safe,cellDetailTextKey,
                                 @(self.settingModel.safeOrigin),cellHiddenText,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                                 @0,cellshowSwitchKey, nil],
                                
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_recording",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                                 self.settingModel.autoPhoto,cellDetailTextKey,
                                 @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                                 @0,cellshowSwitchKey, nil],
                                
                                /*[NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_delay",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap2_Timelapse_title"],cellTextKey,
                                 self.settingModel.delayPhoto,cellDetailTextKey,
                                 @(self.settingModel.isDelayPhotoCanClick), canClickCellKey,
                                 @(self.settingModel.isShowDelayPhotoRedDot), cellRedDotInRight,
                                 @0,cellshowSwitchKey, nil],*/
                                nil]];
    [mobileDogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_standby",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
                                 @(self.settingModel.isStandby),isCellSwitchOn,
                                 @(self.settingModel.isStandByCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil], nil]];
    [mobileDogSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_light",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"LED"],cellTextKey,
                                 @"",cellDetailTextKey,
                                 @(self.settingModel.isOpenIndicator),isCellSwitchOn,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_overturn",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_VideoDirection"],cellTextKey,
                                 @"",cellDetailTextKey,
                                 @(self.settingModel.isRotate),isCellSwitchOn,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @"set_icon_fute",cellIconImageKey,
//                                 [JfgLanguage getLanTextStrByKey:@"HZ_VOTE"],cellTextKey,
//                                 @(self.settingModel.isNTSC),isCellSwitchOn,
//                                 [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
//                                 @(self.settingModel.isCellCanClick), canClickCellKey,
//                                 @1,cellshowSwitchKey, nil],
                                nil]];
    
    return mobileDogSettings;
}

// 720 ap全景 摄像头
- (NSMutableArray *)ap720CameraSettingArray
{
    NSMutableArray *ap720Settings = [NSMutableArray arrayWithCapacity:5];
    
    [ap720Settings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"set_icon_info",cellIconImageKey,
                                                          [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                                          self.settingModel.info,cellDetailTextKey,
                                                          @0,cellshowSwitchKey,
                                                          @(self.settingModel.isCellCanClick), canClickCellKey, nil], nil]];
    [ap720Settings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"720_info_logo",cellIconImageKey,
                                                          [JfgLanguage getLanTextStrByKey:@"LOGO选择"],cellTextKey,
                                                          @(self.settingModel.isCellCanClick), canClickCellKey,
                                                          @0,cellshowSwitchKey, nil], nil]];
    [ap720Settings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        @"set_con_wifi",cellIconImageKey,
                                                        [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                                        self.settingModel.wifi,cellDetailTextKey,
                                                        @(self.settingModel.isCellCanClick), canClickCellKey,
                                                        @0,cellshowSwitchKey,nil],
                                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                                       @"720_info_ap",cellIconImageKey,
                                                       [JfgLanguage getLanTextStrByKey:@"户外模式"],cellTextKey,
                                                       @"",cellDetailTextKey,
                                                       @0,cellshowSwitchKey,
                                                       @1, canClickCellKey,
                                                       nil], nil]];
    
    return ap720Settings;
}


// 中控 功能设置 数据获取
- (NSMutableArray *)efamilySettingsArray
{
    NSMutableArray *efamilySettings = [NSMutableArray array];
    
    [efamilySettings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         @"set_icon_info",cellIconImageKey,
                                                         [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                                         self.settingModel.info,cellDetailTextKey,
                                                         @0,cellshowSwitchKey,
                                                         @(self.settingModel.isCellCanClick), canClickCellKey, nil], nil]];
    [efamilySettings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         @"set_con_wifi",cellIconImageKey,
                                                         [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,[JfgLanguage getLanTextStrByKey:@"cylan_605"],cellDetailTextKey,
                                                         @(self.settingModel.isCellCanClick), canClickCellKey,
                                                         @0,cellshowSwitchKey, nil], nil]];
    [efamilySettings addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [JfgLanguage getLanTextStrByKey:@"DOOR_CLEAR_REOCRD"],cellTextKey,
                                                          @0,cellshowSwitchKey,
                                                          @(self.settingModel.isCellCanClick), canClickCellKey,
                                                          @(UITableViewCellAccessoryNone),cellAccessoryKey, nil], nil]];
    
    return efamilySettings;
}

// RS in doby settings
- (NSMutableArray *)rsSettingsArray
{
    {
        NSMutableArray *rsSettings = [NSMutableArray array];
        
        
        [rsSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_info",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 self.settingModel.detailTextColor, detailTextColorKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil], nil]];
        [rsSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_con_wifi",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                 self.settingModel.wifi,cellDetailTextKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil],
                                nil]];
        [rsSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_safe",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                                 self.settingModel.safe,cellDetailTextKey,
                                 @(self.settingModel.safeOrigin),cellHiddenText,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                                 nil],
                                
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_recording",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                                 self.settingModel.autoPhoto,cellDetailTextKey,
                                 @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                                 nil],nil]];
        [rsSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_standby",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
                                 @(self.settingModel.isStandby),isCellSwitchOn,
                                 @(self.settingModel.isStandByCanClick),canClickCellKey,
                                 @1,cellshowSwitchKey, nil], nil]];
        [rsSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_light",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"LED"],cellTextKey,
                                 @"",cellDetailTextKey,
                                 @(self.settingModel.isOpenIndicator),isCellSwitchOn,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @1,cellshowSwitchKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"set_icon_fute",cellIconImageKey,
                                 [JfgLanguage getLanTextStrByKey:@"HZ_VOTE"],cellTextKey,
                                 @(self.settingModel.isNTSC),isCellSwitchOn,
                                 [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
                                 @1,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil],
                                nil]];
        
        return rsSettings;
    }
}

// 门磁 功能设置 数据获取
- (NSMutableArray *)magSettingsArray
{
    NSMutableArray *magSettings = [NSMutableArray array];
    
    [magSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                                 self.settingModel.info,cellDetailTextKey,
                                 @0,cellshowSwitchKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 nil], nil]];
    
    BOOL iswarn = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGMagWarnStatue"];
    [magSettings addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                   [JfgLanguage getLanTextStrByKey:@"Tap1_Magnetism_Setting_Notify"],cellTextKey,
                                   @(self.settingModel.isCellCanClick), canClickCellKey,
                                   @1,cellshowSwitchKey,@(iswarn),isCellSwitchOn, nil],
                                  nil]];
    
    [magSettings addObject:[NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       [JfgLanguage getLanTextStrByKey:@"Tap1_Magnetism_ClearRecord"],cellTextKey,
                       @(self.settingModel.isCellCanClick), canClickCellKey,
                       @0,cellshowSwitchKey,
                       @(UITableViewCellAccessoryNone),cellAccessoryKey, nil],
                      nil]];
    
    return magSettings;
}

// 功能模块 “我的” 数据获取
- (NSMutableArray *)mineSettingsArray
{
    NSMutableArray *mineArr = [NSMutableArray array];
    
    BOOL isPush = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGAccountIsOpnePush"];
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone == setting.types) {
        isPush = NO;
    }
    
    [mineArr addObject:[NSArray arrayWithObjects:
                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                   [JfgLanguage getLanTextStrByKey:@"PUSH_MSG"],cellTextKey,
                                   @1,cellshowSwitchKey,
                                   @(isPush),isCellSwitchOn,
                                   @(self.settingModel.isCellCanClick), canClickCellKey,
                                   nil],nil]];
    
    NSString *cacheStr = @"0.0M";
    [mineArr addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"CLEAR_DATA"],cellTextKey,
                                 cacheStr,cellDetailTextKey,
                                 @(self.settingModel.isCellCanClick), canClickCellKey,
                                 @0,cellshowSwitchKey,
                                 nil], nil]];
    BOOL showAbout = [[[OemManager getOemConfig:oemAboutKey] objectForKey:oemShowAboutKey] boolValue];
    if (showAbout)
    {
        [mineArr addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"ABOUT"],cellTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil], nil]];
    }
    
    
    return mineArr;
}


#pragma mark
#pragma mark  更新字段 Action
#pragma mark --- public
#pragma mark 按钮 开关 触发事件

- (void)updateDataWithIndexPath:(NSIndexPath *)indexPath changedValue:(id)changedValue
{
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:changedValue error:&error];
    
    switch (self.pType)
    {
        case productType_3G:
        case productType_3G_2X:
        case productType_4G:
        {
            switch (indexPath.section)
            {
                case 1:
                {
                    switch (indexPath.row)
                    {
                        case 1:    //3G。4G 网络
                        {
                            seg.msgId = dpMsgBase_Mobile;
                            seg.value = [MPMessagePackWriter writeObject:changedValue error:&error];
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isMobile = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 3:
                {
                    switch (indexPath.row)
                    {
                        case 0: // 待机
                        {
                            [self updateStandBy:changedValue];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 4:
                {
                    switch (indexPath.row)
                    {
                        case 0: // 设备指示灯
                        {
                            seg.msgId = dpMsgBase_LED;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isOpenIndicator = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
                            }
                        }
                            break;
                        case 1: //画面调转
                        {
                            seg.msgId = dpMsgVideo_diretion;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isRotate = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
                            }
                        }
                            break;
                        case 2: // 110V
                        {
                            seg.msgId = dpMsgBase_NTSC;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isNTSC = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
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
            break;
        case productType_RS_180:
        {
            switch (indexPath.section)
            {
                case 3:
                {
                    switch (indexPath.row)
                    {
                        case 0: // 待机
                        {
                            [self updateStandBy:changedValue];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 4:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            seg.msgId = dpMsgBase_LED;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isOpenIndicator = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                        }
                            break;
                        case 1: // 110V
                        {
                            seg.msgId = dpMsgBase_NTSC;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isNTSC = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
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
            break;
        case productType_RS_120:
        case productType_IPCam:
        case productType_WIFI:{
            switch (indexPath.section)
            {
                case 3:
                {
                    switch (indexPath.row)
                    {
                        case 0: // 待机
                        {
                            [self updateStandBy:changedValue];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 4:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            seg.msgId = dpMsgBase_LED;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isOpenIndicator = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                        }
                            break;
                        case 1: //画面调转
                        {
                            seg.msgId = dpMsgVideo_diretion;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isRotate = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
                            }
                        }
                            break;
                        case 2: // 110V
                        {
                            seg.msgId = dpMsgBase_NTSC;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isNTSC = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
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
            break;
        case productType_Mag:
        {
            if (indexPath.section == 1) {
                //处理开关数据
            }
        }
            break;
        case productType_Mine:
        {
            BOOL setPush = [changedValue boolValue];
            
            if (setPush) {
                
                if ([JFGEquipmentAuthority canNotificationPermission]) {
                    //_switch.on = YES;
                    [JFGSDK isOpenPush:YES];
                    [[NSUserDefaults standardUserDefaults] setBool:[changedValue boolValue] forKey:@"JFGAccountIsOpnePush"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else{
                    //_switch.on = NO;
                }
            }else{
                [JFGSDK isOpenPush:NO];
                [[NSUserDefaults standardUserDefaults] setBool:[changedValue boolValue] forKey:@"JFGAccountIsOpnePush"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //_switch.on = NO;
            }
            
            
            [self update];
        }
            break;
        case productType_FreeCam:
        {
            switch (indexPath.section)
            {
                case 3:
                {
                    seg.msgId = dpMsgVideo_diretion;
                    dpSegs = @[seg];
                    
                    if (!error)
                    {
                        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                            self.settingModel.isRotate = [changedValue boolValue];
                            [self update];
                            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                            
                        } failed:^(RobotDataRequestErrorType error) {
                            
                        }];
                    }
                    else
                    {
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case productType_Camera_HS:
        case productType_Camera_ZY:
        case productType_Camera_GK:
        {
            switch (indexPath.section)
            {
                case 3: // 待机
                {
                    [self updateStandBy:changedValue];
                    /*
                    seg.msgId = dpMsgCamera_isLive;
                    dpSegs = @[seg];
                    
                    if (!error)
                    {
                        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                            self.settingModel.isStandby = [changedValue boolValue];
                            [self update];
                            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:JFGSettingOpenSafety object:changedValue];
                            
                        } failed:^(RobotDataRequestErrorType error) {
                            
                        }];
                    }else{
                        
                        
                    }
                    */
                }
                    break;
                case 4:
                {
                    switch (indexPath.row)
                    {
                        case 1: // 设备指示灯
                        {
                            seg.msgId = dpMsgBase_LED;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isOpenIndicator = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
                            }
                        }
                            break;
                        case 2: // 110V 市电
                        {
                            seg.msgId = dpMsgBase_NTSC;
                            dpSegs = @[seg];
                            
                            if (!error)
                            {
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    self.settingModel.isNTSC = [changedValue boolValue];
                                    [self update];
                                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                    
                                } failed:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            else
                            {
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
            break;
        default:
            break;
    }
    
    
}
// 服务器 更新 自动录像
- (void)updateMotionDection:(NSInteger)dectionType
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgVideo_autoRecord;
    seg.value = [MPMessagePackWriter writeObject:@(dectionType) error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.settingModel.autoPhotoOrigin = (int)dectionType;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

- (void)updateMotionDection:(NSInteger)dectionType tipShow:(BOOL)isShow
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgVideo_autoRecord;
    seg.value = [MPMessagePackWriter writeObject:@(dectionType) error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.settingModel.autoPhotoOrigin = dectionType;
        if (isShow)
        {
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        }
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

// 更新 全景视角
- (void)updatePanoAngle:(int)angleType
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgCamera_Angle;
    seg.value = [MPMessagePackWriter writeObject:[NSString stringWithFormat:@"%d",angleType] error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.settingModel.angleType = angleType;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}



// 本地更新 安全防护 时间
- (void)updateTime:(int)repeatDate
{
    self.settingModel.safeOrigin = repeatDate;
    [self update];
}

// 更新网络状态
- (void)updateSettingCell:(BOOL)canClick
{
    self.settingModel.isMobileCanClick = canClick;
    self.settingModel.isDelayPhotoCanClick = canClick;
    self.settingModel.isStandByCanClick = canClick;
    [self update];
}

// 更新 昵称
- (void)updateAliasWithString:(NSString *)newAlias
{
    self.alias = newAlias;
    self.settingModel.info = self.alias;
    
    [self update];
}

- (void)updateSafeProtectStr:(BOOL)warnEnable repeatTime:(int)repeat begin:(int)beginTime end:(int)endTime
{
    self.settingModel.beginTime = beginTime;
    self.settingModel.endTime = endTime;
    self.settingModel.isWarnEnable = warnEnable;
    self.settingModel.safeOrigin = repeat;
    [self update];
}

- (void)updateWarnEnable:(BOOL)isOpen
{
    self.settingModel.isWarnEnable = isOpen;
    [self update];
}

#pragma mark private
//封装 更新待机 状态
- (void)updateStandBy:(id)changedValue
{
    /*
        dpMsgCamera_isLive,
        dpMsgCamera_WarnEnable,
        dpMsgBase_LED,
        dpMsgVideo_autoRecord
     */
    
    NSError *error = nil;
    NSMutableArray *dpSegs = [[NSMutableArray alloc] initWithCapacity:3];
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.msgId = dpMsgCamera_isLive; //待机
    
    if ([changedValue boolValue] == YES) // 开启 待机
    {
        seg.value = [MPMessagePackWriter writeObject:@[changedValue,@(self.settingModel.isWarnEnable),@(self.settingModel.isOpenIndicator),@(self.settingModel.autoPhotoOrigin)] error:&error];
        [dpSegs addObject:seg];
        [dpSegs addObjectsFromArray:[self isLiveRelative:@[changedValue,@NO,@NO,@(MotionDetectNever)]]];
        
        if (!error)
        {
            [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                self.settingModel.isStandby = [changedValue boolValue];
                self.settingModel.isWarnEnable = NO;
                self.settingModel.isOpenIndicator = NO;
                self.settingModel.autoPhotoOrigin = MotionDetectNever;
                [self update];
                
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:JFGSettingOpenSafety object:changedValue];
                
            } failed:^(RobotDataRequestErrorType error) {
                
            }];
        }
    }
    else // 关闭 待机
    {
        [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_isLive)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
            NSMutableArray *dpValues = [dic objectForKey:dpMsgCameraisLiveKey];
            [dpValues replaceObjectAtIndex:0 withObject:changedValue];
            
            seg.value = [MPMessagePackWriter writeObject:dpValues error:nil];
            
            [dpSegs addObject:seg];
            [dpSegs addObjectsFromArray:[self isLiveRelative:[dic objectForKeyedSubscript:dpMsgCameraisLiveKey]]];
            
            [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic)
            {
                self.settingModel.isStandby = [changedValue boolValue];
                self.settingModel.isWarnEnable = [[dpValues objectAtIndex:1] boolValue];
                self.settingModel.isOpenIndicator = [[dpValues objectAtIndex:2] boolValue];
                self.settingModel.autoPhotoOrigin = [[dpValues objectAtIndex:3] integerValue];
                [self update];
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:JFGSettingOpenSafety object:changedValue];
                
            } failed:^(RobotDataRequestErrorType error) {
                
            }];
            
        } FailBlock:^(RobotDataRequestErrorType error) {
            
        }];
        
        
    }

}

// 待机 关联 属性
- (NSArray *)isLiveRelative:(NSArray *)values
{
    //报警
    DataPointSeg *warnEableSeg = [[DataPointSeg alloc] init];
    warnEableSeg.msgId = dpMsgCamera_WarnEnable;
    warnEableSeg.value = [MPMessagePackWriter writeObject:[values objectAtIndex:1] error:nil];
    //LED指示灯
    DataPointSeg *indicatorSeg = [[DataPointSeg alloc] init];
    indicatorSeg.msgId = dpMsgBase_LED;
    indicatorSeg.value = [MPMessagePackWriter writeObject:[values objectAtIndex:2] error:nil];
    //自动录像
    DataPointSeg *autoRecordSeg = [[DataPointSeg alloc] init];
    autoRecordSeg.msgId = dpMsgVideo_autoRecord;
    autoRecordSeg.value = [MPMessagePackWriter writeObject:[values objectAtIndex:3] error:nil];
    
    return @[indicatorSeg, warnEableSeg, autoRecordSeg];
}




#pragma mark
#pragma mark  功能设置 缓存 存取
- (void)setJfgDeviceSettingCache:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:jfgDeviceSettingCache(self.cid)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)jfgDeviceSettingCahche
{
    NSMutableDictionary *dictCache = [[NSUserDefaults standardUserDefaults] objectForKey:jfgDeviceSettingCache(self.cid)];
    return dictCache;
}

#pragma mark
#pragma mark  删除 消息 ---
- (void)deleteMsg
{
    switch (self.pType)
    {
        case productType_DoorBell:
        {
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc] init];
            seg.version = -1;
            seg.msgId = dpMsgBell_callMsg;
            
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:@[seg] success:^(NSString *identity, int ret) {
                if (ret == 0)
                {
                    [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips3"]];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearDoorBellSuccess" object:nil];
            } failure:^(RobotDataRequestErrorType type) {
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips4"]];
            }];
        }
            break;
        case productType_Mag:
        {
            NSLog(@"清空开关记录");
            
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark --- 网络代理 ---
-(void)jfgNetworkChanged:(JFGNetType)netType
{
    [self updateSettingCell:!(netType == JFGNetTypeConnect || netType == JFGNetTypeOffline)];
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeUpdataAccount) {
        if (errorType == JFGErrorTypeNone) {
            [JFGSDK getAccount];
        }
    }
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
                    case dpMsgBase_Net:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            NSArray *objArr = obj;
                            if (objArr.count>0)
                            {
                                
                                int netType = [[objArr objectAtIndex:0] intValue];
                                switch (netType)
                                {
                                    case DeviceNetType_Offline:
                                    case DeviceNetType_Connetct:
                                    {
                                        [self updateSettingCell:NO];
                                    }
                                        break;
                                    case DeviceNetType_2G:
                                    case DeviceNetType_3G:
                                    case DeviceNetType_4G:
                                    case DeviceNetType_5G:
                                    case DeviceNetType_Wifi:
                                    {
                                        [self updateSettingCell:YES];
                                    }
                                    default:
                                        break;
                                }
                                
                            }
                        }
                        
                    }
                        break;
                    case dpMsgBase_SIMInfo:
                    {
                        if ([obj isKindOfClass:[NSNumber class]])
                        {
                            self.settingModel.SIMCardType = [obj intValue];
                            [self update];
                        }
                    }
                        break;
                    /*
                    case dpMsgBase_SDStatus:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:3] boolValue];
                            
                            if (!isExistSDCard) // SD卡 不存在
                            {
                                self.settingModel.isExistSDCard = isExistSDCard;
                                self.settingModel.sdCardError = [[obj objectAtIndex:2] intValue];
                                self.settingModel.info = self.alias;
                                [self update];
                            }
                            else
                            {
                                self.settingModel.isExistSDCard = isExistSDCard;
                                self.settingModel.sdCardError = [[obj objectAtIndex:2] intValue];
                                [self update];
                            }
                            
                        }
                    }
                        break;
                    */
                    case dpMsgBase_SDCardInfoList:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                            
                            self.settingModel.isExistSDCard = isExistSDCard;
                            self.settingModel.sdCardError = [[obj objectAtIndex:1] intValue];
                            self.settingModel.info = self.alias;
                            [self update];
                            
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

#pragma mark
#pragma mark property

- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] init];
    }
    return _groupArray;
}

- (NSMutableArray *)dpsArray
{
    if (_dpsArray == nil)
    {
        _dpsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        switch (self.pType)
        {
           case productType_DoorBell:
            {
                [_dpsArray addObjectsFromArray:@[@(dpMsgBase_Net)]];
            }
                break;
            case productType_WIFI:
            case productType_3G:
            default:
            {
                [_dpsArray addObjectsFromArray:@[@(dpMsgBase_Net),
                                                 @(dpMsgBase_Mobile),
                                                 @(dpMsgBase_SDStatus),
                                                 @(dpMsgCamera_WarnTime),
                                                 @(dpMsgVideo_autoRecord),
                                                 @(dpMsgCamera_TimeLapse),
                                                 @(dpMsgCamera_isLive),
                                                 @(dpMsgBase_LED),
                                                 @(dpMsgVideo_diretion),
                                                 @(dpMsgBase_NTSC),
                                                 @(dpMsgBase_SIMInfo),
                                                 @(dpMsgCamera_Angle),
                                                 @(dpMsgCamera_WarnEnable),
                                                 ]];
            }
                break;
        }
        
        
    }
    return _dpsArray;
}

- (DeviceSettingModel *)settingModel
{
    if (_settingModel == nil)
    {
        _settingModel = [[DeviceSettingModel alloc] init];
        _settingModel.cid = self.cid;
    }
    return _settingModel;
}

@end
