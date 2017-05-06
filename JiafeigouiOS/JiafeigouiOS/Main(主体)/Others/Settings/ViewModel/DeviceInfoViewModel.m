//
//  DeviceInfoViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceInfoViewModel.h"
#import "JfgTableViewCellKey.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/MPMessagePackReader.h>
#import <JFGSDK/JFGTypeDefine.h>
#import "ProgressHUD.h"
#import "JfgMsgDefine.h"
#import "JfgUserDefaultKey.h"
#import "DeviceInfoModel.h"
#import "dataPointMsg.h"

@interface DeviceInfoViewModel()<JFGSDKCallbackDelegate>
{
}
@property (strong, nonatomic) NSMutableArray *groupArray; // 分组 数据
@property (strong, nonatomic) DeviceInfoModel * model;
@property (strong, nonatomic) NSArray * msgArray;

@property (nonatomic, assign) JFGNetType netWorkState;

@end

@implementation DeviceInfoViewModel

-(instancetype)init{
    if (self = [super init])
    {
        self.msgArray = @[[NSNumber numberWithInteger:dpMsgBase_Power],
                          [NSNumber numberWithInteger:dpMsgBase_Net],
                          [NSNumber numberWithInteger:dpMsgBase_Mac],
                          [NSNumber numberWithInteger:dpMsgBase_SysVersion],
                          [NSNumber numberWithInteger:dpMsgBase_Version],
                          [NSNumber numberWithInteger:dpMsgBase_Battery],
                          [NSNumber numberWithInteger:dpMsgBase_SDStatus],
                          [NSNumber numberWithInteger:dpMsgBase_Timezone],
                          [NSNumber numberWithInteger:dpMsgBase_Uptime]
                          ];
        
        [JFGSDK addDelegate:self];
        _netWorkState = (JFGNetType)-1;
    }
    return self;
}
#pragma mark setter
- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] init];
    }
    return _groupArray;
}

-(DeviceInfoModel *)model{
    if (!_model)
    {
        _model = [[DeviceInfoModel alloc]init];
    }
    return _model;
}

- (BOOL)isClearingSDCard
{
    return self.model.isClearingSDCard;
}

// clear sdcard overtime
- (void)clearSDCardOverTime
{
    self.model.isClearingSDCard = NO;
}

-(void)initModel:(NSMutableDictionary *)dict
{
    self.model.cid = self.cid;
    
    @try
    {
        NSArray *sdInfos = [dict objectForKey:msgBaseSDStatusKey];
        if (sdInfos.count >= 4)
        {
            self.model.totalSpace = [[sdInfos objectAtIndex:0] longLongValue];
            self.model.usedSpace = [[sdInfos objectAtIndex:1] longLongValue];
            self.model.sdCardError = [[sdInfos objectAtIndex:2] intValue];
            self.model.isSDCardExist = [[sdInfos objectAtIndex:3] boolValue];
        }
        
        NSArray *netArray = [dict objectForKey:msgBaseNetKey];
        if (netArray.count >= 2)
        {
            self.model.netType = [[netArray firstObject] intValue];
            self.model.wifi = [netArray objectAtIndex:1];
            self.model.mobileNet = [netArray objectAtIndex:1];
        }
        
        self.model.MAC = [dict objectForKey:msgBaseMacKey];
        self.model.sysVersion = [dict objectForKey:msgBaseSysVersionKey];
        self.model.version = [dict objectForKey:msgBaseVersionKey];
        self.model.battery = [[dict objectForKey:msgBaseBatteryKey] stringValue];
        
        NSArray *timeZoneArr = [dict objectForKey:msgBaseTimeZoneKey];
        if (timeZoneArr.count >= 2)
        {
            self.model.timeZoneOrigin = [NSString stringWithFormat:@"%@",timeZoneArr[0]];
        }
        
        self.model.isCharging = [[dict objectForKey:msgBasePowerKey] boolValue];
        self.model.updateTime = [[dict objectForKey:msgBaseUptimeKey] longLongValue];
        [self checkNewPackage];
    }
    @catch (NSException *exception)
    {
        NSLog(@" deviceInfoViewModel exception ____%@",exception);
    }
    @finally
    {
        
    }

}

