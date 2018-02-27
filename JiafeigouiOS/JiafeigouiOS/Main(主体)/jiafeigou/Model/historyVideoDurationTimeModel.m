//
//  historyVideoDurationTimeModel.m
//  HorizontalTableView
//
//  Created by 杨利 on 16/6/24.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "historyVideoDurationTimeModel.h"

//公式中 70表示一小时在图上的距离，7表示每6分钟的距离
static float oneHourWidth = 70;
static float sixMinuteWidth = 7;

@implementation historyVideoDurationTimeModel

-(float)startPosition
{
    NSDateComponents *dataComponent = [self dateComponentsFromTimestamp:self.startTimestamp];
    float offset_y = dataComponent.hour*oneHourWidth+(dataComponent.minute/6.0)*sixMinuteWidth;
    return floor(offset_y*100) / 100;
}

-(float)endPosition
{
    float min = self.duration/60.0;
    float width = min/6.0*sixMinuteWidth;
    return width+[self startPosition];
}

-(BOOL)isBetweenWithPosition:(float)position
{
    if (position>=[self startPosition] && position <=[self endPosition]) {
        return YES;
    }
    return NO;
}

-(BOOL)isBetweenWithPositionByTimestamp:(int64_t)timestamp
{
    NSDateComponents *dataComponent = [self dateComponentsFromTimestamp:(NSInteger)timestamp];
    
    if (dataComponent.year == [self startYear] && dataComponent.month == [self startMouth] && dataComponent.day== [self startDay]) {
        
        float offset_y = dataComponent.hour*oneHourWidth+(dataComponent.minute/6.0)*sixMinuteWidth;
        return [self isBetweenWithPosition:offset_y];
        
    }
    
    return NO;
}

-(NSInteger)startYear
{
    return [self dateComponentsFromTimestamp:self.startTimestamp].year;
}

-(NSInteger)startMouth
{
    return [self dateComponentsFromTimestamp:self.startTimestamp].month;
}

-(NSInteger)startDay
{
    return [self dateComponentsFromTimestamp:self.startTimestamp].day;
}

//录像开始的小时
-(NSInteger)startHour
{
    return [self dateComponentsFromTimestamp:self.startTimestamp].hour;
}

//录像开始的分钟
-(NSInteger)startMin
{
    return [self dateComponentsFromTimestamp:self.startTimestamp].minute;
}

-(NSDateComponents *)dateComponentsFromTimestamp:(NSInteger)timestamp
{
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    return dateComponent;
}

@end
