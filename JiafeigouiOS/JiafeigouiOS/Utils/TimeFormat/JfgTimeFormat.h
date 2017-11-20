//
//  JfgTimeFormat.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JfgTimeFormat : NSObject

+ (NSDate *)formatTime:(int)time;
+ (NSString *)transToHHmm:(NSString *)timsp;
+ (NSString *)transToHHmm2:(NSString *)timsp;
+ (NSString *)transToDate:(NSString *)timsp;
+ (NSString *)transTotimeSp:(NSString *)time;
+ (NSString *)transToyyyyMMddhhmmss:(NSString *)timsp;
+ (NSString *)transToyyyyMMddhhmmssWithTime:(int)timsp;
+ (NSString *)transToyyyyMMddWithTime:(long long)timesp;

+ (NSString *)transformTime:(long long)timesp withFormat:(NSString *)timeFormat;

+ (BOOL)isToday:(double)timesp;

+(NSString *)transToAITime:(int)timestamp;

@end
