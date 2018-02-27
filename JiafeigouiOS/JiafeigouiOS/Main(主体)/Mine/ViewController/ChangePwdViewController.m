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
#import <JFGSDK/JFGSDKDataPoint.h>
#import "CommonMethod.h"
#import "LoginManager.h"
#import "JfgConstKey.h"

@interface ChangePwdViewController ()<UITextFieldDelegate,JFGSDKCallbackDelegate>
{
    BOOL ischangedSucces;
}
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *eyeView1;
@property (nonatomic, strong) UIView *eyeView2;

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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(openDoorTimeout) object:nil];
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
    if (self.changeType == ChangePwdTypeForDoorlock) {
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MODIFY_DOOR_PSW"];
    }
}
- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.pwdTextField];
    [self.bgView addSubview:self.confirmPwdTextField];
    [self.bgView addSubview:self.line];

    [self.bgView addSubview:self.eyeView1];
    [self.bgView addSubview:self.eyeView2];
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
        make.right.equalTo(@(-40));
        make.height.equalTo(@44);
    }];
    
    [self.eyeView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdTextField.mas_top).with.offset(5);
        make.left.equalTo(self.pwdTextField.mas_right);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pwdTextField.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-5));
        make.height.equalTo(@0.5);
    }];
    [self.confirmPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.line.mas_bottom);
        make.left.equalTo(@15);
        make.right.equalTo(@(-40));
        make.height.equalTo(@44);
    }];
    
    [self.eyeView2 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.confirmPwdTextField.mas_top).with.offset(5);
        make.left.equalTo(self.confirmPwdTextField.mas_right);
        make.width.equalTo(@35);
        make.height.equalTo(@35);
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
    
    if (self.changeType == ChangePwdTypeForAccount) {
        if (str.length > pwMaxLength) {
            
            return NO;
        }
    }else if (self.changeType == ChangePwdTypeForDoorlock){
        if (str.length > 16) {
            
            return NO;
        }
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
        _confirmPwdTextField.rightViewMode =  UITextFieldViewModeWhileEditing;
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

-(UIView *)eyeView1
{
    if (!_eyeView1) {
        _eyeView1 = [self pwTextFieldRightViewWitFrame:CGRectMake(0, 0, 0, 0) tag:10000];
    }
    return _eyeView1;
}

-(UIView *)eyeView2
{
    if (!_eyeView2) {
        _eyeView2 = [self pwTextFieldRightViewWitFrame:CGRectMake(0, 0, 0, 0) tag:10001];
    }
    return _eyeView2;
}

//创建密码输入框右边控件
-(UIView *)pwTextFieldRightViewWitFrame:(CGRect)frame tag:(int)tag
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 35, 35)];
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lockBtn.frame = CGRectMake(0, 0, 35, 35);
    [lockBtn setImage:[UIImage imageNamed:@"lock_btn_noshow password"] forState:UIControlStateNormal];
    [lockBtn setImage:[UIImage imageNamed:@"lock_btn_show password"] forState:UIControlStateSelected];
    lockBtn.adjustsImageWhenDisabled = NO;
    lockBtn.adjustsImageWhenHighlighted = NO;
    lockBtn.tag = tag;
    [lockBtn addTarget:self action:@selector(lockPwAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:lockBtn];
    return bgView;
}

-(void)lockPwAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.tag == 10000) {
        //原始密码
        if (sender.selected) {
            self.pwdTextField.secureTextEntry = NO;
        }else{
            self.pwdTextField.secureTextEntry = YES;
        }
    }else if (sender.tag == 10001){
        //新密码
        if (sender.selected) {
            self.confirmPwdTextField.secureTextEntry = NO;
        }else{
            self.confirmPwdTextField.secureTextEntry = YES;
        }
    }
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)rightButtonAction:(UIButton *)sender
{
    int maxLength = pwMaxLength;
    if (self.changeType == ChangePwdTypeForDoorlock) {
        maxLength = 16;
    }
    if (_pwdTextField.text.length == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"CURRENT_PWD"]];
    }  else if (_confirmPwdTextField.text.length == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
    }else if (_confirmPwdTextField.text.length>maxLength || _confirmPwdTextField.text.length<pwMinLength){
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
    }else{
        
        if (self.changeType == ChangePwdTypeForDoorlock) {
            
#pragma mark- 修改开门密码
            [self changeOpenDoorPw];
            
            
        }else if (self.changeType == ChangePwdTypeForAccount){
            
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
}


-(void)changeOpenDoorPw
{
    [ProgressHUD showProgress:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(openDoorTimeout) object:nil];
    [self performSelector:@selector(openDoorTimeout) withObject:nil afterDelay:30];
    
    DataPointSeg *seg = [[DataPointSeg alloc]init];
    seg.msgId = 405;
    seg.version = 0;
    seg.value = [MPMessagePackWriter writeObject:@[self.pwdTextField.text,self.confirmPwdTextField.text] error:nil];
    
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotDataWithPeer:self.cid action:41 dps:@[seg] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                if (seg.msgId  == 406) {
                    
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        
                        int ret = [obj intValue];
                        if (ret == 0) {
                            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                            int64_t delayInSeconds = 1.5;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                                [ProgressHUD dismiss];
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                
                            });
                        }else{
                             [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
                        }
                        
                    }else{
                         [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
                    }
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(openDoorTimeout) object:nil];
                    
                }
                
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
         [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(openDoorTimeout) object:nil];
    }];
}

-(void)openDoorTimeout
{
     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
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
