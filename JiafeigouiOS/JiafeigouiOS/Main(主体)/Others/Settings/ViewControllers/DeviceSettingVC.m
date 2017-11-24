//
//  DeviceSettingVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceSettingVC.h"
#import "JfgGlobal.h"
#import "DeviceInfoVC.h"
#import "DeviceAutoPhotoVC.h"
#import "SafeProtectVC.h"
#import "DeviceWifiSetVC.h"
#import "TimeLapsePGViewController.h"
#import "TimeLapseGuideViewController.h"
#import "AboutUsViewController.h"
#import "AddDeviceGuideViewController.h"
#import "JfgTableViewCellKey.h"
#import "CommonMethod.h"
#import "JfgMsgDefine.h"
#import "MicroSDCardVC.h"
#import "CusPickerView.h"
#import "JFGEfamilyDataManager.h"
#import "JfgConstKey.h"
#import "FLProressHUD.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"
#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGSDK.h>
#import "SetAngleVC.h"
#import "ConfigWiFiViewController.h"
#import "NSDictionary+FLExtension.h"
#import "LogoSelectVC.h"
#import "LoginManager.h"
#import "JfgConfig.h"
#import "Cf720WiFiAnimationVC.h"
#import "WifiModeFor720CFResultVC.h"
#import "DeepSleepVC.h"
#import "ChangePwdViewController.h"
#import "RegionalizationViewController.h"

@interface DeviceSettingVC()<autoPhotoVCDelegate,UIAlertViewDelegate,JFGSDKCallbackDelegate, setAngleDelegate, safeDelegate,AddDeviceGuideVCNextActionDelegate>
{
    BOOL isLan;
    BOOL isAPModelFor720;
    BOOL isHotport;
}
@property (strong, nonatomic) DeviceSettingTableView *settingTableView;

@end


@implementation DeviceSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aliasChanged:) name:updateAliasNotification object:nil];
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    if (self.pType == productType_Mag) {
        [JFGSDK addDelegate:self];
    }
    
}

-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    [self.settingTableView initData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDevice:) name:deleteDeviceNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:deleteDeviceNotification object:nil];
    [self.settingTableView.deviceSettingVM clearSDCardFinish];
    self.settingTableView.deviceSettingVM = nil;
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.settingTableView initData];
    [self.settingTableView refreshData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)deleteDevice:(NSNotification *)notification
{
    //NSString *cid = notification.object;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)clearMagMsg
{
//    MsgClientClearMagStatusReq req;
//    req.mId = 16925;
//    req.mCallee = [self.cid UTF8String];
//    req.mCaller = "";
    //std::string reqData = getBuff(req);
    //NSData *data = [NSData dataWithBytes:reqData.c_str() length:reqData.length()];
    //[JFGSDK sendEfamilyMsgData:data];
    //[ProgressHUD showProgress:nil];
}

-(void)jfgEfamilyMsg:(id)msg
{
    if ([msg isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = msg;
        if (sourceArr.count >= 5) {
            
            if ([sourceArr[0] integerValue] == 16926) {
                int error = [sourceArr[4] intValue];
                if (error == 0) {
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips3"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearMagMsgSuccess" object:nil];
                }else{
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips4"]];
                }
            }
        }
        
    }
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        
    });
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1002) {
        
        if (buttonIndex == 1) {
            
            [[JFGEfamilyDataManager defaultEfamilyManager]deleteEfamilyMsgListForCid:self.cid];
        }
        
    }
}

#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTINGS_1"];
}

- (void)initView
{
    [self.view addSubview:self.settingTableView];
    [self initViewLayout];
    [self initNavigation];
}

- (void)initViewLayout
{
    [self.settingTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64.0f);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
}


