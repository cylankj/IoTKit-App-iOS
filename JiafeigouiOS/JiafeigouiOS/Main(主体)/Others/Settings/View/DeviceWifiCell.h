//
//  DeviceWifiCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface DeviceWifiCell : BaseTableViewCell
/**
 *  wifi 信号
 */
@property (strong, nonatomic) UIImageView *signalImageView;

/**
 *  wifi 是否 上锁
 */
@property (strong, nonatomic) UIImageView *lockImageView;
/**
 *  系统的 textlabel 自定义
 */
@property (strong, nonatomic) UILabel *cusTextLabel;
/**
 *  系统 的 ImageView  自定义
 */
@property (strong, nonatomic) UIImageView *cusImageView;


/**
 if hidden cusImageView
 */
@property (assign, nonatomic) BOOL isHiddenImage;
@end
