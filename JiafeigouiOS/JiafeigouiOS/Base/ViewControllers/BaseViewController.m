//
//  BaseViewController.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "JfgGlobal.h"
#import <Masonry.h>
@interface BaseViewController ()

@property (nonatomic,strong)CAGradientLayer *dayGradient;
@property (nonatomic,strong)CAGradientLayer *nightGradient;

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBaseView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationViewColor:[self isDayLight]];
}

#pragma mark view
- (void)initBaseView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.view.mas_top);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.equalTo(@64);
    }];
    [self.navigationView layoutIfNeeded];
    [self.navigationView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.navigationView.mas_left).offset(0);
        make.centerY.mas_equalTo(self.navigationView.mas_bottom).offset(-22);
        make.height.greaterThanOrEqualTo(@50);
        make.width.greaterThanOrEqualTo(@50);
    }];
    [self.navigationView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.mas_equalTo(self.navigationView.mas_bottom).offset(-22);
        make.centerX.mas_equalTo(self.navigationView.mas_centerX);
        make.height.equalTo(@17);
        make.width.mas_equalTo(self.navigationView.mas_width).offset(-100);
    }];
    [self.navigationView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.navigationView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.height.greaterThanOrEqualTo(@15);
        make.width.greaterThanOrEqualTo(@15);
    }];
    // 设置 导航条背景 渐变色
    [self setNavigationViewColor:[self isDayLight]];

}

- (void)setLeftButtonImage:(UIImage *)btnImage title:(NSString *)btnTitle font:(UIFont *)font
{
    if (btnImage != nil)
    {
        [self.leftButton setImage:btnImage forState:UIControlStateNormal];
        return;
    }
    
    if (![btnTitle isEqualToString:@""] && btnTitle == nil)
    {
        [self.leftButton setImage:nil forState:UIControlStateNormal];
        [self.leftButton setTitle:btnTitle forState:UIControlStateNormal];
        [self.leftButton.titleLabel setFont:font];
        
//        CGSize labelSize = CGSizeOfString(self.leftButton.titleLabel.text, CGSizeMake(Kwidth, self.leftButton.height), [UIFont systemFontOfSize:self.leftButton.titleLabel.font.pointSize]);
//        self.leftButton.frame = CGRectMake(self.leftButton.left, self.leftButton.top, labelSize.width, self.leftButton.height);
    }
}

- (void)setRightButtonImage:(UIImage *)btnImage title:(NSString *)btnTitle font:(UIFont *)font
{
    if (btnImage != nil)
    {
        [self.rightButton setImage:btnImage forState:UIControlStateNormal];
        return;
    }
    
    if (![btnTitle isEqualToString:@""] && btnTitle != nil)
    {
        [self.rightButton setImage:nil forState:UIControlStateNormal];
        [self.rightButton setTitle:btnTitle forState:UIControlStateNormal];
        [self.rightButton.titleLabel setFont:font];
//        CGSize labelSize = CGSizeOfString(self.rightButton.titleLabel.text, CGSizeMake(Kwidth, self.rightButton.height), [UIFont systemFontOfSize:self.rightButton.titleLabel.font.pointSize]);
//        self.rightButton.frame = CGRectMake(Kwidth-labelSize.width-5, self.rightButton.top, labelSize.width, self.rightButton.height);
    }
}

#pragma mark setter

- (UIView *)navigationView
{
    if (_navigationView == nil)
    {
        _navigationView = [[UIView alloc] init];
    }
    return _navigationView;
}

- (UIButton *)leftButton
{
    if (_leftButton == nil)
    {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
    }
    
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (_rightButton == nil)
    {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.hidden = YES;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_rightButton setImage:[UIImage imageNamed:@"camera_ico_install"] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
    }
    
    return _rightButton;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    return _titleLabel;
}

- (CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.navigationView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#54b2d0"].CGColor,
                           (id)[UIColor colorWithHexString:@"#439ac4"].CGColor,
                           nil];
        
        _dayGradient = gradient;
    }
    return _dayGradient;
}

- (CAGradientLayer *)nightGradient
{
    if (!_nightGradient)
    {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.navigationView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#7590ae"].CGColor,
                           (id)[UIColor colorWithHexString:@"#3a5170"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}


#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    if (self.navigationController.viewControllers.count > 1) // 如果 堆栈有，就pop
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else // 堆栈 为空 模态返回
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
}

- (void)rightButtonAciton:(UIButton *)sender
{
    
}

#pragma mark data
//  判断 是否是 白天
- (BOOL)isDayLight
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    if (dateComponent.hour>=6 && dateComponent.hour<18)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)setNavigationViewColor:(BOOL)isDayLight
{
    CALayer *layer = [[self.navigationView.layer sublayers] objectAtIndex:0];
    
    if (!isDayLight)
    {
        if (layer == self.nightGradient)
        {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.navigationView.layer insertSublayer:self.nightGradient atIndex:0];
        
    }
    else
    {
        if (layer == self.dayGradient)
        {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.navigationView.layer insertSublayer:self.dayGradient atIndex:0];
        
    }
}

@end
