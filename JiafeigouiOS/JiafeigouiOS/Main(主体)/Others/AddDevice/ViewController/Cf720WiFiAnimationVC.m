//
//  Cf720WiFiAnimationVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Cf720WiFiAnimationVC.h"
#import "JfgGlobal.h"
#import "FLGlobal.h"
#import <Masonry.h>
#import "OLImageView.h"
#import "OLImage.h"
#import "CommonMethod.h"
#import "DelButton.h"
#import "ConfigWiFiViewController.h"
#import "BindDevProgressViewController.h"
#import "WifiModeFor720CFResultVC.h"
#import "OemManager.h"
#import "PilotLampStateVC.h"

#define SCREEN_SIZE   [[UIScreen mainScreen] bounds].size
#define DEVICE_IPHONE4S CGSizeEqualToSize(CGSizeMake(320, 480), SCREEN_SIZE)
#define kScreen_Scale  (DEVICE_IPHONE4S==YES ? [UIScreen mainScreen].bounds.size.height/667.0 : [UIScreen mainScreen].bounds.size.width/375.0)
#define kLeft (Kwidth-270.0*kScreen_Scale)/2
#define kTop 100.0*kScreen_Scale
#define Width 270*kScreen_Scale

@interface Cf720WiFiAnimationVC ()
{
    BOOL isGotoConfigWifiVC;
}
@property(nonatomic, strong)UIImageView * circle1;
@property(nonatomic, strong)UILabel * label1;
@property(nonatomic, strong)UIImageView * circle2;
@property(nonatomic, strong)UILabel * label2;
@property(nonatomic, strong)OLImageView * olImageView;
@property(nonatomic, strong)UILabel * lineLabel_bottom;
@property(nonatomic, strong)UIButton * goToSettingButton;
@property(nonatomic, strong)DelButton * exitBtn;
@property(nonatomic, strong)UIButton *declareBtn;

@end

@implementation Cf720WiFiAnimationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.circle1];
    [self.view addSubview:self.label1];
    [self.view addSubview:self.circle2];
    [self.view addSubview:self.label2];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.goToSettingButton];
    [self.view addSubview:self.lineLabel_bottom];
    [self.view addSubview:self.olImageView];
    [self.view addSubview:self.declareBtn];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isGotoConfigWifiVC = NO;
    [self connectedAP];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(BOOL)connectedAP
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.cidStr];
    if (isAP) {
        
        if (!isGotoConfigWifiVC) {
            if (self.eventType == EventTypeOpenAPModel) {
                
                WifiModeFor720CFResultVC *resultVC = [WifiModeFor720CFResultVC new];
                resultVC.isAPModeFinished = YES;
                [self.navigationController pushViewController:resultVC animated:YES];
                
            }else if (self.eventType == EventTypeConfigWifi){
                
                ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
                configWifi.cid = self.cidStr;
                configWifi.pType = productType_720;
                configWifi.configType = configWifiType_resetWifi;
                configWifi.isCamare = YES;
                [self.navigationController pushViewController:configWifi animated:YES];
                
            }else if(self.eventType == EventTypeHotSpot){
                
                ConfigWiFiViewController *configWifi = [ConfigWiFiViewController new];
                configWifi.cid = self.cidStr;
                configWifi.pType = productType_720;
                configWifi.configType = configWifiType_setHotspot;
                configWifi.isCamare = NO;
                [self.navigationController pushViewController:configWifi animated:YES];
                
            }
            
            isGotoConfigWifiVC = YES;
        }
        
        
    }
    return isAP;
}

-(void)becomeActive:(NSNotification *)notification
{
    [self connectedAP];
}

-(void)gotoSettingButtonAction
{
//    WifiModeFor720CFResultVC *resultVC = [WifiModeFor720CFResultVC new];
//    resultVC.isAPModeFinished = YES;
//    [self.navigationController pushViewController:resultVC animated:YES];
    if (![self connectedAP]) {
        
        if (IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(10.0)) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=WIFI"] options:@{} completionHandler:nil];
            
        } else {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }
        
    }
}

-(void)exitAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
        _olImageView = [[OLImageView alloc]initWithFrame:CGRectMake(kLeft, self.label2.bottom+30*kScreen_Scale, 750*0.5*kScreen_Scale, 704*0.5*kScreen_Scale)];
        if ([OemManager oemType] == oemTypeDoby) {
             [_olImageView setImage:[OLImage imageNamed:[JfgLanguage getLanPicNameWithPicName:@"doby"]]];
            
        }else{
            if (self.eventType == EventTypeOpenAPModel) {
                //460 × 700
                [_olImageView setImage:[OLImage imageNamed:[JfgLanguage getLanPicNameWithPicName:@"zhilian"]]];
                _olImageView.size =CGSizeMake(460*0.5*kScreen_Scale, 700*0.5*kScreen_Scale);
            }else{
               [_olImageView setImage:[OLImage imageNamed:[JfgLanguage getLanPicNameWithPicName:@"connDevice"]]];
            }
            
        }
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
