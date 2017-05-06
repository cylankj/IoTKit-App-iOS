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
#import "JFGEfamilyDataManager.h"
#import "JfgConstKey.h"
#import "FLProressHUD.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"
#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGSDK.h>
#import "SetAngleVC.h"
#import "ConfigWiFiViewController.h"
#import "LogoSelectVC.h"
#import "LoginManager.h"
#import "JfgConfig.h"

@interface DeviceSettingVC()<autoPhotoVCDelegate,UIAlertViewDelegate,JFGSDKCallbackDelegate, setAngleDelegate, safeDelegate>
{
    BOOL isLan;
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDevice:) name:deleteDeviceNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:deleteDeviceNotification object:nil];
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
    switch (self.pType)
    {
        case productType_Mine:
        {
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTINGS"];
        }
            break;
            
        default:
        {
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTINGS_1"];
        }
            break;
    }
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
    switch (self.pType) {
        case productType_Mag://门磁
        {
            switch (indexPath.section) {
                case 0:
                {
                    [self pushToDeviceInfoController];
                }
                  break;
                    
                case 2:
                {
                    //清空开关记录
                    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tipsforclearrecents"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                        
                    } OKBlock:^{
                        [self.settingTableView.deviceSettingVM deleteMsg];
                        [self clearMagMsg];
                    }];

                }
                    break;
                default:
                    break;
            }
        }
            break;
        case productType_DoorBell:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    [self pushToDeviceInfoController];
                    
                }
                    break;
                case 1:
                {
                    [self pushToWifiController:@""];
                }
                    break;
                case 2:
                {
                    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tipsforclearrecents"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                        
                    } OKBlock:^{
                        [self.settingTableView.deviceSettingVM deleteMsg];
                    }];
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case productType_Mine:
        {
            switch (indexPath.section) {
                
                case 1:{
                    [FLProressHUD showIndicatorViewFLHUDForStyleDarkWithView:self.view text:@"" position:FLProgressHUDPositionCenter];
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                        [FLProressHUD hideAllHUDForView:self.view animation:NO delay:0];
                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips3"]];
                        [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:1];
                        [self.settingTableView refreshData];
                        [self.settingTableView reloadData];
                    }];
                    
                }
                    break;
                    
                case 2:
                {
                    AboutUsViewController * aboutUs = [AboutUsViewController new];
                    [self.navigationController pushViewController:aboutUs animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case productType_Efamily:
        {
            switch (indexPath.section)
            {
                case 0: // 设备信息
                {
                    [self pushToDeviceInfoController];
                }
                    break;
                case 1: // wifi 配置
                {
                    [self pushToWifiController:@""];
                }
                    break;
                case 2: // 清空 呼叫记录
                {
                    UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"" message:[JfgLanguage getLanTextStrByKey:@"Tap1_Tipsforclearrecents"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"Button_Sure"], nil];
                    aler.tag = 1002;
                    [aler show];
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
                case 0: //设备信息
                {
                    [self pushToDeviceInfoController];
                }
                    break;
                case 1: // wifi 配置
                {
                    [self pushToWifiController:[dataInfo objectForKey:cellDetailTextKey]];
                }
                    break;
                case 2: // 安全防护，自动录像
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            [self pushToSafeProtectController];
                        }
                            break;
                        case 1:
                        {
                            [self pushToAutoPhotoController:dataInfo];
                        }
                            break;
                    }
                }
                    break;
                case 3:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case productType_720:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    [self pushToDeviceInfoController];
                }
                    break;
                case 1:
                {
                    LogoSelectVC *lsVC = [[LogoSelectVC alloc] init];
                    [self.navigationController pushViewController:lsVC animated:YES];
                }
                    break;
                case 2:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            [self pushToWifiController:[dataInfo objectForKey:cellDetailTextKey]];
                        }
                            break;
                        case 1:
                        {
                            [self pushToAddDevicesVC];
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
        case productType_3G:
        default:
            switch (indexPath.section)
            {
                case 0:
                {
                    [self pushToDeviceInfoController];
                }
                    break;
                case 1:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            [self pushToWifiController:[dataInfo objectForKey:cellDetailTextKey]];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            [self pushToSafeProtectController];
                        }
                            break;
                        case 1:
                        {
                            [self pushToAutoPhotoController:dataInfo];
                        }
                            break;
                        /*       暂时保留  延时摄影 代码
                        case 2:
                        {
                            if (![self isFirstTimeLapse])
                            {
                                TimeLapseGuideViewController * guide = [[TimeLapseGuideViewController alloc]init];
                                [self.navigationController pushViewController:guide animated:YES];
                                guide.cid = self.cid;
                            }else{
                                TimeLapsePGViewController * timeLapse = [[TimeLapsePGViewController alloc]init];
                                [self.navigationController pushViewController:timeLapse animated:YES];
                                timeLapse.cid = self.cid;
                            }
                        }
                            break;
                        */
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
                            if (self.pType == productType_Camera_HS )
                            {
                                SetAngleVC *angleVC = [[SetAngleVC alloc] init];
                                angleVC.angleDelegate = self;
                                angleVC.oldAngleType = [[dataInfo objectForKey:cellHiddenText] intValue];
                                [self.navigationController pushViewController:angleVC animated:YES];
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

            break;
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

// 跳转 wifi界面
-(void)pushToWifiController:(NSString *)dogWifi
{
    
    // FreeCam 等类型 直接跳转绑定页面
    if (self.pType == productType_FreeCam || self.pType == productType_DoorBell ||self.pType == productType_DoorBell_V2)
    {
        AddDeviceGuideViewController * wifiConf = [AddDeviceGuideViewController new];
        wifiConf.pType = self.pType;
        wifiConf.cid = self.cid;
        wifiConf.configType = configWifiType_configWifi;
        [self.navigationController pushViewController:wifiConf animated:YES];
        
        return;
    }

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
-(BOOL)isFirstTimeLapse{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"isFirstTimeLapse"] == nil) {
        [userDefault setBool:YES forKey:@"isFirstTimeLapse"];
        [userDefault synchronize];
        return YES;
    }
    return NO;
}
@end
