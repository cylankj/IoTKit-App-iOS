//
//  ChangePhoneViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ChangePhoneViewController.h"
#import "JfgGlobal.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "NSString+FLExtension.h"
#import "CommonMethod.h"
#import "SecurityCodeButton.h"
#import "JfgConfig.h"
#import "ChangePwdViewController.h"
#import "SetPwForOpenLoginViewController.h"
#import "LoginManager.h"

@interface ChangePhoneViewController ()<JFGSDKCallbackDelegate,UITextFieldDelegate> {
    NSString * smsToken;
}
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *smsTextField;
@property (nonatomic, strong) SecurityCodeButton *smsButton;
@property (nonatomic, strong) UIView * line;
@end

@implementation ChangePhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    [JFGSDK addDelegate:self];
    self.rightButton.enabled = NO;
    self.smsButton.enabled = NO;
}
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
    self.rightButton.hidden = NO;
    if (self.actionType == actionTypeBingPhone) {
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_BindPhoneNo"];
    }else{
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"CHANGE_PHONE_NUM"];
        JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
        if (acc.phone.length == 0) {
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_BindPhoneNo"];
        }
        
    }

}
- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.phoneTextField];
    [self.bgView addSubview:self.smsTextField];
    [self.bgView addSubview:self.line];
    [self.bgView addSubview:self.smsButton];
    
    [self.smsButton setTitle:[JfgLanguage getLanTextStrByKey:@"GET_CODE"] forState:UIControlStateNormal];
    [self.smsButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    [self.smsButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
}

- (void)initViewLayout
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0+20.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@88.5);
    }];
    
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@44);
    }];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneTextField.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@0.5);
    }];
    [self.smsTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-85));
        make.height.equalTo(@44);
    }];
    [self.smsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom);
        make.right.equalTo(@(-15));
        make.height.equalTo(@44);
        make.width.greaterThanOrEqualTo(@60);
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.phoneTextField) {
        [textField resignFirstResponder];
        [self.smsTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        [self rightButtonAction:nil];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.smsTextField) {
        if (![self.phoneTextField.text isEqualToString:@""] && ![str isEqualToString:@""]) {
            self.rightButton.enabled = YES;
        }else{
            self.rightButton.enabled = NO;
        }
        if (str.length > 6) {
            
            return NO;
            
        }
        
    }else if (textField == self.phoneTextField){
        if (![self.smsTextField.text isEqualToString:@""] && ![str isEqualToString:@""]) {
            self.rightButton.enabled = YES;
        }else{
            self.rightButton.enabled = NO;
        }
        
        if (![str isEqualToString:@""]) {
            self.smsButton.enabled = YES;
        }else{
            self.smsButton.enabled = NO;
        }
        if (str.length > 11) {
            
            return NO;
            
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.rightButton.enabled = NO;
    if (textField == self.phoneTextField) {
        self.smsButton.enabled = NO;
    }
    return YES;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

- (UITextField *)phoneTextField
{
    if (_phoneTextField == nil)
    {
        _phoneTextField = [[UITextField alloc] init];
        _phoneTextField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _phoneTextField.textColor = [UIColor colorWithHexString:@"#333333"];
        _phoneTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"];
        _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextField.returnKeyType = UIReturnKeyNext;
        [_phoneTextField setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _phoneTextField.delegate = self;
        _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;

    }
    
    return _phoneTextField;
}

- (UITextField *)smsTextField
{
    if (_smsTextField == nil)
    {
        _smsTextField = [[UITextField alloc] init];
        _smsTextField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _smsTextField.textColor = [UIColor colorWithHexString:@"#333333"];
        _smsTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"ENTER_CODE"];
        _smsTextField.delegate = self;
        _smsTextField.keyboardType = UIKeyboardTypeNumberPad;
        _smsTextField.returnKeyType = UIReturnKeyDone;
        [_smsTextField setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _smsTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _smsTextField;
}
- (SecurityCodeButton *)smsButton{
    if (!_smsButton) {
        _smsButton = [SecurityCodeButton buttonWithType:UIButtonTypeCustom];
        [_smsButton setTitle:[JfgLanguage getLanTextStrByKey:@"GET_CODE"] forState:UIControlStateNormal];
        [_smsButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_smsButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_smsButton addTarget:self action:@selector(smsButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _smsButton;
}
- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = TableSeparatorColor;
    }
    return _line;
}
#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)rightButtonAction:(UIButton *)sender
{
    if (![_phoneTextField.text isMobileNumber]) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"]];
    }else if (_smsTextField.text.length == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap0_Register_VerificationCode"]];
    }else{
        //NSLog(@"account = %@",self.jfgAccount.account);
        
        if (smsToken == nil || [smsToken isEqualToString:@""]) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"CODE_ERR"]];
        }else{
            [JFGSDK verifySMSWithAccount:_phoneTextField.text code:_smsTextField.text token:smsToken];
            [ProgressHUD showProgress:nil];
        }
        
    }
    
}
- (void)smsButtonAction
{
    if ([_phoneTextField.text isMobileNumber]) {
        [JFGSDK sendSMSWithPhoneNumber:_phoneTextField.text type:0];
    }else{
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"]];
    }
    
}

-(void)jfgSendSMSResult:(JFGErrorType)errorType token:(NSString *)token {
    if (token) {
        smsToken = token;
    }
    if (errorType != 0) {
        if (errorType == 192) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GetCode_FrequentlyTips"]];
        }else{
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        }
    }else{
        [self.smsButton startKeepTime];
    }
}

-(void)jfgVerifySMSResult:(JFGErrorType)errorType {
    if (errorType != 0) {
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
    }else{
       [JFGSDK resetAccountPhone:_phoneTextField.text token:smsToken];
    }
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeUpdataAccount) {
        if (errorType == 0) {
            if (self.actionType == actionTypeBingPhone)
            {
                //[ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Added_successfully"]];
                [ProgressHUD dismiss];
                SetPwForOpenLoginViewController * changePwd = [SetPwForOpenLoginViewController new];
                changePwd.smsToken = smsToken;
                changePwd.isPhoneNumber = YES;
                [self.navigationController pushViewController:changePwd animated:YES];
                
            }else{
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGAccountMsgChangedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:JFGAccountMsgChangedKey object:nil];
            
        } else {
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        }
    }
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
