//
//  AppDelegate.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/5/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "JiafeigouRootViewController.h"
#import "MineRootViewController.h"
#import "GeTuiSdk.h"
#import "MessageViewController.h"
#import "ExploreRootViewController.h"
#import "JfgMsgDefine.h"
#import "DoorVideoVC.h"
#import "GuideViewController.h"
#import "NetworkMonitor.h"
#import <JFGSDK/JFGSDK.h>
#import "LoginManager.h"
#import "AppDelegate+JFGSDK.h"
#import "AppDelegate+GlobalConfig.h"
#import "UIColor+FLExtension.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "JfgDataTool.h"
#import "WXApi.h"
#import "commonMethod.h"
#import "ApnsManger.h"
#import "CardViewController.h"
#import "LoginLoadingViewController.h"
#import "FLShareSDKHelper.h"
#import "VideoChatVC.h"
#import "JfgLanguage.h"
#import "JFGBoundDevicesMsg.h"
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import <Bugly/Bugly.h>
#import "VideoPlayViewController.h"
#import "BellViewController.h"
#import "WeiboSDK.h"
#import "PLeakSniffer.h"
#import "JFGWebViewController.h"
#import "AdView.h"
#import "SlidePageViewController.h"
#import "BaseNavgationViewController.h"
#import "OemManager.h"
#import "LSAlertView.h"
#import "MsgFor720ViewController.h"

#define USERGETUISDK 1   //是否使用个推sdk

@interface AppDelegate ()<UIAlertViewDelegate, GeTuiSdkDelegate, BuglyDelegate, AdDelegate>
@property (nonatomic, strong) AdView *ad;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self config];
    
    //开启网络监测
    [[NetworkMonitor sharedManager] starMonitor];
    
    //JFGSDK初始化
    [self jfgSDKInitialize];
    
    //初始化SHARESDk
    [FLShareSDKHelper registerPlatforms];
    
    
    [self customizeBuglySDKConfig];
    
    /**
     有几种情况：
     1、3.1.0.000    升级版本（需要引导）
     2、3.2.0.000    升级版本（需要引导）
     3、3.2.1.000    升级版本（需要引导）
     4、3.2.1.100    补丁版本（不需要引导）
     */
    //判断是否已经登录
    
    BOOL isShowLoadViewVC = YES;//是否显示引导页
    
    NSString *ver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [Bugly setUserValue:ver forKey:@"BundleVersion"];
    NSArray *verArr = [ver componentsSeparatedByString:@"."];
    NSMutableString *verPrefix = [[NSMutableString alloc]init];
    for (int i=0; i<verArr.count; i++) {
        if (i<3) {
            [verPrefix appendString:verArr[i]];
        }
    }
    int currentVerNumber = [verPrefix intValue];
    
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    
    //测试升级引导页显示情况代码
    //[userDefault removeObjectForKey:@"OLD_VERSION"];
    
    NSString *lastTimeVer = [userDefault objectForKey:@"OLD_VERSION"];
    if (lastTimeVer) {
        NSArray *lastverArr = [lastTimeVer componentsSeparatedByString:@"."];
        NSMutableString *lastverPrefix = [[NSMutableString alloc]init];
        for (int i=0; i<lastverArr.count; i++) {
            if (i<3) {
                [lastverPrefix appendString:lastverArr[i]];
            }
        }
        int lastVerNumber = [lastverPrefix intValue];
        if (currentVerNumber == lastVerNumber) {
            isShowLoadViewVC = NO;
        }
    }
    
    if ([OemManager oemType] == oemTypeCell_C && isShowLoadViewVC) {
        
        [[NSUserDefaults standardUserDefaults] setObject:ver forKey:@"OLD_VERSION"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGShowDemoForExploreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //首次进入设置可更新账号信息
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGAccountMsgChangedKey];
        isShowLoadViewVC = NO;
        
    }
    
    if (isShowLoadViewVC){
        //第一次登陆
        //首次运行标记
        [[NSUserDefaults standardUserDefaults] setObject:ver forKey:@"OLD_VERSION"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGShowDemoForExploreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self goToGuideViewController];
        //首次进入设置可更新账号信息
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGAccountMsgChangedKey];
        
    }else{
        
        if ([LoginManager sharedManager].currentLoginedAcount && ![[LoginManager sharedManager] isExited])
        {
            //已经登录过,跳转到加菲狗主页
            [[LoginManager sharedManager] loginForLastTimeAccount];
            JFGBaseTabBarViewController *tab = [self goToJFGViewContrller];
            [tab.view addSubview:self.ad];
            
        }else{
            
            //未登录,跳转到欢迎页
            LoginLoadingViewController *lo = [LoginLoadingViewController new];
            [lo.view addSubview:self.ad];
            BaseNavgationViewController * nav = [[BaseNavgationViewController alloc]initWithRootViewController:lo];
            self.window.rootViewController = nav;
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGDoorBellIsCallingKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:JFGDoorBellIsPlayingCid];
    [self.window makeKeyAndVisible];
    //检查AppStore版本
//    [self checkAppStoreVersion];
    
    NSDictionary* pushInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushInfo)
    {
        NSDictionary *apsInfo = [pushInfo objectForKey:@"aps"];
        if(apsInfo)
        {
            [JFGSDK appendStringToLogFile:@"didFinishLaunchingWithOptions"];
            [self apnsMsgHandle:apsInfo isFromFinishLauch:YES];
        }
        
    }
    
    //扬声器改变通知处理
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:)  name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];

    return YES;
}


