//
//  UpgradeResultVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/12/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UpgradeResultVC.h"
#import "UIColor+HexColor.h"
#import "JfgGlobal.h"

@interface UpgradeResultVC ()

@property (nonatomic, strong) UILabel *successLabel;

@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation UpgradeResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark  view
- (void)initView
{
    self.navigationView.hidden = YES;
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.successLabel];
    [self.view addSubview:self.finishButton];
}

#pragma mark
#pragma mark  action
- (void)finishButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark 
#pragma mark  property
- (UILabel *)successLabel
{
    if (_successLabel == nil)
    {
        CGFloat font = 22.0f;
        
        _successLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 215.0f, Kwidth, font)];
        _successLabel.font = [UIFont systemFontOfSize:font];
        _successLabel.textAlignment = NSTextAlignmentCenter;
        _successLabel.text = [JfgLanguage getLanTextStrByKey:@"设备软件更新完成"];
        _successLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    
    return _successLabel;
}


-(UIButton *)finishButton
{
    if (_finishButton == nil)
    {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.frame = CGRectMake(0, self.successLabel.bottom+40, 360*0.5, 44);
        _finishButton.layer.masksToBounds = YES;
        _finishButton.x = self.view.x;
        _finishButton.layer.cornerRadius = 22;
        _finishButton.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _finishButton.layer.borderWidth = 1;
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_finishButton setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UIButton *)backButton
{
    if (_backButton == nil)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(10, 37, 30, 30);
        [_backButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backButton;
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
