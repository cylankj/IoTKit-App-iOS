//
//  DeviceSettingVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceSettingTableView.h"
#import "JiafeigouDevStatuModel.h"

@interface DeviceSettingVC : BaseViewController<DeviceSettingDelegate>

@property (nonatomic,copy)NSString *alis;
@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

@end
