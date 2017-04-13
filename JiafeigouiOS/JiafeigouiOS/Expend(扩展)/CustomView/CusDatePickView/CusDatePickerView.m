//
//  CusDatePickerView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "CusDatePickerView.h"
#import "JfgGlobal.h"
#import "CommonMethod.h"

@interface CusDatePickerView()
{
    NSString *_msgTitle;
    NSString *_okButtonTitle;
    NSString *_cancelButtonTitle;
}

@property (strong, nonatomic) UIView *contentsView;

@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIButton *okButton;

@property (strong, nonatomic) UIView *titleView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIWindow *appWindow;

@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) UIView *maskView;

@end



@implementation CusDatePickerView


- (instancetype)initWitinitWithTitle:(NSString *)title OkButtonTitle:(NSString *)oktitle cancelButtonTitle:(NSString *)cancelTitle
{
    self = [super init];
    self.frame = CGRectMake(0, 0, Kwidth, kheight);
    if (self)
    {
        _okButtonTitle = oktitle;
        _cancelButtonTitle = cancelTitle;
        _msgTitle = title;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self initView];
    [self initViewLayout];
}



#pragma mark view

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];
    [self addSubview:self.contentsView];
    [self.contentsView addSubview:self.datePicker];
    [self.contentsView addSubview:self.titleView];
    [self.contentsView addSubview:self.lineView];
    
    [self.titleView addSubview:self.titleLabel];
    [self.titleView addSubview:self.okButton];
    [self.titleView addSubview:self.cancelButton];
    
}

- (void)initViewLayout
{
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleView.mas_left).with.offset(17.0f);
        make.centerY.equalTo(self.titleView.mas_centerY).with.offset(0.0f);
    }];
    
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleView.mas_right).with.offset(-17.0f);
        make.centerY.equalTo(self.titleView.mas_centerY).with.offset(0.0f);
        make.width.equalTo(self.cancelButton);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.titleView);
    }];
}

-(void)setDate:(nonnull NSDate *)date animated:(BOOL)animated
{
    [self.datePicker setDate:date animated:animated];
}

#pragma mark getter

- (UIView *)contentsView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 207;
    CGFloat widgetX = 0;
    CGFloat widgetY = kheight - widgetHeight;
    
    if (_contentsView == nil)
    {
        _contentsView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _contentsView.backgroundColor = [UIColor whiteColor];
    }
    
    return _contentsView;
}

- (UIDatePicker *)datePicker
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 167;
    CGFloat widgetX = 0;
    CGFloat widgetY = 44;
    
    if (_datePicker == nil)
    {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _datePicker.datePickerMode = UIDatePickerModeTime;//UIDatePickerModeTime;
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (UIButton *)okButton
{
    if (_okButton == nil)
    {
        _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okButton setTitle:_okButtonTitle forState:UIControlStateNormal];
        [_okButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_okButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
        [_okButton addTarget:self action:@selector(okButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okButton;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = _msgTitle;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#8f8f8f"];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
    }
    return _titleLabel;
}

- (UIView *)titleView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 44;
    CGFloat widgetX = 0;
    CGFloat widgetY = 0;
    
    if (_titleView == nil)
    {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _titleView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
    }
    return _titleView;
}

- (UIWindow *)appWindow
{
    if (_appWindow == nil)
    {
        _appWindow = [[[UIApplication sharedApplication] delegate] window];
    }
    
    return _appWindow;
}

- (UIView *)lineView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 0.5;
    CGFloat widgetX = 0;
    CGFloat widgetY = 0;
    
    if (_lineView == nil)
    {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#b2b2b2"];
    }
    return _lineView;
}

-(UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.alpha = 0;
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

#pragma mark action

- (void)dateChanged:(UIDatePicker *)datePicker
{
    if ([self.delegate respondsToSelector:@selector(datePickerDidChanged:)])
    {
        [self.delegate datePickerDidChanged:self.datePicker];
    }
}

- (void)cancelButtonAction:(UIDatePicker *)datePicker
{
    [self dismiss];
    
    if ([self.delegate respondsToSelector:@selector(cancelButtonclicked:)])
    {
        [self.delegate cancelButtonclicked:self.datePicker];
    }
}

- (void)okButtonAction:(UIDatePicker *)datePicker
{
    [self dismiss];
    
    if ([self.delegate respondsToSelector:@selector(okButtonclicked:)])
    {
        [self.delegate okButtonclicked:self.datePicker];
    }
}

- (void)show
{
    [self.appWindow addSubview:self];
    self.contentsView.top = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:self.contentsView.height] animations:^{
        self.maskView.alpha = 0.6;
        self.contentsView.top = [UIScreen mainScreen].bounds.size.height - self.contentsView.height;
    }];
    
}

- (void)dismiss
{
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:self.contentsView.height] animations:^{
        self.maskView.alpha = 0;
        self.contentsView.top = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

@end
