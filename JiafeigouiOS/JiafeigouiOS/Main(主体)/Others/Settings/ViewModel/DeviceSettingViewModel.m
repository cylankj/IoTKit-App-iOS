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
#import "JfgHttp.h"
#import "JfgConstKey.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "DeviceSettingModel.h"
#import "JfgTypeDefine.h"
#import "JfgMsgDefine.h"
#import "JfgProductJduge.h"
#import "ProgressHUD.h"
#import "dataPointMsg.h"
#import "SDImageCache.h"
#import "JfgGlobal.h"
#import "JfgConfig.h"
#import "LSAlertView.h"
#import "LoginManager.h"
#import "JfgDataTool.h"
#import "JFGEquipmentAuthority.h"
#import "JfgUserDefaultKey.h"
#import "OemManager.h"
#import "CommonMethod.h"
#import "PropertyManager.h"
#import "WebChatBindViewController.h"
#import "ChangePhoneViewController.h"
#import "SetDeviceNameVC.h"

@interface DeviceSettingViewModel()<JFGSDKCallbackDelegate>

@property (strong, nonatomic) NSMutableArray *groupArray; // 分组 数据
@property (strong, nonatomic) NSMutableArray *dpsArray; //dps 数组

@property (strong, nonatomic) DeviceSettingModel *settingModel;
@property (strong, nonatomic) PropertyManager *propertyTool;
@property (nonatomic, assign) JFGNetType netWorkState;

@end

@implementation DeviceSettingViewModel

