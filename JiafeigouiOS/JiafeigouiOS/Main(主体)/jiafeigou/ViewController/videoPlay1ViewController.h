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

enum MountMode {
    MOUNT_TOP = 0,
    MOUNT_WALL,
};

struct SFCParamIos {
    int cx;  // 圆心X
    int cy;  // 圆心Y
    int r;   // 圆半径
    
    int w;   // 图片width
    int h;   // 图片height
    int fov; // field of view
};

SFCParamIos getSFCParamIosPreset();
SFCParamIos SFCParamIosMake(int t_cx, int t_cy, int t_r, int t_w, int t_h, int t_fov);

@interface PanoramicIosView()

// panorama interface begin
- (bool)isPanorama;
// 设置悬挂模式
- (void)setMountMode:(MountMode) mode;
// 设置摄像头参数
- (void)configV360:(SFCParamIos) p;
// opengl 截图
- (UIImage*) takeSnapshot;
// 开启陀螺仪
- (void)enableGyro:(bool) enable;
// 开启VR分屏
- (void)enableVRMode:(bool) enable;
// 通知view方向变化
- (void)detectOrientationChange;
// 载入图片
- (BOOL)loadImage:(NSString*) imgPath;
// 载入图片
- (BOOL)loadUIImage:(UIImage*) img;
// 获取双击的手势对象
- (UITapGestureRecognizer*) getDoubleTapRecognizer;
// 手动停止view的渲染和更新（释放timer资源）
- (void)stopRender;

@end


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

@end
