//
//  SetDeviceNameVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <JFGSDK/JFGSDKAcount.h>
typedef NS_ENUM(NSInteger, DeviceNameVCType)
{
    DeviceNameVCTypeSelf,// 设置 设备名称
    DeviceNameVCTypeWifiPassword,// 设置 wifi 密码
    
    DeviceNameVCTypeFriendsRemarkName, //修改 亲友 设备名称
    DeviceNameVCTypeNickName, //昵称
    DeviceNameVCTypeBindEmail, //绑定邮箱
    DeviceNameVCTypeBindPhone, //绑定手机
    DeviceNameVCTypeChangeEmail,//修改邮箱
    DeviceNameVCTypeChangePhone,//修改手机
    DeviceNameVCTypeEmailPassword,//邮箱密码
    DeviceNameVCTypePhonePassword,//手机密码
    DeviceNameVCTypePassword, //密码
    DeviceNameVCTypeSetHelloWorld //发送添加好友打招呼语言
    
};


@interface SetDeviceNameVC : BaseViewController
/**
 *  复用： wifi 名字
 */
@property (copy, nonatomic) NSString *deviceName;

@property (assign, nonatomic) DeviceNameVCType deviceNameVCType;
@property (strong, nonatomic) JFGSDKAcount * jfgAccount;
@property (copy, nonatomic) NSString * account;//针对有些界面并没有JFGSDKAcount，只有一个账号

/**
 WiFi配置
 */
@property (copy, nonatomic)NSString * wifiName;

@end
