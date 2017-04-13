//
//  AddDeviceGuideViewController.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/16.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddDeviceGuideViewController.h"
#import "DoorAddAnimationView.h"
#import "CameraAddAnimationView.h"
#import "ConnDeviceViewController.h"
#import "JfgGlobal.h"
#import "CommonMethod.h"
#import "ConfigWiFiViewController.h"
#import "BindDevProgressViewController.h"
#import "CarameFor720AddAnimationView.h"
#import "AddDeviceMainViewController.h"

@interface AddDeviceGuideViewController()<JFGSDKCallbackDelegate>

@property (nonatomic, strong) UILabel *topTipsLabel;
@property (nonatomic, strong) UILabel *bottomTipLabel;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) DoorAddAnimationView *doorAddAnimationView;
@property (nonatomic, strong) CameraAddAnimationView *cameraAddAnimationView;
@property (nonatomic, strong) CarameFor720AddAnimationView *carame720AddView;
@property (nonatomic, assign) JFGNetType netType;
@end

@implementation AddDeviceGuideViewController

//@dynamic pType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initNavigation];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
}


- (void)initView
{
    [self.view addSubview:self.topTipsLabel];
    [self.view addSubview:self.bottomTipLabel];
    [self.view addSubview:self.nextButton];
    
    if ([CommonMethod isCameraWithType:self.pType]) {
        [self.view addSubview:self.cameraAddAnimationView];
    }else if (self.pType == productType_720){
        [self.view addSubview:self.carame720AddView];
    }else{
        [self.view addSubview:self.doorAddAnimationView];
    }
    
    
    [self.view addSubview:self.backBtn];
}

