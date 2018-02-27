//
//  UpgradeDeviceVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "UpgradeDeviceVC.h"
#import "JfgTableViewCellKey.h"
#import "UpgradeDeviceModel.h"
#import "DeviceInfoFootView.h"
#import "JfgMsgDefine.h"
#import "settingFootView.h"
#import "JfgConstKey.h"
#import "LSAlertView.h"
#import "DownloadUtils.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "JFGBoundDevicesMsg.h"
#import "BaseTableViewCell.h"
#import "CommonMethod.h"
#import "dataPointMsg.h"
#import "NetworkMonitor.h"
#import "JfgGlobal.h"
#import "JfgHttp.h"
#import "VideoPlayFor720ViewController.h"
#import "FileManager.h"
#import "SRDownloadManager.h"

#define timeoutDuration 120


typedef NS_ENUM(NSInteger, upgradeType) {
    upgradeType_DownLoad,
    upgradeType_Upgrade,
};

//typedef NS_ENUM(NSInteger, ControlTag) {
//    cell_redDot_tag,
//};


@interface UpgradeDeviceVC ()<UITableViewDelegate, UITableViewDataSource,JFGSDKCallbackDelegate>
{
    NSTimer *_upgradeTimer;
    CGFloat _timeValue;
}

@property (nonatomic, strong) UpgradeDeviceModel *upgradeModel;

@property (nonatomic, strong) UITableView *upgradeTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) settingFootView *footView;

@property (nonatomic, strong) UIView *progressBgView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *downLoadProgress;

@property (nonatomic, strong) UILabel *upgradeTips;

@property (nonatomic, strong) UIImageView *redDot;

@property (nonatomic, strong) DownloadUtils *downLoadUtils;

@property (nonatomic, copy) NSString *ipAddr;

@property (nonatomic, assign) BOOL isReceivefPong;
@property (nonatomic, assign) BOOL isUpgrading; // device is upgrading now. default NO
@property (nonatomic, assign) int netWorkStatus; // 手机网络状态

@property (nonatomic, strong) NSMutableArray *checkSizeURLArr; // 需要检测大小的url
@property (nonatomic, assign) NSInteger upgradeBinCount;

@end

@implementation UpgradeDeviceVC

NSString *const redDot = @"_redDot";

- (void)dealloc
{
    JFGLog(@" UpgradeDeviceVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    [self initData];
    
    self.isUpgrading = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self finishedUpgradeTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [LSAlertView disMiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    JFG_WS(weakSelf);
    
    [self.view addSubview:self.upgradeTableView];
    [self.view addSubview:self.progressBgView];
    [self.progressBgView addSubview:self.progressLabel];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.progressBgView).with.offset(19.0f);
        make.left.equalTo(weakSelf.progressBgView.mas_left);
        make.right.equalTo(weakSelf.progressBgView.mas_right);
    }];
    
    [self.progressBgView addSubview:self.downLoadProgress];
    [self.downLoadProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.progressBgView).with.offset(-19.0f);
        make.left.equalTo(weakSelf.progressBgView).with.offset(20.0f);
        make.right.equalTo(weakSelf.progressBgView).with.offset(-20.0f);
    }];
    
    [self.view addSubview:self.upgradeTips];
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData
{
    [JFGSDK addDelegate:self];
    
    JFG_WS(weakSelf);
    
    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgBase_Version), @(dpMsgBase_Net)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        weakSelf.upgradeModel.currentVersion = [dic objectForKey:msgBaseVersionKey];
        weakSelf.upgradeModel.deviceWifi = [[dic objectForKey:msgBaseNetKey] objectAtIndex:1];
        weakSelf.upgradeModel.netState = [[[dic objectForKey:msgBaseNetKey] objectAtIndex:0] intValue];
        [weakSelf checkDevVersion];
        [weakSelf update];
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    self.netWorkStatus = [NetworkMonitor sharedManager].currentNetworkStatu;
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"];
}

- (void)update
{
    [self.upgradeTableView reloadData];
}

