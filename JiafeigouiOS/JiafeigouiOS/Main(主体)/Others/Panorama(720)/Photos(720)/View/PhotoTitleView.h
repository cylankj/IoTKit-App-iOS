//
//  PhotoTitleView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTitleView : UIView

- (void)rotateAnimation:(BOOL)isShowMenu;

- (void)updateLayout;

@property (nonatomic, strong) UILabel *titleLbel;
//@property (nonatomic, strong) UIImageView *arrowImgView;

@end