- (void)routeChange:(NSNotification*)notify{
    if(notify){
        NSLog(@"声音声道改变%@",notify);
    }
    AVAudioSessionRouteDescription*route = [[AVAudioSession sharedInstance]currentRoute];
    for (AVAudioSessionPortDescription * desc in [route outputs]) {
        NSLog(@"当前声道%@",[desc portType]);
        NSLog(@"输出源名称%@",[desc portName]);
        if ([[desc portType] isEqualToString:@"Headphones"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            });
        }
    }
}

-(UITabBarItem *)tabBarItemWithNomalImage:(UIImage *)nomalImage selectedImage:(UIImage *)selectedImage title:(NSString *)title
{
    //图片需设置渲染模式为原始模式，不然会被渲染成蓝色
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:title image:[nomalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    //选中文字颜色
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#353c41"],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    //未选中文字颜色
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#929292"],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    return tabBarItem;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12358 && buttonIndex == 1) {
        
        NSString  *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",@"922810939"];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [JFGSDK appendStringToLogFile:@"didReceiveRemoteNotification"];
    [self apnsMsgHandle:userInfo isFromFinishLauch:NO];
}

//全局禁止使用第三方输入法
//- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
//{
//    return NO;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [ApnsManger clearApplicationIconBadge];
    
    [JFGSDK appendStringToLogFile:@"begin background"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [ApnsManger clearApplicationIconBadge];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [JFGSDK appendStringToLogFile:@"end background"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (USERGETUISDK) {
        [ApnsManger keepSysDeviceToken:token];
    }else{
        [JFGSDK deviceTokenUploadForString:token tokenType:1];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"failed register token error :[%@]",[error description]]];
}


#pragma mark
#pragma mark  -- 页面跳转

//跳转到欢迎页面
-(void)goToGuideViewController
{
    SlidePageViewController * guideViewController = [[SlidePageViewController alloc]init];
    BaseNavgationViewController * nav = [[BaseNavgationViewController alloc]initWithRootViewController:guideViewController];
    self.window.rootViewController = nav;
}

// 跳转到"加菲狗"栏目
-(JFGBaseTabBarViewController *)goToJFGViewContrller
{
    //加菲狗Nav
    UINavigationController *jfgNav = [[UINavigationController alloc]initWithRootViewController:[JiafeigouRootViewController new]];
    jfgNav.navigationBar.hidden = YES;
    jfgNav.tabBarItem = [self tabBarItemWithNomalImage:[UIImage imageNamed:@"ico_cleve-dog_normal-拷贝"] selectedImage:[UIImage imageNamed:@"ico_cleve-dog"] title:[JfgLanguage getLanTextStrByKey:@"Tap1_TitleName"]];
    
    //我的Nav
    MineRootViewController *mineVC = [MineRootViewController new];
    UINavigationController *mineNav = [[UINavigationController alloc]initWithRootViewController:mineVC];
    mineNav.tabBarItem = [self tabBarItemWithNomalImage:[UIImage imageNamed:@"ico_mine_normal"] selectedImage:[UIImage imageNamed:@"ico_mine"] title:[JfgLanguage getLanTextStrByKey:@"Tap3_TitleName"]];
    
    //探索Nav
    UINavigationController *expNav = [[UINavigationController alloc]initWithRootViewController:[ExploreRootViewController new]];
    expNav.tabBarItem = [self tabBarItemWithNomalImage:[UIImage imageNamed:@"ico_wondenful_normal"] selectedImage:[UIImage imageNamed:@"ico_wondenful"] title:[JfgLanguage getLanTextStrByKey:@"Tap2_TitleName"]];
    
    //TabBarController
    JFGBaseTabBarViewController *tabController = [[JFGBaseTabBarViewController alloc]init];
    tabController.viewControllers = @[jfgNav,expNav,mineNav];
    [tabController.tabBar setShadowImage:[UIImage new]];
    self.window.rootViewController = nil;
    self.window.rootViewController = tabController;
    
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //获取未读数
        [mineVC getUnreadCount];
        
    });
    
    
    return tabController;
}

