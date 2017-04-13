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

#endif /* JfgTableViewCellKey_h */
