//
//  JFGBaseViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/7/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "TimeChangeMonitor.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import <Masonry.h>

@interface JFGBaseViewController ()<TimeChangeMonitorDelegate>



@property (nonatomic,strong)CAGradientLayer *dayGradient;
@property (nonatomic,strong)CAGradientLayer *nightGradient;

@end

@implementation JFGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initTopBar];
    [self addNotificationDelegate];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

//添加代理，通知等
-(void)addNotificationDelegate
{
    //添加时间变化代理
    [[TimeChangeMonitor sharedManager] starTimer];
    [[TimeChangeMonitor sharedManager] addDelegate:self];
    [[TimeChangeMonitor sharedManager] timerAction];
}

#pragma mark- timeChange Delegate
-(void)timeChangeWithCurrentYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    [self setTopBarBgViewBackgroundColorWithHour:hour];
}


-(void)setTopBarBgViewBackgroundColorWithHour:(NSInteger)hour
{
    if (hour>=6 && hour<18) {
        //白天
        [self setBarViewColor:YES];
    }else{
        //晚上
        [self setBarViewColor:NO];
    }
}

-(void)setBarViewColor:(BOOL)day
{
    if (!day) {
        
        CALayer *layer = [[self.topBarBgView.layer sublayers] objectAtIndex:0];
        if (layer == self.nightGradient) {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.topBarBgView.layer insertSublayer:self.nightGradient atIndex:0];
        
    }else{
        
        CALayer *layer = [[self.topBarBgView.layer sublayers] objectAtIndex:0];
        if (layer == self.dayGradient) {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.topBarBgView.layer insertSublayer:self.dayGradient atIndex:0];
        
    }
}

-(void)setColorAccordingToCalendar{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    if (dateComponent.hour>=6 && dateComponent.hour<18) {
        //白天
        [self setBarViewColor:YES];
    }else{
        //晚上
        [self setBarViewColor:NO];
        
    }
}
-(void)initTopBar
{
    [self.view addSubview:self.topBarBgView];
    [self.topBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@64);
    }];
    
    if (self.navigationController) {
        
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        if (index>0) {
            
            [self.topBarBgView addSubview:self.backBtn];
            [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@2);
                make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
                make.height.greaterThanOrEqualTo(@50);
                make.width.greaterThanOrEqualTo(@50);
            }];
        }
        
    }else{
        
        [self.topBarBgView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@2);
            make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
            make.height.greaterThanOrEqualTo(@50);
            make.width.greaterThanOrEqualTo(@50);
        }];
        
    }
    
    [self.topBarBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
        make.centerX.mas_equalTo(self.topBarBgView.mas_centerX);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@17);
    }];
    [self.topBarBgView layoutIfNeeded];
    [self setColorAccordingToCalendar];
    
}

-(void)showBackBtn
{
    if (self.backBtn.superview == nil) {
        [self.topBarBgView addSubview:self.backBtn];
    }
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@2);
        make.centerY.mas_equalTo(self.topBarBgView.mas_bottom).offset(-22);
        make.height.greaterThanOrEqualTo(@50);
        make.width.greaterThanOrEqualTo(@50);
    }];
}

-(UIView *)topBarBgView
{
    if (!_topBarBgView) {
        _topBarBgView = [[UIView alloc]init];
        //_topBarBgView.backgroundColor = [UIColor colorWithHexString:@"#0da9cf"];

        _topBarBgView.userInteractionEnabled = YES;
    }
    return _topBarBgView;
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_backBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}


-(CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.topBarBgView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#17AFD1"].CGColor,(id)[UIColor colorWithHexString:@"#17AFD1"].CGColor,
                           nil];
        
        _dayGradient = gradient;
    }
    return _dayGradient;
}

-(CAGradientLayer *)nightGradient
{
    if (!_nightGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.topBarBgView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#263954"].CGColor,(id)[UIColor colorWithHexString:@"#263954"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}


-(void)backAction
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
