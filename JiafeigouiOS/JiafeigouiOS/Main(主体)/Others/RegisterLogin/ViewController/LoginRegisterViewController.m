//
//  LoginRegisterViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"
#import "PopAnimation.h"
#import "FLThirdLoginButton.h"
#import "SecurityCodeButton.h"
#import "NewPasswordViewController.h"
#import "JfgConfig.h"
#import "ForgetPasswordRootViewController.h"
#import "LoginManager.h"
#import "JfgTypeDefine.h"
#import "FLProressHUD.h"
#import "NSString+Validate.h"
#import <JFGSDK/JFGSDK.h>
#import "AppDelegate.h"
#import "JfgLanguage.h"
#import "CommonMethod.h"
#import "UserAccountMsg.h"
#import "ProgressHUD.h"
#import "JFGHelpViewController.h"
#import "CommonMethod.h"
#import "NSString+FLExtension.h"
#import "UIButton+Addition.h"
#import "FLShareSDKHelper.h"

@interface LoginRegisterViewController ()<UITextFieldDelegate,LoginManagerDelegate, JFGSDKCallbackDelegate>
{
    LoginState loginState;
}

//登陆相关控件
@property (nonatomic,strong)UIButton *exitBtn;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIButton *pageSwitchBtn;
@property (nonatomic,strong)UITextField *accountTextFiled;
@property (nonatomic,strong)UITextField *pwTextFiled;
@property (nonatomic,strong)UIButton *forgetPwBtn;
@property (nonatomic,strong)FLThirdLoginButton *qqLoginBtn;
@property (nonatomic,strong)FLThirdLoginButton *weiboLoginBtn;
@property (nonatomic,strong)UIView *thirdLoginSpaceLine;
@property (nonatomic,strong)UIButton *loginBtn;
@property (nonatomic,strong)UIView *accountTFGgView;
@property (nonatomic,strong)UIView *pwTFGbView;
@property (nonatomic,strong)UIButton *lockBtn;

//注册相关
@property (nonatomic,strong)UITextField *registerTextFiled;
@property (nonatomic,strong)UIView *registerBgView;
@property (nonatomic,strong)UITextField *codeTextFiled;
@property (nonatomic,strong)UIView *codeBgView;
@property (nonatomic,strong)SecurityCodeButton *secondBtn;
@property (nonatomic,strong)UIButton *registerYDBtn;
@property (nonatomic,strong)UIButton *registerTypeBtn;
@property (nonatomic,strong)UILabel *xieyiLabel;
@property (nonatomic,copy)NSString *token;

@property (nonatomic,strong)UIScrollView *bgScroller;

@end

