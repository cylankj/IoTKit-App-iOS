//
//  JfgTimeFormat.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgTimeFormat.h"
#import "DateTools.h"
#import "JfgLanguage.h"

@implementation JfgTimeFormat


+ (NSDate *)formatTime:(int)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *date= [dateFormatter dateFromString:[NSString stringWithFormat:@"1970-01-01 %d:%d:00", (time>>8&0xff), (time&0xff)]];
    return date;
}

+(NSString *)transToHHmm2:(NSString *)timsp
{
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    return currentDateStr;
}

//时间戳--->时间
+(NSString *)transToHHmm:(NSString *)timsp{
    
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //NSLog(@"%@",detaildate);
    
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; // 指定日历的算法 NSCalendarIdentifierGregorian,NSGregorianCalendar
    // NSDateComponent 可以获得日期的详细信息，即日期的组成
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = comps.year;
    NSInteger currentMounth = comps.month;
    NSInteger currentday = comps.day;
    
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:detaildate];
    NSInteger detailYear = comps.year;
    NSInteger detailMounth = comps.month;
    NSInteger detailDay = comps.day;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    
    NSString *timsStr = @"";
    
    if (detailYear == currentYear &&
        detailMounth == currentMounth &&
        detailDay == currentday) {
        //同一天
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
        timsStr = [NSString stringWithFormat:@"%@ %@",[JfgLanguage getLanTextStrByKey:@"DOOR_TODAY"],currentDateStr];
    }else{
        
        if (detailDay+1 == currentday) {
            //昨天
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
            timsStr = [NSString stringWithFormat:@"%@ %@",[JfgLanguage getLanTextStrByKey:@"Yesterday"],currentDateStr];
            
        }else if(detailYear == currentYear){
            //今年
            [dateFormatter setDateFormat:@"MM/dd HH:mm"];
            timsStr = [dateFormatter stringFromDate:detaildate];
            
        }else{
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
            timsStr = [dateFormatter stringFromDate:detaildate];
        }
        
        
    }
    
    //实例化一个NSDateFormatter对象
   
    //设定时间格式,这里可以设置成自己需要的格
    //NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    //NSLog(@"%@",timsStr);
    return timsStr;
}



+ (NSString *)transToyyyyMMddhhmmss:(NSString *)timsp {
    
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    return currentDateStr;
}

+ (NSString *)transToyyyyMMddhhmmssWithTime:(int)timsp
{
    return [self transToyyyyMMddhhmmss:[NSString stringWithFormat:@"%d",timsp]];
}

+ (NSString *)transToyyyyMMddWithTime:(long long)timesp
{
    //NSTimeInterval time=[timesp doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:timesp]; //如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    return currentDateStr;
}

//时间戳--->日期
+ (NSString *)transToDate:(NSString *)timsp{
    
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDate * nowDate = [NSDate date];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    //设定时间格式,这里可以设置成自己需要的格式
    if ([detaildate year] == [nowDate year]) {
        [dateFormatter setDateFormat:@"MM.dd"];
    } else {
        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    }

    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    if ([detaildate isToday]) {
        return [JfgLanguage getLanTextStrByKey:@"DOOR_TODAY"];
    }else if ([detaildate isYesterday]) {
        return [JfgLanguage getLanTextStrByKey:@"Yesterday"];
    }
    return currentDateStr;
}

+ (NSString *)transformTime:(long long)timesp withFormat:(NSString *)timeFormat
{
    //NSTimeInterval time=[timesp doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:timesp]; //如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    [dateFormatter setAMSymbol:@"am"];
    [dateFormatter setPMSymbol:@"pm"];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:timeFormat];
    
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    
    return currentDateStr;
}

//时间---->时间戳
+(NSString *)transTotimeSp:(NSString *)time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; //设置本地时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:time];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];//时间戳
    return timeSp;
}

+ (BOOL)isToday:(double)timesp
{
    NSDate *argDate=[NSDate dateWithTimeIntervalSince1970:timesp];

    return [argDate isToday];
}
@end
