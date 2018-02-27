//
//  ConfigWiredViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/28.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ConfigWiredViewController.h"
#import "DelButton.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"
#import "FLGlobal.h"
#import "WifiListView.h"
#import "BindDevProgressViewController.h"
#import "UIAlertView+FLExtension.h"
#import <JFGSDK/JFGSDK.h>
#import "JFGDevTypeManager.h"
#import "JFGBoundDevicesMsg.h"

#define kScreen_Scale [UIScreen mainScreen].bounds.size.width/375.0f
#define kTop 100*kScreen_Scale
#define kLeft 20*kScreen_Scale
#define kLineWidth Kwidth-40*kScreen_Scale

@interface ConfigWiredViewController ()<UITextFieldDelegate,JFGSDKBindDeviceDelegate,JFGSDKCallbackDelegate>
{
    JFGSDKUDPResposeFping *didSelectedWifiRespose;
}
@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)UITextField * wifiNameTF;
@property(nonatomic, strong)UILabel * lineLabel_top;
@property(nonatomic, strong)UIButton * nextButton;
@property(nonatomic, strong)UIButton *wifiListButton;
@property(nonatomic, strong)DelButton *exitBtn;
@property(nonatomic, strong)UIButton *declareBtn;
@property(nonatomic, copy)NSString *ipAddress;
@property(nonatomic, copy)NSString *macStr;
@property (nonatomic, strong)JFGSDKBindingDevice *bindDeviceSDK;
@property (nonatomic, strong) NSMutableArray <NSString *>*bindedDevList;

@end

@implementation ConfigWiredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.wifiNameTF];
    [self.view addSubview:self.lineLabel_top];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.wifiListButton];
    [self.view insertSubview:self.wifiListButton aboveSubview:self.wifiNameTF];
    self.nextButton.enabled = NO;
    
    [JFGSDK addDelegate:self];
    //fping获取设备信息
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    // Do any additional setup after loading the view.
}

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([JFGDevTypeManager devIsType:JFGDevFctTypeWired forPid:ask.os]) {
        
        BOOL isExist = NO;
        //屏蔽已绑定设备
        for (NSString *bindedCid in self.bindedDevList) {
            if ([bindedCid isEqualToString:ask.cid]) {
                isExist = YES;
                break;
            }
        }
        
        if ([self.wifiNameTF.text isEqualToString:@""] && !isExist) {
            self.wifiNameTF.text = ask.cid;
            didSelectedWifiRespose = ask;
            self.nextButton.enabled = YES;
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [super viewDidDisappear:animated];
}

-(void)exitAction
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_tips"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
    
    __weak typeof(self) weakSelf = self;
    
    [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
        
        if (buttonIndex == 0) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    } otherDelegate:nil];
    
    
}

-(void)nextButtonAction:(UIButton *)sender
{
    if (didSelectedWifiRespose) {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *addr = [infoDictionary objectForKey:@"Jfgsdk_host"];
        if (!addr || [addr isEqualToString:@""]) {
            addr = @"yun.jfgou.com";
        }
        
        NSString *post = [infoDictionary objectForKey:@"Jfgsdk_post"];
        if (!post || [post isEqualToString:@""]) {
            post = @"443";
        }
        //NSString *serverAdd = [NSString stringWithFormat:@"%@:%@",addr,post];
        NSString *jfgServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"_jfg_changedDomain_"];
        if (jfgServer && [jfgServer isKindOfClass:[NSString class]] && ![jfgServer isEqualToString:@""]) {
            
            NSRange rang = [jfgServer rangeOfString:@":"];
            if (rang.location != NSNotFound) {
                
                NSString *server = [jfgServer substringToIndex:rang.location];
                NSString *pt = [jfgServer substringFromIndex:rang.location+1];
                addr = server;
                post = pt;
            }
        }
        [self.bindDeviceSDK setDev:didSelectedWifiRespose.cid devIp:didSelectedWifiRespose.address devMac:didSelectedWifiRespose.mac serverAddr:addr serverPost:[post intValue]];
        
        BindDevProgressViewController *bindDevice = [BindDevProgressViewController new];
        bindDevice.pType = productType_wired;
        bindDevice.cid = didSelectedWifiRespose.cid;
        bindDevice.macAddr = didSelectedWifiRespose.mac;
        bindDevice.wifiName = @"";
        bindDevice.wifiPassWord = @"";
        [self.navigationController pushViewController:bindDevice animated:YES];
        
    }
}

