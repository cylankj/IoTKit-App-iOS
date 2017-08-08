//
//  AppDelegate.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/5/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(JFGBaseTabBarViewController *)goToJFGViewContrller;

- (void)initGtSDK;

@end

