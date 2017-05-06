//
//  ConfigWiFiViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ConfigWiFiViewController.h"
#import "FLGlobal.h"
#import "DelButton.h"
#import "WifiListView.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "BindDevProgressViewController.h"
#import "JfgUserDefaultKey.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDK.h>
#import "AddDeviceMainViewController.h"
#import <KVOController.h>
#import "DeviceSettingVC.h"
#import "UIAlertView+FLExtension.h"
#import "ProgressHUD.h"
#import "SetWifiLoadingFor720VC.h"
#import "CommonMethod.h"
#import "PilotLampStateVC.h"

#define kScreen_Scale [UIScreen mainScreen].bounds.size.width/375.0f
#define kTop 100*kScreen_Scale
#define kLeft 20*kScreen_Scale
#define kLineWidth Kwidth-40*kScreen_Scale

@interface ConfigWiFiViewController ()<UITextFieldDelegate,JFGSDKCallbackDelegate,UIAlertViewDelegate>
@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)UITextField * wifiNameTF;
@property(nonatomic, strong)UILabel * lineLabel_top;
@property(nonatomic, strong)UITextField * wifiPasswordTF;
@property(nonatomic, strong)UILabel * lineLabel_bottom;
@property(nonatomic, strong)UILabel * tipLabel;
@property(nonatomic, strong)UIButton * nextButton;
@property(nonatomic, strong)UIButton *wifiListButton;
@property(nonatomic, strong)DelButton *exitBtn;
@property(nonatomic, strong)UIButton *declareBtn;


@property (nonatomic, copy) NSString *ipAddress;
@property (nonatomic, copy) NSString *macStr;

@end

@implementation ConfigWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.titleLabel];
    
    [self.view addSubview:self.wifiNameTF];

    [self.view addSubview:self.lineLabel_top];
    
    [self.view addSubview:self.wifiPasswordTF];
//
    [self.view addSubview:self.lineLabel_bottom];
    
    [self.view addSubview:self.tipLabel];
    
    [self.view addSubview:self.nextButton];
    
    [self.view addSubview:[self pwTextFieldRightView]];
    if (self.pType == productType_720) {
        [self.view addSubview:self.declareBtn];
    }
    
    if ([self.cid isKindOfClass:[NSString class]] && self.cid.length >1 && ( [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"50"] ||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"51"] ||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"65"]||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"60"]||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"66"]||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"67"]||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"69"]||
        [[self.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"68"] )) {
        
        self.isCamare = YES;
        
    }
    
    if (self.isCamare) {
        [self.view addSubview:self.wifiListButton];
        [self.view insertSubview:self.wifiListButton aboveSubview:self.wifiNameTF];
    }
    
    [self.view addSubview:self.exitBtn];
    [JFGSDK addDelegate:self];
    //fping获取设备信息
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
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

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    self.cid = ask.cid;
    self.macStr = ask.mac;
    self.ipAddress = ask.address;
    //65开头设备不显示获取wifi列表按钮（FreeCam）
    if (ask.cid && [[ask.cid substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"65"]) {
        
        [self.wifiListButton removeFromSuperview];
        [JFGSDK removeDelegate:self];
        
    }
}

#pragma mark - 按钮事件
-(void)nextButtonAction:(UIButton *)button
{
    // 公共判断区域
    //断开了ap连接
    if (![CommonMethod isConnecttedDeviceWifiWithPid:self.pType]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Item_ConnectionFail"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            [self intoAddDevGuideVC];
            
        } otherDelegate:nil];
        return;
    }
    
    
    
