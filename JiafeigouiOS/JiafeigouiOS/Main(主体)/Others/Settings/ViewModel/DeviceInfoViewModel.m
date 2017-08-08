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
#import "JfgProductJduge.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGTypeDefine.h>
#import "ProgressHUD.h"
#import "JfgConstKey.h"
#import "JfgMsgDefine.h"
#import "JfgUserDefaultKey.h"
#import "CommonMethod.h"
#import "DeviceInfoModel.h"
#import "LoginManager.h"
#import "PropertyManager.h"
#import "JfgHttp.h"
#import "dataPointMsg.h"

@interface DeviceInfoViewModel()<JFGSDKCallbackDelegate>
{
}
@property (strong, nonatomic) NSMutableArray *groupArray; // 分组 数据
@property (strong, nonatomic) DeviceInfoModel * model;
@property (strong, nonatomic) NSArray * msgArray;

@property (nonatomic, assign) JFGNetType netWorkState;

@property (strong, nonatomic) PropertyManager *propertyTool;

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
                          [NSNumber numberWithInteger:dpMsgBase_Timezone],
                          [NSNumber numberWithInteger:dpMsgBase_Uptime],
                          [NSNumber numberWithInteger:dpMsgBase_ipAdress],
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
        _model.pType = self.pType;
    }
    return _model;
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

-(void)initModel:(NSMutableDictionary *)dict
{
    self.model.cid = self.cid;
    
    @try
    {
        NSArray *netArray = [dict objectForKey:msgBaseNetKey];
        if ([netArray isKindOfClass:[NSArray class]])
        {
            if (netArray.count >= 2)
            {
                self.model.netType = [[netArray firstObject] intValue];
                self.model.wifi = [netArray objectAtIndex:1];
                self.model.mobileNet = [netArray objectAtIndex:1];
            }
        }
        
        self.model.MAC = [dict objectForKey:msgBaseMacKey];
        self.model.sysVersion = [dict objectForKey:msgBaseSysVersionKey];
        self.model.softVersion = [dict objectForKey:msgBaseVersionKey];
        
        NSArray *timeZoneArr = [dict objectForKey:msgBaseTimeZoneKey];
        if (timeZoneArr.count >= 2)
        {
            self.model.timeZoneOrigin = [NSString stringWithFormat:@"%@",timeZoneArr[0]];
        }
        
        if ([JfgProductJduge isDoubleFishEyeDevice:self.pType])
        {
            JiafeigouDevStatuModel *devModel = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevModelWithCid:self.cid];
            
            NSNumber *battery = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"barrtyFor720_%@",self.cid]];
            
            self.model.battery = [NSString stringWithFormat:@"%d", [battery intValue]];
            
            BOOL isPrower = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"Perwor_%@",self.cid]];
            self.model.isCharging = isPrower;
            
            JFGLog(@"battery %@   isCharging %d",self.model.battery, self.model.isCharging);
        }
        else
        {
            self.model.battery = [[dict objectForKey:msgBaseBatteryKey] stringValue];
            self.model.isCharging = [[dict objectForKey:msgBasePowerKey] boolValue];
        }
        
        self.model.updateTime = [[dict objectForKey:msgBaseUptimeKey] longLongValue];
        self.model.ipAddress = [dict objectForKey:msgBaseIpAdressKey];
        
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
    switch (self.pType)
    {
        case productType_720p:
        case productType_720:
        {
            [JFGSDK checkTagDeviceVersionForCid:self.cid];
        }
            break;
            
        default:
        {
            if (self.model.softVersion != nil)
            {
                [JFGSDK checkDevVersionWithCid:self.cid pid:self.pType version:self.model.softVersion];
                
            }
            else
                [JFGSDK appendStringToLogFile:@"versoin is nil"];
        }
            break;
    }
    
    
        
}
// request data
- (void)request
{
    switch (self.pType)
    {
        case productType_720p:
        case productType_720:
        {
            if ([CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
            {
                [JFGSDK fping:@"255.255.255.255"];
                [JFGSDK fping:@"192.168.10.255"];
                
//                self.model.isSDCardExist = NO;
                
                return;
            }
            else
            {
                // sd卡状态
                DataPointSeg *seg1 = [DataPointSeg new];
                seg1.msgId = dpMsgBase_SDStatus;
                seg1.value = [NSData data];
                seg1.version = 0;
                // battery, power,
                
                [JFGSDK sendDPDataMsgForSockWithPeer:self.cid dpMsgIDs:@[seg1]];
            }
        }
            
        default:
        {
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
        }
            break;
    }
    
    
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
    
    [self request];
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
            
            NSMutableArray *section0 = [self infoSection0Arr];
            NSMutableArray *section1 = [self infoSection1Arr];
            NSMutableArray *section3 = [self infoSection3Arr];
            NSMutableArray *section4 = [self infoSection4Arr];
            NSMutableArray *section5 = [self infoSection5Arr];
            NSMutableArray *section6 = [self infoSection6Arr];
            
            if (section0.count > 0)
            {
                [self.groupArray addObject:section0];
            }
            if (section1.count > 0)
            {
                [self.groupArray addObject:section1];
            }
            if (section3.count > 0)
            {
                [self.groupArray addObject:section3];
            }
            if (section4.count > 0)
            {
                [self.groupArray addObject:section4];
            }
            if (section5.count > 0)
            {
                [self.groupArray addObject:section5];
            }
            if (section5.count > 0)
            {
                [self.groupArray addObject:section6];
            }
        }
            break;
//        case DeviceInfoTypeAutoPhoto:
//        {
//            [self.groupArray addObjectsFromArray:[self autoPhotoInfos]];
//        }
//            break;
            
        default:
        {
        }
            break;
    }
    
    return self.groupArray;
}

