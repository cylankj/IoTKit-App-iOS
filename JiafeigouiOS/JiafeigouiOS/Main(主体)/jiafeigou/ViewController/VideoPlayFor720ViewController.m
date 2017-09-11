//
//  VideoPlayFor720ViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/11.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "VideoPlayFor720ViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"
#import "DeviceSettingVC.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <POP.h>
#import "JfgGlobal.h"
#import <JFGSDK/CylanJFGSDK.h>
#import "CommonMethod.h"
#import "JfgLanguage.h"
#import <KVOController.h>
#import "JfgTimeFormat.h"
#import "JfgDataTool.h"
#import "JfgMsgDefine.h"
#import "JFGTakePhotoButton.h"
#import "UIButton+Addition.h"
#import "UpgradeDeviceVC.h"
#import "JFGTimepieceView.h"
#import "NSTimer+FLExtension.h"
#import "UIAlertView+FLExtension.h"
#import "JFGShortVideoRecordAnimation.h"
#import "Pano720PhotoVC.h"
#import <JFGSDK/JFGSDKSock.h>
#import <JFGSDK/JFGSDK.h>
#import "ProgressHUD.h"
#import "PopAnimation.h"
#import "JFGMsgForwardDataDownload.h"
#import <commoncrypto/commondigest.h>
#import "LoginManager.h"
#import "AddDeviceGuideViewController.h"
#import "Cf720WiFiAnimationVC.h"
#import "WifiModeFor720CFResultVC.h"
#import "JfgHttp.h"
#import "XTimer.h"
#import "JFGNetDeclareViewController.h"
#import "FLTipsBaseView.h"
#import "JFGEquipmentAuthority.h"
#import "LSAlertView.h"
#import "CommentFrameButton.h"
#import "MsgFor720ViewController.h"
#import "JFGDevOfflineFor720VC.h"
#import "BaseNavgationViewController.h"

#define VIEW_REMOTERENDE_VIEW_TAG  10023
#define SHOW_CANNOT_LOAD_IMAGE_TIP_KEY @"showCantloadImageTipKey"
#define FristIntoVideoPlayFor720VC @"FristIntoVideoPlayFor720VC"

//录像状态
typedef NS_ENUM(NSInteger,VideoRecordStatue) {
    VideoRecordStatueNone,//没有录像
    VideoRecordStatue8SRecording,//短视频录制
    VideoRecordStatueLongRecording,//长视频录制
};

@interface VideoPlayFor720ViewController ()<JFGTakePhotoTouchActionDelegate,JFGSDKCallbackDelegate,AddDeviceGuideVCNextActionDelegate>
{
    videoPlayState playState;//视频播放状态
    VideoRecordStatue recordState;//录像状态
    int batteryRl;//设备电池电量
    int timeoutRequestCount;//连接超时计算
    BOOL isLowSpeed;//是否速率低于5k/s
    BOOL isWifi;//设备是否wifi在线
    BOOL isCarameMode;//是否是拍照模式
    BOOL isShooting;//是否视频拍摄中
    BOOL isPrower;//充电中
    BOOL isShowedLANAlert;//是否显示过低电量弹窗
    
    int shortVideoTimeCount;//短视频时间记录
    NSTimer *shortVideoTimer;//短视频录制计时器
    NSTimer *fpingTimer;
    JFGMsgForwardDataDownload *downloadManager;
    BOOL isDevOffline;
    BOOL isAddNotification;
    BOOL isSetHomeMode;
    BOOL isHaveSDCard;
    BOOL isDidAppear;
    BOOL isAudio;
    BOOL isTalkBack;
    NSString *devIpAddr;
    BOOL isShowLanAleartForPhoto;//公网拍照是否显示无法下载提示
    BOOL isUpdateing;//是否升级中
}



@property (nonatomic,strong)UIButton *settingBtn;
@property (nonatomic, strong) UIImageView *redDotImageView;

//底部一系类控件
@property (nonatomic,strong)UIView *bottomBgView;
@property (nonatomic,strong)UIButton *cameraModeBtn;
@property (nonatomic,strong)UIButton *videoModeBtn;
@property (nonatomic,strong)UIButton *albumsBtn;
@property (nonatomic,strong)JFGTakePhotoButton *takePhotoBtn;

//更多按钮相关
@property (nonatomic,strong)UIButton *moreBtn;
@property (nonatomic,strong)UIButton *micBtn;
@property (nonatomic,strong)UIButton *voiceBtn;

@property (nonatomic,strong)UIView *speedModeBgView;
//@property (nonatomic,strong)UIButton *speedModeLeftBtn;
//@property (nonatomic,strong)UIButton *speedModeRightBtn;
//@property (nonatomic,strong)UILabel *speedModeLabel;

//底层视图
@property (nonatomic,strong)UIImageView *videoBgImageView;
@property (nonatomic,strong)UIImageView *loadingImageView;

//最上方异常提示视图
@property (nonatomic,strong)UIView *singularTipBgView;
@property (nonatomic,strong)UIImageView *singularTipIcon;
@property (nonatomic,strong)UIButton *singularTipCancelBtn;
@property (nonatomic,strong)UILabel *singularTipLabel;

//最上方设备状态显示视图
@property (nonatomic,strong)UIView *statusShowBgView;
@property (nonatomic,strong)UIImageView *statusNetIcon;
@property (nonatomic,strong)UILabel *statusNetLabel;
@property (nonatomic,strong)UIImageView *statusBatteryIcon;
@property (nonatomic,strong)UILabel *statusBatteryLabel;

//流量显示
@property (nonatomic,strong)UILabel *rateLabel;
//长视频录像时间显示控件
@property (nonatomic,strong)JFGTimepieceView *timepiceView;
//短视频时间显示
@property (nonatomic,strong)UILabel *shortVideoTimeLabel;

@property (nonatomic,strong)UIView *againBgView;

@property (nonatomic,strong)JFGShortVideoRecordAnimation *recordAnimationView;

@property (nonatomic,strong)UIActivityIndicatorView *takePhotoLoadingView;

@property (nonatomic,strong)UIView *netModeSwitchBgView;

@property (nonatomic,strong)UILabel *offlineLabel;//一个坑爹的东西

@property (nonatomic,strong)UIButton *msgBtn;

@property (nonatomic,strong)UIView *cameraRedPoint;

@property (nonatomic,strong)UIView *warnRedPoint;

@end

@implementation VideoPlayFor720ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self btnDisenableStatue];//设备状态显示
    [JFGSDK addDelegate:self];
    
    [self initView];
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (!isAP) {
        [self startFping];
    }
}

//显示升级页面
-(void)showUpDataView
{
    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
        [self stopVideoPlay];
    }
    [self stopLoadingAnimation];
    [self hiddenAgainView];
    [self btnDisenableStatue];
    [self stopTimeoutRequest];
    self.rateLabel.hidden = YES;
    self.albumsBtn.enabled = NO;
    [self.albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_disabled"] forState:UIControlStateNormal];
    self.albumsBtn.layer.borderWidth = 0;
    self.statusShowBgView.hidden = YES;
    self.settingBtn.enabled = NO;
    self.offlineLabel.hidden = YES;
    self.statusShowBgView.hidden = YES;
    
    if (![self.videoBgImageView viewWithTag:12589]) {
        UILabel *updateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 25)];
        updateLabel.x = self.videoBgImageView.width*0.5;
        updateLabel.y = self.videoBgImageView.height*0.5;
        updateLabel.font = [UIFont systemFontOfSize:18];
        updateLabel.textColor = [UIColor whiteColor];
        updateLabel.text = [JfgLanguage getLanTextStrByKey:@"VIDEO_FirmwareUpdating"];
        updateLabel.tag = 12589;
        updateLabel.textAlignment = NSTextAlignmentCenter;
        [self.videoBgImageView addSubview:updateLabel];
    }
    isUpdateing = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.redDotImageView.hidden = ![JfgDataTool isShowRedDotInSettingButton:self.devModel.uuid pid:[self.devModel.pid integerValue]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    isDidAppear = YES;
    //开启屏幕常亮
    [self reqUpdateState];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self addVideoNotification];
    [self videoRecordstatusRequest];
    [self workNetDecideForDelaySeconds:0];
    
}


-(void)reqUpdateState
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        
        __weak typeof(self) weakSelf = self;
        [self requestForUrl:[NSString stringWithFormat:@"http://192.168.10.2/cgi/ctrl.cgi?Msg=getUpgradeStatus"] success:^(id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720设备升级状态:%@",responseObject]];
                NSDictionary *dict = responseObject;
                int update = [dict[@"upgradeStatus"] intValue];
                
                if (update == 1) {
                    [weakSelf showUpDataView];
                }else{
                    if (isUpdateing) {
                        isUpdateing = NO;
                        [self videoRecordstatusRequest];
                        [self workNetDecideForDelaySeconds:0];
                    }
                }
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
        
    }else{
        
        __weak typeof(self) weakSelf = self;
        
        [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.devModel.uuid msgIds:@[@228] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            
            for (NSArray *subArr in idDataList) {
                
                for (DataPointSeg *seg in subArr) {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        
                        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720设备升级状态:%@",obj]];
                        int update = [obj intValue];
                        if (update == 1) {
                            [weakSelf showUpDataView];
                        }else{
                            if (isUpdateing) {
                                isUpdateing = NO;
                                [self videoRecordstatusRequest];
                                [self workNetDecideForDelaySeconds:0];
                            }
                        }
                        
                    }
                }
                
            }
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.moreBtn.selected) {
        [self moreAction:self.moreBtn];
    }
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [self stopVideoPlay];
    [self stopFping];
    [self removeVideoDelegate];
    //关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    isDidAppear = NO;
    [self releaseTimer];
    
    //返回首页，移除代理相关
    if (self.navigationController.viewControllers.count<1) {
        [JFGSDK removeDelegate:self];
    }
}


-(void)didBecomeActive
{
    //开启屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self videoRecordstatusRequest];
    [self workNetDecideForDelaySeconds:2];
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (!isAP) {
        [self startFping];
    }
}


-(void)didEnterBackground
{
    [self stopVideoPlay];
    [self stopFping];
    //关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    isDidAppear = NO;
}

//网络状态判断
-(void)workNetDecideForDelaySeconds:(int)second
{
    self.offlineLabel.hidden = YES;
    self.statusShowBgView.hidden = NO;
    
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    
    if (isAP) {
        
        [self showStatusTipForWiFiMode:NO batteryCapacity:batteryRl];
        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
           
            [self startLiveVideo];
            self.micBtn.enabled = NO;
            self.voiceBtn.enabled = NO;
           
        }
       
    }else{
        
        self.micBtn.enabled = YES;
        self.voiceBtn.enabled = YES;
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            
            int64_t delayInSeconds = second;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline && [JFGSDK currentNetworkStatus] != JFGNetTypeWifi && !isShowedLANAlert) {
                
                    //客户端移动网络在线
                    __weak typeof(self) weakSelf = self;
                    
                    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                        [weakSelf stopVideoPlay];
                    }
                    
                    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
                        
//                        if ([JFGSDK currentNetworkStatus] == JFGNetTypeWifi) {
//                            if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
//                                [weakSelf startLiveVideo];
//                            }
//                        }else{
//                            
//                            
//                        }
                        if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                            [weakSelf stopVideoPlay];
                        }
                        [weakSelf showAgainView];
                        
                        
                    } OKBlock:^{
                        
                        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                            [weakSelf startLiveVideo];
                        }else{
                            [weakSelf stopVideoPlay];
                            int64_t delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                                [weakSelf startLiveVideo];
                                
                            });
                            
                        }
                        isShowedLANAlert = YES;
                    }];

                    [self showStatusTipForWiFiMode:YES batteryCapacity:self.devModel.Battery];
                    
                }else{
                    
                    if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
                        //离线
                        if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                            [self stopVideoPlay];
                        }
                        [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tap1_DisconnectedPleaseCheck"]];
                        [self showAgainView];
                    }else{
                        //客户端wifi连接
                        
                        int barrt = batteryRl;
                        if (barrt<=0) {
                            barrt = self.devModel.Battery;
                        }
                        
                        [self showStatusTipForWiFiMode:YES batteryCapacity:barrt];
                        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                            [self startLiveVideo];
                        }
                    }
                    
                    
                }
                
            });
            
        }else{
            
            
            if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
                //离线
                if (playState == videoPlayStatePlaying) {
                    [self stopVideoPlay];
                }
                [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tap1_DisconnectedPleaseCheck"]];
                [self showAgainView];
            }else{
                if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                    [self startLiveVideo];
                }
            }
           
        }
    }
    [self reqForBattaryAndSDCard];
}


