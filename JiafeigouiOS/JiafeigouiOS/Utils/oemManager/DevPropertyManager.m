//
//  DevPropertyManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "DevPropertyManager.h"

@implementation DevPropertyManager

//是否支持分辨率切换
+(BOOL)isSupportRPSwitchForPid:(NSString *)pid
{
    BOOL isSupport = NO;
    NSArray *supportPids = @[@"18",@"36",@"37",@"47",@"48"];
    for (NSString *_pid in supportPids) {
        if ([_pid isEqualToString:pid]) {
            isSupport = YES;
            break;
        }
    }
    return isSupport;
}

+(BOOL)isRSDevForPid:(NSString *)pid
{
    BOOL isSupport = NO;//38 39 81 49 50
    NSArray *supportPids = @[@"38",@"39",@"49",@"50",@"81"];
    for (NSString *_pid in supportPids) {
        if ([_pid isEqualToString:pid]) {
            isSupport = YES;
            break;
        }
    }
    return isSupport;
}

@end
