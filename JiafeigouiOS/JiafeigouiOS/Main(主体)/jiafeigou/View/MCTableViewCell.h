//
//  MCTableViewCell.h
//  JiafeigouIOS
//
//  Created by Michiko on 15/12/16.
//  Copyright © 2015年 liao tian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lineView.h"

@interface MCTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel; //中间 时间
@property (strong, nonatomic) UILabel *stateLabel; // 状态
@property (strong, nonatomic) UIImageView *dotImageView;// 圆圈
@property (strong, nonatomic) UILabel *dateLabel;// 日期
@property (strong, nonatomic) lineView * line; //虚线
@property (assign, nonatomic) NSInteger doorState;

-(void)setDateLabelText:(NSString *)string;

@end
