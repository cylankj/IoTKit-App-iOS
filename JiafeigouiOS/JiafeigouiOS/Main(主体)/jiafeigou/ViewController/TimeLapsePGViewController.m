//
//  TimeLapsePGViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeLapsePGViewController.h"
#import "DelButton.h"
#import "FLGlobal.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIButton+FLExtentsion.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import "DJActionSheet.h"
#import "HistoryDatePicker.h"
#import "NSDate+DateTools.h"
#import "DeviceSettingVC.h"
#import <POP.h>
#import <JFGSDK/JFGSDK.h>
#import "DJDelayPickerView.h"
#import "CameraButton.h"
#import "NetworkMonitor.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import "LSAlertView.h"
#import "JfgMsgDefine.h"
#import "JfgTimeFormat.h"
#import "OemManager.h"
#import "dataPointMsg.h"
#import "JfgDataTool.h"
#import "CommonMethod.h"
#import <SDImageCache.h>
#import "JfgConfig.h"
#import "LoginManager.h"
#import "JfgUserDefaultKey.h"

#define AheadEndLessMinAlert 1089
#define AheadEndAlert 1090

#define MinPhotos 150 //最小需要拍摄的照片
@interface TimeLapsePGViewController()<HistoryDatePickerDelegate,JFGSDKCallbackDelegate,DJDelayPickerViewDelegate,UIAlertViewDelegate,CameraButtonDelegate,NetworkMonitorDelegate,JFGSDKPlayVideoDelegate>
{
    NSArray * timeButtonImages;
    NSArray * shootSeconds;//20,60
    NSMutableArray * _shootHours;
    NSMutableArray * _startHours;
    NSMutableArray * _startMinutes;
    NSTimer * snapTimer;//闪一下屏幕的倒计时时间器
    NSTimer * hoursCountDownTimer;
    NSTimer * hasNeedTimer;//等待开始拍摄，还剩多少时间的倒计时
    int64_t startShootTime;//开始拍摄的时间
    NSInteger shootTotalSeconds;//从拍摄开始还剩下的总共的秒数，倒计时用的这个
    NSInteger hasNeedTime;//等待开始拍摄，还剩多少时间
    NSInteger shootCycle;//多少秒拍一张，秒
    NSInteger minPhotos; //当前已经拍了多少张
}
@property(strong, nonatomic)NSDateFormatter *dateFormatter;
/*准备*/
@property(strong, nonatomic)UILabel * titleLabel;//标题
@property(strong, nonatomic)DelButton * exitButton;//退出按钮
@property(strong, nonatomic)UIView * bigBgView;//中间的背景View
@property(strong, nonatomic)UIView * shadow;//阴影
@property(strong, nonatomic)UILabel * explainLabel;//中间说明的文字
@property(strong, nonatomic)UIButton * timeButton;//下左按钮
@property(strong, nonatomic)CameraButton * playButton;//下中按钮
@property(strong, nonatomic)UIButton * pgButton;//下右按钮
@property(strong, nonatomic)UIButton * noNetButton;//无网刷新按钮
@property(assign, nonatomic)NSInteger shootBreakTimeIndex;//延时多少秒(20s,60s),两个的标记index
@property(assign ,nonatomic)NSInteger shootTotalHours;//选择的拍摄时长,小时，不变的
@property(strong, nonatomic)UIView * startView;//开始拍摄的时间（不是马上开始才有）
@property(strong, nonatomic)UILabel * startLabel;
/*延时拍摄中*/
@property(strong, nonatomic)UIImageView * bigImageView;//截图视图
@property(strong, nonatomic)UIView * flashView;//闪一下
/*处理*/
@property(strong, nonatomic)UIView *coverView;//覆盖物
@property(strong, nonatomic)UIImageView * circleImageView;//转圈
@property(strong, nonatomic)UILabel * progressLabel;//进度
/*完成*/
@property(strong, nonatomic)UIButton * seeButton;//看一看
@property(strong, nonatomic)UIButton * againButton;//再来一次
@property(strong, nonatomic)JFGSDKVideoView *videoView;

@end

