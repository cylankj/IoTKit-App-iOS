//
//  UIButton+Click.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UIButton+Click.h"
#import <objc/runtime.h>

static const void *LSUIButtonBlockForTouchUpInsideKey = &LSUIButtonBlockForTouchUpInsideKey;
@interface UIButton()

@property (nonatomic,copy,setter=setHanderForTouchUpInside:)void(^handerForTouchUpInside)(UIButton *button);

@end
@implementation UIButton (Click)

+ (void)button:(UIButton *)button touchUpInSideHander:(void(^)(UIButton *button))hander {
    [button initWihtHanderForTouchUpInside:^(UIButton *button) {
        if (hander) {
            hander(button);
        }
    }];
}
-(void)initWihtHanderForTouchUpInside:(void(^)(UIButton *button))hander
{
    if (!self) {
        return;
    }
    [self addTarget:self action:@selector(handerForTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    self.handerForTouchUpInside = hander;
}
-(void)handerForTouchUpInsideAction:(UIButton *)button
{
    void (^hander)(UIButton *button) = self.handerForTouchUpInside;
    if (!hander)
    {
        return;
    }
    hander(button);
}
-(void)setHanderForTouchUpInside:(void(^)(UIButton *button))hander
{
    objc_setAssociatedObject(self, LSUIButtonBlockForTouchUpInsideKey, hander, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}
-(void(^)(UIButton *button))handerForTouchUpInside
{
    return objc_getAssociatedObject(self, LSUIButtonBlockForTouchUpInsideKey);
}
@end