@implementation LoginRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transformLogin) name:@"LoginViewTransformLoginView" object:nil];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.pageSwitchBtn];
    [self.view addSubview:self.bgScroller];
    
    if (self.viewType == FristIntoViewTypeLogin) {
        
        [self initializeLoginViewWithAnimation];
        [self initializeRegisterViewWithoutAnimation];
        
    }else{
        
        [self.bgScroller setContentOffset:CGPointMake(self.view.width, 0)];
        self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_register"];
        [self.pageSwitchBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
        [self initializeRegisterViewWithAnimation];
        [self initializeLoginViewWithoutAnimation];
        
    }
    
    loginState = LoginStateNot;
    // Do any additional setup after loading the view.
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
    [[LoginManager sharedManager] addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [ProgressHUD dismiss];
    [[LoginManager sharedManager] removeDelegate:self];
}

-(void)transformLogin
{
    self.accountTextFiled.text = self.registerTextFiled.text;
    [self pageSwitchAction];
}

#pragma mark- -------------------界面相关----------------------
#pragma mark-
//输入框文字变化，对应按钮状态改变
-(void)textFiledTextDidChange:(NSNotification *)notification
{
    UITextField *textFiled = notification.object;
    if (textFiled == _accountTextFiled || textFiled == _pwTextFiled) {
        
        if (textFiled == _accountTextFiled) {
            
            if ([textFiled.text isEqualToString:@""]) {
                _pwTextFiled.text = @"";
            }
        }
        
        if (![_pwTextFiled.text isEqualToString:@""] && ![_accountTextFiled.text isEqualToString:@""]) {
            _loginBtn.enabled = YES;
        }else{
            _loginBtn.enabled = NO;
        }
        
    }
    
    if (textFiled == _registerTextFiled || textFiled == _codeTextFiled) {
        
        //验证码输入框未出现时候状态
        if (_registerBgView.left != _codeBgView.left ) {
            
            if (![_registerTextFiled.text isEqualToString:@""]) {
                _registerYDBtn.enabled = YES;
            }else{
                _registerYDBtn.enabled = NO;
            }
            
        }else{
            if (![_registerTextFiled.text isEqualToString:@""] && ![_codeTextFiled.text isEqualToString:@""] ) {
                
                _registerYDBtn.enabled = YES;
                
            }else{
                
                _registerYDBtn.enabled = NO;
            }
        }
        
    }
}

/**
 *  登陆页面视图初始化（带动画）
 */
-(void)initializeLoginViewWithAnimation
{
    //记录控件原始的正确的位置
    CGFloat accountBgCenter = self.accountTFGgView.y;
    CGFloat pwBgCenter = self.pwTFGbView.y;
    CGFloat loginCenter = self.loginBtn.y;
    CGFloat forgetPwCenter = self.forgetPwBtn.y;
    CGFloat qqLoginCenter = self.qqLoginBtn.y;
    CGFloat weiboLoginCenter  = self.weiboLoginBtn.y;
    CGFloat lineCenter = self.thirdLoginSpaceLine.y;
    
    //将所有控件移到屏幕下方
    self.accountTFGgView.y = self.pwTFGbView.y = self.loginBtn.y = self.forgetPwBtn.y = self.qqLoginBtn.y = self.weiboLoginBtn.y = self.thirdLoginSpaceLine.y = self.view.height + 100;
    
    
    [self.bgScroller addSubview:self.accountTFGgView];
    [self.bgScroller addSubview:self.pwTFGbView];
    [self.bgScroller addSubview:self.loginBtn];
    [self.bgScroller addSubview:self.forgetPwBtn];
    [self.bgScroller addSubview:self.qqLoginBtn];
    [self.bgScroller addSubview:self.weiboLoginBtn];
    [self.bgScroller addSubview:self.thirdLoginSpaceLine];
    
    if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin) {
        NSString *lastAccount = [[NSUserDefaults standardUserDefaults] objectForKey:JFGCurrentLoginedAccountKey];

        self.accountTextFiled.text = lastAccount;
    }
    
    //设置时间为2
    double delayInSeconds = 0.2;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //推迟两纳秒执行
    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.accountTFGgView.x, accountBgCenter) withView:self.accountTFGgView completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.pwTFGbView.x, pwBgCenter) withView:self.pwTFGbView completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.loginBtn.x, loginCenter) withView:self.loginBtn completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.forgetPwBtn.x, forgetPwCenter) withView:self.forgetPwBtn completionBlock:nil];
        
    });
    
   
    
    //设置时间为2
    double delayInSeconds2 = 0.5;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds2 =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
    //推迟两纳秒执行
    dispatch_queue_t concurrentQueue2 =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds2, concurrentQueue2, ^(void){
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.qqLoginBtn.x, qqLoginCenter) withView:self.qqLoginBtn completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.weiboLoginBtn.x, weiboLoginCenter) withView:self.weiboLoginBtn completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.thirdLoginSpaceLine.x, lineCenter) withView:self.thirdLoginSpaceLine completionBlock:nil];
        
    });
}


//初始化登陆页面，不带动画
-(void)initializeLoginViewWithoutAnimation
{
    [self.bgScroller addSubview:self.accountTFGgView];
    [self.bgScroller addSubview:self.pwTFGbView];
    [self.bgScroller addSubview:self.loginBtn];
    [self.bgScroller addSubview:self.forgetPwBtn];
   
    [self.bgScroller addSubview:self.qqLoginBtn];
    [self.bgScroller addSubview:self.weiboLoginBtn];
    [self.bgScroller addSubview:self.thirdLoginSpaceLine];
   
}

//初始化注册页面，带动画
-(void)initializeRegisterViewWithAnimation
{
    CGFloat registerBgViewOriginCenterY = self.registerBgView.y;
    CGFloat registerYDBtnOriginCenterY = self.registerYDBtn.y;
    CGFloat xieyiCenterY = self.xieyiLabel.y;
    CGFloat registerTypeBtnCenterY = self.registerTypeBtn.y;
    
    self.codeBgView.left = self.view.width*2+10;
    
    self.registerBgView.y = self.registerYDBtn.y = self.xieyiLabel.y = self.registerTypeBtn.y = self.view.height + 200;

    [self.bgScroller addSubview:self.registerBgView];
    [self.bgScroller addSubview:self.registerYDBtn];
    [self.bgScroller addSubview:self.codeBgView];
    [self.bgScroller addSubview:self.xieyiLabel];
    
    //非简体中文字体不显示手机注册
    if ([JfgLanguage languageType] == 0) {
        [self.bgScroller addSubview:self.registerTypeBtn];
    }else{
        [self waiguoZhuCe];
    }

    
    //设置时间为2
    double delayInSeconds = 0.2;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //推迟两纳秒执行
    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.registerBgView.x, registerBgViewOriginCenterY) withView:self.registerBgView completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.registerYDBtn.x, registerYDBtnOriginCenterY) withView:self.registerYDBtn completionBlock:nil];
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.xieyiLabel.x, xieyiCenterY) withView:self.xieyiLabel completionBlock:nil];
        
        
    });
    
    
    //设置时间为2
    double delayInSeconds2 = 0.5;
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds2 =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
    //推迟两纳秒执行
    dispatch_queue_t concurrentQueue2 =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds2, concurrentQueue2, ^(void){
        
        [PopAnimation startSpringPositonAnimation:CGPointMake(self.registerTypeBtn.x, registerTypeBtnCenterY) withView:self.registerTypeBtn completionBlock:nil];
        
    });

}

/**
 *  注册页面视图初始化（不带动画）
 */
