//
//  JFGSDKRenderView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JFGSDK/JFGSDKVideoView.h>

enum MountMode {
    MOUNT_TOP = 0,
    MOUNT_WALL,
};

enum DFDisplayMode {
    DM_Equirectangular = 0,  // for test
    DM_Panorama,            // 正常全景
    DM_LittlePlanet,        // 小行星
    DM_Fisheye,             // 鱼眼
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

@protocol VideoRenderIosProtocol <NSObject>
@end

@interface PanoramicIosView()<VideoRenderIosProtocol>

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
// 是否启用视频第一帧动画
-(void)enableFirstFrameEvent:(bool)enable;

@end


@interface Panoramic720IosView : UIView<VideoRenderIosProtocol>

// panorama interface begin

// 初始化全景view
- (id)initPanoramicViewWithFrame:(CGRect)frame;
- (bool)isPanorama;
// 设置摄像头参数
- (void)configV720;
- (void)configV720WithXML:(NSString*)xml_path;
// opengl 截图
- (UIImage*)takeSnapshot;

//
- (void) setDisplayMode:(DFDisplayMode) mode;
- (DFDisplayMode) getCurrentDisplayMode;
// 开启陀螺仪
- (void)enableGyro:(bool)enable;
// 开启VR分屏
- (void)enableVRMode:(bool)enable;
// 通知view方向变化
- (void)detectOrientationChange:(UIDeviceOrientation) Orientation;
// 载入图片
- (BOOL)loadImage:(NSString*)imgPath;
// 载入图片
- (BOOL)loadUIImage:(UIImage*)img;
// 获取双击的手势对象
- (UITapGestureRecognizer*)getDoubleTapRecognizer;
// 手动停止view的渲染和更新（释放timer资源）
- (void)stopRender;

// 是否启用视频第一帧动画
-(void)enableFirstFrameEvent:(bool)enable;

// panorama interface end

@end


@interface JFGSDKRenderView : NSObject

@end