#pragma mark setter
- (DeviceSettingTableView *)settingTableView
{
    if (_settingTableView == nil)
    {
        _settingTableView = [[DeviceSettingTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _settingTableView.settingDelegate = self;
        _settingTableView.cid = self.cid;
        _settingTableView.pType = self.pType;
        _settingTableView.isShare = self.isShare;
        _settingTableView.pid = self.devModel.pid;
        
        
        NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
        JiafeigouDevStatuModel *currentModel;
        
        for (JiafeigouDevStatuModel *model in list) {
            
            if ([model.uuid isEqualToString:self.cid] || [model.sn isEqualToString:self.cid]) {
                
                currentModel = model;
                break;
                
            }
            
        }
        
        if ([currentModel.alias isEqualToString:@""]) {
            self.alis = currentModel.uuid;
        }else{
            self.alis = currentModel.alias;
        }
        _settingTableView.alias = self.alis;
        [_settingTableView setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
    
    return _settingTableView;
}

#pragma mark action

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark deviceSettingDelegate
- (void)deviceSettingTableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo
{
    JFG_WS(weakSelf);
    
    NSString *cellID = [dataInfo objectForKey:cellUniqueID];
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@" clicked unique id %@",cellID]];
    
    if ([cellID isEqualToString:deviceInfo]) // 设备信息
    {
        [self pushToDeviceInfoController];
    }
    else if ([cellID isEqualToString:wifiConfig]) // wifi 配置
    {
        [self pushToWifiController:[dataInfo objectForKey:cellDetailTextKey]];
    }
    else if ([cellID isEqualToString:safeProtect]) // 安全防护
    {
        [self pushToSafeProtectController];
    }
    else if ([cellID isEqualToString:recordSetting])    // 录像设置
    {
        [self pushToAutoPhotoController:dataInfo];
    }
    else if ([cellID isEqualToString:microSDCard]) // sd 卡
    {
        [self sdCardClear:dataInfo];
    }
    else if ([cellID isEqualToString:angle])    // 视角
    {
        [self pubshToAngle:dataInfo];
    }
    else if ([cellID isEqualToString:clearCallMsg]) // 清空 呼叫记录
    {
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tipsforclearrecents"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            [weakSelf.settingTableView.deviceSettingVM deleteMsg];
        }];
    }
    else if ([cellID isEqualToString:hotWireless])      // 开启 AP
    {
        [self.settingTableView.deviceSettingVM openHotWired];
    }
    else if ([cellID isEqualToString:apConnectting])    // 直连ap
    {
        isAPModelFor720 = YES;
        isHotport = NO;
        BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
        if (isAP) {
            WifiModeFor720CFResultVC *resultVC = [WifiModeFor720CFResultVC new];
            resultVC.isAPModeFinished = YES;
            [self.navigationController pushViewController:resultVC animated:YES];
        }else{
            AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
            deviGuide.pType = productType_720;
            deviGuide.delegate = self;
            [self.navigationController pushViewController:deviGuide animated:YES];
        }
    }else if ([cellID isEqualToString:deepsleep]){
        
        //省电模式
        DeepSleepVC *sleepVC = [DeepSleepVC new];
        sleepVC.cid = self.cid;
        [self.navigationController pushViewController:sleepVC animated:YES];
        
    }else if ([cellID isEqualToString:phoneHotspot]){
        
        NSString *iPhoneName = [UIDevice currentDevice].name;
        if (self.settingTableView.deviceSettingVM.settingModel.deviceNetType == DeviceNetType_Wifi && [iPhoneName isEqualToString:self.settingTableView.deviceSettingVM.settingModel.wifi]) {
            //已开启热点
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_HOTSPOT_CONNECTED"]];
            return;
        }
        
        //开启热点
        BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
        
        if (isAP) {
            
            //AP模式下
            ConfigWiFiViewController *configWifi = [[ConfigWiFiViewController alloc]init];
            configWifi.cid = self.cid;
            configWifi.pType = self.pType;
            configWifi.configType = configWifiType_setHotspot;
            [self.navigationController pushViewController:configWifi animated:YES];
            
        }else{
            
            
            if (self.settingTableView.deviceSettingVM.settingModel.deviceNetType != DeviceNetType_Offline) {
                //在线
                NSString *devWifiName = self.settingTableView.deviceSettingVM.settingModel.wifi;
                NSString *iphoneWifiName = [CommonMethod currentConnecttedWifi];
                
                if ([devWifiName isEqualToString:iphoneWifiName]) {
                    //局域网环境
                    ConfigWiFiViewController *configWifi = [[ConfigWiFiViewController alloc]init];
                    configWifi.cid = self.cid;
                    configWifi.pType = self.pType;
                    configWifi.configType = configWifiType_setHotspot;
                    [self.navigationController pushViewController:configWifi animated:YES];
                    
                }else{
                    //非局域网环境
                    [LSAlertView showAlertWithTitle:nil Message:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"WIFI_SET_1"],devWifiName] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"WELL_OK"] OtherButtonTitle:nil CancelBlock:^{
                        
                    } OKBlock:^{
                        
                    }];
                }
                
            }else{
                //离线
                isAPModelFor720 = YES;
                isHotport = YES;
                AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
                deviGuide.pType = productType_720;
                deviGuide.delegate = self;
                [self.navigationController pushViewController:deviGuide animated:YES];
            }
        }
    }else if ([cellID isEqualToString:idCellDoorlockPw]){
        
        //门锁
        ChangePwdViewController *pw = [ChangePwdViewController new];
        pw.changeType = ChangePwdTypeForDoorlock;
        pw.cid = self.cid;
         [self.navigationController pushViewController:pw animated:YES];
    }
}