#pragma mark- fping
-(void)startFping
{
    if (fpingTimer == nil) {
        fpingTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fpingAction) userInfo:nil repeats:YES];
    }
}

-(void)fpingAction
{
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    NSLog(@"VideoPlayFor720VC_fpingAction");
}

-(void)stopFping
{
    if (fpingTimer && [fpingTimer isValid]) {
        [fpingTimer invalidate];
        fpingTimer = nil;
    }
}

-(void)releaseTimer
{
    [self stopFping];
    if (shortVideoTimer && [shortVideoTimer isValid]) {
        [shortVideoTimer invalidate];
    }
    shortVideoTimer = nil;
    [self.timepiceView stopTimer];
    [self.recordAnimationView stopAnimation];
}


#pragma mark- JFGSDKDelegate
-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if (!isDidAppear) {
        return;
    }
    if ([ask.cid isEqualToString:self.devModel.uuid] && isDidAppear) {
        
        [self stopFping];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720 fpingResult:[ip:%@ cid:%@]",ask.address,ask.cid]];
        if (devIpAddr && [devIpAddr isEqualToString:ask.address]) {
            return;
        }
        devIpAddr = ask.address;
        //[ProgressHUD showText:@"局域网ip地址获取成功"];
        [self reqForBattaryAndSDCard];
        [self videoRecordstatusRequest];
        
        
        [JFGSDK checkTagDeviceVersionForCid:self.devModel.uuid];
    }
}


//- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
//{
//    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"isHaveNewPackage [%d]", info.hasNewPkg]];
//    if (info.hasNewPkg)
//    {
//        [self showAlterView];
//    }
//}

// 区块升级包 版本检测 回调
-(void)jfgDevCheckTagDeviceVersion:(NSString *)version
                          describe:(NSString *)describe
                          tagInfos:(NSArray <JFGSDKDevUpgradeInfoT *> *)infos
                               cid:(NSString *)cid
                         errorType:(JFGErrorType)errorType
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"isHaveNewPackage [%d]", infos.count > 0]];

    if (infos.count > 0 && [self.devModel.uuid isEqualToString:cid])
    {
        [self showAlterView];
    }
}

- (void)showAlterView
{
    if (isDidAppear)
    {
        NSUserDefaults *stdDefault = [NSUserDefaults standardUserDefaults];
        double showedTime = [[stdDefault objectForKey:[NSString stringWithFormat:@"_showUpgradeViewTime_%@",self.devModel.uuid]] doubleValue];
        BOOL isToday = [JfgTimeFormat isToday:showedTime];
        
        if (!isToday)
        {
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Device_UpgradeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                upgradeDevice.cid = self.devModel.uuid;
                upgradeDevice.pType = (productType)[self.devModel.pid intValue];
                [self.navigationController pushViewController:upgradeDevice animated:YES];
            }];
            
            [stdDefault setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[NSString stringWithFormat:@"_showUpgradeViewTime_%@",self.devModel.uuid]];
            
        }
        
        [stdDefault synchronize];
    }
}

-(void)requestForUrl:(NSString *)url success:(void (^)(id _Nullable responseObject))success failure:(void (^)(NSError * _Nonnull))failure
{
   
    AFHTTPSessionManager *manager = [JfgHttp sharedHttp].httpManager;
    NSLog(@"requestUrl:%@",url);
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"error%@",error);  //这里打印错误信息
        if (failure) {
            failure(error);
        }
    }];
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (online && isDidAppear) {
        if ( [self.singularTipLabel.text isEqualToString:[JfgLanguage getLanTextStrByKey:@"Tap1_DisconnectedPleaseCheck"]]) {
            [self workNetDecideForDelaySeconds:0];
        }
    }
}

-(void)jfgNetworkChanged:(JFGNetType)netType
{
    if (!isDidAppear) {
        return;
    }
    if (netType == JFGNetTypeOffline) {
        //断网
        //离线
        [self stopVideoPlay];
        [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tap1_DisconnectedPleaseCheck"]];
        
    }else if(netType == JFGNetTypeWifi){
        //WiFi网络
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap1_SwitchedWiFi"]];
        
        //切换网络会导致连接中的直播断开连接
        [self stopVideoPlay];
        [self showAgainView];
        BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
        if (!isAP) {
            [self startFping];
        }
        
    }else{
        if (isShowedLANAlert) {
            //移动网络
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap1_SwitchedNetwork"]];
        }
        [self stopVideoPlay];
        [self showAgainView];
        devIpAddr = nil;
    }
    
    if (netType != JFGNetTypeOffline) {
        //[self netModeViewCloseAction];
    }
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    [self showStatusTipForWiFiMode:!isAP batteryCapacity:batteryRl];
}

//获取电池与sd卡状态(走公网)
-(void)reqForBattaryAndSDCard
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        
        __weak typeof(self) weakSelf  = self;
    
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetSDInfo ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
           
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int sdcard = [dict[@"sdIsExist"] intValue];
                if (sdcard == 1) {
                    isHaveSDCard = YES;
                }else{
                    isHaveSDCard = NO;
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720DevSDCard:[%@]",dict]];
            }
            
        } failure:^(NSError * _Nonnull error) {
            
            NSLog(@"%@",error);
            
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeBattery ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            //电池电量
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int battery = [dict[@"battery"] intValue];
                batteryRl = battery;
                if (isPrower) {
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                }else{
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:battery];
                }
                weakSelf.devModel.Battery = battery;
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:battery] forKey:[NSString stringWithFormat:@"barrtyFor720_%@",self.devModel.uuid]];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_Battery:[%@]",dict]];
               // NSLog(@"devModel:%@ battery:%d %d",self.devModel,self.devModel.Battery,self.devModel.isPower);
            }
            
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetPowerLine ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            //是否充电中
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int powerline = [dict[@"powerline"] intValue];
                if (powerline == 1) {
                    isPrower = YES;
                    weakSelf.devModel.isPower = YES;
                }else{
                    isPrower = NO;
                    weakSelf.devModel.isPower = NO;
                }
            
                [[NSUserDefaults standardUserDefaults] setBool:isPrower forKey:[NSString stringWithFormat:@"Perwor_%@",weakSelf.devModel.uuid]];
                
                if (isPrower) {
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                }else{
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:batteryRl];
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_powerline:[%@]",dict]];
            }
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetRP ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            //清晰度模式
            NSLog(@"%@",responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
               
                NSDictionary *dict = responseObject;
                id obj = [dict objectForKey:@"resolution"];
                if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                    int resolution = [obj intValue];
                    [weakSelf videoRPModelViewDeal:resolution];
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_resolution:[%@]",dict]];
                
            }
            
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        
    }else{
    
        //sd卡状态
        DataPointSeg *seg1 = [DataPointSeg new];
        seg1.msgId = 204;
        seg1.value = [NSData data];
        seg1.version = 0;
        
        //电池状态
        DataPointSeg *seg2 = [DataPointSeg new];
        seg2.msgId = 206;
        seg2.value = [NSData data];
        seg2.version = 0;
        
        DataPointSeg *seg3 = [DataPointSeg new];
        seg3.msgId = dpMsgBase_Power;
        seg3.value = [NSData data];
        seg3.version = 0;
        
        [JFGSDK sendDPDataMsgForSockWithPeer:self.devModel.uuid dpMsgIDs:@[seg1,seg2,seg3]];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:21 msg:[NSData data]];
    }
}


//视频录制情况
-(void)videoRecordstatusRequest
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        
        __weak typeof(self) weakSelf  = self;
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetRecStatue ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            if (isUpdateing) {
                return ;
            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                
                int ret = [dict[@"ret"] intValue];
                int seconds = [dict[@"seconds"] intValue];
                int videoType = [dict[@"videoType"] intValue];
                if (ret != 0) {
                    if (recordState != VideoRecordStatueNone ) {
                        [self stopVideoViewRefresh];
                        self.takePhotoBtn.selected = NO;
                    }
                    recordState = VideoRecordStatueNone;
                    
                    weakSelf.settingBtn.enabled = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:-1],weakSelf.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
                    return ;
                }
                if (videoType == -1) {
                    //没有录像
                    if (recordState != VideoRecordStatueNone ) {
                        [weakSelf stopVideoViewRefresh];
                        weakSelf.takePhotoBtn.selected = NO;
                    }
                    recordState = VideoRecordStatueNone;
                    weakSelf.settingBtn.enabled = YES;
                }else if(videoType == 1){
                    //8s短视频
                    if (isCarameMode) {
                        [weakSelf videoModelAction];
                        weakSelf.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatue8SRecording;
                    if (playState == videoPlayStatePlaying) {
                        [weakSelf btnStatueForShortVideoWithRemainSe:8-seconds];
                    }
                    weakSelf.settingBtn.enabled = NO;
                }else if (videoType == 2){
                    //长视频
                    if (isCarameMode) {
                        [weakSelf videoModelAction];
                        weakSelf.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatueLongRecording;
                    if (playState == videoPlayStatePlaying) {
                        [weakSelf btnStatueForLongVideoForSecounds:seconds];
                    }
                    weakSelf.settingBtn.enabled = NO;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:videoType],weakSelf.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"videoRecordstatus:%@",dict]];
            }
            
        } failure:^(NSError * _Nonnull) {
            
            
        }];
        
    }else{
    
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:13 msg:[NSData data]];
        
    }

}



#pragma mark- 20006
-(void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                             mSeq:(uint64_t)mSeq
                                              cid:(NSString *)cid
                                             type:(int)type
                                     isInitiative:(BOOL)initiative
                                          msgData:(NSData *)msgData
{
    [self jfgMsgRobotForwardDataV2AckForSockWithMsgID:msgID mSeq:mSeq cid:cid type:type msgData:msgData];
}

-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type msgData:(NSData *)msgData
{
    if (![cid isEqualToString:self.devModel.uuid] || isUpdateing) {
        return;
    }
    id obj = [MPMessagePackReader readData:msgData error:nil];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfgMsgRobotForward:%@ type:%d",obj,type]];
    if (type == 8) {
        //拍照请求回调
        [self carameDataDeal:msgData];
    }else if (type == 10){
        //录制视频请求回调
        [self videoDataDeal:msgData];
    }else if (type == 14){
        //视频录制情况
        [self videoRecordDeal:msgData];
    }else if (type == 22){
        //视频分辨率
        [self videoRPGetDataDeal:msgData];
    }else if (type == 18){
        //清晰度
        [self speedSetDataDeal:msgData];
    }else if (type == 12){
        //停止视频录制
        [self stopVideoDataDeal:msgData];
    }
}



#pragma mark- 20006 dp
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    if (![cid isEqualToString:self.devModel.uuid]) {
        return;
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfgDPMsgRobotForwardInitiative:%d type:%d",initiative,type]];
    //JFG_WS(weakSelf);
    
    for (DataPointSeg *seg in dpMsgArr) {
        id obj2 = [MPMessagePackReader readData:seg.value error:nil];
        NSLog(@"%@",obj2);
        if (seg.msgId == 204) {
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            NSLog(@"%@",obj);
            if ([obj isKindOfClass:[NSArray class]]) {
                /*
                 storage int64 卡容量 单位byte
                 storage_used int64 已用空间 单位byte
                 sdcard_errno int 错误号。0 正常； 非0错误，需要格式化
                 sdcard bool 是否有卡
                 */
                NSArray *sourArr = obj;
                if (sourArr.count>=4) {
                    
                    id obj2 = sourArr[3];
                    if ([obj2 isKindOfClass:[NSNumber class]]) {
                        isHaveSDCard = [obj2 boolValue];
                        if (initiative && !isHaveSDCard && isDidAppear) {
                            //主动上报
                            //MSG_SD_OFF
                            //__weak typeof(self) weakSelf = self;
                            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{

                            } OKBlock:^{
                                
                            }];
                           
                        }
                    }
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_SDCard:[%@]",obj]];
            }
            
        }else if (seg.msgId == 206 || seg.msgId == dpMsgBase_Power){
            [self baratyDeal:seg];
        }else if (seg.msgId == 203){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sdCardForward) object:nil];
            if ([obj2 isKindOfClass:[NSArray class]]) {
                NSArray *sourArr = obj2;
                if (sourArr.count>=3 ) {
                    id obj = sourArr[2];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        
                        int ret = [obj intValue];
                        if (ret == 0) {
                            //格式化成功
                            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SD_INFO_3"]];
                        }else{
                            //格式化失败
                            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
                        }
                        return;
                        
                    }
                }
            }
            //格式化失败
            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
            
        }else if (seg.msgId == 222){
            
            if ([obj2 isKindOfClass:[NSArray class]]){
                
                NSArray *sourArr = obj2;
                if (sourArr.count) {
                    isHaveSDCard = [[obj2 objectAtIndex:0] boolValue];
                    if (initiative && !isHaveSDCard && isDidAppear) {
                        //主动上报
                        //MSG_SD_OFF
                        //__weak typeof(self) weakSelf = self;
                        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                            
                        } OKBlock:^{
                            
                        }];
                        
                    }
                }
            }
        }
    }
}


