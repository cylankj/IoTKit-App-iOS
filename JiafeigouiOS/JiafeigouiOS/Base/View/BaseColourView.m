//
//  BaseColourView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/4.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseColourView.h"
#import "JfgGlobal.h"

@interface BaseColourView()

@property (nonatomic,strong)CAGradientLayer *dayGradient;
@property (nonatomic,strong)CAGradientLayer *nightGradient;

@end

@implementation BaseColourView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self setLayerColour:[self isDayLight]];
}

#pragma mark data
//  判断 是否是 白天
- (BOOL)isDayLight
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    if (dateComponent.hour>=6 && dateComponent.hour<18)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)setLayerColour:(BOOL)isDayLight
{
    CALayer *layer = [[self.layer sublayers] objectAtIndex:0];
    
    if (!isDayLight)
    {
        if (layer == self.nightGradient)
        {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.layer insertSublayer:self.nightGradient atIndex:0];
        
    }
    else
    {
        if (layer == self.dayGradient)
        {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.layer insertSublayer:self.dayGradient atIndex:0];
        
    }
}


#pragma mark property
- (CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#54b2d0"].CGColor,
                           (id)[UIColor colorWithHexString:@"#439ac4"].CGColor,
                           nil];
        
        _dayGradient = gradient;
    }
    return _dayGradient;
}

- (CAGradientLayer *)nightGradient
{
    if (!_nightGradient)
    {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#7590ae"].CGColor,
                           (id)[UIColor colorWithHexString:@"#3a5170"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}

@end