- (id)init
{
    self = [super init];
    if (self)
    {
        [JFGSDK addDelegate:self];
        
        _netWorkState = (JFGNetType)-1;
        
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
    self.settingModel.pType = type;
    
    if ([_delegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [self initModel:[self jfgDeviceSettingCahche]];
        [_delegate fetchDataArray:[self createDataWithProductType:type Cid:cid]]; //获取 初始数据
    }
    
    if ([PropertyManager showPropertiesRowWithPid:self.pType key:pHotWireless])
    {
        [self pingRequest];
    }
    
    switch (self.pType)
    {
//        case productType_IPCam:
//        case productType_IPCam_V2:
//        {
//            [self pingRequest];
//        }
        default:
        {
            [[dataPointMsg shared] packSingleDataPointMsg:self.dpsArray withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
                if (dic == nil)
                {
                    dic = [self jfgDeviceSettingCahche];
                }
                
                [self initModel:dic];
                [self update];
                
            } FailBlock:^(RobotDataRequestErrorType error) {
                
            }];
        }
            break;
    }    
    
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
        if ([wifiArray isKindOfClass:[NSArray class]])
        {
            if (wifiArray.count >= 2)
            {
                self.settingModel.deviceNetType = (DeviceNetType)[[wifiArray objectAtIndex:0] integerValue];
                self.settingModel.wifi = [wifiArray objectAtIndex:1];
            }
        }
        
        
        NSArray *deepSleepArr = [dict objectForKey:dpMsgBellDeepSleepKey];
        if ([deepSleepArr isKindOfClass:[NSArray class]]) {
            
            if (deepSleepArr.count > 2) {
                
                self.settingModel.isPowerSavingEnable = [[deepSleepArr objectAtIndex:0] boolValue];
                self.settingModel.powerSavingBeginTime = [[deepSleepArr objectAtIndex:1] longLongValue];
                self.settingModel.powerSavingEndTime = [[deepSleepArr objectAtIndex:2] longLongValue];
                
            }
            
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
        
        if ([JfgProductJduge isDoubleFishEyeDevice:self.pType] && [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
        {
            [self pingRequest];
        }
        else
        {
            NSArray *sdInfos = [dict objectForKey:msgBaseSDStatusKey];
            if (sdInfos.count >= 4)
            {
                self.settingModel.sdCardError = [[sdInfos objectAtIndex:2] intValue];
                self.settingModel.isExistSDCard = [[sdInfos objectAtIndex:3] boolValue];
            }
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
        
        self.settingModel.isWiredNetAvailalbe = [[dict objectForKey:msgBaseWiredNetAvailableKey] boolValue];
        self.settingModel.isUsingWiredNet = [[dict objectForKey:msgBaseUsingWiredNetKey] boolValue];
        
    } @catch (NSException *exception) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"deviceSettingVM %@",exception]];
    } @finally {
        
    }
}

- (void)pingRequest
{
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    
    self.settingModel.isInLocalNet = NO;
    [JFGSDK appendStringToLogFile:@"fping request in deviceSettingVM "];
}

// 关门 造 数据
- (NSArray *)createDataWithProductType:(productType)type Cid:(NSString *)cid
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"product Type in DevSetting [%ld]", type]];
    
    [self.groupArray removeAllObjects];
    
    if (self.isShare && (type != productType_720 && type != productType_720p))
    {
        [self.groupArray addObjectsFromArray:[self shareSettingsArray]];
    }
    else
    {
        switch (type)
        {
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
                                 deviceInfo, cellUniqueID,
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
    
    NSMutableArray *section0 = [self section0Arr];
    NSMutableArray *section1 = [self section1Arr];
    NSMutableArray *section1_1 = [self section1_1Arr];
    NSMutableArray *section2 = [self section2Arr];
    NSMutableArray *sdCardSection = [self sectionSDCardArr];
    NSMutableArray *section3 = [self section3Arr];
    NSMutableArray *section4 = [self section4Arr];
    NSMutableArray *clearMsgCallSetion = [self clearMsgCallSection];
    
    if (section0.count > 0)
    {
        [dogSettings addObject:section0];
    }
    if (section1.count > 0)
    {
        [dogSettings addObject:section1];
    }
    if (section1_1.count) {
        [dogSettings addObject:section1_1];
    }
    if (section2.count > 0)
    {
        [dogSettings addObject:section2];
    }
    if (sdCardSection.count > 0)
    {
        [dogSettings addObject:sdCardSection];
    }
    if (section3.count > 0)
    {
        [dogSettings addObject:section3];
    }
    if (section4.count > 0)
    {
        [dogSettings addObject:section4];
    }
    if (clearMsgCallSetion.count > 0)
    {
        [dogSettings addObject:clearMsgCallSetion];
    }
        
    return dogSettings;
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
    
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    
    if (account.wxopenid && ![account.wxopenid isEqualToString:@""] && account.wx_push == 1) {
        isPush = YES;
    }else{
        isPush = NO;
    }
    if (isPush) {
        [mineArr addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Alarm_WeChat"],cellTextKey,
                             @1,cellshowSwitchKey,
                             @(isPush),isCellSwitchOn,
                             @(self.settingModel.isShowWxRedDot), cellRedDotInRight,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil],
                            
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Change_ID"],cellTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             nil],
                            nil]];
        
        
    }else{
        [mineArr addObject:[NSArray arrayWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Alarm_WeChat"],cellTextKey,
                             @1,cellshowSwitchKey,
                             @(self.settingModel.isShowWxRedDot), cellRedDotInRight,
                             @(isPush),isCellSwitchOn,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil],nil]];
    }
    
    
    
    [mineArr addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"CLEAR_DATA"],cellTextKey,
                                 self.settingModel.cacheString,cellDetailTextKey,
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

#pragma mark section data handle

- (NSMutableArray *)section0Arr
{
    NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:2];
    
    [section0 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        @"set_icon_info",cellIconImageKey,
                        [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"],cellTextKey,
                         deviceInfo, cellUniqueID,
                        self.settingModel.info,cellDetailTextKey,
                        @0,cellshowSwitchKey,
                        @(self.settingModel.isCellCanClick), canClickCellKey,
                         nil]];
    
    
    return section0;
}
- (NSMutableArray *)section1Arr
{
    NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pWifiKey])
    {
        switch (self.pType)
        {
            case productType_720:
            case productType_720p:
            {
                [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     @"set_con_wifi",cellIconImageKey,
                                     wifiConfig, cellUniqueID,
                                     [JfgLanguage getLanTextStrByKey:@"Tap1_HomeMode"],cellTextKey,
                                     self.settingModel.wifi,cellDetailTextKey,
                                     @(self.settingModel.isCellCanClick), canClickCellKey,
                                     @0,cellshowSwitchKey,nil]];
            }
                break;
            
            default:
            {
                [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     @"set_con_wifi",cellIconImageKey,
                                     [JfgLanguage getLanTextStrByKey:@"WIFI"],cellTextKey,
                                     wifiConfig, cellUniqueID,
                                     self.settingModel.wifi,cellDetailTextKey,
                                     @0,cellshowSwitchKey,
                                     @(self.settingModel.isCellCanClick), canClickCellKey,
                                     nil]];
            }
                break;
        }
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pApConnectting])
    {
        [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"720_info_ap",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_OutdoorMode"],cellTextKey,
                             apConnectting, cellUniqueID,
                             self.settingModel.outdoorString,cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @1, canClickCellKey,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pHotWireless])
    {
        [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_hot_spots",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"Start_Hotspot"],cellTextKey,
                             hotWireless, cellUniqueID,
                             @0,cellshowSwitchKey,
                             [JfgLanguage getLanTextStrByKey:@"Start_Hotspot_Note"],cellFootViewTextKey,
                             @(self.settingModel.isHotWiredCanClick), canClickCellKey,
                             nil]];
    }
    
    if (self.settingModel.SIMCardType == SIMType_Using)
    {
        [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"set_icon_3g",cellIconImageKey,
                            [JfgLanguage getLanTextStrByKey:@"MOBILE_DATA"],cellTextKey,
                             mobileConfig, cellUniqueID,
                            @"",cellDetailTextKey,
                            @(self.settingModel.isMobile),isCellSwitchOn,
                            @(self.settingModel.isMobileCanClick), canClickCellKey,
                             @1,cellshowSwitchKey, nil]];
    }
    
    return (section1.count>0)?section1:nil;
}


