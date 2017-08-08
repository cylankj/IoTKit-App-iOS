//
//  JFGBoundDevicesMsg.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGSDK.h>
#import "LoginManager.h"
#import "JfgCachePathManager.h"
#import "JfgConfig.h"
#import "CommonMethod.h"
#import "jfgConfigManager.h"
#import "JfgTypeDefine.h"

/*

终端类型定义
define("OS_SERVER",                             -1); 用于显示系统消息图标
define("OS_IOS_PHONE",                          0);
define("OS_PC",                                 1);
define("OS_ANDROID_PHONE",                      2);
define("OS_CAMARA_ANDROID_SERVICE",             3);                   备注: 2015.11.23，已废弃可复用
define("OS_CAMERA_ANDROID",                     4); //DOG-72          备注：Android 3G摄像头
define("OS_CAMERA_UCOS",                        5); //DOG-1W-V1       备注：WiFi摄像头 UCOS
define("OS_DOOR_BELL",                          6); //DOG-BELL        备注：门铃 WiFi主板
define("OS_CAMERA_UCOS_V2",                     7); //DOG-1W-V2       备注：WiFi摄像头 UCOS
define("OS_EFAML",                              8); //DOG-iHOME       备注：中控
define("OS_TEMP_HUMI",                          9);                   备注：温湿度        2016.9.9, 已废弃可复用
define("OS_IR",                                10);                   备注：红外感应      2016.9.9, 已废弃可复用
define("OS_MAGNET",                            11); //DOG-EN-MG       备注：中控 门磁
define("OS_AIR_DETECTOR",                      12);                   备注：中控 空气检测 2016.9.9, 已废弃可复用
define("OS_CAMERA_UCOS_V3",                    13); //DOG-1W-V3       备注：WiFi摄像头
define("OS_DOOR_BELL_CAM",                     14); //DOG-ML-CAM      备注：摄像头主板
define("OS_DOOR_BELL_V2",                      15); //DOG-BELL-V2     备注：Wifi狗主板,门铃功能 2015.10.28 zll
define("OS_CAMERA_ANDROID_4G",                 16); //DOG-82          备注：Android 4G摄像头
define("OS_CAMERA_CC3200",                     17); //DOG-CAM-CC3200  备注：乐视狗使用门铃包DOG-CAM-CC3200
define("OS_CAMERA_HS",                         18); //DOG-2W          备注：WiFi摄像头 海思       2016.9.21
define("OS_CAMERA_ZY",                         19); //DOG-3W          备注：WiFi摄像头 乔安 智源  2016.9.21
define("OS_CAMERA_GK",                         20); //DOG-4W          备注：WiFi摄像头 国科       2016.9.21
define("OS_CAMERA_5W",                         21); //DOG-5W          备注：双鱼眼

*/


@interface JFGBoundDevicesMsg()<JFGSDKCallbackDelegate,LoginManagerDelegate>

@property (nonatomic,strong)NSMutableArray *devicesList;
@property (nonatomic,strong)NSMutableArray *delDeviceList;

@end

@implementation JFGBoundDevicesMsg

+(instancetype)sharedDeciceMsg
{
    static dispatch_once_t onceToken;
    static JFGBoundDevicesMsg *msg = nil;
    dispatch_once(&onceToken, ^{
        msg = [[JFGBoundDevicesMsg alloc]init];
    });
    return msg;
}

-(instancetype)init
{
    self = [super init];
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillTerminateNotification object:nil];
    [[LoginManager sharedManager] addDelegate:self];
    return self;
}

-(void)applicationDidEnterBackground
{
    [self saveDeviceList:self.devicesList];
}

-(void)loginOutAccount
{
    [self.devicesList removeAllObjects];
}

-(void)loginOutForServer:(JFGErrorType)error
{
    [self.devicesList removeAllObjects];
}

-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
    NSMutableArray *newList = [[NSMutableArray alloc]init];
    NSArray <NSArray <AddDevConfigModel *>*>* allType = [jfgConfigManager getAddDevModel];
    
    
    [deviceList enumerateObjectsUsingBlock:^(JFGSDKDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        JiafeigouDevStatuModel *model = [[JiafeigouDevStatuModel alloc]init];
        model.uuid = obj.uuid;
        model.sn = obj.sn;
        model.alias = obj.alias;
        model.pid = obj.pid;
        model.Battery = 100;
        
        NSInteger typeMark = 0;
        
        for (NSArray *subArr in allType) {
            for (AddDevConfigModel *_model in subArr) {
                
                for (NSNumber *osNum in _model.osList) {
                    
                    if ([osNum intValue] == [model.pid intValue]) {
                        typeMark = [_model.typeMark intValue];
                        break;
                    }
                }
                if (typeMark !=0) {
                    break;
                }
            }
            if (typeMark !=0) {
                break;
            }
        }
        
        switch (typeMark) {
            case 2:
                model.deviceType = JFGDeviceTypePanoramicCamera;
                break;
            case 3:
            case 7:
                model.deviceType = JFGDeviceTypeDoorBell;
                break;
            default:
                model.deviceType = JFGDeviceTypeCameraWifi;
                break;
        }
        
        if ([obj.pid intValue] == 4 || [obj.pid intValue] == 1071) {
            //3G摄像头
            model.deviceType = JFGDeviceTypeCamera3G;
        }else if ([obj.pid intValue] == 16){
            //4G摄像头
            model.deviceType = JFGDeviceTypeCamera4G;
        }
        
        if ([obj.shareAccount isKindOfClass:[NSString class]] && ![obj.shareAccount isEqualToString:@""]) {
            model.shareState = DevShareStatuOther;
            NSLog(@"cid:%@ Show",model.uuid);
        }
        
        [self setValueFor720WithModel:model];
        [newList addObject:model];
        
    }];
    
    if (self.devicesList == nil || self.devicesList.count == 0) {

        self.devicesList = [[NSMutableArray alloc]initWithArray:newList];

    }else{
        
        //获取原始的信息
        for (JiafeigouDevStatuModel *model in [self.devicesList copy]) {
            
            for (JiafeigouDevStatuModel *newModel in newList) {
                
                if ([model.uuid isEqualToString:newModel.uuid] && [model.sn isEqualToString:newModel.sn]) {
                    
                    newModel.netType = model.netType;
                    newModel.unReadMsgCount = model.unReadMsgCount;
                    newModel.lastMsg = model.lastMsg;
                    newModel.lastMsgTime = model.lastMsgTime;
                    newModel.delayCamera = model.delayCamera;
                    newModel.Battery = model.Battery;
                    newModel.isPower = model.isPower;
                    newModel.safeIdle = model.safeIdle;
                    newModel.safeFence = model.safeFence;
                    newModel.doorcOpen = model.doorcOpen;
                    newModel.unReadPhotoCount = model.unReadPhotoCount;
                    
                    break;
                    
                }
            }
        }
        //检查是否有设备被删除
        //[self compareDeviceListForNetList:deviceList localList:self.devicesList];
        self.devicesList = [[NSMutableArray alloc]initWithArray:newList];
        
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BoundDevicesRefreshNotification object:nil];
}

