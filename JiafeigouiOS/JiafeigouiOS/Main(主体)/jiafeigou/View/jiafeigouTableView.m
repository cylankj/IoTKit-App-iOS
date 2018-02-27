//
//  jiafeigouTableView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "jiafeigouTableView.h"
#import "CommonMethod.h"
#import <JZNavigationExtension/JZNavigationExtension.h>
#import "jiafeigouTableViewCell.h"
#import <MXParallaxHeader/MXScrollView.h>
#import "UIColor+FLExtension.h"
#import "FLGlobal.h"
#import "UIView+FLExtensionForFrame.h"
#import <QuartzCore/QuartzCore.h>
#import "RippleAnimationView.h"
#import "NothingDevTipView.h"
#import "EfamilyRootVC.h"
#import "jiafeigouTableView+Data.h"
#import "BellViewController.h"
#import "VideoPlayViewController.h"
#import "VideoPlayFor720ViewController.h"
#import "MagViewController.h"
#import "NetworkMonitor.h"
#import "LoginManager.h"
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgMsgDefine.h"
#import "LSAlertView.h"
#import "ProgressHUD.h"
#import "FileManager.h"
#import "jfgConfigManager.h"
#import "JfgCacheManager.h"
#import "JFGGrayPolicyManager.h"
#import "DoorVideoVC.h"
#import "FLLog.h"
#import "PropertyManager.h"

@interface jiafeigouTableView()<MXScrollViewDelegate,NetworkMonitorDelegate,LoginManagerDelegate>
{
    UIView *notNetLabel;
    BOOL isEnableRefresh;
}

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UIView *barView;

@property (nonatomic,strong)RippleAnimationView *rippleView;

@property (nonatomic,strong)CAGradientLayer *dayGradient;

@property (nonatomic,strong)CAGradientLayer *nightGradient;

//无设备提醒视图
@property (nonatomic,strong)NothingDevTipView *addDevReminderBgView;

@property (nonatomic,strong)NSArray *devList;

@end


@implementation jiafeigouTableView
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
    
    BOOL isShowNotNetLabel;
    NSString *delCid;
}


-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
    self.separatorInset = UIEdgeInsetsMake(0,73, 0, 0);
    self.dpReqForLastTimeInterval = 0;
    isEnableRefresh = YES;
    [[NetworkMonitor sharedManager] addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutAccount) name:JFGAccountLoginOutKey object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"JFGTableViewReloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceList) name:BoundDevicesRefreshNotification object:nil];
    [self loginStatueChick];
    [self addDataDelegate];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
             [JFGSDK refreshDeviceList];
        }else{
            [self deviceList];
        }
    }
    return self;
}


-(void)jfgLoginOutByServerWithCause:(JFGErrorType)errorType
{
    [self.dataArray removeAllObjects];
    [self reloadData];
}

-(void)jfgDeviceShareList:(NSDictionary<NSString *,NSArray<JFGSDKFriendRequestInfo *> *> *)friendList
{
    for (NSString *key in friendList.allKeys) {
        
        JiafeigouDevStatuModel *model = [self.dataDict objectForKey:key];
        if (model) {
            NSArray *arr = friendList[key];
            if (arr && arr.count>0) {
                
                if (model.shareState != DevShareStatuOther) {
                    model.shareState = DevShareStatuAlready;
                }
            }
        }
        
    }
    [self reloadData];
}

-(void)loginOutAccount
{
    [self.dataArray removeAllObjects];
    [self reloadData];
}

-(void)loginStatueChick
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut) {
        [self hideHeaderInSection];
        self.refreshView.hidden = YES;
    }else{
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [self hideHeaderInSection];
            self.refreshView.hidden = NO;
        }else{
            [self showHeaderInSection];
            self.refreshView.hidden = YES;
        }
    }
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (online) {
        [self hideHeaderInSection];
        self.refreshView.hidden = NO;
    }else{
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
            [self showHeaderInSection];
        }
        self.refreshView.hidden = YES;
    }
    
}

#pragma mark- 解除绑定结果
-(void)jfgDeviceUnBind:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        
        [JFGGrayPolicyManager resetGrayTime];
        [ProgressHUD dismiss];
        [JFGSDK refreshDeviceList];
        [JFGSDK fping:@"255.255.255.255"];
        if (delCid) {
            //删除720设备
            NSString *filePath1 = [FileManager jfgPano720PhotoDirPath:delCid];
            NSString *filePath2 = [FileManager jfgPano720PhotoThumbnailsPath:delCid];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:filePath1]) {
                [fileManager removeItemAtPath:filePath1 error:nil];
            }
            if ([fileManager fileExistsAtPath:filePath2]) {
                [fileManager removeItemAtPath:filePath2 error:nil];
            }
            [JfgCacheManager removeSfcPatamModelForCid:delCid];
            [JfgCacheManager removeCacheForAIMsgWithCid:delCid];
        }
        
        
    }else{
        
        if (delCid) {
            [[JFGBoundDevicesMsg sharedDeciceMsg] removeDelDeviceCid:delCid];
        }
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_NETWORK_4"]];
        
    }
    
    
}

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if (delCid && [ask.cid isEqualToString:delCid]) {
        [JFGSDK udpSetDevAPForCid:delCid ip:ask.address model:1];
        delCid = nil;
    }
}

//退出登录（其他端修改密码，服务器强制退出以及用户执行loginOut）
-(void)loginOut
{
    [self.dataArray removeAllObjects];
    [self reloadData];
}



