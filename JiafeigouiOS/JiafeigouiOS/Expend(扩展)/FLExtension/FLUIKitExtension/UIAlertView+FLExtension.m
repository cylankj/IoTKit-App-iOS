//
//  UIAlertView+FLExtension.m
//  FLExtensionTask
//
//  Created by 紫贝壳 on 15/8/14.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "UIAlertView+FLExtension.h"
#import <objc/runtime.h>

static const void *FLAlertActionBlockKey = &FLAlertActionBlockKey;
static const void *FLAlertDelegateBlockKey = &FLAlertDelegateBlockKey;

@implementation UIAlertView (FLExtension)


// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showAlertViewWithClickedButtonBlock:(void(^)(NSInteger buttonIndex))block
                              otherDelegate:(id)delegate
{
    if (block) {
        /**
         1 创建关联（源对象，关键字，关联的对象和一个关联策略。)
         2 关键字是一个void类型的指针。每一个关联的关键字必须是唯一的。通常都是会采用静态变量来作为关键字。
         3 关联策略表明了相关的对象是通过赋值，保留引用还是复制的方式进行关联的；关联是原子的还是非原子的。这里的关联策略和声明属性时的很类似。
         */
        objc_setAssociatedObject(self, &FLAlertActionBlockKey, block, OBJC_ASSOCIATION_COPY);
        
        if (delegate) {
            objc_setAssociatedObject(self, &FLAlertDelegateBlockKey, delegate, OBJC_ASSOCIATION_ASSIGN);
        }
        
        self.delegate = self;
        [self show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    ///获取关联的对象，通过关键字。
    void (^block) (NSInteger button) = objc_getAssociatedObject(self, &FLAlertActionBlockKey);
    
    if (block) {
        ///block传值
        block(buttonIndex);
    }

}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(alertViewCancel:)]) {
        [delegate alertViewCancel:alertView];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [delegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [delegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(alertView: willDismissWithButtonIndex:)]) {
        [delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(alertView: didDismissWithButtonIndex:)]) {
        [delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    id delegate = objc_getAssociatedObject(self, &FLAlertDelegateBlockKey);
    if (delegate && [delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [delegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    return YES;
}


@end
