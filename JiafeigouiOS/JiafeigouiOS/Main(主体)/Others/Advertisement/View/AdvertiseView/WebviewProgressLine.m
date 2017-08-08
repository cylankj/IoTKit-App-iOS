//
//  WebviewProgressLine.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "WebviewProgressLine.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"

@implementation WebviewProgressLine

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}

-(void)startLoadingAnimation{
    self.hidden = NO;
    self.width = 0.0;

    [UIView animateWithDuration:0.4 animations:^{
        self.width = [UIScreen mainScreen].bounds.size.width * 0.3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.width = [UIScreen mainScreen].bounds.size.width * 0.6;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                self.width = [UIScreen mainScreen].bounds.size.width * 0.9;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}


-(void)endLoadingAnimation{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.width = [UIScreen mainScreen].bounds.size.width;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
