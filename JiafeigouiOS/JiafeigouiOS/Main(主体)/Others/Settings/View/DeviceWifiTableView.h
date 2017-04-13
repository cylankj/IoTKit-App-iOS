//
//  DeviceWifiTableView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDeviceTableView.h"
#import "DeviceWifiSetViewModel.h"

@protocol DeviceWifiDelegate <NSObject>

@optional

- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo;

@end

@interface DeviceWifiTableView : BaseDeviceTableView<UITableViewDelegate, UITableViewDataSource, DeviceWifiSetVMDelegate>

@property (weak, nonatomic) id<DeviceWifiDelegate> deviceWifiDelegate;

@property (nonatomic, copy) NSString *selectedWifi;

@end
