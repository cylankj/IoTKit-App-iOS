//
//  DevPropertyManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DevPropertyManager : NSObject

//是否支持分辨率切换
+(BOOL)isSupportRPSwitchForPid:(NSString *)pid;

//是否是RS设备
+(BOOL)isRSDevForPid:(NSString *)pid;

@end
