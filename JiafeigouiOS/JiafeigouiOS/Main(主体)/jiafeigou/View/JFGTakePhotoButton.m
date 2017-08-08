//
//  JFGTakePhotoButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGTakePhotoButton.h"
#import "XTimer.h"

#define longTapMacSecoud 0.8

@interface JFGTakePhotoButton()
{
    NSTimer *timer;
    CGFloat count;
    BOOL isReturnAction;
}
@end

@implementation JFGTakePhotoButton

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self addTarget:self action:@selector(offsetButtonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(offsetButtonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
}

-(void)offsetButtonTouchBegin:(id)sender
{
    if (timer && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    count = 0;
    isReturnAction = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

-(void)offsetButtonTouchEnd:(id)sender{
    
    if (timer && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    
    if (isReturnAction) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoTouchUpDown:forTakePhotoEvents:)]) {
            [self.delegate takePhotoTouchLongTapEnd];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoTouchUpDown:forTakePhotoEvents:)]) {
        [self.delegate takePhotoTouchUpDown:self forTakePhotoEvents:JFGTakePhotoTouchSingleTap];
    }
        
    NSLog(@"count = %f",count);
}

-(void)handleTimer:(id)sender
{
    count = count + 0.1;
    if (count >= longTapMacSecoud && !isReturnAction) {
       
        //长按
        isReturnAction = YES;
        if (timer && [timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoTouchUpDown:forTakePhotoEvents:)]) {
            [self.delegate takePhotoTouchUpDown:self forTakePhotoEvents:JFGTakePhotoTouchLongTap];
        }
    }
    NSLog(@"%@ timer",[self class]);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
