//
//  NewPasswordViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "NewPasswordViewController.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgConfig.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import "FLProressHUD.h"
#import "CommonMethod.h"
#import "LoginManager.h"
#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "UIButton+Addition.h"
#import "UserAccountMsg.h"
#import "NSString+FLExtension.h"
#import "ForgetEmailPasswordViewController.h"

@interface NewPasswordViewController ()<UITextFieldDelegate, JFGSDKCallbackDelegate,UIAlertViewDelegate,LoginManagerDelegate>

@property (nonatomic,strong)UIButton *exitBtn;
@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UITextField *pwTextFiled;
@property (nonatomic,strong)UIView *pwTFGbView;
@property (nonatomic,strong)UIButton *querenBtn;
@end

@implementation NewPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.pwTFGbView];
    [self.view addSubview:self.querenBtn];
    [JFGSDK addDelegate:self];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[LoginManager sharedManager] addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[LoginManager sharedManager] removeDelegate:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [super viewWillAppear:animated];
}



-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    _querenBtn.enabled = NO;
    [_querenBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toBeString.length > 12) {
        return NO;
    }
    
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if (![toBeString isEqualToString:@""]) {
        _querenBtn.enabled = YES;
    }else{
        _querenBtn.enabled = NO;
    }
    
    return YES;
}

-(void)exitAction
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap3_logout_tips"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_No"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"Button_Yes"], nil];
    alert.tag = 12345;
    [alert show];
}



-(void)makeAction
{
    
    if (self.pwTextFiled.text.length<6) {
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PASSWORD_LESSTHAN_SIX"]];
        return;
        
    }
    
    [self.view endEditing:YES];
    
    [ProgressHUD showProgress:nil];

    switch (_type)
    {
            
        case SetPasswordTypeInitializePassword:
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
            [self performSelector:@selector(actionTimeOut) withObject:nil afterDelay:30];
            
            [JFGSDK userRegister:self.accountStr keyword:self.pwTextFiled.text registerType:self.registerType token:self.registerToken];
            [JFGSDK appendStringToLogFile:@"userRegisterAction"];
        }
            break;
        case SetPasswordTypeResetPassword:
        {
            [JFGSDK forgetPasswordWithAccount:self.accountStr token:self.registerToken newPassword:self.pwTextFiled.text];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark == JFG SDK Delegate ==
- (void)jfgRegisterResult:(JFGErrorType)errorType
{
    if (self.navigationController.visibleViewController == self)
    {
        
        if (errorType == JFGErrorTypeNone) {
            
            if ([self.accountStr isEmail]) {
                
                [ProgressHUD dismiss];
                ForgetEmailPasswordViewController *em = [ForgetEmailPasswordViewController new];
                em.type = EmailCheckTypeCheckEmailTip;
                em.email = self.accountStr;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
                [self.navigationController pushViewController:em animated:YES];
                
            }else{
                
                [[LoginManager sharedManager] loginWithAccount:self.accountStr password:self.pwTextFiled.text];
                //十秒超时处理
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
                [self performSelector:@selector(actionTimeOut) withObject:nil afterDelay:30];
            }
            JFGLog(@"注册 成功");
            
        }else{
            
            if (errorType == JFGErrorTypeSMSCodeTimeout) {
                
                [ProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"INVALID_CODE"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] otherButtonTitles:nil, nil];
                alert.tag = 10001;
                [alert show];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
            }else{
                [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
            }
        }
        
    }
}

-(void)actionTimeOut
{
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
}

-(void)jfgSetPasswordForOpenLoginResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }else{
        
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        
    }
}

- (void)jfgChangePasswordResult:(JFGErrorType)errorType
{
    if (self.navigationController.visibleViewController == self)
    {
        if (errorType == JFGErrorTypeNone) {
            
            JFGLog(@"修改 成功");
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PWD_OK"]];
            int64_t delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
                
            });
            
        }else{
            
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
            
        }
    }
}


-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeForgetPassworld) {
        if (self.navigationController.visibleViewController == self)
        {
            if (errorType == JFGErrorTypeNone) {
                
                JFGLog(@"修改 成功");
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PWD_OK"]];
                int64_t delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                });
                
                
                
            }else{
                
                [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
            }
        }
    }
}

