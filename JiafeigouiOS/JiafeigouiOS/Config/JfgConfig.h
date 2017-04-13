//
//  JfgConfig.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/11.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef JfgConfig_h
#define JfgConfig_h

#pragma mark SDK 萝卜头
/**
    dnwB7zfqjOqUmayw9XbVbfWh8ahSIShs   yf
    Z5SYDbLV44zfFGRdAgFQhH62fAnIqf3G   robot
    IAiAWpo9iGQzUB3w4OmGFUsJmACXDaWt   test1
 Z5SYDbLV44zfFGRdAgFQhH62fAnIqf3G
 */

//NSString *const company_vKey = @"dnwB7zfqjOqUmayw9XbVbfWh8ahSIShs";
NSString *const company_vid = @"0001";
NSString *const company_vKey_robot = @"Z5SYDbLV44zfFGRdAgFQhH62fAnIqf3G";

//账号头像改变通知
NSString *const account_headImage_changed = @"account_headImageChanged_";
NSString *const JFGCurrentLoginedAccountKey = @"JFGCurrentLoginedAccountKey";

//账号相关key
//账号信息更新
NSString *const JFGAccountMsgChangedKey = @"JFGAccountMsgChangedKey";
NSString *const JFGAccountLoginStatueSaveKey = @"JFGAccountLoginStatueSaveKey";
NSString *const JFGAccountLoginOutKey = @"JFGAccountLoginOutKey_";

NSString *const JFGGotoSettingKey = @"JFGGotoSettingKey_";
NSString *const JFGSettingOpenSafety = @"JFGSettingOpenSafety_";

NSString *const JFGDelExporePicKey = @"JFGDelExporePicKey_";

NSString *const JFGNotShowOffnetKey =@"JFGNotShowOffnetKey_";

NSString *const JFGExploreRefreshNotificationKey = @"JFGExploreRefreshNotificationKey_";

NSString *const JFGAccountHeadImageVersion = @"JFGAccountHeadImageVersionKey";
NSString *const JFGDeviceAliasChangedNotificationKey = @"JFGDeviceAliasChangedNotificationKey";
//设备被其他端删除消息通知或取消分享
NSString *const JFGDeviceDelByOtherClientNotification = @"JFGDeviceDelByOtherClientNotification_";

NSString *const JFGShowDemoForExploreKey = @"JFGShowDemoForExploreKey_";

//是否有门铃正在被呼叫
NSString *const JFGDoorBellIsCallingKey = @"JFGDoorBellIsCallingKey_";
NSString *const JFGDoorBellIsPlayingCid = @"JFGDoorBellIsPlayingCid";
NSString *const JFGTabBarJumpVcKey = @"JFGTabBarJumpVcKey_";

// bugly 相关配置
NSString *const buglyAppID = @"900022745";

#endif /* JfgConfig_h */

