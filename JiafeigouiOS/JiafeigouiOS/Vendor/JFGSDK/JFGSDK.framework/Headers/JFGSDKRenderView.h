//
//  JFGSDKRenderView.h
//  JFGSDK
//
//  Created by 杨利 on 2017/8/15.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum  {
    MOUNT_TOP = 0,
    MOUNT_WALL,
} MountMode;

typedef enum  {
    DM_Equirectangular = 0,  // for test
    DM_Panorama,            // 正常全景
    DM_LittlePlanet,        // 小行星
    DM_Fisheye,             // 鱼眼
} DFDisplayMode;

typedef enum  {
    SFM_Normal,              // 正常全景
    SFM_Cylinder,           // 圆柱
    SFM_Quad,				// 四分屏
} SFDisplayMode;

struct SFCParamIos {
    int cx;  // 圆心X
    int cy;  // 圆心Y
    int r;   // 圆半径
    
    int w;   // 图片width
    int h;   // 图片height
    int fov; // field of view
};
//默认值使用：640, 480, 480, 1280, 960, 180

//全景摄像头悬挂模式
typedef NS_ENUM(NSInteger,PanoramaCameraMode){
    PanoramaLiveModeTop,
    PanoramaLiveModeWall,
};

//全景摄像头参数设置
typedef NS_ENUM(NSInteger,PanoramaCameraParam){
    PanoramaCameraParamTopPreset,
    PanoramaCameraParamWallPreset,
};


#pragma mark- 普通渲染视图
@interface VideoRenderIosView : UIView

@end


#pragma mark- 单鱼眼渲染视图
@interface PanoramicIosView : GLKView

// 初始化全景view
- (id)initPanoramicViewWithFrame:(CGRect)frame;
- (bool)isPanorama;
// 设置悬挂模式
- (void)setMountMode:(MountMode)mode;
// 设置摄像头参数
- (void)configV360:(struct SFCParamIos)p;
// opengl 截图
- (UIImage*) takeSnapshot;
// 通知view方向变化
- (void)detectOrientationChange;
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
- (void)drawRect:(CGRect)rect;

@end


#pragma mark- RS单鱼眼渲染视图（支持多种视图模式）
@interface PanoramicIosViewRS : GLKView

// 初始化全景view
- (id)initPanoramicViewWithFrame:(CGRect)frame;
- (bool)isPanorama;
// 设置悬挂模式
- (void)setMountMode:(MountMode)mode;
// 设置摄像头参数
- (void)configV360:(struct SFCParamIos)p;
// opengl 截图
- (UIImage*)takeSnapshot;
// 通知view方向变化
- (void)detectOrientationChange;
// 载入图片
- (BOOL)loadImage:(NSString*)imgPath;
// 载入图片
- (BOOL)loadUIImage:(UIImage*)img;
// 获取双击的手势对象
- (UITapGestureRecognizer*) getDoubleTapRecognizer;
// 手动停止view的渲染和更新（释放timer资源）
- (void)stopRender;
// 是否启用视频第一帧动画
-(void)enableFirstFrameEvent:(bool) enable;
// 开启自动旋转
-(void)enableAutoRotation:(bool) enable;
// 手机摇一摇
-(void)phoneShook;
// 设置显示模式（正常、圆柱、四分屏)
-(void)setDisplayMode:(SFDisplayMode)mode;
// panorama interface end
- (void)drawRect:(CGRect) rect;

@end


#pragma mark- 双鱼眼视图渲染
@interface Panoramic720IosView : GLKView

// 初始化全景view
- (id)initPanoramicViewWithFrame:(CGRect)frame;
- (bool)isPanorama;
// 设置摄像头参数
- (void)configV720;
- (void)configV720WithXML:(NSString*) xml_path;
// opengl 截图
- (UIImage*) takeSnapshot;
// 设置显示模式
- (void)setDisplayMode:(DFDisplayMode) mode;
- (DFDisplayMode) getCurrentDisplayMode;
// 开启陀螺仪
- (void)enableGyro:(bool) enable;
// 开启VR分屏后
// 自动开启陀螺仪
// 自动切换到normal模式，并且无法切换到其他模式
- (void)enableVRMode:(bool) enable;
// 通知view方向变化
- (void)detectOrientationChange:(UIDeviceOrientation) Orientation;
// 载入图片
- (BOOL)loadImage:(NSString*) imgPath;
// 载入图片
- (BOOL)loadUIImage:(UIImage*) img;
// 获取双击的手势对象
- (UITapGestureRecognizer*) getDoubleTapRecognizer;
// 手动停止view的渲染和更新（释放timer资源）
- (void)stopRender;
// 是否启用视频第一帧动画
-(void)enableFirstFrameEvent:(bool) enable;
// panorama interface end
- (void) drawRect:(CGRect) rect;

@end

@interface JFGSDKRenderView : NSObject

@end