-(void)jfgForgetPasswordResult:(JFGErrorType)errorType
{
   [ProgressHUD dismiss];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10001) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (alertView.tag == 12345 && buttonIndex == 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- LoginDelegate
-(void)loginFail:(JFGErrorType)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
    [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:error]];
}

-(void)loginSuccess
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(actionTimeOut) object:nil];
    //注册登录成功，直接跳转主页
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [ProgressHUD dismiss];
       // [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RIGN_SUC"]];
        [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"RIGN_SUC"] position:FLProgressHUDPositionCenter];
        [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
        
    });
    
    //NSLog(@"LoginSuccess:%@",[NSThread currentThread]);
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if ([delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *barBar = (UITabBarController *)delegate.window.rootViewController;
            barBar.selectedIndex = 0;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [delegate goToJFGViewContrller];
        }
        
    });
    
}


#pragma mark property

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
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.width-150)*0.5, 130*0.5, 150, 23)];
        _titleLabel.font = [UIFont systemFontOfSize:23];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#444444"];
        if (_type == SetPasswordTypeInitializePassword) {
            _titleLabel.text= [JfgLanguage getLanTextStrByKey:@"SET_PWD"];
        }else{
            _titleLabel.text= [JfgLanguage getLanTextStrByKey:@"NEW_PWD"];
        }
    }
    return _titleLabel;
}

-(UIView *)pwTFGbView
{
    if (!_pwTFGbView) {
        _pwTFGbView = [[UIView alloc]initWithFrame:CGRectMake(20, 150, self.self.view.width-40, 35)];
        _pwTFGbView.backgroundColor = [UIColor clearColor];
        _pwTFGbView.userInteractionEnabled = YES;
        [_pwTFGbView addSubview:self.pwTextFiled];
        
        UIView *lineView = [self factoryLineView:CGRectMake(0, _pwTextFiled.bottom+8, _pwTextFiled.width+102, 1)];
        [_pwTFGbView addSubview:lineView];
        
        UIView *rightView = [self pwTextFieldRightView];
        rightView.left = _pwTFGbView.width-rightView.width;
        [_pwTFGbView addSubview:rightView];
        rightView.bottom = lineView.top-2;
        
        
        CGFloat centerX = _pwTextFiled.x;
        CGFloat centerY = _pwTextFiled.y;
        _pwTextFiled.width = lineView.width-2*rightView.width;
        _pwTextFiled.x = centerX;
        _pwTextFiled.y = centerY+1;
    }
    return _pwTFGbView;
}

//创建密码输入框右边控件
-(UIView *)pwTextFieldRightView
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
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




-(UITextField *)pwTextFiled
{
    if (!_pwTextFiled) {
        _pwTextFiled = [self factoryTextFieldWithFrame:CGRectMake(51,0, self.view.width-40-102, 25) placeholder:[JfgLanguage getLanTextStrByKey:@"PASSWORD"]];
        _pwTextFiled.secureTextEntry = YES;
        _pwTextFiled.returnKeyType = UIReturnKeyDone;
        _pwTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
        _pwTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _pwTextFiled;
}

-(UIButton *)querenBtn
{
    if (!_querenBtn) {
        
        _querenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _querenBtn.frame = CGRectMake(0, self.pwTFGbView.bottom+40, 360*0.5, 44);
        _querenBtn.layer.masksToBounds = YES;
        _querenBtn.x = self.view.x;
        _querenBtn.layer.cornerRadius = 22;
        _querenBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _querenBtn.layer.borderWidth = 1;
        [_querenBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_querenBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        [_querenBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        _querenBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_querenBtn addTarget:self action:@selector(makeAction) forControlEvents:UIControlEventTouchUpInside];
        _querenBtn.selected = NO;
        _querenBtn.enabled = NO;
        _querenBtn.isRelatingNetwork = YES;
        
    }
    return _querenBtn;
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

//密码明文密文切换
-(void)lockPwAction:(UIButton *)sender
{
   
    NSString *text = _pwTextFiled.text;
    if (sender.selected) {
        self.pwTextFiled.secureTextEntry = YES;
        sender.selected  = NO;
    }else{
        self.pwTextFiled.secureTextEntry = NO;
        sender.selected  = YES;
    }
    _pwTextFiled.text= text;
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