#pragma mark- 网络提示
-(void)showHeaderInSection
{
    if (notNetLabel && notNetLabel.hidden == NO) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        notNetLabel.hidden = NO;
        isShowNotNetLabel = YES;
        
        for (JiafeigouDevStatuModel *mode in self.dataArray) {
            mode.netType = JFGNetTypeOffline;
            //mode.unReadMsgCount = 0;
        }
        
        [self reloadData];
    });
   
}

-(void)hideHeaderInSection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        isShowNotNetLabel = NO;
        notNetLabel.hidden = YES;
        [self reloadData];
        
    });
   
}

-(void)networkChanged:(NetworkStatus)statu
{
    if (statu == NotReachable) {
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
            [self showHeaderInSection];
        }
        
    }
    
}


#pragma mark- tableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (isShowNotNetLabel) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, 44)];
        label.text = @"zh";
        label.textColor = [UIColor clearColor];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = YES;
        return label;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isShowNotNetLabel) {
        return 44;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count) {
        [self hideAddDevReminder];
    }else{
        [self showAddDevReminder];
    }
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDForCell = @"jiafeigoucellID";
    jiafeigouTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDForCell];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"jiafeigouTableViewCell" owner:self options:nil]lastObject];
        UIView *selectedBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 80)];
        selectedBackView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        cell.selectedBackgroundView = selectedBackView;
    }
    
    JiafeigouDevStatuModel *dev = [self.dataArray objectAtIndex:indexPath.row];
    
    //别名
    if (dev.alias && ![dev.alias isEqualToString:@""] && ![dev.alias isEqualToString:dev.uuid]) {
        
        
        NSMutableString *newStr = [NSMutableString new];
        int j=0;
        for(int i =0; i < [dev.alias length]; i++)
        {
            NSString *temp = [dev.alias substringWithRange:NSMakeRange(i, 1)];
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
        cell.deviceNickLabel.text = newStr;
        
    }else{

        cell.deviceNickLabel.text = dev.uuid;
       
        
    }
    
    
    UIImage *iconImage = [UIImage imageNamed:dev.iconPath];
    UIImage *disableIconImage = [UIImage imageNamed:dev.offlineIconPath];
    if (!iconImage) {
        iconImage = [UIImage imageNamed:@"ico_camera"];
    }
    if (!disableIconImage) {
        disableIconImage = [UIImage imageNamed:@"ico_camera_Disabled"];
    }
    
    if (dev.netType == JFGNetTypeOffline || dev.netType == JFGNetTypeConnect) {
        cell.deviceImageView.image = disableIconImage;
        
        if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera && [CommonMethod isConnectedAPWithPid:productType_720 Cid:dev.uuid]) {
            cell.deviceImageView.image = iconImage;
        }
       
    }else{
        cell.deviceImageView.image = iconImage;
    }
    
    //未读消息数处理
    [self unreadCountDealForCell:cell devModel:dev];
    
    BOOL showShareIcon = NO;
    //分享状态
    if (dev.shareState == DevShareStatuNot) {
        //无分享
        cell.shareImageView.hidden = YES;
    }else if (dev.shareState == DevShareStatuOther){
        //来自于分享
        cell.shareImageView.hidden = NO;
    }else if (dev.shareState == DevShareStatuAlready){
        //分享给别人了
        cell.shareImageView.hidden = YES;
        showShareIcon = YES;
    }
    //NSLog(@"showShareIcon:%d",showShareIcon);
    //右侧图标
    if (dev.netType == JFGNetTypeOffline || dev.netType == JFGNetTypeConnect) {
        cell.iconImage1.hidden = YES;
        cell.iconImage2.hidden = YES;
        cell.iconImage3.hidden = YES;
        cell.iconImage4.hidden = YES;
        
        if (showShareIcon) {
            cell.iconImage1.hidden = NO;
            cell.iconImage1.image = [UIImage imageNamed:@"ico_share_status"];
        }
        
        if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera){
            // 720全景
            if ([CommonMethod isConnectedAPWithPid:productType_720 Cid:dev.uuid]) {
                BOOL isLowBattery = NO;
                if (dev.Battery <= 20 && !dev.isPower) {
                    isLowBattery = YES;
                }
                
                if (showShareIcon) {
                    cell.iconImage2.hidden = NO;
                    cell.iconImage2.image = [UIImage imageNamed:@"home_icon_ap"];
                    if (dev.delayCamera) {
                        cell.iconImage3.hidden = NO;
                        cell.iconImage3.image = [UIImage imageNamed:@"home_icon_recording"];
                        if (isLowBattery) {
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_battery_status"];
                        }
                        
                    }else{
                        
                        if (isLowBattery) {
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_battery_status"];
                        }
                    }
                }else{
                    cell.iconImage1.image = [UIImage imageNamed:@"home_icon_ap"];
                    cell.iconImage1.hidden = NO;
                    if (dev.delayCamera) {
                        cell.iconImage2.hidden = NO;
                        cell.iconImage2.image = [UIImage imageNamed:@"home_icon_recording"];
                        if (isLowBattery) {
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_battery_status"];
                        }
                        
                    }else{
                        
                        if (isLowBattery) {
                            cell.iconImage2.hidden = NO;
                            cell.iconImage2.image = [UIImage imageNamed:@"ico_battery_status"];
                        }
                    }
                }
                
            }else{
                //cell.deviceMsgLabel.text = [JfgLanguage getLanTextStrByKey:@"OFF_LINE"];
            }
            
        }
        
    }else{
        
        cell.iconImage1.hidden = NO;
        cell.iconImage2.hidden = YES;
        cell.iconImage3.hidden = YES;
        cell.iconImage4.hidden = YES;
        
        if (dev.netType == JFGNetTypeWifi) {
            cell.iconImage1.image = [UIImage imageNamed:@"ico_wifi_status"];
        }else if(dev.netType == JFGNetType2G){
            cell.iconImage1.image = [UIImage imageNamed:@"ico_2g"];
        }else if(dev.netType == JFGNetType3G){
            cell.iconImage1.image = [UIImage imageNamed:@"ico_3g"];
        }else if (dev.netType == JFGNetTypeWired){
            cell.iconImage1.image = [UIImage imageNamed:@"home_icon_wired"];
        }

        
        BOOL isLowBattery = NO;
        if (dev.deviceType == JFGDeviceTypeCamera3G) {
            if (dev.Battery < 50) {
                isLowBattery = YES;
            }
        }else if (dev.deviceType == JFGDeviceTypeDoorBell){
            if (dev.Battery <= 20) {
                isLowBattery = YES;
            }
        }else if (dev.deviceType == JFGDeviceTypeDoorSensor){
            if (dev.Battery < 5) {
                isLowBattery = YES;
            }
        }else if ([dev.pid isEqualToString:@"17"] || [CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera){
            if (dev.Battery <= 20 && !dev.isPower) {
                isLowBattery = YES;
            }
        }
        
        if (isLowBattery) {
            cell.iconImage2.hidden = NO;
            cell.iconImage2.image = [UIImage imageNamed:@"ico_battery_status"];
            
            if (dev.safeFence && dev.shareState != DevShareStatuOther && !dev.safeIdle) {//安全防护
                cell.iconImage3.hidden = NO;
                cell.iconImage3.image = [UIImage imageNamed:@"ico_safety_status"];
                
                if (dev.delayCamera) {//延时摄影开启中
                    cell.iconImage4.hidden = NO;
                    cell.iconImage4.image = [UIImage imageNamed:@"ico_photography_status"];
                    if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
                        cell.iconImage4.image = [UIImage imageNamed:@"home_icon_recording"];
                    }

                }
                
            }else{
                
                if (dev.delayCamera) {//延时摄影开启中
                    cell.iconImage3.hidden = NO;
                    cell.iconImage3.image = [UIImage imageNamed:@"ico_photography_status"];
                    if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
                        cell.iconImage3.image = [UIImage imageNamed:@"home_icon_recording"];
                    }
                    
                    if (showShareIcon) {//已分享
                        cell.iconImage4.hidden = NO;
                        cell.iconImage4.image = [UIImage imageNamed:@"ico_share_status"];
                        
                    }else{
                        
                        if (dev.safeIdle) {//安全待机
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }
                    
                }else{
                    if (showShareIcon) {//已分享
                        cell.iconImage3.hidden = NO;
                        cell.iconImage3.image = [UIImage imageNamed:@"ico_share_status"];
                        
                        if (dev.safeIdle) {
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }else{
                        
                        if (dev.safeIdle) {//安全待机
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }
                }
                
            }
            
        }else{
            
            if (dev.safeFence && dev.shareState != DevShareStatuOther && !dev.safeIdle) {//安全防护
                cell.iconImage2.hidden = NO;
                cell.iconImage2.image = [UIImage imageNamed:@"ico_safety_status"];
                
                if (dev.delayCamera) {//延时摄影开启中
                    cell.iconImage3.hidden = NO;
                    cell.iconImage3.image = [UIImage imageNamed:@"ico_photography_status"];
                    if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
                        cell.iconImage3.image = [UIImage imageNamed:@"home_icon_recording"];
                    }

                    if (showShareIcon) {//已分享
                        cell.iconImage4.hidden = NO;
                        cell.iconImage4.image = [UIImage imageNamed:@"ico_share_status"];
                    }else{
                        
                        if (dev.safeIdle) {//安全待机
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }
                }else{
                    
                    if (showShareIcon) {
                        cell.iconImage3.hidden = NO;
                        cell.iconImage3.image = [UIImage imageNamed:@"ico_share_status"];
                        
                        if (dev.safeIdle) {//安全待机
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                        
                    }else{
                        
                        if (dev.safeIdle) {//安全待机
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                        
                    }
                    
                }
                
            }else{
                
                
                if (dev.delayCamera) {
                    
                    cell.iconImage2.hidden = NO;
                    cell.iconImage2.image = [UIImage imageNamed:@"ico_photography_status"];
                    if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
                        cell.iconImage2.image = [UIImage imageNamed:@"home_icon_recording"];
                    }

                    if (showShareIcon) {
                        cell.iconImage3.hidden = NO;
                        cell.iconImage3.image = [UIImage imageNamed:@"ico_share_status"];
                        if (dev.safeIdle) {
                            cell.iconImage4.hidden = NO;
                            cell.iconImage4.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }else{
                        if (dev.safeIdle) {
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }
                    
                }else{
                    
                    if (showShareIcon) {
                        cell.iconImage2.hidden = NO;
                        cell.iconImage2.image = [UIImage imageNamed:@"ico_share_status"];
                        if (dev.safeIdle) {
                            cell.iconImage3.hidden = NO;
                            cell.iconImage3.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                        
                    }else{
                        if (dev.safeIdle) {
                            cell.iconImage2.hidden = NO;
                            cell.iconImage2.image = [UIImage imageNamed:@"ico_standby_status"];
                        }
                    }
                }
            }
        }
    }
    //[JFGSDK appendStringToLogFile:@"执行刷新cell"];
    //[JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cellForRow[uuid:%@ pid:%@ net:%ld]",dev.uuid,dev.pid,dev.netType]];
    
    return cell;
}

-(void)unreadCountDealForCell:(jiafeigouTableViewCell *)cell devModel:(JiafeigouDevStatuModel *)dev
{
    //未读消息
    cell.devicemsgTimeLabel.text = dev.lastMsgTime;
    cell.unreadRedPoint.hidden = NO;
    BOOL isHiddenRedPoint = NO;
    NSString *msgString = @"";
    NSString *timeString = dev.lastMsg;
    
    if (dev.deviceType == JFGDeviceTypeDoorBell) {
        
        if (dev.unReadMsgCount == 0) {
            msgString = [JfgLanguage getLanTextStrByKey:@"Tap1_NoMessages"];
            timeString = @"";
            isHiddenRedPoint = YES;
        }else if (dev.unReadMsgCount<99){
            msgString = [NSString stringWithFormat:@"[%ld]%@",(long)dev.unReadMsgCount,[JfgLanguage getLanTextStrByKey:@"Tap1_Index_Tips_Newvisitor"]];
        }else{
            msgString = [NSString stringWithFormat:@"[99+]%@",[JfgLanguage getLanTextStrByKey:@"Tap1_Index_Tips_Newvisitor"]];
        }
        
    }else if(dev.shareState != DevShareStatuOther){
        
        int unreadCount = 0;
        if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
            //双鱼眼
            unreadCount = (int)dev.unReadMsgCount+(int)dev.unReadPhotoCount;
            FLLog(@"unReadMsgCount:%d unReadPhotoCount:%d",dev.unReadMsgCount,dev.unReadPhotoCount);
        }else{
            unreadCount = (int)dev.unReadMsgCount;
        }
        
        if (unreadCount == 0) {
            
            msgString = [JfgLanguage getLanTextStrByKey:@"Tap1_NoMessages"];
            timeString = @"";
            isHiddenRedPoint = YES;
            
        }else if (unreadCount<99){
            msgString = [NSString stringWithFormat:@"[%d]%@",unreadCount,[JfgLanguage getLanTextStrByKey:@"MSG_WARNING"]];
        }else{
            msgString = [NSString stringWithFormat:@"[99+]%@",[JfgLanguage getLanTextStrByKey:@"MSG_WARNING"]];
        }
        
    }else if (dev.shareState == DevShareStatuOther){
        
        isHiddenRedPoint = YES;
        timeString = @"";
        msgString = @"";
        
        if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
            //双鱼眼
            int unreadCount = (int)dev.unReadMsgCount+(int)dev.unReadPhotoCount;
            FLLog(@"unReadMsgCount:%d unReadPhotoCount:%d",(int)dev.unReadMsgCount,(int)dev.unReadPhotoCount);
            if (unreadCount == 0 || dev.netType == JFGNetTypeOffline) {
                
                msgString = [JfgLanguage getLanTextStrByKey:@"Tap1_NoMessages"];
                timeString = @"";
                isHiddenRedPoint = YES;
                
            }else if (unreadCount<99){
                msgString = [NSString stringWithFormat:@"[%d]%@",unreadCount,[JfgLanguage getLanTextStrByKey:@"MSG_WARNING"]];
            }else{
                msgString = [NSString stringWithFormat:@"[99+]%@",[JfgLanguage getLanTextStrByKey:@"MSG_WARNING"]];
            }
            
        }
        
    }
    
    cell.unreadRedPoint.hidden = isHiddenRedPoint;
    cell.devicemsgTimeLabel.text = timeString;
    cell.deviceMsgLabel.text = msgString;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *viewControler = [CommonMethod viewControllerForView:self];
    if (viewControler)
    {
        JiafeigouDevStatuModel *dev = [self.dataArray objectAtIndex:indexPath.row];
        
        switch (dev.deviceType)
        {
            case JFGDeviceTypeCamera3G:
            case JFGDeviceTypeCamera4G:
            case JFGDeviceTypeDoorBell:
            case JFGDeviceTypeCameraWifi:
            {
                VideoPlayViewController *video = [[VideoPlayViewController alloc]initWithMessage];
                video.cid = dev.uuid;
                video.devModel = dev;
                video.hidesBottomBarWhenPushed = YES;
                [viewControler.navigationController pushViewController:video animated:YES];
//                DoorVideoVC *doorVideo = [[DoorVideoVC alloc] init];
//                doorVideo.pType = productType_DoorBell;
//                doorVideo.cid = dev.uuid;
//                doorVideo.actionType = doorActionTypeActive;
//                doorVideo.isOnline = YES;
//                ///[cid]/[timestamp].jpg
//                doorVideo.hidesBottomBarWhenPushed = YES;
//                doorVideo.imageUrl = @"";
//                //doorVideo.actionType =
//                [viewControler.navigationController pushViewController:doorVideo animated:YES];
            }
                break;
//            case JFGDeviceTypeDoorBell:
//            {
//                BellViewController *bell = [BellViewController new];
//                bell.hidesBottomBarWhenPushed = YES;
//                bell.cid = dev.uuid;
//                bell.devModel = dev;
//                bell.isShare = isFromOthers;
//                
//                if (dev.netType == JFGNetTypeOffline) {
//                    bell.state = BellStateOffline;
//                }else{
//                    bell.state = BellStateOnline;
//                }
//                if (dev.alias && ![dev.alias isEqualToString:@""]) {
//                    bell.alias = dev.alias;
//                }else{
//                    bell.alias = dev.uuid;
//                }
//                [viewControler.navigationController pushViewController:bell animated:YES];
//            }
//                break;
           
            
            case JFGDeviceTypePanoramicCamera:{
                
                if ([CommonMethod devBigTypeForOS:dev.pid] == JFGDevBigTypeEyeCamera) {
                    
                    VideoPlayFor720ViewController *videoFor720 = [[VideoPlayFor720ViewController alloc]init];
                    videoFor720.devModel = dev;
                    videoFor720.hidesBottomBarWhenPushed = YES;
                    [viewControler.navigationController pushViewController:videoFor720 animated:YES];
                    
                }else{
                    
                    VideoPlayViewController *video = [[VideoPlayViewController alloc]initWithMessage];
                    video.hidesBottomBarWhenPushed = YES;
                    video.cid = dev.uuid;
                    video.devModel = dev;
                    [viewControler.navigationController pushViewController:video animated:YES];
                }
            }
                break;
            
            default:{
                
                VideoPlayViewController *video = [[VideoPlayViewController alloc]initWithMessage];
                video.hidesBottomBarWhenPushed = YES;
                video.cid = dev.uuid;
                video.devModel = dev;
                [viewControler.navigationController pushViewController:video animated:YES];
                
            }
                break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak JiafeigouDevStatuModel *dev = [self.dataArray objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SURE_DELETE_1"],dev.uuid];
        
        if (dev.alias) {
            message = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SURE_DELETE_1"],dev.alias];
        }
        
        [LSAlertView showAlertWithTitle:message Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        } OKBlock:^{
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                [CommonMethod showNetDisconnectAlert];
                return;
            }
            [[JFGBoundDevicesMsg sharedDeciceMsg] addDelDeviceCid:dev.uuid];
            [ProgressHUD showProgress:nil];
            [JFGSDK unBindDev:dev.uuid];
            delCid = dev.uuid;
            
        }];
    }
}

#pragma mark- 添加设备提示
//显示添加设备提醒文本
-(void)showAddDevReminder
{
    if (!_addDevReminderBgView) {
        CGFloat bgHeight = 172;
        CGFloat bgWidth =180;
        
        CGFloat y =  (self.height - ceil(kheight*0.34) - bgHeight)*0.5-10;
        if (y<0) {
            y=0;
        }
        _addDevReminderBgView = [[NothingDevTipView alloc]initWithFrame:CGRectMake((self.width-bgWidth)*0.5, y, bgWidth, bgHeight)];
        [_addDevReminderBgView setTipImage:[UIImage imageNamed:@"pic_tips _none"] title:[JfgLanguage getLanTextStrByKey:@"Tap1_Index_NoDevice"] subTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_AddDeviceTips"]];
        [self addSubview:_addDevReminderBgView];
        
    }
    [self sendSubviewToBack:_addDevReminderBgView];
}

//去除添加设备提示文本
-(void)hideAddDevReminder
{
    if (_addDevReminderBgView) {
        [_addDevReminderBgView removeFromSuperview];
        _addDevReminderBgView = nil;
    }
}


#pragma mark- 顶部视图相关
- (void)stretchHeaderView:(UIView*)view subViews:(UIView*)subview
{
    //设置顶部被拉伸的图片
    self.parallaxHeader.view =view;
    defaultViewHeight = view.size.height;
    
    //设置顶部图片显示区域高度
    self.parallaxHeader.height = defaultViewHeight;
    self.parallaxHeader.mode = MXParallaxHeaderModeTopFill;
    
    //设置上推之后留出的最小距离
    self.parallaxHeader.minimumHeight = 64;
    
    //头部视图上添加模拟的navigationBar,同时也是一个遮罩，随着滚动颜色渐变
    [self.parallaxHeader.view addSubview:self.barView];
    
    //把显示标题的label添加到Bar上
    [self.barView addSubview:self.titleLabel];
    
    //添加到tableview上的视图，会随着tableview的拖拉变动而变动
    //添加文字内容到tableview上（parallaxHeader的height随着滚动会发生改变，位置不可控）
    subview.tag = 10003;
    [self addSubview:subview];
    
    //添加波纹视图
    [self addSubview:self.rippleView];
    [self addSubview:self.refreshView];
    
    [self.refreshView setRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    
    self.refreshView.frame = CGRectMake(0, -defaultViewHeight+30, self.width, 23);
    
    self.refreshView.originOffset_y = defaultViewHeight;
    
    [self createShowNetView];
    
}

-(void)createShowNetView
{
    notNetLabel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 44)];
    notNetLabel.backgroundColor = [UIColor colorWithHexString:@"#fffce1"];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(29, 7, 20, 20)];
    imageView.y = notNetLabel.height*0.5;
    imageView.image = [UIImage imageNamed:@"icon_caution"];
    [notNetLabel addSubview:imageView];
    
    UILabel *nt = [[UILabel alloc]initWithFrame:CGRectMake(64, 0, notNetLabel.width-64, notNetLabel.height)];
    nt.backgroundColor = [UIColor clearColor];
    nt.text = [JfgLanguage getLanTextStrByKey:@"NoNetworkTips"];
    nt.font = [UIFont systemFontOfSize:16];
    nt.textColor =[UIColor colorWithHexString:@"#777777"];
    [notNetLabel addSubview:nt];
    notNetLabel.hidden = YES;
    [self addSubview:notNetLabel];
    [self sendSubviewToBack:notNetLabel];
}

//刷新事件
-(void)headerRereshing
{
    if (isEnableRefresh) {
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [JFGSDK refreshDeviceList];
            [self performSelector:@selector(refreshOverTime) withObject:nil afterDelay:10];
            isEnableRefresh = NO;
            [JFGSDK appendStringToLogFile:@"执行刷新动作"];
        }else{
            [self.refreshView endRefresh];
        }
    }else{
        //刷新间隔3秒
        [self performSelector:@selector(resetRefresh) withObject:nil afterDelay:3];
        [self.refreshView endRefresh];
        NSLog(@"未刷新");
    }
}

-(void)resetRefresh
{
    isEnableRefresh = YES;
}

-(void)refreshOverTime
{
    [self.refreshView endRefresh];
}

#pragma mark- 数据处理
-(void)deviceList
{
    [JFGSDK appendStringToLogFile:@"deviceList"];
    NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    
    self.dataArray = [[NSMutableArray alloc]initWithArray:list];
    self.dataDict = [NSMutableDictionary new];
    
    for (JiafeigouDevStatuModel *mode in self.dataArray) {
        [self.dataDict setObject:mode forKey:mode.uuid];
    }
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        if (self.dpReqForLastTimeInterval > curTime) {
            self.dpReqForLastTimeInterval = 0;
        }
    
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"current:%.0f lastTime:%.0f",curTime,self.dpReqForLastTimeInterval]];
        
        if (curTime - self.dpReqForLastTimeInterval > 2) {
            [self messageList];
            self.dpReqForLastTimeInterval = curTime;
        }
        
    }
    [self.refreshView endRefresh];
    [self reloadData];
}

