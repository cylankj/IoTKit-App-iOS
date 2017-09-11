//
//  OemManager.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "OemManager.h"
#import "JfgConstKey.h"
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import "NSFileManager+FLExtension.h"
#import "JfgUserDefaultKey.h"
#import <JFGSDK/JFGSDK.h>

@implementation OemManager

#pragma mark  oem 字符串
NSString *const appDisplayNameKey = @"CFBundleDisplayName";
NSString *const cylan = @"cylan";
NSString *const doby = @"zhongxing";
NSString *const cell_c = @"cell_c";

NSString *const domainKey = @"Jfgsdk_host";
NSString *const portKey = @"Jfgsdk_post";

// oem 类型
+ (NSInteger)oemType
{
    NSString *bundleOem = [[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey];
    
    if ([bundleOem isEqualToString:doby])
    {
        return oemTypeDoby;
    }
    else if (([bundleOem isEqualToString:cell_c]))
    {
        return oemTypeCell_C;
    }
    
    return oemTypeCylan;
}
// appName
+ (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:appDisplayNameKey];
}

#pragma mark 配置读取

+ (id)getOemConfig:(NSString *)oemConfigKey
{
    id result = nil;
    
    NSDictionary *configDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oemConfig" ofType:@"plist"]];
    
    if (![oemConfigKey isEqualToString:@""] && oemConfigKey != nil)
    {
        result = [configDict objectForKey:oemConfigKey];
    }

    return result;
}

+ (NSString *)getOemProtocolUrl
{
    NSString *protocolUrl = @"";

    switch ([self oemType])
    {
        case oemTypeDoby:
        {
//            protocolUrl = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Treaty_url"],[NSString stringWithFormat:@"_%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:oemNameKey]]];
            
            switch ([JfgLanguage languageType])
            {
                case LANGUAGE_TYPE_CHINESE:
                {
                    protocolUrl = @"http://www.jfgou.com/app/DobyNew/treaty_DobyNew_cn.html";
                }
                    break;
                    
                default:
                {
                    protocolUrl = @"http://www.jfgou.com/app/DobyNew/treaty_DobyNew_en.html";
                }
                    break;
            }
            
        }
            break;
        case oemTypeCell_C: // 不显示 协议
        {
            
        }
            break;
        case oemTypeCylan:
        default:
        {
//            "Treaty_url" = "http://www.jfgou.com/app/treaty%@_en.html";
            protocolUrl = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Treaty_url"],@""];
            
            /*
            switch ([JfgLanguage languageType])
            {
                case LANGUAGE_TYPE_CHINESE:
                {
                    protocolUrl = @"http://www.jfgou.com/app/treaty_cn.html";
                }
                    break;
                    
                default:
                {
                    protocolUrl = @"http://www.jfgou.com/app/treaty_en.html";
                }
                    break;
            }
            */
        }
            break;
    }
    
    return protocolUrl;
}

+ (NSString *)getOemHelpUrl
{
    NSString *helpUrl = @"";
    
    switch ([self oemType])
    {
        case oemTypeDoby:
        case oemTypeCell_C: // 不显示 协议
        {
            if ([JfgLanguage languageType] == LANGUAGE_TYPE_CHINESE) {
                helpUrl = [NSString stringWithFormat:@"https://%@:8081/helps/zh-rCN_zhongxing.html",[self getdomainURLString]];
            }else{
                helpUrl = [NSString stringWithFormat:@"https://%@:8081/helps/en_zhongxing.html",[self getdomainURLString]];
            }
            
        }
            break;
        case oemTypeCylan:
        default:
        {
            helpUrl = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"help_url"],[self getdomainURLString], @""];
        }
            break;
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"helpUrl:%@",helpUrl]];
    return helpUrl;
}

+ (NSString *)getOemVid
{
    NSString *vidKey = @"";
    
    switch ([OemManager oemType])
    {
        case oemTypeDoby:
        {
            vidKey = @"0002";
        }
            break;
        case oemTypeCell_C:
        {
            vidKey = @"0060";
        }
            break;
        case oemTypeCylan:
        default:
        {
            vidKey = company_vid;
        }
            break;
    }
    return vidKey;
}

+ (NSString *)getOemVKey
{
    NSString *oemKey = @"";
    
    switch ([OemManager oemType])
    {
        case oemTypeDoby:
        {
            //ekPVDWnSKiTkwCT3QQkXd0U0SolaYqr1
            oemKey = @"ekPVDWnSKiTkwCT3QQkXd0U0SolaYqr1";
        }
            break;
        case oemTypeCell_C:
        {
            oemKey = @"doLUb8CEObqCKQpA05ytKKHPu5Q3SvYX";
        }
            break;
        case oemTypeCylan:
        default:
        {
            oemKey = company_vKey_robot;
        }
            break;
    }
    return oemKey;
}

#pragma mark 域名获取

+ (NSString *)getdomainWithPortURLString
{
    return [NSString stringWithFormat:@"%@:%@",[self getdomainWithPortURLString], [self getPort]];
}

+ (NSString *)getdomainURLString
{
    NSString *domainUrlStrng = [[NSUserDefaults standardUserDefaults] objectForKey:jfgDomianURL];
    
    
    if (domainUrlStrng != nil && ![domainUrlStrng isEqualToString:@""])
    {
        if ([domainUrlStrng containsString:@":"])
        {
            NSArray *domains = [domainUrlStrng componentsSeparatedByString:@":"];
            
            return [domains objectAtIndex:0];
        }
    }
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:domainKey];
}

+ (NSString *)getPort
{
    NSString *domainUrlStrng = [[NSUserDefaults standardUserDefaults] objectForKey:jfgDomianURL];
    
    if (domainUrlStrng != nil && ![domainUrlStrng isEqualToString:@""])
    {
        if ([domainUrlStrng containsString:@":"])
        {
            NSArray *domains = [domainUrlStrng componentsSeparatedByString:@":"];
            
            return [domains objectAtIndex:1];
        }
    }
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:portKey];
}

@end
