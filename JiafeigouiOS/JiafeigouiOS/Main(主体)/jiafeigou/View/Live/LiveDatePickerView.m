//
//  LiveDatePickerView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "LiveDatePickerView.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"

@interface LiveDatePickerView()

@property (nonatomic,weak)id <LiveDatePickerDelegate> delegate;
@property (nonatomic,strong)UIDatePicker *datePicker;
@property (nonatomic,strong)NSDate *selectedDate;
@property (nonatomic,strong)UIView *pickerBgView;

@end

@implementation LiveDatePickerView

-(instancetype)initWithDelegate:(id<LiveDatePickerDelegate>) delegate
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.delegate = delegate;
    [self initView];
    return self;
}

-(void)show
{
    self.alpha = 0;
    self.pickerBgView.top = self.height;
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    [keyWindows addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pickerBgView.bottom = self.height;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pickerBgView.top = self.height;
    } completion:^(BOOL finished) {
        
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)cancelAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerCancel)]) {
        [self.delegate pickerCancel];
    }
    [self dismiss];
}

-(void)doneAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerSelectedDate:)]) {
        [self.delegate pickerSelectedDate:self.selectedDate?self.selectedDate:[NSDate date]];
    }
    [self dismiss];
}

-(void)initView
{
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 44)];
    topBgView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
    [self.pickerBgView addSubview:topBgView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 13, 60, 18);
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [topBgView addSubview:cancelBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(15, 13, 60, 18);
    doneBtn.right = self.width-10;
    doneBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [topBgView addSubview:doneBtn];
    
    [self.pickerBgView addSubview:topBgView];
    [self.pickerBgView addSubview:self.datePicker];
    
    [self addSubview:self.pickerBgView];
}

-(UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44, self.width, 216)];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *maxDate = [dateFormatter dateFromString:@"2018-12-31 23:59"];
        _datePicker.maximumDate = maxDate;
        _datePicker.minimumDate = [NSDate date];
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
    }
    return _datePicker;
}

-(UIView *)pickerBgView
{
    if (!_pickerBgView) {
        _pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 216+44)];
        _pickerBgView.bottom = self.height;
        _pickerBgView.backgroundColor = [UIColor whiteColor];
    }
    return _pickerBgView;
}

-(void)setMaximumDate:(NSDate *)maximumDate
{
    if ([_maximumDate isEqualToDate:maximumDate]) {
        return;
    }
    _maximumDate = maximumDate;
    self.datePicker.maximumDate = _maximumDate;
}

-(void)setMinimumDate:(NSDate *)minimumDate
{
    if ([_minimumDate isEqualToDate:minimumDate]) {
        return;
    }
    _minimumDate = minimumDate;
    self.datePicker.minimumDate = _minimumDate;
}

-(void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    if (_datePickerMode == datePickerMode) {
        return;
    }
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

-(void)dateChanged:(id)sender
{
    UIDatePicker* control = (UIDatePicker*)sender;
    self.selectedDate = control.date;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
