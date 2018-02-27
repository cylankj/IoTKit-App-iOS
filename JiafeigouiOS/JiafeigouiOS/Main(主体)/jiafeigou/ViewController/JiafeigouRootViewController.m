//
//  JiafeigouRootViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JiafeigouRootViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "FLGlobal.h"
#import "PopAnimation.h"
#import "TimeChangeMonitor.h"
#import "LoginManager.h"
#import <MXParallaxHeader/MXParallaxHeader.h>
#import "jiafeigouTableView.h"
#import "UIColor+FLExtension.h"
#import <JZNavigationExtension/JZNavigationExtension.h>
#import "FLTipsBaseView.h"
#import "FLProressHUD.h"
#import "ApnsManger.h"
#import "EfamilyRootVC.h"
#import "JfgMsgDefine.h"
#import "LoginRegisterViewController.h"
#import "QRViewController.h"
#import "AddDeviceMainViewController.h"
#import "DoorVideoVC.h"
#import "NetworkMonitor.h"
#import <JFGSDK/MPMessagePackReader.h>
#import "JfgLanguage.h"
#import "ProgressHUD.h"
#import "DeviceSettingViewModel.h"
#import "dataPointMsg.h"
#import "SetDevNicNameViewController.h"
#import "JfgConfig.h"
#import "CommonMethod.h"
#import "JFGEquipmentAuthority.h"
#import "JFGBoundDevicesMsg.h"
#import "LSChatModel.h"
#import "LSBookManager.h"
#import "JFGLogUploadManager.h"
#import "ShareVideoViewController.h"
#import "JFGNetDeclareViewController.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "BaseNavgationViewController.h"
#import "WebChatBindViewController.h"
#import <pop/POP.h>
#import "RegionalizationViewController.h"


@interface JiafeigouRootViewController ()<TimeChangeMonitorDelegate,LoginManagerDelegate,JFGSDKCallbackDelegate>
{
    NSMutableArray *dataArray;
    BOOL stopAnimation;
}
//昵称Lable
@property (nonatomic,strong)UILabel *nickNameLabel;

//问候语Label
@property (nonatomic,strong)UILabel *greetLabel;

//顶部背景图片
@property (nonatomic,strong)UIImageView *topBackgroundImageView;

//添加设备
@property (nonatomic,strong)UIButton *addButton;


@property (nonatomic,strong)jiafeigouTableView *_tableView;


@end

@implementation JiafeigouRootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.title = [JfgLanguage getLanTextStrByKey:@"Tap1_TitleName"];
    
    //添加这个页面数据需要的代理
    [self delegateManager];
    
    //设置头部视图
    [self initHeaderViewForTableView];
    
    [self.view addSubview:self._tableView];
    [self.view addSubview:self.addButton];
    
    //获取账号信息
    [JFGSDK getAccount];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess)
    {
        [ApnsManger registerRemoteNotification:YES];
        //刷新设备列表，防止列表回复过早导致信息丢失
       // [JFGSDK refreshDeviceList];
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"ssessid:%@",[JFGSDK getSession]]];
    
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"addAnimationKey"];
    NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    if (!version ) {
        [self showTipView];
        [self startAddBtnAnimation];
        [[NSUserDefaults standardUserDefaults] setObject:ver forKey:@"addAnimationKey"];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess)
    {
        [ApnsManger registerRemoteNotification:NO];
    }
}

-(void)orientationChanged:(NSNotification *)notification
{
    //UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
}

-(void)viewDidAppear:(BOOL)animated
{
    //开启波浪滚动
    [self._tableView startRipple];
    [self._tableView loginStatueChick];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
    
    NSString *devName = [NSString stringWithUTF8String:object_getClassName(self)];
    NSLog(@"vcName:%@",devName);
    //[JFGSDK refreshDeviceList];
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //关闭波浪滚动
    [self._tableView stopRipple];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [super viewDidDisappear:animated];
}



