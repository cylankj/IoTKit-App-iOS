//
//  AngleView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AngleView.h"
#import "JfgGlobal.h"
#import "UIButton+FLExtentsion.h"

@interface AngleView()

@property (nonatomic, strong) UIView *bgView; //背景view

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *setAngleButton;

@end


@implementation AngleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        self.alpha = 1;
        
        self.bgView.center = self.center;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self initView];
}

- (void)initView
{
    [self addSubview:self.bgView];
    
    [self.bgView addSubview:self.iconImageView];
    [self.bgView addSubview:self.msgLabel];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).with.offset(23.0f);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.bgView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).with.offset(-(Kwidth-100*2)/(3*2));
        make.top.equalTo(self.msgLabel.mas_bottom).with.offset(29.0);
    }];
    
    [self.bgView addSubview:self.setAngleButton];
    [self.setAngleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).with.offset((Kwidth-100*2)/(3*2));
        make.top.equalTo(self.msgLabel.mas_bottom).with.offset(29.0);
    }];
}


- (UIView *)bgView
{
    if (_bgView == nil)
    {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat width = Kwidth;
        CGFloat height = 185;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
//        _bgView.backgroundColor = [UIColor redColor];
    }
    
    return _bgView;
}

- (UIImageView *)iconImageView
{
    if (_iconImageView == nil)
    {
        CGFloat width = 60;
        CGFloat height = 60;
        CGFloat x = (self.width - width)*0.5;
        CGFloat y = 0;
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _iconImageView.image = [UIImage imageNamed:@"icon_overlooking"];
    }
    
    return _iconImageView;
}

- (UILabel *)msgLabel
{
    if (_msgLabel == nil)
    {
//        CGFloat width = self.width;
//        CGFloat height = 70;
//        CGFloat x = 0;
//        CGFloat y = self.iconImageView.bottom + 23;
//        WithFrame:CGRectMake(x, y, width, height)
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_OverlookTips_View"];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [UIFont systemFontOfSize:14.0f];
        _msgLabel.numberOfLines = 2;
        _msgLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    
    return _msgLabel;
}


- (UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        CGFloat width = 100;
        CGFloat height = 38;
        CGFloat x = (self.width - 2*width)/3.0;
        CGFloat y = self.msgLabel.bottom + 29;
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_cancelButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"angle_press"] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"angle_normal"] forState:UIControlStateNormal];
        [_cancelButton bk_initWihtHanderForTouchUpInside:^(UIButton *button) {
            [self removeFromSuperview];
        }];
    }
    return _cancelButton;
}

- (UIButton *)setAngleButton
{
    if (_setAngleButton == nil)
    {
        CGFloat width = 100;
        CGFloat height = 38;
        CGFloat x = (self.width - 2*width)*2/3.0 + self.cancelButton.width;
        CGFloat y = self.msgLabel.bottom + 29;
        
        _setAngleButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_setAngleButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] forState:UIControlStateNormal];
        [_setAngleButton setBackgroundImage:[UIImage imageNamed:@"angle_press"] forState:UIControlStateNormal];
        [_setAngleButton setBackgroundImage:[UIImage imageNamed:@"angle_normal"] forState:UIControlStateNormal];
    }
    
    return _setAngleButton;
}

@end