-(void)setValueFor720WithModel:(JiafeigouDevStatuModel *)model
{
    if ([CommonMethod devBigTypeForOS:model.pid] == JFGDevBigTypeEyeCamera) {
        model.unReadMsgCount = 0;
        model.lastMsg = @"";
        model.safeIdle = NO;
        model.safeFence = NO;
    }
}


-(void)jfgOtherClientAnswerDoorbellForCid:(NSString *)cid
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"rev:门铃被其他端接听:%@",cid]];
}

//比较服务端设备数据与本地(判断是否有设备被取消分享，或者其他端删除)
-(void)compareDeviceListForNetList:(NSArray <JFGSDKDevice *>*)netList localList:(NSArray <JiafeigouDevStatuModel *>*)localList
{
    for (JiafeigouDevStatuModel *localModel in localList) {
        
        BOOL isExits = NO;
        for (JFGSDKDevice *netModel in netList) {
            
            if ([netModel.uuid isEqualToString:localModel.uuid]) {
                isExits = YES;
                break;
            }
            
        }
        if (!isExits) {
            //设备被删除了
            BOOL isOtherDel = YES;
            for (NSString *delCid in self.delDeviceList) {
                if ([delCid isEqualToString:localModel.uuid]) {
                    isOtherDel = NO;
                    break;
                }
            }
            if (isOtherDel) {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:localModel.uuid forKey:@"cid"];
                if (localModel.shareState == DevShareStatuOther) {
                    //取消分享了
                    NSLog(@"取消分享");
                    [dict setObject:[NSNumber numberWithInt:0] forKey:@"delType"];
                }else{
                    //其他端删除
                    NSLog(@"删除设备");
                    [dict setObject:[NSNumber numberWithInt:1] forKey:@"delType"];
                }
                //[[NSNotificationCenter defaultCenter] postNotificationName:JFGDeviceDelByOtherClientNotification object:dict];
                
            }
            
        }
        
    }
}

-(void)addDelDeviceCid:(NSString *)cid
{
    if ([cid isKindOfClass:[NSString class]]) {
        [self.delDeviceList addObject:cid];
    }
}

-(void)removeDelDeviceCid:(NSString *)cid
{
    if ([cid isKindOfClass:[NSString class]]) {
        for (NSString *_cid in [self.delDeviceList copy]) {
            if ([_cid isEqualToString:cid]) {
                [self.delDeviceList removeObject:_cid];
                break;
            }
        }
    }
}

//模型数组归档
-(void)saveDeviceList:(NSArray *)deviceList
{
    if (!deviceList.count) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:deviceList forKey:@"list"];
    //结束编码
    [archiver finishEncoding];
    //写入
    [data writeToFile:[self filePath] atomically:YES];
    //NSLog(@"%d",success);
}

-(void)clearDeviceList
{
    [self.devicesList removeAllObjects];
}

//解档
-(NSMutableArray <JiafeigouDevStatuModel *>*)getDevicesList
{
    if (self.devicesList == nil) {
        self.devicesList = [[NSMutableArray alloc]initWithArray:[self getCacheDeviceList]];
    }
    return self.devicesList;
}

- (JiafeigouDevStatuModel *)getDevModelWithCid:(NSString *)cid
{
    NSArray *devModels = [self getDevicesList];
    JiafeigouDevStatuModel *resultModel = nil;
    
    for (NSInteger i = 0; i < devModels.count; i ++)
    {
        resultModel = (JiafeigouDevStatuModel *)[devModels objectAtIndex:i];
        if ([resultModel.uuid isEqualToString:cid])
        {
            return resultModel;
        }
    }
    
    return resultModel;
}

-(NSArray *)getCacheDeviceList
{
    NSData *_data = [NSData dataWithContentsOfFile:[self filePath]];
    if (_data == nil) {
        return [NSArray new];
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
    //解档出数据模型Student
    //解码并解档出model
    NSArray *list = [unarchiver decodeObjectForKey:@"list"];
    //关闭解档
    [unarchiver finishDecoding];
    return list;
}

-(NSString *)filePath
{
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_deviceList.db",account]];
    return path;
}

-(NSMutableArray *)delDeviceList
{
    if (_delDeviceList == nil) {
        _delDeviceList = [[NSMutableArray alloc]init];
    }
    return _delDeviceList;
}

@end
