//
//  jfgConfigManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AddDevConfigModel;
@class PorwerWarnModel;

@interface jfgConfigManager : NSObject
/**
 * 获取添加设备页显示内容，区分oem
 */
+(NSArray <NSArray <AddDevConfigModel *>*>*)getAddDevModel;

/**
 * 获取所有设备类型，不区分oem
 */
+(NSArray <NSArray <AddDevConfigModel *>*>*)getAllDevModel;

/**
 * 设备电量提醒
 */
+(NSArray <PorwerWarnModel *> *)getPoewerModel;

/**
 * 设备是否是门铃
 */
+(BOOL)devIsDoorBellForPid:(NSString *)pid;

/**
 * 设备是否是猫眼
 */
+(BOOL)devIsCatEyeForPid:(NSString *)pid;

/**
 * 设备是否支持安全防护功能
 */
+(BOOL)devIsSupportSafetyForPid:(NSString *)pid;

/**
 * 当前是否连接设备Wifi
 */
+(BOOL)isAPModel;

@end


/**
 *  设备电量低于多少时候提醒
 */
@interface PorwerWarnModel : NSObject

@property (nonatomic,strong)NSNumber *porwer;//剩余电量阈值
@property (nonatomic,strong)NSArray *osList;//os列表

@end


//添加设备页相关属性
@interface AddDevConfigModel : NSObject

@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *iconName;//绑定设备，分享设备页图标
@property (nonatomic,copy)NSString *homeIconName;//首页图标（在线）
@property (nonatomic,copy)NSString *homeDisableIconName;//首页图标（离线）
@property (nonatomic,copy)NSString *gifName;//添加动画gif名称
@property (nonatomic,copy)NSString *userActionTitle;//添加动画页面操作说明
@property (nonatomic,copy)NSString *ledTitle;//led灯闪烁说明
@property (nonatomic,copy)NSString *ledState;//led灯状态按钮文字
@property (nonatomic,strong)NSArray <NSNumber *> *osList;//添加类别支持的os列表
@property (nonatomic,strong)NSArray <NSString *> *oems;//支持厂家列表
@property (nonatomic,strong)NSArray <NSString *> *cidPrefixList;//起始cid

/**
 *  每个添加设备类别唯一标示
 *  1:智能摄像头  2:720摄像头  3:门铃(有电池版)  4:IPCam  5:云相机  6:猫眼  7:智能门铃（无电池版）
 */
@property (nonatomic,assign)NSNumber *typeMark;

@end
