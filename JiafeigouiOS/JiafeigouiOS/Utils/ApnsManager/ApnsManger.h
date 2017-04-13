//
//  ApnsManger.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/11/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApnsManger : NSObject

+ (void)registerRemoteNotification:(BOOL)forceRegister;
+ (void)unRegisterNotification;
// 清空 角标
+ (void)clearApplicationIconBadge;

#pragma mark
#pragma mark  属性
// certType 
+ (NSString *)certType;



#pragma mark
#pragma mark token 存取
// token 的get 和 set  确保唯一 出口入口
+ (void)keepSysDeviceToken:(NSString *)token;
+ (NSString *)getSysDeviceToken;

#pragma mark
#pragma mark clientID 存取
// GtClientID 的get 和 set  确保唯一 出口入口
+ (void)keeptGtClientID:(NSString *)clientID;
+ (NSString *)getGtClientID;

#pragma mark
#pragma mark Gt 配置参数
+ (NSString *)geTuiAppKey;
+ (NSString *)geTuiAppID;
+ (NSString *)geTuiAppSecret;

@end