- (void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
     if ([peer isEqualToString:self.devModel.uuid]) {
         for (DataPointSeg *seg in msgList) {
             
             if (seg.msgId == 505 || seg.msgId == 222){
                 
                 //被分享设备不处理报警消息
                 JiafeigouDevStatuModel *mode = self.devModel;
                 if (mode.shareState == DevShareStatuOther) {
                     return;
                 }
                 self.warnRedPoint.hidden = NO;
             }
         }
     }
}


-(void)sdCardForward
{
    //格式化失败
    [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
}

#pragma mark- 720数据处理
-(void)baratyDeal:(DataPointSeg *)seg
{
    if (seg.msgId == 206){
        //电池电量
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if ([obj isKindOfClass:[NSNumber class]]) {
            batteryRl =  [obj intValue];
            if (isPrower) {
                [self showStatusTipForWiFiMode:isWifi batteryCapacity:200];
            }else{
                [self showStatusTipForWiFiMode:isWifi batteryCapacity:[obj intValue]];
            }
            self.devModel.Battery = [obj intValue];
            NSLog(@"barrty:%d",[obj intValue]);
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_barrty:[%@]",obj]];
            [[NSUserDefaults standardUserDefaults] setValue:obj forKey:[NSString stringWithFormat:@"barrtyFor720_%@",self.devModel.uuid]];
        }
        
    }else if (seg.msgId == dpMsgBase_Power){
        
        //充电中
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if (seg.msgId == dpMsgBase_Power){
            if ([obj isKindOfClass:[NSNumber class]]) {
                int power  = [obj intValue];
                //BOOL isPower = [obj boolValue];
                //isPrower = isPower;
                if (power == 1) {
                    isPrower = YES;
                    self.devModel.isPower = YES;
                    [self showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                }else{
                    isPrower = NO;
                    self.devModel.isPower = NO;
                    [self showStatusTipForWiFiMode:isWifi batteryCapacity:batteryRl];
                    if ([self isShowLowBattaryTip] && batteryRl<20 && isDidAppear) {
                        
                        //__weak typeof(self) weakSelf = self;
                        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"DOOR_LOW_BATTERY"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{

                        } OKBlock:^{
 
                        }];
                        
                        NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastDateKey];
                    }
                }
            }
            NSLog(@"devModel:%@ battery:%d %d",self.devModel,self.devModel.Battery,self.devModel.isPower);
            [[NSUserDefaults standardUserDefaults] setBool:isPrower forKey:[NSString stringWithFormat:@"Perwor_%@",self.devModel.uuid]];
           
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720Dev_power:[%@]",obj]];
        }
    }
}

-(void)videoRecordDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"videoRecordDeal:%@",obj]];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count >= 3) {
            
            @try {
                /*
                 int，     ret       错误码
                 int，     secends   视频录制的时长,单位秒
                 int,      videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频；
                 */
                int ret = [sourceArr[0] intValue];
                int secouds = [sourceArr[1] intValue];
                int videoType = [sourceArr[2] intValue];
                
                if (ret != 0 || ret == -1) {
                    //没有录像
                    if (recordState != VideoRecordStatueNone ) {
                        [self stopVideoViewRefresh];
                        self.takePhotoBtn.selected = NO;
                    }
                    recordState = VideoRecordStatueNone;
                    self.settingBtn.enabled = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:-1],self.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
                    return;
                    
                }
                
                
                if (videoType == -1 || videoType == 0) {
                    //没有录像
                    if (recordState != VideoRecordStatueNone ) {
                        [self stopVideoViewRefresh];
                        self.takePhotoBtn.selected = NO;
                    }
                    recordState = VideoRecordStatueNone;
                    self.settingBtn.enabled = YES;
                    
                }else if(videoType == 1){
                    //8s短视频，视频录制开始回调
                    if (isCarameMode) {
                        [self videoModelAction];
                    }
                    self.takePhotoBtn.selected = YES;
                    recordState = VideoRecordStatue8SRecording;
                    if (playState == videoPlayStatePlaying) {
                        [self btnStatueForShortVideoWithRemainSe:8-secouds];
                    }
                    self.settingBtn.enabled = NO;
                    
                }else if (videoType == 2){
                    //长视频
                    if (isCarameMode) {
                        [self videoModelAction];
                    }
                    self.takePhotoBtn.selected = YES;
                    recordState = VideoRecordStatueLongRecording;
                    if (playState == videoPlayStatePlaying) {
                        [self btnStatueForLongVideoForSecounds:secouds];
                    }
                    self.settingBtn.enabled = NO;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:videoType],self.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
}

-(void)videoRPModelViewDeal:(int)hight
{
    UILabel *lb = [self.speedModeBgView viewWithTag:1000002];
    if (hight == 1) {
        self.speedModeBgView.tag = 1;
        lb.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"];
    }else{
        self.speedModeBgView.tag = 2;
        lb.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"];
    }
}



-(void)speedSetDataDeal:(NSData *)msgData
{
    //int，     ret       错误码:  ret=-1 设置失败
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSNumber class]]) {
        
        int ret = [obj intValue];
        if (ret == 0) {
            if (self.speedModeBgView.tag == 1) {
                [self videoRPModelViewDeal:2];
            }else{
                [self videoRPModelViewDeal:1];
            }
        }
    }
}

-(void)videoRPGetDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    NSLog(@"%@",obj);
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *sourArr = obj;
        if (sourArr.count>1) {
            
            id obj1 = sourArr[0];
            id obj2 = sourArr[1];
            if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]]) {
                //int ret = [obj1 intValue];
                int type = [obj2 intValue];
                [self videoRPModelViewDeal:type];
            }
            
        }
    }
}

-(void)stopVideoDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count) {
            
            @try {
                /*
                 int，     ret       错误码
                 string，  fileName  文件名， 命名格式[timestamp].jpg 或 [timestamp]_[secends].avi， timestamp是文件生成时间的unix时间戳，secends是视频录制的时长,单位秒。根据后缀区分是图片或视频。
                */
                int ret = [sourceArr[0] intValue];
                if (ret == -2) {
                    [self videoOrPhotoFailedDealForVideo:YES ret:-2];
                }
                
                
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            
            
        }
        
    }

}

-(void)carameDataDeal:(NSData *)msgData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(caremaReqOvertime) object:nil];
    [self stopVideoViewRefresh];
    [self btnStatueForCarame];
    
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *arr = obj;
        /*
         int，     ret       错误码
         string，  fileName  文件名， 命名格式[timestamp].jpg 或 [timestamp]_[secends].avi， timestamp是文件生成时间的unix时间戳，secends是视频录制的时长,单位秒。根据后缀区分是图片或视频。
         int，     fileSize  文件大小, bit。
         string，  md5  文件的md5值
         */
        int ret = 0;
        if (arr.count>0 ) {
            
            id obj1 = arr[0];
            if ([obj1 isKindOfClass:[NSNumber class]]) {
                ret = [obj1 intValue];
            }
            if (ret != 0) {
                [self videoOrPhotoFailedDealForVideo:NO ret:ret];
            }else{
                self.devModel.unReadPhotoCount ++ ;
                self.cameraRedPoint.hidden = NO;
                [self carameAnimation];
                [self showCantLoadImageTip];
            }
        }
    }
}


-(void)videoDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
    if ([obj isKindOfClass:[NSNumber class]]) {
        int ret = [obj intValue];
        if (ret == 0) {
            NSLog(@"录像成功");
            self.settingBtn.enabled = NO;
            //公网模式下，无法加载图片提示
            [self showCantLoadImageTip];
        }else{
            recordState = VideoRecordStatueNone;
            NSLog(@"录像失败");
            [self stopVideoViewRefresh];
            self.takePhotoBtn.selected = NO;
            self.settingBtn.enabled = YES;
            [self videoOrPhotoFailedDealForVideo:YES ret:ret];
        }
    }
}


-(void)videoOrPhotoFailedDealForVideo:(BOOL)isVideo ret:(int)ret
{
    if (!isDidAppear) {
        return;
    }
    //2003
    if (ret == 2022) {
        //初始化
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:nil Message:[self videoOrPhotoError:ret forVideo:YES] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SD_INIT"] CancelBlock:^{
            
        } OKBlock:^{
            
            [ProgressHUD showProgress:[JfgLanguage getLanTextStrByKey:@"SD_INFO_2"]];
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(sdCardForward) object:nil];
            [weakSelf performSelector:@selector(sdCardForward) withObject:nil afterDelay:10];
            
            BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:weakSelf.devModel.uuid];
            if (isAP) {
                devIpAddr = @"192.168.10.2";
            }
            if (devIpAddr) {
                
                [weakSelf requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeSDFormat ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sdCardForward) object:nil];
                        NSDictionary *dict = responseObject;
                        int sdcard = [dict[@"sdcard_recogntion"] intValue];
                        if (sdcard == 0) {
                            //格式化成功
                            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SD_INFO_3"]];
                        }else{
                            //格式化失败
                            [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
                        }
                        
                    }
                    
                } failure:^(NSError * _Nonnull) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sdCardForward) object:nil];
                    //格式化失败
                    [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SD_ERR_3"]];
                }];
                
            }else{
                
                DataPointSeg *seg1 = [DataPointSeg new];
                seg1.msgId = 218;
                seg1.value = [MPMessagePackWriter writeObject:[NSNumber numberWithInt:0] error:nil];
                seg1.version = 0;
                
                [JFGSDK sendDPDataMsgForSockWithPeer:self.devModel.uuid dpMsgIDs:@[seg1]];
                
            }
            
        }];
        
        
    }else if (ret == 150 || ret == 2003){
        //低电量与sd卡已满
        //__weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:nil Message:[self videoOrPhotoError:ret forVideo:isVideo] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            
        }];
        
    }else{
        [ProgressHUD showText:[self videoOrPhotoError:ret forVideo:isVideo]];
    }
    
}