-(void)delegateManager
{
    //添加时间变化代理
    [[TimeChangeMonitor sharedManager] starTimer];
    [[TimeChangeMonitor sharedManager] addDelegate:self];
    [[LoginManager sharedManager] addDelegate:self];
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpingRootView) name:@"JFGJumpingRootView" object:nil];
}

-(void)jumpingRootView
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

//创建tableView头部相关视图
-(void)initHeaderViewForTableView
{
    topBgViewHeight = ceil(kheight*0.34);
    self.nickNameLabel.text = @"Hi";
    self.topBackgroundImageView.image = [UIImage imageNamed:@"header_bg"];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -topBgViewHeight, self.view.width, topBgViewHeight)];
    [headerView addSubview:self.nickNameLabel];
    [headerView addSubview:self.greetLabel];

    [self._tableView stretchHeaderView:self.topBackgroundImageView subViews:headerView];
    
    [[TimeChangeMonitor sharedManager] timerAction];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        self._tableView.refreshView.hidden = YES;
    }

}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark receive push_msg 
- (void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    @try
    {
        for (DataPointSeg *seg in msgList)
        {
            NSError *error = nil;
            id obj = [MPMessagePackReader readData:seg.value error:&error];
            if (error == nil)
            {
                switch (seg.msgId)
                {
                    /*
                    // 插入SD卡 默认开启 移动侦测
                    case dpMsgBase_SDStatus:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:3] boolValue];
                            int SDCardError = [[obj objectAtIndex:2] intValue];
                            
                            if (isExistSDCard && SDCardError == 0) // SD卡 正常使用
                            {
                                [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_WarnEnable)] withCid:peer SuccessBlock:^(NSMutableDictionary *dic)
                                {
                                    BOOL isWarnEnable = [[dic objectForKey:dpMsgCameraWarnEnableKey] boolValue];
                                    if (isWarnEnable) // 移动侦测 开启
                                    {
                                        DeviceSettingViewModel *settingVM = [[DeviceSettingViewModel alloc] init];
                                        settingVM.cid = peer;
                                        [settingVM updateMotionDection:MotionDetectAbnormal tipShow:NO];
                                    }
                                    
                                } FailBlock:^(RobotDataRequestErrorType error) {
                                    
                                }];
                            }
                            
                        }
                    }
                        break;
                    */
                    // 插入SD卡 默认开启 移动侦测
                    case dpMsgBase_SDCardInfoList:
                    {
                        if ([obj isKindOfClass:[NSArray class]])
                        {
                            BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                            int SDCardError = [[obj objectAtIndex:1] intValue];
                            
                            if (isExistSDCard && SDCardError == 0)
                            {
                                [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_WarnEnable)] withCid:peer SuccessBlock:^(NSMutableDictionary *dic)
                                 {
                                     BOOL isWarnEnable = [[dic objectForKey:dpMsgCameraWarnEnableKey] boolValue];
                                     if (isWarnEnable) // 移动侦测 开启
                                     {
                                         DeviceSettingViewModel *settingVM = [[DeviceSettingViewModel alloc] init];
                                         settingVM.cid = peer;
                                         settingVM.fwVC = self;
                                         [settingVM updateMotionDection:MotionDetectAbnormal tipShow:NO];
                                     }
                                     
                                 } FailBlock:^(RobotDataRequestErrorType error) {
                                     
                                 }];
                            }
                            
                        }
                    }
                        break;
                }
            }
        }
    } @catch (NSException *exception) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jifeigou RootViewControl %@",exception]];
    } @finally {
        
    }
}



