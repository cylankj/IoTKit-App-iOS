//
//  VideoPlayViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//  视频播放页面

#import "VideoPlayViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"
#import "UIAlertView+FLExtension.h"
#import "TimeChangeMonitor.h"
#import "MessageViewController.h"
#import "DeviceSettingVC.h"
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import "CommonMethod.h"
#import "LSAlertView.h"
#import "HitTestScrollView.h"
#import "JfgUserDefaultKey.h"
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"

@interface VideoPlayViewController ()<TimeChangeMonitorDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,JFGSDKCallbackDelegate>

@property (nonatomic,strong)UIView *topBarBgView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UIButton *videoTitleLabel;
@property (nonatomic,strong)UIButton *msgTitleLabel;
@property (nonatomic,strong)UIView *topTitleSelectedLine;
@property (nonatomic,strong)UIButton *settingBtn;

@property (nonatomic,strong)CAGradientLayer *dayGradient;
@property (nonatomic,strong)CAGradientLayer *nightGradient;

@property (nonatomic,strong)HitTestScrollView *bgScrollerView;
@property (nonatomic,strong)videoPlay1ViewController *videoPlay;
@property (nonatomic,strong)MessageViewController * messageVC;

@property (nonatomic,assign)BOOL isClearCount;

@property (nonatomic, strong) UIImageView *redDotImageView;

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];

    [JFGSDK addDelegate:self];
    [self addNotificationDelegate];
    [self initTopBar];
    
    if (self.devModel.shareState == DevShareStatuOther) {
        [self.view addSubview:self.bgScrollerView];
        [self addChildViewController:self.videoPlay];
        [self.bgScrollerView addSubview:self.videoPlay.view];
        self.videoPlay.isShow = YES;
        self.bgScrollerView.contentSize = CGSizeMake(self.view.width, self.bgScrollerView.height);
    }else{
        [self.view addSubview:self.bgScrollerView];
        [self addChildViewController:self.videoPlay];
        [self.bgScrollerView addSubview:self.videoPlay.view];
        
        [self addChildViewController:self.messageVC];
        [self.bgScrollerView addSubview:self.messageVC.view];
        self.messageVC.cid = self.cid;
        
        self.videoPlay.isShow = YES;
        self.bgScrollerView.isIntercept = YES;
        self.bgScrollerView.interceptLimits = self.view.bounds.size.height*0.45;
        [self interceptContol];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isShowRed = ([[NSUserDefaults standardUserDefaults] boolForKey:isShowSafeRedDot(self.cid)] || [[NSUserDefaults standardUserDefaults] boolForKey:isShowAutoPhotoRedDot(self.cid)] || [[NSUserDefaults standardUserDefaults] boolForKey:isShowDelayPhotoRedDot(self.cid)]);
    if (self.devModel.shareState == DevShareStatuOther)
    {
        isShowRed = NO;
    }
    self.redDotImageView.hidden = !isShowRed;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    if (self.navigationController.viewControllers.count <=2 ) {
        
        [JFGSDK removeDelegate:self];
        [self.videoPlay removeHistoryDelegate];
    }
    NSLog(@"vcs:%d",self.navigationController.viewControllers.count);
    
}



-(void)interceptContol
{
    if (self.bgScrollerView.contentOffset.x < self.view.bounds.size.width) {
        self.bgScrollerView.isIntercept = YES;
    }else{
        self.bgScrollerView.isIntercept = NO ;
    }
}

-(void)delDeviceNotification:(NSNotification *)notification
{
    [CommonMethod delDeviceByOtherClientWithNotification:notification cid:self.cid superViweController:self];
}

//添加代理，通知等
-(void)addNotificationDelegate
{
    //添加时间变化代理
    [[TimeChangeMonitor sharedManager] starTimer];
    [[TimeChangeMonitor sharedManager] addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transformToVideoView:) name:@"JFGLookHistoryVideo2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingAction) name:JFGGotoSettingKey object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delDeviceNotification:) name:JFGDeviceDelByOtherClientNotification object:nil];
}

-(void)transformToVideoView:(NSNotification *)notification
{
    [self.bgScrollerView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self scrollerContentOffset:0];
    [self interceptContol];
}

