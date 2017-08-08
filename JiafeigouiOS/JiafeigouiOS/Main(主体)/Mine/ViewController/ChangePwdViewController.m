//
//  ChangePwdViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "JfgGlobal.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "CommonMethod.h"
#import "LoginManager.h"
#import "JfgConstKey.h"

@interface ChangePwdViewController ()<UITextFieldDelegate,JFGSDKCallbackDelegate>
{
    BOOL ischangedSucces;
}
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField * pwdTextField;
@property (nonatomic, strong) UITextField * confirmPwdTextField;
@property (nonatomic, strong) UIView * line;
@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    [JFGSDK addDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
}

#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"FINISHED"] forState:UIControlStateNormal];
    self.rightButton.hidden = NO;
    self.rightButton.enabled = NO;
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"CHANGE_PWD"];
}
- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.pwdTextField];
    [self.bgView addSubview:self.confirmPwdTextField];
    [self.bgView addSubview:self.line];
}

- (void)initViewLayout
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0+20.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@88.5);
    }];
    
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@44);
    }];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pwdTextField.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@0.5);
    }];
    [self.confirmPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@44);
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.pwdTextField) {
        [textField resignFirstResponder];
        [self.confirmPwdTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        [self rightButtonAction:nil];
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.confirmPwdTextField) {
        
        if (self.pwdTextField.text.length>=6 && str.length >=6 ) {
            self.rightButton.enabled = YES;
        }else{
            self.rightButton.enabled = NO;
        }
        
    }else{
        
        if (self.confirmPwdTextField.text.length>=6 && str.length >=6 ) {
            self.rightButton.enabled = YES;
        }else{
            self.rightButton.enabled = NO;
        }
        
    }
    
    if (str.length > pwMaxLength) {
        //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.rightButton.enabled = NO;
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

- (UITextField *)pwdTextField
{
    if (_pwdTextField == nil)
    {
        _pwdTextField = [[UITextField alloc] init];
        _pwdTextField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _pwdTextField.textColor = [UIColor colorWithHexString:@"#333333"];
        _pwdTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"Tap3_ChangePassword"];
        _pwdTextField.secureTextEntry = YES;
        _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _pwdTextField.returnKeyType = UIReturnKeyNext;
        [_pwdTextField setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _pwdTextField.clearButtonMode = UITextFieldViewModeAlways;
        _pwdTextField.delegate = self;
    }
    
    return _pwdTextField;
}
- (UITextField *)confirmPwdTextField{
    if (_confirmPwdTextField == nil)
    {
        _confirmPwdTextField = [[UITextField alloc] init];
        _confirmPwdTextField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
        _confirmPwdTextField.textColor = [UIColor colorWithHexString:@"#333333"];
        _confirmPwdTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"NEW_PWD"];
        _confirmPwdTextField.secureTextEntry = YES;
        _confirmPwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _confirmPwdTextField.returnKeyType = UIReturnKeyDone;
        [_confirmPwdTextField setFont:[UIFont fontWithName:@"PingFangSC" size:16.0f]];
        _confirmPwdTextField.clearButtonMode = UITextFieldViewModeAlways;
        _confirmPwdTextField.delegate = self;
    }
    return _confirmPwdTextField;
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
    if (_pwdTextField.text.length == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"CURRENT_PWD"]];
    }  else if (_confirmPwdTextField.text.length == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
    }else if (_confirmPwdTextField.text.length>pwMaxLength || _confirmPwdTextField.text.length<pwMinLength){
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
    }else{
        
        if ([self.jfgAccount.account isKindOfClass:[NSString class]]) {
            [JFGSDK changePasswordWithAccount:self.jfgAccount.account oldPassword:_pwdTextField.text newPassword:_confirmPwdTextField.text];
            [ProgressHUD showProgress:nil];
        }else{
            
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            if (account.account) {
                [JFGSDK changePasswordWithAccount:account.account oldPassword:_pwdTextField.text newPassword:_confirmPwdTextField.text];
                [ProgressHUD showProgress:nil];
            }
            
        }
    }
    
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeChangedPassworld) {
        if (errorType ==0) {
            
            ischangedSucces = YES;
            
            NSString *account = @"";
            if (self.jfgAccount.phone && ![self.jfgAccount.phone isEqualToString:@""]) {
                account = self.jfgAccount.phone;
            }else if (self.jfgAccount.email && ![self.jfgAccount.email isEqualToString:@""]){
                account = self.jfgAccount.email;
            }
            [[LoginManager sharedManager] loginWithAccount:account password:self.confirmPwdTextField.text];
            
        }else{
            
            ischangedSucces = NO;
            [ProgressHUD showText: [CommonMethod languageKeyForLoginErrorType:errorType]];
        }
    }
}

-(void)jfgChangerPasswordResult:(JFGErrorType)errorType
{
    
}

-(void)jfgLoginResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        
        if (ischangedSucces) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PWD_OK_1"]];
        }
        
    }else{
        
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        
    }
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        
    });
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