#pragma mark
#pragma mark  设备信息 缓存 存取
- (void)setJfgDeviceInfoCache:(NSDictionary *)dict
{
    if (dict != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:jfgDeviceInfoCache(self.cid)];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (NSMutableDictionary *)getJfgDeviceInfoCache
{
    NSMutableDictionary *dictCache = [[NSUserDefaults standardUserDefaults] objectForKey:jfgDeviceInfoCache(self.cid)];
    return dictCache;
}


#pragma mark
#pragma mark 数据请求
- (void)checkNewPackage
{
    if (self.model.version != nil)
    {
        [JFGSDK checkDevVersionWithCid:self.cid pid:self.pType version:self.model.version];
    }
    else
        [JFGSDK appendStringToLogFile:@"versoin is nil"];
        
}

#pragma mark 
#pragma mark 创建数据

- (NSArray *)dataArrayFromViewModelWithProductType:(productType)type Cid:(NSString *)cid
{
    self.cid = cid;
    self.pType = type;
    
    if ([self.myDelegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [self initModel:[self getJfgDeviceInfoCache]];
        
        [self.myDelegate fetchDataArray:[self createDataWithProductType:type Cid:cid]];
    }
    
    [[dataPointMsg shared] packSingleDataPointMsg:self.msgArray withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic)
     {
         if (dic == nil)
         {
             dic = [self getJfgDeviceInfoCache];
         }
         else
         {
             [self setJfgDeviceInfoCache:dic];
         }
         
         [self initModel:dic];
         [self update];
     } FailBlock:^(RobotDataRequestErrorType error)
     {
     }];
    
    
    return [self createDataWithProductType:type Cid:cid];
}

// 关门 造 数据
- (NSArray *)createDataWithProductType:(productType)type Cid:(NSString *)cid
{
    NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    JiafeigouDevStatuModel *currentModel;
    NSString *alias;
    
    
    for (JiafeigouDevStatuModel *model in list) {
        
        if ([model.uuid isEqualToString:cid] || [model.sn isEqualToString:cid]) {
            
            currentModel = model;
            break;
            
        }
        
    }
    
    if ([currentModel.alias isEqualToString:@""]) {
        alias = currentModel.uuid;
    }else{
        alias = currentModel.alias;
    }
    self.model.deviceName = alias;
    self.cid = currentModel.uuid;
    
    [self.groupArray removeAllObjects];
    switch (_deviceInfoType)
    {
        case DeviceInfoTypeInfo:
        {
            switch (type)
            {
                case productType_Mag:
                {
                    [self.groupArray addObjectsFromArray:[self magInfos]];
                }
                    break;
                case productType_DoorBell:
                {
                    [self.groupArray addObjectsFromArray:[self doorBellInfos]];
                }
                    break;
                case productType_3G:
                case productType_4G:
                case productType_3G_2X:
                {
                    [self.groupArray addObjectsFromArray:[self mobileDeviceInfos]];
                }
                    break;
                case productType_IPCam:
                case productType_RS_180:
                case productType_RS_120:
                case productType_WIFI:{
                    [self.groupArray addObjectsFromArray:[self wifiDevicesInfos]];
                }
                    break;
                case productType_Camera_ZY:
                case productType_Camera_HS:
                {
                    [self.groupArray addObjectsFromArray:[self panoDevicesInfos]];
                }
                    break;
                case productType_FreeCam:
                {
                    [self.groupArray addObjectsFromArray:[self freeCamInfos]];
                }
                    break;
                default:
                {
                    [self.groupArray addObject:[NSArray arrayWithObjects:
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                                                 alias,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                                 nil],
                                                nil]];
                    if (self.isShare == NO)
                    {
                        [self.groupArray addObject:[NSArray arrayWithObjects:
                                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                                                     self.model.timeZone,cellDetailTextKey,
                                                     self.model.timeZoneOrigin, cellHiddenText,
                                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                                     nil],
                                                    nil]];
                        
                        [self.groupArray addObject:[NSArray arrayWithObjects:
                                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                                     self.model.SDCardInfo,cellDetailTextKey,
                                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                                     @(self.model.sdCardType), cellHiddenText,
                                                     nil],
                                                    nil]];
                        
                    }
                    [self.groupArray addObject:[NSArray arrayWithObjects:
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"NETWORK_1"],cellTextKey,
                                                 self.model.net,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                                 nil],
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                                                 self.model.wifi,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                                 nil],
                                                nil]];
                    
                    [self.groupArray addObject:[NSArray arrayWithObjects:
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                                                 self.model.cid,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                                 nil],
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                                                 self.model.MAC,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                                 nil],
                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                                                 self.model.sysVersion,cellDetailTextKey,
                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                                 nil],
