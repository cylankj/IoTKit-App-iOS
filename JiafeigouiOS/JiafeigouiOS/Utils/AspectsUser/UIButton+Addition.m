//
//  UIButton+Addition.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/10.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "UIButton+Addition.h"
#import <objc/runtime.h>

const NSString *KeyIsRelatingNetwork = @"KeyIsRelatingNetwork";
const NSString *KeyIsRelatingTouchEvent = @"KeyIsRelatingTouchEvent";

@implementation UIButton (Addition)

-(BOOL)isRelatingNetwork
{
    return [objc_getAssociatedObject(self, &KeyIsRelatingNetwork) boolValue];
}

- (void)setIsRelatingNetwork:(BOOL)isRelatingNetwork
{
    objc_setAssociatedObject(self, &KeyIsRelatingNetwork, @(isRelatingNetwork), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isRelatingTouchEvent
{
    return [objc_getAssociatedObject(self, &KeyIsRelatingTouchEvent) boolValue];
}

-(void)setIsRelatingTouchEvent:(BOOL)isRelatingTouchEvent
{
    objc_setAssociatedObject(self, &KeyIsRelatingTouchEvent, @(isRelatingTouchEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
