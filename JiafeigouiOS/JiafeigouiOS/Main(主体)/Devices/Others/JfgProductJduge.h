//
//  JfgProductJduge.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/5.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JfgGlobal.h"
#import "JfgMsgDefine.h"

@interface JfgProductJduge : NSObject

// 是否 显示 自动录像 按钮
+ (BOOL)isAutoRecordSwitch:(productType)pType;

// 是否 是 720 双鱼眼 设备
+ (BOOL)isDoubleFishEyeDevice:(productType)pType;

@end
