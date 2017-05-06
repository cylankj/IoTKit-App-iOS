//
//  JFGControlEventInterceptor.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGControlEventInterceptor.h"
#import <Aspects.h>
#import <UIKit/UIKit.h>
#import "ProgressHUD.h"
#import "UIButton+Addition.h"
#import <JFGSDK/JFGSDK.h>
#import "CommonMethod.h"

@implementation JFGControlEventInterceptor

+(void)load
{
    [super load];
    [JFGControlEventInterceptor sharedInstance];
}

+(instancetype)sharedInstance
{
    static dispatch_once_t oneToken;
    static JFGControlEventInterceptor *vcInter;
    dispatch_once(&oneToken, ^{
        vcInter = [[JFGControlEventInterceptor alloc]init];
    });
    return vcInter;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        // 使用 Aspects 进行方法的拦截
        // AspectOptions 三种方式选择：在原本方法前执行、在原本方法后执行、替换原本方法
        
//        [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
//            
//            id obj = [aspectInfo instance];
//            NSString *devName = [NSString stringWithUTF8String:object_getClassName(obj)];
//            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@:viewDidAppear",devName]];
//            
//        } error:NULL];
        
        //退出页面时候，取消当前ProgressHUD的加载显示
        [UIViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
            
            //UIViewController * vc = [aspectInfo instance];
            //[vc.view endEditing:YES];
            //NSInvocation *invocation = aspectInfo.originalInvocation;
            //[invocation invoke];执行原始方法
            [ProgressHUD dismiss];
            id obj = [aspectInfo instance];
            NSString *devName = [NSString stringWithUTF8String:object_getClassName(obj)];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@:viewDidDisappear",devName]];
            
        } error:NULL];
        
        
        
        
        //拦截UIButton的点击事件，防止连续点击
        [UIButton aspect_hookSelector:@selector(touchesEnded:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo)
        {
            __block UIButton *bt = [aspectInfo instance];
            if (bt.userInteractionEnabled) {
                int64_t delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (!bt.isRelatingTouchEvent) {
                        bt.userInteractionEnabled = YES;
                    }
                });
                
                if (!bt.isRelatingTouchEvent) {
                    bt.userInteractionEnabled = NO;
                }
            }
            
            if (bt.isRelatingNetwork && [JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
                [CommonMethod showNetDisconnectAlert];
            }else{
                NSInvocation *invocation = aspectInfo.originalInvocation;
                [invocation invoke];//执行原始方法
            }

        } error:NULL];
        
    }
    return self;
}

@end
