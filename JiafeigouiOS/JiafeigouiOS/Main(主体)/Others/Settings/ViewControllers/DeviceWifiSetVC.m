//
//  DeviceWifiSetVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceWifiSetVC.h"
#import "SetDeviceNameVC.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDKBindingDevice.h>
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKBindDeviceDelegate.h>
#import "ProgressHUD.h"
#import "JfgTableViewCellKey.h"


@interface DeviceWifiSetVC ()<JFGSDKBindDeviceDelegate, JFGSDKCallbackDelegate>

@property (strong, nonatomic) DeviceWifiTableView *deviceWifiTableview;

@property (nonatomic, copy) NSString *ssid;

@end

@implementation DeviceWifiSetVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    
    [JFGSDK addDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SELECT_NETWORK"];
}

- (void)initView
{
    [self.view addSubview:self.deviceWifiTableview];
}

- (void)initViewLayout
{
    [self.deviceWifiTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

#pragma mark data


#pragma mark getter
- (DeviceWifiTableView *)deviceWifiTableview
{
    if (_deviceWifiTableview == nil)
    {
        _deviceWifiTableview = [[DeviceWifiTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _deviceWifiTableview.deviceWifiDelegate = self;
        _deviceWifiTableview.selectedWifi = self.dogWifi;
        _deviceWifiTableview.cid = self.cid;
    }
    
    return _deviceWifiTableview;
}


#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark delegate
- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo
{
    if (![[dataInfo objectForKey:isLocked] boolValue]) // 未加密，直接发送配置
    {
        self.ssid = [dataInfo objectForKey:cellTextKey];
        [JFGSDK fping:@"255.255.255.255"];
        [ProgressHUD showProgress:nil];
    }
    else
    {
        SetDeviceNameVC *setWifiPass = [[SetDeviceNameVC alloc] init];
        setWifiPass.deviceNameVCType = DeviceNameVCTypeWifiPassword;
        setWifiPass.wifiName = [dataInfo objectForKey:cellTextKey];
        setWifiPass.cid = self.cid;
        [self.navigationController pushViewController:setWifiPass animated:YES];
    }
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if (ask != nil)
    {
        if ([ask.cid isEqualToString:self.cid] && self.ssid != nil)
        {
            [JFGSDK wifiSetWithSSid:self.ssid keyword:@"" cid:ask.cid ipAddr:ask.address mac:ask.mac];
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DOOR_SET_WIFI_MSG"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
