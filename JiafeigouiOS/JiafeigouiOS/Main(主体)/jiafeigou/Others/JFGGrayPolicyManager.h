//
//  JFGGrayPolicyManager.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/8/14.
//  Copyright © 2017年 lirenguang. All rights reserved.
//  灰度策略请求相关

#import <Foundation/Foundation.h>

@interface JFGGrayPolicyManager : NSObject

//获取灰度策略表（距离上次获取大于六个小时，否则无效）
+(void)reqGrayPolicy;

//当前账号下面支持AI功能的设备是否开放AI功能入口
+(BOOL)isSupportAIForCurrentAcount;

//删除灰度策略获取时间记录（下次刷新设备列表会重新获取）
+(void)resetGrayTime;

@end
