//
//  CusPickerView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/2.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CusPickerView.h"
#import "JfgGlobal.h"
#import "CommonMethod.h"

@interface CusPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSString *minKey;
    NSString *secondKey;
}
@property (nonatomic, strong) UIWindow *appWindow;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *contentsView;

@property (nonatomic, strong) UIButton *comfirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) UIView *lineView;


@property (nonatomic, copy) NSString *okButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *msgTitle;
@property (nonatomic, copy) NSString *selectedKey;


@property (nonatomic, strong) NSMutableDictionary *pickerDict;

@property (nonatomic, assign) NSInteger originSelectValue;

@end


@implementation CusPickerView

- (instancetype)initWitinitWithTitle:(NSString *)title OkButtonTitle:(NSString *)oktitle cancelButtonTitle:(NSString *)cancelTitle
{
    self = [super init];
    self.frame = CGRectMake(0, 0, Kwidth, kheight);
    
    if (self)
    {
        _okButtonTitle = oktitle;
        _cancelButtonTitle = cancelTitle;
        _msgTitle = title;
        
        minKey = [JfgLanguage getLanTextStrByKey:@"MINUTE_Cloud"];
        secondKey = [JfgLanguage getLanTextStrByKey:@"REPEAT_TIME_ALARM"];
        
//        self.selectedKey = [JfgLanguage getLanTextStrByKey:@"MINUTE_Cloud"];
    }
    return self;
}

- (void)setData:(NSInteger )originData
{
    self.originSelectValue = originData;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [self initView];
    [self initViewLayout];
}

- (void)initView
{
    [self addSubview:self.bgView];
    
    [self addSubview:self.contentsView];
    [self.contentsView addSubview:self.topView];
    [self.contentsView addSubview:self.pickerView];
    [self.contentsView addSubview:self.lineView];
    
    [self.topView addSubview:self.comfirmButton];
    [self.topView addSubview:self.cancelButton];
    [self.topView addSubview:self.titleLabel];
    
}

- (void)initViewLayout
{
    JFG_WS(weakSelf);
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentsView.mas_left).with.offset(17.0f);
        make.centerY.equalTo(weakSelf.topView.mas_centerY);
    }];
    
    [self.comfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentsView.mas_right).with.offset(-17.0f);
        make.centerY.equalTo(weakSelf.topView.mas_centerY);
        make.width.equalTo(weakSelf.cancelButton);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentsView);
        make.centerY.equalTo(weakSelf.topView.mas_centerY);
    }];
}

- (void)show
{
    JFG_WS(weakSelf);
    [self.appWindow addSubview:self];
    
    if (self.originSelectValue == 30)
    {
        self.selectedKey = secondKey;
        [self.pickerView reloadComponent:0];
        
        [self.pickerView selectRow:0 inComponent:1 animated:NO];
        
        [self pickView:self.pickerView hightedRow:0 inComponent:1];
        [self pickView:self.pickerView hightedRow:0 inComponent:0];
    }
    else
    {
        NSInteger rowInFirstComponet = (self.originSelectValue/60)-1;
        
        self.selectedKey = minKey;
        [self.pickerView reloadComponent:0];
        
        [self.pickerView selectRow:rowInFirstComponet inComponent:0 animated:NO];
        [self.pickerView selectRow:1 inComponent:1 animated:NO];
        
        [self pickView:self.pickerView hightedRow:1 inComponent:1];
        [self pickView:self.pickerView hightedRow:rowInFirstComponet inComponent:0];
    }
    
    self.contentsView.top = kheight;
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.bgView.alpha = 0.2f;
        weakSelf.contentsView.top = kheight - weakSelf.contentsView.height;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)dismiss
{
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.contentsView.top = kheight;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)pickView:(UIPickerView *)pickerView hightedRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *dateLabel =  (UILabel *)[pickerView viewForRow:row forComponent:component];
    dateLabel.textColor = [UIColor colorWithHexString:@"#333333"];
}

#pragma mark action
- (void)comfirmButtonAction:(UIButton *)sender
{
    NSInteger selectedValue = 0;
    
    if ([self.selectedKey isEqualToString:minKey])
    {
        selectedValue = ([self.pickerView selectedRowInComponent:0]+1) * 60;
    }
    else
    {
        selectedValue = 30;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didComfirmItem:pickerView:)])
    {
        [_delegate didComfirmItem:selectedValue pickerView:self.pickerView];
    }
    
    [self dismiss];
}

- (void)cancelButtonAction:(UIButton *)sender
{

    [self dismiss];
}


#pragma mark pickerview delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickerDict.allKeys.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    switch (component)
    {
        case 0:
        {
            NSArray *rows = [self.pickerDict objectForKey:self.selectedKey];
            return [rows count];
        }
            break;
        case 1:
        {
            return self.pickerDict.allKeys.count;
        }
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return  pickerView.bounds.size.width*0.5;
            
        case 1:
            return pickerView.bounds.size.width*0.5;
            
        default:
            break;
    }
    
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.font = [UIFont systemFontOfSize:18.0f];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    
    switch (component)
    {
        case 0:
        {
            dateLabel.text = [NSString stringWithFormat:@"%@", [[self.pickerDict objectForKey:self.selectedKey] objectAtIndex:row]];
        }
            break;
            
        case 1:
        {
            dateLabel.text = [NSString stringWithFormat:@"%@", [self.pickerDict.allKeys objectAtIndex:row]];
        }
            break;
            
        default:
            break;
    }
    [dateLabel sizeToFit];
    dateLabel.adjustsFontSizeToFitWidth = YES;
    
    return dateLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self pickView:pickerView hightedRow:row inComponent:component];

    if (component == 1)
    {
        self.selectedKey = [self.pickerDict.allKeys objectAtIndex:row];
        [pickerView reloadComponent:0];
        [self pickView:pickerView hightedRow:0 inComponent:0];
    }
    
}


#pragma mark getter

- (UIWindow *)appWindow
{
    if (_appWindow == nil)
    {
        _appWindow = [[[UIApplication sharedApplication] delegate] window];
    }
    
    return _appWindow;
}


-(UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.alpha = 0.2f;
        _bgView.backgroundColor = [UIColor blackColor];
    }
    return _bgView;
}

- (UIView *)topView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 44;
    CGFloat widgetX = 0;
    CGFloat widgetY = 0;
    
    if (_topView == nil)
    {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _topView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
    }
    return _topView;
}

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

- (UIButton *)comfirmButton
{
    if (_comfirmButton == nil)
    {
        _comfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_comfirmButton setTitle:_okButtonTitle forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_comfirmButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
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

- (UIPickerView *)pickerView
{
    
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 167;
    CGFloat widgetX = 0;
    CGFloat widgetY = 44;
    
    if (_pickerView == nil)
    {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (NSMutableDictionary *)pickerDict
{
    if (_pickerDict == nil)
    {
        _pickerDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@[@1,@2,@3,@4,@5,@6,@7,@8,@9,@10], minKey, @[@30], secondKey, nil];
        
    }
    return _pickerDict;
}

@end