-(void)messageList
{
    [JFGSDK appendStringToLogFile:@"messageList"];
    
    //每次cid请求限制最多十个，所以对cid进行10个一组的分组处理
    NSMutableArray *groups = [NSMutableArray new];
    [self.dataArray enumerateObjectsUsingBlock:^(JiafeigouDevStatuModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSInteger group = idx/10;
        if (groups.count>group) {
            
            NSMutableArray *g = [groups objectAtIndex:group];
            [g addObject:obj];
            
        }else{
            
            NSMutableArray *g = [[NSMutableArray alloc]init];
            [g addObject:obj];
            [groups addObject:g];
        }
        
    }];
    
    for (NSArray *cidList in groups) {
        [self robotGetDPForMultiDataForDevModels:cidList];
    }
    
    //获取已分享好友列表
    NSMutableArray *cidList = [NSMutableArray new];
    for (JiafeigouDevStatuModel *mode in self.dataArray) {
        //被分享设备不获取已分享设备列表
        if (mode.shareState != DevShareStatuOther) {
            [cidList addObject:mode.uuid];
        }
    }
    [JFGSDK getDeviceSharedListForCids:cidList];
    
}

-(void)robotGetDPForMultiDataForDevModels:(NSArray *)devModels
{
    NSMutableDictionary *dpsDict = [[NSMutableDictionary alloc]init];
    
    for (JiafeigouDevStatuModel *mode in devModels) {
        
        NSMutableArray *msgIDArr = [[NSMutableArray alloc]initWithArray:@[[NSNumber numberWithInt:dpMsgCamera_isLive],[NSNumber numberWithInt:dpMsgBase_Battery],[NSNumber numberWithInt:dpMsgBase_Net],[NSNumber numberWithInt:dpMsgCamera_WarnEnable]]];
        
        
        BOOL isDoorBell = [jfgConfigManager devIsDoorBellForPid:mode.pid];
        //不是被分享设备，获取设备最新一条报警消息时间
        if (mode.shareState != DevShareStatuOther){
            [msgIDArr addObject:[NSNumber numberWithInt:dpMsgCamera_WarnMsg]];
            if ([PropertyManager showPropertiesRowWithPid:[mode.pid intValue] key:pRemoteWatchKey]) {
                [msgIDArr addObject:@404];
            }
        }else{
            if (isDoorBell) {
                [msgIDArr addObject:[NSNumber numberWithInt:dpMsgBell_callMsg]];
            }
        }
        
        //720设备只有两个属性需要获取
        if ([CommonMethod devBigTypeForOS:mode.pid] == JFGDevBigTypeEyeCamera) {
            [msgIDArr removeAllObjects];
            [msgIDArr addObject:[NSNumber numberWithInt:dpMsgBase_Net]];
            [msgIDArr addObject:[NSNumber numberWithInt:dpMsgCamera_WarnMsg]];
            [msgIDArr addObject:[NSNumber numberWithInt:dpMsgCamera_WarnEnable]];
            //获取720设备的电量
            [self battrayFor720WithCid:mode.uuid];
        }
        
        NSMutableArray *msgVerSegArr = [NSMutableArray new];
        for (NSNumber *msgID in msgIDArr) {
            DataPointIDVerSeg *seg = [DataPointIDVerSeg new];
            seg.msgId =[msgID intValue];
            seg.version = 0;
            [msgVerSegArr addObject:seg];
        }
        
#pragma mark- 报警与门铃呼叫未读消息数
        //被分享设备不显示报警消息
        if (mode.shareState == DevShareStatuOther && mode.deviceType != JFGDeviceTypeDoorBell && [CommonMethod devBigTypeForOS:mode.pid] != JFGDevBigTypeEyeCamera ) {
            
            mode.unReadMsgCount = 0;
            
        }else{
            
            //NSMutableArray *unReadMsgIDArr = [NSMutableArray new];
            for (int i =  1001; i<=1006; i++) {
                DataPointIDVerSeg *seg = [DataPointIDVerSeg new];
                seg.msgId = i;
                seg.version = 0;
                [msgVerSegArr addObject:seg];
            }

        }
        [dpsDict setObject:msgVerSegArr forKey:mode.uuid];
        
    }
    
    //安全防护 电量 网络类型 最新报警消息 待机 延时摄影是否开启
    [[JFGSDKDataPoint sharedClient] robotGetMultiDataForReqDict:dpsDict Limit:1 asc:NO success:^(NSDictionary<NSString *,NSDictionary *> *repDict) {
        
        for (NSString *peer in repDict) {
            
            NSDictionary *dic = repDict[peer];
            JiafeigouDevStatuModel *model = [self.dataDict objectForKey:peer];
            for (NSString *msgID in dic) {
                NSArray *segArr = dic[msgID];
                if (segArr.count) {
                    
                    DataPointSeg *seg = [segArr lastObject];
                    
                    switch (seg.msgId) {
                            
                        case dpMsgCamera_isLive:{//待机状态
                            
                            model.safeIdle = NO;
                            id obj = [MPMessagePackReader readData:seg.value error:nil];
                            if ([obj isKindOfClass:[NSArray class]]) {
                                
                                NSArray *arr = obj;
                                if (arr.count>0) {
                                    id obj2 = arr[0];
                                    if ([obj2 isKindOfClass:[NSNumber class]]) {
                                        
                                        BOOL isLive = [obj2 boolValue];
                                        if (isLive) {
                                            model.safeIdle = YES;
                                        }
                                        
                                    }
                                }
                            }
                        }
                            break;
                        case 404:{
                            id obj = [MPMessagePackReader readData:seg.value error:nil];
                            if ([obj isKindOfClass:[NSArray class]]) {
                                
                                NSArray *sourceArr = obj;
                                if (sourceArr.count>2) {
                                    
                                    BOOL isOpen = [sourceArr[0] boolValue];
                                    
                                    int64_t beginTime = [sourceArr[1] longLongValue];
                                    int64_t endTime = [sourceArr[2] longLongValue];
                                    
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                                    [dateFormatter setDateFormat:@"HH"];
                                    int currentHour = [[dateFormatter stringFromDate:[NSDate date]] intValue];
                                    // 0  -- 24
                                    // 22 -- 8
                                    
                                    int setBeginHour = (int)beginTime/60/60;
                                    int setEndHour = (int)endTime/60/60;
                                    
                                    if (isOpen) {
                                        if (setBeginHour < setEndHour) {
                                            //没有跨天
                                            if (currentHour>=setBeginHour && currentHour <= setEndHour) {
                                                model.deepSleep = YES;
                                            }else{
                                                model.deepSleep = NO;
                                            }
                                            
                                            
                                        }else{
                                            //设置时间跨天了
                                            if (currentHour >= setBeginHour || currentHour <= setEndHour) {
                                                model.deepSleep = YES;
                                            }else{
                                                model.deepSleep = NO;
                                            }
                                            
                                        }
                                    }else{
                                        
                                        model.deepSleep = NO;
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                            break;
                            
                        case dpMsgBase_Battery:{//电量
                            
                            if ([CommonMethod devBigTypeForOS:model.pid] == JFGDevBigTypeEyeCamera) {
                                break;
                            }
                            if (model.deviceType == JFGDeviceTypeDoorBell || model.deviceType == JFGDeviceTypeCamera3G || [model.pid isEqualToString:@"17"]) {
                                id obj = [MPMessagePackReader readData:seg.value error:nil];
                                if ([obj isKindOfClass:[NSNumber class]]) {
                                    model.Battery = [obj intValue];
                                }
                                
                            }else{
                                model.Battery = 100;
                            }
                            
                        }
                            break;
                            
                        case dpMsgBase_Net:{//网络状态
                            
                            [self deviceNetworkState:seg devModel:model];
                        }
                            break;
                        case dpMsgBell_callMsg:
                            
                        case dpMsgCamera_WarnMsg:{
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                            NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
                            [formatter setTimeZone:localTimeZone];
                            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:seg.version/1000];
                            NSTimeInterval time= fabs([[NSDate date] timeIntervalSinceDate:confromTimesp]);
                            if (time<=60*5) {
                                model.lastMsgTime = [JfgLanguage getLanTextStrByKey:@"JUST_NOW"];
                            }else if (time <= 60*60*24){
                                [formatter setDateFormat:@"HH:mm"];
                                NSString *t = [formatter stringFromDate:confromTimesp];
                                model.lastMsgTime = t;
                            }else{
                                [formatter setDateFormat:@"YY/MM/dd"];
                                NSString *t = [formatter stringFromDate:confromTimesp];
                                model.lastMsgTime = t;
                            }
                        }
                            break;
                            
                        case dpMsgCamera_WarnEnable:{
                            id obj = [MPMessagePackReader readData:seg.value error:nil];
                            if (obj && [obj isKindOfClass:[NSNumber class]]) {
                                if ([obj boolValue]) {
                                    model.safeFence = YES;
                                }else{
                                    model.safeFence = NO;
                                }
                                
                            }else{
                                model.safeFence = YES;
                            }
                            
                            if (model.deviceType == JFGDeviceTypeDoorBell) {
                                model.safeFence = NO;
                            }
                            
                        }
                            break;
                        case dpMsgCamera_TimeLapse:{
                            id obj = [MPMessagePackReader readData:seg.value error:nil];
                            if ([obj isKindOfClass:[NSArray class]]) {
                                
                                model.delayCamera = NO;
                                NSArray *objArr = obj;
                                if (objArr.count>3) {
                                    id obj1 = objArr[3];
                                    if ([obj1 isKindOfClass:[NSNumber class]]) {
                                        int status = [obj1 intValue];
                                        if (status == 1) {
                                            model.delayCamera = YES;
                                        }
                                    }
                                }
                            }
                        }
                            break;
                        default:
                            break;
                    }
                    
                    
                }
            }
            
            int count = 0;
            for (int i = 1001; i<=1006; i++){
                
                NSArray *segArr_msgID = dic[[NSString stringWithFormat:@"%d",i]];
                if (segArr_msgID.count) {
                    DataPointSeg *seg = [segArr_msgID lastObject];
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        count = [obj intValue] + count;
                    }
                }
                
            }
            model.unReadMsgCount = count;
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self reloadData];
            
        });
        
    } failure:^(RobotDataRequestErrorType type) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }];
}

