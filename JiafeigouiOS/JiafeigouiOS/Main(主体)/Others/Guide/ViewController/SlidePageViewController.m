//
//  SlidePageViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "SlidePageViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"
#import "SMPageControl.h"
#import "LoginLoadingViewController.h"
#import "LoginManager.h"
#import "AppDelegate.h"

@interface SlidePageViewController ()<UIScrollViewDelegate>
{
    SMPageControl *SMpage;
}
@property (nonatomic,strong)UIScrollView *bgScrollerView;
@property (nonatomic,strong)UIImageView *currentPageView;

@end

@implementation SlidePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > self.view.width*2) {
        [self gotoLoginLoadingView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/self.view.width;
    CGFloat leftcenter = self.view.width*0.5-28.5;
    leftcenter = leftcenter+page*33;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currentPageView.x = leftcenter;
    }];
}

-(void)pageAction:(UIButton *)btn
{
    CGFloat leftcenter = self.view.width*0.5-28.5;
    leftcenter = leftcenter+(btn.tag - 2000)*33;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currentPageView.x = leftcenter;
        self.bgScrollerView.contentOffset = CGPointMake((btn.tag - 2000)*self.view.bounds.size.width, 0);
    }];
}

-(void)gotoLoginLoadingView
{
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"ICAM_CURRENT_ACCOUNT"];
    NSString *pw = [[NSUserDefaults standardUserDefaults] objectForKey:@"ICAM_PASSWORD_SHOW"];
    if ([LoginManager sharedManager].currentLoginedAcount && ![[LoginManager sharedManager] isExited])
    {
        //已经登录过,跳转到加菲狗主页
        [[LoginManager sharedManager] loginForLastTimeAccount];
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate goToJFGViewContrller];
        
    }else if (account && [account isKindOfClass:[NSString class]] && pw && [pw isKindOfClass:[NSString class]] && ![account isEqualToString:@""]){
        
        //使用2.0账号登录,跳转到加菲狗主页
        [[LoginManager sharedManager] loginForLastTimeAccount];
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate goToJFGViewContrller];
        
    }else{
        //未登录,跳转到欢迎页
        //        LoginLoadingViewController *lo = [LoginLoadingViewController new];
        //        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:lo];
        //        self.window.rootViewController = nav;
        LoginLoadingViewController *login = [LoginLoadingViewController new];
        login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //login.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:login animated:YES completion:nil];
    }
    
}


-(void)initView
{
    [self.view addSubview:self.bgScrollerView];
    NSMutableArray *images = nil;
    if (self.view.bounds.size.height == 480) {
        
        if ([JfgLanguage languageType] == 0) {
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_640_960_1_ch",@"guide_pages_640_960_2_ch",@"guide_pages_640_960_3_ch", nil];
        }else{
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_640_960_1_en",@"guide_pages_640_960_2_en",@"guide_pages_640_960_3_en", nil];
        }
        
        
    }else if (self.view.bounds.size.height == 568){
        if ([JfgLanguage languageType] == 0) {
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_640_1136_1_ch",@"guide_pages_640_1136_2_ch",@"guide_pages_640_1136_3_ch", nil];
        }else{
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_640_1136_1_en",@"guide_pages_640_1136_2_en",@"guide_pages_640_1136_3_en", nil];
        }
    }else{
        if ([JfgLanguage languageType] == 0) {
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_750_1334_1_ch",@"guide_pages_750_1334_2_ch",@"guide_pages_750_1334_3_ch", nil];
        }else{
            images = [[NSMutableArray alloc]initWithObjects:@"guide_pages_750_1334_1_en",@"guide_pages_750_1334_2_en",@"guide_pages_750_1334_3_en", nil];
        }
    }
    
    int i=0;
    for (NSString *imageName in images) {
        
        UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        imageview.frame = CGRectMake(i*self.bgScrollerView.width, 0, self.bgScrollerView.width, self.bgScrollerView.height);
        imageview.userInteractionEnabled = YES;
        [self.bgScrollerView addSubview:imageview];
        i++;
    }
    [self initPageControl];
}

-(void)initPageControl
{
    CGFloat leftcenter = self.view.width*0.5-28.5;
    for (int i=0; i<3; i++) {
        
        UIButton *page = [UIButton buttonWithType:UIButtonTypeCustom];
        page.frame = CGRectMake(0, 0, 9, 9);
        page.x = leftcenter+i*33;
        page.bottom = self.view.height * (1-0.056);
        [page setImage:[UIImage imageNamed:@"guide_pages_point_two"] forState:UIControlStateNormal];
        page.tag = 2000+i;
        page.showsTouchWhenHighlighted = NO;
        [page addTarget:self action:@selector(pageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:page];
        
    }
    self.currentPageView.frame = CGRectMake(0, 0, 36*0.5, 18*0.5);
    self.currentPageView.x = leftcenter;
    self.currentPageView.bottom = self.view.height * (1-0.056);
    [self.view addSubview:self.currentPageView];
    
}

-(UIScrollView *)bgScrollerView
{
    if (_bgScrollerView == nil) {
        _bgScrollerView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _bgScrollerView.contentSize = CGSizeMake(self.view.bounds.size.width*3+5, 0);
        _bgScrollerView.pagingEnabled = YES;
        _bgScrollerView.showsHorizontalScrollIndicator = NO;
        _bgScrollerView.showsVerticalScrollIndicator = NO;
        _bgScrollerView.delegate = self;
        _bgScrollerView.bounces = NO;
        _bgScrollerView.backgroundColor = [UIColor whiteColor];
    }
    return _bgScrollerView;
}


-(UIImageView *)currentPageView
{
    if (!_currentPageView) {
        _currentPageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"guide_pages_point_one"]];
    }
    return _currentPageView;
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