-(void)initializeRegisterViewWithoutAnimation
{
    [self.bgScroller addSubview:self.registerBgView];
    [self.bgScroller addSubview:self.registerYDBtn];
    self.codeBgView.left = self.view.width*2+10;
    [self.bgScroller addSubview:self.codeBgView];
    [self.bgScroller addSubview:self.xieyiLabel];
    
    if ([JfgLanguage languageType] == 0) {
        [self.bgScroller addSubview:self.registerTypeBtn];
    }else{
        [self waiguoZhuCe];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)tapBgScroller
{
    [self.view endEditing:YES];
}

#pragma mark- 登陆界面视图

-(UIButton *)exitBtn
{
    if (!_exitBtn) {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10-2, 130/2-5-2, 33+4, 33+4);
        [_exitBtn setImage:[UIImage imageNamed:@"login_btn_close"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.width-180)*0.5, 130*0.5, 180, 25)];
        _titleLabel.font = [UIFont systemFontOfSize:23];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#444444"];
        _titleLabel.text= [JfgLanguage getLanTextStrByKey:@"LOGIN"];
    }
    return _titleLabel;
}

-(UIButton *)pageSwitchBtn
{
    if (!_pageSwitchBtn) {
        
        _pageSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pageSwitchBtn.frame = CGRectMake(self.view.width-15-70, 130*0.5-5, 70, 23+10);
        _pageSwitchBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _pageSwitchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_pageSwitchBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_register"] forState:UIControlStateNormal];
        [_pageSwitchBtn  setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_pageSwitchBtn addTarget:self action:@selector(pageSwitchAction) forControlEvents:UIControlEventTouchUpInside];
        _pageSwitchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        
    }
    return _pageSwitchBtn;
}

-(UIScrollView *)bgScroller
{
    if (!_bgScroller) {
        _bgScroller = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 140, self.view.width, self.view.height-140)];
        _bgScroller.contentSize = CGSizeMake(self.view.width*2, 0);
        _bgScroller.pagingEnabled = YES;
        _bgScroller.showsHorizontalScrollIndicator = NO;
        _bgScroller.showsVerticalScrollIndicator = NO;
        _bgScroller.alwaysBounceHorizontal = NO;
        _bgScroller.userInteractionEnabled = YES;
        _bgScroller.bounces = NO;
        _bgScroller.scrollEnabled = NO;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBgScroller)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_bgScroller addGestureRecognizer:tap];
    }
    return _bgScroller;
}

