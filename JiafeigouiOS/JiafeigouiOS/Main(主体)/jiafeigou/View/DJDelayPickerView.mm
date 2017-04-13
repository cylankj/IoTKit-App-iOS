//
//  DJDatePickerView.m
//  DJActionRuler
//
//  Created by SghOmk on 16/6/30.
//  Copyright © 2016年 SHENZHEN BITHEALTH TECHNOLOGY CO.,LTD. All rights reserved.
//

#import "DJDelayPickerView.h"
#import "NSDate+DateTools.h"
#import "FLGlobal.h"
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "DateTools.h"
#import "JfgLanguage.h"
#define PICKERVIEWROWHEIGHT 40

struct HoursMin {
    NSInteger hours;
    NSInteger mins;
};

@interface DJDelayPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString *selectedItem;
    NSIndexPath *indexPath;
}
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIView *pickerBgView;
@property (nonatomic,strong)UIPickerView *_pickerView;
@property (nonatomic,strong)UIButton *dissMissBtn;
@property (nonatomic,strong)UIButton *doBtn;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign ,nonatomic) NSInteger selectOneRow,selectTwoRow,selectThreeRow;

@end


@implementation DJDelayPickerView


+ (instancetype)delayPickerView{
    
    DJDelayPickerView *picker =[[DJDelayPickerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    
    return picker;
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView =[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.6;
        [self addSubview:maskView];
        [self addSubview:self.pickerBgView];
        [self.pickerBgView addSubview:self.dissMissBtn];
        [self.pickerBgView addSubview:self.titleLabel];
        [self.pickerBgView addSubview:self.doBtn];
        [self.pickerBgView addSubview:self._pickerView];
    }
    return self;
}
#pragma mark- UIPickerViewDataSource

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (0 ==component) {
        return 3;
    } else if (1 ==component){
        return 25;
    }else{
        return 61;
    }
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return Kwidth /3;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return PICKERVIEWROWHEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    NSString *titleString =nil;

    if (0 ==component) {
        switch (row) {
            case 0:
            titleString =@"";
                break;
            case 1:
            {
                titleString =[self.dateFormatter stringFromDate:[NSDate date]];//今天
            }
                break;
            case 2:
            {
                titleString =[self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24 *60 *60]];//明天
            }
                break;
        }
    }else{
        if (row >9) {
            titleString =[NSString stringWithFormat:@"%ld",(long)row -1];
        }else if (row >0){
            titleString =[NSString stringWithFormat:@"0%ld",(long)row -1];
        }else if (1 ==component){
            titleString =[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Start"];
        }else{
            titleString =@"";
        }
    }
    
    if (view) {
        UILabel *lab =[view viewWithTag:20];
        [lab setText:titleString];
        return view;
    }else{
        UIView *vi =[[UIView alloc] initWithFrame:CGRectMake(0, 0, Kwidth /3, PICKERVIEWROWHEIGHT)];
        
        UILabel *lab =[[UILabel alloc] initWithFrame:vi.frame];
        [lab setText:titleString];
        [lab setTextColor:[UIColor blackColor]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setFont:[UIFont systemFontOfSize:22]];
        [lab setTag:20];
        [vi addSubview:lab];
        
        return vi;
    }
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [pickerView reloadComponent:0];
    [self handlePickerView:pickerView selectRow:row inComponent:component];
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter =[[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:[NSString stringWithFormat:@"M%@d%@",[JfgLanguage getLanTextStrByKey:@"MONTHS"],[JfgLanguage getLanTextStrByKey:@"SUN_2"]]];
    }
    return _dateFormatter;
}

- (HoursMin)selectedAddTenMins:(NSInteger)addMins{
    //获取当前时间 +10 分钟
    NSDate *aDate =[NSDate dateWithTimeIntervalSinceNow:addMins *60];
    NSInteger hours =[aDate hour];
    NSInteger mins =[aDate minute];
    HoursMin h ;
    h.hours =hours;
    h.mins =mins;
    
    return h;
}

- (void)handlePickerView:(UIPickerView *)pickerView selectRow:(NSInteger)row inComponent:(NSInteger)component{
    static NSInteger component_one_row =0;//初始化每一列的选中  第一列
    static NSInteger component_two_row =0;//初始化每一列的选中  第二列
    static NSInteger component_three_row =0;//初始化每一列的选中  第三列
    //如果现在选中的是row ==0   则将picker选中到 立即开始
    if (0 ==row){
        [pickerView selectRow:0 inComponent:0 animated:YES];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        component_one_row =0;
        component_two_row =0;
        component_three_row =0;
        self.selectOneRow =component_one_row;
        self.selectTwoRow =component_two_row;
        self.selectThreeRow =component_three_row;
        return;
    }
    //如果现在第一列选中第二行 也就是今天 则将picker选中到 当前时间 +10 分钟
    if (0 ==component && 1 ==row){
        //是如果现在时间是 23 :50 :00 ~ 23 :59 :59
        
        //那么十分钟后的时间则是 第二天的 00 :00 :00 ~ 00 :09 :59
        
        //这一段时间涉及到从明天切回到今天
        
        //逻辑需要重做

        HoursMin h =[self selectedAddTenMins:10];//这里是获取十分钟后的时间
        
        if (h.hours ==0 &&h.mins <10) { //如果时间是 00 :00 :00 ~ 00 :09 :59
            //但是 如果现在是从第二天的时间切回到第一天的时间则将 今天选中的时间切回到当前的时间
            if (component_two_row ==1 &&component_three_row <11) {
                HoursMin now =[self selectedAddTenMins:0];
                [pickerView selectRow:now.hours +1 inComponent:1 animated:YES];
                [pickerView selectRow:now.mins +1 inComponent:2 animated:YES];
                component_one_row =1;
                component_two_row =now.hours +1;
                component_three_row =now.mins +1;
                self.selectOneRow =component_one_row;
                self.selectTwoRow =component_two_row;
                self.selectThreeRow =component_three_row;
            }else{//则跳转到第二天的 这个时间
                [pickerView selectRow:2 inComponent:0 animated:YES];
                [pickerView selectRow:h.hours +1 inComponent:1 animated:YES];
                [pickerView selectRow:h.mins +1 inComponent:2 animated:YES];
                component_one_row =2;
                component_two_row =h.hours +1;
                component_three_row =h.mins +1;
                self.selectOneRow =component_one_row;
                self.selectTwoRow =component_two_row;
                self.selectThreeRow =component_three_row;
            }
            return;
        }else{
            [pickerView selectRow:h.hours +1 inComponent:1 animated:YES];
            [pickerView selectRow:h.mins +1 inComponent:2 animated:YES];
            component_one_row =1;
            component_two_row =h.hours +1;
            component_three_row =h.mins +1;
            self.selectOneRow =component_one_row;
            self.selectTwoRow =component_two_row;
            self.selectThreeRow =component_three_row;
            return;
        }
    }
    //如果第一列选中的是第三行 也就是明天 则将picker选中到 00:00
    if (0 ==component && 2 ==row){
        [pickerView selectRow:1 inComponent:1 animated:YES];
        [pickerView selectRow:1 inComponent:2 animated:YES];
        component_one_row =2;
        component_two_row =1;
        component_three_row =1;
        self.selectOneRow =component_one_row;
        self.selectTwoRow =component_two_row;
        self.selectThreeRow =component_three_row;
        return;
    }
    //如果现在第二列选中的row >0 则判断 第一列的选中行数  如果第一列的选中行数大于1 则暂时不管
    if (1 ==component || 2 ==component) {
        if (0 ==component_one_row){
            //是如果现在时间是 23 :50 :00 ~ 23 :59 :59
            
            //那么十分钟后的时间则是 第二天的 00 :00 :00 ~ 00 :09 :59
            
            //这一段时间涉及到从明天切回到今天
            
            //逻辑需要重做
            
            HoursMin h =[self selectedAddTenMins:10];//这里是获取十分钟后的时间
            
            if (h.hours ==0 &&h.mins <10) { //如果时间是 00 :00 :00 ~ 00 :09 :59
                //但是 如果现在是从第二天的时间切回到第一天的时间则将 今天选中的时间切回到当前的时间
                if (component_two_row ==1 &&component_three_row <11) {
                    HoursMin now =[self selectedAddTenMins:0];
                    [pickerView selectRow:now.hours +1 inComponent:1 animated:YES];
                    [pickerView selectRow:now.mins +1 inComponent:2 animated:YES];
                    component_one_row =1;
                    component_two_row =now.hours +1;
                    component_three_row =now.mins +1;
                    self.selectOneRow =component_one_row;
                    self.selectTwoRow =component_two_row;
                    self.selectThreeRow =component_three_row;
                }else{//则跳转到第二天的 这个时间
                    [pickerView selectRow:2 inComponent:0 animated:YES];
                    [pickerView selectRow:h.hours +1 inComponent:1 animated:YES];
                    [pickerView selectRow:h.mins +1 inComponent:2 animated:YES];
                    component_one_row =2;
                    component_two_row =h.hours +1;
                    component_three_row =h.mins +1;
                    self.selectOneRow =component_one_row;
                    self.selectTwoRow =component_two_row;
                    self.selectThreeRow =component_three_row;
                }
                return;
            }else{
                [pickerView selectRow:1 inComponent:0 animated:YES];
                [pickerView selectRow:h.hours +1 inComponent:1 animated:YES];
                [pickerView selectRow:h.mins +1 inComponent:2 animated:YES];
                component_one_row =1;
                component_two_row =h.hours +1;
                component_three_row =h.mins +1;
                self.selectOneRow =component_one_row;
                self.selectTwoRow =component_two_row;
                self.selectThreeRow =component_three_row;
                return;
            }
        }else if (1 ==component_one_row){
            if (component ==1) {
                component_two_row =row;
            }
            if (component ==2) {
                component_three_row =row;
            }
            NSInteger selectedHours =component_two_row -1;
            NSInteger selectedMins =component_three_row -1;
            //将小时数和分钟数转换成时间 和当前时间做对比
            HoursMin now =[self selectedAddTenMins:0];
            //选择器设定时间早于当前时间,松手后立即弹回当前时间
            if (selectedMins <now.mins ||selectedHours <now.hours) {
                if (selectedHours <=now.hours) {
                    [pickerView selectRow:1 inComponent:0 animated:YES];
                    [pickerView selectRow:now.hours +1 inComponent:1 animated:YES];
                    [pickerView selectRow:now.mins +1 inComponent:2 animated:YES];
                    component_one_row =1;
                    component_two_row =now.hours +1;
                    component_three_row =now.mins +1;
                    self.selectOneRow =component_one_row;
                    self.selectTwoRow =component_two_row;
                    self.selectThreeRow =component_three_row;
                    return;
                }
            }
            self.selectOneRow =component_one_row;
            self.selectTwoRow =component_two_row;
            self.selectThreeRow =component_three_row;
        }else if (2 ==component_one_row){
            if (component ==1) {
                component_two_row =row;
            }
            if (component ==2) {
                component_three_row =row;
            }
            self.selectOneRow =component_one_row;
            self.selectTwoRow =component_two_row;
            self.selectThreeRow =component_three_row;
        }
    }
}

#pragma mark- action
-(void)show
{
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    self.alpha = 0;
    [keyWindows addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.pickerBgView.bottom = kheight;
    } completion:^(BOOL finished) {
      
    }];
}