- (void)leftButtonAction:(UIButton *)sender
{
    switch (self.pType)
    {
        case productType_720p:
        case productType_720:
        {
            if (self.isUpgrading)
            {
                for (UIViewController *vc in self.navigationController.viewControllers)
                {
                    if ([vc isKindOfClass:[VideoPlayFor720ViewController class]])
                    {
                        [self.navigationController popToViewController:vc animated:YES];
                    }
                }
            }   
            else
            {
                [super leftButtonAction:sender];
            }
        }
            break;
            
        default:
        {
            [super leftButtonAction:sender];
        }
            break;
    }
}

- (void)upgradeAction:(UIButton *)sender
{
    JFG_WS(weakSelf);
    
    switch (self.netWorkStatus)
    {
        case NotReachable:
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
        }
            return;
        case ReachableViaWWAN:
        {
            if ([self isDeviceOffLine])
            {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NOT_ONLINE"]];
                return;
            }
            
            if ([self.upgradeModel.currentVersion isEqualToString:self.upgradeModel.lastestVersion])
            {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_LatestFirmwareTips"]];
            }
            else
            {
                if (self.upgradeModel.dlState != downloadStateDownloaded)
                {
                    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
                    } OKBlock:^{
                        
                        [weakSelf downLoadDeveiceBin];
                    }];
                }
                else
                {
                    [self downLoadDeveiceBin];
                }
            }
        }
            return;
        case ReachableViaWiFi:
        default:
        {
            if ([self isDeviceOffLine])
            {
                [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
                return;
            }
            
            if ([self.upgradeModel.lastestVersion isEqualToString:self.upgradeModel.currentVersion])
            {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_LatestFirmwareTips"]];
            }else{
                // 以上判断都 阻止不了 那就下载吧
                [self downLoadDeveiceBin];
            }
        }
            break;
    }
    
}

- (BOOL)isDeviceOffLine
{
    if ([CommonMethod isDeviceBlockUpgrade:self.pType]) {
        return NO;
    }
    
    switch (self.upgradeModel.netState)
    {
        case DeviceNetType_Offline:
        case DeviceNetType_Connetct:
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR"]];
        }
            return YES;
            
        default:
            return NO;
    }
}

- (void)downLoadDeveiceBin
{
    //self.footView.deleteButton.enabled = NO;
    self.footView.deleteButton.enabled = NO;
    JFG_WS(weakSelf);

    if ([CommonMethod isDeviceBlockUpgrade:self.pType]) {
        if (self.upgradeModel.downLoadURLArr.count > 0)
        {
            [self download:[self.upgradeModel.downLoadURLArr firstObject]];
        }
        else
        {
            //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_LatestFirmwareTips"]];
            if ([self.upgradeModel.lastestVersion isEqualToString:self.upgradeModel.currentVersion])
            {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_LatestFirmwareTips"]];
                self.footView.deleteButton.enabled = YES;
            }
            else
            {
                [self show720UpgradeAlert];
            }
        }
        
        
    }else{
        
        if (self.upgradeModel.binUrl == nil || [self.upgradeModel.binUrl isEqualToString:@""]) {
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"]];
            self.footView.deleteButton.enabled = YES;
            return;
        }
        
        [self.downLoadUtils downloadWithUrl:self.upgradeModel.binUrl toDirectory:[FileManager jfgLogDirPath] state:^(SRDownloadState state) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download upgrade file state [%ld]",(unsigned long)state]];
            
            switch (state)
            {
                case SRDownloadStateCompleted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.downLoadProgress.progress = 0;
                        weakSelf.progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdating"],@"0%"];
                        weakSelf.progressBgView.hidden = YES;
                        [weakSelf.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                        
                        [weakSelf showUpgradeAlert];
                        
                    });
                }
                    break;
                case SRDownloadStateFailed:
                {
                    [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"]];
                    weakSelf.footView.deleteButton.enabled = YES;
                }
                    break;
                default:
                    break;
            }
        } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressBgView.hidden = NO;
                [weakSelf setProgressValue:progress upgradeType:upgradeType_DownLoad];
            });
        } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
            NSLog(@"%@",error);
            
        }];
        
    }
    
    
    
}

- (void)startUpgradeTimer
{
    _upgradeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(upgradeTimerAction:) userInfo:nil repeats:YES];
}