#pragma mark- timeChange Delegate
-(void)timeChangeWithCurrentYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *reminderText;

    if (hour>=6 && hour<18) {
        //白天
        reminderText = [JfgLanguage getLanTextStrByKey:@"Tap1_Index_DayGreetings"];
        
    }else{
        //晚上
        reminderText = [JfgLanguage getLanTextStrByKey:@"Tap1_Index_NightGreetings"];
       
    }
    
    if (hour>=6 && hour<18) {
        //白天
        self.topBackgroundImageView.image = [UIImage imageNamed:@"header_bg"];
        [self._tableView setBarViewColor:YES];
    }else{
        //晚上
        self.topBackgroundImageView.image = [UIImage imageNamed:@"bg_top_夜晚"];
        [self._tableView setBarViewColor:NO];
    }
    
    if (![reminderText isEqualToString:self.greetLabel.text]) {
        self.greetLabel.text = reminderText;
    }
    
}

#pragma mark- LoginManagerDelegate
-(void)loginSuccess
{
    [[TimeChangeMonitor sharedManager] timerAction];
    [JFGSDK getAccount];
    [self._tableView loginStatueChick];
    self._tableView.refreshView.hidden = NO;
}

//退出登录
-(void)loginOut
{
    self._tableView.refreshView.hidden = YES;
    [[TimeChangeMonitor sharedManager] timerAction];
    self.nickNameLabel.text = @"Hi";
    [self._tableView loginStatueChick];
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (online == NO) {
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
            JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
            [self jfgUpdateAccount:acc];
        }
    }
}

#pragma mark- JFGSDKDelegate
-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    if (account) {
        
        if (account.alias && ![account.alias isEqualToString:@""]) {
            
            NSMutableString *newStr = [NSMutableString new];
            int j=0;
            for(int i =0; i < [account.alias length]; i++)
            {
                NSString *temp = [account.alias substringWithRange:NSMakeRange(i, 1)];
                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1) {
                    j = j+2;
                }else{
                    j++;
                }
                if (j<=16) {
                    [newStr appendString:temp];
                }else{
                    [newStr appendString:@"..."];
                    break;
                }
            }

            
            self.nickNameLabel.text = [NSString stringWithFormat:@"Hi,%@...",newStr];
            
        }else{
            
            NSMutableString *newStr = [NSMutableString new];
            int j=0;
            for(int i =0; i < [account.account length]; i++)
            {
                NSString *temp = [account.account substringWithRange:NSMakeRange(i, 1)];
                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1) {
                    j = j+2;
                }else{
                    j++;
                }
                if (j<=16) {
                    [newStr appendString:temp];
                }else{
                    [newStr appendString:@"..."];
                    break;
                }
            }
            self.nickNameLabel.text = [NSString stringWithFormat:@"Hi,%@...",newStr];
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JFGAccountIsOpnePush"];
        [[NSUserDefaults standardUserDefaults] setBool:account.pushEnable forKey:@"JFGAccountIsOpnePush"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}



//门铃被动呼叫,要保持一直能收到回调
- (void)jfgDoorbellCall:(JFGSDKDoorBellCall *)call {
    NSLog(@"收到门铃呼叫");
    
    if (call.isAnswer) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"doorBellCall:%@ isAnswered",call.cid]];
        return;
    }
    
    BOOL isExist = NO;
    NSMutableArray <JiafeigouDevStatuModel *> *cidList = [JFGBoundDevicesMsg sharedDeciceMsg].getDevicesList;
    for (JiafeigouDevStatuModel *model in cidList) {
        
        if ([model.uuid isEqualToString:call.cid]) {
            isExist = YES;
            break;
        }
        
    }
    if (!isExist || !call.cid) {
        return;
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"doorBellCall:%@",call.cid]];
    
    NSString *playingCid = [[NSUserDefaults standardUserDefaults] objectForKey:JFGDoorBellIsPlayingCid];
    
    if (playingCid && [playingCid isEqualToString:call.cid]) {
        return;
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:JFGDoorBellIsCallingKey])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGDoorBellIsCallingKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:JFGDoorBellIsCallingKey object:call.cid];
            //30s 后恢复为呼叫状态，防止其他页面忘记恢复
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetDoorBellCallStatues) object:nil];
            [self performSelector:@selector(resetDoorBellCallStatues) withObject:nil afterDelay:20];
            DoorVideoVC *doorVideo = [[DoorVideoVC alloc] init];
            doorVideo.pType = productType_DoorBell;
            doorVideo.cid = call.cid;
            doorVideo.actionType = doorActionTypeUnActive;
            ///[cid]/[timestamp].jpg
            NSString *imageUrl = [JFGSDK getCloudUrlWithFlag:call.regionType fileName:[NSString stringWithFormat:@"/%@/%d.jpg",call.cid,call.time]];
            doorVideo.imageUrl = imageUrl;
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"门铃呼叫截图：%@",imageUrl]];
          
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showDoorBellCallingVC" object:nil];
            
            
            UIViewController *vc = [self getCurrentVC];
            if ([vc isKindOfClass:[RegionalizationViewController class]]) {

                [vc presentViewController:doorVideo animated:YES completion:nil];

            }else{
            
                UIWindow * window = [UIApplication sharedApplication].keyWindow;
                UITabBarController * barCon = (UITabBarController *)window.rootViewController;
                if ([barCon isKindOfClass:[UITabBarController class]]) {
                    
                    UINavigationController * nav = barCon.viewControllers[barCon.selectedIndex];
                    doorVideo.hidesBottomBarWhenPushed = YES;
                    [nav pushViewController:doorVideo animated:YES];
                }
                
            }
        }
    }
}

