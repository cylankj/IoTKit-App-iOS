//
//  BellView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BellView : UIView
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) BOOL isShared;
@property (assign, nonatomic) BOOL isAnswered;
@property (strong, nonatomic) UILabel * dateLabel;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UIImageView * headerImageView;
@property (strong, nonatomic) UIButton * callState;
@property (strong, nonatomic) UIImageView *selectedImage;
@property (strong, nonatomic)UIImageView * redDot;
@end

