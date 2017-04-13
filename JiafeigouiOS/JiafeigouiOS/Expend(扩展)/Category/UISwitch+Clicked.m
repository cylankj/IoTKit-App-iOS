//
//  UISwitch+Clicked.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UISwitch+Clicked.h"
#import <objc/runtime.h>

static const void *UISwitchBlockForChangedKey = &UISwitchBlockForChangedKey;

@interface UISwitch ()

@property (nonatomic,copy,setter=setHanderForValueChanged:) void(^handerForTouchUpInside)(UISwitch *_switch);

@end

@implementation UISwitch (Clicked)

- (void)addValueChangedBlockAcion:(void(^)(UISwitch *_switch))hander
{
    [self initWihtHanderForValuedChanged:^(UISwitch *_switch) {
        if (hander)
        {
            hander(_switch);
        }
    }];
}

-(void)initWihtHanderForValuedChanged:(void(^)(UISwitch *_switch))hander
{
    if (!self) {
        return;
    }
    [self addTarget:self action:@selector(handerForTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    self.handerForValueChanged = hander;
}

-(void)handerForTouchUpInsideAction:(UISwitch  *)_switch
{
    void (^hander)(UISwitch *_switch) = self.handerForValueChanged;
    if (!hander)
    {
        return;
    }
    hander(_switch);
}

- (void)setHanderForValueChanged:(void(^)(UISwitch *_switch))hander
{
     objc_setAssociatedObject(self, UISwitchBlockForChangedKey, hander, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void(^)(UISwitch *_switch))handerForValueChanged
{
    return objc_getAssociatedObject(self, UISwitchBlockForChangedKey);
}
@end
