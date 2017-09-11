//
//  SetWifiFor720VC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "SetWifiLoadingFor720VC.h"
#import "BindProgressAnimationView.h"
#import "UIView+FLExtensionForFrame.h"
#import "AddDeviceErrorVC.h"
#import "NSTimer+FLExtension.h"
#import "AddDeviceMainViewController.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDK.h>
#import "WifiModeFor720CFResultVC.h"
#import "dataPointMsg.h"
#import "JfgMsgDefine.h"
#import "VideoPlayFor720ViewController.h"
#import "UIColor+HexColor.h"
#import "LSAlertView.h"

@interface SetWifiLoadingFor720VC ()<JFGSDKCallbackDelegate>
{
    NSString *currentCid;
    BOOL isShowOuttime;
    NSTimer *timeOutTimer;
    int timeCount;
    BOOL isPushed;
}
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)BindProgressAnimationView *animationView;
@property (nonatomic,strong)UILabel *detailLabel;
@end

@implementation SetWifiLoadingFor720VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.animationView];
    [self.view addSubview:self.detailLabel];
    
    //开启屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.animationView starAnimation];
    
    isShowOuttime = YES;
    [self startTimer];
    [JFGSDK appendStringToLogFile:@"startOuttimeCount"];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isPushed = NO;
    [JFGSDK addDelegate:self];
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    
}


-(void)startTimer
{
    if (timeOutTimer && timeOutTimer.isValid) {
        [timeOutTimer invalidate];
    }
    __weak typeof(self) weakSelf = self;
    timeCount = 0;
    timeOutTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        
        timeCount ++;
        if (timeCount>5) {
            
            if (timeCount%2==0) {
                [weakSelf checkDeviceNetStatue];
            }
            
        }
        if (timeCount > 90) {
            [timeOutTimer invalidate];
            timeOutTimer = nil;
            [weakSelf netConnectTimeout];
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"setwifi:%d",timeCount]];
        
    } repeats:YES];
}

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self.cid]) {
        [JFGSDK wifiSetWithSSid:self.wifiName keyword:self.wifiPassword cid:self.cid ipAddr:ask.address mac:ask.mac];
    }
}

-(void)jfgSetWifiRespose:(JFGSDKUDPResposeSetWifi *)ask
{
    if ([ask.cid isEqualToString:self.cid]) {
        //成功
        __block SetWifiLoadingFor720VC *blockself = self;
        int64_t delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [blockself checkDeviceNetStatue];
            
        });
        
    }
}

-(void)checkDeviceNetStatue
{
    if (self.cid && ![self.cid isEqualToString:@""]) {
        
        __block SetWifiLoadingFor720VC *blockself = self;
        [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(dpMsgBase_Net)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            
            for (NSArray *subArr in idDataList) {
                for (DataPointSeg *seg in subArr) {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        NSArray *objArr = obj;
                        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"720主动网络检测，%@",obj]];
                        if (objArr.count>0) {
                            
                            int netType = [[objArr objectAtIndex:0] intValue];
                            switch (netType)
                            {
                                case DeviceNetType_2G:
                                case DeviceNetType_3G:
                                case DeviceNetType_4G:
                                case DeviceNetType_5G:
                                case DeviceNetType_Wifi:
                                {
                                    [JFGSDK removeDelegate:blockself];
                                    [blockself.animationView successAnimationWithCompletionBlock:^{
                                        
                                        if (timeOutTimer && timeOutTimer.isValid) {
                                            [timeOutTimer invalidate];
                                        }
                                        timeOutTimer = nil;
                                        if (!isPushed) {
                                            WifiModeFor720CFResultVC *result = [WifiModeFor720CFResultVC new];
                                            result.isAPModeFinished = NO;
                                            [blockself.navigationController pushViewController:result animated:YES];
                                            isPushed = YES;
                                        }
                                        
                                        
                                    }];
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                        }
                    }
                   
                }
            }
            
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
       
    }else{
        [JFGSDK appendStringToLogFile:@"720网络检测，cid为空"];
        
    }
    
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (online) {
        [self checkDeviceNetStatue];
    }
}

- (void)pushToErrorVC
{
    if (timeOutTimer && [timeOutTimer isValid]) {
        [timeOutTimer invalidate];
        timeOutTimer = nil;
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"setWfifError [%d]", 600]];
    AddDeviceErrorVC *errorVC = [AddDeviceErrorVC new];
    errorVC.errorType = 600;
    errorVC.pType = productType_720;
    [self.navigationController pushViewController:errorVC animated:YES];
}

#pragma mark receive push_msg
- (void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    @try
    {
        
        for (DataPointSeg *seg in msgList)
        {
            NSError *error = nil;
            __block SetWifiLoadingFor720VC *blockself = self;
            id obj = [MPMessagePackReader readData:seg.value error:&error];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"网络推送:%@: %@",peer,[obj description]]];
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
                            switch (netType)
                            {
                                case DeviceNetType_2G:
                                case DeviceNetType_3G:
                                case DeviceNetType_4G:
                                case DeviceNetType_5G:
                                case DeviceNetType_Wifi:
                                {
                                    [JFGSDK removeDelegate:blockself];
                                    [blockself.animationView successAnimationWithCompletionBlock:^{
                                        
                                        if (!isPushed) {
                                            WifiModeFor720CFResultVC *result = [WifiModeFor720CFResultVC new];
                                            result.isAPModeFinished = NO;
                                            [blockself.navigationController pushViewController:result animated:YES];
                                            isPushed = YES;
                                        }
                                       
                                        
                                    }];
                                }
                                    break;
                                default:
                                    break;
                            }
                            
                        }
                    }
                    
                }
                    break;
            }
        }

    } @catch (NSException *exception) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jifeigou RootViewControl %@",exception]];
    } @finally {
        
    }
}



-(void)netConnectTimeout
{
    [self.animationView failedAnimation];
    [self pushToErrorVC];
}

-(void)back
{
    __weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_tips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        
    } OKBlock:^{
        if (weakSelf.navigationController){
            for (UIViewController *temp in weakSelf.navigationController.viewControllers)
            {
                if ([temp isKindOfClass:[AddDeviceMainViewController class]])
                {
                    [weakSelf.navigationController popToViewController:temp animated:YES];
                }else if ([temp isKindOfClass:[VideoPlayFor720ViewController class]]){
                    [weakSelf.navigationController popToViewController:temp animated:YES];
                }
            }
            
        }else{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }

    }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1024 && buttonIndex == 1) {
        
        if (self.navigationController){
            for (UIViewController *temp in self.navigationController.viewControllers)
            {
                if ([temp isKindOfClass:[AddDeviceMainViewController class]])
                {
                    [self.navigationController popToViewController:temp animated:YES];
                }else if ([temp isKindOfClass:[VideoPlayFor720ViewController class]]){
                    [self.navigationController popToViewController:temp animated:YES];
                }
            }
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

#pragma mark- getter
-(UIButton *)backBtn
{
    if (!_backBtn) {
        //20 36
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 74*0.5, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(BindProgressAnimationView *)animationView
{
    if (!_animationView) {
        _animationView = [[BindProgressAnimationView alloc]initWithFrame:CGRectMake(0, self.view.height*0.28-25, 0, 0)];
        _animationView.x = self.view.x;
        _animationView.bindResetBlock = ^(){
           
        };
    }
    return _animationView;
}

-(UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.animationView.bottom, self.view.width, 19)];
        _detailLabel.font = [UIFont systemFontOfSize:18];
        _detailLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _detailLabel.text = [JfgLanguage getLanTextStrByKey:@"DEVICE_CONNECTING_WIFI"];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _detailLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