#pragma mark section data handle

- (NSMutableArray *)infoSection0Arr
{
    NSMutableArray *section0 = [NSMutableArray arrayWithCapacity:2];
    
    [section0 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"],cellTextKey,
                         deviceName,cellUniqueID,
                         self.model.deviceName,cellDetailTextKey,
                         @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                         nil]];
    
    
    return section0;
}
- (NSMutableArray *)infoSection1Arr
{
    NSMutableArray *section1 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pTimeZoneKey])
    {
        [section1 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"],cellTextKey,
                             timeZone,cellUniqueID,
                             self.model.timeZone,cellDetailTextKey,
                             self.model.timeZoneOrigin, cellHiddenText,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             nil]];
    }
    
    return (section1.count>0)?section1:nil;
}


- (NSMutableArray *)infoSection3Arr
{
    NSMutableArray *section3 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pDevUpgradeKey])
    {
        [section3 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"],cellTextKey,
                             devUpgrade,cellUniqueID,
                             self.model.softVersion,cellDetailTextKey,
                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                             @(self.model.hasNewPackage), cellRedDotInRight,
                             nil]];
    }
    
    return section3;
}

- (NSMutableArray *)infoSection4Arr
{
    NSMutableArray *section4 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pWifiInfoKey])
    {
        [section4 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Wi-Fi"],cellTextKey,
                             self.model.wifi,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    return section4;
}

- (NSMutableArray *)infoSection5Arr
{
    NSMutableArray *section5 = [NSMutableArray arrayWithCapacity:2];
    
    [section5 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"Tap1_Setting_Cid"],cellTextKey,
                             self.model.cid,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    
    
    if ([self.propertyTool showRowWithPid:self.pType key:pMacKey])
    {
        [section5 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"MAC"],cellTextKey,
                             self.model.MAC,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pIpAdress])
    {
        [section5 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"IP_Address"],cellTextKey,
                             self.model.ipAddress,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pSysVersionKey])
    {
        [section5 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"SYSTME_VERSION"],cellTextKey,
                             self.model.sysVersion,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pSoftVersionKey])
    {
        [section5 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"SOFTWARE_VERSION"],cellTextKey,
                             self.model.softVersion,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    return section5;
}

- (NSMutableArray *)infoSection6Arr
{
    NSMutableArray *section6 = [NSMutableArray arrayWithCapacity:2];
    
    if ([self.propertyTool showRowWithPid:self.pType key:pBatteryKey])
    {
        [section6 addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"BATTERY_LEVEL"],cellTextKey,
                             self.model.battery,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    if ([self.propertyTool showRowWithPid:self.pType key:pUpTimeKey])
    {
        [section6 addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                             [JfgLanguage getLanTextStrByKey:@"STANBY"],cellTextKey,
                             self.model.lastingUseTime,cellDetailTextKey,
                             @(UITableViewCellAccessoryNone),cellAccessoryKey,
                             nil]];
    }
    
    return section6;
}