- (void)initNavigation
{
    self.navigationView.hidden = YES;
    [self.leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark setter
- (UILabel *)topTipsLabel
{
    CGFloat widgetX = 15;
    CGFloat widgetY = 104 * designHscale;
    CGFloat widgetWidth = (Kwidth - widgetX*2);
    CGFloat widgetHeight = 30;
    
    if (_topTipsLabel == nil)
    {
        _topTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        
        if ([CommonMethod isCameraWithType:self.pType] || self.pType == productType_720) {
            _topTipsLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_CameraTipsTitle"];
        }else{
            _topTipsLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_DoorbellTipsTitle"];
        }
        _topTipsLabel.textAlignment = NSTextAlignmentCenter;
        _topTipsLabel.font = [UIFont systemFontOfSize:27.0f];
        _topTipsLabel.adjustsFontSizeToFitWidth = YES;
        _topTipsLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    
    return _topTipsLabel;
}

- (UILabel *)bottomTipLabel
{
    CGFloat widgetX = 15;
    CGFloat widgetY = self.topTipsLabel.bottom + 10 * designHscale;
    CGFloat widgetWidth = (Kwidth - widgetX*2);
    CGFloat widgetHeight = 30;
    
    if (_bottomTipLabel == nil)
    {
        _bottomTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _bottomTipLabel.textAlignment = NSTextAlignmentCenter;
       
        
        if ([CommonMethod isCameraWithType:self.pType] || self.pType == productType_720) {
            _bottomTipLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_CameraTips"];
        }else{
            _bottomTipLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_DoorbellTips"];
        }
        _bottomTipLabel.font = [UIFont systemFontOfSize:17.0f];
        _bottomTipLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    
    return  _bottomTipLabel;
}

- (UIButton *)nextButton
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 52;
    CGFloat widgetX = 0;
    CGFloat widgetY = kheight - widgetHeight;
    
    if (_nextButton == nil)
    {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        if ([CommonMethod isCameraWithType:self.pType] || self.pType == productType_720) {
            [_nextButton setTitle:[JfgLanguage getLanTextStrByKey:@"BLINKING"] forState:UIControlStateNormal];
        }else{
            [_nextButton setTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_BLINKING"] forState:UIControlStateNormal];
        }

        
        [_nextButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"add_btn_pressed"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"add_btn"] forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

- (DoorAddAnimationView *)doorAddAnimationView
{
    CGFloat widgetX = self.view.center.x;
    CGFloat widgetY = self.bottomTipLabel.bottom + 50 * designHscale;
    widgetY = ceil(widgetY);
    
    if (_doorAddAnimationView == nil)
    {
        _doorAddAnimationView = [[DoorAddAnimationView alloc] initWithFrame:CGRectMake(widgetX, widgetY, 0, 0)];
        [_doorAddAnimationView startAnimation];
    }
    
    return _doorAddAnimationView;
}

- (CameraAddAnimationView *)cameraAddAnimationView
{
    CGFloat widgetX = self.view.center.x;
    CGFloat widgetY = self.bottomTipLabel.bottom + 50 * designHscale;
    
    if (_cameraAddAnimationView == nil)
    {
        _cameraAddAnimationView = [[CameraAddAnimationView alloc] initWithFrame:CGRectMake(widgetX, widgetY, 0, 0)];
        [_cameraAddAnimationView startAnimation];
    }
    
    return _cameraAddAnimationView;
}

-(CarameFor720AddAnimationView *)carame720AddView
{
    CGFloat widgetX = self.view.center.x;
    CGFloat widgetY = self.bottomTipLabel.bottom + 50 * designHscale;
    
    
    if (_carame720AddView == nil)
    {
        _carame720AddView = [[CarameFor720AddAnimationView alloc] initWithFrame:CGRectMake(widgetX, widgetY, 0, 0)];
        
        if (_carame720AddView.bottom > self.nextButton.top) {
            _carame720AddView.bottom = self.nextButton.top;
        }
        [_carame720AddView startAnimation];
    }
    
    return _carame720AddView;
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 37, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark action
-(void)backAction
{
    if (self.navigationController){
        BOOL isPop = NO;
        for (UIViewController *temp in self.navigationController.viewControllers)
        {
            if ([temp isKindOfClass:[AddDeviceMainViewController class]])
            {
                isPop = YES;
                [self.navigationController popToViewController:temp animated:YES];
            }
        }
        
        if (!isPop) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    //
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)nextButtonAction:(UIButton *)sender
{
//    if ([CommonMethod isConnecttedDeviceWifiWithPid:self.pType]) {    //if has connected ap
//        
//        [JFGSDK ping:@"255.255.255.255"];          //need get dog's net type.
//    } else {
//       
//    }
    ConnDeviceViewController *conn = [[ConnDeviceViewController alloc] init];
    conn.pType = self.pType;
    conn.cidStr =self.cid;
    conn.configType = self.configType;
    [self.navigationController pushViewController:conn animated:YES];
}

#pragma mark - JFGSDKCallBack
- (void)jfgPingRespose:(JFGSDKUDPResposePing *)ask
{
    self.netType = ask.net;
    if ((self.netType == 2 || self.netType == 3 || self.netType == 4 || self.netType == 5) && self.configType != configWifiType_configWifi)
    {
        BindDevProgressViewController * bindDev = [BindDevProgressViewController new];
        bindDev.cid = ask.cid;
        bindDev.pType = self.pType;
        bindDev.wifiName = @"";
        bindDev.wifiPassWord = @"";
        [self.navigationController pushViewController:bindDev animated:YES];
    }
    else
    {
        ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
        configWifi.cid = ask.cid;
        configWifi.pType = self.pType;
        configWifi.configType = self.configType;
        if (self.pType == productType_FreeCam)
        {
            if (
                //部分门铃可以获取wifi列表
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"50"] ||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"51"] ||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"65"]||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"60"]||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"66"]||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"67"]||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"69"]||
                [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"68"]) {
                
                configWifi.isCamare = YES;
                
            }else{
                
                configWifi.isCamare = NO;
            }
            
        }else{
            configWifi.isCamare = YES;
        }
        [self.navigationController pushViewController:configWifi animated:YES];
    }
}
@end
