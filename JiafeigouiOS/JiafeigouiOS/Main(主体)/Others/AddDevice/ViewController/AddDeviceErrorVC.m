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

@interface AddDeviceErrorVC()

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *reTryButton;

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
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        for (UIViewController *temp in self.navigationController.viewControllers)
        {
            if ([temp isKindOfClass:[AddDeviceGuideViewController class]])
            {
                [self.navigationController popToViewController:temp animated:YES];
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
        CGFloat widgetX = 0;
        CGFloat widgetY = 215.0f;
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 22.f;
        
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_NETWORK_2"];
        _errorLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _errorLabel.font = [UIFont systemFontOfSize:widgetHeight];
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
        _reTryButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _reTryButton.isRelatingNetwork = YES;
        [_reTryButton addTarget:self action:@selector(reTryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _reTryButton;
}

@end