-(void)battrayFor720WithCid:(NSString *)cid
{
    //电池状态
    DataPointSeg *seg2 = [DataPointSeg new];
    seg2.msgId = 206;
    seg2.value = [NSData data];
    seg2.version = 0;
    
    DataPointSeg *seg3 = [DataPointSeg new];
    seg3.msgId = dpMsgBase_Power;
    seg3.value = [NSData data];
    seg3.version = 0;
    
    [JFGSDK sendDPDataMsgForSockWithPeer:cid dpMsgIDs:@[seg2,seg3]];
    [JFGSDK sendMsgForTcpWithDst:@[cid] isAck:YES fileType:13 msg:[NSData data]];
}


-(void)deviceUnreadCount:(DataPointSeg *)seg devModel:(JiafeigouDevStatuModel *)devModel
{
    
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    //NSLog(@"offset:%f",scrollView.contentOffset.y);
    //parallaxHeader.view的高度
    CGFloat topHeight;
    
    UIView *bgView = [self viewWithTag:10003];
    UILabel *nickLabel = [bgView viewWithTag:10001];
    UILabel *greedLabel = [bgView viewWithTag:10002];
    
    
    if (scrollView.parallaxHeader.progress<0) {
        //上推
        topHeight = scrollView.parallaxHeader.height-fabs(scrollView.parallaxHeader.progress *scrollView.parallaxHeader.height);
    
    }else{
        //下拉
        topHeight = scrollView.parallaxHeader.height+fabs(scrollView.parallaxHeader.progress) *scrollView.parallaxHeader.height;
    }
    
    if (topHeight < 64) {
        return;
    }
    //NSLog(@"topHeight:%f",topHeight);
    //往上滚动了，顶部视图高度小于原始高度
    if (topHeight<defaultViewHeight-2) {
        
        //设置遮罩的高度与顶部视图高度一致
        self.barView.height  = topHeight;
        
        if (fabs(scrollView.contentOffset.y)<defaultViewHeight) {
            
            self.barView.alpha = (defaultViewHeight-topHeight)/(defaultViewHeight-64);
            self.rippleView.alpha = 1-self.barView.alpha;
            greedLabel.alpha = nickLabel.alpha = self.rippleView.alpha;
            
        }
        
    }else{
        
        self.barView.alpha = 0;
        self.barView.height  = topHeight;
        self.rippleView.alpha = 1;
        greedLabel.alpha = 1;
        nickLabel.alpha = 1;
    }
    
    if (topHeight <= 65) {
        
        if (self.titleLabel.hidden) {
            
            self.titleLabel.hidden = NO;
            self.titleLabel.bottom = self.barView.bottom;
            [UIView animateWithDuration:0.5 animations:^{
                self.titleLabel.alpha = 1;
            }];

        }
        
        
   }else{
        
        if (!self.titleLabel.hidden) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.titleLabel.alpha = 0;
            } completion:^(BOOL finished) {
                self.titleLabel.hidden = YES;
            }];
            
        }
       
    }
    
