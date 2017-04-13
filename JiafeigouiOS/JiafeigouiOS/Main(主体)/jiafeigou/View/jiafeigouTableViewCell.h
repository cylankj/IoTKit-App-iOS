//
//  jiafeigouTableViewCell.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface jiafeigouTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNickLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *devicemsgTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadRedPoint;

/**
 *  最右边的图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImage1;

@property (weak, nonatomic) IBOutlet UIImageView *iconImage2;

@property (weak, nonatomic) IBOutlet UIImageView *iconImage3;

/**
 *  最左边的那个图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImage4;

@property (nonatomic,strong)UIImageView *shareImageView;

@end