-(void)cancelPick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelPick)]) {
        [self.delegate cancelPick];
    }
    [self dismiss];
}

-(void)doAction{
    if (self.selectOneRow +self.selectTwoRow +self.selectThreeRow ==0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(delayPickerView:didSelectTime:isBegainNow:)]) {
            [self.delegate delayPickerView:self didSelectTime:[NSDate date] isBegainNow:YES];
        }
    }else{
        //在这里将选中的行数转换成时间
        NSInteger days =self.selectOneRow;
        NSInteger hous =self.selectTwoRow;
        NSInteger mins =self.selectThreeRow;
        //基础时间,以今天为基础时间
        NSDate *bascDate =[NSDate date];
        //转化后的今天
        NSDate *today =[NSDate dateWithYear:[bascDate year] month:[bascDate month] day:[bascDate day]];
        //计算过后的选中的天数
        NSDate *selectDay =[[[[today dateByAddingDays:days -1] dateByAddingHours:hous -1] dateByAddingMinutes:mins -1] dateByAddingSeconds:59];
        if (self.delegate && [self.delegate respondsToSelector:@selector(delayPickerView:didSelectTime:isBegainNow:)]) {
            [self.delegate delayPickerView:self didSelectTime:selectDay isBegainNow:NO];
        }
    }
    [self dismiss];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        self.pickerBgView.top = kheight;
    } completion:^(BOOL finished) {
        self.alpha = 0;
        [self removeFromSuperview];
    }];
}



//-(void)setTitle:(NSString *)title
//{
//    _title = title;
//    self.titleLabel.text = title;
//}


#pragma mark- view
-(void)initView
{
    [self addSubview:self.pickerBgView];
    
    
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, Kwidth-120, 44)];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#8f8f8f"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setText:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_StartTime"]];
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
        [button addTarget:self action:@selector(cancelPick) forControlEvents:UIControlEventTouchUpInside];
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
        __pickerView.delegate =self;
        __pickerView.dataSource =self;
    }
    return __pickerView;
}

//-(void)setBgImageView:(UIImageView *)bgImageView
//{
//    if (bgImageView != _bgImageView) {
//        [_bgImageView removeFromSuperview];
//    }
//    if (bgImageView) {
//        [self addSubview:bgImageView];
//        [self sendSubviewToBack:bgImageView];
//        _bgImageView= bgImageView;
//    }
//}

@end
