//
//  HeaderViewFor720.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define isEditingNotification @"_isEditingNotification"

@interface HeaderViewFor720 : UIView

- (void)setEditing:(BOOL)isEditing;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *dotImageView;

@end