-(NSString *)videoOrPhotoError:(int)ret forVideo:(BOOL)video
{
    if (ret == -2) {
        return [JfgLanguage getLanTextStrByKey:@"Tap1_LessThan3sTips"];
    }else if (ret == 150){
        return [JfgLanguage getLanTextStrByKey:@"Tap1_LowPower"];
    }else if (ret == 2003){
        return [JfgLanguage getLanTextStrByKey:@"Tap1_SDCardFullyTips"];
    }else if (ret == 2004){
        return [JfgLanguage getLanTextStrByKey:@"NO_SDCARD"];
    }else if (ret == 2007){
        [self videoRecordstatusRequest];
        return [JfgLanguage getLanTextStrByKey:@"Record_Operate"];
    }else if (ret == 2008){
        return [JfgLanguage getLanTextStrByKey:@"Formatting"];
    }else if (ret == 2022){
        return [JfgLanguage getLanTextStrByKey:@"Tap1_NeedsInitializedTips"];
    }
    if (video) {//Fail_Record
        return [NSString stringWithFormat:@"%@(%d)",[JfgLanguage getLanTextStrByKey:@"Fail_Record"],ret];
    }else{
        return [NSString stringWithFormat:@"%@(%d)",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_RecordingFailed"],ret];
    }
    
}

-(void)initView
{
    if (self.devModel.alias && ![self.devModel.alias isEqualToString:@""]) {
        self.titleLabel.text = self.devModel.alias;
    }else{
        self.titleLabel.text = self.devModel.uuid;
    }
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat wid = self.view.width - 88*2;
        make.height.equalTo(@(wid));
    }];
    [self.topBarBgView addSubview:self.settingBtn];
    
   
    
    [self.topBarBgView addSubview:self.msgBtn];
    [self.topBarBgView addSubview:self.warnRedPoint];
    if (self.devModel.unReadMsgCount>0) {
        self.warnRedPoint.hidden = NO;
    }
    
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.cameraModeBtn];
    [self.bottomBgView addSubview:self.videoModeBtn];
    [self.bottomBgView addSubview:self.albumsBtn];
    [self.bottomBgView addSubview:self.cameraRedPoint];
    if (self.devModel.unReadPhotoCount != 0) {
        self.cameraRedPoint.hidden = NO;
    }
    
    [self.bottomBgView addSubview:self.takePhotoBtn];
    [self.bottomBgView addSubview:self.moreBtn];
    [self.bottomBgView addSubview:self.timepiceView];
    [self.bottomBgView addSubview:self.shortVideoTimeLabel];
    [self.bottomBgView addSubview:self.recordAnimationView];
    
    [self.view addSubview:self.videoBgImageView];
    [self.videoBgImageView addSubview:self.loadingImageView];
    [self.videoBgImageView addSubview:self.rateLabel];
    [self.videoBgImageView addSubview:self.speedModeBgView];
//    [self.speedModeBgView addSubview:self.speedModeLeftBtn];
//    [self.speedModeBgView addSubview:self.speedModeLabel];
//    [self.speedModeBgView addSubview:self.speedModeRightBtn];
    [self.videoBgImageView addSubview:self.voiceBtn];
    [self.videoBgImageView addSubview:self.micBtn];
    [self.videoBgImageView addSubview:self.offlineLabel];
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
}



-(void)initData
{
    isShowedLANAlert = NO;
    isShowLanAleartForPhoto = YES;
    batteryRl = self.devModel.Battery;
    isHaveSDCard = YES;
    isDidAppear = YES;
    timeoutRequestCount = 0;
    devIpAddr = nil;
    isCarameMode = YES;//初始化进入，默认拍照模式
    playState = videoPlayStatePause;
    recordState = VideoRecordStatueNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delAllPhoto) name:JFG720DevDelAllPhotoNotificationKey object:nil];
}

-(void)delAllPhoto
{
    [self.albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_normal"] forState:UIControlStateNormal];
    [self.albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_disabled"] forState:UIControlStateDisabled];
    self.albumsBtn.layer.borderWidth = 0;
}

#pragma mark- 视频播放
-(void)startLiveVideo
{
    if (playState == videoPlayStatePlaying) {
        return;
    }
    playState = videoPlayStatePlayPreparing;
    [self startLodingAnimation];
    /*!
     *  开始视频直播 获取视频播放视图
     *  可以通过回调#jfgRTCPNotifyBitRate:videoRecved:frameRate:timesTamp: 查看视频加载情况
     长时间接收视频数据为0，则为网络状况差或者超时。
     */
    isDevOffline = NO;
    [CylanJFGSDK connectCamera:self.devModel.uuid];
    self.rateLabel.hidden = NO;
    [self startTimeoutRequestForDelay:30];
}


-(void)stopVideoPlay
{
    [CylanJFGSDK stopRenderView:NO withCid:self.devModel.uuid];
    if (self.devModel.uuid) {
        [CylanJFGSDK disconnectVideo:self.devModel.uuid];
    }else{
        [CylanJFGSDK disconnectVideo:@""];
    }
    UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
            
            Panoramic720IosView *rvc = (Panoramic720IosView *)remoteView;
            [rvc stopRender];
        }
        [remoteView removeFromSuperview];
        remoteView = nil;
        [JFGSDK appendStringToLogFile:@"remoteRemoveFromSuperView"];
    }
    playState = videoPlayStatePause;
    self.rateLabel.text = @"0k/s";
    [self stopVideoViewRefresh];
    [self btnDisenableStatue];
    [self stopLoadingAnimation];
    [self stopTimeoutRequest];

}

#pragma mark- 添加代理
//视频播放相关代理
-(void)addVideoNotification
{
    if (isAddNotification) {
        return;
    }
    //视频直播相关代理
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"applicationDidEnterBackgroundBeforeEnvchange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    isAddNotification = YES;
}

-(void)removeVideoDelegate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidEnterBackgroundBeforeEnvchange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    isAddNotification = NO;
}


#pragma mark- 视频直播代理
-(void)onNotifyResolution:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    if (dict) {
        
        int width = [[dict objectForKey:@"width"] intValue];
        int height = [[dict objectForKey:@"height"] intValue];
        NSLog(@"originSize:%@",NSStringFromCGSize(CGSizeMake(width, height)));
        CGSize size = CGSizeMake(width, height);
        
        //防止多次接受通知
        if (playState == videoPlayStatePlaying) {
            return;
        }
        [JFGSDK appendStringToLogFile:@"onNotifyResolution remoteViewSizeFit"];
        
        UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if (remoteView) {
            if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
                Panoramic720IosView *rv= (Panoramic720IosView *)remoteView;
                [rv stopRender];
            }
            [remoteView removeFromSuperview];
            remoteView = nil;
        }
        
        width = self.view.width;
        height= width;
        size = CGSizeMake(width, width);
         
        Panoramic720IosView * _remoteView = [[Panoramic720IosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, self.videoBgImageView.width, self.videoBgImageView.height)];
        [_remoteView configV720];
        [_remoteView setDisplayMode:DM_Fisheye];
        _remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
        _remoteView.backgroundColor = [UIColor blackColor];
        _remoteView.layer.edgeAntialiasingMask = YES;
        [self.videoBgImageView addSubview:_remoteView];
        [self.videoBgImageView sendSubviewToBack:_remoteView];
        
        [CylanJFGSDK startRenderRemoteView:_remoteView];
        playState = videoPlayStatePlaying;
        [self stopLoadingAnimation];
        [self btnStatueForCarame];
        
        if (recordState != VideoRecordStatueNone) {
            [self videoRecordstatusRequest];
        }

        //开启屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

-(void)onNotificatyRTCP:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (dict) {
        int bitRate = [dict[@"bit"] intValue];
        //int frameRate = [dict[@"frameRate"] intValue];
        //long long timesTamp = [dict[@"timestamp"] intValue];
        //int videorecved = [dict[@"videoRecved"] intValue];
        //historyLastestTimeStamp = timesTamp;
        
//        if (!dateFormatter) {
//            dateFormatter = [[NSDateFormatter alloc]init];
//            [dateFormatter setDateFormat:@"MM/dd HH:mm"];
//        }
//        
        if (bitRate == 0) {
            [self startTimeoutRequestForDelay:10];
        }else{
            [self stopTimeoutRequest];
        }
        
        if (bitRate < 5) {
            if (!isLowSpeed) {
                [self performSelector:@selector(rtcpLowAction) withObject:nil afterDelay:3];
            }
            isLowSpeed = YES;
        }else{
            if (isLowSpeed) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
            }
            [self stopLoadingAnimation];
            isLowSpeed = NO;
        }
//        self.videoPlayTipLabel.text = dat;
//        //CGFloat m = videoRecved/1024.0/1024.0;
        CGFloat kb = bitRate/8;
        //NSString *recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fM",kb,m];
        //    if (m>1024) {
        //        recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fG",kb,m/1024.0];
        //    } 5
        //self.rateLabel.hidden = NO;
        if (kb>1024) {
            self.rateLabel.text = [NSString stringWithFormat:@"%.1fM/s",kb/1024];
        }else{
            self.rateLabel.text = [NSString stringWithFormat:@"%.0fK/s",kb];
        }
        NSLog(@"bit:%fkb/s",kb);
        
    }
}



-(void)onRecvDisconnectForRemote:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *remoteID = dict[@"remote"];
    NSLog(@"disConnect:%@",remoteID);
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"Disconnect:%@ errorType:%@",remoteID,dict[@"error"]]];
    
    if ([remoteID isEqualToString:self.devModel.uuid] || [remoteID isEqualToString:@"server"]) {
        
        
        JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
        if (errorType == JFGErrorTypeVideoPeerInConnect) {
            
            [self stopVideoPlay];
            __weak typeof(self) weakSelf = self;
            if (isDidAppear) {
                
                //__weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:nil Message:[CommonMethod languaeKeyForLiveVideoErrorType:errorType] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf backAction];
                }];
                
            }
            //[self showTipView:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
            
        }else if (errorType == JFGErrorTypeVideoPeerNotExist){
            //Tap1_Offline
            BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
            if (isAP) {
                return;
            }
            [self stopVideoPlay];
            [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tap1_Offline"]];
            isDevOffline = YES;
            
        }else{
            [self stopVideoPlay];
            [self showTipView:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
        }
       
        playState = videoPlayStateDisconnectCamera;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
        
    }
    
}

#pragma mark- 直播超时事件
-(void)startTimeoutRequestForDelay:(NSInteger)delay
{
    if (timeoutRequestCount == 0) {
        [self performSelector:@selector(playRequestTimeoutDeal) withObject:nil afterDelay:delay];
        timeoutRequestCount++;
    }
}

-(void)stopTimeoutRequest
{
    if (timeoutRequestCount != 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRequestTimeoutDeal) object:nil];
        timeoutRequestCount --;
    }
}

-(void)playRequestTimeoutDeal
{
    playState = videoPlayStateDisconnectCamera;
    [self stopVideoPlay];
    isDevOffline = NO;
    [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
    [self showAgainView];
}

-(void)rtcpLowAction
{
    if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
        [self startLodingAnimation];
    }
}


#pragma mark- 按钮事件
-(void)albumsAction:(UIButton *)sender
{
    Pano720PhotoVC *panoPhotoVC = [[Pano720PhotoVC alloc] init];
    panoPhotoVC.cid = self.devModel.uuid;
    panoPhotoVC.nickName = self.devModel.alias;
    panoPhotoVC.pType = (productType)[self.devModel.pid intValue];
    
    [self.navigationController.view.layer addAnimation:[PopAnimation moveTopAnimation] forKey:nil];
    [self.navigationController pushViewController:panoPhotoVC animated:NO];
    
    self.devModel.unReadPhotoCount = 0 ;
    self.cameraRedPoint.hidden = YES;
}

-(void)netModeSwitchTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    NSLog(@"%@",NSStringFromCGPoint(point));
    [self netModeViewCloseAction];
    if (point.y <self.view.height*0.5) {
        //上半部，wifi模式
        isSetHomeMode = YES;
        NSLog(@"top");
    }else{
        //下半部，直连
        NSLog(@"bottom");
        isSetHomeMode = NO;
    }
    AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
    deviGuide.pType = productType_720;
    deviGuide.delegate = self;
    [self.navigationController pushViewController:deviGuide animated:YES];
}

-(void)addDeviceGuideVCNectActionForVC:(UIViewController *)vc
{
    Cf720WiFiAnimationVC *wifiAn = [Cf720WiFiAnimationVC new];
    wifiAn.cidStr = self.devModel.uuid;
    wifiAn.isAPModel = !isSetHomeMode;
    [vc.navigationController pushViewController:wifiAn animated:YES];
}