//    if (self.wifiNameTF.left == 0) {
//        
//        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ENTER_WIFI"]];
//        return;
//    }
    
    // 分开 处理
    
    switch (self.configType)
    {
        case configWifiType_configWifi:
        {
            
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"wifiName:%@  wifiPasword:%@",self.wifiNameTF.text,self.wifiPasswordTF.text]];
            [JFGSDK wifiSetWithSSid:self.wifiNameTF.text keyword:self.wifiPasswordTF.text cid:self.cid ipAddr:@"255.255.255.255" mac:@""];
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DOOR_SET_WIFI_MSG"]];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case configWifiType_default:
        {
            
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"wifiName:%@  wifiPasword:%@",self.wifiNameTF.text,self.wifiPasswordTF.text]];
            BindDevProgressViewController *bindDevice = [BindDevProgressViewController new];
            bindDevice.pType = self.pType;
            bindDevice.cid = self.cid;
            bindDevice.wifiName = self.wifiNameTF.text;
            bindDevice.wifiPassWord = self.wifiPasswordTF.text;
            [self.navigationController pushViewController:bindDevice animated:YES];
            
        }
            break;
        case configWifiType_resetWifi:{
            
            SetWifiLoadingFor720VC *setwifi = [SetWifiLoadingFor720VC new];
            setwifi.wifiName = self.wifiNameTF.text;
            setwifi.wifiPassword = self.wifiPasswordTF.text;
            setwifi.cid = self.cid;
            [self.navigationController pushViewController:setwifi animated:YES];
        }
            break;
            
        default:
            
            break;
    }
    
    
    
}
-(void)getWiFiListAciton:(UIButton *)button{

    [self.view endEditing:YES];
    [WifiListView createWifiListView:^(NSString *wifiNameString) {
        self.wifiNameTF.text = wifiNameString;
    }];
}

-(void)exitAction
{
    //弹框逻辑处理
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_tips"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
    alert.tag = 10245;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 10245 && buttonIndex == 0) {
        [self intoAddDevGuideVC];
        
    }
}

-(void)intoAddDevGuideVC
{
    switch (self.configType)
    {
        case configWifiType_configWifi:
        {
            for (UIViewController *temp in self.navigationController.viewControllers)
            {
                if ([temp isKindOfClass:[DeviceSettingVC class]]  )
                {
                    [self.navigationController popToViewController:temp animated:YES];
                }
            }
        }
            break;
        case configWifiType_default:
        default:
        {
            for (UIViewController *temp in self.navigationController.viewControllers)
            {
                if ([temp isKindOfClass:[AddDeviceMainViewController class]]   || [temp isKindOfClass:[DeviceSettingVC class]])
                {
                    [self.navigationController popToViewController:temp animated:YES];
                }
               
            }
        }
            break;
    }
    
}

