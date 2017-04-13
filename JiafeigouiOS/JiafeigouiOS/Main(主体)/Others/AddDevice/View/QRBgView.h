//
//  QRBgView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRBgView : UIView

@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomtView;

@property (strong, nonatomic) UIImageView *centerImageView; // 中间扫码框图片
@property (strong, nonatomic) UILabel *describLabel; // 描述 文字label
@property (strong, nonatomic) UIImageView *lineImageView; // 动画imageView

@property (nonatomic, strong) UIActivityIndicatorView *_indicatorView;
@property (nonatomic, strong) UILabel *noteLabel;

- (void)startQRAnimation;
- (void)stopQRAnimation;

-(void)showLoading;
-(void)stopLoading;

@end
