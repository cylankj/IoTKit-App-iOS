//
//  EfamilyRecordView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//
/**
 *  语音 留言 按钮
 */
#import <UIKit/UIKit.h>
#import "RecordButton.h"

@interface EfamilyRecordView : UIView

/**
 *  倒计时动画 view
 */
@property (nonatomic, strong) UIView *animatinLine;
/**
 *   录音 按钮
 */
@property (nonatomic, strong) RecordButton *recordButton;
/**
 *  录音 按钮  左右两边 音波图片
 */
@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UIImageView *rightImageView;

/**
 *  退出/隐藏 按钮
 */
@property (nonatomic, strong) UIButton *exitButton;

/**
 *  显示 动画
 */
- (void)showAnimationWithDuration:(CGFloat)duration;
/**
 *  隐藏 动画
 */
- (void)hideAnimationWithDuration:(CGFloat)duration;

@end
