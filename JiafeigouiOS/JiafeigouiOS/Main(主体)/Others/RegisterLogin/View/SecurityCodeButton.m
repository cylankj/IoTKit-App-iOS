//
//  SecurityCodeButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SecurityCodeButton.h"
#import "UIColor+FLExtension.h"
#import "JfgLanguage.h"
@implementation SecurityCodeButton
{
    NSTimer *_timer;
    BOOL keepTime;
    NSInteger second;
}

-(void)didMoveToSuperview
{
    [self setTitle:[JfgLanguage getLanTextStrByKey:@"Button_ReObtain"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
    self.showsTouchWhenHighlighted = NO;
    keepTime = NO;
}

-(void)text
{
    [self startKeepTime];
}

-(void)startKeepTime
{
    if (!keepTime) {
        
        keepTime = YES;
        self.isKeepTimeing = YES;
        second = 90;
        self.userInteractionEnabled = NO;
        self.selected = YES;
        [self setTitle:@"90s" forState:UIControlStateNormal];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(keepTimer) userInfo:nil repeats:YES];
        
    }

}


-(void)keepTimer
{
    second --;
    [self setTitle:[NSString stringWithFormat:@"%ds",second] forState:UIControlStateNormal];
    self.userInteractionEnabled = NO;
    if (second == 0) {
        
        self.userInteractionEnabled = YES;
        [self setTitle:[JfgLanguage getLanTextStrByKey:@"Button_ReObtain"] forState:UIControlStateNormal];
        self.selected = NO;
        keepTime = NO;
        self.isKeepTimeing = NO;
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
