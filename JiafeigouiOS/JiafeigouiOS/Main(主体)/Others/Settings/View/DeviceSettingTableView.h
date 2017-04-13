//
//  DeviceSettingTableView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDeviceTableView.h"
#import "settingFootView.h"
#import "DeviceSettingViewModel.h"
#import "SDImageCache.h"

@protocol DeviceSettingDelegate <NSObject>

@optional

- (void)deviceSettingTableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo;

-(void)cellSwitchDidSelected:(NSIndexPath *)idnexPath type:(productType)type;

@end


@interface DeviceSettingTableView : BaseDeviceTableView<UITableViewDelegate, UITableViewDataSource, DeviceSettingVMDelegate>

//刷新数据
-(void)refreshData;
// 请求 数据
- (void)initData;
/**
 *  ViewModel
 */
@property (strong, nonatomic) DeviceSettingViewModel *deviceSettingVM;

@property (assign, nonatomic)id<DeviceSettingDelegate> settingDelegate;

@property (strong, nonatomic) settingFootView *footView;

@property (copy, nonatomic) NSString * alias;

@property (assign, nonatomic) BOOL isShare;

@end