@implementation TimeLapsePGViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [JFGSDK addDelegate:self];
    
    [[NetworkMonitor sharedManager]addDelegate:self];
    [[NetworkMonitor sharedManager]starMonitor];
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //背景图片
    UIImageView * bgImgaeView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [bgImgaeView setImage:[UIImage imageNamed:@"delay_bg"]];
    [self.view addSubview:bgImgaeView];
    
    self.shootBreakTimeIndex = 0;
    self.shootTotalHours = 8;
    shootCycle = 20;
    hasNeedTime = 0;
    shootTotalSeconds = 8*3600;
    
    shootSeconds = @[@"20S",@"60S"];
    timeButtonImages = @[@"delay_icon_time",@"delay_icon_60time"];
    
    _shootHours = [NSMutableArray array];
    for (int i=1; i<=16; i++) {
        NSString * hour = [NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]];
        [_shootHours addObject:hour];
    }
 
    [self addTopViews];
    if ([NetworkMonitor sharedManager].currentNetworkStatu == NotReachable) {
        [self.noNetButton setHidden:NO];
        self.state = cameraStateNoNet;
    }else{
        [self startLiveVideo];
    }
    [self addOtherViews];
    [self updateCameraState:cameraStatePreparing];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isShowDelayPhotoRedDot(self.cid)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSNumber *seg = [NSNumber numberWithInt:dpMsgCamera_TimeLapse];
    [[dataPointMsg shared]packSingleDataPointMsg:@[seg] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        NSLog(@"获取延时摄影：%@",dic);
        if(dic.count > 0) {
            NSArray * timeLapseArr = [dic objectForKey:@"_timeLapse"];
            int status = [[timeLapseArr objectAtIndex:3] integerValue];
            if(status == 1) {
                //获取循环时间
                shootCycle = [[timeLapseArr objectAtIndex:1] integerValue];
                
                //获取开始时间
                startShootTime = [[timeLapseArr objectAtIndex:0] longLongValue];
                //获取当前时间
                int64_t nowTime = [[NSDate date] timeIntervalSince1970];
                //获取总共拍摄时间
                NSInteger totalSecond = [[timeLapseArr objectAtIndex:2] integerValue];
                self.shootTotalHours = totalSecond/3600;
                
                if (startShootTime < nowTime) {
                    NSLog(@"已经开始摄影了");
                    //计算已经拍摄了多长时间,这个时间可以用int表示，足够
                    int hasDoneTime = (int)(nowTime - startShootTime);
                    NSLog(@"hasDoneTime:%d",hasDoneTime);
                    //已经拍摄了多少张图片
                    minPhotos = hasDoneTime/shootCycle;
                    //还剩多少秒
                    shootTotalSeconds = totalSecond - hasDoneTime;
                    //更新拍摄状态为正在拍摄中
                    [self updateCameraState:cameraStateShooting];
                } else {
                    NSLog(@"准备开始摄影");
                    shootTotalSeconds = totalSecond;
                    //还需要多少秒才开始
                    hasNeedTime = (int)(startShootTime - nowTime);
                    NSLog(@"hasNeedTime:%d",hasNeedTime);
                    [self updateCameraState:cameraStateWaitting];
                }

            }else if (status == 3){
                //已经完成
                
                [self updateCameraState:cameraStateEnd];
            } else {
               NSLog(@"被终止了");
                [self updateCameraState:cameraStateFailed];
            }
        }else{
            NSLog(@"未开始摄影");
        }

        
    } FailBlock:^(RobotDataRequestErrorType error) {
        NSLog(@"获取延时摄影失败：%ld",(long)error);
    }];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopVideoPlay];
    [JFGSDK removeDelegate:self];
    [[NetworkMonitor sharedManager]removeDelegate:self];
    [[NetworkMonitor sharedManager]stopMonitor];
}