#pragma mark
#pragma mark 数据 更新
- (void)updateTimeZone:(NSString *)zoneID timeZone:(int)zoneTime
{
    if([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess)
    {
        [CommonMethod showNetDisconnectAlert];
        
        return;
    }
        
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
- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([self.cid isEqualToString:ask.cid])
    {
        JFG_WS(weakSelf);
        
        [[JfgHttp sharedHttp] get:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getPowerLine", ask.address] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            weakSelf.model.isCharging = [[responseObject objectForKey:panoIsCharging] boolValue];
            [weakSelf update];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        [[JfgHttp sharedHttp] get:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getDevInfo", ask.address] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            weakSelf.model.updateTime = [[responseObject objectForKey:panoUptime] longLongValue];
            weakSelf.model.MAC = [responseObject objectForKey:mac];
            weakSelf.model.sysVersion = [responseObject objectForKey:sysVersion];
            [weakSelf update];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
    }
}


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
//                        case dpMsgBase_SDCardFomat:
//                        {
//                            if ([obj isKindOfClass:[NSArray class]])
//                            {
//                                NSArray *sdInfos = (NSArray *)obj;
//                                if (sdInfos.count >= 4)
//                                {
//                                    _model.sdCardError = [[sdInfos objectAtIndex:2] intValue];
//                                    _model.isSDCardExist = [[sdInfos objectAtIndex:3] boolValue];
//                                    
//                                    if (_model.sdCardError == 0)
//                                    {
//                                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips3"]];
//                                    }
//                                    else
//                                    {
//                                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
//                                    }
//                                }
//                                self.model.isClearingSDCard = NO;
//                                [self update];
//                            }
//                        }
//                            break;
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
//                        case dpMsgBase_SDCardInfoList:
//                        {
//                            if ([obj isKindOfClass:[NSArray class]])
//                            {
//                                BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
//                                if (isExistSDCard == NO)
//                                {
//                                    //show hub sdCard was pulled out
//                                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"]];
//                                }
//                                
//                                /*
//                                // if is Clearing SDCard now, then someone pull sdCard out
//                                if (self.model.isClearingSDCard == YES && isExistSDCard == NO)
//                                {
//                                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
//                                    self.model.isClearingSDCard = NO;
//                                }
//                                */
//                                self.model.isSDCardExist = isExistSDCard;
//                                self.model.sdCardError = [[obj objectAtIndex:1] intValue];
//                                [self update];
//                                
//                            }
//                        }
//                            break;
                    }
                }
            }
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"deviceInfo VM %@",exception]];
        } @finally {
            
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
    for (DataPointSeg *seg in dpMsgArr)
    {
        NSError *error = nil;
        id obj = [MPMessagePackReader readData:seg.value error:&error];
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"socket dpID[%llu]  value[%@]", seg.msgId, obj]];
        
        if (error == nil)
        {
            switch (seg.msgId)
            {
                case dpMsgBase_Power:
                {
                    self.model.isCharging = [obj boolValue];
                }
                    break;
                case dpMsgBase_Net:
                {
                    NSArray *netArray = (NSArray *)obj;
                    if (netArray.count >= 2)
                    {
                        self.model.netType = [[netArray firstObject] intValue];
                        self.model.wifi = [netArray objectAtIndex:1];
                        self.model.mobileNet = [netArray objectAtIndex:1];
                    }
                }
                    break;
                case dpMsgBase_Mac:
                {
                    self.model.MAC = obj;
                }
                    break;
                case dpMsgBase_SysVersion:
                {
                    self.model.sysVersion = obj;
                }
                    break;
                case dpMsgBase_Version:
                {
                    self.model.softVersion = obj;
                }
                    break;
                case dpMsgBase_Battery:
                {
                    self.model.battery = obj;
                }
                    break;
                // SDCard 插拔
//                case dpMsgBase_SDStatus:
//                {
//                    if ([obj isKindOfClass:[NSArray class]])
//                    {
//                        BOOL isExistSDCard = [[obj objectAtIndex:3] intValue];
//                        if (isExistSDCard == NO)
//                        {
//                            //show hub sdCard was pulled out
//                            if (initiative)
//                            {
//                                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"]];
//                            }
//                        }
//                        
//                        self.model.isSDCardExist = isExistSDCard;
//                        self.model.sdCardError = [[obj objectAtIndex:2] intValue];
//                        
//                    }
//                }
//                    break;
                case dpMsgBase_Timezone:
                {
                    NSArray *timeZoneArr = (NSArray *)obj;
                    if (timeZoneArr.count >= 2)
                    {
                        self.model.timeZoneOrigin = [NSString stringWithFormat:@"%@",timeZoneArr[0]];
                    }
                }
                    break;
                case dpMsgBase_Uptime:
                {
                    self.model.updateTime = [obj longLongValue];
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    [self update];
}


- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    self.model.hasNewPackage = info.hasNewPkg;
    
    [self update];
}

// 区块升级包 版本检测 回调
-(void)jfgDevCheckTagDeviceVersion:(NSString *)version
                          describe:(NSString *)describe
                          tagInfos:(NSArray <JFGSDKDevUpgradeInfoT *> *)infos
                               cid:(NSString *)cid
                         errorType:(JFGErrorType)errorType
{
    self.model.hasNewPackage = infos.count > 0;
    [self update];
}

@end