-(NSMutableArray *)section1_1Arr
{
    NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:1];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pRemoteWatchKey]) {
        
        //deepsleep
        [section1 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"install_icon_power_saving",cellIconImageKey,
                             [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE"],cellTextKey,
                             deepsleep, cellUniqueID,
                             @"",cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.isShowDeepSleepRedDot), cellRedDotInRight,
                             nil]];
        
    }
    
    return section1;
}

- (NSMutableArray *)section2Arr
{
    NSMutableArray *section2 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pProtectionKey])
    {
        [section2 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"set_icon_safe",cellIconImageKey,
                            [JfgLanguage getLanTextStrByKey:@"SECURE"],cellTextKey,
                             safeProtect, cellUniqueID,
                            self.settingModel.safe,cellDetailTextKey,
                            @(self.settingModel.safeOrigin),cellHiddenText,
                            @0,cellshowSwitchKey,
                            @(self.settingModel.isCellCanClick), canClickCellKey,
                            @(self.settingModel.isShowSafeRedDot), cellRedDotInRight,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pRecordSettingKey])
    {
        [section2 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"set_icon_recording",cellIconImageKey,
                            [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"],cellTextKey,
                            recordSetting, cellUniqueID,
                            self.settingModel.autoPhoto,cellDetailTextKey,
                            @(self.settingModel.autoPhotoOrigin),cellHiddenText,
                            @0,cellshowSwitchKey,
                            @(self.settingModel.isCellCanClick), canClickCellKey,
                            @(self.settingModel.isShowAutoPhotoRedDot), cellRedDotInRight,
                             nil]];
    }
    
    return section2;
}

- (NSMutableArray *)sectionSDCardArr
{
    NSMutableArray *sectionSdCard = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pSDCardKey])
    {
        [sectionSdCard addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                  @"set_icon_sd",cellIconImageKey,
                                  microSDCard,cellUniqueID,
                                  self.settingModel.SDCardInfo,cellDetailTextKey,
                                  @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                  @(self.settingModel.isCellCanClick), canClickCellKey,
                                  @(self.settingModel.sdCardType), cellHiddenText,
                                  self.settingModel.detailTextColor, detailTextColorKey,
                                  nil]];
    }
    
    return sectionSdCard;
}


- (NSMutableArray *)section3Arr
{
    NSMutableArray *section3 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pStandByKey])
    {
        [section3 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"set_icon_standby",cellIconImageKey,
                             standBy, cellUniqueID,
                            [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Standby"],cellTextKey,
                            @(self.settingModel.isStandby),isCellSwitchOn,
                            @(self.settingModel.isStandByCanClick),canClickCellKey,
                             @1,cellshowSwitchKey, nil]];
    }
    
    return section3;
}