-(UITextField *)accountTextFiled
{
    if (!_accountTextFiled) {
        _accountTextFiled = [self factoryTextFieldWithFrame:CGRectMake(0, 0, self.bgScroller.width-40, 25) placeholder:[JfgLanguage getLanTextStrByKey:@"SHARE_E_MAIL"]];
        _accountTextFiled.returnKeyType = UIReturnKeyNext;
        _accountTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _accountTextFiled;
}

-(UITextField *)pwTextFiled
{
    if (!_pwTextFiled) {
        _pwTextFiled = [self factoryTextFieldWithFrame:CGRectMake(51,0, self.accountTextFiled.width-102, self.accountTextFiled.height) placeholder:[JfgLanguage getLanTextStrByKey:@"PASSWORD"]];
        _pwTextFiled.secureTextEntry = YES;
    
        _pwTextFiled.returnKeyType = UIReturnKeyDone;
       
        _pwTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _pwTextFiled;
}

-(UIView *)accountTFGgView
{
    if (!_accountTFGgView) {
        _accountTFGgView = [[UIView alloc]initWithFrame:CGRectMake(20, 10, self.bgScroller.width-40,35)];
        _accountTFGgView.backgroundColor = [UIColor clearColor];
        _accountTFGgView.userInteractionEnabled = YES;
        [_accountTFGgView addSubview:self.accountTextFiled];
        
        UIView *lineView = [self factoryLineView:CGRectMake(0, _accountTextFiled.bottom+8, _accountTextFiled.width, 1)];
        [_accountTFGgView addSubview:lineView];
    }
    return _accountTFGgView;
}

-(UIView *)pwTFGbView
{
    if (!_pwTFGbView) {
        _pwTFGbView = [[UIView alloc]initWithFrame:CGRectMake(20, self.accountTFGgView.bottom+40, self.accountTFGgView.width, self.accountTFGgView.height)];
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
    lockBtn.adjustsImageWhenDisabled = NO;
    lockBtn.adjustsImageWhenHighlighted = NO;
    [lockBtn addTarget:self action:@selector(lockPwAction:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:lockBtn];
    self.lockBtn = lockBtn;
   
    return bgView;
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

-(UIButton *)loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(0, self.pwTFGbView.bottom+40, 360*0.5, 44);
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.x = self.view.x;
        _loginBtn.layer.cornerRadius = 22;
        _loginBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _loginBtn.layer.borderWidth = 1;
        [_loginBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_loginBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.selected = NO;
        _loginBtn.enabled = NO;
        _loginBtn.isRelatingNetwork = YES;
    }
    return _loginBtn;
}

-(UIButton *)forgetPwBtn
{
    if (!_forgetPwBtn) {
        _forgetPwBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetPwBtn.frame = CGRectMake(0, self.loginBtn.bottom+20-15-10, 90, 20+22);
        _forgetPwBtn.left = (self.view.width-_forgetPwBtn.width)*0.5;
        [_forgetPwBtn setTitle:[JfgLanguage getLanTextStrByKey:@"FORGOT_PWD_1"] forState:UIControlStateNormal];
        [_forgetPwBtn setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        _forgetPwBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _forgetPwBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_forgetPwBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _forgetPwBtn;
}

-(FLThirdLoginButton *)qqLoginBtn
{
    if (!_qqLoginBtn) {
        _qqLoginBtn = [FLThirdLoginButton buttonWithType:UIButtonTypeCustom];
        _qqLoginBtn.frame = CGRectMake((self.view.width-200)*0.5, self.bgScroller.height-40-20, 75, 34*0.5);
        [_qqLoginBtn setTitleColor:[UIColor colorWithHexString:@"#7c7c7c"] forState:UIControlStateNormal];
        _qqLoginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        if ([JfgLanguage languageType] == 0) {
             [_qqLoginBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN_QQ"] forState:UIControlStateNormal];
            [_qqLoginBtn setImage:[UIImage imageNamed:@"btn_qq"] forState:UIControlStateNormal];
        }else{
            [_qqLoginBtn setTitle:@"Twitter" forState:UIControlStateNormal];
            [_qqLoginBtn setImage:[UIImage imageNamed:@"icon_twitter"] forState:UIControlStateNormal];
        }
        
        [_qqLoginBtn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
        _qqLoginBtn.isRelatingNetwork = YES;
    }
    return _qqLoginBtn;
}

-(FLThirdLoginButton *)weiboLoginBtn
{
    if (!_weiboLoginBtn) {
        _weiboLoginBtn = [FLThirdLoginButton buttonWithType:UIButtonTypeCustom];
        _weiboLoginBtn.frame = CGRectMake(self.qqLoginBtn.right+50, self.bgScroller.height-40-20, 75, 34*0.5);
        [_weiboLoginBtn setTitleColor:[UIColor colorWithHexString:@"#7c7c7c"] forState:UIControlStateNormal];
        _weiboLoginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        if ([JfgLanguage languageType] == 0) {
            [_weiboLoginBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN_WEIBO"] forState:UIControlStateNormal];
            [_weiboLoginBtn setImage:[UIImage imageNamed:@"btn_weibo"] forState:UIControlStateNormal];
        }else{
            [_weiboLoginBtn setImage:[UIImage imageNamed:@"icon_facebook"] forState:UIControlStateNormal];
            [_weiboLoginBtn setTitle:@"Facebook" forState:UIControlStateNormal];
        }
        
        [_weiboLoginBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
        _weiboLoginBtn.isRelatingNetwork = YES;
    }
    return _weiboLoginBtn;
}

-(UIView *)thirdLoginSpaceLine
{
    if (!_thirdLoginSpaceLine) {
        _thirdLoginSpaceLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.qqLoginBtn.top+2, 1, self.qqLoginBtn.height-4)];
        _thirdLoginSpaceLine.x = self.view.x;
        _thirdLoginSpaceLine.backgroundColor = [UIColor colorWithHexString:@"#7c7c7c"];
    }
    return _thirdLoginSpaceLine;
}



#pragma mark- 注册页面控件
-(UITextField *)registerTextFiled
{
    if (!_registerTextFiled) {
        _registerTextFiled = [self factoryTextFieldWithFrame:CGRectMake(0, 0, self.bgScroller.width-40, 25) placeholder:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"]];
        _registerTextFiled.returnKeyType = UIReturnKeyDone;
        _registerTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        _registerTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _registerTextFiled;
}

-(UITextField *)codeTextFiled
{
    if (!_codeTextFiled) {
        _codeTextFiled = [self factoryTextFieldWithFrame:CGRectMake(51,0, self.accountTextFiled.width-102, self.accountTextFiled.height) placeholder:[JfgLanguage getLanTextStrByKey:@"Tap0_Register_VerificationCode"]];
        _codeTextFiled.secureTextEntry = YES;
        _codeTextFiled.secureTextEntry = NO;
        _codeTextFiled.returnKeyType = UIReturnKeyDone;
        _codeTextFiled.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _codeTextFiled;
}

-(SecurityCodeButton *)secondBtn
{
    if (!_secondBtn) {
        _secondBtn = [SecurityCodeButton buttonWithType:UIButtonTypeCustom];
        _secondBtn.frame = CGRectMake(0, 0, 60, 20);
        [_secondBtn addTarget:self action:@selector(reSendSMS) forControlEvents:UIControlEventTouchUpInside];
    }
    return _secondBtn;
}

-(UIView *)registerBgView
{
    if (!_registerBgView) {
        _registerBgView = [[UIView alloc]initWithFrame:CGRectMake(20+self.view.width, 10, self.bgScroller.width-40,35)];
        _registerBgView.backgroundColor = [UIColor clearColor];
        _registerBgView.userInteractionEnabled = YES;
        
        
        [_registerBgView addSubview:self.registerTextFiled];
        UIView *lineView = [self factoryLineView:CGRectMake(0, _registerTextFiled.bottom+8, _registerTextFiled.width, 1)];
        [_registerBgView addSubview:lineView];
        
    }
    return _registerBgView;
}

-(UIView *)codeBgView
{
    if (!_codeBgView) {
        _codeBgView = [[UIView alloc]initWithFrame:CGRectMake(self.registerBgView.left, self.registerBgView.bottom+40, self.registerBgView.width, self.registerBgView.height)];
        _codeBgView.backgroundColor = [UIColor clearColor];
        _codeBgView.userInteractionEnabled = YES;
        
        
        [_codeBgView addSubview:self.codeTextFiled];
        
        UIView *lineView = [self factoryLineView:CGRectMake(0, _codeTextFiled.bottom+8, self.bgScroller.width-40, 1)];
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

-(UIButton *)registerYDBtn
{
    if (!_registerYDBtn) {
        
        _registerYDBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerYDBtn.frame = CGRectMake(0, self.registerBgView.bottom+40, 360*0.5, 44);
        _registerYDBtn.layer.masksToBounds = YES;
        _registerYDBtn.x = self.view.x+self.view.width;
        _registerYDBtn.layer.cornerRadius = 22;
        _registerYDBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _registerYDBtn.layer.borderWidth = 1;
        [_registerYDBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"GET_CODE"] forState:UIControlStateNormal];
        _registerYDBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_registerYDBtn addTarget:self action:@selector(registerYDAction:) forControlEvents:UIControlEventTouchUpInside];
        _registerYDBtn.selected = NO;
        _registerYDBtn.tag = 123456;
        [_registerYDBtn setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        _registerYDBtn.enabled = NO;
        _registerYDBtn.isRelatingNetwork = YES;
    }
    return _registerYDBtn;
}

-(UILabel *)xieyiLabel
{
    if (!_xieyiLabel) {
        
        _xieyiLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.width+(self.view.width-250)*0.5+5, self.registerYDBtn.bottom+20, 250, 15)];
        _xieyiLabel.font = [UIFont systemFontOfSize:13];
        _xieyiLabel.text = [JfgLanguage getLanTextStrByKey:@"AGREE"];
        _xieyiLabel.userInteractionEnabled = YES;
        _xieyiLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _xieyiLabel.textAlignment = NSTextAlignmentLeft;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(_xieyiLabel.width-105, 0, 105, _xieyiLabel.height);
        NSString *text = [NSString stringWithFormat:@"<<%@>>",[JfgLanguage getLanTextStrByKey:@"TERM_OF_USE"]];
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        //btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn addTarget:self action:@selector(readXieyi) forControlEvents:UIControlEventTouchUpInside];
        [_xieyiLabel addSubview:btn];
        
        //位置适配
        CGSize size = [_xieyiLabel sizeThatFits:CGSizeMake(self.view.width, _xieyiLabel.height)];
        
        CGSize btnSize = [btn.titleLabel sizeThatFits:CGSizeMake(self.view.width-size.width, btn.height)];
        
        _xieyiLabel.width = size.width + btnSize.width;
        
        if (_xieyiLabel.width > self.view.width) {
            CGFloat btnw = self.view.width - size.width;
            btn.width = btnw;
        }else{
           btn.width = btnSize.width;
        }
        
        btn.left = size.width;
        _xieyiLabel.x = self.view.width + self.view.x;
        if (_xieyiLabel.left < self.view.width) {
            _xieyiLabel.left = self.view.width;
        }
        
    }
    return _xieyiLabel;
}

-(UIButton *)registerTypeBtn
{
    if (!_registerTypeBtn) {
        _registerTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerTypeBtn.frame = CGRectMake((self.view.width-100)*0.5+self.view.width,self.bgScroller.height-35-30-5, 100, 35+10);
        [_registerTypeBtn setTitle:[JfgLanguage getLanTextStrByKey:@"EMAIL_SIGNUP"] forState:UIControlStateNormal];
        [_registerTypeBtn setTitleColor:[UIColor colorWithHexString:@"#7c7c7c"] forState:UIControlStateNormal];
        _registerTypeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_registerTypeBtn addTarget:self action:@selector(registerTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        _registerTypeBtn.tag = 20;
    }
    return _registerTypeBtn;
}

#pragma mark- TextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
   
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _accountTextFiled) {
        [textField resignFirstResponder];
        [_pwTextFiled becomeFirstResponder];
    }else if(textField == _pwTextFiled){
        [_pwTextFiled resignFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
   
    if (textField == _accountTextFiled || textField == _pwTextFiled) {
        
        if (textField == _accountTextFiled) {
            
            if (toBeString.length>65) {
                return NO;
            }
          
        }else{
            if (toBeString.length>12) {
                return NO;
            }
        }
        
    }
    
    if (textField == _registerTextFiled) {
        if (self.registerTypeBtn.tag == 20) {
           //手机注册
            if (toBeString.length>11) {
                return NO;
            }
        }else{
            if (toBeString.length>65) {
                return NO;
            }
        }
    }
    
    if (textField == _codeTextFiled) {
        if (toBeString.length>6) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark- LoginManagerDelegate
-(void)loginOut
{
    
}

-(void)loginFail:(JFGErrorType)error
{
    if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin ) {
         [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:error]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopLoginingAnimation];
    });
    
    loginState = LoginStateLoginFinished;
    self.pwTextFiled.enabled = YES;
    self.accountTextFiled.enabled = YES;
    self.lockBtn.userInteractionEnabled = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginTimeOut) object:nil];
}




-(void)loginSuccess
{
    //[[NSNotificationCenter defaultCenter]postNotificationName:LoginSuccessNotification object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loginTimeOut) object:nil];
    [self stopLoginingAnimation];
    loginState = LoginStateLoginFinished;
    self.pwTextFiled.enabled = YES;
    self.accountTextFiled.enabled = YES;
    self.lockBtn.userInteractionEnabled = YES;

    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if ([delegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JFGTabBarJumpVcKey object:[NSNumber numberWithInt:0]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [delegate goToJFGViewContrller];
    }
}


#pragma mark- --------------按钮事件-------------------
#pragma mark-
-(void)exitAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pageSwitchAction
{
    [self.view endEditing:YES];
    
    CGPoint point;
    if (self.bgScroller.contentOffset.x/self.view.width == 0) {
        
        point = CGPointMake(self.view.width, 0);
        [UIView animateWithDuration:0.5 animations:^{
            
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap0_register"];
            [self.pageSwitchBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
            
        }];
        
    }else{
        
        point = CGPointMake(0, 0);
        [UIView animateWithDuration:0.5 animations:^{
            self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LOGIN"];
            [self.pageSwitchBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_register"] forState:UIControlStateNormal];
        }];
    }
    
    //弹性动画
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    animation.toValue = [NSValue valueWithCGPoint:point];
    //速度
    animation.springSpeed = 10;
    //弹力
    animation.springBounciness = 8;
    //摩擦力
    //animation.dynamicsFriction = 15;
    //张力
   // animation.dynamicsTension = 85;

    [self.bgScroller pop_addAnimation:animation forKey:@"contentoffset"];
}


/**
 *  切换手机/邮箱注册
 */
-(void)registerTypeAction:(UIButton *)sender
{
    _registerTextFiled.text = @"";
    self.registerYDBtn.enabled = NO;
    
    if (self.codeBgView.left == self.view.width*2+10) {
        [self.registerBgView pulseViewWithTime:1];
        [self.registerYDBtn pulseViewWithTime:1];
    }
    
    
    if (sender.tag == 20) {
        //切换到邮箱注册
        sender.tag = 21;
        
        _registerTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
        
        [sender setTitle:[JfgLanguage getLanTextStrByKey:@"PHONE_SIGNUP"] forState:UIControlStateNormal];
        self.registerTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"EMAIL_1"];
        
        if (self.registerYDBtn.top == self.loginBtn.top) {
            
            [UIView animateWithDuration:1 animations:^{
                
                self.codeBgView.left = self.view.width*2+10;
                
            } completion:^(BOOL finished) {
                
                _codeTextFiled.text = @"";
                
            }];
            
            
            
            [UIView animateWithDuration:1 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                
                self.registerYDBtn.top = self.registerBgView.bottom+40;
                self.xieyiLabel.top = self.registerYDBtn.bottom+20;
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.xieyiLabel.alpha = 1;
                }];
                
            } completion:^(BOOL finished) {
                
            }];
            
        }
        self.registerYDBtn.tag = 123457;
        [UIView animateWithDuration:0.5 animations:^{
            [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"]forState:UIControlStateNormal];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateDisabled];
            }
            
        }];
    }else{
        sender.tag = 20;
        [sender setTitle:[JfgLanguage getLanTextStrByKey:@"EMAIL_SIGNUP"] forState:UIControlStateNormal];
        //切换手机注册
        self.registerTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"];
        _registerTextFiled.keyboardType = UIKeyboardTypeNumberPad;
        self.registerYDBtn.tag = 123456;
        [UIView animateWithDuration:0.5 animations:^{
            [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"GET_CODE"] forState:UIControlStateNormal];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"GET_CODE"] forState:UIControlStateDisabled];
            }
        }];
    }
}

//外国注册只是用邮箱注册
-(void)waiguoZhuCe
{
    self.registerTypeBtn.tag = 21;
    
    _registerTextFiled.keyboardType = UIKeyboardTypeEmailAddress;
    
    [self.registerTypeBtn setTitle:[JfgLanguage getLanTextStrByKey:@"PHONE_SIGNUP"] forState:UIControlStateNormal];
    self.registerTextFiled.placeholder = [JfgLanguage getLanTextStrByKey:@"EMAIL_1"];
    
    if (self.registerYDBtn.top == self.loginBtn.top) {
        self.codeBgView.left = self.view.width*2+10;
        _codeTextFiled.text = @"";
        self.registerYDBtn.top = self.registerBgView.bottom+40;
        self.xieyiLabel.top = self.registerYDBtn.bottom+20;
        self.xieyiLabel.alpha = 1;
    }
    self.registerYDBtn.tag = 123457;
    [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"]forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateDisabled];
    }
    
}

/**
 *  注册下一步引导按钮事件
 */
-(void)registerYDAction:(UIButton *)sender
{
   
    [self.view endEditing:YES];
    if (sender.tag == 123456) {
        if ([self.registerTextFiled.text isMobileNumber]){
            [self sendSMSWithPhoneNO:self.registerTextFiled.text];
        }else{
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"]];
        }
        
    }else{
        //继续
        if (self.registerTypeBtn.tag == 20) // 手机注册
        {
            if ([self.registerTextFiled.text isMobileNumber]) {
                
                if (self.codeTextFiled.text.length == 6) {
                    [JFGSDK verifySMSWithAccount:self.registerTextFiled.text code:self.codeTextFiled.text token:self.token];
                    [ProgressHUD showProgress:nil];
                }else{
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_ESMS_CODE_FALSE"]];
                }
                
               
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"]];
            }
            
            
        }
        else // 邮箱注册
        {
            
            //防止连续重复点击
            sender.userInteractionEnabled = NO;
            if ([self.registerTextFiled.text isEmail])
            {
                [ProgressHUD showProgress:nil];
                [JFGSDK checkIsRegisteredForAccount:self.registerTextFiled.text];
                
            }else{
                
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"EMAIL_2"]];
            }
            sender.userInteractionEnabled = YES;
        }
//        [JFGSDK userLogin:self.registerTextFiled.text keyword:@"" vid:company_vid vkey:company_vKey];
        
        
    }
}


/**
 *  协议
 */
-(void)readXieyi
{
    JFGHelpViewController * help = [[JFGHelpViewController alloc]init];
    help.showRightBarItem = NO;
    help.isXieyi = YES;
    help.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:help animated:YES];
}


