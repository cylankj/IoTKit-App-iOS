//
//  ForgetPasswordRootViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ForgetPasswordRootViewController.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "NSString+FLExtension.h"
#import "NSString+Validate.h"
#import "ProgressHUD.h"
#import "FLProressHUD.h"
#import "ForgetEmailPasswordViewController.h"
#import "SecurityCodeButton.h"
#import "JfgTypeDefine.h"
#import "NewPasswordViewController.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgLanguage.h"
#import "CommonMethod.h"
#import "JfgConfig.h"
#import "UIButton+Addition.h"

typedef NS_ENUM(NSInteger, forgetPassControl) {
    BTN_NextSendSMSTag = 1000, //发送验证码
    BTN_NextVerfySMSTag, // 检测 验证码
    BTN_NextReSendSMSTag, // 重新发送验证码
};

@interface ForgetPasswordRootViewController ()<UITextFieldDelegate, JFGSDKCallbackDelegate>

@property (nonatomic,strong)UIButton *exitBtn;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UITextField *accountTextFiled;
@property (nonatomic,strong)UIView *accountTFGgView;
@property (nonatomic,strong)UIButton *nextBtn;

@property (nonatomic,strong)UITextField *codeTextFiled;
@property (nonatomic,strong)UIView *codeBgView;
@property (nonatomic,strong)SecurityCodeButton *secondBtn;

@property (nonatomic, copy) NSString *token;

@end

@implementation ForgetPasswordRootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.accountTFGgView];
    [self.view addSubview:self.nextBtn];
    self.codeBgView.left = self.view.width*2+10;
    [self.view addSubview:self.codeBgView];
    
    [JFGSDK addDelegate:self];
    
    if (self.padding && ![self.padding isEqualToString:@""]) {
        self.accountTextFiled.text = self.padding;
        self.nextBtn.enabled = YES;
    }
    // Do any additional setup after loading the view.
}

//输入框文字变化，对应按钮状态改变
-(void)textFiledTextDidChange:(NSNotification *)notification
{
    UITextField *textFiled = notification.object;

    
    if (textFiled == _accountTextFiled || textFiled == _codeTextFiled) {
        
        //验证码输入框未出现时候状态
        if (self.codeBgView.left != self.accountTFGgView.left ) {
            
            if (![_accountTextFiled.text isEqualToString:@""]) {
                _nextBtn.enabled = YES;
            }else{
                _nextBtn.enabled = NO;
            }
            
        }else{
            if (![_accountTextFiled.text isEqualToString:@""] && ![_codeTextFiled.text isEqualToString:@""] ) {
                
                _nextBtn.enabled = YES;
                
            }else{
                
                _nextBtn.enabled = NO;
            }
        }
        
    }
}



-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _accountTextFiled) {
        if (toBeString.length > 65) {
            return NO;
        }
    }
    if (textField == _codeTextFiled) {
        if (toBeString.length > 6) {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark- action
-(void)nextAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([_accountTextFiled.text isEmail] || ([_accountTextFiled.text isMobileNumber] && _accountTextFiled.text.length == 11)){
        
        if ([_accountTextFiled.text isEmail])
        {
            //邮箱
            [JFGSDK forgetPasswordWithEmail:_accountTextFiled.text];
            [ProgressHUD showProgress:nil];
            
        }else{
            
            if (sender.tag == BTN_NextSendSMSTag) // 发送验证码
            {
                //此处先判断手机号是否已经注册，然后再弹出输入验证码框
                [JFGSDK sendSMSWithPhoneNumber:_accountTextFiled.text type:smsCodeTypeForgetPass];
                
            }else if(sender.tag == BTN_NextVerfySMSTag || sender.tag == BTN_NextReSendSMSTag){ // 检测 验证码
            
                if (_codeTextFiled.text.length<6)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_ESMS_CODE_FALSE"]];
                        
                    });
                } else {
                    [JFGSDK verifySMSWithAccount:_accountTextFiled.text code:_codeTextFiled.text token:self.token];
                }
                
                
            }
            [ProgressHUD showProgress:nil];
        }
        
    }else{
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ACCOUNT_ERR"]];
    }
    
}



