//
//  VideoPlayFor720ViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/11.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseViewController.h"
#import "JiafeigouDevStatuModel.h"
#import "videoPlay1ViewController.h"

@interface Panoramic720IosView : VideoRenderIosView

// 初始化全景view
- (id)initPanoramicViewWithFrame:(CGRect)frame;
- (bool)isPanorama;
// 设置摄像头参数
- (void)configV720;
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
-(void) enableFirstFrameEvent:(bool) enable;


@end


@interface VideoPlayFor720ViewController : JFGBaseViewController

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

@end
