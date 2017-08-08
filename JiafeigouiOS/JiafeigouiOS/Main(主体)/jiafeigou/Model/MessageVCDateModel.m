//
//  MessageVCDateModel.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/24.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MessageVCDateModel.h"

@implementation MessageVCDateModel


+(NSTimeInterval)timestampsAfter1DayWithTimestamp:(UInt64)timestamp
{
    NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSTimeInterval endtime = [endDate timeIntervalSince1970];
    return endtime;
}

//获取给定时间起往前15天零点时间戳
+(NSArray *)timestampsBefore15DayWithTimestamp:(UInt64)timestamp
{
    NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSTimeInterval startTime = [startDate timeIntervalSince1970];
    NSMutableArray *timeStampArr = [NSMutableArray new];
    
    [timeStampArr addObject:[NSNumber numberWithLongLong:startTime]];
    
    for (int i=1; i<7; i++) {
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-i toDate:startDate options:0];
        NSTimeInterval endtime = [endDate timeIntervalSince1970];
        [timeStampArr addObject:[NSNumber numberWithLongLong:endtime]];
        NSLog(@"%.0f",endtime);
    }
    
    return timeStampArr;
}

+(NSInteger)yearFromTimestamp:(NSTimeInterval)timestamp
{
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:createDate];
    return [year integerValue];
}

+(NSInteger)monthFromTimestamp:(NSTimeInterval)timestamp
{
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *mounth = [dateFormatter stringFromDate:createDate];
    return [mounth integerValue];
}

+(NSInteger)dayFromTimestamp:(NSTimeInterval)timestamp
{
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *days = [dateFormatter stringFromDate:createDate];
    return [days integerValue];
}



@end
