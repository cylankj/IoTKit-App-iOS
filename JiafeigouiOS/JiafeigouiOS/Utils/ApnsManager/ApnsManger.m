//
//  ApnsManger.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2016/11/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ApnsManger.h"
#import "GeTuiSdk.h"
#import "NSString+FLExtension.h"
#import "JfgGlobal.h"
#import "LoginManager.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgConstKey.h"
#import "AppDelegate.h"

@interface ApnsManger()<GeTuiSdkDelegate>

@end


@implementation ApnsManger

NSString *const jfgRegisterTokenTime = @"_jfgRegisterTokenTime";
NSString *const jfgDeviceToken = @"_jfgDeviceToken";
NSString *const jfgGtClientID = @"_jfgGtClientID";

NSString *const cylan_inhouse = @"com.cylan.jiafeigoupush";
NSString *const cylan_inhouseDev = @"com.cylan.jiafeigoupush.dev";
NSString *const cylan_personal = @"com.cylan.jiafeigouapns";
NSString *const cylan_personalDev = @"com.cylan.jiafeigouapns.dev";
NSString *const cylan_company = @"jiafeigouAppstore";
NSString *const cylan_companyDev = @"jiafeigouAppstoreDev";

NSString *const qiaoan_compay = @"com.test.qiaoan.vrcctv";
NSString *const qiaoan_compayDev = @"com.test.qiaoan.vrcctv.dev";
NSString *const extelLink_personal = @"com.ylt.jiafeigouapns";
NSString *const extelLink_personalDev = @"com.ylt.jiafeigouapns.dev";
NSString *const cellC_company = @"com.cell.push";
NSString *const cellC_companyDev = @"com.cell.push.dev";


+ (void)registerRemoteNotification:(BOOL)forceRegister
{
    NSUserDefaults *stdDefault = [NSUserDefaults standardUserDefaults];
    double registerError = [[NSDate date] timeIntervalSince1970] - [[stdDefault valueForKey:jfgRegisterTokenTime] doubleValue];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"apns timeError  %f",registerError]];
    
    //  强制 注册
    if (forceRegister)
    {
        [self registerNotification];
        return;
    }
    if (registerError > 30*60.0) // 0.5h 后重新注册
    {
        [self registerNotification];
    }
    else
    {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"not register because not at time [%f]",registerError]];
    }
    
}

+ (void)registerNotification
{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] initGtSDK];
    
    [[NSUserDefaults standardUserDefaults] setValue:@([[NSDate date] timeIntervalSince1970]) forKey:jfgRegisterTokenTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{//获取到token了，可延迟执行
#ifdef __IPHONE_8_0
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [JFGSDK appendStringToLogFile:@"remote register iOS8.0 +"];
            return ;
        }
#endif
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
        [JFGSDK appendStringToLogFile:@"remote register iOS7.0 -"];
    });
}

+ (void)unRegisterNotification
{
    [self destoryGtSDK];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
    {
        [JFGSDK appendStringToLogFile:@"[un register token] \n"];
        [[UIApplication sharedApplication ] unregisterForRemoteNotifications];
    }
    [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:jfgRegisterTokenTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:jfgGtClientID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:jfgDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void)clearApplicationIconBadge
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JFGSDK appendStringToLogFile:@"clear BadgeNumber"];
}

#pragma mark
#pragma mark  -- Property
+ (NSString *)getSysDeviceToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:jfgDeviceToken];
}

+ (void)keepSysDeviceToken:(NSString *)token
{
    [JFGSDK appendStringToLogFile:@"[receive token] \n"];
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:jfgDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [GeTuiSdk registerDeviceToken:token];
    
    [self bindGtClientID:[self getGtClientID] WithToken:token];
}

+ (NSString *)getGtClientID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:jfgGtClientID];
}

+ (void)keeptGtClientID:(NSString *)clientID
{
    [JFGSDK appendStringToLogFile:@"[receive clientId] \n"];
    [[NSUserDefaults standardUserDefaults] setValue:clientID forKey:jfgGtClientID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self bindGtClientID:clientID WithToken:[self getSysDeviceToken]];
}