- (void)moveDectionChanged:(BOOL)isOpen repeatTime:(int)repeat begin:(int)begin end:(int)end
{
    [self.settingTableView.deviceSettingVM updateSafeProtectStr:isOpen repeatTime:repeat begin:begin end:end];
}

- (void)warnRelativeAutoPhoto:(NSInteger)autoPhotoType
{
    [self.settingTableView.deviceSettingVM updateMotionDection:autoPhotoType];
}

-(void)hideProgressHUD
{
    [ProgressHUD dismiss];
}

#pragma mark 
#pragma mark   界面 跳转方法
// 跳转 安全防护
- (void)pushToSafeProtectController
{
    SafeProtectVC *safeProtect = [[SafeProtectVC alloc] init];
    safeProtect.cid = self.cid;
    safeProtect.pType = self.pType;
    safeProtect.delegate = self;
    [self.navigationController pushViewController:safeProtect animated:YES];
}

// 跳转 设备信息
- (void)pushToDeviceInfoController
{
    DeviceInfoVC * infoVC = [[DeviceInfoVC alloc]init];
    infoVC.cid = self.cid;
    infoVC.alis = self.alis;
    infoVC.pType = self.pType;
    infoVC.isShare = self.isShare;
    [self.navigationController pushViewController:infoVC animated:YES];
}

// push 到自动录像界面
- (void)pushToAutoPhotoController:(NSDictionary *)dataInfo
{
    DeviceAutoPhotoVC *autoPhoto = [[DeviceAutoPhotoVC alloc] init];
    autoPhoto.delegate = self;
    autoPhoto.cid = self.cid;
    autoPhoto.pType = self.pType;
    autoPhoto.oldselectedIndex = [[dataInfo objectForKey:cellHiddenText] integerValue];
    [self.navigationController pushViewController:autoPhoto animated:YES];
}

- (void)sdCardClear:(NSDictionary *)dataDict
{
    int sdCardType = [[dataDict objectForKey:cellHiddenText] intValue];
    // 未插卡 和 正常使用 不需要提示
    
    switch (sdCardType)
    {
        case SDCardType_Using:
        {
            MicroSDCardVC *microSDcard = [[MicroSDCardVC alloc] init];
            microSDcard.cid = self.cid;
            microSDcard.isShare = self.isShare;
            microSDcard.pType = self.pType;
            [self.navigationController pushViewController:microSDcard animated:YES];
        }
        break;
        case SDCardType_Error:
        {
            if ([self.settingTableView.deviceSettingVM isClearingSDCard])
            {
                return;
            }
            //格式化sd卡wwwwwwww
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SD_INIT"] CancelBlock:^{
            } OKBlock:^{
                [self.settingTableView.deviceSettingVM clearSDCard];
            }];
        }
        default:
        break;
    }
}
// 跳转 wifi界面
-(void)pushToWifiController:(NSString *)dogWifi
{
    NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    JiafeigouDevStatuModel *currentModel;
    
    for (JiafeigouDevStatuModel *model in list)
    {
        if ([model.uuid isEqualToString:self.cid] || [model.sn isEqualToString:self.cid])
        {
            currentModel = model;
            break;
        }
    }
    // FreeCam 等类型 直接跳转绑定页面
    switch (self.pType)
    {
        case productType_FreeCam:
        case productType_DoorBell:
        case productType_DoorBell_V2:
        case productType_CesBell_V2:
        case productType_CatEye:
        case productType_CesBell:
        case productType_RSDoorBell:
        case productType_KKS_DoorBell:
        {
            AddDeviceGuideViewController * wifiConf = [AddDeviceGuideViewController new];
            wifiConf.pType = self.pType;
            wifiConf.cid = self.cid;
            wifiConf.configType = configWifiType_configWifi;
            [self.navigationController pushViewController:wifiConf animated:YES];
            
            return;
        }
            break;
        case productType_720p:
        case productType_720:
        {
            NSString *currentWifiName = [CommonMethod currentConnecttedWifi];
            
            
            if ([CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid] || [dogWifi isEqualToString:currentWifiName]) {
                
                //局域网或者直连AP
                ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
                configWifi.cid = self.cid;
                configWifi.pType = productType_720;
                configWifi.configType = configWifiType_resetWifi;
                configWifi.isCamare = YES;
                [self.navigationController pushViewController:configWifi animated:YES];
                
            }else if(currentModel.netType == JFGNetTypeOffline){
                
                //离线
                isAPModelFor720 = NO;
                isHotport = NO;
                AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
                deviGuide.pType = productType_720;
                deviGuide.delegate = self;
                [self.navigationController pushViewController:deviGuide animated:YES];
                
            }else{
                
                //前往WiFi配置
                [LSAlertView showAlertWithTitle:nil Message:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"WIFI_SET_1"],dogWifi] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"WELL_OK"] OtherButtonTitle:nil CancelBlock:^{
                    
                } OKBlock:^{
                    
                }];
            }
            return;
        }
            break;
        default:
            break;
    }

    
    
    if (currentModel.netType != JFGNetTypeOffline && currentModel.netType != JFGNetTypeConnect)
    {
        if ([[CommonMethod currentConnecttedWifi] isEqualToString:dogWifi]
            || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
        {
            
            switch (self.pType)
            {
                default:
                {
                    //前往WiFi选项
                    DeviceWifiSetVC *deviceWifiSet = [DeviceWifiSetVC new];
                    deviceWifiSet.pType = self.pType;
                    deviceWifiSet.cid = self.cid;
                    deviceWifiSet.dogWifi = dogWifi;
                    [self.navigationController pushViewController:deviceWifiSet animated:YES];
                }
                    break;
            }
            
            
            
        }
        else if ([dogWifi isEqualToString:@""])
        {
            [self pushToAddDevicesVC];
        }
        else
        {
            //前往WiFi配置
            [LSAlertView showAlertWithTitle:nil Message:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"WIFI_SET_1"],dogWifi] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"WELL_OK"] OtherButtonTitle:nil CancelBlock:^{
                
            } OKBlock:^{
                
            }];
        }
    }
    else
    {
        [self pushToAddDevicesVC];
    }
}