-(void)singularTipTapAction:(UITapGestureRecognizer *)tap
{
    if (isDevOffline) {
        [self showNetModeSwitchView];
    }
    if ([self.singularTipLabel.text isEqualToString:[JfgLanguage getLanTextStrByKey:@"Tap1_DisconnectedPleaseCheck"]]) {
        //无网络
        JFGNetDeclareViewController *netDeclareVC = [JFGNetDeclareViewController new];
        [self.navigationController pushViewController:netDeclareVC animated:YES];
    }
}

#pragma mark- 按钮状态

//默认拍照状态
-(void)btnStatueForCarame
{
    isCarameMode = YES;
    self.cameraModeBtn.selected = YES;
    self.cameraModeBtn.hidden = NO;
    self.videoModeBtn.selected = NO;
    self.videoModeBtn.hidden = NO;
    self.cameraModeBtn.enabled = YES;
    self.videoModeBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.moreBtn.hidden = NO;
    self.albumsBtn.enabled = YES;
    self.albumsBtn.hidden = NO;
    if (self.devModel.unReadPhotoCount !=0) {
        self.cameraRedPoint.hidden = NO;
    }
    self.takePhotoBtn.enabled = YES;
    self.takePhotoBtn.userInteractionEnabled = YES;
    self.takePhotoBtn.hidden = NO;
    self.settingBtn.enabled = YES;
    [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateNormal];
    [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateSelected];
    self.takePhotoBtn.selected = NO;
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP){
        //self.moreBtn.enabled = NO;
    }
}

//不可点击状态
-(void)btnDisenableStatue
{
    self.cameraModeBtn.enabled = NO;
    self.videoModeBtn.enabled = NO;
    self.moreBtn.enabled = NO;
    self.albumsBtn.enabled = YES;
    self.takePhotoBtn.enabled = NO;
    if (self.moreBtn.selected) {
        [self moreAction:self.moreBtn];
    }
}


//拍照，或者录像请求发送中的状态
-(void)btnStatueForLoading
{
    self.cameraModeBtn.hidden = YES;
    self.videoModeBtn.hidden = YES;
    self.moreBtn.hidden = YES;
    self.albumsBtn.hidden = YES;
    self.cameraRedPoint.hidden = YES;
    self.takePhotoBtn.enabled = NO;
    if (self.takePhotoLoadingView.superview != self.takePhotoBtn) {
        [self.takePhotoLoadingView removeFromSuperview];
        [self.takePhotoBtn addSubview:self.takePhotoLoadingView];
    }
    [self.takePhotoLoadingView startAnimating];
    self.takePhotoLoadingView.hidden = NO;
}

//短视频录制状态
-(void)btnStatueForShortVideoWithRemainSe:(int)remainSecound
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cameraModeBtn.hidden = YES;
        self.videoModeBtn.hidden = YES;
        self.albumsBtn.hidden = YES;
        self.cameraRedPoint.hidden = YES;
        self.moreBtn.hidden = YES;
    }];
    if (self.moreBtn.selected) {
        [self hideMoreBtn];
        self.moreBtn.selected = NO;
    }
    self.shortVideoTimeLabel.text = [NSString stringWithFormat:@"%dS",remainSecound];
    self.shortVideoTimeLabel.hidden = NO;
    shortVideoTimeCount = remainSecound;
    if (shortVideoTimer && [shortVideoTimer isValid]) {
        [shortVideoTimer invalidate];
    }
    shortVideoTimer = nil;
    
    shortVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shortVideoTimeShowAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:shortVideoTimer forMode:NSRunLoopCommonModes];
    
    [self.recordAnimationView startAnimation];
    [self.recordAnimationView setHidden:NO];
    [self.takePhotoLoadingView removeFromSuperview];
    self.takePhotoLoadingView.hidden = YES;
    self.takePhotoBtn.enabled = YES;
}


//长视频录制状态
-(void)btnStatueForLongVideoForSecounds:(int)secounds
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cameraModeBtn.hidden = YES;
        self.videoModeBtn.hidden = YES;
        self.albumsBtn.hidden = YES;
        self.cameraRedPoint.hidden = YES;
        self.moreBtn.hidden = YES;
    }];
    if (self.moreBtn.selected) {
        [self hideMoreBtn];
        self.moreBtn.selected = NO;
    }
    [self.takePhotoLoadingView removeFromSuperview];
    self.takePhotoLoadingView.hidden = YES;
    self.takePhotoBtn.enabled = YES;
    self.timepiceView.hidden = NO;
    
    int hour = secounds/3600;
    int minute = (secounds%3600)/60;
    int second = secounds%60;
    
    [self.timepiceView startTimerForHour:hour min:minute sec:second];
}

-(void)btnEnableStatue
{
    self.cameraModeBtn.enabled = YES;
    self.videoModeBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.albumsBtn.enabled = YES;
    self.takePhotoBtn.enabled = YES;
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP){
        //self.moreBtn.enabled = NO;
    }
}


-(void)settingAction
{
    DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
    deviceSetting.cid = self.devModel.uuid;
    deviceSetting.isShare = (self.devModel.shareState == DevShareStatuOther);
    deviceSetting.devModel = self.devModel;
    deviceSetting.pType = productType_720;
    
    if ([self.devModel.alias isEqualToString:@""]) {
        deviceSetting.alis = self.devModel.uuid;
    }else{
        deviceSetting.alis = self.devModel.alias;
    }
    
    [self.navigationController pushViewController:deviceSetting animated:YES];
    
}

-(void)videoModelAction
{
    if (isCarameMode) {
        //选择
        self.takePhotoBtn.selected = NO;
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_video_normal"] forState:UIControlStateNormal];
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_video_recording_nomal"] forState:UIControlStateSelected];
        isCarameMode = NO;
        self.videoModeBtn.selected = YES;
        self.cameraModeBtn.selected = NO;
        
        NSString *isfrist = [[NSUserDefaults standardUserDefaults] objectForKey:FristIntoVideoPlayFor720VC];
        if (!isfrist) {
            [self showLongVideoTip];
        }
    }
}




-(void)cameraModeAction
{
    if (!isCarameMode) {
        isCarameMode = YES;
        self.videoModeBtn.selected = NO;
        self.cameraModeBtn.selected = YES;
        self.settingBtn.enabled = YES;
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateNormal];
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateSelected];
        self.takePhotoBtn.selected = NO;
    }
}

-(void)moreAction:(UIButton *)sender
{
    NSLog(@"touch");
    if (sender.selected) {
        [self hideMoreBtn];
    }else{
        [self showMoreBtn];
    }
    sender.selected = !sender.selected;
}


//重新加载按钮事件
-(void)againAction
{
    [self hiddenAgainView];
    [self workNetDecideForDelaySeconds:0];
}

//点击按钮隐藏tip
-(void)singularTipCancelBtnAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.singularTipBgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.singularTipBgView.hidden = YES;
    }];
    if (isDevOffline) {
        self.offlineLabel.hidden = NO;
        self.statusShowBgView.hidden = YES;
        //[self showAgainView];
    }
}

//拍照按钮
-(void)takePhotoTouchUpDown:(JFGTakePhotoButton *)btn forTakePhotoEvents:(JFGTakePhotoTouchEvents)controlEvents
{
    if (btn.selected == NO) {
        
        if (!isCarameMode) {
            //录像模式下点击
            if (controlEvents == JFGTakePhotoTouchLongTap) {
                NSLog(@"long tap");
#pragma mark- 长按开始短视频录制
                recordState = VideoRecordStatue8SRecording;
                //[self btnStatueForLoading];
                [self shortVideoRecoding];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                [self performSelector:@selector(videoReqOvertime) withObject:nil afterDelay:10];
                btn.selected = !btn.selected;

            }else{
#pragma mark- 单击开始长视频录制
                recordState = VideoRecordStatueLongRecording;
                [self btnStatueForLoading];
                [self longVideoRecoding];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                [self performSelector:@selector(videoReqOvertime) withObject:nil afterDelay:10];
                btn.selected = !btn.selected;

            }
        }else{
            //拍照模式下
            recordState = VideoRecordStatueNone;
            [self btnStatueForLoading];
            [self camarePhotoReq];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(caremaReqOvertime) object:nil];
            [self performSelector:@selector(caremaReqOvertime) withObject:nil afterDelay:10];

        }
        
    }else{
        
        if (!isCarameMode) {
            
            if (self.shortVideoTimeLabel.hidden == NO) {
                //停止短视频录制
                [self stopShortVideoRecode];
                self.settingBtn.enabled = YES;
            }
            
            if (self.timepiceView.hidden == NO) {
                //停止长视频录制
                [self stopLongVideoRecode];
                self.settingBtn.enabled = YES;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
            [self stopVideoViewRefresh];
            btn.selected = !btn.selected;
            
        }else{
            //拍照模式下
            recordState = VideoRecordStatueNone;
            [self btnStatueForLoading];
            [self camarePhotoReq];
        }
    }
    
}

//长按结束，停止短视频录制
-(void)takePhotoTouchLongTapEnd
{
    if (!self.shortVideoTimeLabel.hidden) {
        [self stopShortVideoRecode];
        self.settingBtn.enabled = YES;
        self.takePhotoBtn.selected = NO;
        [self stopVideoViewRefresh];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
    }
}

-(void)videoReqOvertime
{
    recordState = VideoRecordStatueNone;
    [self stopVideoViewRefresh];
    self.takePhotoBtn.selected = NO;
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Request_TimeOut"]];
}

-(void)caremaReqOvertime
{
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Request_TimeOut"]];
    [self stopVideoViewRefresh];
    [self btnStatueForCarame];
}

-(void)stopVideoViewRefresh
{
    [self.takePhotoLoadingView removeFromSuperview];
    [self.takePhotoLoadingView setHidden:YES];
    self.takePhotoBtn.enabled = YES;
    self.shortVideoTimeLabel.hidden = YES;
    self.shortVideoTimeLabel.text = @"8S";
    shortVideoTimeCount = 8;
    if (shortVideoTimer && shortVideoTimer.isValid) {
        [shortVideoTimer invalidate];
        shortVideoTimer = nil;
    }
    
    [self.recordAnimationView stopAnimation];
    [self.recordAnimationView setHidden:YES];
    self.timepiceView.hidden = YES;
    [self.timepiceView stopTimer];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.cameraModeBtn.hidden = NO;
        self.videoModeBtn.hidden = NO;
        self.albumsBtn.hidden = NO;
        self.moreBtn.hidden = NO;
        if (self.devModel.unReadPhotoCount != 0) {
            self.cameraRedPoint.hidden = NO;
        }
    }];
}

-(void)shortVideoTimeShowAction
{
    shortVideoTimeCount --;
    self.shortVideoTimeLabel.text = [NSString stringWithFormat:@"%dS",shortVideoTimeCount];
    if (shortVideoTimeCount <= 0) {
        
        self.shortVideoTimeLabel.hidden = YES;
        self.shortVideoTimeLabel.text = @"8S";
        self.takePhotoBtn.selected = NO;
        if (shortVideoTimer && [shortVideoTimer isValid]) {
            [shortVideoTimer invalidate];
            shortVideoTimer = nil;
        }
        [self.recordAnimationView stopAnimation];
        [self.recordAnimationView setHidden:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraModeBtn.hidden = NO;
            self.videoModeBtn.hidden = NO;
            self.albumsBtn.hidden = NO;
            self.moreBtn.hidden = NO;
            
        } completion:^(BOOL finished) {
            self.settingBtn.enabled = YES;
            if (self.devModel.unReadPhotoCount != 0) {
                self.cameraRedPoint.hidden = NO;
            }
        }];
        
    }
    NSLog(@"VideoPlayFor720VC_shortVideoTimeShowAction");
}

#pragma mark- 长视频录制相关
-(void)longVideoRecoding
{
    [self videoRecordingReqForLong:YES];
}

-(void)stopLongVideoRecode
{
    if (recordState != VideoRecordStatueNone) {
        [self stopVideoRecordingReqForLong:YES];
    }
}

#pragma mark- 短视频录制相关
-(void)shortVideoRecoding
{
    [self videoRecordingReqForLong:NO];
}

