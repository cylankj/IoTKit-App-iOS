//
//  SetDeviceNameVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SetDeviceNameVC.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import "NSString+FLExtension.h"
#import "ProgressHUD.h"
#import "LoginManager.h"
#import "LSAlertView.h"
#import "JiafeigouRootViewController.h"
#import "JfgConstKey.h"
#import "JfgConfig.h"
#import "AddFriendsVC.h"
#import "CommonMethod.h"
#import "SetPwForOpenLoginViewController.h"
#import "CheckingEmailViewController.h"

@interface SetDeviceNameVC ()<JFGSDKCallbackDelegate,UITextFieldDelegate>
{
    
    NSString *textString;
}
/**
 *  背景 view
 */
@property (strong, nonatomic) UIView *bgView;

/**
 *  设备名字 textField
 */
@property (strong, nonatomic) UITextField *deviceNameTextFiled;
/**
 *  XX 按钮
 */

//@property (strong, nonatomic) UIButton *clearButton;

@end

@implementation SetDeviceNameVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [JFGSDK removeDelegate:self];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark view
- (void)initNavigation
{
    NSString *titleStr = @"";
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
   
    self.rightButton.hidden = NO;

    if (self.deviceNameVCType == DeviceNameVCTypeNickName) {
        if ([self.jfgAccount.alias isEqualToString:@""]) {
            
        }
    }else if (self.deviceNameVCType == DeviceNameVCTypeFriendsRemarkName){
        [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"FINISHED"] forState:UIControlStateNormal];
        
    }
    
    
    if (self.deviceNameVCType == DeviceNameVCTypeSetHelloWorld || self.deviceNameVCType == DeviceNameVCTypeWifiPassword) {
        self.rightButton.enabled = YES;
    }else{
        self.rightButton.enabled = NO;
    }
    
    
    switch (self.deviceNameVCType)
    {
        case DeviceNameVCTypeSelf:
            titleStr = [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"];
            break;
        case DeviceNameVCTypeWifiPassword:
            titleStr = [JfgLanguage getLanTextStrByKey:@"ENTER_PWD_1"];
            break;
        case DeviceNameVCTypeFriendsRemarkName:
            titleStr = [JfgLanguage getLanTextStrByKey:@"Tap3_Friends_UserInfo_ModName"];
            break;
        case DeviceNameVCTypeNickName:
            titleStr = [JfgLanguage getLanTextStrByKey:@"ALIAS"];
            break;
        case DeviceNameVCTypeBindEmail:
            titleStr = [JfgLanguage getLanTextStrByKey:@"Tap0_BindEmail"];
            break;
        case DeviceNameVCTypeBindPhone:
            titleStr = [JfgLanguage getLanTextStrByKey:@"Tap0_BindPhoneNo"];
            break;
        case DeviceNameVCTypeChangeEmail:
            titleStr = [JfgLanguage getLanTextStrByKey:@"CHANGE_EMAIL"];
            break;
        case DeviceNameVCTypeChangePhone:
            titleStr = [JfgLanguage getLanTextStrByKey:@"CHANGE_PHONE_NUM"];
            break;
        case DeviceNameVCTypePassword:
            titleStr = [JfgLanguage getLanTextStrByKey:@"SET_PWD"];
            break;
        case DeviceNameVCTypeEmailPassword:
            titleStr = [JfgLanguage getLanTextStrByKey:@"SET_PWD"];
            break;
        case DeviceNameVCTypePhonePassword:
            titleStr = [JfgLanguage getLanTextStrByKey:@"SET_PWD"];
            break;
        case DeviceNameVCTypeSetHelloWorld:
            titleStr = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd"];
            break;
        default:
            break;
    }
    self.titleLabel.text = titleStr;
}

- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.deviceNameTextFiled];
    
    if (self.deviceNameVCType == DeviceNameVCTypeNickName) {
        
        self.deviceNameTextFiled.text = self.jfgAccount.alias;
        self.deviceName = self.jfgAccount.alias;
        
    }else if (self.deviceNameVCType == DeviceNameVCTypeChangeEmail){
        
        self.deviceNameTextFiled.text = self.jfgAccount.email;
        self.deviceName = self.jfgAccount.email;
        
    }else if (self.deviceNameVCType == DeviceNameVCTypeFriendsRemarkName ||  self.deviceNameVCType == DeviceNameVCTypeSetHelloWorld){
        
        self.deviceNameTextFiled.text = self.deviceName;
    }
}

