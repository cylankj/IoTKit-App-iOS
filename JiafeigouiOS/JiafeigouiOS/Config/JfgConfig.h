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
NSString *const JFGClearFeedbackNotificationKey = @"JFGClearFeedbackNotificationKey_";
NSString *const JFGIsAlwaysShowWebchatRedPointKey = @"_JFGIsAlwaysShowWebchatRedPointKey";//已经显示过绑定微信红点提醒

//账号相关key
//账号信息更新
NSString *const JFGAccountMsgChangedKey = @"JFGAccountMsgChangedKey";
NSString *const JFGAccountLoginStatueSaveKey = @"JFGAccountLoginStatueSaveKey";
NSString *const JFGAccountLoginOutKey = @"JFGAccountLoginOutKey_";

NSString *const JFGGotoSettingKey = @"JFGGotoSettingKey_";
NSString *const JFGGotoDeepSleepKey = @"JFGGotoDeepSleepKey_";
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

//720设备删除所有相片通知
NSString *const JFG720DevDelAllPhotoNotificationKey = @"JFG720DevDelAllPhotoNotificationKey_";

// bugly 相关配置
NSString *const buglyAppID = @"900022745";

//摄像头大类，用于直播相关页面跳转
typedef NS_ENUM(NSInteger,JFGDevViewType) {

    JFGDevBigTypeSinglefisheyeCamera,//单鱼眼
    JFGDevBigTypeEyeCamera,//双鱼眼
    JFGDevBigTypeSquareness,//矩形
    JFGDevBigType360,//360度设备，支持更种模式切换（圆柱，圆，四分屏幕）
    
};

//720设备局域网请求链接类型
typedef NS_ENUM(NSInteger,JFG720DevLANReqUrlType) {
    
    JFG720DevLANReqUrlTypeSnapShot,//拍照
    JFG720DevLANReqUrlTypeGetRecStatue,//录像状态
    JFG720DevLANReqUrlTypeSDFormat,//格式化sd卡
    JFG720DevLANReqUrlTypeGetSDInfo,//sd卡信息
    JFG720DevLANReqUrlTypeGetPowerLine,//是否连接电源线
    JFG720DevLANReqUrlTypeBattery,//电量
    JFG720DevLANReqUrlTypeGetRP,//分辨率
    
//    JFG720DevLANReqUrlTypeFileLogo,//设置logo
//    JFG720DevLANReqUrlTypeStartRec,//开始录像
//    JFG720DevLANReqUrlTypeStopRec,//停止录像
//    JFG720DevLANReqUrlTypeGetFileList,//sd卡文件列表
//    JFG720DevLANReqUrlTypeDownloadFile,//下载文件
//    JFG720DevLANReqUrlTypeDelFile,//删除文件
};

#endif /* JfgConfig_h */