- (void)upgradeTimerAction:(NSTimer *)timer
{
    [self setProgressValue:_timeValue/[self getTimeOutDuration] upgradeType:upgradeType_Upgrade];
    _timeValue = _timeValue + 1;
    if (_timeValue > [self getTimeOutDuration])
    {
        [self finishedUpgradeTimer];
        self.isUpgrading = NO;
        
        switch (self.pType)
        {
            /*
            case productType_720:
            case productType_720p:
            {
                JFG_WS(weakSelf);
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdateFai"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf jfgFpingRequest];
                }];
            }
                break;
            */
            default:
            {
                [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdateFai"]];
            }
                break;
        }
        
        
        self.progressBgView.hidden = YES;
    }
    
    
}

- (void)finishedUpgradeTimer
{
    if (_upgradeTimer)
    {
        if ([_upgradeTimer isValid])
        {
            [_upgradeTimer invalidate];
        }
    }
    self.isUpgrading = NO;
    _upgradeTimer = nil;
}

- (void)setProgressValue:(CGFloat)val upgradeType:(int)type
{
    self.downLoadProgress.progress = val;
    self.progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:(type == upgradeType_Upgrade)?@"Tap1_FirmwareUpdating":@"Tap1_FirmwareDownloading"],[NSString stringWithFormat:@"%0.2f%%",self.downLoadProgress.progress*100]];
}

- (int)getTimeOutDuration
{
    if ([CommonMethod isDeviceBlockUpgrade:self.pType]) {
        return 60*5;
    }else{
        return timeoutDuration;
    }
}

- (void)showUpgradeAlert
{
    JFG_WS(weakSelf);
    
    if ([self.upgradeModel.deviceWifi isEqualToString:[CommonMethod currentConnecttedWifi]] || [CommonMethod isConnectedAPWithPid:weakSelf.pType Cid:self.cid])
    {
        // 开始升级
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_UpdateFirmwareTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            weakSelf.footView.deleteButton.enabled = YES;
        } OKBlock:^{
            [weakSelf jfgFpingRequest];
        }];
        
    }
    else
    {
        NSString *showedWifi = (self.upgradeModel.deviceWifi == nil || [self.upgradeModel.deviceWifi isEqualToString:@""])?[CommonMethod appendAPNameWithPid:self.pType Cid:self.cid]:self.upgradeModel.deviceWifi;
        
        [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"setwifi_check"], showedWifi] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.footView.deleteButton.enabled = YES;
            });
            
        } OKBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.footView.deleteButton.enabled = YES;
            });
        }];
    }
}

- (void)show720UpgradeAlert
{
    //JFG_WS(weakSelf);
    if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
        //无网络连接
        [CommonMethod showNetDisconnectAlert];
        self.footView.deleteButton.enabled = YES;
        return;
    }
    
    JiafeigouDevStatuModel *devModel = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevModelWithCid:self.cid];
    
    if (devModel.netType == JFGNetTypeOffline) {
        self.footView.deleteButton.enabled = YES;
        //设备不在线
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"NOT_ONLINE"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            
        }];
        
    }else if(devModel.netType == JFGNetTypeWifi){
        //wifi模式
        NSString *currentWifi = [CommonMethod currentConnecttedWifi];
        if ((currentWifi != nil && ![currentWifi isEqualToString:@""] && [self.upgradeModel.deviceWifi isEqualToString:currentWifi]) || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
        {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"upgrade battery %d", devModel.Battery]];
            if (devModel.Battery < 30)
            {
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Update_Electricity"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                    
                } OKBlock:^{
                    
                }];
                self.footView.deleteButton.enabled = YES;
                
            }else{
                
                [self jfgFpingRequest];
            }
            
            
        }else{
            
            //self.upgradeModel.deviceWifi
            NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"WIFI_SET_1"],self.upgradeModel.deviceWifi];
            [LSAlertView showAlertWithTitle:nil Message:str CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                
            }];
            self.footView.deleteButton.enabled = YES;
            
        }
        
        
    }else if (devModel.netType == JFGNetTypeWired){
        //有线连接模式
        [self jfgFpingRequest];
    }
