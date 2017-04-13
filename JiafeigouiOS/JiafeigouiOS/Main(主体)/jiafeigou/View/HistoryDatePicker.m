//
//  HistoryDatePicker.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "HistoryDatePicker.h"
#import "FLGlobal.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"
@interface HistoryDatePicker()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *selectedItem;
    NSIndexPath *indexPath;
}
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIView *pickerBgView;
@property (nonatomic,strong)UIPickerView *_pickerView;
@property (nonatomic,strong)UIButton *dissMissBtn;
@property (nonatomic,strong)UIButton *doBtn;
@property (nonatomic,strong)UIView *backgroundView;

@end

@implementation HistoryDatePicker

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){

        UIView *maskView =[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0;
        maskView.tag = 10001;
        [self addSubview:maskView];
        self.backgroundColor = [UIColor clearColor];
        
        
        [self initView];
    }
    return self;
}

+(instancetype)historyDatePicker
{
    HistoryDatePicker *picker = [[HistoryDatePicker alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    return picker;
}


#pragma mark- action
-(void)show
{
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    self.alpha = 0;
    [keyWindows addSubview:self];
    
    UIView *maskView = [self viewWithTag:10001];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        maskView.alpha = 0.4;
        self.pickerBgView.bottom = kheight;
    } completion:^(BOOL finished) {

    }];
    
    
    
    
}

-(void)cancel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancel)]) {
        [self.delegate cancel];
    }
    [self dismiss];
}

-(void)doAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItem:indexPath:)]) {
        [self.delegate didSelectedItem:selectedItem indexPath:indexPath];
    }
    [self dismiss];
}

-(void)dismiss
{
    UIView *maskView = [self viewWithTag:10001];
    [UIView animateWithDuration:0.3 animations:^{
        
        maskView.alpha = 0;
        self.pickerBgView.top = kheight;
        
    } completion:^(BOOL finished) {
        self.alpha = 0;
        [self removeFromSuperview];
    }];
}




-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

-(void)setDataArray:(NSMutableArray<NSArray <NSString *> *> *)dataArray
{
    if (dataArray.count) {
        
        _dataArray = dataArray;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        if (_dataArray.count>0) {
            NSArray *temp = [_dataArray objectAtIndex:0];
            if (temp.count>0) {
                selectedItem = temp[0];
            }
        }
        [self._pickerView reloadAllComponents];
        
    }
}


#pragma mark- UIPickerViewDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.dataArray.count;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.dataArray.count>component) {
        
        return [self.dataArray objectAtIndex:component].count;
        
    }
    return 0;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return Kwidth/self.dataArray.count;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.dataArray.count > component) {
        NSArray *arr = [self.dataArray objectAtIndex:component];
        if (arr.count > row) {
            NSString *str = arr[row];
            selectedItem = str;
        }
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:component];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *arr = [self.dataArray objectAtIndex:component];
    if (arr.count > row) {
        NSString *str = arr[row];
        return str;
    }
    return nil;
}




#pragma mark- view
-(void)initView
{
    [self addSubview:self.pickerBgView];
    [self.pickerBgView addSubview:self.dissMissBtn];
    [self.pickerBgView addSubview:self.titleLabel];
    [self.pickerBgView addSubview:self.doBtn];
    [self.pickerBgView addSubview:self._pickerView];
}



-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, Kwidth-120, 44)];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

-(UIButton *)dissMissBtn
{
    if (!_dissMissBtn) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(17, 7, 50, 30);
        [button setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        _dissMissBtn = button;
    }
    return _dissMissBtn;
}

-(UIButton *)doBtn
{
    if (!_doBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 7, 50, 30);
        rightBtn.right = Kwidth-17;
        [rightBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [rightBtn addTarget:self action:@selector(doAction) forControlEvents:UIControlEventTouchUpInside];
        _doBtn = rightBtn;
    }
    return _doBtn;
}

-(UIView *)pickerBgView
{
    if (!_pickerBgView) {
        _pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 207)];
        _pickerBgView.backgroundColor  = [UIColor colorWithHexString:@"f6f6f6"];
    }
    return _pickerBgView;
}

-(UIPickerView *)_pickerView
{
    if (!__pickerView) {
        __pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, Kwidth, 163)];
        __pickerView.backgroundColor = [UIColor whiteColor];
        // 显示选中框
        __pickerView.showsSelectionIndicator=YES;
        __pickerView.dataSource = self;
        __pickerView.delegate = self;
    }
    return __pickerView;
}



-(void)setBgImageView:(UIImageView *)bgImageView
{
    if (!bgImageView) {
        return;
    }
    if (bgImageView != _bgImageView) {
        [_bgImageView removeFromSuperview];
    }
    if (bgImageView) {
        [self addSubview:bgImageView];
        [self sendSubviewToBack:bgImageView];
        _bgImageView= bgImageView;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