// 接收apns消息 处理
- (void)apnsMsgHandle:(NSDictionary *)pushDict isFromFinishLauch:(BOOL)isFromFinishLauch
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@" receive apns msg pushDict %@  appState[%ld]", pushDict, (long)[UIApplication sharedApplication].applicationState]];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        NSString *customStr = nil;
        
        if (isFromFinishLauch)
        {
            customStr = [pushDict objectForKey:@"custom"];
        }else{
            customStr = [pushDict valueForKeyPath:@"aps.custom"];
        }
        
        if (![customStr isEqualToString:@""] && customStr != nil)
        {
            [GeTuiSdk handleRemoteNotification:pushDict];
            
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"['] "];
            customStr = [[customStr componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
            NSArray *apsArray = [customStr componentsSeparatedByString:@","];
            
            @try {
                if (apsArray.count > 2)
                {
                    switch ([[apsArray objectAtIndex:0] intValue])
                    {
                        case JfgMsgType_BellActiveCall:
                        {
                            
                            /**
                             
                             custom = "[2516,'500000000250','',1489385652,'http://oss-cn-hangzhou.aliyuncs.com/jiafeigou-yf/500000000250/1489385652.jpg?OSSAccessKeyId=xjBdwD1du8lf2wMI&Expires=1489990454&Signature=CPDiDx3uNWGvFttaTavVciR2fkw%3D']";
                             
                             */
                            NSString *cid = apsArray[1];
                            NSString *timestamp = @"0";
                            if (apsArray.count>3) {
                                timestamp = apsArray[3];
                            }
                            NSString *imageUrl = @"";
                            if (apsArray.count>4) {
                                imageUrl = apsArray[4];
                            }
                            [self gotoDoorCallVC:cid imageUrl:imageUrl timestamp:[timestamp longLongValue]];
                        }
                            break;
                        default:
                        {
                            JiafeigouDevStatuModel *devModel = nil;
                            NSMutableArray * deviList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
                            for (JiafeigouDevStatuModel *model in deviList) {
                                if ([model.uuid isEqualToString:[apsArray objectAtIndex:2]]) {
                                    if (model.unReadMsgCount == 0) {
                                        model.unReadMsgCount = 1;
                                    }
                                    devModel = model;
                                    break;
                                }
                            }
                            
                            if (devModel) {
                                
                                if ([CommonMethod devBigTypeForOS:devModel.pid] == JFGDevBigTypeEyeCamera) {
                                    
                                    MsgFor720ViewController *msg = [MsgFor720ViewController new];
                                    msg.cid = devModel.uuid;
                                    msg.devModel = devModel;
                                    UIWindow * window = [UIApplication sharedApplication].keyWindow;
                                    UITabBarController * barCon = (UITabBarController *)window.rootViewController;
                                    barCon.selectedIndex = 0;
                                    UINavigationController * nav = barCon.viewControllers[0];
                                    msg.hidesBottomBarWhenPushed = YES;
                                    [nav pushViewController:msg animated:YES];
                                    
                                }else{
                                    
                                    VideoPlayViewController *videoPlayVC = [[VideoPlayViewController alloc] initWithMessage];
                                    videoPlayVC.cid = [apsArray objectAtIndex:2];
                                    videoPlayVC.devModel = devModel;
                                    UIWindow * window = [UIApplication sharedApplication].keyWindow;
                                    UITabBarController * barCon = (UITabBarController *)window.rootViewController;
                                    barCon.selectedIndex = 0;
                                    UINavigationController * nav = barCon.viewControllers[0];
                                    videoPlayVC.hidesBottomBarWhenPushed = YES;
                                    [nav pushViewController:videoPlayVC animated:YES];
                                }
                            }                
                        }
                            break;
                    }
                }
            } @catch (NSException *exception) {
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"appDelegate exception: %@", [exception description]]];
            } @finally {
                
            }
            
        }
        else
        {
            
        }
    }
    
}

