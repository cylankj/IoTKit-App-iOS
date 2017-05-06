//
//  LSChatCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSChatModel;

@interface LSChatCell : UITableViewCell
/**
 *  数据模型
 */
@property(strong, nonatomic)LSChatModel * model;
/**
 *  时间
 */
@property(strong, nonatomic)UILabel * timeLabel;

/**
 *  发送状态
 */
@property(strong,nonatomic)UILabel *sendStatueLabel;
/**
 *  自己的头像（右边）
 */
@property(strong, nonatomic)UIImageView * headerImageSelf;
/**
 *  别人的头像（左边）
 */
@property(strong, nonatomic)UIImageView * headerImageOther;
/**
 *  自己的气泡（右边）
 */
@property(strong, nonatomic)UIButton * bubbleSelf;
/**
 *  别人的气泡（左边）
 */
@property(strong, nonatomic)UIButton *bubbleOther;


+ (instancetype)tableCellWithTableView :(UITableView *)tableView;

@end