- (NSMutableArray *)section4Arr
{
    NSMutableArray *section4 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pAngleKey])
    {
        [section4 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"install_icon_angle",cellIconImageKey,
                             angle, cellUniqueID,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_ViewAngle"],cellTextKey,
                             self.settingModel.angleStr,cellDetailTextKey,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(self.settingModel.angleType), cellHiddenText,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pLedKey])
    {
        [section4 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            @"set_icon_light",cellIconImageKey,
                             indirector, cellUniqueID,
                            [JfgLanguage getLanTextStrByKey:@"LED"],cellTextKey,
                            @"",cellDetailTextKey,
                            @(self.settingModel.isOpenIndicator),isCellSwitchOn,
                            @(self.settingModel.isCellCanClick), canClickCellKey,
                             @1,cellshowSwitchKey, nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pHangUpKey])
    {
        [section4 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_overturn",cellIconImageKey,
                             hangup, cellUniqueID,
                             [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_VideoDirection"],cellTextKey,
                             @"",cellDetailTextKey,
                             @(self.settingModel.isRotate),isCellSwitchOn,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @1,cellshowSwitchKey, nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pNTSCKey])
    {
        [section4 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             @"set_icon_ntsc",cellIconImageKey,
                             ntsc, cellUniqueID,
                             [JfgLanguage getLanTextStrByKey:@"HZ_NTSC_PAL"],cellTextKey,
                             @(self.settingModel.isNTSC),isCellSwitchOn,
                             [JfgLanguage getLanTextStrByKey:@"FOOT_TIP_VOTE"],cellFootViewTextKey,
                             @1,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             nil]];
    }
    
    return section4;
}

- (NSMutableArray *)clearMsgCallSection
{
    NSMutableArray *section = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pCallMsg])
    {
        [section addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"DOOR_CLEAR_REOCRD"],cellTextKey,
                             clearCallMsg, cellUniqueID,
                             @0,cellshowSwitchKey,
                             @(self.settingModel.isCellCanClick), canClickCellKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey, nil]];
    }
    
    return  section;
}


#pragma mark
#pragma mark  更新字段 Action
#pragma mark --- public
#pragma mark 按钮 开关 触发事件