-(void)resetDoorBellCallStatues
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:JFGDoorBellIsCallingKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGDoorBellIsCallingKey];
    }
}

#pragma mark- action
-(void)addBtnAction
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut)
    {
        LoginRegisterViewController *loginRegister = [LoginRegisterViewController new];
        loginRegister.viewType = FristIntoViewTypeLogin;
        BaseNavgationViewController *nav = [[BaseNavgationViewController alloc]initWithRootViewController:loginRegister];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        
    }else{
        
        AddDeviceMainViewController *addDevice = [AddDeviceMainViewController new];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:addDevice];
        nav.navigationBarHidden = YES;
        addDevice.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:addDevice animated:YES];
        
       
        
    }
    [self.addButton setImage:[UIImage imageNamed:@"btn_addto"] forState:UIControlStateNormal];
    [self stopAddBtnAnimation];
    
}


#pragma mark- getter
//创建顶部背景视图
-(UIImageView *)topBackgroundImageView
{
    if (_topBackgroundImageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, topBgViewHeight)];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _topBackgroundImageView = imageView;
        
    }
    return _topBackgroundImageView;
    
}

//创建昵称Label
-(UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        CGFloat height = 29;
        CGFloat nickNameLabelWidth = 200;
        CGFloat nickNameFontSize = 27;
        CGFloat center_y = ceil(kheight*0.34)*0.5;
        _nickNameLabel = [self factoryLabelWithFrame:CGRectMake(self.view.x-nickNameLabelWidth*0.5, 75, nickNameLabelWidth, height) fontSize:nickNameFontSize];
        _nickNameLabel.bottom = center_y;
        _nickNameLabel.tag = 10001;
    }
    return _nickNameLabel;
}


//创建问候语Label
-(UILabel *)greetLabel
{
    if (!_greetLabel) {
        CGFloat height = 15;
        CGFloat width = self.view.width-100;
        CGFloat fontSize = 17;
        CGFloat center_y = ceil(kheight*0.34)*0.5;
        _greetLabel = [self factoryLabelWithFrame:CGRectMake(self.view.x-width*0.5, self.nickNameLabel.bottom+13, width, height) fontSize:fontSize];
        _greetLabel.top = center_y+13;
        _greetLabel.tag = 10002;
    }
    return _greetLabel;
}