-(void)getWiFiListAciton:(UIButton *)button
{
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    [WifiListView createWifiListViewForType:WifiListTypeCid commplete:^(id obj) {

        if ([obj isKindOfClass:[JFGSDKUDPResposeFping class]]) {
            JFGSDKUDPResposeFping *wifi = obj;
            weakSelf.wifiNameTF.text = wifi.cid;
            didSelectedWifiRespose = wifi;
            weakSelf.nextButton.enabled = YES;
        }
       
    }];
    
    
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 104, self.view.width, 27*kScreen_Scale)];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-regular" size:27*kScreen_Scale];
        _titleLabel.font = [UIFont systemFontOfSize:27*kScreen_Scale];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.text = [JfgLanguage getLanTextStrByKey:@"WIRED_SELECT_DEVICE_CID"];
    }
    return _titleLabel;
    
}
-(UITextField *)wifiNameTF{
    if (!_wifiNameTF) {
        
        _wifiNameTF = [self creatTextField];
        _wifiNameTF.userInteractionEnabled = NO;
        _wifiNameTF.frame = CGRectMake(kLeft+35, 202, kLineWidth-70, 16);
        _wifiNameTF.placeholder = [JfgLanguage getLanTextStrByKey:@"WIRED_SELECT_DEVICE_CID_TIPS"];
        _wifiNameTF.delegate = self;
        _wifiNameTF.returnKeyType = UIReturnKeyDone;
        _wifiNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        
    }
    return _wifiNameTF;
}

-(UILabel *)lineLabel_top
{
    if (!_lineLabel_top) {
        _lineLabel_top = [self creatLineLabel];
        _lineLabel_top.frame = CGRectMake(kLeft, self.wifiNameTF.bottom+13, kLineWidth, 1);
    }
    return _lineLabel_top;
}

-(UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(0, 277, 360*0.5, 44);
        _nextButton.layer.masksToBounds = YES;
        _nextButton.x = self.view.x;
        _nextButton.layer.cornerRadius = 22;
        _nextButton.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _nextButton.layer.borderWidth = 1;
        [_nextButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor colorWithHexString:@"#cecece"] forState:UIControlStateDisabled];
        [_nextButton setTitle:[JfgLanguage getLanTextStrByKey:@"NEXT"] forState:UIControlStateNormal];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
-(UIButton *)wifiListButton{
    if (!_wifiListButton) {
        _wifiListButton= [UIButton buttonWithType:UIButtonTypeCustom];
        _wifiListButton.frame = CGRectMake(self.lineLabel_top.right-35, self.lineLabel_top.bottom-2-35, 35, 35);
        [_wifiListButton setBackgroundColor:[UIColor clearColor]];
        [_wifiListButton setImage:[UIImage imageNamed:@"add_btn_wifiList"] forState:UIControlStateNormal];
        [_wifiListButton addTarget:self action:@selector(getWiFiListAciton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wifiListButton;
}
-(DelButton *)exitBtn
{
    if (!_exitBtn) {
        _exitBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10, 37, 10, 18);
        [_exitBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

-(UITextField *)creatTextField
{
    UITextField * textField = [[UITextField alloc]init];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:16*kScreen_Scale];
    textField.textColor = [UIColor colorWithHexString:@"#666666"];
    [textField setValue:[UIColor colorWithHexString:@"#cecece"] forKeyPath:@"_placeholderLabel.textColor"];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    return textField;
}

-(UILabel *)creatLineLabel
{
    UILabel * lineLabel = [[UILabel alloc]init];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#cecece"];
    return lineLabel;
}

- (JFGSDKBindingDevice *)bindDeviceSDK
{
    if (_bindDeviceSDK == nil)
    {
        _bindDeviceSDK = [[JFGSDKBindingDevice alloc] init];
        //_bindDeviceSDK.delegate = self;
    }
    return _bindDeviceSDK;
}

-(NSMutableArray *)bindedDevList
{
    if (!_bindedDevList) {
        _bindedDevList = [NSMutableArray new];
        NSMutableArray *devModels = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
        for (JiafeigouDevStatuModel *model in devModels) {
            [_bindedDevList addObject:model.uuid];
        }
    }
    return _bindedDevList;
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