- (void)initViewLayout
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0+20.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@44);
    }];
    
    [self.deviceNameTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView.mas_centerY);
        make.left.equalTo(self.bgView).with.offset(15.0f);
        make.right.equalTo(self.bgView).with.offset(-5);
    }];
}

#pragma mark- TextFiled Delegate
int maxLength = 12;
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //note：键盘智能输入不会触发此代理方法，这是一个bug吗
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //不能输入空字符
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    //禁止输入表情
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    
    //好友昵称，设备昵称，自己昵称字符不能超过12个
    if (self.deviceNameVCType == DeviceNameVCTypeNickName || self.deviceNameVCType == DeviceNameVCTypeFriendsRemarkName || self.deviceNameVCType == DeviceNameVCTypeSelf)
    {
        
        if (textField.markedTextRange == nil && textField.text.length > maxLength)
        {
            return NO;
        }
       
    }
    
    if (self.deviceNameVCType == DeviceNameVCTypeBindEmail || self.deviceNameVCType == DeviceNameVCTypeChangeEmail) {
        if (str.length>65) {
            return  NO;
            
        }
    }
    
    if (self.deviceNameVCType == DeviceNameVCTypeSetHelloWorld) {
        if (str.length>20) {
            return  NO;
            
        }
    }
    
    return YES;
}

-(void)textFieldValueChanged:(UITextField *)textField
{
    
    if ([textField.text isEqualToString:@""])
    {
        self.rightButton.enabled = NO;
        if (self.deviceNameVCType == DeviceNameVCTypeSetHelloWorld || self.deviceNameVCType == DeviceNameVCTypeWifiPassword) {
            self.rightButton.enabled = YES;
        }
        return;
    }else{
        self.rightButton.enabled = YES;
    }
    
   
    
    if (self.deviceNameVCType == DeviceNameVCTypeNickName || self.deviceNameVCType == DeviceNameVCTypeFriendsRemarkName || self.deviceNameVCType == DeviceNameVCTypeSelf) {
        
        if ([self.deviceName isEqualToString:textField.text] || [textField.text isEqualToString:@""]) {
            self.rightButton.enabled = NO;
        }else{
            self.rightButton.enabled = YES;
        }
        
     //   NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
//        if ([lang hasPrefix:@"zh-Hans"]) {// 简体中文输入，包括简体拼音，健体五笔，简体手写
//                    }
//        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//        else{
//            if (textField.text.length >= maxLength) {
//                textField.text = [textField.text substringToIndex:maxLength];
//            }
//        }
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (textField.text.length >= maxLength) {
                textField.text = [textField.text substringToIndex:maxLength];
            }
        }
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }

        
    }
    
    
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.deviceNameVCType != DeviceNameVCTypeWifiPassword && self.deviceNameVCType != DeviceNameVCTypeSetHelloWorld) {
        self.rightButton.enabled = NO;
    }
    //
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
}

#pragma mark getter
- (UIView *)bgView
{
    if (_bgView == nil)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        [_bgView.layer setBorderColor:[UIColor colorWithHexString:@"#e8e8e8"].CGColor];
        [_bgView.layer setBorderWidth:.5f];
        [_bgView.layer setFrame:CGRectMake(0.0f, 43.0, Kwidth, 1.0f)];
        
    }
    return _bgView;
}