#pragma mark- JFGSDDelegate
-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
    BOOL isExist = NO;
    for (JFGSDKDevice *dev in deviceList) {
        if ([dev.uuid isEqualToString:self.cid]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        
        NSArray *delCidArr =  [JFGBoundDevicesMsg sharedDeciceMsg].delDeviceList;
        for (NSString *cid in delCidArr) {
            if ([cid isEqualToString:self.cid]) {
                return;
            }
        }
        
        //确保不会第二次弹窗
        JFGSDKDevice *_dev = [deviceList lastObject];
        self.cid = _dev.uuid;
        NSString *str = @"";
        if (self.devModel.shareState == DevShareStatuOther) {
            //取消分享
            str = [JfgLanguage getLanTextStrByKey:@"Tap1_shareDevice_canceledshare"];
        }else{
            //删除设备
            str = [JfgLanguage getLanTextStrByKey:@"Tap1_device_deleted"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:str delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } otherDelegate:nil];
        
    }
}

#pragma mark --public
- (void)setInnerScrollViewContentOffset:(BOOL)isOffset
{
    //[self.bgScrollerView setContentOffset:CGPointMake(isOffset?self.view.width:0, 0) animated:YES];
    [self topTitleAction:isOffset?self.msgTitleLabel:self.videoTitleLabel];
    [self interceptContol];
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

#pragma mark- ScrollerViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollerContentOffset:scrollView.contentOffset.x];
}

-(void)scrollerContentOffset:(CGFloat)contentOffset
{
    if (contentOffset == 0) {
        
        [self topTitleAction:_videoTitleLabel];
    }else{
        
        [self topTitleAction:_msgTitleLabel];
    }
    [self interceptContol];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

-(void)initTopBar
{
    [self.view addSubview:self.topBarBgView];
    [self.topBarBgView addSubview:self.backBtn];
    [self.topBarBgView addSubview:self.settingBtn];
    
    if (self.devModel.shareState == DevShareStatuOther) {
        //被分享用户只显示视频页面
        [self.topBarBgView addSubview:self.videoTitleLabel];
        self.videoTitleLabel.x = self.topBarBgView.x;
    }else{
        [self.topBarBgView addSubview:self.videoTitleLabel];
        [self.topBarBgView addSubview:self.msgTitleLabel];
        [self.topBarBgView addSubview:self.topTitleSelectedLine];
    }
    
    
}


-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)settingAction
{
    DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
    deviceSetting.cid = self.cid;
    deviceSetting.isShare = (self.devModel.shareState == DevShareStatuOther);
    deviceSetting.devModel = self.devModel;
    //
    deviceSetting.pType = (productType)[self.devModel.pid intValue];
    
    if ([self.devModel.alias isEqualToString:@""]) {
        deviceSetting.alis = self.devModel.uuid;
    }else{
        deviceSetting.alis = self.devModel.alias;
    }
    
    [self.navigationController pushViewController:deviceSetting animated:YES];
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


//顶部标题选择按钮事件
-(void)topTitleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        
        if (sender == _videoTitleLabel) {
            if (self.messageVC.editButton.selected == YES) {
                [_messageVC editButtonAction:_messageVC.editButton];
            }
            if (_messageVC.timeSelectButton.selected == YES) {
                [_messageVC selectDate:_messageVC.timeSelectButton];
            }
            
            if (_videoTitleLabel.selected) {
                
                return ;
            }
            
            self.topTitleSelectedLine.x = self.videoTitleLabel.x;
            _videoTitleLabel.selected = YES;
            _msgTitleLabel.selected = NO;
            if (self.bgScrollerView.contentOffset.x != 0) {
                [self.bgScrollerView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            self.videoPlay.isShow = YES;
             [[NSNotificationCenter defaultCenter]postNotificationName:VideoPlayViewShowingNotification object:nil];
            
            int64_t delayInSeconds = 1.0;
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
               
                
            });
            
            
            
            
        }else{
            
            self.topTitleSelectedLine.x = self.msgTitleLabel.x;
            
            if (_msgTitleLabel.selected) {
                return;
            }
            
            _msgTitleLabel.selected = YES;
            _videoTitleLabel.selected = NO;
            if (self.bgScrollerView.contentOffset.x != self.view.width) {
                [self.bgScrollerView setContentOffset:CGPointMake(self.view.width, 0) animated:YES];
            }
            self.videoPlay.isShow = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:VideoPlayViewDismissNotification object:nil];
            
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                
                
            });
            
            if (self.isClearCount == NO) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearUnReadCount" object:self.cid];
                self.isClearCount = YES;
            }
            
        }
        
    }];
    [self interceptContol];
}


