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
#import "OLImageView.h"
#import "OLImage.h"
#import "PilotLampStateVC.h"
#import "jfgConfigManager.h"
#import "ConfigWiredViewController.h"
#import "MTA.h"

@interface AddDeviceGuideViewController()<JFGSDKCallbackDelegate>

@property (nonatomic, strong) UILabel *topTipsLabel;
@property (nonatomic, strong) UILabel *bottomTipLabel;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *declareBtn;

@property (nonatomic, strong) DoorAddAnimationView *doorAddAnimationView;
@property (nonatomic, strong) CameraAddAnimationView *cameraAddAnimationView;
@property (nonatomic, strong) CarameFor720AddAnimationView *carame720AddView;
@property (nonatomic, strong) OLImageView * olImageView;
@property (nonatomic, assign) JFGNetType netType;
@property (nonatomic,strong)AddDevConfigModel *addModel;
@end

@implementation AddDeviceGuideViewController

//@dynamic pType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getAddModel];//如果获取失败，默认使用wifi绑定界面
    [self initView];
    [self initNavigation];
    [MTA trackCustomKeyValueEvent:@"AddDev_guideSetWifi" props:@{}];
}

-(void)getAddModel
{
    NSArray *dataArr = [jfgConfigManager getAllDevModel];
    
    //有线添加模式界面数据
    //因为支持有线添加的设备可能不只有92 这个设备，所以单独提出来
    if (self.pType == productType_wired) {
        
        for (NSArray *subArr in dataArr) {
            for (AddDevConfigModel *model in subArr) {
                
                for (NSNumber *os in model.osList) {
                    if ([os integerValue] == 92 && [model.typeMark intValue] == 9) {
                        self.addModel = model;
                        return;
                    }
                }
            }
        }
        
    }else{
        for (NSArray *subArr in dataArr) {
            for (AddDevConfigModel *model in subArr) {
                
                for (NSNumber *os in model.osList) {
                    
                    if ([os integerValue] == self.pType && [model.typeMark intValue] != 9) {
                        self.addModel = model;
                        return;
                    }
                }
            }
        }
    }
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
}


- (void)initView
{
    if ([self.addModel.typeMark integerValue] == 1) {
        [self.view addSubview:self.cameraAddAnimationView];
    }else if ([self.addModel.typeMark integerValue] == 2){
        [self.view addSubview:self.carame720AddView];
        [self.view addSubview:self.declareBtn];
    }else if ([self.addModel.typeMark integerValue] == 3){
        [self.view addSubview:self.doorAddAnimationView];
    }else{
        [self.view addSubview:self.olImageView];
    }
    [self.view addSubview:self.topTipsLabel];
    [self.view addSubview:self.bottomTipLabel];
    [self.view addSubview:self.nextButton];
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
        _topTipsLabel.text = [JfgLanguage getLanTextStrByKey:self.addModel.userActionTitle];
        _topTipsLabel.textAlignment = NSTextAlignmentCenter;
        _topTipsLabel.font = [UIFont systemFontOfSize:27.0f];
        _topTipsLabel.adjustsFontSizeToFitWidth = YES;
        _topTipsLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    
    return _topTipsLabel;
}

- (UILabel *)bottomTipLabel
{
    CGFloat widgetX = 18;
    CGFloat widgetY = self.topTipsLabel.bottom + 10 * designHscale;
    CGFloat widgetWidth = (Kwidth - widgetX*2);
    CGFloat widgetHeight = 45;
    
    if (_bottomTipLabel == nil)
    {
        _bottomTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _bottomTipLabel.numberOfLines = 2;
        _bottomTipLabel.textAlignment = NSTextAlignmentCenter;
       _bottomTipLabel.text = [JfgLanguage getLanTextStrByKey:self.addModel.ledTitle];
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
        [_nextButton setTitle:[JfgLanguage getLanTextStrByKey:self.addModel.ledState] forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"add_btn_pressed"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"add_btn"] forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

-(UIButton *)declareBtn
{
    if (!_declareBtn) {
        _declareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _declareBtn.frame = CGRectMake(self.view.width-15-25, 40, 25, 25);
        [_declareBtn setImage:[UIImage imageNamed:@"icon_explain_gray"] forState:UIControlStateNormal];
        [_declareBtn addTarget:self action:@selector(intoVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _declareBtn;
}

-(void)intoVC
{
    PilotLampStateVC *lampVC = [PilotLampStateVC new];
    [self presentViewController:lampVC animated:YES completion:nil];
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

-(OLImageView *)olImageView{
    if (!_olImageView) {
        CGFloat widgetX = self.view.center.x;
        CGFloat widgetY = self.bottomTipLabel.bottom + 50 * designHscale;
        _olImageView = [[OLImageView alloc]initWithFrame:CGRectMake(widgetX, widgetY, self.view.width, self.view.width)];
        _olImageView.backgroundColor = [UIColor clearColor];
        UIImage *image = nil;
        if (self.addModel && self.addModel.gifName && self.addModel.gifName.length>3) {
            image = [OLImage imageNamed:self.addModel.gifName];
            if (!image) {
                image =[UIImage imageNamed:self.addModel.gifName];
            }
        }else{
            image = [OLImage imageNamed:@"ruishiyindao.gif"];
        }
        
        CGFloat scale = image.size.height/image.size.width;
        CGFloat imageVcHeight = self.view.width*scale;
        _olImageView.height = imageVcHeight;
        [_olImageView setImage:image];
        _olImageView.x = self.view.x;
        _olImageView.y = (self.nextButton.top - self.bottomTipLabel.bottom)*0.5+self.bottomTipLabel.bottom;
        
    }
    return _olImageView;
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
                if (![self.navigationController popToViewController:temp animated:YES]) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                return;
            }
        }
        
        if (!isPop) {
            if (![self.navigationController popViewControllerAnimated:YES]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
    }else{
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)nextButtonAction:(UIButton *)sender
{
    if (self.pType == productType_wired) {
        
        ConfigWiredViewController *config = [ConfigWiredViewController new];
         [self.navigationController pushViewController:config animated:YES];
        
    }else{
        
        if (self && self.delegate && [self.delegate respondsToSelector:@selector(addDeviceGuideVCNectActionForVC:)]) {
            [self.delegate addDeviceGuideVCNectActionForVC:self];
            return;
        }
        ConnDeviceViewController *conn = [[ConnDeviceViewController alloc] init];
        conn.pType = self.pType;
        conn.cidStr =self.cid;
        conn.configType = self.configType;
        [self.navigationController pushViewController:conn animated:YES];
        
    }
    
    
    
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
