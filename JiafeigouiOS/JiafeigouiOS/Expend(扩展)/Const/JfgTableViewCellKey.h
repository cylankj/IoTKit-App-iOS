//
//  JfgTableViewCellKey.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef JfgTableViewCellKey_h
#define JfgTableViewCellKey_h

// text 内容
NSString *const cellTextKey = @"_textContent";
// detailText 内容
NSString *const cellDetailTextKey = @"_detailTextContent";
// imageView 图片
NSString *const cellIconImageKey = @"_settingIconImage";
// footView text 内容
NSString *const cellFootViewTextKey = @"_footViewText";
// HeadView text 内容
NSString *const cellHeadViewTextKey = @"_headViewText";
// Switch 右边开关按钮(显示)
NSString *const cellshowSwitchKey = @"_showSwitch";
// Switch 右边开关 是否开启
NSString *const isCellSwitchOn = @"_isSwitchOn";

NSString *const canClickCellKey = @"_canClickCellKey";

NSString *const detailTextColorKey = @"_detailTextColor"; // 详情内容 文字颜色

// 系统 右边标记 类型
NSString *const cellAccessoryKey = @"_accessory";

// 右侧 红点key
NSString *const cellRedDotInRight = @"_rightRedDot";
// 隐藏域 记录 服务器原始数据
NSString *const cellHiddenText = @"_hiddenText";

NSString *const cellUniqueID = @"_celluuid";

#pragma mark uuid value

// 功能设置 cell 唯一id
NSString *const deviceInfo = @"_deviceInfo";
NSString *const wifiConfig = @"_wifiConfig";
NSString *const hotWireless = @"_hotWireless";
NSString *const mobileConfig = @"_mobileConfig";
NSString *const apConnectting = @"_apConnectting";
NSString *const safeProtect = @"_safeProtect";
NSString *const recordSetting = @"_recordSetting";
NSString *const clearCallMsg = @"_clearCallMsg";
NSString *const standBy = @"_standBy";
NSString *const angle = @"_angle";
NSString *const indirector = @"_indirector";
NSString *const hangup = @"_hangup";
NSString *const ntsc = @"_ntsc";

// 设备信息 cell 唯一id
NSString *const deviceName = @"_deviceName";
NSString *const timeZone = @"_timeZone";
NSString *const microSDCard = @"_microSDCard";
NSString *const devUpgrade = @"_devUpgrade";

// 录像设置 cell 唯一id
NSString *const idCellMoveRecord = @"_idCellMoveRecord";    // 猫眼
NSString *const idCellRecordWhenAbnormal = @"_idCellRecordWhenAbnormal";
NSString *const idCellNeverReocrd = @"_idCellNeverRecord";
NSString *const idCellAbnormalRecord = @"_idCellAbnormalRecord";
NSString *const idCellAwaysRecord = @"_idCellAwaysRecord";

// 安全防护 cell 唯一id
NSString *const idCellWarnEnable = @"_idCellWarnEnable";
NSString *const idCellSensitive = @"_idCellSensitive";
NSString *const idCellWarnSound = @"_idCellWarnSound";
NSString *const idCellAIRecognition = @"_idCellAIRecognition";
NSString *const idCellAlramDutaion = @"_idCellAlramDutaion";
NSString *const idCellWarnBeginTime = @"_idCellWarnBeginTime";
NSString *const idCellWarnEndTime = @"_idCellWarnEndTime";
NSString *const idCellRepeatTime = @"_idCellRepeatTime";

#endif /* JfgTableViewCellKey_h */
