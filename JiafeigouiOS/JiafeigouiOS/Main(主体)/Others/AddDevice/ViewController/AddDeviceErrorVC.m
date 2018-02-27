//
//  AddDeviceErrorVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddDeviceErrorVC.h"
#import "AddDeviceGuideViewController.h"
#import "JfgGlobal.h"
#import "UIButton+Addition.h"
#import "PilotLampStateVC.h"
#import "VideoPlayFor720ViewController.h"
#import "AddDeviceMainViewController.h"

@interface AddDeviceErrorVC()

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *reTryButton;
@property (nonatomic,strong) UIButton *declareBtn;
@property (nonatomic,strong) UIButton *backBtn;

@end

@implementation AddDeviceErrorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initNavigationView];
}

- (void)initView
{
    [self.view addSubview:self.errorLabel];
    [self.view addSubview:self.reTryButton];
    if (self.pType == productType_720) {
        [self.view addSubview:self.declareBtn];
        [self.view addSubview:self.backBtn];
    }
    self.errorLabel.text = [self errorStringWithErrorType:self.errorType];
}

- (void)initNavigationView
{
    self.navigationView.hidden = YES;
    [self.leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark action
- (void)reTryButtonAction
{
    if (self.errorType == BindResultType_Success)
    {
        if (self.navigationController) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        
        BOOL isAlwaysJumped = NO;
        for (UIViewController *temp in self.navigationController.viewControllers)
        {
            if ([temp isKindOfClass:[AddDeviceGuideViewController class]])
            {
                [self.navigationController popToViewController:temp animated:YES];
                isAlwaysJumped = YES;
                break;
            }
        }
        if (!isAlwaysJumped) {
            if (self.navigationController) {
                for (UIViewController *temp in self.navigationController.viewControllers)
                {
                    if ([temp isKindOfClass:[AddDeviceMainViewController class]] || [temp isKindOfClass:[VideoPlayFor720ViewController class]])
                    {
                        [self.navigationController popToViewController:temp animated:YES];
                        return ;
                    }
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (NSString *)errorStringWithErrorType:(int)errorType
{
    NSString *resultStr = @"";
    
    switch (errorType)
    {
        case BindResultType_Success:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"Added_successfully"];
        }
            break;
        case BindResultType_CidNotExist:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"RET_EBINDCID_NOT_EXIST"];
        }
            break;
        case BindResultType_Timeout:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips5"];
        }
            break;
        case BindResultType_AlwaysBinded:{
            
            NSString *str = [JfgLanguage getLanTextStrByKey:@"OTHER_TIME"];
            if ([self.errorMsg isKindOfClass:[NSString class]]) {
                str = self.errorMsg;
            }
            
            str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MSG_REBIND"],str];
            resultStr = str;
            
            //MSG_REBIND
        }
            break;
        default:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"NO_NETWORK_2"];
        }
            break;
    }
    return resultStr;
}

#pragma mark property
- (UILabel *)errorLabel
{
    if (_errorLabel == nil)
    {
        CGFloat widgetX = 10;
        CGFloat widgetY = 190.0f;
        CGFloat widgetWidth = Kwidth-20;
        CGFloat widgetHeight = 50.f;
        
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _errorLabel.numberOfLines = 0;
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_NETWORK_2"];
        _errorLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _errorLabel.font = [UIFont systemFontOfSize:20];
    }
    return _errorLabel;
}

- (UIButton *)reTryButton
{
    if (_reTryButton == nil)
    {
        CGFloat widgetWidth = 180.0f;
        CGFloat widgetHeight = 44.0f;
        CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
        CGFloat widgetY = self.errorLabel.bottom + 40.0f;
        
        
        _reTryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reTryButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        _reTryButton.layer.masksToBounds = YES;
        _reTryButton.layer.cornerRadius = 22;
        _reTryButton.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        _reTryButton.layer.borderWidth = 1;
        [_reTryButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_reTryButton setTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] forState:UIControlStateNormal];
        if (self.errorType == BindResultType_AlwaysBinded) {
            [_reTryButton setTitle:[JfgLanguage getLanTextStrByKey:@"WELL_OK"] forState:UIControlStateNormal];
        }
        _reTryButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _reTryButton.isRelatingNetwork = NO;
        [_reTryButton addTarget:self action:@selector(reTryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _reTryButton;
}

-(UIButton *)declareBtn
{
    if (!_declareBtn) {
        _declareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _declareBtn.frame = CGRectMake(self.view.width-15-25, 40, 25, 25);
        [_declareBtn setImage:[UIImage imageNamed:@"icon_explain_gray"] forState:UIControlStateNormal];
        [_declareBtn addTarget:self action:@selector(intoVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _declareBtn;
}

-(void)intoVC
{
    PilotLampStateVC *lampVC = [PilotLampStateVC new];
    [self presentViewController:lampVC animated:YES completion:nil];
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 37, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"btn_return"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(void)backAction
{
    [self reTryButtonAction];
}

@end