- (void)pushToAddDevicesVC
{
    AddDeviceGuideViewController * wifiConf = [AddDeviceGuideViewController new];
    wifiConf.pType = self.pType;
    wifiConf.configType = configWifiType_configWifi;
    [self.navigationController pushViewController:wifiConf animated:YES];
}

- (void)pubshToAngle:(NSDictionary *)dataInfo
{
    SetAngleVC *angleVC = [[SetAngleVC alloc] init];
    angleVC.angleDelegate = self;
    angleVC.oldAngleType = [[dataInfo objectForKey:cellHiddenText] intValue];
    [self.navigationController pushViewController:angleVC animated:YES];
}

//跳转wifi配置动画页面（720设备专属）
-(void)addDeviceGuideVCNectActionForVC:(UIViewController *)vc
{
    Cf720WiFiAnimationVC *wifiAn = [Cf720WiFiAnimationVC new];
    wifiAn.cidStr = self.cid;
    if (isHotport) {
        wifiAn.eventType = EventTypeHotSpot;
    }else{
        wifiAn.eventType = isAPModelFor720?EventTypeOpenAPModel:EventTypeConfigWifi;
    }
    [vc.navigationController pushViewController:wifiAn animated:YES];
}

#pragma mark 移动侦测 更新
- (void)updateMotionDetection:(NSInteger)motionType
{
    [self.settingTableView.deviceSettingVM updateMotionDection:motionType];
}

- (void)updateWarnEnable:(BOOL)isOpen
{
    [self.settingTableView.deviceSettingVM updateWarnEnable:isOpen];
}

#pragma mark 全景视角 更新
- (void)angleChanged:(int)angleType
{
    [self.settingTableView.deviceSettingVM updatePanoAngle:angleType];
    [[NSNotificationCenter defaultCenter] postNotificationName:angleChangedNotification object:@(angleType)];
}

-(void)aliasChanged:(NSNotification *)notification
{
    NSString *newAlias = notification.object;
    [self.settingTableView.deviceSettingVM updateAliasWithString:newAlias];
}

#pragma mark - isFirstTimeLapse
-(BOOL)isFirstTimeLapse
{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"isFirstTimeLapse"] == nil) {
        [userDefault setBool:YES forKey:@"isFirstTimeLapse"];
        [userDefault synchronize];
        return YES;
    }
    return NO;
}
@end
