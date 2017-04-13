//
//  UpgradeDeviceModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "UpgradeDeviceModel.h"

@implementation UpgradeDeviceModel

- (NSString *)lastestVersion
{
    if (_lastestVersion == nil || [_lastestVersion isEqualToString:@""])
    {
        _lastestVersion = self.currentVersion;
    }
    
    return _lastestVersion;
}

- (NSString *)totalSizeStr
{
    if (self.totalSize/1024 > 1)
    {
        _totalSizeStr = [NSString stringWithFormat:@"%0.2fM",self.totalSize/1024/1024];
    }
    else
    {
        _totalSizeStr = [NSString stringWithFormat:@"%0.2fK",self.totalSize];
    }
    
    return _totalSizeStr;
}

- (NSString *)binUrl
{
    if (_binUrl != nil)
    {
        _binUrl = [_binUrl stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return _binUrl;
}

@end