-(UILabel *)factoryLabelWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = [UIColor colorWithHexString:@"#ffffff"];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 3;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//创建添加设备按钮
-(UIButton *)addButton
{
    if (!_addButton) {
        CGFloat width = 35+4;
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:@"addAnimationKey"];
//        NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        if (!version) {
            [addBtn setImage:[UIImage imageNamed:@"btn_add-to"] forState:UIControlStateNormal];
        }else{
            [addBtn setImage:[UIImage imageNamed:@"btn_addto"] forState:UIControlStateNormal];
        }
        addBtn.frame = CGRectMake(self.view.width-width-15+5, 30-5-2, width, width);
        addBtn.right = self.view.width - 10;
        addBtn.top = 64-39;
        [addBtn addTarget:self action:@selector(addBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _addButton = addBtn;
        
    }
    return _addButton;
}

-(void)startAddBtnAnimation
{
    __weak typeof(self) weakself = self;
    [self popAnimationForScaleXY:CGSizeMake(1.2, 1.2) completionBlock:^{
       
        [weakself popAnimationForScaleXY:CGSizeMake(1, 1) completionBlock:^{
            if (!stopAnimation) {
                [weakself startAddBtnAnimation];
            }else{
                [self.addButton pop_removeAnimationForKey:@"AlphaUp"];
                [self.addButton pop_removeAnimationForKey:@"scalingUp"];
            }
            
        }];
    }];
    
    [self popAnimationForAlpha:0.5 completionBlock:^{
       [weakself popAnimationForAlpha:1 completionBlock:^{
           
       }];
    }];
}

-(void)popAnimationForAlpha:(CGFloat)alpha
                     completionBlock:(void(^)(void))completionBlock
{
    [self.addButton pop_removeAnimationForKey:@"AlphaUp"];
    POPBasicAnimation *_scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    _scaleAnimation.duration = 1;
    _scaleAnimation.toValue = @(alpha);
    [self.addButton pop_addAnimation:_scaleAnimation forKey:@"AlphaUp"];
    _scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
        
        if (completionBlock) {
            completionBlock();
        }
        
    };
    
}

-(void)popAnimationForScaleXY:(CGSize)size
                     completionBlock:(void(^)(void))completionBlock
{
    [self.addButton pop_removeAnimationForKey:@"scalingUp"];
    POPBasicAnimation *_scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    _scaleAnimation.duration = 1;
    _scaleAnimation.toValue = [NSValue valueWithCGSize:size];
    [self.addButton pop_addAnimation:_scaleAnimation forKey:@"scalingUp"];
    _scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished){
        
        if (completionBlock) {
            completionBlock();
        }
        
    };
}

-(void)stopAddBtnAnimation
{
    stopAnimation = YES;
}

-(UITableView *)_tableView
{
    if (!__tableView) {
        __tableView = [[jiafeigouTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-44) style:UITableViewStylePlain];
        __tableView.tableFooterView = [UIView new];
        __tableView.showsVerticalScrollIndicator = NO;
        
//        打包机 升级Xcode 后在兼容， 暂时屏蔽
        if (@available(iOS 11.0, *)) {
            __tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return __tableView;
}

#pragma mark- 显示引导tip
//显示引导tip
-(void)showTipView
{
    FLTipsBaseView *tipBaseView = [FLTipsBaseView tipBaseView];
    
    
    UIView *tipBgView = [[UIView alloc]initWithFrame:CGRectMake(Kwidth-10-132, self.addButton.bottom+10, 132, 46)];
    tipBgView.backgroundColor = [UIColor clearColor];
    [tipBaseView addTipView:tipBgView];
    
    
    UIImageView *roleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(tipBgView.width-11-12, 0, 12, 6)];
    roleImageView.image = [UIImage imageNamed:@"tip_bg"];
    [tipBgView addSubview:roleImageView];
    
    
    UIImageView *tipbgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, roleImageView.bottom, 132, 40)];
    tipbgImageView.image = [UIImage imageNamed:@"tip_bg2"];
    
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 112, 20)];
    tipLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Add_Tips"];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:13];
    [tipbgImageView addSubview:tipLabel];
    
    [tipBgView addSubview:tipbgImageView];
    
    [tipBaseView show];
}


- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"JiaFeiGouRootViewController");       
}


@end