//                                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                 [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
//                                                 self.model.version,cellDetailTextKey,
//                                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
//                                                 nil],
                                                nil]];

                [self.groupArray addObject:[NSArray arrayWithObjects:
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                                             self.model.battery,cellDetailTextKey,
                                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                             nil],
                                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                                             self.model.SDCardSpace,cellDetailTextKey,
                                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                             nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                                             self.model.lastingUseTime,cellDetailTextKey,
                                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                             nil],
                                            nil]];
                    
                }
                    break;
            }
        }
            break;
        case DeviceInfoTypeAutoPhoto:
        {
            [self.groupArray addObjectsFromArray:[self autoPhotoInfos]];
        }
            break;
            
        default:
        {
        }
            break;
    }
    
    return self.groupArray;
}

#pragma mark
#pragma mark 数据 获取 方法
// 门磁数据
- (NSMutableArray *)magInfos
{
    NSMutableArray *magArray = [NSMutableArray arrayWithCapacity:5];
    
    [magArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                                 self.model.deviceName,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 nil],
                                nil]];
    [magArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"MODEL"],cellTextKey,
                                 [JfgLanguage getLanTextStrByKey:@"xyz"],cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"SN"],cellTextKey,
                                 [JfgLanguage getLanTextStrByKey:@"48488484884"],cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    [magArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                                 self.model.battery,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                                 self.model.lastingUseTime,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    
    return magArray;
}
// 门铃数据
- (NSMutableArray *)doorBellInfos
{
    NSMutableArray *doorBellArr = [NSMutableArray arrayWithCapacity:5];
    
    [doorBellArr addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                                 self.model.deviceName,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 nil],
                                nil]];
    [doorBellArr addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                                 self.model.cid,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                                 self.model.MAC,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                                 self.model.sysVersion,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                /*[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                                 self.model.version,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],*/
                                nil]];
    if (!self.isShare)
    {
        [doorBellArr addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                                 self.model.newPackageStr,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 @(self.model.hasNewPackage), cellRedDotInRight,
                                 @(self.model.hasNewPackage), cellHiddenText,
                                 nil],
                                nil]];
    }
    
    [doorBellArr addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                                 self.model.wifi,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    [doorBellArr addObject:[NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                             self.model.battery,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                             self.model.lastingUseTime,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil],
                            nil]];
    
    
    return doorBellArr;
 }
// wifi 狗 设备信息
- (NSMutableArray *)wifiDevicesInfos
{
    NSMutableArray *wifiArray = [NSMutableArray arrayWithCapacity:5];
    
    [wifiArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                                 self.model.deviceName,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 nil],
                                nil]];
    if (self.isShare == NO)
    {
        [wifiArray addObject:[NSArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                                     self.model.timeZone,cellDetailTextKey,
                                     self.model.timeZoneOrigin, cellHiddenText,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     nil],
                                    nil]];
        
        [wifiArray addObject:[NSArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                     self.model.SDCardInfo,cellDetailTextKey,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     @(self.model.sdCardType), cellHiddenText,
                                     nil],
                                    nil]];
        [wifiArray addObject:[NSArray arrayWithObjects:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                               self.model.newPackageStr,cellDetailTextKey,
                               @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                               @(self.model.hasNewPackage), cellRedDotInRight,
                               nil],
                              nil]];
    }
    
    [wifiArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                                 self.model.wifi,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    
    [wifiArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                                 self.model.cid,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                                 self.model.MAC,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                                 self.model.sysVersion,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
//                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                 [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
//                                 self.model.version,cellDetailTextKey,
//                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
//                                 nil],
                                nil]];
    
    [wifiArray addObject:[NSArray arrayWithObjects:
                          /*[NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                           self.model.battery,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],*/
                          //                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          //                                 [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                          //                                 self.model.SDCardSpace,cellDetailTextKey,
                          //                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                          //                                 nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                           self.model.lastingUseTime,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],
                          nil]];
    
    
    return wifiArray;
}
// 3G,4G 设备信息
- (NSMutableArray *)mobileDeviceInfos
{
    NSMutableArray *mobileArray = [NSMutableArray arrayWithCapacity:5];
    
    [mobileArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                                 self.model.deviceName,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 nil],
                                nil]];
    if (self.isShare == NO)
    {
        [mobileArray addObject:[NSArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                                     self.model.timeZone,cellDetailTextKey,
                                     self.model.timeZoneOrigin, cellHiddenText,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     nil],
                                    nil]];
        
        [mobileArray addObject:[NSArray arrayWithObjects:
                                    [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                     self.model.SDCardInfo,cellDetailTextKey,
                                     @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                     @(self.model.sdCardType), cellHiddenText,
                                     nil],
                                    nil]];
        
        [mobileArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                                 self.model.newPackageStr,cellDetailTextKey,
                                 @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                 @(self.model.hasNewPackage), cellRedDotInRight,
                                 nil],
                                nil]];
    }
    
    [mobileArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"NETWORK_1"],cellTextKey,
                                 self.model.mobileNet,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                                 self.model.wifi,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    
    [mobileArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                                 self.model.cid,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                                 self.model.MAC,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                                 self.model.sysVersion,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
//                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                 [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
//                                 self.model.version,cellDetailTextKey,
//                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
//                                 nil],
                                nil]];
    

    [mobileArray addObject:[NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                             self.model.battery,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil],
                            //                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            //                                 [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                            //                                 self.model.SDCardSpace,cellDetailTextKey,
                            //                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            //                                 nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                             self.model.lastingUseTime,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil],
                            nil]];

    return mobileArray;
}