-(void)addTopViews{
    [self.view addSubview:self.exitButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.shadow];
}
-(void)addOtherViews{
    [self.view addSubview:self.bigBgView];
    [self.view addSubview:self.timeButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.pgButton];
    [self.bigBgView addSubview:self.noNetButton];

}
#pragma mark - 相机状态
-(void)updateCameraState:(cameraState)state{
    switch (state) {
        case cameraStatePreparing:{
            self.state  = cameraStatePreparing;
            minPhotos = 0;
            [self.timeButton setHidden:NO];
            [self.playButton setHidden:NO];
            [self.pgButton setHidden:NO];
            [self.startView setHidden:YES];
            [self.bigImageView setHidden:YES];
            [self.progressLabel setHidden:YES];
            [self.coverView setHidden:YES];
            [self.noNetButton setHidden:YES];
            [self.explainLabel setText:[NSString stringWithFormat:@"%@%dS %@%d%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],shootCycle,[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],self.shootTotalHours,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
        }
            break;
        case cameraStateWaitting:{
            self.state  = cameraStateWaitting;
            minPhotos = 0;
            [self.timeButton setHidden:YES];
            [self.playButton setHidden:NO];
            [self.pgButton setHidden:YES];
            [self.startView setHidden:NO];
            [self.bigBgView bringSubviewToFront:self.startView];
            [self.bigImageView setHidden:YES];
            [self.progressLabel setHidden:YES];
            [self.coverView setHidden:YES];
            [self.noNetButton setHidden:YES];
            [self.explainLabel setText:[NSString stringWithFormat:@"%@%dS %@%d%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],shootCycle,[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],self.shootTotalHours, [JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
            self.startLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:startShootTime]];
            [self startHasLeftTimer];
        }
            break;
        case cameraStateShooting:{
            self.state = cameraStateShooting;
            [self saveTimeToLocal];
            [self sendTimeToServer];
            //按钮开始动画
            [self.playButton startAnimation];
            //显示截图的视图
            [self.bigImageView setHidden:NO];
            //隐藏左右的按钮
            [self.timeButton setHidden:YES];
            [self.pgButton setHidden:YES];
            //先设置第一张
            //[self.bigImageView setImage:[self.videoView videoScreenshotForLocal:NO]];
            minPhotos += 1;
            //按时间截图显示
            [self startSnapShot];
            //显示
            [self updateExplainLabel];
            //开始倒计时
            [self startHourCountDown];
        }
            break;
        case cameraStateHandling:{
            //停止播放
            [self stopVideoPlay];
            //标记状态
            self.state = cameraStateHandling;
            //按钮停止动画
            [self.playButton stopAnimation];
            //注销计时器
            [snapTimer invalidate];
            [hoursCountDownTimer invalidate];
            //界面变化
            [self.playButton setHidden:YES];
            [self.progressLabel setHidden:NO];
            [self.coverView setHidden:NO];
            //开始合成的转圈动画
            [self startLodingAnimation];
            [self.explainLabel setText:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Synthesis"]];
        }
            break;
        case cameraStatePause:{
            self.state = cameraStatePause;
            if (minPhotos<MinPhotos) {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_End_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_EndButton"] CancelBlock:^{
                    //继续录制,标记状态
                    self.state = cameraStateShooting;
                } OKBlock:^{
                    //结束录制
                    NSError * error = nil;
                    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
                    seg1.msgId = dpMsgCamera_TimeLapse;
                    int64_t startTime = [[NSDate date] timeIntervalSince1970];
                    seg1.value = [MPMessagePackWriter writeObject:@[[NSNumber numberWithLongLong:startTime],[NSNumber numberWithInteger:shootCycle],[NSNumber numberWithInteger:shootTotalSeconds],[NSNumber numberWithBool:false]] error:&error];
                    [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                        NSLog(@"取消延时摄影成功");
                        [self updateCameraState:cameraStateFailed];
                        
                    } failure:^(RobotDataRequestErrorType type) {
                        NSLog(@"取消延时摄影失败：%d",type);
                    }];
                }];
            }else{

                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_End_Tips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                    //继续录制,标记状态
                    self.state = cameraStateShooting;
                } OKBlock:^{
                    //提前结束录制，并将已拍摄的图片合成小视频，页面转到【视频合成】页
                    NSError * error = nil;
                    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
                    seg1.msgId = dpMsgCamera_TimeLapse;
                    int64_t startTime = [[NSDate date] timeIntervalSince1970];
                    seg1.value = [MPMessagePackWriter writeObject:@[[NSNumber numberWithLongLong:startTime],[NSNumber numberWithInteger:shootCycle],[NSNumber numberWithInteger:shootTotalSeconds],[NSNumber numberWithBool:false]] error:&error];
                    [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                        NSLog(@"提前结束延时摄影成功");
                        [self updateCameraState:cameraStateHandling];
                        
                    } failure:^(RobotDataRequestErrorType type) {
                        NSLog(@"提前结束延时摄影失败：%d",type);
                    }];
                }];
            }
        }
            break;
        case cameraStateFailed:{
            if (self.state==cameraStatePause) {  //结束录制任务，并删除服务器所有此任务的所有图片
                //释放计时器
                [snapTimer invalidate];
                [hoursCountDownTimer invalidate];
                //按钮复原
                [self.playButton stopAnimation];
                //恢复到准备阶段
                [self updateCameraState:cameraStatePreparing];
            }
        }
            break;
        case cameraStateEnd:{
            self.state = cameraStateEnd;
            [self stopLoadingAnimation];
            [self.progressLabel setHidden:YES];
            [self.view addSubview:self.againButton];
            [self.bigBgView addSubview:self.seeButton];
            [self.coverView setHidden:YES];
            [self getfirstImage];
            [self.explainLabel setText:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_SynthesisTips"]];
        }
            break;
        case cameraStateNoNet:{
            self.state = cameraStateNoNet;
            [self stopVideoPlay];
        }
            break;
        default:
            break;
    }
}
#pragma mark - 关于时间同步
//将时间保存到本地
-(void)saveTimeToLocal{
    
}
//将时间发送给服务器
-(void)sendTimeToServer{
    
}
//网络不好
-(void)netOff{
    
}
//网络恢复了
-(void)netOn{
    
}
//请求下一次拍摄的时间点
-(void)requestNextShootTime{
    
}
//同步时间
-(void)synchronizeTime{
    
}
//服务器删除所有图片
-(void)serverDeletePhotos{
    
}
//从服务器请求视频
-(void)requestVideo{
    
}
//清空时间(本地/服务器)
-(void)clearTime{
    
}
#pragma mark - 网络监听
-(void)networkChanged:(NetworkStatus)statu{
    switch (self.state) {
        case cameraStatePreparing:{
            if (statu == NotReachable) {
                NSLog(@"isMianThread:%d",[NSThread isMainThread]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.noNetButton setHidden:NO];
                    [self updateCameraState:cameraStateNoNet];
                    [self stopLoadingAnimation];
                });
            }else{
                [self.noNetButton setHidden:YES];
                [self startLiveVideo];
            }
        }
            break;
        case cameraStateShooting:{
            if(statu == NotReachable){
                //给出提示
            }else{
                //对比本地时间来判断是否已经完成,如果未完成则请求时间
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - 播放视频
//开始直播
-(void)startLiveVideo{
    
    [self startLodingAnimation];
    //[self.playVideo startLiveVideo:self.cid isLoadLocalVideo:NO];
    [self.videoView startLiveRemoteVideo:self.cid];
}
//停止视频播放
-(void)stopVideoPlay
{
//    [self.playVideo stopVideoPlay];
    [self.videoView stopVideo];
}

-(void)jfgResolutionNotifyWidth:(int)width height:(int)height peer:(NSString *)peer
{
    [self.bigBgView bringSubviewToFront:self.videoView];
    self.videoView.frame = self.bigImageView.bounds;
}

-(void)jfgRTCPNotifyBitRate:(int)bitRate videoRecved:(int)videoRecved frameRate:(int)frameRate timesTamp:(int)timesTamp{
    NSLog(@"bit:%dkb/s videoRecved:%dM",bitRate,videoRecved);
    if (self.state == cameraStatePreparing) {
        if (bitRate!=0) {
            [self stopLoadingAnimation];
        }else{
            if(self.circleImageView.hidden==YES && self.noNetButton.hidden==YES){
                [self startLodingAnimation];
            }
        }
    }
}
#pragma mark - circleAnimation
-(void)startLodingAnimation
{
    [self.noNetButton setHidden:YES];
    self.circleImageView.hidden = NO;
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    
    [self.circleImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopLoadingAnimation
{
    if(self.circleImageView.hidden==YES){
        return;
    }
    [self.circleImageView setHidden:YES];
    [self.circleImageView.layer pop_removeAnimationForKey:@"rotation"];
}

#pragma mark - 截图计时器
-(void)startSnapShot{

    snapTimer = [NSTimer scheduledTimerWithTimeInterval:shootCycle target:self selector:@selector(setBigImage:) userInfo:nil repeats:YES];
}
-(void)setBigImage:(UIImage *)image{
    minPhotos += 1;
    [self.bigBgView addSubview:self.flashView];
    self.flashView.alpha = 1.0;
    [UIView animateWithDuration:.8f
                     animations:^{
                         [self.flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [self.flashView removeFromSuperview];
                     }
     ];
//    [self.bigImageView setImage:image];
}
#pragma mark -拍摄时长倒计时
-(void)startHourCountDown{
    hoursCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCountDown) userInfo:nil repeats:YES];
}
-(void)timeCountDown{
    shootTotalSeconds -= 1;
    [self performSelectorOnMainThread:@selector(updateCountDownLabel) withObject:nil waitUntilDone:NO];
}
-(void)updateCountDownLabel{
    [self updateExplainLabel];
    if (shootTotalSeconds==0) {
        [self updateCameraState:cameraStateHandling];
    }
}
- (void)updateExplainLabel {
    NSInteger hour = shootTotalSeconds/3600;
    NSInteger min = shootTotalSeconds/60%60;
    NSInteger sec = shootTotalSeconds%60;
    [self.explainLabel setText:[NSString stringWithFormat:@"%@ %d:%.2d:%.2d",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Countdown"],hour,min,sec]];
}
#pragma mark - 等待拍摄倒计时
- (void)startHasLeftTimer{
    hasNeedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hasLeftTime) userInfo:nil repeats:YES];
}
- (void)hasLeftTime {
    hasNeedTime -= 1;
    NSLog(@"准备还需要%d秒",hasNeedTime);
    if (hasNeedTime == 0) {
        [self updateCameraState:cameraStateShooting];
    }
}
#pragma mark - 拍摄结束后
-(void)getfirstImage
{
    NSString *imageUrl = [JfgDataTool getTimeLapseForCid:self.cid timestamp:startShootTime vid:[OemManager getOemVid] flag:1 fileType:@"jpg"];
    //如果不存在，从网络获取
    NSURL* url = [NSURL URLWithString:imageUrl];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.bigImageView.image = image;
        }
 
    }];
}
-(NSString *)getMp4URLStr {
    return [JfgDataTool getTimeLapseForCid:self.cid timestamp:startShootTime vid:[OemManager getOemVid] flag:1 fileType:@"pm4"];
}
#pragma mark - ButtonAction
-(void)exitButtonAction{
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DeviceSettingVC class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
-(void)timeButtonAction:(UIButton *)button{
    [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"] buttonTitleArray:@[@"20S",@"60S"] actionType:actionTypeSelect defaultIndex:self.shootBreakTimeIndex didSelectedBlock:^(NSInteger index) {
        self.shootBreakTimeIndex = index;
        if (index==0 && self.shootTotalHours>16) {
            //拍摄时长超过16,此时应该恢复到8小时(20s:1~16)
            [self.explainLabel setText:[NSString stringWithFormat:@"%@20S %@8%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],[JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
            shootCycle = 20;
            self.shootTotalHours=8;
            shootTotalSeconds = 8*3600;
        }else if(index==1 && self.shootTotalHours<4){
            //拍摄时长小于4小时(60s:4~24)
            [self.explainLabel setText:[NSString stringWithFormat:@"%@60S %@8%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],[JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
            shootCycle = 60;
            self.shootTotalHours=8;
            shootTotalSeconds = 8*3600;
        }else{
            shootCycle = self.shootBreakTimeIndex==0?20:60;
            [self.explainLabel setText:[NSString stringWithFormat:@"%@%dS %@%d%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],shootCycle,[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],self.shootTotalHours, [JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];

        }
    } didDismissBlock:^{
        [self.timeButton setImage:[UIImage imageNamed:[timeButtonImages objectAtIndex:self.shootBreakTimeIndex]] forState:UIControlStateNormal];
        [_shootHours removeAllObjects];
        if(self.shootBreakTimeIndex == 0){
            for (int i=1; i<=16; i++) {
                NSString * hour = [NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]];
                [_shootHours addObject:hour];
            }
        }else{
            for (int i=4; i<=24; i++) {
                NSString * hour = [NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]];
                [_shootHours addObject:hour];
            }
        }
    }];
}
-(void)playButtonAction:(CameraButton *)button{
    if (self.state == cameraStatePreparing) {
        DJDelayPickerView * delayView = [DJDelayPickerView delayPickerView];
        delayView.delegate = self;
        [delayView show];
    }else if(self.state == cameraStateShooting){
        //暂停
        [self updateCameraState:cameraStatePause];
    }else{
        
    }
}
-(void)pgButtonAction:(UIButton *)button{
    HistoryDatePicker * picker= [HistoryDatePicker historyDatePicker];
    picker.dataArray = [NSMutableArray arrayWithObject:_shootHours];
    picker.backgroundColor = [UIColor clearColor];
    picker.delegate = self;
    picker.title = [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"];
    [picker show];
}
-(void)disconnectNetAction{
    [self startLiveVideo];
}
#pragma mark - CameraButton

-(void)touchDown
{
    switch (self.state) {
        case cameraStatePreparing:{
            DJDelayPickerView * delayView = [DJDelayPickerView delayPickerView];
            delayView.delegate = self;
            [delayView show];
        }
            break;
        case cameraStateShooting:{
            //暂停
            [self updateCameraState:cameraStatePause];
        }
            break;
        case cameraStateWaitting:{
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_End_NotStartTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_No"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Yes"] CancelBlock:nil OKBlock:^{
                NSError * error = nil;
                DataPointSeg * seg1 = [[DataPointSeg alloc]init];
                seg1.msgId = dpMsgCamera_TimeLapse;
                int64_t startTime = [[NSDate date] timeIntervalSince1970];
                seg1.value = [MPMessagePackWriter writeObject:@[[NSNumber numberWithLongLong:startTime],[NSNumber numberWithInteger:shootCycle],[NSNumber numberWithInteger:shootTotalSeconds],[NSNumber numberWithInteger:0]] error:&error];
                [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                    NSLog(@"取消延时摄影成功");
                    [hasNeedTimer invalidate];
                    hasNeedTime = 0;
                    [self updateCameraState:cameraStatePreparing];
                    
                } failure:^(RobotDataRequestErrorType type) {
                    NSLog(@"取消延时摄影失败：%d",type);
                }];
            }];
        }
            break;
    
        default:
            break;
    }
}

-(void)didStartProgressAnimation{
    
}
-(void)didCameraOnePhoto{
    
}
-(void)didStopAnimation{
    
}
#pragma mark - HistoryDatePickerDelegate选择拍摄总时长的回调
-(void)cancel{
    NSLog(@"cancel");
}
-(void)didSelectedItem:(NSString *)item indexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectedItem:%@-%d",item,indexPath.row);
    if (self.shootBreakTimeIndex==0) {
        self.shootTotalHours = indexPath.row+1;
    }else{
        self.shootTotalHours = indexPath.row+4;
    }
    shootTotalSeconds = self.shootTotalHours *60*60;
    [_explainLabel setText:[NSString stringWithFormat:@"%@%dS %@%d%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],shootCycle,[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],self.shootTotalHours,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
}
#pragma mark - DJDelayPickerViewDelegate
-(void)cancelPick{
  NSLog(@"cancelPick");
}

-(void)delayPickerView:(DJDelayPickerView *)pickView didSelectTime:(NSDate *)time isBegainNow:(BOOL)isBegainNow{
    NSLog(@"time=%@",time);
    
    NSError * error = nil;
    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
    seg1.msgId = dpMsgCamera_TimeLapse;
    startShootTime = [time timeIntervalSince1970];
    hasNeedTime = [time timeIntervalSince1970]-[[NSDate date] timeIntervalSince1970];
    seg1.value = [MPMessagePackWriter writeObject:@[[NSNumber numberWithLongLong:startShootTime],[NSNumber numberWithInteger:shootCycle],[NSNumber numberWithInteger:shootTotalSeconds],[NSNumber numberWithInteger:1]] error:&error];
    [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        NSLog(@"设置延时摄影成功");
        if (isBegainNow) {
            //更新本地的一些操作
            [self updateCameraState:cameraStateShooting];
            
        }else{
            [self updateCameraState:cameraStateWaitting];
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        NSLog(@"设置延时摄影失败：%d",type);
    }];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case AheadEndLessMinAlert:{
            if (buttonIndex == 1) {
                //结束录制任务
                
            }else{
               
            }
        }
            break;
        case AheadEndAlert:{
            if (buttonIndex == 1) {
                
            }else{
                
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - 界面
-(UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((Kwidth-200)/2.0, 33.5, 200, 17)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        _titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse"];
    }
    return _titleLabel;
}
-(DelButton *)exitButton{
    if(!_exitButton){
        _exitButton = [DelButton buttonWithType:UIButtonTypeCustom];
        [_exitButton setFrame:CGRectMake(10, 27, 30, 30)];
        [_exitButton setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}
-(UIView *)bigBgView{
    if (!_bigBgView) {
        _bigBgView = [[UIView alloc]initWithFrame:CGRectMake((Kwidth-322*designWscale)/2.0, 0.16*kheight, 322*designWscale, 257*designWscale)];
        _bigBgView.layer.cornerRadius = 6.0;
        _bigBgView.layer.masksToBounds = YES;
   
        
        [_bigBgView setContentMode:UIViewContentModeScaleAspectFill];
        [_bigBgView addSubview:self.videoView];
        [_bigBgView addSubview:self.bigImageView];
        [_bigBgView addSubview:self.explainLabel];
        [_bigBgView addSubview:self.coverView];
        [_bigBgView addSubview:self.circleImageView];
        [_bigBgView addSubview:self.progressLabel];
        [_bigBgView addSubview:self.startView];
        //添加截图的视图
    }
    return _bigBgView;
}
-(UIView *)shadow{
    if (!_shadow) {
        _shadow = [[UIView alloc]initWithFrame:CGRectMake((Kwidth-322*designWscale)/2.0, 0.16*kheight, 322*designWscale, 257*designWscale)];
        _shadow.backgroundColor = [UIColor grayColor];
        CALayer * layer = [_shadow layer];
        _shadow.layer.cornerRadius = 6.0;
        [layer setShadowColor:[UIColor grayColor].CGColor];
        [layer setShadowRadius:4];
        [layer setShadowOpacity:0.8];
        [layer setShadowOffset:CGSizeMake(0, 4)];
    }
    return _shadow;
}
-(UIButton *)noNetButton{
    if (!_noNetButton) {
        _noNetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_noNetButton setFrame:CGRectMake((322*designWscale-50)/2, (257*designWscale-50)/2, 50.0, 50.0)];
        [_noNetButton setImage:[UIImage imageNamed:@"camera_icon_no-network"] forState:UIControlStateNormal];
        [_noNetButton addTarget:self action:@selector(disconnectNetAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noNetButton;
}
-(UIImageView *)bigImageView{
    if(!_bigImageView){
        _bigImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 322*designWscale, (257-32)*designWscale)];
        _bigImageView.backgroundColor = [UIColor clearColor];
    }
    return _bigImageView;
}
- (UIView *)startView{
    if (!_startView) {
        _startView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 322*designWscale, (257-32)*designWscale)];
        _startView.backgroundColor = [UIColor whiteColor];
        [_startView addSubview:self.startLabel];
    }
    return _startView;
}
- (UILabel *)startLabel {
    if (!_startLabel) {
        _startLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.startView.height-16.0)*0.5, self.startView.width, 16.0)];
        [_startLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLabel setTextAlignment:NSTextAlignmentCenter];

    }
    return _startLabel;
}
-(UILabel *)explainLabel{
    if (!_explainLabel) {
        _explainLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bigImageView.bottom-1, self.bigImageView.width, 32*designWscale+1)];
        [_explainLabel setTextAlignment:NSTextAlignmentCenter];
        [_explainLabel setBackgroundColor:[UIColor whiteColor]];
        [_explainLabel setFont:[UIFont systemFontOfSize:13]];
        [_explainLabel setTextColor:[UIColor colorWithHexString:@"#888888"]];
        [_explainLabel setText:[NSString stringWithFormat:@"%@%dS %@%d%@",[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Interval"],shootCycle,[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_RecordTime"],self.shootTotalHours,[JfgLanguage getLanTextStrByKey:@"Word_Hours"]]];
    }
    return _explainLabel;
}
-(UIButton *)timeButton{
    if(!_timeButton){
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setFrame:CGRectMake(self.playButton.left-50*designWscale-65, self.playButton.top, 65, 65)];
        [_timeButton setImage:[UIImage imageNamed:@"delay_icon_time"] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(timeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}
-(CameraButton *)playButton{
    if(!_playButton){
        _playButton = [[CameraButton alloc]initWithFrame:CGRectMake((Kwidth-65)/2, self.bigBgView.bottom+0.1*kheight, 65, 65)];
        _playButton.delegate = self;
        _playButton.intervalTime = shootCycle;
    }
    return _playButton;
}

-(void)Test
{
    
}

-(UIButton *)pgButton{
    if(!_pgButton){
        _pgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pgButton setFrame:CGRectMake(self.playButton.right+50*designWscale, self.playButton.top, 65, 65)];
        [_pgButton setImage:[UIImage imageNamed:@"delay_ico_photography"] forState:UIControlStateNormal];
        [_pgButton addTarget:self action:@selector(pgButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pgButton;
}
-(UIView *)flashView{
    if (!_flashView) {
        _flashView = [[UIView alloc] initWithFrame:self.bigImageView.frame];
        [_flashView setBackgroundColor:[UIColor whiteColor]];
    }
    return _flashView;
}
#pragma mark - 处理中
-(UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:self.bigBgView.bounds];
        _coverView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    }
    return _coverView;
}
-(UIImageView *)circleImageView{
    if(!_circleImageView){
        CGPoint p = self.bigImageView.center;
        _circleImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delay_login_loading"]];
        _circleImageView.center = p;
        _circleImageView.size = CGSizeMake(62, 62);
    };
    return _circleImageView;
}
-(UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]init];
        _progressLabel.size = CGSizeMake(62, 62);
        _progressLabel.center = self.circleImageView.center;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.font = [UIFont systemFontOfSize:18];
    }
    return _progressLabel;
}
-(JFGSDKVideoView *)videoView
{
    if (!_videoView) {
        _videoView = [[JFGSDKVideoView alloc]initWithFrame:CGRectMake(0, 0, self.bigImageView.bounds.size.width, self.bigImageView.bounds.size.height)];
        _videoView.backgroundColor = [UIColor clearColor];
        _videoView.delegate = self;
    }
    return _videoView;
}
#pragma mark - 处理完成
-(UIButton *)seeButton{
    if (!_seeButton) {
        _seeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _seeButton.size = CGSizeMake(50, 50);
        _seeButton.center = self.bigImageView.center;
        [_seeButton setImage:[UIImage imageNamed:@"btn_playVideo"] forState:UIControlStateNormal];
    }
    return _seeButton;
}
-(UIButton *)againButton{
    if (!_againButton) {
        _againButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_againButton setFrame:CGRectMake((Kwidth-180)/2.0, self.bigBgView.bottom+0.13*kheight*designWscale, 180, 44)];
        _againButton.layer.cornerRadius = 22;
        _againButton.layer.masksToBounds = YES;
        _againButton.backgroundColor = [UIColor clearColor];
        [_againButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Setting"] forState:UIControlStateNormal];
        [_againButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"]];
        [_againButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        _againButton.layer.borderWidth = 0.5;
        _againButton.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    }
    return _againButton;
}
-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter =[[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

@end