//忘记密码
-(void)forgetPassword
{
    ForgetPasswordRootViewController *fp = [ForgetPasswordRootViewController new];
    fp.padding = self.accountTextFiled.text;
    if (self.navigationController) {
        [self.navigationController pushViewController:fp animated:YES];
    }else{
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:fp] animated:YES completion:nil];
    }
    
}

//登陆按钮事件
-(void)loginAction:(UIButton *)sender
{
    NSString *str = _accountTextFiled.text;
    if ([str isEmail] || [str isMobileNumber]) {
        
        
        if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        }else{
            [self startLoginingAnimation];
            loginState = LoginStateLogining;
            self.accountTextFiled.enabled = NO;
            self.pwTextFiled.enabled = NO;
            self.lockBtn.userInteractionEnabled = NO;
            
            [[LoginManager sharedManager] loginWithAccount:_accountTextFiled.text password:_pwTextFiled.text];
            
            //十秒超时处理
            [self performSelector:@selector(loginTimeOut) withObject:nil afterDelay:10];
        }
        
        
        
    }else{
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ACCOUNT_ERR_1"]];
        
    }
}

-(void)loginTimeOut
{
    if (loginState == LoginStateLogining) {
        
        [self stopLoginingAnimation];
        self.pwTextFiled.enabled = YES;
        self.accountTextFiled.enabled = YES;
        self.lockBtn.userInteractionEnabled = YES;
        loginState = LoginStateLoginFinished;
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LOGIN_ERR"]];
        
    }
}

