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
#import "JFGGrayPolicyManager.h"
#import "DevicesViewModel.h"



@interface JFGBoundDevicesMsg()<JFGSDKCallbackDelegate,LoginManagerDelegate>

@property (nonatomic,strong)NSMutableArray *devicesList;
@property (nonatomic,strong)NSMutableArray *delDeviceList;
@property (nonatomic,strong)NSMutableArray *newDevCidList;
@property (nonatomic,strong)DevicesViewModel *devicesVM;
@property (nonatomic,strong)NSArray *devList;

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
            case 6:
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
                    newModel.iconPath = model.iconPath;
                    newModel.offlineIconPath = model.offlineIconPath;
                    [self iconPathForModel:newModel];
                    break;
                    
                }
            }
        }
        //检查是否有设备被删除
        //[self compareDeviceListForNetList:deviceList localList:self.devicesList];
        self.devicesList = [[NSMutableArray alloc]initWithArray:newList];
        
    }
    
    [JFGGrayPolicyManager reqGrayPolicy];
    [self setDefaultValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:BoundDevicesRefreshNotification object:nil];
}

-(void)iconPathForModel:(JiafeigouDevStatuModel *)devModel
{
    if (devModel.iconPath == nil || devModel.offlineIconPath == nil || [devModel.iconPath isEqualToString:@""] || [devModel.offlineIconPath isEqualToString:@""]) {
        
        NSString *iconPath = @"";
        NSString *offlinePath = @"";
        BOOL isFinished = NO;
        for (NSArray *subArr in self.devList) {
            
            for (AddDevConfigModel *model in subArr) {
                
                for (NSNumber *os in model.osList) {
                    
                    if ([os integerValue] == [devModel.pid integerValue]) {
                        iconPath = model.homeIconName;
                        offlinePath = model.homeDisableIconName;
                        isFinished = YES;
                        break;
                    }
                    
                }
                if (isFinished) {
                    break;
                }
            }
            if (isFinished) {
                break;
            }
            
        }
        devModel.iconPath = iconPath;
        devModel.offlineIconPath = offlinePath;
        
    }
    

}

-(void)setDefaultValue
{
    for (JiafeigouDevStatuModel *model in self.devicesList) {
        for (NSString *cid in [self.newDevCidList copy]) {
            
            if ([cid isEqualToString:model.uuid]) {
                
                self.devicesVM.pType = (productType)[model.pid intValue];
                [self.devicesVM setDevicesDefaultDataWithCid:cid]; // 设置 默认值
                if ([self.newDevCidList containsObject:cid]) {
                    [self.newDevCidList removeObject:cid];
                }
                
            }
            
        }
    }
    
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


-(void)addNewDeviceForCid:(NSString *)cid
{
    if ([cid isKindOfClass:[NSString class]]) {
        for (NSString *alwaysCid in self.newDevCidList) {
            if ([alwaysCid isEqualToString:cid]) {
                return;
            }
        }
        [self.newDevCidList addObject:cid];
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

-(NSMutableArray *)newDevCidList
{
    if (!_newDevCidList) {
        _newDevCidList = [NSMutableArray new];
    }
    return _newDevCidList;
}

- (DevicesViewModel *)devicesVM
{
    if (_devicesVM == nil)
    {
        _devicesVM = [[DevicesViewModel alloc] init];
    }
    return _devicesVM;
}

-(NSArray *)devList
{
    if (!_devList) {
        _devList = [[NSArray alloc]initWithArray:[jfgConfigManager getAllDevModel]];
    }
    return _devList;
}

@end
