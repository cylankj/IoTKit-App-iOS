//
//  GuideViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/5/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "GuideViewController.h"
#import "FLGlobal.h"
#import "JiafeigouRootViewController.h"
#import "MineRootViewController.h"
#import "ExploreRootViewController.h"
#import "AppDelegate.h"
#import "LoginRegisterViewController.h"
#import <Masonry.h>
#import "JfgLanguage.h"
@interface GuideViewController ()

@end

@implementation GuideViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    guideScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    guideScrollView.delegate = self;
    [self.view addSubview:guideScrollView];
  
    //4个引导页+1个欢迎页的大小
    guideScrollView.contentSize = CGSizeMake(Kwidth*5,kheight);
    
    //显示页码
    guideScrollView.pagingEnabled = YES;
    
    //隐藏滚动条
    guideScrollView.showsVerticalScrollIndicator = NO;
    guideScrollView.showsHorizontalScrollIndicator = NO;
    
    //取消弹簧效果
    guideScrollView.bounces = NO;
    
    //放图片
    for (int i=1; i<=5; i++)
    {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(Kwidth*(i-1), 0, Kwidth, kheight)];
        
        if (i==5)
        {
            //最后的欢迎页
            imageView.image = [UIImage imageNamed:@"guide1"];
        }
        else
        {
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide%d",i]];
        }
        [guideScrollView addSubview:imageView];
    }
    
    //按钮
    UIImage * buttonImage = [UIImage imageNamed:@"login_button"];
    
    //注册
    UIButton * registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [registerButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_register"] forState:UIControlStateNormal];
    [registerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:36];
    [guideScrollView addSubview:registerButton];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(guideScrollView).with.offset(Kwidth*4-80);
        make.bottom.equalTo(self.view).with.offset(-80.0f);
    }];
    
    //登录
    UIButton * loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [loginButton setTitle:[JfgLanguage getLanTextStrByKey:@"LOGIN"] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:36];
    [loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [guideScrollView addSubview:loginButton];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(guideScrollView).with.offset(Kwidth*4.5-80);
        make.bottom.equalTo(self.view).with.offset(-80.0f);
    }];
    
    //立即进入
    UIButton * enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [enterButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap0_WelcomeTourist"] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    enterButton.titleLabel.font = [UIFont systemFontOfSize:36];
    [enterButton addTarget:self action:@selector(enterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [guideScrollView addSubview:enterButton];
    
    [enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(guideScrollView).with.offset(4*Kwidth);
        make.bottom.equalTo(self.view).with.offset(-20.0f);
    }];

    //页码
    pageController = [[UIPageControl alloc]init];
    
    pageController.numberOfPages = 4;
    
    pageController.pageIndicatorTintColor = [UIColor lightGrayColor];
    
    [pageController addTarget:self action:@selector(touchPage:) forControlEvents:UIControlEventValueChanged];
    
    [guideScrollView addSubview:pageController];
    
    //约束
    [pageController mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-83);
        make.centerX.equalTo(self.view);
    }];
    
    //是否是第一次登录或者新版本
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"OLD_VERSION"]==nil || [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] != [userDefault objectForKey:@"OLD_VERSION"])
    {
        //先显示引导页
        [self showGuideView];
    }else{
        //不显示引导页,直接显示欢迎页面
        [self showWelcomeView];
    }
}
-(void)showGuideView
{
    guideScrollView.contentOffset = CGPointMake(0, 0);
    
    //首次运行标记
    [[NSUserDefaults standardUserDefaults]setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"OLD_VERSION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)showWelcomeView
{
    guideScrollView.contentOffset = CGPointMake(Kwidth*4, 0);
    
    //不显示页码
    pageController.hidden = YES;
    
    //不能滚动
    guideScrollView.scrollEnabled = NO;
}
#pragma mark UIButton Action
-(void)registerButtonAction
{
    LoginRegisterViewController *loginRegisterVC = [[LoginRegisterViewController alloc]init];
    loginRegisterVC.viewType = FristIntoViewTypeRegister;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginRegisterVC];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)loginButtonAction
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
#pragma mark UIPageControl TouchAction
-(void)touchPage:(UIPageControl *)page
{
    guideScrollView.contentOffset = CGPointMake(page.currentPage*Kwidth, 0);
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //导航页结束,到欢迎页,不需要pageController
    if (scrollView.contentOffset.x>Kwidth*3)
    {

        pageController.hidden = YES;
    }
    else
    {
        pageController.hidden = NO;
        
        pageController.currentPage = guideScrollView.contentOffset.x/Kwidth;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
