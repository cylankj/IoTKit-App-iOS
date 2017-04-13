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
#import "LoginManager.h"

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
    // Do any additional setup after loading the view.
}

-(void)registerButtonAction
{
    LoginRegisterViewController *loginRegisterVC = [[LoginRegisterViewController alloc]init];
    loginRegisterVC.viewType = FristIntoViewTypeRegister;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginRegisterVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)LoginAction
{
    LoginRegisterViewController *loginRegisterVC = [[LoginRegisterViewController alloc]init];
    loginRegisterVC.viewType = FristIntoViewTypeLogin;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginRegisterVC];
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
