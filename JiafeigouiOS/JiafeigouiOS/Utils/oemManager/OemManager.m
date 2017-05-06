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

@implementation OemManager

#pragma mark  oem 字符串
NSString *const appDisplayNameKey = @"CFBundleDisplayName";
NSString *const cylan = @"cylan";
NSString *const doby = @"zhongxing";
NSString *const cell_c = @"cell_c";

NSString *const domainKey = @"Jfgsdk_host";

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
            switch ([JfgLanguage languageType])
            {
                case LANGUAGE_TYPE_CHINESE:
                {
                    protocolUrl = @"http://www.jfgou.com/app/treaty_zhongxing_cn.html";
                }
                    break;
                    
                default:
                {
                    protocolUrl = @"http://www.jfgou.com/app/treaty_zhongxing_en.html";
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
            helpUrl = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"help_url_Doby"],[[[NSBundle mainBundle] infoDictionary] objectForKey:domainKey]];
        }
            break;
        case oemTypeCylan:
        default:
        {
            helpUrl = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"help_url"],[[[NSBundle mainBundle] infoDictionary] objectForKey:domainKey]];
        }
            break;
    }
    
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
            oemKey = @"F6rHsK2c3af7SAV0CKsRQpwa14QijAdB";
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

@end
