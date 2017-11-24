//
//  TimeChangeMonitor.m
//  JiafeigouiOS
//
//  Created by yangli on 16/5/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeChangeMonitor.h"

@interface TimeChangeMonitor()
{
    NSTimer *_timer;
    NSHashTable *_hashTable;
}
@end


@implementation TimeChangeMonitor

+(instancetype)sharedManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    _hashTable = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    return self;
}

-(void)starTimer
{
    if (!_timer || ![_timer isValid]) {
        [self timerAction];
        _timer = [NSTimer scheduledTimerWithTimeInterval:5*60 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

-(BOOL)isValid
{
    if (_timer == nil) {
        return NO;
    }
    return [_timer isValid];
}

-(void)stopTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
    }
}

-(void)addDelegate:(id<TimeChangeMonitorDelegate>)delegate
{
    [_hashTable addObject:delegate];
}

-(void)removeDelegate:(id<TimeChangeMonitorDelegate>)delegate
{
    [_hashTable removeObject:delegate];
}

-(void)timerAction
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    //NSInteger hour = [dateComponent hour];
    
    for (id<TimeChangeMonitorDelegate>delegate in [_hashTable copy]) {
        
        if ([delegate respondsToSelector:@selector(timeChangeWithCurrentYear:month:day:hour:minute:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate timeChangeWithCurrentYear:[dateComponent year] month:[dateComponent month] day:[dateComponent day] hour:[dateComponent hour] minute:[dateComponent minute]];
            });
        }
    }
}



@end