//    NSString *currentWifi = [CommonMethod currentConnecttedWifi];
//
//    if (([self.upgradeModel.deviceWifi isEqualToString:currentWifi] && currentWifi != nil && ![currentWifi isEqualToString:@""]) || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
//    {
//        JiafeigouDevStatuModel *devModel = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevModelWithCid:self.cid];
//
//        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"upgrade battery %d", devModel.Battery]];
//
//        if (devModel.Battery < 30)
//        {
//
//            //__weak typeof(self) weakSelf = self;
//            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Update_Electricity"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
//
//            } OKBlock:^{
//
//            }];
//
//
//            return;
//        }
//
//        [self jfgFpingRequest];
//    }
//    else
//    {
//        NSString *showedWifi = (self.upgradeModel.deviceWifi == nil || [self.upgradeModel.deviceWifi isEqualToString:@""])?[CommonMethod appendAPNameWithPid:self.pType Cid:self.cid]:self.upgradeModel.deviceWifi;
//
//        [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"setwifi_check"],showedWifi] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.footView.deleteButton.enabled = YES;
//            });
//        } OKBlock:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.footView.deleteButton.enabled = YES;
//            });
//        }];
//    }
}
#pragma mark 下载

// 分块升级 ，计算 所有包的大小
- (void)binTotalSize:(NSString *)urlString
{
    if ([urlString isEqualToString:@""] || urlString == nil)
    {
        return;
    }

    JFG_WS(weakSelf);
    
    [self.downLoadUtils checkUrl:urlString downLoadAction:^(DownLoadModel *dlModel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.downLoadUtils setDirectory:[FileManager jfgLogDirPath]];
            [weakSelf.checkSizeURLArr removeObject:urlString];
            weakSelf.upgradeModel.dlState = dlModel.dlState;
            
            switch (dlModel.dlState)
            {
                case downloadStateDownloaded:
                {
                    if ([weakSelf.downLoadUtils isDownloadFileCompleted:urlString])
                    {
                        [weakSelf.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                    }
                    
                }
                    break;
                case downloadStateNeedDownload:
                case downloadStateReLoad:
                {
                    if (![weakSelf.downLoadUtils isDownloadFileCompleted:urlString])
                    {
                        weakSelf.upgradeModel.totalSize = weakSelf.upgradeModel.totalSize + [dlModel.totalSize floatValue];
                        [weakSelf.footView.deleteButton setTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1a_DownloadInstall"],weakSelf.upgradeModel.totalSizeStr] forState:UIControlStateNormal];
                    }
                }
                    break;
                default:
                    break;
            }
            
            [weakSelf binTotalSize:[weakSelf.checkSizeURLArr firstObject]];
        });
    }];
}


- (void)download:(NSString *)urlString
{
    JFG_WS(weakSelf);
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download upgrade url string %@",urlString]];
    
    if (urlString == nil || [urlString isEqualToString:@""]) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"]];
        return;
    }
    
    [self.downLoadUtils downloadWithUrl:urlString toDirectory:[FileManager jfgLogDirPath] state:^(SRDownloadState state) {
        
        switch (state)
        {
            case SRDownloadStateCompleted:
            {
                [weakSelf.upgradeModel.downLoadURLArr removeObject:urlString];
                if (weakSelf.upgradeModel.downLoadURLArr.count > 0)
                {
                    [weakSelf download:[weakSelf.upgradeModel.downLoadURLArr firstObject]];
                }
                else // 表示下载完毕
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.downLoadProgress.progress = 0;
                        weakSelf.progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdating"],@"0%"];
                        weakSelf.progressBgView.hidden = YES;
                        
                        [weakSelf.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                        [weakSelf show720UpgradeAlert];
                        
                    });
                }
                
                
            }
                break;
            case SRDownloadStateFailed:
            {
                [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"]];
                weakSelf.footView.deleteButton.enabled = YES;
                
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf download:urlString];
                }];
                
            }
                break;
            default:
                break;
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"receive data %ld",receivedSize]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressBgView.hidden = NO;
            
            if (self.upgradeModel.binUrls.count == 1)
            {
                [weakSelf setProgressValue:progress upgradeType:upgradeType_DownLoad];
            }
            else if (weakSelf.upgradeBinCount > 0)
            {
                CGFloat newProgress = (weakSelf.upgradeBinCount*0.1 - weakSelf.upgradeModel.downLoadURLArr.count*0.1)/(weakSelf.upgradeBinCount*0.1);
                [weakSelf setProgressValue:newProgress upgradeType:upgradeType_DownLoad];
            }
            
        });
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark
#pragma mark  == 数据请求====