- (void)updateDataWithIndexPath:(NSIndexPath *)indexPath changedValue:(id)changedValue
{
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    NSLog(@"indexPath  uuid %@", [[self.groupArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    
    
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
                        case 1:
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
        case productType_IPCam:
        case productType_IPCam_V2:
        {
            switch (indexPath.section)
            {
                case 1:
                {
                    switch (indexPath.row)
                    {
                        case 1:     // 有线模式
                        {
//                            [self updateWiredNet:changedValue];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
//                case 3:
//                {
//                    switch (indexPath.row)
//                    {
//                        case 0: // 待机
//                        {
//                            [self updateStandBy:changedValue];
//                        }
//                            break;
//                            
//                        default:
//                            break;
//                    }
//                }
//                    break;
                case 3:
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
                        __weak typeof(self) weakSelf = self;
                        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                            weakSelf.settingModel.isRotate = [changedValue boolValue];
                            [weakSelf update];
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
        case productType_CesCamera:
        {
            switch (indexPath.section)
            {
                case 3: // 待机
                {
                    [self updateStandBy:changedValue];
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
                                __weak typeof(self) weakSelf = self;
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    weakSelf.settingModel.isOpenIndicator = [changedValue boolValue];
                                    [weakSelf update];
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
                                __weak typeof(self) weakSelf = self;
                                [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                                    weakSelf.settingModel.isNTSC = [changedValue boolValue];
                                    [weakSelf update];
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
        case productType_WIFI_V2:
        case productType_RS_120:
        case productType_WIFI:
        default:
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
    }
    
    
}

- (void)updateDataWithCelluuid:(NSString *)cellUniqueID changedValue:(id)changedValue
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cell witch uniqueID %@", cellUniqueID]];
    
    if ([cellUniqueID isEqualToString:indirector])
    {
        [self updateIndirector:changedValue];
    }
    else if ([cellUniqueID isEqualToString:standBy])
    {
        [self updateStandBy:changedValue];
    }
    else if ([cellUniqueID isEqualToString:hangup])
    {
        [self updateDiretion:changedValue];
    }
    else if ([cellUniqueID isEqualToString:ntsc])
    {
        [self updateNTSC:changedValue];
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
    
    __weak typeof(self) weakSelf = self;
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        weakSelf.settingModel.autoPhotoOrigin = (int)dectionType;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [weakSelf update];
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
    
    __weak typeof(self) weakSelf = self;
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        weakSelf.settingModel.autoPhotoOrigin = dectionType;
        if (isShow)
        {
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        }
        [weakSelf update];
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
    NSString *ap = [NSString stringWithFormat:@"DOG-2W-%@",[self.cid substringFromIndex:6]];
    NSString *currentWifi = [CommonMethod currentConnecttedWifi];
    
    if ([currentWifi isEqualToString:ap]) {
        self.settingModel.angleType = angleType;
        [self update];
    }else{
        __weak typeof(self) weakSelf = self;
        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
            weakSelf.settingModel.angleType = angleType;
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            [weakSelf update];
        } failed:^(RobotDataRequestErrorType error) {
            
        }];
    }
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

- (void)openHotWired
{
    NSString *msgTitle = nil;
    
    switch (self.settingModel.deviceNetType)
    {
        case DeviceNetType_Wifi:
        {
            msgTitle = [JfgLanguage getLanTextStrByKey:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Start_Hotspot_Prompt"], self.settingModel.wifi]];
        }
            break;
        case DeviceNetType_Wired:
        {
            msgTitle = [JfgLanguage getLanTextStrByKey:@"Cable_Mode_Start_Hotspot"];
        }
            break;
        default:
            return;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:msgTitle Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        
    } OKBlock:^{
        
        [weakSelf sendOpenHotWireMsg];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Instructions_Sent"]];
        [weakSelf performSelector:@selector(jfgSetAPRespose:) withObject:nil afterDelay:10.0];
    }];
}

#pragma mark private

// 更新 有线模式 开关
- (void)updateWiredNet:(id)isOpen
{
    JFG_WS(weakSelf);
    
    if ([isOpen boolValue] == NO) // 关闭
    {
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Cable_Mode_Switch_Cancel"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            weakSelf.settingModel.isUsingWiredNet = ![isOpen boolValue];
            [weakSelf update];
        } OKBlock:^{
            [weakSelf sendWiredNetMsg:isOpen];
        }];
    }
    else
    {
        [self sendWiredNetMsg:isOpen];
    }
    
}

// 发送 开启有线 消息
- (void)sendWiredNetMsg:(id)isOpen
{
    JFG_WS(weakSelf);
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:isOpen error:&error];
    
    seg.msgId = dpMsgBase_isUsingWiredNet;
    dpSegs = @[seg];
    
    if (!error)
    {
        [[dataPointMsg shared] setdpDataWithCid:weakSelf.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
            weakSelf.settingModel.isUsingWiredNet = [isOpen boolValue];
            [weakSelf update];
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            
        } failed:^(RobotDataRequestErrorType error) {
            
        }];
    }
}

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
            __weak typeof(self) weakSelf = self;
            [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic) {
                weakSelf.settingModel.isStandby = [changedValue boolValue];
                weakSelf.settingModel.isWarnEnable = NO;
                weakSelf.settingModel.isOpenIndicator = NO;
                weakSelf.settingModel.autoPhotoOrigin = MotionDetectNever;
                [weakSelf update];
                
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:JFGSettingOpenSafety object:changedValue];
                
            } failed:^(RobotDataRequestErrorType error) {
                
            }];
        }
    }
    else // 关闭 待机
    {
        __weak typeof(self) weakSelf = self;
        [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_isLive)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
            NSMutableArray *dpValues = [dic objectForKey:dpMsgCameraisLiveKey];
            [dpValues replaceObjectAtIndex:0 withObject:changedValue];
            
            seg.value = [MPMessagePackWriter writeObject:dpValues error:nil];
            
            [dpSegs addObject:seg];
            [dpSegs addObjectsFromArray:[weakSelf isLiveRelative:[dic objectForKeyedSubscript:dpMsgCameraisLiveKey]]];
            
            [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dpSegs success:^(NSMutableDictionary *dic)
            {
                weakSelf.settingModel.isStandby = [changedValue boolValue];
                weakSelf.settingModel.isWarnEnable = [[dpValues objectAtIndex:1] boolValue];
                weakSelf.settingModel.isOpenIndicator = [[dpValues objectAtIndex:2] boolValue];
                weakSelf.settingModel.autoPhotoOrigin = [[dpValues objectAtIndex:3] integerValue];
                [weakSelf update];
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

// 修改 设备指示灯
- (void)updateIndirector:(id)changedValue
{
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:changedValue error:&error];
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

- (void)updateDiretion:(id)changedValue
{
    NSArray *dpSegs = nil;
    NSError *error = nil;

    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:changedValue error:&error];
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
}

- (void)updateNTSC:(id)changedValue
{
    NSArray *dpSegs = nil;
    NSError *error = nil;
    
    DataPointSeg *seg = [[DataPointSeg alloc] init];
    seg.value = [MPMessagePackWriter writeObject:changedValue error:&error];
    
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
}

// 发送 开启热点消息
- (void)sendOpenHotWireMsg
{
    if (self.settingModel.ipAdress != nil)
    {
        [JFGSDK udpSetDevAPForCid:self.cid ip:self.settingModel.ipAdress model:1];
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"openHotWire udp ip address %@", self.settingModel.ipAdress]];
}

// 清空 SDcard
- (void)clearSDCard
{
    int sdcardClearDuration = 120.0f;
    
    if (self.netWorkState == JFGNetTypeOffline)
    {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
        return;
    }
    DataPointSeg *seg =[[DataPointSeg alloc]init];
    seg.msgId = dpMsgBase_FormatSD;
    seg.version = 0;
    [ProgressHUD shared].timeOutTip = [JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips5"];
    [ProgressHUD showProgress:[JfgLanguage getLanTextStrByKey:@"SD_INFO_2"] lastingTime:sdcardClearDuration];
    
    self.settingModel.isClearingSDCard = YES;
    [self performSelector:@selector(clearSDCardOverTime) withObject:nil afterDelay:sdcardClearDuration];
    
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
    } failure:^(RobotDataRequestErrorType type) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
    }];
}

- (void)clearSDCardFinish
{
    [ProgressHUD dismiss];
}

// clear sdcard overtime
- (void)clearSDCardOverTime
{
    self.settingModel.isClearingSDCard = NO;
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
        case productType_CesBell:
        case productType_CesBell_V2:
        case productType_RSDoorBell:
        case productType_CatEye:
        case productType_KKS_DoorBell:
        {
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc] init];
            seg.version = -1;
            seg.msgId = dpMsgBell_callMsg;
            
            DataPointIDVerSeg *seg1 = [[DataPointIDVerSeg alloc] init];
            seg1.version = -1;
            seg1.msgId = dpMsgBell_callMsgV3;
            
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:@[seg, seg1] success:^(NSString *identity, int ret) {
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
            
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark --- 网络代理 ---
- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([self.cid isEqualToString:ask.cid])
    {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"recevie fpingResponse"]];
        
        if ([PropertyManager showPropertiesRowWithPid:self.pType key:pHotWireless])
        {
            self.settingModel.ipAdress = ask.address;
            self.settingModel.isInLocalNet = YES;
        }
        
        
        switch (self.pType)
        {
//            case productType_IPCam:
//            case productType_IPCam_V2:
//            {
//                self.settingModel.ipAdress = ask.address;
//                self.settingModel.isInLocalNet = YES;
//            }
//                break;
            case productType_720p:
            case productType_720:
            {
                JFG_WS(weakSelf);
                [[JfgHttp sharedHttp] get:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getSdInfo", ask.address] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                    weakSelf.settingModel.isExistSDCard = [[responseObject objectForKey:panoSdCardExistKey] boolValue];
                    weakSelf.settingModel.sdCardError = [[responseObject objectForKey:panoSdCardError] intValue];
        
                    [weakSelf update];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
                break;
            default:
                break;
        }
        
        [self update];
    }
    
}

- (void)jfgSetAPRespose:(JFGSDKUDPResposeSetAP *)ask
{
    if (ask == nil)
    {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Start_Failed"]];
        return;
    }
    
    if ([ask.cid isEqualToString:self.cid])
    {
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Start_Success"]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(jfgSetAPRespose:) object:nil];
    }
}

-(void)jfgNetworkChanged:(JFGNetType)netType
{
    self.netWorkState = netType;
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
            JFGLog(@"___ push obj __ %@", obj);
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
                                self.settingModel.deviceNetType = (DeviceNetType)netType;
                                self.settingModel.wifi = [objArr objectAtIndex:1];
                                
                                if (![JfgDataTool deviceIsOnline:(DeviceNetType)netType])
                                {
                                    switch (self.pType)
                                    {
                                        case productType_IPCam:
                                        case productType_IPCam_V2:
                                        {
                                            [self pingRequest];     // 重新 检测局域网
                                        }
                                            break;
                                            
                                        default:
                                            break;
                                    }
                                }
                                [self updateSettingCell:[JfgDataTool deviceIsOnline:(DeviceNetType)netType]];
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
                    case dpMsgBase_isWiredNetAvailable:
                    {
                        self.settingModel.isWiredNetAvailalbe = [obj boolValue];
                        [self update];
                    }
                        break;
                    case dpMsgCamera_isLive:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            NSArray *isLiveArr = (NSArray *)obj;
                            if (isLiveArr.count >= 4)
                            {
                                self.settingModel.isStandby = [[isLiveArr objectAtIndex:0] boolValue];
                                self.settingModel.isWarnEnable = [[isLiveArr objectAtIndex:1] boolValue];
                                self.settingModel.isOpenIndicator = [[isLiveArr objectAtIndex:2] boolValue];
                                self.settingModel.autoPhotoOrigin = [[isLiveArr objectAtIndex:3] integerValue];
                                [self update];
                            }
                        }
                    }
                        break;
                    case dpMsgBase_SDCardFomat:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            NSArray *sdInfos = (NSArray *)obj;
                            if (sdInfos.count >= 4)
                            {
                                self.settingModel.sdCardError = [[sdInfos objectAtIndex:2] intValue];
                                self.settingModel.isExistSDCard = [[sdInfos objectAtIndex:3] boolValue];
                                
                                if (self.settingModel.sdCardError == 0)
                                {
                                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_INFO_3"]];
                                }
                                else
                                {
                                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
                                }
                            }
                            self.settingModel.isClearingSDCard = NO;
                            [self update];
                        }
                    }
                    break;
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
                    case dpMsgBase_SDStatus:
                    {
                        self.settingModel.isExistSDCard = [[obj objectAtIndex:3] intValue];
                        self.settingModel.sdCardError = [[obj objectAtIndex:2] intValue];
                        [self update];
                    }
                        break;
                    default:
                        break;
                }
            }
            
            
        }
    }
}