-(void)jfgForgetPassByEmail:(NSString *)email errorType:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        [ProgressHUD dismiss];
        ForgetEmailPasswordViewController *emailVC = [ForgetEmailPasswordViewController new];
        emailVC.email = _accountTextFiled.text;
        [self.navigationController pushViewController:emailVC animated:YES];
    }else{
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
    }
    
}

-(void)exitAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reSendSMSAction
{
    if (!self.secondBtn.isKeepTimeing) {
        [JFGSDK sendSMSWithPhoneNumber:_accountTextFiled.text type:smsCodeTypeForgetPass];
        self.nextBtn.tag = BTN_NextReSendSMSTag;
        [self.secondBtn startKeepTime];
    }
   
}

#pragma mark 
#pragma mark == SDK Delegate ==
-(void)jfgSendSMSResult:(JFGErrorType)errorType token:(NSString *)token
{
    if (errorType == JFGErrorTypeNone) {
        self.token = token;
        [ProgressHUD dismiss];
        
        if (self.nextBtn.tag == BTN_NextSendSMSTag) {
            self.nextBtn.enabled = NO;
            _accountTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"];
            [UIView animateWithDuration:0.4 animations:^{
                
                self.nextBtn.top = self.codeBgView.bottom+40;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    [self.nextBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateNormal];
                }];
                
            }];
            
            [UIView animateWithDuration:1 delay:0.2 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
                self.codeBgView.left = self.accountTFGgView.left;
                [self.secondBtn startKeepTime];
            } completion:^(BOOL finished) {
                
            }];
            self.accountTextFiled.enabled = NO;
        }
        self.nextBtn.tag = BTN_NextVerfySMSTag;
    
    }else{
        
        if (errorType == 192) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GetCode_FrequentlyTips"]];
        }else{
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        }
        
        
    }
    
}

-(void)jfgVerifySMSResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        [ProgressHUD dismiss];
        NewPasswordViewController *newP = [[NewPasswordViewController alloc]init];
        newP.type = SetPasswordTypeResetPassword;
        newP.registerType = registerTypePhone;
        newP.accountStr = _accountTextFiled.text;
        newP.registerToken = self.token;
        [self.navigationController pushViewController:newP animated:YES];
    }else{
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
    }
    
}

#pragma mark- TextField Delegate



#pragma mark getter

-(UIButton *)exitBtn
{
    if (!_exitBtn) {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10-2, 130/2-5-2, 33+4, 33+4);
        [_exitBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.width-200)*0.5, 130*0.5, 200, 25)];
        _titleLabel.font = [UIFont systemFontOfSize:23];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#444444"];
        _titleLabel.text= [JfgLanguage getLanTextStrByKey:@"FORGOT_PWD"];
    }
    return _titleLabel;
}

-(UITextField *)accountTextFiled
{
    if (!_accountTextFiled) {
        _accountTextFiled = [self factoryTextFieldWithFrame:CGRectMake(0, 0, self.view.width-40, 25) placeholder:[JfgLanguage getLanTextStrByKey:@"PHONE_EMAIL"]];
        
        if ([JfgLanguage languageType] != LANGUAGE_TYPE_CHINESE) {
            _accountTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"EMAIL"];
        }
        
        _accountTextFiled.returnKeyType = UIReturnKeyDone;
        _accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _accountTextFiled;
}

-(UITextField *)factoryTextFieldWithFrame:(CGRect)frame placeholder:(NSString*)text
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.placeholder = text;
    textField.font = [UIFont systemFontOfSize:16];
    textField.tintColor = [UIColor colorWithHexString:@"#49b8ff"];
    [textField setValue:[UIColor colorWithHexString:@"#cecece"] forKeyPath:@"_placeholderLabel.textColor"];
    textField.delegate = self;
    return textField;
}