- (void)jfgFpingRequest
{
    self.isReceivefPong = NO;
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    [ProgressHUD showProgress:nil isTip:NO lastingTime:5.0f];
    
    [self performSelector:@selector(dismissHude) withObject:nil afterDelay:5.0f];
}

- (void)dismissHude
{
    if (self.isReceivefPong == NO && self.navigationController.visibleViewController == self)
    {
        JFG_WS(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
        
            JiafeigouDevStatuModel *devModel = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevModelWithCid:self.cid];
            if (devModel.netType == JFGNetTypeWired){
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"WIRED_UPGRADE_NON_LAN"]];
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"UPDATE_DISCONNECT"]];
            }
            weakSelf.footView.deleteButton.enabled = YES;
            
        });
    }
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self.cid] && self.navigationController.visibleViewController == self)
    {
        self.isReceivefPong = YES;
        self.progressBgView.hidden = NO;
        
        [ProgressHUD dismiss];
        [self dismissHude];
        
        self.ipAddr = ask.address;
        
        NSString *upgradeURL = nil;
        
        if ([CommonMethod isDeviceBlockUpgrade:self.pType]) {
            NSString *binName = nil;
            
            for (NSInteger i = 0; i < self.upgradeModel.binUrls.count; i ++)
            {
                if (binName == nil)
                {
                    binName = [[NSURL URLWithString:[self.upgradeModel.binUrls objectAtIndex:i]] lastPathComponent];
                }
                else
                {
                    binName = [binName stringByAppendingString:[NSString stringWithFormat:@";%@",[[NSURL URLWithString:[self.upgradeModel.binUrls objectAtIndex:i]] lastPathComponent]]];
                }
            }
            
            if (binName != nil)
            {
                upgradeURL = [NSString stringWithFormat:@"http://%@:8765/%@",[CommonMethod getIPAddress:YES], binName];
                self.isUpgrading = YES;
            }
        }else{
            
             upgradeURL = [NSString stringWithFormat:@"http://%@:8765/%@",[CommonMethod getIPAddress:YES], [[NSURL URLWithString:self.upgradeModel.binUrl] lastPathComponent]];
            
        }

        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfg upgrade url [%@]",upgradeURL]];
        if (upgradeURL != nil)
        {
            [JFGSDK deviceUpgreadeForIp:self.ipAddr url:upgradeURL cid:self.cid];
        }
        
        self.progressBgView.hidden = NO;
        [self setProgressValue:0.0f upgradeType:upgradeType_Upgrade];
        _timeValue = 1.0;
        [self startUpgradeTimer];
        [JFGSDK appendStringToLogFile:@"begin upgrade"];
    }
}

#pragma mark
#pragma mark JFGSDK  delegate
- (void)checkDevVersion
{
    if ([CommonMethod isDeviceBlockUpgrade:self.pType])
    {
        [JFGSDK checkTagDeviceVersionForCid:self.cid];
    }
    else
    {
        if (self.upgradeModel.currentVersion != nil)
        {
            [JFGSDK checkDevVersionWithCid:self.cid pid:self.pType version:self.upgradeModel.currentVersion];
        }
        
    }
}

- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    JFG_WS(weakSelf);
    
    self.upgradeModel.lastestVersion = info.version;
    self.upgradeModel.versionDescribe = info.upgradeTips;
    self.upgradeModel.isShowRedDot = info.hasNewPkg;
    self.upgradeModel.binUrl = info.url;
    
    if (info.hasNewPkg)
    {
        [self.downLoadUtils checkUrl:self.upgradeModel.binUrl downLoadAction:^(DownLoadModel *dlModel){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.upgradeModel.dlState = dlModel.dlState;
                
                if (dlModel.dlState == downloadStateDownloaded)
                 {
                     [weakSelf.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                 }
                 else
                 {
                    weakSelf.upgradeModel.totalSize = [dlModel.totalSize floatValue];
                    [weakSelf.footView.deleteButton setTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1a_DownloadInstall"],weakSelf.upgradeModel.totalSizeStr] forState:UIControlStateNormal];
                 }
            });
            
        }];
    }
    
    [self update];
}