-(void)qqLogin
{
    [self stopLoginingAnimation];
    loginState = LoginStateLogining;
    
    if ([JfgLanguage languageType] == 0) {
        
        if ([FLShareSDKHelper isInstalledQQ]) {
            [[LoginManager sharedManager] openLoginByQQ];
            [self performSelector:@selector(loginTimeOut) withObject:nil afterDelay:15];
        }else{
            [ProgressHUD showText:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],@"QQ"]];
            
        }
        
        
    }else{
        [[LoginManager sharedManager] openLoginByType:JFGSDKLoginTypeOpenLoginForTwitter];
        [self performSelector:@selector(loginTimeOut) withObject:nil afterDelay:15];
    }
    
    
}

-(void)weiboLogin
{
    loginState = LoginStateLogining;
    
    if ([JfgLanguage languageType] == 0) {
        [[LoginManager sharedManager] openLoginByweibo];
    }else{
        [[LoginManager sharedManager] openLoginByType:JFGSDKLoginTypeOpenLoginForFacebook];
    }
    
    [self performSelector:@selector(loginTimeOut) withObject:nil afterDelay:15];
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

//清除密码按钮
-(void)clearPwTextField
{
    if (!_pwTextFiled.isFirstResponder) {
        return;
    }
    self.pwTextFiled.text = @"";
}

//开始 登陆按钮动画
-(void)startLoginingAnimation
{
    self.loginBtn.userInteractionEnabled = NO;
    
    [PopAnimation startSpringAlphaAnimationForView:self.forgetPwBtn alpha:0];

    POPAnimatableProperty *properAnimation = [POPAnimatableProperty propertyWithName:@"xyscal" initializer:^(POPMutableAnimatableProperty *prop) {
        
        prop.readBlock = ^(id obj, CGFloat values[]){
            values[0] = [[obj description] floatValue];
            
        };
        
        prop.writeBlock = ^(id obj, const CGFloat values[]){
            
            UIButton *button = obj;
            
            //CGFloat maxX = CGRectGetMaxX(button.frame);
            CGFloat width = values[0];
            //CGFloat minX = maxX - width;
            
            if (width <= CGRectGetHeight(button.frame)+20) {
                [button setTitle:@" " forState:UIControlStateNormal];
            }
            CGFloat x = (self.view.width-width)*0.5;
            button.frame = CGRectMake(x, CGRectGetMinY(button.frame), width, CGRectGetHeight(button.frame));
            
        };
        prop.threshold = 0.1;
    }];
    
    
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animation];
    baseAnimation.property = properAnimation;
    baseAnimation.duration = 0.5;
    CGFloat width = CGRectGetWidth(self.loginBtn.frame);
    CGFloat heigth = CGRectGetHeight(self.loginBtn.frame);
    baseAnimation.fromValue =@(width);
    baseAnimation.toValue = @(heigth);
    baseAnimation.completionBlock = ^(POPAnimation *animation,BOOL finished){
      
        self.loginBtn.layer.borderColor = [UIColor clearColor].CGColor;
        [self.loginBtn setImage:[UIImage imageNamed:@"login_loading"] forState:UIControlStateNormal];
        [PopAnimation startRotationAnimationForView:self.loginBtn];
        [self.loginBtn pop_removeAnimationForKey:@"base"];
        
    };
    [self.loginBtn pop_addAnimation:baseAnimation forKey:@"base"];
}