-(UIView *)factoryLineView:(CGRect)frame
{
    UIView *lineView = [[UIView alloc]initWithFrame:frame];
    lineView.backgroundColor =[UIColor colorWithHexString:@"#e8e8e8"];
    lineView.height = 1;
    return lineView;
}

-(UIView *)accountTFGgView
{
    if (!_accountTFGgView) {
        _accountTFGgView = [[UIView alloc]initWithFrame:CGRectMake(20, 150, self.view.width-40,35)];
        _accountTFGgView.backgroundColor = [UIColor clearColor];
        _accountTFGgView.userInteractionEnabled = YES;
        
        
        [_accountTFGgView addSubview:self.accountTextFiled];
        UIView *lineView = [self factoryLineView:CGRectMake(0, _accountTextFiled.bottom+8, _accountTextFiled.width, 1)];
        [_accountTFGgView addSubview:lineView];
        
    }
    return _accountTFGgView;
}

-(UITextField *)codeTextFiled
{
    if (!_codeTextFiled) {
        _codeTextFiled = [self factoryTextFieldWithFrame:CGRectMake(51,0, self.accountTextFiled.width-102, self.accountTextFiled.height) placeholder:[JfgLanguage getLanTextStrByKey:@"ENTER_CODE"]];
        _codeTextFiled.secureTextEntry = YES;
        _codeTextFiled.secureTextEntry = NO;
        _codeTextFiled.delegate = self;
        _codeTextFiled.returnKeyType = UIReturnKeyDone;
        _codeTextFiled.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _codeTextFiled;
}

-(SecurityCodeButton *)secondBtn
{
    if (!_secondBtn) {
        _secondBtn = [SecurityCodeButton buttonWithType:UIButtonTypeCustom];
        [_secondBtn addTarget:self action:@selector(reSendSMSAction) forControlEvents:UIControlEventTouchUpInside];
        _secondBtn.frame = CGRectMake(0, 0, 60, 20);
        _secondBtn.isRelatingNetwork = YES;
    }
    return _secondBtn;
}

-(UIView *)codeBgView
{
    if (!_codeBgView) {
        _codeBgView = [[UIView alloc]initWithFrame:CGRectMake(self.accountTFGgView.left, self.accountTFGgView.bottom+40, self.accountTFGgView.width, self.accountTFGgView.height)];
        _codeBgView.backgroundColor = [UIColor clearColor];
        _codeBgView.userInteractionEnabled = YES;
        [_codeBgView addSubview:self.codeTextFiled];
        
        UIView *lineView = [self factoryLineView:CGRectMake(0, _codeTextFiled.bottom+8, self.view.width-40, 1)];
        [_codeBgView addSubview:lineView];
        
        self.secondBtn.left = lineView.width-60;
        self.secondBtn.bottom = lineView.top-10;
        [_codeBgView addSubview:self.secondBtn];
        
        CGFloat centerX = self.codeTextFiled.x;
        self.codeTextFiled.width = lineView.width-140;
        self.codeTextFiled.x = centerX;
        
    }
    return _codeBgView;
}

-(UIButton *)nextBtn
{
    if (!_nextBtn) {
        
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.frame = CGRectMake(0, self.accountTFGgView.bottom+40, 360*0.5, 44);
        _nextBtn.layer.masksToBounds = YES;
        _nextBtn.x = self.view.x;
        _nextBtn.layer.cornerRadius = 22;
        _nextBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _nextBtn.layer.borderWidth = 1;
        [_nextBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
         [_nextBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        [_nextBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.selected = NO;
        _nextBtn.tag = BTN_NextSendSMSTag;
        _nextBtn.enabled = NO;
        _nextBtn.isRelatingNetwork = YES;
    }
    return _nextBtn;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
