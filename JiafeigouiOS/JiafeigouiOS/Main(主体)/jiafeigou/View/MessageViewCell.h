//
//  MessageViewCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageImageView.h"

@class TimeLineView,MessageImageView,DelButton;

@interface MessageViewCell : UITableViewCell
//隐藏该隐藏的,防止拖动的时候出现BUG
@property (assign,nonatomic) BOOL hiddenSubviews;
//左边的线条view
@property (strong,nonatomic) TimeLineView *line;
//tip小图片
@property (strong,nonatomic) UIImageView *tip;

//label
@property (strong,nonatomic) UILabel *label;

//删除按钮
@property (strong,nonatomic) DelButton *deleteBtn;

//视频播放按钮(cell4 不会创建该button)
@property (strong,nonatomic) UIButton *avBtn;

@property (nonatomic,assign) uint64_t timestamp;

@property (nonatomic,assign)BOOL hiddenAvBtn;

- (void)setBothUIButtonMasonry:(UIView *)view;
- (void)handleHiddenView:(BOOL)edting;

- (void)handleMasonry:(BOOL)edting;

@end

@interface MessageViewCell1 : MessageViewCell // 三张图片 类型Cell

//图片1
@property (strong,nonatomic) MessageImageView *imgv1;

//图片2
@property (strong,nonatomic) MessageImageView *imgv2;

//图片3
@property (strong,nonatomic) MessageImageView *imgv3;

@end

@interface MessageViewCell2 : MessageViewCell // 两张图片 类型cell

//图片1
@property (strong,nonatomic) MessageImageView *imgv1;

//图片2
@property (strong,nonatomic) MessageImageView *imgv2;


@end

@interface MessageViewCell3 : MessageViewCell // 一张图片 类型Cell

//图片1
@property (strong,nonatomic) MessageImageView *imgv1;


@end

@interface MessageViewCell4 : MessageViewCell // 文字 类型 Cell


//文字label
@property (strong,nonatomic) UITextView *contentLabel;


@end