+ (void)bindGtClientID:(NSString *)clientID WithToken:(NSString *)token
{
    if ((![token empty] && token != nil) && ((![clientID empty] && clientID != nil)))
    {
        [GeTuiSdk registerDeviceToken:token];
        
        if ([[self getGtClientID] isEqualToString:clientID])
        {
            [JFGSDK deviceTokenUploadForString:clientID];
        }
        else
        {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"same clientID [%@]  [%@]",token, [self getGtClientID]]];
        }
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"Gt registerDeviceToken:[%@] clientID:[%@]",token, clientID]];
}

#pragma mark
#pragma mark  -- GeTui SDK

+ (void)destoryGtSDK
{
    [GeTuiSdk destroy];
    [JFGSDK appendStringToLogFile:@"[GeTuiSdk destroy] \n"];
}


#pragma mark  ----GeTui 配置获取
// certType 在info.plist 文件传进来
+ (NSString *)certType
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"];
}

+ (NSString *)geTuiAppKey
{
    NSString *retStr = @"";
    
#pragma mark 定制包 证书
    // 乔安
    if (([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"VRCCTV"]))
    {
        if ([[self certType] isEqualToString:qiaoan_compayDev]) // 乔安 dev证书
        {
            retStr = @"XjMr9OuhGbAsRuS8ks0dk2";
        }
        else if ([[self certType] isEqualToString:qiaoan_compay]) // 乔安 dist证书
        {
            retStr = @"ZMjs6LoypD8GtdUrKW3m17";
        }
    }
    
    // extel_link
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"extel_link"])
    {
        if ([[self certType] isEqualToString:extelLink_personalDev]) // extel_link dev证书
        {
            retStr = @"xpUA9L6Kf46jem2WpRdYP5";
        }
        else if ([[self certType] isEqualToString:extelLink_personal]) // extel_link dist证书
        {
            retStr = @"5Pv2j22gIb6x8eLVXPpPk8";
        }
    }
    
    // cell_c
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"cell_c"])
    {
        if ([[self certType] isEqualToString:cellC_companyDev])
        {
            retStr = @"hqJ7DOwkiz9ofyQliBWSq7";
        }
        else if ([[self certType] isEqualToString:cellC_company])
        {
            retStr = @"C7QS8K96Bw9J2yIOyotR29";
        }
    }
    
#pragma mark cylan 证书
    
    if ([[self certType] isEqualToString:cylan_inhouse]) // inhourse dist证书
    {
        retStr = @"B5UxrC5YEt80DGbQ3J9vq9";
    }
    else if ([[self certType] isEqualToString:cylan_personalDev]) // inhourse dev个人证书 doby
    {
        retStr = @"HX6Ny4pvY68tr2NLG8KIH";
    }
    else if ([[self certType] isEqualToString:cylan_personal]) // dist 个人证书 doby
    {
        retStr = @"Ll1pom4rhBASdjmfMT3qf4";
    }
    else if ([[self certType] isEqualToString:cylan_company]) // dist 公司证书 cylan
    {
        retStr = @"Z9vD3d2Phi7PJlTVoPICE2";
    }
    else if ([[self certType] isEqualToString:cylan_companyDev]) // dev 公司证书 cylan
    {
        retStr = @"BbDAVQ2A0c8I3sJgWbnA75";
    }
    else if ([[self certType] isEqualToString:cylan_inhouseDev])
    {
        retStr = @"9yrBuuvPk39uxzGMMCoD11";
    }
    return retStr;
}

+ (NSString *)geTuiAppID
{
    NSString *retStr = @"";
    
#pragma mark 定制包 证书
    // 乔安
    if (([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"VRCCTV"]))
    {
        if ([[self certType] isEqualToString:qiaoan_compayDev]) // 乔安 dev证书
        {
            retStr = @"I4eCZlTDxm9TF9I723Q8M8";
        }
        else if ([[self certType] isEqualToString:qiaoan_compay]) // 乔安 dist证书
        {
            retStr = @"jZIAChByhA9r0qu7mfc4y7";
        }
    }
    
    
    // extel_link
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"extel_link"])
    {
        if ([[self certType] isEqualToString:extelLink_personalDev]) // extel_link dev证书
        {
            retStr = @"Hdpwm9Dvu69hFJ61SDiu9";
        }
        else if ([[self certType] isEqualToString:extelLink_personal]) // extel_link dist证书
        {
            retStr = @"EQAUxPr1aC8GK1d6NzCpa2";
        }
    }
    
    // cell_c
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"cell_c"])
    {
        if ([[self certType] isEqualToString:cellC_companyDev])
        {
            retStr = @"lsY0DtYfCa9xVgLUgEBWv";
        }
        else if ([[self certType] isEqualToString:cellC_company])
        {
            retStr = @"4eUvkfDgSW8oaKBo06JZc9";
        }
    }
    
