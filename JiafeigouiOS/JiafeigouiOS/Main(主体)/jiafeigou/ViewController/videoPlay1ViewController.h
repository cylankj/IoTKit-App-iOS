//
//  videoPlay1ViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLTipsBaseView.h"
#import "JFGBoundDevicesMsg.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import "SFCParamModel.h"

#define VideoPlayViewShowingNotification @"VideoPlayViewShowingNotification"
#define VideoPlayViewDismissNotification @"VideoPlayViewDismissNotification"


typedef NS_ENUM(NSInteger,videoPlayState){
    
    videoPlayStatePlayPreparing,//播放准备中
    videoPlayStatePlaying,//播放中
    videoPlayStatePause,//暂停中
    videoPlayStateNotNet,//无网络
    videoPlayStateSafa,//安全防护模式
    videoPlayStateDisconnectCamera,
    
};

//窗口模式
typedef NS_ENUM(NSInteger,videoPlayWindowsMode){
    
    videoPlayModeSmallWindow,//小窗口
    videoPlayModeFullScreen,//全屏
    
};

//内容模式
typedef NS_ENUM(NSInteger,videoPlayContentMode){
    
    videoPlayContentModeLive = 0,//直播
    videoPlayContentModeHistory,//历史视频
    
};

@interface videoPlay1ViewController : UIViewController

@property (nonatomic,copy)NSString *cid;

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

@property (nonatomic,assign)BOOL isShow;

-(void)removeAllNotification;
-(void)removeHistoryDelegate;
-(void)setHistoryVideoForTimestamp:(uint64_t)timestamp;
//摇一摇结束调用
-(void)motionEnded;

@end