- (NSMutableArray *)freeCamInfos
{
    NSMutableArray *freeeCamArr = [NSMutableArray arrayWithCapacity:5];
    
    [freeeCamArr addObject:[NSArray arrayWithObjects:
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                           self.model.deviceName,cellDetailTextKey,
                           @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                           nil],
                          nil]];
    if (self.isShare == NO)
    {
        [freeeCamArr addObject:[NSArray arrayWithObjects:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                               self.model.timeZone,cellDetailTextKey,
                               self.model.timeZoneOrigin, cellHiddenText,
                               @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                               nil],
                              nil]];
        
        [freeeCamArr addObject:[NSArray arrayWithObjects:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                               self.model.SDCardInfo,cellDetailTextKey,
                               @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                               @(self.model.sdCardType), cellHiddenText,
                               nil],
                              nil]];
        [freeeCamArr addObject:[NSArray arrayWithObjects:
                              [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                               self.model.newPackageStr,cellDetailTextKey,
                               @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                               @(self.model.hasNewPackage), cellRedDotInRight,
                               nil],
                              nil]];
    }
    
    [freeeCamArr addObject:[NSArray arrayWithObjects:
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                           self.model.wifi,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],
                          nil]];
    
    [freeeCamArr addObject:[NSArray arrayWithObjects:
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                           self.model.cid,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                           self.model.MAC,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],
                          [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                           self.model.sysVersion,cellDetailTextKey,
                           @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           nil],
                          //                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          //                                 [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                          //                                 self.model.version,cellDetailTextKey,
                          //                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                          //                                 nil],
                          nil]];
    
        [freeeCamArr addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                                 self.model.battery,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                //                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                //                                 [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                                //                                 self.model.SDCardSpace,cellDetailTextKey,
                                //                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                //                                 nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                                 self.model.lastingUseTime,cellDetailTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    
    return freeeCamArr;
}

