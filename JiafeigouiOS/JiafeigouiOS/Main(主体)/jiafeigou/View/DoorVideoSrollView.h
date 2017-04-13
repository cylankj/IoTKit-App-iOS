//
//  DoorVideoSrollView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VIEW_REMOTERENDE_VIEW_TAG 1032

@interface DoorVideoSrollView : UIScrollView<UIScrollViewDelegate>

/**
 *  是否 横屏 竖屏
 */
@property (nonatomic, assign) BOOL isFullScreen;

//#pragma mark  竖屏
///**
// *  流量速度 Button 有背景所以用Button
// */
//@property (nonatomic, strong) UIButton *flowSpeedButton;
///**
// *  上方遮罩 ImageView
// */
//@property (nonatomic, strong) UIImageView *shadeImageView;
///**
// *  下方遮罩 ImageView
// */
//@property (nonatomic, strong) UIImageView *bottomShadeImageView;
///**
// *  全屏 按钮
// */
//@property (nonatomic, strong) UIButton *fullScreenButton;
//
//#pragma mark  横屏
///**
// *  竖屏 按钮
// */
//@property (nonatomic, strong) UIButton *halfScreenButton;
///**
// *  标题 名字
// */
//@property (nonatomic, strong) UILabel *nickNameLabel;

@end