#pragma  mark - UITouch
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
#pragma mark - 控件
-(UILabel *)titleLabel{
    if (!_tipLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kTop, Kwidth, 27*kScreen_Scale)];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-regular" size:27*kScreen_Scale];
        _titleLabel.font = [UIFont systemFontOfSize:27*kScreen_Scale];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_WifiConfTips"];
    }
    return _titleLabel;
}
-(UITextField *)wifiNameTF{
    if (!_wifiNameTF) {
        _wifiNameTF = [self creatTextField];
        _wifiNameTF.frame = CGRectMake(kLeft+35, self.titleLabel.bottom+76*kScreen_Scale, kLineWidth-70, 16);
        _wifiNameTF.placeholder = [JfgLanguage getLanTextStrByKey:@"ENTER_WIFI"];
        NSString *availabelwifi = [[NSUserDefaults standardUserDefaults] objectForKey:availableWIFI];
        if ([availabelwifi hasPrefix:@"DOG"] || [availabelwifi hasPrefix:@"dog"]) {
            availabelwifi = @"";
        }
        _wifiNameTF.text = availabelwifi;
        _wifiNameTF.delegate = self;
        _wifiNameTF.returnKeyType = UIReturnKeyNext;
        _wifiNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.KVOController observe:_wifiNameTF keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
           
            
        }];
    }
    return _wifiNameTF;
}
-(UITextField *)wifiPasswordTF
{
    if (!_wifiPasswordTF) {
        _wifiPasswordTF = [self creatTextField];
        _wifiPasswordTF.frame = CGRectMake(kLeft+35, self.lineLabel_top.bottom+41*kScreen_Scale, kLineWidth-70, 16);
        _wifiPasswordTF.placeholder = [JfgLanguage getLanTextStrByKey:@"ENTER_WIFI_PWD"];
        _wifiPasswordTF.secureTextEntry = YES;
        _wifiPasswordTF.delegate = self;
        _wifiPasswordTF.keyboardType = UIKeyboardTypeEmailAddress;
        _wifiPasswordTF.returnKeyType = UIReturnKeyDone;
        _wifiPasswordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _wifiPasswordTF.rightViewMode = UITextFieldViewModeAlways;
        [self.KVOController observe:_wifiPasswordTF keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            if (_wifiPasswordTF.text.length>60) {
                
               
            }

        }];
    }
    return _wifiPasswordTF;
}
-(UILabel *)lineLabel_top
{
    if (!_lineLabel_top) {
        _lineLabel_top = [self creatLineLabel];
        _lineLabel_top.frame = CGRectMake(kLeft, self.wifiNameTF.bottom+13*kScreen_Scale, kLineWidth, 0.5);
    }
    return _lineLabel_top;
}
-(UILabel *)lineLabel_bottom{
    if (!_lineLabel_bottom) {
        _lineLabel_bottom = [self creatLineLabel];
        _lineLabel_bottom.frame = CGRectMake(kLeft, self.wifiPasswordTF.bottom+13*kScreen_Scale, kLineWidth, 0.5);
    }
    return _lineLabel_bottom;
}
-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.lineLabel_bottom.bottom+15*kScreen_Scale, Kwidth, 13*kScreen_Scale)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:13*kScreen_Scale];
        _tipLabel.font = [UIFont systemFontOfSize:13*kScreen_Scale];
        _tipLabel.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
        _tipLabel.text = [JfgLanguage getLanTextStrByKey:@"WIFI_SET_5GTIPS"];
    }
    return _tipLabel;
}
-(UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(0, self.tipLabel.bottom+40*kScreen_Scale, 360*0.5, 44);
        _nextButton.layer.masksToBounds = YES;
        _nextButton.x = self.view.x;
        _nextButton.layer.cornerRadius = 22;
        _nextButton.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _nextButton.layer.borderWidth = 1;
        [_nextButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
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
-(UILabel *)creatLineLabel{
    UILabel * lineLabel = [[UILabel alloc]init];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#cecece"];
    return lineLabel;
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
    [textField addTarget:self action:@selector(textFieldValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    return textField;
}

//创建密码输入框右边控件
-(UIView *)pwTextFieldRightView
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(self.wifiPasswordTF.right, self.wifiPasswordTF.top-10, 35, 35)];
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lockBtn.frame = CGRectMake(0, 0, 35, 35);
    [lockBtn setImage:[UIImage imageNamed:@"lock_btn_noshow password"] forState:UIControlStateNormal];
    [lockBtn setImage:[UIImage imageNamed:@"lock_btn_show password"] forState:UIControlStateSelected];
    lockBtn.adjustsImageWhenHighlighted = NO;
    [lockBtn addTarget:self action:@selector(lockPwAction:) forControlEvents:UIControlEventTouchUpInside];
    lockBtn.selected = NO;
    [bgView addSubview:lockBtn];
    
    return bgView;
}

//密码明文密文切换
-(void)lockPwAction:(UIButton *)sender
{
    NSString *text = self.wifiPasswordTF.text;
    if (sender.selected) {
        self.wifiPasswordTF.secureTextEntry = YES;
        sender.selected  = NO;
    }else{
        self.wifiPasswordTF.secureTextEntry = NO;
        self.wifiPasswordTF.keyboardType = UIKeyboardTypeASCIICapable;
        sender.selected  = YES;
    }
    self.wifiPasswordTF.text = text;
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
    [self.navigationController pushViewController:lampVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextfieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * maxLString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.wifiNameTF) {
        if (maxLString.length > 31) {
            return NO;
        }
    }else{
        if (maxLString.length > 63) {
            return NO;
        }
    }
   
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _wifiNameTF) {
        [textField resignFirstResponder];
        [_wifiPasswordTF becomeFirstResponder];
    }else if (textField == _wifiPasswordTF){
        [textField resignFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldValueChanged:(UITextField *)textField
{
//    NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
//    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入，包括简体拼音，健体五笔，简体手写
//        UITextRange *selectedRange = [textField markedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position) {
//            if (textField.text.length >63) {
//                textField.text = [textField.text substringToIndex:63];
//            }
//        }
//        //有高亮选择的字符串，则暂不对文字进行统计和限制
//        else{
//            
//        }
//    }
//    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//    else{
//        if (textField.text.length >63) {
//            textField.text = [textField.text substringToIndex:63];
//        }
//    }
    
    
}


@end