//停止登陆按钮动画
-(void)stopLoginingAnimation
{
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [PopAnimation startSpringAlphaAnimationForView:self.forgetPwBtn alpha:1];
        [PopAnimation stopRotationAnimationForView:self.loginBtn];
        _loginBtn.transform = CGAffineTransformIdentity;
        _loginBtn.frame = CGRectMake(0, self.pwTFGbView.bottom+40, 360*0.5, 44);
        _loginBtn.x = self.view.x;
        [_loginBtn setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
        [self.loginBtn setImage:nil forState:UIControlStateNormal];
        self.loginBtn.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _loginBtn.userInteractionEnabled =  YES;
        
    });
    
   
}

#pragma mark JFG SDK action
- (void)sendSMSWithPhoneNO:(NSString *)phone
{
    [ProgressHUD showProgress:nil];
    [JFGSDK sendSMSWithPhoneNumber:phone type:smsCodeTypeRegister];
}

- (void)reSendSMS
{
    [self sendSMSWithPhoneNO:self.registerTextFiled.text];
}

#pragma mark JFG SDK Delegate
-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeIsRegistered) {
        if (errorType == 0) {
            //账号已经注册
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:JFGErrorTypeAccountAlreadyExist]];
        }else{
            NewPasswordViewController *newP = [[NewPasswordViewController alloc]init];
            newP.type = SetPasswordTypeInitializePassword;
            newP.registerType = registerTypeEmail;
            newP.accountStr = self.registerTextFiled.text;
            newP.registerToken = self.token;
            [self.navigationController pushViewController:newP animated:YES];
        }
    }
}


