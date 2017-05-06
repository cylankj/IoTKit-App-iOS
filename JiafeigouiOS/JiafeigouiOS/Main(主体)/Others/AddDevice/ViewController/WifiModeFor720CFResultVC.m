//
//  WifiModeFor720CFResultVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "WifiModeFor720CFResultVC.h"
#import "CommonMethod.h"
#import "DelButton.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "VideoPlayFor720ViewController.h"


@interface WifiModeFor720CFResultVC ()

@property(nonatomic,strong)DelButton * exitBtn;
@property(nonatomic,strong)UIImageView *tipImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIButton *lookBtn;

@end

@implementation WifiModeFor720CFResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.tipImageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.lookBtn];
    // Do any additional setup after loading the view.
}

-(void)exitAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)lookAction
{
    NSArray *vcArr = self.navigationController.viewControllers;
    for (UIViewController *vc in vcArr) {
        
        if ([vc isKindOfClass:[VideoPlayFor720ViewController class]]) {
            
            [self.navigationController popToViewController:vc animated:YES];
            return;
            
        }
        
    }
}

-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc]initWithImage:self.isAPModeFinished?[UIImage imageNamed:@"pic_ap_finish"]:[UIImage imageNamed:@"pic_home_finish_model"]];
        _tipImageView.top = self.view.height*0.3;
        _tipImageView.x = self.view.x;
    }
    return _tipImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.tipImageView.bottom + 27, self.view.width, 18)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        if (self.isAPModeFinished) {
            _titleLabel.text = @"户外模式已开启";
        }else{
            _titleLabel.text = @"家居模式已开启";
        }
    }
    return _titleLabel;
}

-(UIButton *)lookBtn
{
    if (!_lookBtn) {
        _lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lookBtn.frame = CGRectMake(0, self.titleLabel.bottom+self.view.height*0.12, 360*0.5, 44);
        _lookBtn.x = self.view.x;
        _lookBtn.layer.masksToBounds = YES;
        _lookBtn.layer.cornerRadius = 22;
        _lookBtn.layer.borderWidth = 1;
        _lookBtn.layer.borderColor = [UIColor colorWithHexString:@"#d8d8d8"].CGColor;
        _lookBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_lookBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_lookBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_BELL_LOOK"] forState:UIControlStateNormal];
        [_lookBtn addTarget:self action:@selector(lookAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lookBtn;
}

-(DelButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(10, 37, 10, 18);
        [_exitBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
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
