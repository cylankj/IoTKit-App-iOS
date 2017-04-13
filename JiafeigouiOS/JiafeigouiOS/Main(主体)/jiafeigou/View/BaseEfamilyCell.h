//
//  BaseEfamilyCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseEfamilyCell : BaseTableViewCell
/**
 *  时间标题
 */
@property(nonatomic, strong) UILabel  *timeLabel;
/**
 *  头像 图片
 */
@property(nonatomic, strong) UIImageView *headImageView;
/**
 *  蓝色 背景图片
 */
@property(nonatomic, strong) UIImageView *bgImageView;


@end