-(void)gotoDoorCallVC:(NSString *)cid imageUrl:(NSString *)url timestamp:(long long)timestamp
{
    
    if (cid == nil || [cid isEqualToString:@""]) {
        [JFGSDK appendStringToLogFile:@"cid为空"];
        return;
    }
    
    uint64_t time = [[NSDate date] timeIntervalSince1970];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"apns推送时间：%lld  当前时间:%lld",timestamp,time]];
    
    if (time - timestamp > 30) {
        
        static BOOL isIntoDoorBellRecordVC = NO;
        if (!isIntoDoorBellRecordVC) {
    
            //isIntoDoorBellRecordVC = YES;
            VideoPlayViewController *videoPlayVC = [[VideoPlayViewController alloc] initWithMessage];
            videoPlayVC.cid = cid;
            NSMutableArray * deviList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
            for (JiafeigouDevStatuModel *model in deviList) {
                if ([model.uuid isEqualToString:cid]) {
                    if (model.unReadMsgCount == 0) {
                        
                        //为了跳转消息页面
                        model.unReadMsgCount = 1;
                    }
                    videoPlayVC.devModel = model;
                    break;
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showDoorBellCallingVC" object:nil];
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            UITabBarController * barCon = (UITabBarController *)window.rootViewController;
            if ([barCon isKindOfClass:[UITabBarController class]]) {
                 
                UINavigationController * nav = barCon.viewControllers[barCon.selectedIndex];
                videoPlayVC.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:videoPlayVC animated:YES];
            }
            
            
            int64_t delayInSeconds = 30.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                isIntoDoorBellRecordVC = NO;
                
            });
            
        }
    }else{
        
        NSString *playingCid = [[NSUserDefaults standardUserDefaults] objectForKey:JFGDoorBellIsPlayingCid];
        if (playingCid && [playingCid isEqualToString:cid]) {
            return;
        }
       
        if (![[NSUserDefaults standardUserDefaults] boolForKey:JFGDoorBellIsCallingKey])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGDoorBellIsCallingKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:JFGDoorBellIsCallingKey object:cid];
            //30s 后恢复为呼叫状态，防止其他页面忘记恢复
            [self performSelector:@selector(resetDoorBellCallStatues) withObject:nil afterDelay:30];
            DoorVideoVC *doorVideo = [[DoorVideoVC alloc] init];
            doorVideo.pType = productType_DoorBell;
            doorVideo.cid = cid;
            doorVideo.actionType = doorActionTypeUnActive;
            ///[cid]/[timestamp].jpg
            
            doorVideo.imageUrl = url;
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"apns 门铃呼叫截图：%@",url]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showDoorBellCallingVC" object:nil];
            
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            UITabBarController * barCon = (UITabBarController *)window.rootViewController;
            if ([barCon isKindOfClass:[UITabBarController class]]) {
                barCon.selectedIndex = 0;
                UINavigationController * nav = barCon.viewControllers[0];
                doorVideo.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:doorVideo animated:YES];
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

- (void)customizeBuglySDKConfig
{
    BuglyConfig *buglyConfig = [[BuglyConfig alloc] init];
    buglyConfig.delegate = self;
    buglyConfig.blockMonitorEnable = YES;
    buglyConfig.blockMonitorTimeout = 3.0f;
    buglyConfig.debugMode = YES;
    
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"deviceType:[%@]  currentOS: [%f]",[CommonMethod deviceType], [[UIDevice currentDevice].systemVersion floatValue]]];
    [Bugly startWithAppId:buglyAppID config:buglyConfig];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"bugly sysVersion:%f",[[UIDevice currentDevice].systemVersion floatValue]]];
    
}

- (NSString * BLY_NULLABLE)attachmentForException:(NSException * BLY_NULLABLE)exception
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"----- Crash excaption ：\n %@",exception]];
    return exception.name;
}


#pragma mark
#pragma mark GeTui SDK
- (void)initGtSDK
{
    if (USERGETUISDK) {
        [GeTuiSdk startSdkWithAppId:[ApnsManger geTuiAppID] appKey:[ApnsManger geTuiAppKey] appSecret:[ApnsManger geTuiAppSecret] delegate:self];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"getui init version [%@]", [GeTuiSdk version]]];
    }
}

#pragma mark
#pragma mark   advertisement
- (AdView *)ad
{
    if (_ad == nil)
    {
        _ad = [[AdView alloc] initWithFrame:self.window.bounds];
        _ad.delegate = self;
    }
    
    return _ad;
}

- (void)watchAd:(NSString *)adUrlString
{
    
    JFGWebViewController *webView = [[JFGWebViewController alloc] init];
    webView.type = webViewTypeAd;
    webView.urlString = adUrlString;
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UITabBarController * barCon = (UITabBarController *)window.rootViewController;
    if ([barCon isKindOfClass:[UITabBarController class]]) {
        
        UINavigationController * nav = barCon.viewControllers[barCon.selectedIndex];
        webView.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:webView animated:YES];
    }
}

- (void)skipAction
{
//    [self.ad removeFromSuperview];
}

#pragma mark
#pragma mark kGtSDK Delegate
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId
{
    [ApnsManger keeptGtClientID:clientId];
    
}
/** SDK       */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"\n>>>[GeTuiSdk error]:%@\n\n", [error localizedDescription]]];
}

- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *) taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString * )appId {
    
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
}

#pragma mark -Weixin
-(void)onResp:(BaseResp *)resp
{
    NSLog(@"resp from wechat");
}
@end