- (void)jfgSendSMSResult:(JFGErrorType)errorType token:(NSString *)token
{
    
    if (errorType == JFGErrorTypeNone) {
        self.token = token;
        
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Contacts_Sent"]];
        
        _registerYDBtn.tag = 123457;
        _registerYDBtn.enabled = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.registerYDBtn.top = self.loginBtn.top;
            self.xieyiLabel.top = self.forgetPwBtn.top;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.xieyiLabel.alpha = 0;
            }];
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 animations:^{
                [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateNormal];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                    [self.registerYDBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] forState:UIControlStateDisabled];
                }
            }];
            
        }];
        
        [self.secondBtn startKeepTime];
        
        [UIView animateWithDuration:1 delay:0.2 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.codeBgView.left = self.pwTFGbView.left+self.view.width;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        
        if (errorType == 192) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GetCode_FrequentlyTips"]];
        }else{
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
        }
        
    }
    
}

-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist
{
    if ([account isEqualToString:self.registerTextFiled.text]) {
        if (isExist) {
            
            [ProgressHUD dismiss];
            NewPasswordViewController *newP = [[NewPasswordViewController alloc]init];
            newP.type = SetPasswordTypeInitializePassword;
            newP.registerType = registerTypeEmail;
            newP.accountStr = self.registerTextFiled.text;
            newP.registerToken = self.token;
            [self.navigationController pushViewController:newP animated:YES];
            
        }else{
            
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:JFGErrorTypeAccountNotExist]];
        }
    }
}

-(void)jfgVerifySMSResult:(JFGErrorType)errorType
{
    
    if (errorType == JFGErrorTypeNone) {
        [ProgressHUD dismiss];
        NewPasswordViewController *newP = [[NewPasswordViewController alloc]init];
        newP.type = SetPasswordTypeInitializePassword;
        newP.registerType = registerTypePhone;
        newP.accountStr = self.registerTextFiled.text;
        newP.registerToken = self.token;
        [self.navigationController pushViewController:newP animated:YES];
    }else{
        [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:errorType]];
    }
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