// 区块升级包 版本检测 回调
-(void)jfgDevCheckTagDeviceVersion:(NSString *)version
                          describe:(NSString *)describe
                          tagInfos:(NSArray <JFGSDKDevUpgradeInfoT *> *)infos
                               cid:(NSString *)cid
                         errorType:(JFGErrorType)errorType
{
    [self.upgradeModel.downLoadURLArr removeAllObjects];
    [self.upgradeModel.binUrls removeAllObjects];
    [self.checkSizeURLArr removeAllObjects];
    self.upgradeBinCount = infos.count;
    self.upgradeModel.lastestVersion = version;
    
    
    if (infos.count > 0)
    {
        self.upgradeModel.versionDescribe = describe;
        self.upgradeModel.totalSize = 0;
        self.upgradeModel.isShowRedDot = YES;
        
        for (NSInteger i = 0; i < infos.count; i ++)
        {
            JFGSDKDevUpgradeInfoT *upgradeModel = [infos objectAtIndex:i];
            
            [self.checkSizeURLArr addObject:upgradeModel.url];
            [self.upgradeModel.downLoadURLArr addObject:upgradeModel.url];
            [self.upgradeModel.binUrls addObject:upgradeModel.url];
            
        }
        
        [self binTotalSize:[self.checkSizeURLArr firstObject]];
    }
    else
    {
        self.upgradeModel.versionDescribe = @"";
        self.upgradeModel.lastestVersion = self.upgradeModel.currentVersion;
    }
    
    [self update];
}

// 升级回调
-(void)jfgDevUpgradeInfo:(JFGSDKDeviceUpgrade *)info
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"upgrade info ret %ld",info.ret]];
    
    if ([self.cid isEqualToString:info.cid])
    {
        if (info.ret == 0)
        {
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdateSuc"]];
            self.upgradeModel.isShowRedDot = NO;
            self.upgradeModel.currentVersion = self.upgradeModel.lastestVersion;
            self.progressBgView.hidden = YES;
            [self update];
        }
        else
        {
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdateFai"]];
            self.progressBgView.hidden = YES;
        }
        
        [self finishedUpgradeTimer];
        self.footView.deleteButton.enabled = YES;
    }
}

#pragma mark - NetworkDalegate
-(void)jfgNetworkChanged:(JFGNetType)netType
{
    switch (netType)
    {
        case JFGNetTypeWifi:
        {
            self.netWorkStatus = ReachableViaWiFi;
        }
            break;
        case JFGNetType2G:
        case JFGNetType3G:
        case JFGNetType4G:
        case JFGNetType5G:
        {
            self.netWorkStatus = ReachableViaWWAN;
        }
            break;
        case JFGNetTypeConnect:
        case JFGNetTypeOffline:
        {
            self.netWorkStatus = NotReachable;
        }
            break;
        default:
            break;
    }
    
//    self.netWorkStatus = netType;
}