// 全景 摄像头 设备信息
- (NSMutableArray *)panoDevicesInfos
{
    return [self hSDevicesInfos];
}
// HS 设备信息
- (NSMutableArray *)hSDevicesInfos
{
    NSMutableArray *hsArray = [NSMutableArray arrayWithCapacity:5];
    [hsArray addObject:[NSArray arrayWithObjects:
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                         self.model.deviceName,cellDetailTextKey,
                         @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                         nil],
                        nil]];
    if (self.isShare == NO)
    {
        [hsArray addObject:[NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                             self.model.timeZone,cellDetailTextKey,
                             self.model.timeZoneOrigin, cellHiddenText,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             nil],
                            nil]];
        
        [hsArray addObject:[NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                             self.model.SDCardInfo,cellDetailTextKey,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             @(self.model.sdCardType), cellHiddenText,
                             nil],
                            nil]];
        /*
        [hsArray addObject:[NSArray arrayWithObjects:
                            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                             self.model.newPackageStr,cellDetailTextKey,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             @(self.model.hasNewPackage), cellRedDotInRight,
                             nil],
                            nil]];*/
    }
    
    [hsArray addObject:[NSArray arrayWithObjects:
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                         self.model.wifi,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        nil]];
    
    [hsArray addObject:[NSArray arrayWithObjects:
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                         self.model.cid,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                         self.model.MAC,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                         self.model.sysVersion,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                         self.model.version,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        nil]];
    
    [hsArray addObject:[NSArray arrayWithObjects:
                        /* [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                         self.model.battery,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],*/
                        //                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        //                                 [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                        //                                 self.model.SDCardSpace,cellDetailTextKey,
                        //                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                        //                                 nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                         self.model.lastingUseTime,cellDetailTextKey,
                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                         nil],
                        nil]];
    
    
    return hsArray;
}
// 乔安 设备信息
- (NSMutableArray *)jooanDevicesInfos
{
    NSMutableArray *jooanArray = [NSMutableArray arrayWithCapacity:5];
    [jooanArray addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                            self.model.deviceName,cellDetailTextKey,
                            @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                            nil],
                           nil]];
    if (self.isShare == NO)
    {
        [jooanArray addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                                self.model.timeZone,cellDetailTextKey,
                                self.model.timeZoneOrigin, cellHiddenText,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                nil],
                               nil]];
        
        [jooanArray addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                self.model.SDCardInfo,cellDetailTextKey,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                @(self.model.sdCardType), cellHiddenText,
                                nil],
                               nil]];
        
        [jooanArray addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                                self.model.newPackageStr,cellDetailTextKey,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                @(self.model.hasNewPackage), cellRedDotInRight,
                                nil],
                               nil]];
    }
    
    [jooanArray addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"NETWORK_1"],cellTextKey,
                            self.model.net,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                            self.model.wifi,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           nil]];
    
    [jooanArray addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                            self.model.cid,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                            self.model.MAC,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                            self.model.sysVersion,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           //                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           //                         [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                           //                         self.model.version,cellDetailTextKey,
                           //                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           //                         nil],
                           nil]];

    [jooanArray addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                            self.model.battery,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           //                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           //                         [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                           //                         self.model.SDCardSpace,cellDetailTextKey,
                           //                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           //                         nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                            self.model.lastingUseTime,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           nil]];
    
    return jooanArray;
}
- (NSMutableArray *)Pano720CameraInfos
{
    NSMutableArray *pano720Infos = [NSMutableArray arrayWithCapacity:5];
    [pano720Infos addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                            self.model.deviceName,cellDetailTextKey,
                            @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                            nil],
                           nil]];
    
    
    if (self.isShare == NO)
    {
        [pano720Infos addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                                self.model.timeZone,cellDetailTextKey,
                                self.model.timeZoneOrigin, cellHiddenText,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                nil],
                               nil]];
        
        [pano720Infos addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"SETTING_SD"],cellTextKey,
                                self.model.SDCardInfo,cellDetailTextKey,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                @(self.model.sdCardType), cellHiddenText,
                                nil],
                               nil]];
        
        [pano720Infos addObject:[NSArray arrayWithObjects:
                               [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                                self.model.newPackageStr,cellDetailTextKey,
                                @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                @(self.model.hasNewPackage), cellRedDotInRight,
                                nil],
                               nil]];
    }
    
    [pano720Infos addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"NETWORK_1"],cellTextKey,
                            self.model.net,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                            self.model.wifi,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           nil]];
    
    [pano720Infos addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                            self.model.cid,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                            self.model.MAC,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                            self.model.sysVersion,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           //                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           //                         [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                           //                         self.model.version,cellDetailTextKey,
                           //                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           //                         nil],
                           nil]];
    
    [pano720Infos addObject:[NSArray arrayWithObjects:
                           [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                            self.model.battery,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           //                        [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           //                         [JfgLanguage getLanTextStrByKey:@"VALID_STORAGE"],cellTextKey,
                           //                         self.model.SDCardSpace,cellDetailTextKey,
                           //                         @(UITableViewCellAccessoryNone),cellAccessoryKey,
                           //                         nil],
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                            self.model.lastingUseTime,cellDetailTextKey,
                            @(UITableViewCellAccessoryNone),cellAccessoryKey,
                            nil],
                           nil]];
    
    return pano720Infos;
}



