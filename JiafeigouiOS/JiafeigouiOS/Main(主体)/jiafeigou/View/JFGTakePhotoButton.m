//
//  JFGTakePhotoButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGTakePhotoButton.h"

@interface JFGTakePhotoButton()
{
    NSTimer *timer;
    CGFloat count;
}
@end

@implementation JFGTakePhotoButton

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self addTarget:self action:@selector(offsetButtonTouchBegin:)forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(offsetButtonTouchEnd:)forControlEvents:UIControlEventTouchUpInside];
}

-(void)offsetButtonTouchBegin:(id)sender{
    
    count = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
    [timer fire];
}

-(void)offsetButtonTouchEnd:(id)sender{
    
    if (timer && [timer isValid]) {
        [timer invalidate];
    }
    if (count > 0.8) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoTouchUpDown:forTakePhotoEvents:)]) {
            [self.delegate takePhotoTouchUpDown:self forTakePhotoEvents:JFGTakePhotoTouchLongTap];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoTouchUpDown:forTakePhotoEvents:)]) {
            [self.delegate takePhotoTouchUpDown:self forTakePhotoEvents:JFGTakePhotoTouchSingleTap];
        }
    }
    NSLog(@"count = %f",count);
}

-(void)handleTimer:(id)sender
{
    count = count + 0.1;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
