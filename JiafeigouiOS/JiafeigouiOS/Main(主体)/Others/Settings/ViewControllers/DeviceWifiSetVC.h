//
//  DeviceWifiSetVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceWifiTableView.h"

@interface DeviceWifiSetVC : BaseViewController<DeviceWifiDelegate>

@property (nonatomic, copy) NSString *dogWifi; // 狗连接的wifi

@end