-(void)stopShortVideoRecode
{
    if (recordState != VideoRecordStatueNone) {
        [self stopVideoRecordingReqForLong:NO];
    }
    
}

#pragma mark- 拍照
-(void)camarePhotoReq
{
    if (playState == videoPlayStatePlaying) {

        BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
        if (isAP) {
            devIpAddr = @"192.168.10.2";
        }

        NSData *data = [MPMessagePackWriter writeObject:@[@""] error:nil];
        if (devIpAddr) {
            __weak typeof(self) weakSelf = self;
            [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeSnapShot ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    NSDictionary *dict = responseObject;
                    int ret = [dict[@"ret"] intValue];
                    if (ret == 0) {
                        //[ProgressHUD showText:@"拍照成功"];
                        weakSelf.devModel.unReadPhotoCount ++ ;
                        weakSelf.cameraRedPoint.hidden = NO;
                        [weakSelf showCantLoadImageTip];
                        [weakSelf carameAnimation];
                    }else{
                        [weakSelf videoOrPhotoFailedDealForVideo:NO ret:ret];
                    }
                    
                }
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(caremaReqOvertime) object:nil];
                [weakSelf stopVideoViewRefresh];
                [weakSelf btnStatueForCarame];
                
            } failure:^(NSError * _Nonnull error) {
                
                
                NSString *url = [CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeSnapShot ipAdd:devIpAddr];
                NSLog(@"%@ errorUrl:%@",error,url);
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(caremaReqOvertime) object:nil];
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_RecordingFailed"]];
                [weakSelf stopVideoViewRefresh];
                [weakSelf btnStatueForCarame];
                
            }];
            
        }else{
            
            [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:7 msg:data];
        }
    
       
            
       
    }
}


#pragma mark- 拍照图片放大动画
-(void)carameAnimation
{
    UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
            
            Panoramic720IosView *rvc = (Panoramic720IosView *)remoteView;
            UIImage *image = [rvc takeSnapshot];
            if (image) {
                self.albumsBtn.layer.borderWidth = 1;
                [self.albumsBtn setImage:image forState:UIControlStateNormal];
                NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
                [imgData writeToFile:[self snapImgDataFilePath] atomically:YES];
            }
        }
    }
    
    self.cameraRedPoint.hidden = YES;
    int64_t delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        self.cameraRedPoint.hidden = NO;
        
    });
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = 0.4;// 动画时间
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    
    // 这三个数字，我只研究了前两个，所以最后一个数字我还是按照它原来写1.0；前两个是控制view的大小的；
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    //[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)]];
    //[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.25, 1.25, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    animation.values = values;
    
    [self.albumsBtn.layer addAnimation:animation forKey:nil];
}

-(NSString *)snapImgDataFilePath
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"snapFor720_%@",self.devModel.uuid]];
    return filePath;
}

-(void)videoResolvingPowerForIsHight:(BOOL)hight
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        
        __weak typeof(self) weakSelf = self;
        [self requestForUrl:[self videoRPIsHight:hight] success:^(id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                    if (self.speedModeBgView.tag == 1) {
                        [weakSelf videoRPModelViewDeal:2];
                    }else{
                        [weakSelf videoRPModelViewDeal:1];
                    }
                    
                    
                }else{
                    
                }
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
    }else{
        NSData *data = [MPMessagePackWriter writeObject:@(hight?1:0) error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:17 msg:data];
    }
}

-(void)videoRecordingReqForLong:(BOOL)isLong
{
    //9 videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        __weak typeof(self) weakSelf = self;
        [self requestForUrl:[self startRecIsLongVideo:isLong] success:^(id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                    if (recordState == VideoRecordStatue8SRecording) {
                        [weakSelf btnStatueForShortVideoWithRemainSe:8];
                    }else{
                        [weakSelf btnStatueForLongVideoForSecounds:0];
                    }
                    weakSelf.settingBtn.enabled = NO;
                    //公网模式下，无法加载图片提示
                    [self showCantLoadImageTip];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:isLong?2:1],weakSelf.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
                    
                }else{
                    recordState = VideoRecordStatueNone;
                    NSLog(@"录像失败");
                    weakSelf.takePhotoBtn.selected = NO;
                    weakSelf.settingBtn.enabled = YES;
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(videoReqOvertime) object:nil];
                    [weakSelf videoOrPhotoFailedDealForVideo:YES ret:ret];
                    [self stopVideoViewRefresh];
                    
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"videoRecordingRsp:%@",dict]];
                
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
        
    }else{
        
        NSData *data = [MPMessagePackWriter writeObject:@(isLong?2:1) error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:9 msg:data];
    }
    
}

-(void)stopVideoRecordingReqForLong:(BOOL)isLong
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        [self requestForUrl:[self stopRecIsLongVideo:isLong] success:^(id  _Nullable responseObject) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                }else{
                    [self videoOrPhotoFailedDealForVideo:YES ret:ret];
                }
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"stopVideoRecordingRsp:%@",dict]];
                
            }
        } failure:^(NSError * _Nonnull) {
            
    
        }];
        
    }else{
        NSData *data = [MPMessagePackWriter writeObject:@(isLong?2:1) error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:11 msg:data];
    }
    
    //显示视频截图
    UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
            
            Panoramic720IosView *rvc = (Panoramic720IosView *)remoteView;
            UIImage *image = [rvc takeSnapshot];
            
            
            if (image) {
                [self.albumsBtn setImage:image forState:UIControlStateNormal];
                NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
                [imgData writeToFile:[self snapImgDataFilePath] atomically:YES];
            }
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:-1],self.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
}

#pragma mark- 动画事件
-(void)startLodingAnimation
{
    if (isUpdateing) {
        return;
    }
    if (self.loadingImageView.superview == nil) {
        [self.videoBgImageView addSubview:self.loadingImageView];
    }else{
        [self.videoBgImageView bringSubviewToFront:self.loadingImageView];
    }
    if (!self.loadingImageView.hidden) {
        return;
    }
    self.loadingImageView.hidden = NO;
    [self hiddenTipView];
    [self hiddenAgainView];
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    //baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [self.loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopLoadingAnimation
{
    if (self.loadingImageView.hidden) {
        return;
    }
    self.loadingImageView.hidden = YES;
    [self.loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
}

#pragma mark- 异常显示
-(void)showTipView:(NSString *)tipString
{
    if (self.singularTipBgView.hidden) {
        
        self.rateLabel.hidden = YES;
        self.singularTipBgView.top = -self.singularTipBgView.height;
        self.singularTipBgView.hidden = NO;
        self.offlineLabel.hidden = YES;
        self.singularTipBgView.alpha = 1;
        if (self.singularTipBgView.superview == nil) {
            [self.videoBgImageView addSubview:self.singularTipBgView];
        }else{
            [self.videoBgImageView bringSubviewToFront:self.singularTipBgView];
        }
        
        self.singularTipLabel.text = tipString;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.singularTipBgView.top = 0;
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        self.singularTipLabel.text = tipString;
    }
}

-(void)hiddenTipView
{
    if (!self.singularTipBgView.hidden) {
        self.singularTipBgView.alpha = 0;
        self.singularTipBgView.top = -self.singularTipBgView.height;
        self.singularTipBgView.hidden = YES;
        self.rateLabel.hidden = NO;
    }
}

#pragma mark- 重新加载视图
-(void)showAgainView
{
    if (self.againBgView.superview == nil) {
        [self.videoBgImageView addSubview:self.againBgView];
    }else{
        [self.videoBgImageView bringSubviewToFront:self.againBgView];
    }
    self.againBgView.hidden = NO;
    [self stopLoadingAnimation];
}

-(void)hiddenAgainView
{
    self.againBgView.hidden = YES;
    [self.againBgView removeFromSuperview];
}


#pragma mark- 设备离线点击事件
-(void)showNetModeSwitchView
{
//    if (self.netModeSwitchBgView.superview == nil) {
//        self.netModeSwitchBgView.alpha = 0;
//        [self.view addSubview:self.netModeSwitchBgView];
//        [UIView animateWithDuration:0.5 animations:^{
//            self.netModeSwitchBgView.alpha = 1;
//        }];
//    }
    JFGDevOfflineFor720VC *offVC = [[JFGDevOfflineFor720VC alloc]init];
    offVC.cid = self.devModel.uuid;
    BaseNavgationViewController * nav = [[BaseNavgationViewController alloc] initWithRootViewController:offVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)netModeViewCloseAction
{
    [UIView animateWithDuration:0.5 animations:^{
        self.netModeSwitchBgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.netModeSwitchBgView removeFromSuperview];
    }];
}

#pragma mark- 状态显示
-(void)showStatusTipForWiFiMode:(BOOL)wifiMode batteryCapacity:(int)battery
{
    if (isUpdateing) {
        return;
    }
    isWifi = wifiMode;
    if (self.statusShowBgView.superview == nil) {
        [self.videoBgImageView addSubview:self.statusShowBgView];
        [self.statusShowBgView addSubview:self.statusNetIcon];
        [self.statusShowBgView addSubview:self.statusNetLabel];
        [self.statusShowBgView addSubview:self.statusBatteryIcon];
        [self.statusShowBgView addSubview:self.statusBatteryLabel];
    }
    self.statusShowBgView.hidden = NO;
    if (wifiMode) {
        self.statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_wifi"];
        self.statusNetLabel.text = [NSString stringWithFormat:@"WiFi%@",[JfgLanguage getLanTextStrByKey:@"DOOR_CONNECT"]];
    }else{
        self.statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_ap"];
        self.statusNetLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_OutdoorMode"];
    }
    
    if (battery > 100) {
        self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge"];
        self.statusBatteryLabel.text = [JfgLanguage getLanTextStrByKey:@"CHARGING_One"];
    }else{
        if (battery >= 80) {
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_full"];
            NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:lastDateKey];
        }else if (battery > 20){
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_half"];
            NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:lastDateKey];
        }else{
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_low_power"];
            //电量低于20%
            if ([self isShowLowBattaryTip] && !isPrower && isDidAppear) {
                
                //__weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"DOOR_LOW_BATTERY"]  CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
                    
                } OKBlock:^{
                    
                }];
                
                NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastDateKey];
            }
            
        }
        self.statusBatteryLabel.text = [NSString stringWithFormat:@"%d%%",battery];
    }
}

-(void)showLongVideoTip
{
    if (isDidAppear && playState == videoPlayStatePlaying && recordState == VideoRecordStatueNone) {
        
        FLTipsBaseView *tipBaseView = [FLTipsBaseView tipBaseView];
        
        NSString *text = [JfgLanguage getLanTextStrByKey:@"Tips_ShortVideo"];
        UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5 , 10, 14)];
        tipLabel.text = text;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font = [UIFont systemFontOfSize:13];
        [tipLabel sizeToFit];
        
        UIView *tipBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tipLabel.width+10, tipLabel.height+10+6)];
        tipBgView.backgroundColor = [UIColor clearColor];
        tipBgView.bottom = self.view.height - 140;
        tipBgView.x = self.view.x+23*0.5+self.videoModeBtn.width*0.5;
        
        [tipBaseView addTipView:tipBgView];
        
        UIImageView *tipbgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tipBgView.width, tipLabel.height+10)];
        tipbgImageView.image = [UIImage imageNamed:@"tip_bg2"];
        
        UIImageView *roleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, tipbgImageView.bottom, 12, 6)];
        roleImageView.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180.0f));
        roleImageView.image = [UIImage imageNamed:@"tip_bg"];
        roleImageView.x = tipbgImageView.x;
        [tipBgView addSubview:roleImageView];
        
        
        [tipbgImageView addSubview:tipLabel];
        [tipBgView addSubview:tipbgImageView];
        
        [tipBaseView show];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"mark" forKey:FristIntoVideoPlayFor720VC];
    }
}

