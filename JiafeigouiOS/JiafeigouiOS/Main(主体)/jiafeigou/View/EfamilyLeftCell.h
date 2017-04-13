//
//  EfamilyLeftCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 *  中控 主动发起 Cell
 */


#import "BaseEfamilyCell.h"

@interface EfamilyLeftCell : BaseEfamilyCell

/**
 *  接听 未接听 小图标
 */
@property (nonatomic, strong) UIImageView *iconImageView;
/**
 *  内容 显示 Label
 */
@property (nonatomic, strong) UILabel *contentsLabel;
/**
 *  单元格 上方 小别名  “视频通话”
 */
@property (nonatomic, strong) UILabel *nickNameLabel;

@end