#pragma mark
#pragma mark === 代理=====
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"upgradeCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (!cell)
    {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierStr];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = nil;
    }
    
    cell.textLabel.text = [dataInfo objectForKey:cellTextKey];
    cell.detailTextLabel.text = [dataInfo objectForKey:cellDetailTextKey];
    cell.redDot.hidden = ![[dataInfo objectForKey:redDot] boolValue];
    [cell.redDot mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell);
        make.right.equalTo(cell.mas_right).with.offset(2.0f);
    }];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        DeviceInfoFootView *footView =[[DeviceInfoFootView alloc] init];
        footView.footLabel.text = [dataInfo objectForKey:cellFootViewTextKey];
        footView.footLabel.font = [UIFont systemFontOfSize:12.0f];
        return footView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    CGFloat stanrdSpace = 20.0f;
    
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        CGSize labelSize = CGSizeOfString([dataInfo objectForKey:cellFootViewTextKey], CGSizeMake(footLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
        return labelSize.height + stanrdSpace;
    }
    
    if (section == [self.dataArray count] - 1)
    {
        return stanrdSpace;
    }
    
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


#pragma mark getter
- (UITableView *)upgradeTableView
{
    if (_upgradeTableView == nil)
    {
        _upgradeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Kwidth, kheight - 64) style:UITableViewStyleGrouped];
        _upgradeTableView.scrollEnabled = NO;
        _upgradeTableView.delegate = self;
        _upgradeTableView.dataSource = self;
        _upgradeTableView.tableFooterView = self.footView;
    }
    return _upgradeTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    [_dataArray removeAllObjects];
    [_dataArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [JfgLanguage getLanTextStrByKey:@"Tap1_CurrentVersion"],cellTextKey,
                                                     self.upgradeModel.currentVersion,cellDetailTextKey,
                                                     nil],
                           nil]];
    [_dataArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [JfgLanguage getLanTextStrByKey:@"Tap1_LatestVersion"],cellTextKey,
                                                     self.upgradeModel.versionDescribe,cellFootViewTextKey,
                                                     self.upgradeModel.lastestVersion,cellDetailTextKey,
                                                     @(self.upgradeModel.isShowRedDot), redDot,
                                                     nil],
                           nil]];
    
    return _dataArray;
}

- (NSMutableArray *)checkSizeURLArr
{
    if (_checkSizeURLArr == nil)
    {
        _checkSizeURLArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    
    return _checkSizeURLArr;
}

- (DownloadUtils *)downLoadUtils
{
    if (_downLoadUtils == nil)
    {
        _downLoadUtils = [[DownloadUtils alloc] init];
        _downLoadUtils.pType = self.pType;
    }
    
    return _downLoadUtils;
}

- (UpgradeDeviceModel *)upgradeModel
{
    if (_upgradeModel == nil)
    {
        _upgradeModel = [[UpgradeDeviceModel alloc] init];
    }
    return _upgradeModel;
}

- (settingFootView *)footView
{
    if (_footView == nil)
    {
        _footView = [[settingFootView alloc] initWithFrame:CGRectMake(-1, 0, Kwidth, 119.0f)]; // 设计 描边癖 像素+1
        [_footView.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
        [_footView.deleteButton addTarget:self action:@selector(upgradeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}

- (UIView *)progressBgView
{
    if (_progressBgView == nil)
    {
        _progressBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kheight - 67, Kwidth, 67)];
        _progressBgView.backgroundColor = [UIColor whiteColor];
        _progressBgView.hidden = YES;
    }
    return _progressBgView;
}

- (UILabel *)progressLabel
{
    if (_progressLabel == nil)
    {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:14.0f];
        _progressLabel.textColor = [UIColor colorWithHexString:@"#8c8c8c"];
        _progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdating"],@"0%"];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _progressLabel;
}

- (UIProgressView *)downLoadProgress
{
    if (_downLoadProgress == nil)
    {
        _downLoadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    return _downLoadProgress;
}

- (UIImageView *)redDot
{
    if (_redDot == nil)
    {
        _redDot = [[UIImageView alloc] init];
        _redDot.image = [UIImage imageNamed:@"bell_red_dot"];
        _redDot.frame = CGRectMake(0, 0, 22.0, 22.0);
    }
    
    return _redDot;
}

- (UILabel *)upgradeTips
{
    if (_upgradeTips == nil)
    {
        CGFloat xWidth = Kwidth - 15*2.0;
        CGFloat fontSize = 13.0f;
        CGSize labelSize = CGSizeOfString([JfgLanguage getLanTextStrByKey:@"Tap1_Update_Precautions"], CGSizeMake(xWidth, kheight), [UIFont systemFontOfSize:fontSize]);
        
        _upgradeTips = [[UILabel alloc] initWithFrame:CGRectMake(15, self.footView.bottom + 15.0, xWidth, labelSize.height)];
        _upgradeTips.textColor = [UIColor colorWithHexString:@"#888888"];
        _upgradeTips.numberOfLines = 0;
        _upgradeTips.font = [UIFont systemFontOfSize:fontSize];
        _upgradeTips.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Update_Precautions"];
        _upgradeTips.textAlignment = NSTextAlignmentCenter;
    }
    return _upgradeTips;
}

@end
