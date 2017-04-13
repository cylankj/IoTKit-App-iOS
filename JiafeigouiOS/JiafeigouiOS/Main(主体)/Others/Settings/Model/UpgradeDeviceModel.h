//
//  UpgradeDeviceModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface UpgradeDeviceModel : BaseModel


@property (nonatomic, copy) NSString *currentVersion;  //当前版本

@property (nonatomic, copy) NSString *lastestVersion;  //最新版本

@property (nonatomic, copy) NSString *versionDescribe; //版本说明

@property (nonatomic, assign) BOOL isShowRedDot;

@property (nonatomic, copy) NSString *deviceWifi;

@property (nonatomic, copy) NSString *binUrl;

@property (nonatomic, assign) CGFloat totalSize;
@property (nonatomic, copy) NSString *totalSizeStr;

@property (nonatomic, assign) int dlState;

@property (nonatomic, assign) int netState;

@end