// 自动录像
- (NSMutableArray *)autoPhotoInfos
{
    NSMutableArray *autoPhotoArray = [NSMutableArray arrayWithCapacity:5];
    [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"RECORD_MODE"],cellTextKey,
                                 [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_0"],cellFootViewTextKey,
                                 @(UITableViewCellAccessoryCheckmark),cellAccessoryKey,
                                 nil],
                                nil]];
    
    if (self.pType != productType_FreeCam)
    {
        [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_1"],cellTextKey,
                                    [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_1"],cellFootViewTextKey,
                                    @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                    nil],
                                   nil]];
    }
    
    [autoPhotoArray addObject:[NSArray arrayWithObjects:
                                [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_2"],cellTextKey,
                                 [JfgLanguage getLanTextStrByKey:@"RECORD_INFO_2"],cellFootViewTextKey,
                                 @(UITableViewCellAccessoryNone),cellAccessoryKey,
                                 nil],
                                nil]];
    return autoPhotoArray;
}

#pragma mark
#pragma mark 数据 更新
- (void)updateTimeZone:(NSString *)zoneID timeZone:(int)zoneTime
{
    DataPointSeg * seg = [[DataPointSeg alloc]init];
    NSError * error = nil;
    seg.msgId = dpMsgBase_Timezone;
    seg.value = [MPMessagePackWriter writeObject:@[zoneID,[NSNumber numberWithInteger:zoneTime]] error:&error];
    NSArray * dps = @[seg];
    
    [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
        self.model.timeZoneOrigin = zoneID;
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        [self update];
    } failed:^(RobotDataRequestErrorType error) {
        
    }];
}

- (void)updateAliasWithString:(NSString *)newAlias
{
    self.model.deviceName = newAlias;
    [self update];
}

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
    
    self.model.isClearingSDCard = YES;
    [self performSelector:@selector(clearSDCardOverTime) withObject:nil afterDelay:sdcardClearDuration];
    
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
    } failure:^(RobotDataRequestErrorType type) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
    }];
}

-(void)update
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(updatedDataArray:)])
    {
        [_myDelegate updatedDataArray:[self createDataWithProductType:self.pType Cid:self.cid]];
    }
}

#pragma mark
#pragma mark  sdk delegate
- (void)jfgNetworkChanged:(JFGNetType)netType
{
    self.netWorkState = netType;
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray <DataPointSeg *> *)msgList
{
    if (self.deviceInfoType == DeviceInfoTypeInfo)
    {
        @try
        {
            for (DataPointSeg *seg in msgList)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (error == nil)
                {
                    switch (seg.msgId)
                    {
                        case dpMsgBase_SDCardFomat:
                        {
                            if ([obj isKindOfClass:[NSArray class]])
                            {
                                NSArray *sdInfos = (NSArray *)obj;
                                if (sdInfos.count >= 4)
                                {
                                    _model.sdCardError = [[sdInfos objectAtIndex:2] intValue];
                                    _model.isSDCardExist = [[sdInfos objectAtIndex:3] boolValue];
                                    
                                    if (_model.sdCardError == 0)
                                    {
                                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_INFO_3"]];
                                    }
                                    else
                                    {
                                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
                                    }
                                }
                                self.model.isClearingSDCard = NO;
                                [self update];
                            }
                        }
                            break;
                        case dpMsgBase_Battery:
                        {
                            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cid[%@]'s battery %@",self.cid, obj]];
                            self.model.battery = obj;
                            [self update];
                        }
                            break;
                        case dpMsgBase_Power:
                        {
                            self.model.isCharging = [obj boolValue];
                            [self update];
                        }
                            break;
                        case dpMsgBase_SDCardInfoList:
                        {
                            if ([obj isKindOfClass:[NSArray class]])
                            {
                                BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                                
                                self.model.isSDCardExist = isExistSDCard;
                                self.model.sdCardError = [[obj objectAtIndex:1] intValue];
                                [self update];
                                
                            }
                        }
                            break;
                    }
                }
            }
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jifeigou RootViewControl %@",exception]];
        } @finally {
            
        }
    }
    
    
}

- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    self.model.hasNewPackage = info.hasNewPkg;
    
    [self update];
}

@end
