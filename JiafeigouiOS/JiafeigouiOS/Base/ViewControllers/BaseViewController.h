//
//  BaseViewController.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

@interface BaseViewController : UIViewController

#pragma mark view
// 导航条 左边按钮
@property (strong, nonatomic) UIButton *leftButton;

//导航条 右边按钮，默认隐藏
@property (strong, nonatomic) UIButton *rightButton;

// 导航条的view
@property (strong, nonatomic) UIView *navigationView;

// 导航条的 title
@property (strong, nonatomic) UILabel *titleLabel;

- (void)setLeftButtonImage:(UIImage *)btnImage title:(NSString *)btnTitle font:(UIFont *)font;
- (void)setRightButtonImage:(UIImage *)btnImage title:(NSString *)btnTitle font:(UIFont *)font;

#pragma mark model
/**
 *  cid 设备 唯一 标识
 */
@property (copy, nonatomic) NSString *cid;

/**
 *  产品类别ID ，区分产品
 */
@property (assign, nonatomic) productType pType;
/**
 * 是否分享
 */
@property (assign, nonatomic) BOOL isShare;

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender;

@end
