//
//  JFGSDKBindingDevice.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/4/7.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGSDKBindDeviceDelegate.h"

@interface JFGSDKBindingDevice : NSObject

/**
 *  绑定代理
 */
@property (nonatomic,assign)id <JFGSDKBindDeviceDelegate> delegate;


/**
 *  AP模式下借助设备扫描周边wifi
 *  需在连接设备wifi后执行此操作
 */
-(void)scanWifi;


/**
 *  用于局域网指定设备扫描wifi
 */
-(void)scanWifiWithCid:(NSString *)cid mac:(NSString *)mac addr:(NSString *)addr;


/*!
 *  绑定设备（起AP模式绑定）（绑定成功后会触发JFGSDKCallbackDelegate #jfgDeviceList:回调，此方法默认强制绑定）
 *  需在连接设备wifi后执行此操作
 *  @param sn  新设备填写设备sn，旧设备无需填写（cid）
 *  @param ssid  wifi ssid
 *  @param key   wifi 密码
 *  @note 设置wifi模式
 */
-(void)bindDevWithSn:(NSString *)sn
                ssid:(NSString *)ssid
                 key:(NSString *)key;


/*!
 *  绑定设备(同上)
 *  @param isRebind  是否强制绑定 （YES：强制绑定，其他已绑定此设备的账号会解绑此设备 NO：如果此设备已被绑定，不支持重新绑定到其他账号）
 */
-(void)bindDevWithSn:(NSString *)sn
                ssid:(NSString *)ssid
                 key:(NSString *)key
            isRebind:(BOOL)isRebind;


/**
 *  绑定设备（设备通过蓝牙等方式自定义通信设置设备wifi等配置）
 *
 *  @param sn 设备标示
 *  @param macAddr 设备mac地址，防止工厂将cid刷重复
 *  @param isRebind  是否强制绑定 （YES：强制绑定，其他已绑定此设备的账号会解绑此设备 NO：如果此设备已被绑定，不支持重新绑定到其他账号）
 *  @return 绑定产生的随机数（需要通知设备）
 */
-(NSString *)bindDevWithSn:(NSString *)sn
                devMacAddr:(NSString *)macAddr
                  isRebind:(BOOL)isRebind;

@end
