//
//  ConnDeviceViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ConnDeviceViewController.h"
#import "JfgGlobal.h"
#import "FLGlobal.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "OLImageView.h"
#import "OLImage.h"
#import "CommonMethod.h"
#import "DelButton.h"
#import "ConfigWiFiViewController.h"
#import "FLGlobal.h"
#import "BindDevProgressViewController.h"

#define SCREEN_SIZE   [[UIScreen mainScreen] bounds].size
#define DEVICE_IPHONE4S CGSizeEqualToSize(CGSizeMake(320, 480), SCREEN_SIZE)
#define kScreen_Scale  (DEVICE_IPHONE4S==YES ? [UIScreen mainScreen].bounds.size.height/667.0 : [UIScreen mainScreen].bounds.size.width/375.0)
#define kLeft (Kwidth-270.0*kScreen_Scale)/2
#define kTop 100.0*kScreen_Scale
#define Width 270*kScreen_Scale
@interface ConnDeviceViewController ()<JFGSDKCallbackDelegate>
{
    BOOL devHasNet;//设备自身网络是否可用
}
@property(nonatomic, strong) UIImageView * circle1;
@property(nonatomic, strong) UILabel * label1;
@property(nonatomic, strong) UIImageView * circle2;
@property(nonatomic, strong) UILabel * label2;
@property(nonatomic, strong)OLImageView * olImageView;
@property(nonatomic, strong)UILabel * lineLabel_bottom;
@property(nonatomic, strong)UIButton * goToSettingButton;
@property(nonatomic, strong)DelButton * exitBtn;
@end

@implementation ConnDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.circle1];
    [self.view addSubview:self.label1];
    [self.view addSubview:self.circle2];
    [self.view addSubview:self.label2];
    [self.view addSubview:self.exitBtn];
    
    if (!IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)){
        [self.view addSubview:self.goToSettingButton];
        [self.view addSubview:self.lineLabel_bottom];
    }
    /*
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    playerLayer.frame = CGRectMake(kLeft, self.label2.bottom+40*kScreen_Scale, Width, 350*kScreen_Scale);
    [self.view.layer addSublayer:playerLayer];
    [self.avPlayer play];
    
    //监听视频播放玩后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //监听视屏播放状态
    //[item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];*/
    [self.view addSubview:self.olImageView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
    isConnectAp = [CommonMethod isConnecttedDeviceWifiWithPid:self.pType];
    if (isConnectAp) {
        [JFGSDK ping:@"255.255.255.255"];
    }
    if (IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)) {
        
        
        if (isConnectAp) {
            if (self.goToSettingButton.superview != self.view) {
                [self.view addSubview:self.goToSettingButton];
                [self.view addSubview:self.lineLabel_bottom];
            }
        }else{
            [self.goToSettingButton removeFromSuperview];
            [self.lineLabel_bottom removeFromSuperview];
        }
        
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)becomeActive:(NSNotificationCenter *)notifi
{
    if ([CommonMethod isConnecttedDeviceWifiWithPid:self.pType]) {
//        ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
//        configWifi.cid = self.cidStr;
//        configWifi.configType = self.configType;
//        configWifi.pType = self.pType;
//        if (self.pType == productType_FreeCam) {
//            configWifi.isCamare = NO;
//        }else{
//            configWifi.isCamare = YES;
//        }
//        [self.navigationController pushViewController:configWifi animated:YES];
        [JFGSDK ping:@"255.255.255.255"];
    }
}

-(void)goNextVCIsConfigWifi:(BOOL)isConfig forCid:(NSString *)cid
{
    if (isConfig) {
        ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
        configWifi.cid = cid;
        configWifi.pType = self.pType;
        configWifi.configType = self.configType;
        if (self.pType == productType_FreeCam)
        {
            if (
                //部分门铃可以获取wifi列表
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"50"] ||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"51"] ||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"65"]||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"60"]||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"66"]||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"67"]||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"69"]||
                [[cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"68"]) {
                
                configWifi.isCamare = YES;
                
            }else{
                
                configWifi.isCamare = NO;
            }
            
        }else{
            configWifi.isCamare = YES;
        }
        [self.navigationController pushViewController:configWifi animated:YES];
    }else{
        BindDevProgressViewController * bindDev = [BindDevProgressViewController new];
        bindDev.cid = cid;
        bindDev.pType = self.pType;
        bindDev.wifiName = @"";
        bindDev.wifiPassWord = @"";
        [self.navigationController pushViewController:bindDev animated:YES];
    }
}

