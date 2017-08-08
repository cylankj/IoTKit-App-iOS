//
//  LoginLoadingViewController.m
//  卡片动画
//
//  Created by 杨利 on 16/8/24.
//  Copyright © 2016年 KuBao. All rights reserved.
//

#import "LoginLoadingViewController.h"
#import "UIColor+HexColor.h"
#import "LoginRegisterViewController.h"
#import "AppDelegate.h"
#import "JfgLanguage.h"
#import "UIAlertView+FLExtension.h"
#import "OemManager.h"
#import "JfgUserDefaultKey.h"
#import "LoginManager.h"
#import "BaseNavgationViewController.h"

@interface LoginLoadingViewController ()

@property (nonatomic,strong)UIImageView *topImageView;
@property (nonatomic,strong)UIImageView *wzImageView;
@property (nonatomic,strong)UIButton *loginButton;
@property (nonatomic,strong)UIButton *registerButton;
@property (nonatomic,strong)UIButton *anylookButton;

@end

@implementation LoginLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topImageView];
    [self.view addSubview:self.wzImageView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.anylookButton];
    //进入欢迎页，此时必须处于退出登录状态
    [LoginManager sharedManager].loginStatus = JFGSDKCurrentLoginStatusLoginOut;
    //[self interfaceOrientation:UIInterfaceOrientationPortrait];
    // Do any additional setup after loading the view.
    
    
    
#ifdef DEBUG
    [self addChangeIpGesture];
#else
    NSString *ipAddressString = [[[NSBundle mainBundle] infoDictionary] objectForKey:domainKey];
    if (![ipAddressString hasPrefix:@"yun.jfgou.com"])
    {
        [self addChangeIpGesture];
    }
#endif
}

//强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark
#pragma mark  ---- 切换平台 手势---------
- (void)addChangeIpGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeServerAddress:)];
    tapGesture.numberOfTapsRequired = 10;
    tapGesture.numberOfTouchesRequired = 1;
    [self.topImageView addGestureRecognizer:tapGesture];
    self.topImageView.userInteractionEnabled = YES;
}

- (void)changeServerAddress:(UITapGestureRecognizer *)gesture
{
//    NSString *domainURLString = [[NSUserDefaults standardUserDefaults] objectForKey:jfgDomianURL];
    UIAlertView *changeIpAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"更改ip地址及端口号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更改", nil];
    changeIpAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *ipTextField = [changeIpAlertView textFieldAtIndex:0];
    ipTextField.placeholder = @"eg: yun.jfgou.com:443";
    ipTextField.text = [NSString stringWithFormat:@"%@:%@",[OemManager getdomainURLString],[OemManager getPort]];
//    UITextField *portTextField = [changeIpAlertView textFieldAtIndex:1];
//    portTextField.placeholder = @"请输入端口号，若不变可不输";
//    portTextField.text = [NSString stringWithFormat:@"%@",[serverInfo objectForKey:@"port"]];
//    portTextField.secureTextEntry = NO;
    [changeIpAlertView showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
        
        if (buttonIndex == 1)
        {
            NSString *newDomainURL = [ipTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (![newDomainURL isEqualToString:@""] && newDomainURL != nil)
            {
                [[NSUserDefaults standardUserDefaults] setObject:newDomainURL forKey:jfgDomianURL];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }
        
        
    } otherDelegate:nil];
    
}

#pragma mark
#pragma mark  getter

-(void)registerButtonAction
{
    LoginRegisterViewController *loginRegisterVC = [[LoginRegisterViewController alloc]init];
    loginRegisterVC.viewType = FristIntoViewTypeRegister;
    BaseNavgationViewController*nav = [[BaseNavgationViewController alloc]initWithRootViewController:loginRegisterVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)LoginAction
{
    LoginRegisterViewController *loginRegisterVC = [[LoginRegisterViewController alloc]init];
    loginRegisterVC.viewType = FristIntoViewTypeLogin;
    BaseNavgationViewController *nav = [[BaseNavgationViewController alloc]initWithRootViewController:loginRegisterVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];

}

-(void)enterButtonAction
{
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate goToJFGViewContrller];
}


-(UIButton *)anylookButton
{
    if (!_anylookButton) {
        
        _anylookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _anylookButton.frame = CGRectMake(self.loginButton.frame.origin.x, CGRectGetMaxY(self.registerButton.frame)+0.03*self.view.bounds.size.height, self.loginButton.frame.size.width, 15);
        [_anylookButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_WelcomeTourist"] forState:UIControlStateNormal];
        [_anylookButton setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateNormal];
        _anylookButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_anylookButton addTarget:self action:@selector(enterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _anylookButton;
}

-(UIButton *)registerButton
{
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame = CGRectMake(self.loginButton.frame.origin.x, CGRectGetMaxY(self.loginButton.frame)+14, self.loginButton.bounds.size.width, self.loginButton.bounds.size.height);
        _registerButton.layer.masksToBounds = YES;
        _registerButton.layer.cornerRadius = self.loginButton.bounds.size.height*0.5;
        _registerButton.backgroundColor = [UIColor colorWithHexString:@"#f2f1f1"];;
        [_registerButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_register"] forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _registerButton;
}

-(UIButton *)loginButton
{
    if (!_loginButton) {
        _loginButton =[UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = self.topImageView.bounds.size.width;
        CGFloat height = 0.15*width;
        CGFloat y = self.view.bounds.size.height*0.14+CGRectGetMaxY(self.wzImageView.frame);
        
        if (self.view.bounds.size.height<600) {
            y = self.view.bounds.size.height*0.1+CGRectGetMaxY(self.wzImageView.frame);
        }
        
        CGFloat x = self.topImageView.frame.origin.x;
        _loginButton.frame= CGRectMake(x, y, width, height);
        _loginButton.layer.masksToBounds = YES;
        _loginButton.layer.cornerRadius = height*0.5;
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"#4b9fd5"];
        [_loginButton setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_loginButton addTarget:self action:@selector(LoginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

-(UIImageView *)wzImageView
{
    if (!_wzImageView) {
        
        
        UIImage *image = [UIImage imageNamed:@"sign-in_soglan"];
        
        if ([JfgLanguage languageType] !=0) {
            image = [UIImage imageNamed:@"sign-in_soglan_eg"];
        }
        //350   51
        CGFloat top = CGRectGetMaxY(self.topImageView.frame)+self.view.bounds.size.height*0.03;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-350*0.5)*0.5, top, 350*0.5, 25.5)];
        imageView.image = image;
        _wzImageView = imageView;
    }
    return _wzImageView;
}

-(UIImageView *)topImageView
{
    if (_topImageView == nil) {
        
        CGFloat imageWith = self.view.bounds.size.width*0.75;
        UIImage *image = [UIImage imageNamed:@"pic_sign-in"];
        
        CGFloat scale = image.size.height/image.size.width;
        CGFloat imageHeight = imageWith*scale;
        
        /**
         *  568 480
         */
        CGFloat y = self.view.bounds.size.height * 0.2;
        
        if (self.view.bounds.size.height<600) {
            y = self.view.bounds.size.height * 0.15;
        }
        
        CGFloat x = (self.view.bounds.size.width-imageWith)*0.5;
        _topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, imageWith, imageHeight)];
        _topImageView.image = image;
        
    }
    return _topImageView;
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
