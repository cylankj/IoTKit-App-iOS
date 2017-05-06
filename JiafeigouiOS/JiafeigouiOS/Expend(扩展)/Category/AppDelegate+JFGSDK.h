//
//  AppDelegate+JFGSDK.h
//  JiafeigouiOS
//
//  Created by yangli on 16/5/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AppDelegate.h"
#import <JFGSDK/JFGSDK.h>
#import "NetworkMonitor.h"

@interface AppDelegate (JFGSDK)<JFGSDKCallbackDelegate,NetworkMonitorDelegate>


/**
 *  JFGSDK初始化
 */
-(void)jfgSDKInitialize;

@end