-(void)showCantLoadImageTip
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (!isAP && !devIpAddr) {
        
        NSString *uKey = [NSString stringWithFormat:@"%@_%@",SHOW_CANNOT_LOAD_IMAGE_TIP_KEY,self.devModel.uuid];
        BOOL isCantShow = [[NSUserDefaults standardUserDefaults] boolForKey:uKey];
        if (!isCantShow && isShowLanAleartForPhoto) {
            
            isShowLanAleartForPhoto = NO;
            //__weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Switch_Mode"]  CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Dont_Show_Again"] CancelBlock:^{
                
            } OKBlock:^{
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:uKey];
            }];
            
        }
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:SHOW_CANNOT_LOAD_IMAGE_TIP_KEY]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"mark" forKey:SHOW_CANNOT_LOAD_IMAGE_TIP_KEY];
            
           
        }
        
        
    }
}


//电量弹窗控制
-(BOOL)isShowLowBattaryTip
{
    NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:lastDateKey];
    if (!lastDate) {
        return YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSDate *currentDate = [NSDate date];
    
    NSString *currentTime = [dateFormatter stringFromDate:currentDate];
    NSString *lastTime = [dateFormatter stringFromDate:lastDate];
    if ([currentTime isEqualToString:lastTime]) {
        return NO;
    }
    
    return YES;
}


#pragma mark- getter
-(UIButton *)settingBtn
{
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.frame = CGRectMake(self.view.width-44-5, 20, 44, 44);
        [_settingBtn setImage:[UIImage imageNamed:@"camera_ico_install"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        [_settingBtn addSubview:self.redDotImageView];
        
        __weak typeof(self) weakSelf = self;
        [self.KVOController observe:self.settingBtn keyPath:@"enabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            //根据设置按钮的状态设置消息按钮状态
            UIButton *btn = object;
            if ([btn isKindOfClass:[UIButton class]]) {
                weakSelf.msgBtn.enabled = btn.enabled;
            }
            
        }];
    }
    return _settingBtn;
}

- (UIImageView *)redDotImageView
{
    if (_redDotImageView == nil)
    {
        _redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 20, 20)];
        _redDotImageView.image = [UIImage imageNamed:@"bell_red_dot"];
        _redDotImageView.hidden = NO;
    }
    return _redDotImageView;
}

-(UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 144)];
        _bottomBgView.bottom = self.view.height;
        UIColor *color = [UIColor colorWithHexString:@"#333333"];
        color = [color colorWithAlphaComponent:0.95];
        _bottomBgView.backgroundColor = color;
    }
    return _bottomBgView;
}

-(UIButton *)albumsBtn
{
    if (!_albumsBtn) {
        _albumsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumsBtn.size = CGSizeMake(45, 45);
        _albumsBtn.left = 39;
        _albumsBtn.bottom = self.bottomBgView.height - 33;
        _albumsBtn.layer.masksToBounds = YES;
        _albumsBtn.layer.cornerRadius = 45*0.5;
        _albumsBtn.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
        
        NSData *imgData = [[NSData alloc]initWithContentsOfFile:[self snapImgDataFilePath]];
        if (imgData) {
            UIImage *img = [UIImage imageWithData:imgData];
            [_albumsBtn setImage:img forState:UIControlStateNormal];
            _albumsBtn.layer.borderWidth = 1;
        }else{
            [_albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_normal"] forState:UIControlStateNormal];
            [_albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_disabled"] forState:UIControlStateDisabled];
            _albumsBtn.layer.borderWidth = 0;
        }
        [_albumsBtn addTarget:self action:@selector(albumsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumsBtn;
}

-(UIButton *)takePhotoBtn
{
    if (!_takePhotoBtn) {
        _takePhotoBtn = [JFGTakePhotoButton buttonWithType:UIButtonTypeCustom];
        _takePhotoBtn.size = CGSizeMake(73, 73);
        _takePhotoBtn.x = self.bottomBgView.width*0.5;
        _takePhotoBtn.bottom = self.bottomBgView.height-19;
        [_takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateNormal];
        [_takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_disabled"] forState:UIControlStateDisabled];
        _takePhotoBtn.delegate = self;

    }
    return _takePhotoBtn;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.size = CGSizeMake(45, 45);
        _moreBtn.right = self.bottomBgView.width - 39;
        _moreBtn.bottom = self.albumsBtn.bottom;
        _moreBtn.selected = NO;
        _moreBtn.isRelatingTouchEvent = YES;
        [_moreBtn setImage:[UIImage imageNamed:@"camera720_icon_more_normal"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"camera720_icon_more_disabled"] forState:UIControlStateDisabled];
        [_moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

-(UIButton *)cameraModeBtn
{
    if (!_cameraModeBtn) {
        _cameraModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraModeBtn.size = CGSizeMake(25, 25);
        _cameraModeBtn.top = 9;
        _cameraModeBtn.right = self.view.x - 23*0.5;
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_normal"] forState:UIControlStateNormal];
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_selected"] forState:UIControlStateSelected];
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_disabled"] forState:UIControlStateDisabled];
        [_cameraModeBtn addTarget:self action:@selector(cameraModeAction) forControlEvents:UIControlEventTouchUpInside];
        _cameraModeBtn.selected = YES;
        //camera720_icon_camera_selected_disabled
    }
    
    return _cameraModeBtn;
}

-(UIButton *)videoModeBtn
{
    if (!_videoModeBtn) {
        _videoModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoModeBtn.size = CGSizeMake(25, 25);
        _videoModeBtn.top = 9;
        _videoModeBtn.left = self.view.x + 23*0.5;
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_small_normal"] forState:UIControlStateNormal];
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_selected"] forState:UIControlStateSelected];
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_small_disabled"] forState:UIControlStateDisabled];
        [_videoModeBtn addTarget:self action:@selector(videoModelAction) forControlEvents:UIControlEventTouchUpInside];
        //camera720_icon_video_selected_disabled
    }
    return _videoModeBtn;
}

-(UIImageView *)videoBgImageView
{
    if (!_videoBgImageView) {
        _videoBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64 -self.bottomBgView.height)];
        _videoBgImageView.userInteractionEnabled = YES;
        _videoBgImageView.backgroundColor = [UIColor blackColor];
        _videoBgImageView.clipsToBounds = YES;
    }
    return _videoBgImageView;
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_loading"]];
        _loadingImageView.x = self.videoBgImageView.width*0.5;
        _loadingImageView.y = self.videoBgImageView.height*0.5;
        _loadingImageView.userInteractionEnabled = YES;
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}


-(UIView *)singularTipBgView
{
    if (!_singularTipBgView) {
        _singularTipBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _singularTipBgView.backgroundColor = [UIColor colorWithHexString:@"#fffce1"];
        _singularTipBgView.top = -44;
        _singularTipBgView.hidden = YES;
        
        [_singularTipBgView addSubview:self.singularTipIcon];
        [_singularTipBgView addSubview:self.singularTipLabel];
        [_singularTipBgView addSubview:self.singularTipCancelBtn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singularTipTapAction:)];
        [_singularTipBgView addGestureRecognizer:tap];
        
    }
    return _singularTipBgView;
}

-(UIImageView *)singularTipIcon
{
    if (!_singularTipIcon) {
        _singularTipIcon = [[UIImageView alloc]initWithFrame:CGRectMake(29, 12, 20, 20)];
        _singularTipIcon.image = [UIImage imageNamed:@"icon_caution"];
    }
    return _singularTipIcon;
}

-(UILabel *)singularTipLabel
{
    if (!_singularTipLabel) {
        _singularTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 12, self.view.width-70-56, 20)];
        _singularTipLabel.backgroundColor = [UIColor clearColor];
        _singularTipLabel.font = [UIFont boldSystemFontOfSize:16];
        _singularTipLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    }
    return _singularTipLabel;
}

-(UIButton *)singularTipCancelBtn
{
    if (!_singularTipCancelBtn) {
        _singularTipCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _singularTipCancelBtn.frame = CGRectMake(0, 10, 24, 24);
        _singularTipCancelBtn.right = self.view.width - 15;
        [_singularTipCancelBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_singularTipCancelBtn addTarget:self action:@selector(singularTipCancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _singularTipCancelBtn;
}





#pragma mark- getter
-(UIView *)statusShowBgView
{
    if (!_statusShowBgView) {
        _statusShowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 32)];
        _statusShowBgView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.2];
        
    }
    return _statusShowBgView;
}

-(UIImageView *)statusNetIcon
{
    if (!_statusNetIcon) {
        _statusNetIcon = [[UIImageView alloc]initWithFrame:CGRectMake(17, 7, 18, 18)];
        _statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_wifi"];
    }
    return _statusNetIcon;
}

-(UILabel *)statusNetLabel
{
    if (!_statusNetLabel) {
        _statusNetLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.statusNetIcon.right+10, self.statusNetIcon.top, 100, self.statusNetIcon.height)];
        _statusNetLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _statusNetLabel.font = [UIFont systemFontOfSize:12];
        _statusNetLabel.text = [NSString stringWithFormat:@"WiFi%@",[JfgLanguage getLanTextStrByKey:@"DOOR_CONNECT"]];;
    }
    return _statusNetLabel;
}

-(UIImageView *)statusBatteryIcon
{
    if (!_statusBatteryIcon) {
        _statusBatteryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 6, 18, 18)];
        _statusBatteryIcon.right = self.view.width - 15;
        _statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_full"];
    }
    return _statusBatteryIcon;
}

-(UILabel *)statusBatteryLabel
{
    if (!_statusBatteryLabel) {
        _statusBatteryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, 40, 18)];
        _statusBatteryLabel.right = self.view.width - 10 - 30;
        _statusBatteryLabel.font = [UIFont systemFontOfSize:12];
        _statusBatteryLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _statusBatteryLabel.text = @"100%";
        _statusBatteryLabel.textAlignment = NSTextAlignmentRight;
        
    }
    return _statusBatteryLabel;
}

-(UILabel *)rateLabel
{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 37, 50, 22)];
        _rateLabel.right = self.view.width - 10;
        _rateLabel.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.2];
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        _rateLabel.font = [UIFont systemFontOfSize:12];
        _rateLabel.layer.masksToBounds = YES;
        _rateLabel.layer.cornerRadius = 3;
        _rateLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _rateLabel.text = @"0K/s";
        _rateLabel.hidden = YES;
    }
    return _rateLabel;
}

-(UIView *)speedModeBgView
{
    if (!_speedModeBgView) {
        
        CGFloat btnWidth = 50 + 41 + 12;
        CGFloat top = self.view.height - 64 - self.bottomBgView.height-15-44;
        _speedModeBgView = [[UIView alloc]initWithFrame:CGRectMake(self.view.width-144-15, top, btnWidth, 44)];
        _speedModeBgView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.4];
        _speedModeBgView.layer.masksToBounds = YES;
        _speedModeBgView.layer.cornerRadius = 22;
        _speedModeBgView.right = self.videoBgImageView.width-15;
        _speedModeBgView.top = self.view.height - 64 - self.bottomBgView.height;
        _speedModeBgView.alpha = 0;
        _speedModeBgView.tag = 1;
        
        UIImageView *leftImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"btn_leftkey_nomal"]];
        leftImageView.left = 10;
        leftImageView.top = 10;
        [_speedModeBgView addSubview:leftImageView];
        
        UILabel *textlabel = [[UILabel alloc]initWithFrame:CGRectMake(32+5, 12, 60, 20)];
        textlabel.font = [UIFont systemFontOfSize:15];
        textlabel.textColor  = [UIColor colorWithHexString:@"#ffffff"];
        textlabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"];
        textlabel.tag = 1000002;
        [textlabel sizeToFit];
        [_speedModeBgView addSubview:textlabel];
        
        btnWidth = textlabel.width + 41 + 12;
        _speedModeBgView.width = btnWidth;
        _speedModeBgView.right = self.view.width - 15;
        __weak typeof(self) weakSelf = self;
        [self.KVOController observe:textlabel keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            UILabel *lb = [weakSelf.speedModeBgView viewWithTag:1000002];
            //根据文字适配
            [lb sizeToFit];
            CGFloat allWidth = lb.width + 41 + 12;;
            weakSelf.speedModeBgView.width = allWidth;
            weakSelf.speedModeBgView.right = self.view.width - 15;
            
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(speedTapAction)];
        [_speedModeBgView addGestureRecognizer:tap];
       
    }
    return _speedModeBgView;
}