// 720 专用
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    if ([cid isEqualToString:self.cid]) {
        
        for (DataPointSeg *seg in dpMsgArr)
        {
            NSError *error = nil;
            id obj = [MPMessagePackReader readData:seg.value error:&error];
            
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"socket dpID[%llu]  value[%@]", seg.msgId, obj]];
            
            if (error == nil)
            {
                switch (seg.msgId)
                {
                        // SDCard 插拔
                    case dpMsgBase_SDStatus:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:3] intValue];
                            if (isExistSDCard == NO)
                            {
                                //show hub sdCard was pulled out
                                if (initiative)
                                {
                                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"]];
                                }
                            }
                            
                            self.settingModel.isExistSDCard = isExistSDCard;
                            self.settingModel.sdCardError = [[obj objectAtIndex:2] intValue];
                            
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
        [self update];
        
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
            case productType_CesBell:
            case productType_CesBell_V2:
            {
                [_dpsArray addObjectsFromArray:@[@(dpMsgBase_Net)]];
                if ([PropertyManager showPropertiesRowWithPid:self.pType key:pSDCardKey]) {
                    [_dpsArray addObject:@(dpMsgBase_SDStatus)];
                }
            }
                break;
                
            case productType_WIFI:
            case productType_CatEye:
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
                                                @(dpMsgBase_isWiredNetAvailable),
                                                 @(dpMsgBase_isUsingWiredNet)
                                                 ,@(dpMsgBell_deepSleep)]];
            }
                break;
        }
        
        
    }
    return _dpsArray;
}

- (PropertyManager *)propertyTool
{
    if (_propertyTool == nil)
    {
        _propertyTool = [[PropertyManager alloc] init];
        _propertyTool.propertyFilePath = [[NSBundle mainBundle] pathForResource:self.isShare?@"properties_share":@"properties" ofType:@"json"];
    }
    return _propertyTool;
}

- (BOOL)isClearingSDCard
{
    return self.settingModel.isClearingSDCard;
}

- (DeviceSettingModel *)settingModel
{
    if (_settingModel == nil)
    {
        _settingModel = [[DeviceSettingModel alloc] init];
        _settingModel.cid = self.cid;
        _settingModel.pType = self.pType;
        _settingModel.isShare = self.isShare;
    }
    return _settingModel;
}

@end