- (UITextField *)deviceNameTextFiled
{
    if (_deviceNameTextFiled == nil)
    {
        _deviceNameTextFiled = [[UITextField alloc] init];
        _deviceNameTextFiled.text = self.deviceName;
        _deviceNameTextFiled.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _deviceNameTextFiled.delegate = self;
        _deviceNameTextFiled.textColor = [UIColor colorWithHexString:@"#333333"];
        _deviceNameTextFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        [_deviceNameTextFiled setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _deviceNameTextFiled.clearButtonMode = UITextFieldViewModeAlways;
        [_deviceNameTextFiled addTarget:self action:@selector(textFieldValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    }
    
    return _deviceNameTextFiled;
}

//- (UIButton *)clearButton
//{
//    if (_clearButton == nil)
//    {
//        _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_clearButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    }
//    return _clearButton;
//}


#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    [super leftButtonAction:sender];
}

- (void)rightButtonAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess)
    {
        
        [CommonMethod showNetDisconnectAlert];
        return;
        
    }
    
    if ([self.deviceNameTextFiled.text isEqualToString:@""] && self.deviceNameVCType == DeviceNameVCTypeWifiPassword)
    {
        return;
    }
    
    if ([self.deviceNameTextFiled.text isEqualToString:@""] && self.deviceNameVCType != DeviceNameVCTypeSetHelloWorld) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LOCATION_NAME_ERROR"]];
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [ProgressHUD dismiss];
            [self.deviceNameTextFiled becomeFirstResponder];
            
        });
        return;
    }
    switch (_deviceNameVCType) {
        case DeviceNameVCTypeWifiPassword:
        {
            NSString * keyString = self.deviceNameTextFiled.text;
            if(self.deviceNameTextFiled.text.length == 0 || self.deviceNameTextFiled.text == nil)
            {
                keyString = @"";
            }
            
            [JFGSDK wifiSetWithSSid:self.wifiName keyword:keyString cid:self.cid ipAddr:@"255.255.255.255" mac:@""];
            
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"DOOR_SET_WIFI_MSG"]];
            for (UIViewController * VC in self.navigationController.viewControllers) {
                if ([VC isKindOfClass:[JiafeigouRootViewController class]]) {
                    [self.navigationController popToViewController:VC animated:YES];
                }
            }
        }
            break;
        case DeviceNameVCTypeNickName:{
            if (_deviceNameTextFiled.text.length !=0) {
                [JFGSDK resetAccountEmail:nil orAlias:_deviceNameTextFiled.text];
            }
        }
            break;
        case DeviceNameVCTypeFriendsRemarkName:{
            if (_deviceNameTextFiled.text.length !=0) {
                [JFGSDK setRemarkName:_deviceNameTextFiled.text forFriendByAccount:self.account];
                [ProgressHUD showProgress:nil];
            }
        }
            break;
        case DeviceNameVCTypeSelf:
        {
            [_deviceNameTextFiled resignFirstResponder];
            textString = _deviceNameTextFiled.text;
            [JFGSDK setAlias:_deviceNameTextFiled.text forCid:self.cid];
            [ProgressHUD showProgress:nil];
        }
            break;
        case DeviceNameVCTypeBindEmail:{
            /*邮箱格式正确且未注册过，分情况判断：①通过第三方登录，未绑定手机号和邮箱时--点击确定跳转到【设置密码】页面
            ②通过手机号登录，未绑定邮箱时--点击确定弹出气泡提示“绑定成功”；2s后退出页面*/
            if (![_deviceNameTextFiled.text isEmail]) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
                return;
            }
            
            
            if (_deviceNameTextFiled.text.length > 0) {
                if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin) {
                    
                    [ProgressHUD showProgress:nil];
                    [JFGSDK resetAccountEmail:_deviceNameTextFiled.text orAlias:nil];
                    
                } else {
                    
                    [ProgressHUD showProgress:nil];
                    [JFGSDK resetAccountEmail:_deviceNameTextFiled.text orAlias:nil];
//                    JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
//                    if (([acc.phone isEqualToString:@""] || acc.phone == nil) && ([acc.email isEqualToString:@""] || acc.email == nil)) {
//                        SetPwForOpenLoginViewController *setPw = [[SetPwForOpenLoginViewController alloc]init];
//                        setPw.isPhoneNumber = NO;
//                        [self.navigationController pushViewController:setPw animated:YES];
//                    }else{
//                       
//                    }
                    
                    
                }
            } else {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
            }
        }
            break;

        case DeviceNameVCTypeChangeEmail:{
            //邮箱格式正确且未注册过，点击完成后弹出气泡提示“设置成功”；2S后跳转到【个人信息】页面，邮箱一栏，显示新绑定的邮箱地址
            
            if (![_deviceNameTextFiled.text isEmail]) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
                return;
            }
            
            if ([_deviceNameTextFiled.text isEqualToString:self.jfgAccount.email]) {
                
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_EEDITUSERINFO_EMAIL"]];
                return;
            }
            
            
            if (_deviceNameTextFiled.text.length > 0) {
                if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin) {
                    
                    [ProgressHUD showProgress:nil];
                    [JFGSDK resetAccountEmail:_deviceNameTextFiled.text orAlias:nil];
                    
                } else {
                    [ProgressHUD showProgress:nil];
                    [JFGSDK resetAccountEmail:_deviceNameTextFiled.text orAlias:nil];
                    
                    
                    
                }
            } else {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
            }
        }
            break;
        case DeviceNameVCTypeEmailPassword:{
            if (_deviceNameTextFiled.text.length>12 || _deviceNameTextFiled.text.length<6) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
            }else{
                
            }
        }
            break;
        case DeviceNameVCTypePhonePassword:{
            if (_deviceNameTextFiled.text.length>12 || _deviceNameTextFiled.text.length<6) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
            }else{
                
            }
        }
            
            break;
        case DeviceNameVCTypeSetHelloWorld:{
            
            [JFGSDK addFriendByAccount:self.cid additionTags:self.deviceNameTextFiled.text];
            [ProgressHUD showProgress:nil];
            
        }
            break;
            
        case DeviceNameVCTypeBindPhone:{
            
            if ([self.deviceNameTextFiled.text isMobileNumber]) {
                
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"]];
            }
            
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - JFGSDKCallBack
//好友请求
-(void)jfgResultIsRelatedToFriendWithType:(JFGFriendResultType)type error:(JFGErrorType)errorType {
    switch (type) {
        case JFGFriendResultTypeSetRemarkName: {
            if (errorType == 0) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SUBMIT_FAIL"]];
            }
        }
            
            break;
            
        case JFGFriendResultTypeAddFriend:{
            if (errorType == 0) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Contacts_InvitedTips"]];
                
                NSArray *vcs = self.navigationController.viewControllers;
                for (UIViewController *vc in vcs) {
                    if ([vc isKindOfClass:[AddFriendsVC class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return;
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [ProgressHUD showText:[CommonMethod languageKeyForAddFriendErrorType:errorType]];
            }
        }
            break;
            
        default:
            break;
    }
    
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        
    });
}


-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeUpdataAccount) {
        if (errorType == 0) {
            if (_deviceNameVCType == DeviceNameVCTypeChangeEmail || _deviceNameVCType == DeviceNameVCTypeNickName) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            } else if (_deviceNameVCType == DeviceNameVCTypeBindEmail) {
                
                JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
                if (([acc.phone isEqualToString:@""] || acc.phone == nil)) {
                    SetPwForOpenLoginViewController *setPw = [[SetPwForOpenLoginViewController alloc]init];
                    setPw.isPhoneNumber = NO;
                    setPw.smsToken = _deviceNameTextFiled.text;
                    [self.navigationController pushViewController:setPw animated:YES];
                    return;
                }else{
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Added_successfully"]];
                }
                
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:JFGAccountMsgChangedKey object:nil];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGAccountMsgChangedKey];
            
            
            if (_deviceNameVCType == DeviceNameVCTypeChangeEmail || _deviceNameVCType == DeviceNameVCTypeBindEmail) {
                CheckingEmailViewController *check = [[CheckingEmailViewController alloc]init];
                check.email = self.deviceNameTextFiled.text;
                [self.navigationController pushViewController:check animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            
            
        } else {
            
            if (errorType == 187) {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"RET_EEDITUSERINFO_EMAIL"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"I_KNOW"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
            }else if(errorType == 189){
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
            }else{
                [ProgressHUD showText:[NSString stringWithFormat:@"error：%lu",(unsigned long)errorType]];
            }
            
        }
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [ProgressHUD dismiss];
            
        });
    }
}


//fping
-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask {
    if (ask != nil)
    {
        if ([ask.cid isEqualToString:self.cid])
        {
            
        }
    }
}
//设置WiFi密码
-(void)jfgSetWifiRespose:(JFGSDKUDPResposeSetWifi *)ask {
    /*if(ask.success) {
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"DOOR_SET_WIFI_MSG"]];
        for (UIViewController * VC in self.navigationController.viewControllers) {
            if ([VC isKindOfClass:[JiafeigouRootViewController class]]) {
                [self.navigationController popToViewController:VC animated:YES];
            }
        }
    }
    */
}
-(void)jfgSetDeviceAliasResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeCIDAliasExist) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_EALIAS_EXIST"]];
    }else{
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:updateAliasNotification object:textString];
        [JFGSDK refreshDeviceList];
        [self.navigationController popViewControllerAnimated:YES];
    }
    int64_t delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}
@end
