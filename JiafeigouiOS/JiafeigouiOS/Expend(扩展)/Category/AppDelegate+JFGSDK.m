//
//  AppDelegate+JFGSDK.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AppDelegate+JFGSDK.h"
#import "LoginManager.h"
#import <objc/runtime.h>
#import "JfgGlobal.h"
#import "JFGBoundDevicesMsg.h"
#import "ProgressHUD.h"
#import "CommonMethod.h"
#import "OemManager.h"
#import "FileManager.h"
#import "JfgConstKey.h"
#import "JfgConfig.h"

static char const *objKey;

@implementation AppDelegate (JFGSDK)

-(void)jfgSDKInitialize
{
    [JFGSDK connectWithVid:[OemManager getOemVid] vKey:[OemManager getOemVKey] ForWorkDir:[FileManager jfgLogDirPath]];
    [JFGSDK logEnable:YES];
    [JFGSDK addDelegate:self];
    [[NetworkMonitor sharedManager] addDelegate:self];
    [JFGBoundDevicesMsg sharedDeciceMsg];
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfg language Name: [%@]",[JfgLanguage languageName]]];
}

-(void)jfgOnUpdateNTP:(uint32_t)unixTimestamp
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:JFGSDKNTPTIMESTAMP];
    [[NSUserDefaults standardUserDefaults] setObject:@(unixTimestamp) forKey:JFGSDKNTPTIMESTAMP];
}

-(void)jfgNetworkChanged:(JFGNetType)netType
{
    if (netType == JFGNetTypeOffline) {
        
        //某些页面断网不需要出现轻提示（如：绑定设备页面）
        if (![[NSUserDefaults standardUserDefaults] boolForKey:JFGNotShowOffnetKey]) {
            
            [ProgressHUD dismiss];
            int64_t delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [CommonMethod showNetDisconnectAlert];
                
            });
        }
        
        
    }
}

#pragma mark- JFGSDKDelegate



#pragma mark- getter and setter
-(void)setJfgSDKConnected:(BOOL)jfgSDKConnected
{
    objc_setAssociatedObject(self, &objKey, @(jfgSDKConnected), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)jfgSDKConnected
{
    return [objc_getAssociatedObject(self, &objKey) boolValue];
}

@end
