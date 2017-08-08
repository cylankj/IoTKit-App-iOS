//
//  CameraButton.h
//  HeaderRotation
//
//  Created by 杨利 on 16/6/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CameraButtonDelegate;

@interface CameraButton : UIControl

/**
 *  拍一张照片的间隔
 */
@property (nonatomic,assign)CGFloat intervalTime;

/**
 *  代理
 */
@property (nonatomic,weak)id <CameraButtonDelegate> delegate;

/**
 *  开启延时摄影按钮动画
 */
-(void)startAnimation;


/**
 *  停止延时摄影按钮动画
 */
-(void)stopAnimation;


@end


@protocol CameraButtonDelegate <NSObject>

/**
 *  按钮被点击后
 */
-(void)touchDown;

/**
 *  已经开始延时摄影动画
 */
-(void)didStartProgressAnimation;

/**
 *  时间间隔内已经拍摄了一张
 */
-(void)didCameraOnePhoto;

/**
 *  已经停止延时摄影按钮动画
 */
-(void)didStopAnimation;

@end