//    CGFloat offset = scrollView.contentOffset.y;
//    if (offset<-65) {
//        
//    }
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"offset:%f",scrollView.contentOffset.y);
    [self.refreshView scrollViewDidEndDrag:scrollView];
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -60, Kwidth, 44)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_TitleName"];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.hidden = YES;
        
    }
    return _titleLabel;
}

-(UIView *)barView
{
    if (!_barView) {
        
        _barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, defaultViewHeight)];
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        if (dateComponent.hour >=6 && dateComponent.hour < 18) {
            [self setBarViewColor:YES];
        }else{
            [self setBarViewColor:NO];
        }
        _barView.alpha = 0;
        
    }
    return _barView;
}

-(void)setBarViewColor:(BOOL)day
{
    if (!day) {
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.nightGradient) {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.nightGradient atIndex:0];
        
    }else{
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.dayGradient) {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.dayGradient atIndex:0];

    }
}

-(RippleAnimationView *)rippleView
{
    if (!_rippleView) {
        CGFloat height = ceil(kheight*0.09);
        _rippleView = [[RippleAnimationView alloc]initWithFrame:CGRectMake(0, -height, self.width, height)];
    }
    return _rippleView;
}

-(void)startRipple
{
    [self.rippleView startTimer];
}

-(void)stopRipple
{
    [self.rippleView stopTimer];
}


-(FLRefreshHeader *)refreshView
{
    if (!_refreshView) {
        _refreshView = [[FLRefreshHeader alloc]initWithFrame:CGRectMake(0, -defaultViewHeight+30, self.width, 23)];
        _refreshView.showType = FLRefreshShowTypeGradually;
        _refreshView.originOffset_y = defaultViewHeight;
        _refreshView.dragHeight = 80;
    }
    return _refreshView;
}


-(CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.barView.bounds;
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
        gradient.frame = self.barView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#263954"].CGColor,(id)[UIColor colorWithHexString:@"#263954"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}

-(NSArray *)devList
{
    if (!_devList) {
        _devList = [[NSArray alloc]initWithArray:[jfgConfigManager getAllDevModel]];
    }
    return _devList;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation DoorSensorStatusLabel

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    
}

-(void)mySetBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

@end