#pragma mark - JFGSDKCallBack
- (void)jfgPingRespose:(JFGSDKUDPResposePing *)ask
{
//    self.netType = ask.net;
    if ((ask.net == 2 || ask.net == 3 || ask.net == 4 || ask.net == 5) && self.configType != configWifiType_configWifi)
    {
        devHasNet = YES;
        [self goNextVCIsConfigWifi:NO forCid:ask.cid];
    }
    else
    {
        devHasNet = NO;
        [self goNextVCIsConfigWifi:YES forCid:ask.cid];
    }
}


#pragma mark - buttonAction
-(void)exitAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoSettingButtonAction
{
    isConnectAp = [CommonMethod isConnecttedDeviceWifiWithPid:self.pType];
    
    if (isConnectAp == NO)
    {
        if (IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }
    }
    else
    {
        if (devHasNet) {
            [self goNextVCIsConfigWifi:NO forCid:self.cidStr];
        }else{
            [self goNextVCIsConfigWifi:YES forCid:self.cidStr];
        }
        
    }
}
#pragma mark - 控件
-(UIImageView *)circle1{
    if (!_circle1) {
        _circle1 = [[UIImageView alloc]initWithFrame:CGRectMake(kLeft, kTop, 7, 7)];
        _circle1.image = [UIImage imageNamed:@"add_tipImage_blue"];
    }
    return _circle1;
}
-(UIImageView *)circle2{
    if (!_circle2) {
        _circle2 = [[UIImageView alloc]initWithFrame:CGRectMake(kLeft, self.label1.bottom+10, 7, 7)];
        _circle2.image = [UIImage imageNamed:@"add_tipImage_gray"];
        [self.view addSubview:_circle2];
    }
    return _circle2;
}
-(UILabel *)label1{
    if (!_label1) {
        _label1 = [[UILabel alloc]initWithFrame:CGRectMake(self.circle1.right+9, kTop-4, Width-self.circle1.width-9, 15*kScreen_Scale)];
        _label1.font = [UIFont fontWithName:@"PingFangSC-medium" size:15*kScreen_Scale];
        _label1.font = [UIFont systemFontOfSize:15*kScreen_Scale];
        _label1.textColor = [UIColor colorWithHexString:@"#333333"];
        _label1.numberOfLines = 0;
        _label1.lineBreakMode = NSLineBreakByCharWrapping;
        _label1.textAlignment = NSTextAlignmentLeft;
        _label1.text = [JfgLanguage getLanTextStrByKey:@"WIFI_SET_3"];
        CGSize size = [_label1 sizeThatFits:CGSizeMake(_label1.width, MAXFLOAT)];
        _label1.frame = CGRectMake(self.circle1.right+9, kTop-3, Width-self.circle1.width, size.height);
    }
    return _label1;
}
-(UILabel *)label2{
    if (!_label2) {
        _label2 = [[UILabel alloc]initWithFrame:CGRectMake(self.circle2.right+9, self.circle2.top-3, self.label1.width, 15*kScreen_Scale+2)];
        _label2.font = [UIFont fontWithName:@"PingFangSC-medium" size:15*kScreen_Scale];
        _label2.font = [UIFont systemFontOfSize:15*kScreen_Scale];
        _label2.textColor = [UIColor colorWithHexString:@"#333333"];
        _label2.textAlignment = NSTextAlignmentLeft;
        
        _label2.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"WIFI_SET_4"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    }
    return _label2;
}
-(OLImageView *)olImageView{
    if (!_olImageView) {
        _olImageView = [[OLImageView alloc]initWithFrame:CGRectMake(kLeft, self.label2.bottom+30*kScreen_Scale, 230*kScreen_Scale, 350*kScreen_Scale)];
        [_olImageView setImage:[OLImage imageNamed:[JfgLanguage getLanPicNameWithPicName:@"connDevice"]]];
        _olImageView.x = self.view.x;
    }
    return _olImageView;
}
-(UILabel *)lineLabel_bottom{
    if (!_lineLabel_bottom) {
        _lineLabel_bottom = [[UILabel alloc]initWithFrame:CGRectMake(0, kheight-52-0.5, Kwidth, 0.5)];
        _lineLabel_bottom.backgroundColor = [UIColor colorWithHexString:@"#d8d8d8"];
    }
    return _lineLabel_bottom;
}
-(UIButton *)goToSettingButton{
    if (!_goToSettingButton) {
        _goToSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _goToSettingButton.frame = CGRectMake(0, kheight-52, Kwidth, 52);
        [_goToSettingButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_goToSettingButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_ToSetting"] forState:UIControlStateNormal];
        _goToSettingButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_goToSettingButton addTarget:self action:@selector(gotoSettingButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goToSettingButton;
}
-(DelButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10, 37, 10, 18);
        [_exitBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}
@end
