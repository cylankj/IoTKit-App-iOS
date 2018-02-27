//
//  BindDevProgressViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/16.
//  Copyright © 2016年 lirenguang. All rights reserved.
//  绑定设备加载过程页面

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BindDevProgressViewController : BaseViewController

@property (nonatomic, assign) configWifiType configType;

@property (nonatomic, copy) NSString *wifiName;

@property (nonatomic, copy) NSString *wifiPassWord;

@property (nonatomic,copy)NSString *macAddr;


@end
