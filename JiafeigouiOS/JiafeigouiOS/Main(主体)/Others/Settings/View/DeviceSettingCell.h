//
//  DeviceSettingCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgGlobal.h"
#import "BaseTableViewCell.h"

@interface DeviceSettingCell : BaseTableViewCell

@property (strong, nonatomic) UISwitch *settingSwitch;

@property (strong, nonatomic) UIImageView * cusImageVIew;

@property (strong, nonatomic) UILabel *cusLabel;

@property (strong, nonatomic) UILabel *cusDetailLabel; //重写 detailTextLabel

@property (assign, nonatomic) BOOL canClickCell;

- (void)layoutAgain;

@end