-(UIView *)topBarBgView
{
    if (!_topBarBgView) {
        _topBarBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 64)];
        //_topBarBgView.backgroundColor = [UIColor colorWithHexString:@"#0da9cf"];
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
        _topBarBgView.userInteractionEnabled = YES;
    }
    return _topBarBgView;
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(2, 18, 50, 50);
        [_backBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(UIButton *)settingBtn
{
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.frame = CGRectMake(self.view.width-44-5, 20, 44, 44);
        [_settingBtn setImage:[UIImage imageNamed:@"camera_ico_install"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        [_settingBtn addSubview:self.redDotImageView];
    }
    return _settingBtn;
}

-(UIButton *)videoTitleLabel
{
    if (!_videoTitleLabel) {
        _videoTitleLabel = [self topTitleButtonWithFrame:CGRectMake(self.view.x-22.5-50, 34, 50, 16) title:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video"]];
        _videoTitleLabel.selected = YES;
        CGSize size = [_videoTitleLabel.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, 16)];
        _videoTitleLabel.width = size.width;
        _videoTitleLabel.left = self.view.x-22.5-size.width;
        //_videoTitleLabel.backgroundColor = [UIColor orangeColor];
    }
    return _videoTitleLabel;
}

-(UIButton *)msgTitleLabel
{
    if (!_msgTitleLabel) {
        _msgTitleLabel = [self topTitleButtonWithFrame:CGRectMake(self.view.x+22.5, 34, 50, 16) title:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Messages"]];
        CGSize size = [_msgTitleLabel.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, 16)];
        _msgTitleLabel.width = size.width;
        _msgTitleLabel.left = self.view.x+22.5;
        //_msgTitleLabel.backgroundColor = [UIColor orangeColor];
    }
    return _msgTitleLabel;
}

-(UIButton *)topTitleButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(topTitleAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UIView *)topTitleSelectedLine
{
    if (!_topTitleSelectedLine) {
        _topTitleSelectedLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 2)];
        _topTitleSelectedLine.center = CGPointMake(self.videoTitleLabel.x, self.videoTitleLabel.bottom+9);
        _topTitleSelectedLine.backgroundColor = [UIColor whiteColor];
    }
    return _topTitleSelectedLine;
}

-(UIScrollView *)bgScrollerView
{
    if (!_bgScrollerView) {
        _bgScrollerView = [[HitTestScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _bgScrollerView.contentSize = CGSizeMake(self.view.width*2, self.view.height-64);
        _bgScrollerView.showsHorizontalScrollIndicator = NO;
        _bgScrollerView.bounces = NO;
        _bgScrollerView.delegate = self;
        _bgScrollerView.pagingEnabled = YES;
        //_bgScrollerView.panGestureRecognizer.delegate = self;
    }
    return _bgScrollerView;
}

-(videoPlay1ViewController *)videoPlay
{
    if (!_videoPlay) {
        _videoPlay = [[videoPlay1ViewController alloc]init];
        _videoPlay.cid = self.cid;
    }
    _videoPlay.devModel = self.devModel;
    
    return _videoPlay;
}


-(MessageViewController *)messageVC{
    if (!_messageVC) {
        _messageVC = [[MessageViewController alloc]init];
        _messageVC.cid = self.cid;
        _messageVC.devModel = self.devModel;
        if (self.devModel.netType == JFGNetTypeOffline) {
            _messageVC.isDeviceOffline = YES;
        }else{
            _messageVC.isDeviceOffline = NO;
        }
        
        CGRect re = _messageVC.view.frame;
        [_messageVC.view setFrame:CGRectMake(re.size.width, 0, re.size.width, re.size.height-64)];

    }
    return _messageVC;
}

-(CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.topBarBgView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#54b2d0"].CGColor,
                           (id)[UIColor colorWithHexString:@"#439ac4"].CGColor,
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
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#23344e"].CGColor,
                           (id)[UIColor colorWithHexString:@"#2b3f5b"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}

- (UIImageView *)redDotImageView
{
    if (_redDotImageView == nil)
    {
        _redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 20, 20)];
        _redDotImageView.image = [UIImage imageNamed:@"bell_red_dot"];
        _redDotImageView.hidden = NO;
    }
    return _redDotImageView;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.videoPlay removeAllNotification];
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
