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

@interface SetWifiLoadingFor720VC ()<JFGSDKCallbackDelegate>
{
    NSString *currentCid;
    BOOL isShowOuttime;
    NSTimer *timeOutTimer;
    int timeCount;
}
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)BindProgressAnimationView *animationView;
@end

@implementation SetWifiLoadingFor720VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.animationView];
    
    //开启屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.animationView starAnimation];
    
    isShowOuttime = YES;
    [JFGSDK appendStringToLogFile:@"startOuttimeCount"];
    
    [JFGSDK addDelegate:self];
    [JFGSDK fping:@"255.255.255.255"];
    
    timeCount = 0;
    timeOutTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        
        timeCount ++;
        if (timeCount > 90) {
            [self netConnectTimeout];
            [timeOutTimer invalidate];
            timeOutTimer = nil;
        }
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"setwifi:%d",timeCount]];
        
    } repeats:YES];
    // Do any additional setup after loading the view.
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
        [blockself checkDeviceNetStatue];
    }
}

-(void)checkDeviceNetStatue
{
    if (self.cid && ![self.cid isEqualToString:@""]) {
        
        __block SetWifiLoadingFor720VC *blockself = self;
        [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgBase_Net)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
            NSArray *wifiArray = [dic objectForKey:msgBaseNetKey];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"主动检测网络:%@",[wifiArray description]]];
            
            if (wifiArray.count >= 2)
            {
                switch ([[wifiArray objectAtIndex:0] integerValue])
                {
                    case DeviceNetType_2G:
                    case DeviceNetType_3G:
                    case DeviceNetType_4G:
                    case DeviceNetType_5G:
                    case DeviceNetType_Wifi:
                    {
                        [JFGSDK removeDelegate:blockself];
                        [blockself.animationView successAnimationWithCompletionBlock:^{
                
                            WifiModeFor720CFResultVC *result = [WifiModeFor720CFResultVC new];
                            result.isAPModeFinished = NO;
                            [blockself.navigationController pushViewController:result animated:YES];
                            
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }else{
                
                
            }
        } FailBlock:^(RobotDataRequestErrorType error) {
            
            
            
        }];
    }
    
}

- (void)pushToErrorVC
{
    //isShowOuttime = NO;
    
    if (timeOutTimer && [timeOutTimer isValid]) {
        [timeOutTimer invalidate];
        timeOutTimer = nil;
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"setWfifError [%d]", 600]];
    AddDeviceErrorVC *errorVC = [AddDeviceErrorVC new];
    errorVC.errorType = 600;
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
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"被动网络推送:%@: %@",peer,[obj description]]];
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
                                        
                                        WifiModeFor720CFResultVC *result = [WifiModeFor720CFResultVC new];
                                        result.isAPModeFinished = NO;
                                        [blockself.navigationController pushViewController:result animated:YES];
                                        
                                    }];
                                }
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_tips"] message:nil delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"OK"], nil];
    alert.tag = 1024;
    [alert show];
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
        _animationView = [[BindProgressAnimationView alloc]initWithFrame:CGRectMake(0, self.view.height*0.32-72, 0, 0)];
        _animationView.x = self.view.x;
        _animationView.bindResetBlock = ^(){
           
        };
    }
    return _animationView;
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
