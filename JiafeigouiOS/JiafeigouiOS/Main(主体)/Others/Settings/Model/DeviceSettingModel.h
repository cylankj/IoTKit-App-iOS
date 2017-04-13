//
//  DeviceSettingModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//


/**
 *  功能设置 的 Model类
 */


#import "BaseModel.h"
#import "JfgTypeDefine.h"

@interface DeviceSettingModel : BaseModel


/**
 *  设备信息
 */
@property (copy, nonatomic) NSString *info;

@property (assign, nonatomic) DeviceNetType deviceNetType;

/**
 *  设备连接的 wifi
 */
@property (copy, nonatomic) NSString *wifi;

/**
 *  是否开启 移动网络 关闭[0]   开启[1]
 */
@property (assign, nonatomic) BOOL isMobile;
@property (assign, nonatomic) int SIMCardType;

/**
 * 开启 安全防护 时间
 */
@property (nonatomic, assign) BOOL isWarnEnable;
@property (assign, nonatomic) long safeOrigin; //安全防护 原始数据
@property (nonatomic, assign) int beginTime; // 开始时间
@property (nonatomic, assign) int endTime;  // 结束时间
@property (copy, nonatomic) NSString *safe;

/**
 * 自动录像
 */
@property (assign, nonatomic) NSInteger autoPhotoOrigin;// 自动录像 原始数据
@property (copy, nonatomic) NSString *autoPhoto;

// SD卡 信息
@property (assign, nonatomic) BOOL isExistSDCard;
@property (assign, nonatomic) int sdCardError;

/**
 *  延迟拍摄
 */
@property (assign, nonatomic) BOOL isOpenDelayPhoto;
@property (assign, nonatomic) long long delayPhotoBeginTime;
@property (copy, nonatomic) NSString *delayPhoto;

/**
 * 待机  开启[1] 关闭【0】
 */
@property (assign, nonatomic) BOOL isStandby;

/**
 *  设备指示灯  开启【1】 关闭【0】
 */
@property (assign, nonatomic) BOOL isOpenIndicator;
/*
 * 平视，俯视
 */
@property (assign, nonatomic) int angleType;
@property (copy, nonatomic) NSString *angleStr;

/**
 *  画面 旋转 开启【1】  关闭【0】
 */
@property (assign, nonatomic) int isRotate;
/**
 *  电流 频率 110V
 */
@property (assign, nonatomic) BOOL isNTSC;

/**
 *  是否开启 通知
 */
@property (assign, nonatomic) BOOL isOpenNotifi;

/**
 门磁,开关时通知我
 */
@property (assign, nonatomic) BOOL isNotifyMe;

#pragma mark
#pragma mark  是否显示小红点
// 安全防护 小红点
@property (nonatomic, assign) BOOL isShowSafeRedDot;
// 自动录像 小红点
@property (nonatomic, assign) BOOL isShowAutoPhotoRedDot;
// 延时摄影 小红点
@property (nonatomic, assign) BOOL isShowDelayPhotoRedDot;
// 其他小红点
@property (nonatomic, assign) BOOL isShowOthersRedDot;

#pragma mark
#pragma mark  单元格 是否可点击
/*
 cell 是否可 点击属性
 */

// 单独 某个cell
@property (assign, nonatomic) BOOL isMobileCanClick;
@property (assign, nonatomic) BOOL isDelayPhotoCanClick;
@property (assign, nonatomic) BOOL isStandByCanClick;

// 所有的cell
@property (assign, nonatomic) BOOL isCellCanClick;

// detail Text Color
@property (nonatomic, copy) UIColor *detailTextColor;

@end
