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
#import "BaseTableViewCell.h"
#import "CommonMethod.h"
#import "dataPointMsg.h"
#import "NetworkMonitor.h"
#import "JfgGlobal.h"
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

@property (nonatomic, strong) UIImageView *redDot;

@property (nonatomic, strong) DownloadUtils *downLoadUtils;

@property (nonatomic, copy) NSString *toPath;
@property (nonatomic, copy) NSString *ipAddr;

@property (nonatomic, assign) BOOL isReceivefPong;
@property (nonatomic, assign) int netWorkStatus; // 手机网络状态

@end

@implementation UpgradeDeviceVC

NSString *const redDot = @"_redDot";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    [self initData];
    
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
    [self.view addSubview:self.upgradeTableView];
    
    [self.view addSubview:self.progressBgView];
    [self.progressBgView addSubview:self.progressLabel];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressBgView).with.offset(19.0f);
        make.left.equalTo(self.progressBgView.mas_left);
        make.right.equalTo(self.progressBgView.mas_right);
    }];
    
    [self.progressBgView addSubview:self.downLoadProgress];
    [self.downLoadProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.progressBgView).with.offset(-19.0f);
        make.left.equalTo(self.progressBgView).with.offset(20.0f);
        make.right.equalTo(self.progressBgView).with.offset(-20.0f);
    }];
    
    
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData
{
    [JFGSDK addDelegate:self];
    
    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgBase_Version), @(dpMsgBase_Net)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        self.upgradeModel.currentVersion = [dic objectForKey:msgBaseVersionKey];
        self.upgradeModel.deviceWifi = [[dic objectForKey:msgBaseNetKey] objectAtIndex:1];
        self.upgradeModel.netState = [[[dic objectForKey:msgBaseNetKey] objectAtIndex:0] intValue];
        [self checkDevVersion];
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    self.netWorkStatus = [NetworkMonitor sharedManager].currentNetworkStatu;
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdate"];
}

- (void)update
{
    [self.upgradeTableView reloadData];
}


- (void)upgradeAction:(UIButton *)sender
{
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
                        
                        [self downLoadDeveiceBin];
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
                return;
            }
            
            if ([self.upgradeModel.lastestVersion isEqualToString:self.upgradeModel.currentVersion])
            {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_LatestFirmwareTips"]];
            }
            else
            {
                // 以上判断都 阻止不了 那就下载吧
                [self downLoadDeveiceBin];
            }
        }
            break;
    }
    
}

- (BOOL)isDeviceOffLine
{
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
    self.footView.deleteButton.enabled = NO;
    self.toPath = [FileManager jfgUpgradeFilePath:self.pType];
    
    [self.downLoadUtils downloadWithUrl:self.upgradeModel.binUrl toDirectory:[FileManager jfgLogDirPath] state:^(SRDownloadState state) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"download upgrade file state [%ld]",(unsigned long)state]];
        
        switch (state)
        {
            case SRDownloadStateCompleted:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.downLoadProgress.progress = 0;
                    self.progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdating"],@"0%"];
                    self.progressBgView.hidden = YES;
                    [self.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                    
                    if ([self.upgradeModel.deviceWifi isEqualToString:[CommonMethod currentConnecttedWifi]] || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
                    {
                        // 开始升级
                        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_UpdateFirmwareTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                            self.footView.deleteButton.enabled = YES;
                        } OKBlock:^{
                            [self jfgFpingRequest];
                        }];
                        
                    }
                    else
                    {
                        [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"setwifi_check"],self.upgradeModel.deviceWifi] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
                            self.footView.deleteButton.enabled = YES;
                        } OKBlock:^{
                            self.footView.deleteButton.enabled = YES;
                        }];
                    }
                    
                });
            }
                break;
            case SRDownloadStateFailed:
            {
                [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_DownloadFirmwareFai"]];
                self.footView.deleteButton.enabled = YES;
            }
                break;
            default:
                break;
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressBgView.hidden = NO;
            [self setProgressValue:progress upgradeType:upgradeType_DownLoad];
        });
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        
    }];
}

- (void)startUpgradeTimer
{
    _upgradeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(upgradeTimerAction:) userInfo:nil repeats:YES];
}

- (void)upgradeTimerAction:(NSTimer *)timer
{
    [self setProgressValue:_timeValue/timeoutDuration upgradeType:upgradeType_Upgrade];
    _timeValue = _timeValue + 1;
    if (_timeValue > timeoutDuration)
    {
        [self finishedUpgradeTimer];
         [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap1_FirmwareUpdateFai"]];
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
    _upgradeTimer = nil;
}

- (void)setProgressValue:(CGFloat)val upgradeType:(int)type
{
    self.downLoadProgress.progress = val;
    self.progressLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:(type == upgradeType_Upgrade)?@"Tap1_FirmwareUpdating":@"Tap1_FirmwareDownloading"],[NSString stringWithFormat:@"%0.2f%%",self.downLoadProgress.progress*100]];
}

#pragma mark
#pragma mark  == 数据请求====

- (void)jfgFpingRequest
{
    self.isReceivefPong = NO;
    [JFGSDK fping:@"255.255.255.255"];
    [ProgressHUD showProgress:nil isTip:NO lastingTime:5.0f];
    
    [self performSelector:@selector(dismissHude) withObject:nil afterDelay:5.0f];
}

- (void)dismissHude
{
    if (self.isReceivefPong == NO && self.navigationController.visibleViewController == self)
    {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"UPDATE_DISCONNECT"]];
        self.footView.deleteButton.enabled = YES;
    }
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
//    [ProgressHUD dismiss];
    
    if ([ask.cid isEqualToString:self.cid] && self.navigationController.visibleViewController == self)
    {
        self.isReceivefPong = YES;
        self.progressBgView.hidden = NO;
        [ProgressHUD dismiss];
        [self dismissHude];
        
        self.ipAddr = ask.address;
        NSString *url = [NSString stringWithFormat:@"http://%@:8765/%@",[CommonMethod getIPAddress:YES], [[NSURL URLWithString:self.upgradeModel.binUrl] lastPathComponent]];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfg upgrade url [%@]",url]];
        [JFGSDK deviceUpgreadeForIp:self.ipAddr url:url cid:self.cid];
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
    [JFGSDK checkDevVersionWithCid:self.cid pid:self.pType version:self.upgradeModel.currentVersion];
}

- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    self.upgradeModel.lastestVersion = info.version;
    self.upgradeModel.versionDescribe = info.upgradeTips;
    self.upgradeModel.isShowRedDot = info.hasNewPkg;
    self.upgradeModel.binUrl = info.url;
    
    if (info.hasNewPkg)
    {
        [self.downLoadUtils checkUrl:self.upgradeModel.binUrl downLoadAction:^(DownLoadModel *dlModel){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.upgradeModel.dlState = dlModel.dlState;
                
                if (dlModel.dlState == downloadStateDownloaded)
                 {
                     [self.footView.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Update"] forState:UIControlStateNormal];
                 }
                 else
                 {
                    self.upgradeModel.totalSize = [dlModel.totalSize floatValue];
                    [self.footView.deleteButton setTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1a_DownloadInstall"],self.upgradeModel.totalSizeStr] forState:UIControlStateNormal];
                 }
            });
            
        }];
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

#pragma mark getter
- (UITableView *)upgradeTableView
{
    if (_upgradeTableView == nil)
    {
        _upgradeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Kwidth, kheight - 64) style:UITableViewStyleGrouped];
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

@end