#pragma mark cylan 证书
    
    if ([[self certType] isEqualToString:cylan_inhouse])
    {
        retStr = @"hpAMPN1CeK8yN0hTVJdqD5";
    }
    else if ([[self certType] isEqualToString:cylan_personalDev])
    {
        retStr = @"OilSIixGBE63OXgsI7Yyo";
    }
    else if ([[self certType] isEqualToString:cylan_personal]) // dist 个人证书
    {
        retStr = @"oCQ3tLnS4s8AB6raHE8Uj7";
    }
    else if ([[self certType] isEqualToString:cylan_company])
    {
        retStr = @"NEmmdFfQSv9Q63gUQKNvm8";
    }
    else if ([[self certType] isEqualToString:cylan_companyDev])
    {
        retStr = @"Bn6dvkuQWA7rlW3ew9paK7";
    }
    else if ([[self certType] isEqualToString:cylan_inhouseDev])
    {
        retStr = @"OudErko02H7Dc1P4nNJRd3";
    }
    return retStr;
}

+ (NSString *)geTuiAppSecret
{
    NSString *retStr = @"";
#pragma mark 定制包 证书
    // 乔安
    if (([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"VRCCTV"]))
    {
        if ([[self certType] isEqualToString:qiaoan_compayDev]) // 乔安 dev证书
        {
            retStr = @"OfxvnwSgHA7Uj3g3qJju69";
        }
        else if ([[self certType] isEqualToString:qiaoan_compay]) // 乔安 dist证书
        {
            retStr = @"7qI2eWJxKA75JaJ81yPBG5";
        }
    }
    
    // extel_link
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"extel_link"])
    {
        if ([[self certType] isEqualToString:extelLink_personalDev]) // extel_link dev证书
        {
            retStr = @"JdiF4vmgg79QCulhBc2GN3";
        }
        else if ([[self certType] isEqualToString:extelLink_personal]) // extel_link dist证书
        {
            retStr = @"KUDPuFznlc7fZzOWTDc56";
        }
    }
    
    // cell_c
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey] isEqualToString:@"cell_c"])
    {
        if ([[self certType] isEqualToString:cellC_companyDev])
        {
            retStr = @"uddda1mmnBAotxOd24SFC5";
        }
        else if ([[self certType] isEqualToString:cellC_company])
        {
            retStr = @"AiDhcIpd0i9SEislDd0sz1";
        }
    }
    
#pragma mark cylan 证书
    
    if ([[self certType] isEqualToString:cylan_inhouse])
    {
        retStr = @"povmvs3kDVANfQ0YUcX00A";
    }
    else if ([[self certType] isEqualToString:cylan_personalDev])
    {
        retStr = @"9dtcWzbxkP9tsybk3HCRm";
    }
    else if ([[self certType] isEqualToString:cylan_personal]) // dist 个人证书
    {
        retStr = @"FghOAink1JAZUqQpRo4Bc";
    }
    else if ([[self certType] isEqualToString:cylan_company]) // dist 公司证书 cylan
    {
        retStr = @"GJIx0TSBCP8lLKsWL7Lmd4";
    }
    else if ([[self certType] isEqualToString:cylan_companyDev])
    {
        retStr = @"zjAvazxVMjAnZTuUOsYWw2";
    }
    else if ([[self certType] isEqualToString:cylan_inhouseDev])
    {
        retStr = @"ChFWaeCVzK8KLGK0WbW8I7";
    }
    return retStr;
}


@end