-(void)speedTapAction
{
    if (self.speedModeBgView.tag == 1) {
        [self videoResolvingPowerForIsHight:NO];
    }else{
        [self videoResolvingPowerForIsHight:YES];
    }
}

-(UIButton *)voiceBtn
{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake(0, 0, 0, 0);
//        _voiceBtn.frame = CGRectMake(0, 0, 44, 44);
//        _voiceBtn.bottom = self.speedModeBgView.top-15;
//        _voiceBtn.right = self.videoBgImageView.width-15;
//        [_voiceBtn setImage:[UIImage imageNamed:@"camera720_icon_no_voice_nomal"] forState:UIControlStateNormal];
//        [_voiceBtn setImage:[UIImage imageNamed:@"camera720_icon_no_voice_pressed"] forState:UIControlStateHighlighted];
//        _voiceBtn.top = self.view.height - 64 - self.bottomBgView.height;
//        _voiceBtn.alpha = 0;
//        [_voiceBtn addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
        //camera720_icon_voice_nomal
        //camera720_icon_voice_pressed
    }
    return _voiceBtn;
}

-(UIButton *)micBtn
{
    if (!_micBtn) {
        _micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _micBtn.frame = CGRectMake(0, 0, 0, 0);
        
        //音频功能恢复后，放开一下代码
//        _micBtn.frame = CGRectMake(0, 0, 44, 44);
//        _micBtn.bottom = self.voiceBtn.top-15;
//        _micBtn.right = self.videoBgImageView.width-15;
//        _micBtn.top = self.view.height - 64 - self.bottomBgView.height;
//        [_micBtn setImage:[UIImage imageNamed:@"camera720_icon_notalk_nomal"] forState:UIControlStateNormal];
//        [_micBtn setImage:[UIImage imageNamed:@"camera720_icon_notalk_pressed"] forState:UIControlStateHighlighted];
//        _micBtn.alpha = 0;
//        [_micBtn addTarget:self action:@selector(micAction:) forControlEvents:UIControlEventTouchUpInside];
        //camera720_icon_talk_nomal
        //camera720_icon_talk_pressed
    }
    return _micBtn;
}

-(void)micAction:(UIButton *)sender
{
    
//    if (sender.selected) {
//        
//        //关闭麦克
//        sender.selected = NO;
//        [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:isAudio];
//        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
//        isTalkBack = NO;
//        
//    }else{
//        
//        if ([JFGEquipmentAuthority canRecordPermission]) {
//            sender.selected = YES;
//            [CylanJFGSDK setAudio:YES openMic:YES openSpeaker:YES];
//            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:YES];
//            isTalkBack = YES;
//        }
//    }
}

-(void)voiceAction:(UIButton *)sender
{
//    if (sender.selected) {
//        //打开
//        if ([JFGEquipmentAuthority canRecordPermission]) {
//            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:YES];
//            [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:YES];
//            sender.selected = !sender.selected;
//            isAudio = YES;
//        }
//        
//    }else{
//        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
//        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:YES];
//        sender.selected = !sender.selected;
//        isAudio = NO;
//    }
}

-(void)hideMoreBtn
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGFloat top = self.view.height - 64 - self.bottomBgView.height;
        self.speedModeBgView.top = top;
        self.voiceBtn.top = top;
        self.micBtn.top = top;
        
        self.speedModeBgView.alpha = 0;
        self.voiceBtn.alpha = 0;
        self.micBtn.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.speedModeBgView.alpha = 0;
        self.voiceBtn.alpha = 0;
        self.micBtn.alpha = 0;
    }];
}

-(void)showMoreBtn
{
    [UIView animateWithDuration:0.2 animations:^{
        self.speedModeBgView.alpha = 1;
        self.speedModeBgView.hidden = NO;
        self.voiceBtn.alpha = 1;
        self.micBtn.alpha = 1;
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat top = self.view.height - 64 - self.bottomBgView.height-15-44;
        self.micBtn.bottom = top - self.voiceBtn.height - 15 - 15;
        self.voiceBtn.bottom = top - 15;
        self.speedModeBgView.top = top;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)msgAction
{
    MsgFor720ViewController *msg = [MsgFor720ViewController new];
    msg.cid = self.devModel.uuid;
    msg.devModel = self.devModel;
    [self.navigationController pushViewController:msg animated:YES];
    self.warnRedPoint.hidden = YES;
}

-(JFGTimepieceView *)timepiceView
{
    if (!_timepiceView) {
        _timepiceView = [[JFGTimepieceView alloc]initWithFrame:CGRectMake(0, 18, 100, 18)];
        _timepiceView.x = self.view.width*0.5;
        _timepiceView.hidden = YES;
    }
    return _timepiceView;
}

-(UILabel *)shortVideoTimeLabel
{
    if (!_shortVideoTimeLabel) {
        _shortVideoTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 18, 100, 18)];
        _shortVideoTimeLabel.x = self.view.width * 0.5;
        _shortVideoTimeLabel.font = [UIFont systemFontOfSize:16];
        _shortVideoTimeLabel.textAlignment = NSTextAlignmentCenter;
        _shortVideoTimeLabel.textColor = [UIColor whiteColor];
        _shortVideoTimeLabel.text = @"0S";
        _shortVideoTimeLabel.hidden = YES;
    }
    return _shortVideoTimeLabel;
}

-(JFGShortVideoRecordAnimation *)recordAnimationView
{
    if (!_recordAnimationView) {
        _recordAnimationView = [[JFGShortVideoRecordAnimation alloc]initWithFrame:CGRectMake(0, 0, self.bottomBgView.width, 3)];
        _recordAnimationView.hidden = YES;
    }
    return _recordAnimationView;
}

-(UIActivityIndicatorView *)takePhotoLoadingView
{
    if (!_takePhotoLoadingView) {
        _takePhotoLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _takePhotoLoadingView.center = CGPointMake(self.takePhotoBtn.width*0.5, self.takePhotoBtn.height*0.5);
        
    }
    return _takePhotoLoadingView;
}

-(UIView *)againBgView
{
    if (!_againBgView) {
        _againBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250*0.5, 250*0.5)];
        _againBgView.center = CGPointMake(self.videoBgImageView.width*0.5, self.videoBgImageView.height*0.5+40);
        _againBgView.backgroundColor = [UIColor clearColor];
        _againBgView.hidden = YES;
        
        UIButton *againBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [againBtn setImage:[UIImage imageNamed:@"camera_icon_no-network"] forState:UIControlStateNormal];
        againBtn.size = CGSizeMake(50, 50);
        againBtn.x = self.againBgView.width*0.5;
        [againBtn addTarget:self action:@selector(againAction) forControlEvents:UIControlEventTouchUpInside];
        [_againBgView addSubview:againBtn];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, againBtn.bottom+19, self.againBgView.width, 17)];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"重新加载";
        [_againBgView addSubview:label];
        
        againBtn.top = (_againBgView.height - 19 - againBtn.height - label.height)*0.5;
    }
    return _againBgView;
}

-(UIView *)netModeSwitchBgView
{
    if (!_netModeSwitchBgView) {
        _netModeSwitchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _netModeSwitchBgView.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.6];
        //540 × 702
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pop_model"]];
        bgImageView.center = self.view.center;
        bgImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(netModeSwitchTap:)];
        [bgImageView addGestureRecognizer:tap];
        [_netModeSwitchBgView addSubview:bgImageView];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(0, 0, 44, 44);
        closeBtn.x = self.view.x;
        closeBtn.top = bgImageView.bottom + 20;
        [closeBtn setImage:[UIImage imageNamed:@"pop_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(netModeViewCloseAction) forControlEvents:UIControlEventTouchUpInside];
        [_netModeSwitchBgView addSubview:closeBtn];
        
        
        
        for (int i=0; i<2; i++) {
            
            CGFloat startTop = 0;
            if (i==0) {
                startTop = 20;
            }else{
                startTop = bgImageView.height*0.5+20;
            }
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, startTop, bgImageView.width, 17)];
            titleLable.textColor = [UIColor colorWithHexString:@"#333333"];
            titleLable.font = [UIFont systemFontOfSize:16];
            titleLable.textAlignment = NSTextAlignmentCenter;
            
            UILabel *detailLable = [[UILabel alloc]initWithFrame:CGRectMake(29, titleLable.bottom+100-10, bgImageView.width-58, 35)];
            detailLable.font = [UIFont systemFontOfSize:14];
            detailLable.numberOfLines = 2;
            detailLable.textColor = [UIColor colorWithHexString:@"#666666"];
            detailLable.textAlignment = NSTextAlignmentCenter;
            
            if (i == 0) {
                titleLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_HomeMode"];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_TCPconnected"]];
                NSRange strRange = {0,[str length]};
                [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
                detailLable.attributedText = str;
                
                
            }else{
                titleLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_OutdoorMode"];
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_UDPconnected"]];
                NSRange strRange = {0,[str length]};
                [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
                detailLable.attributedText = str;
                detailLable.top = titleLable.bottom+95-10;
            }
            
            [bgImageView addSubview:titleLable];
            [bgImageView addSubview:detailLable];
        }
        
    }
    return _netModeSwitchBgView;
}

-(UILabel *)offlineLabel
{
    if (!_offlineLabel) {
        _offlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 12, self.view.width*0.5, 20)];
        _offlineLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _offlineLabel.font = [UIFont systemFontOfSize:12];
        _offlineLabel.text = [JfgLanguage getLanTextStrByKey:@"NOT_ONLINE"];
        _offlineLabel.textAlignment = NSTextAlignmentLeft;
        _offlineLabel.hidden = YES;
    }
    return _offlineLabel;
}


-(NSString *)startRecIsLongVideo:(BOOL)isLong
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        int islon = 1;
        if (isLong) {
            islon = 2;
        }else{
            islon = 1;
        }
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=startRec&videoType=%d",devIpAddr,islon];
    }
    return @"";
    
}

-(NSString *)videoRPIsHight:(BOOL)isHight
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=setResolution&videoStandard=%d",devIpAddr,isHight?1:0];
    }
    return @"";
}

-(NSString *)stopRecIsLongVideo:(BOOL)isLong
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=stopRec&videoType=%d",devIpAddr,isLong?2:1];
    }
    return @"";
}

-(NSString *)downloadForFileName:(NSString *)fileName
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    if (isAP) {
        devIpAddr = @"192.168.10.2";
    }
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/images/%@",devIpAddr,fileName];
    }
    return @"";
}

-(UIButton *)msgBtn
{
    if (!_msgBtn) {
        _msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _msgBtn.frame = CGRectMake(0, 0, 30, 30);
        _msgBtn.right = self.view.width - 58;
        _msgBtn.top = 26;
        [_msgBtn setImage:[UIImage imageNamed:@"icon_imaggega"] forState:UIControlStateNormal];
        [_msgBtn addTarget:self action:@selector(msgAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgBtn;
}

-(UIView *)cameraRedPoint
{
    if (!_cameraRedPoint) {
        _cameraRedPoint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        _cameraRedPoint.backgroundColor = [UIColor redColor];
        _cameraRedPoint.layer.masksToBounds = YES;
        _cameraRedPoint.layer.cornerRadius = 4;
        _cameraRedPoint.hidden = YES;
        _cameraRedPoint.left = self.albumsBtn.left + 34;
        _cameraRedPoint.bottom = self.albumsBtn.bottom -34;
    }
    return _cameraRedPoint;
}

-(UIView *)warnRedPoint
{
    if (!_warnRedPoint) {
        _warnRedPoint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        _warnRedPoint.backgroundColor = [UIColor redColor];
        _warnRedPoint.layer.masksToBounds = YES;
        _warnRedPoint.layer.cornerRadius = 4;
        _warnRedPoint.hidden = YES;
        _warnRedPoint.left = self.msgBtn.left + 20;
        _warnRedPoint.bottom = self.msgBtn.bottom - 18;
    }
    return _warnRedPoint;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [JFGSDK appendStringToLogFile:@"video720VC dealloc"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
