//
//  AppDelegate+GlobalConfig.m
//  JiafeigouiOS
//
//  Created by yangli on 16/6/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AppDelegate+GlobalConfig.h"
#import "SDWebImageManager.h"
#import <Foundation/Foundation.h>

@implementation AppDelegate (GlobalConfig)

-(void)config
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //过滤oss长度
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        
        NSString *urlStr = [url absoluteString];
        if ([urlStr rangeOfString:@"security-token"].location != NSNotFound && [urlStr rangeOfString:@"jiafeigou"].location != NSNotFound) {
            url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        }
        
//        NSString *host = url.host;
//        NSString *scheme = url.scheme;
        NSString *path = url.path;
        //[[NSUserDefaults standardUserDefaults] setObject:url.host forKey:@"osshost"];
        
        return path;
        
    }];
}

@end
