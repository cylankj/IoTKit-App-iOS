//
//  NewHistoryDateSelectedPicker.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "NewHistoryDateSelectedPicker.h"
#import "FLGlobal.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"
#import <Masonry.h>

@interface NewHistoryDateSelectedPicker()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *selectedItem;
    NSIndexPath *indexPath;
    NSInteger hour;
    NSInteger minute;
}
@property (nonatomic,strong)UILabel *titleLabel;



@end

@implementation NewHistoryDateSelectedPicker

-(id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}



+(instancetype)historyDatePicker
{
    NewHistoryDateSelectedPicker *picker = [[NewHistoryDateSelectedPicker alloc] initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
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
        if (self.isFullScreen) {
            self.pickerBgView.bottom = Kwidth;
        }else{
            self.pickerBgView.bottom = kheight;
        }
        
        [self.pickerBgView reloadInputViews];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedYearString:hour:minute:)]) {
        [self.delegate didSelectedYearString:selectedItem hour:hour minute:minute];
    }
    [self dismiss];
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

-(UIView *)maskView
{
    if (!_maskView) {
        UIView *maskView =[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0;
        maskView.tag = 10001;
        _maskView = maskView;
    }
    return _maskView;
}

#pragma mark- UIPickerViewDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
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
    if (self.widthForComponents.count && self.widthForComponents.count>component) {
        NSNumber *num = self.widthForComponents[component];
        if ([num isKindOfClass:[NSNumber class]]) {
            return [num floatValue];
        }else{
            return Kwidth/self.dataArray.count;
        }
    }
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
            if (component == 0) {
                selectedItem = str;
            }else if (component == 1){
                hour = [str integerValue];
            }else if (component == 2){
                minute = [str integerValue];
            }
        }
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:component];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18]];
        pickerLabel.textColor = [UIColor blackColor];
        if (component == 0) {
            [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        }
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *arr = [self.dataArray objectAtIndex:component];
    if (arr.count > row) {
        NSString *str = arr[row];
        if (component == 0) {
            str = [str stringByReplacingOccurrencesOfString:@"_" withString:@"  "];
        }
        return str;
    }
    return @"";
}




#pragma mark- view
-(void)initView
{
    [self addSubview:self.maskView];
    [self addSubview:self.pickerBgView];
    [self.pickerBgView addSubview:self.dissMissBtn];
    [self.pickerBgView addSubview:self.titleLabel];
    [self.pickerBgView addSubview:self.doBtn];
    [self.pickerBgView addSubview:self._pickerView];
   
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
        _pickerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 205)];
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






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation HistoryPickerDateModel


@end
