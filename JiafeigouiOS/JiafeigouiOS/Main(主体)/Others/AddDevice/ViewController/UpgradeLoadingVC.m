//
//  UpgradeLoadingVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UpgradeLoadingVC.h"
#import <JFGSDK/JFGSDK.h>
#import "BindProgressAnimationView.h"
#import "LSAlertView.h"
#import "UpgradeResultVC.h"
#import "JfgGlobal.h"

@interface UpgradeLoadingVC ()<JFGSDKCallbackDelegate>

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *uLtitleLabel;
@property (nonatomic, strong) UILabel *upgradingLabel;
@property (nonatomic, strong) BindProgressAnimationView *aniView;

//@property (nonatomic, strong) JFGSDK 

@end

@implementation UpgradeLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    
    [self upgradeBegining];
}

- (void)initView
{
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.aniView];
    [self.view addSubview:self.uLtitleLabel];
    [self.view addSubview:self.upgradingLabel];
    
    [JFGSDK addDelegate:self];
}

- (void)initNavigation
{
    // 顶部 导航设置
    self.navigationView.hidden = YES;
    
}

- (void)upgradeBegining
{
    [JFGSDK deviceUpgreadeForIp:self.ipAddr url:self.destnationPath cid:self.cid];
    [self.aniView starAnimation];
}

#pragma mark delegate
-(void)jfgDevUpgradeInfo:(JFGSDKDeviceUpgrade *)info
{
    if ([self.cid isEqualToString:info.cid])
    {
        if (info.ret == 0)
        {
            [self.aniView successAnimationWithCompletionBlock:^{
                [self pushToResult];
            }];
        }
        else
        {
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"UPDATE_FAIL"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                [self.aniView stopShake];
            } OKBlock:^{
                [self upgradeBegining];
            }];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action


- (void)pushToResult
{
    UpgradeResultVC *upgradeResult = [UpgradeResultVC new];
    [self.navigationController pushViewController:upgradeResult animated:YES];
}

#pragma mark
#pragma mark  property

- (BindProgressAnimationView *)aniView
{
    if (_aniView == nil)
    {
        _aniView = [[BindProgressAnimationView alloc] initWithFrame:CGRectMake(0, kheight*0.32-72, 0, 0)];
        _aniView.x = self.view.x;
    }
    return _aniView;
}

- (UILabel *)upgradingLabel
{
    if (_upgradingLabel == nil)
    {
        CGFloat fontSize = 16.0f;
        _upgradingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.aniView.bottom - 10.0f, Kwidth, fontSize)];
        _upgradingLabel.text = [JfgLanguage getLanTextStrByKey:@"UPDATING_BUTTON"];
        _upgradingLabel.textAlignment = NSTextAlignmentCenter;
        _upgradingLabel.font = [UIFont systemFontOfSize:fontSize];
        _upgradingLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        
    }
    
    return _upgradingLabel;
}

- (UILabel *)uLtitleLabel
{
    if (_uLtitleLabel == nil)
    {
        _uLtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, Kwidth - 60*2, 44)];
        _uLtitleLabel.text = [JfgLanguage getLanTextStrByKey:@"DEVICE_UPGRADE"];
        _uLtitleLabel.font = [UIFont systemFontOfSize:17.0f];
        _uLtitleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _uLtitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    
    return _uLtitleLabel;
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, (44-30)/2.0 + 20, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


@end
