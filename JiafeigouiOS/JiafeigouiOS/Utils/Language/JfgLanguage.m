//
//  JfgLanguage.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/5/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgLanguage.h"

@implementation JfgLanguage


+(NSInteger)languageType
{
    
    if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hans"])
    {
        return LANGUAGE_TYPE_CHINESE;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"ru"])
    {
        return LANGUAGE_TYPE_RUSSIAN;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"pt"]) // pt, pt-PT
    {
        return LANGUAGE_TYPE_PORTUGUESE;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"es"]) //es, es-MX
    {
        return  LANGUAGE_TYPE_SPANISH;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"ja"])
    {
        return LANGUAGE_TYPE_JANPANESE;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"fr"])//fr, fr-CA
    {
        return LANGUAGE_TYPE_FRENCH;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"de"]) // de, de-CN
    {
        return LANGUAGE_TYPE_GERMAN;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"it"])
    {
        return LANGUAGE_TYPE_ITALIAN;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"tr"])
    {
        return LANGUAGE_TYPE_TURKISH;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hant"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-HK"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-TW"])
    {
        return LANGUAGE_TYPE_CH_TRADITIONAL;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"vi"])
    {
        return LANGUAGE_TYPE_VI_CN;
    }
    if ([SYSTEM_LANGUAGE hasPrefix:@"id"])
    {
        return LANGUAGE_TYPE_id_ID;
    }
    return LANGUAGE_TYPE_ENGLISH;
}

+(NSString *)languageName
{
    
    if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hans"] || [SYSTEM_LANGUAGE hasPrefix:@"ru"] || [SYSTEM_LANGUAGE hasPrefix:@"pt"] || [SYSTEM_LANGUAGE hasPrefix:@"es"]  || [SYSTEM_LANGUAGE hasPrefix:@"ja"] || [SYSTEM_LANGUAGE hasPrefix:@"fr"] || [SYSTEM_LANGUAGE hasPrefix:@"de"] || [SYSTEM_LANGUAGE hasPrefix:@"it"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-Hant"] || [SYSTEM_LANGUAGE hasPrefix:@"tr"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-HK"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-TW"] ||
        [SYSTEM_LANGUAGE hasPrefix:@"vi"] || [SYSTEM_LANGUAGE hasPrefix:@"id"]) //
    {
        return SYSTEM_LANGUAGE;
    }
    return @"en";
}

+ (NSString *) getLanPicNameWithPicName:(NSString *)picName
{
    if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hans"])
    {
        return [NSString stringWithFormat:@"%@_hans",picName];
    }
    return [NSString stringWithFormat:@"%@_en",picName];
}


+ (NSString *)getLanTextStrByKey:(NSString *)keyString
{
    NSString *valueString = NSLocalizedString(keyString, nil);
    NSString *pathString = @"";
    
    // 部分需要特殊处理的列出来
    if ([SYSTEM_LANGUAGE hasPrefix:@"en"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hans"]) // zh-Hans-CN , zh-Hans
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"fr"])  // fr-CA, fr
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"fr" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"es"]) // es, es-MX
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"es" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"pt"]) // pt, pt-PT
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"pt" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"de"]) // de, de-CN
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"de" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"ja"]) // ja, ja-CN
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"ja" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"ru"])// ru, ru-CN
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"ru" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"it"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"it" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"tr"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"tr" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"zh-Hant"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-HK"] || [SYSTEM_LANGUAGE hasPrefix:@"zh-TW"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"zh-Hant" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"vi"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"vi-VN" ofType:@"lproj"];
    }
    else if ([SYSTEM_LANGUAGE hasPrefix:@"id"])
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"id-ID" ofType:@"lproj"];
    }
    else
    {
        pathString = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    }
    if (![pathString isEqualToString:@""])
    {
        NSBundle *enLanguageBundle = [NSBundle bundleWithPath:pathString];
        valueString = [enLanguageBundle localizedStringForKey:keyString value:nil table:nil];
    }
    return valueString;
}

@end
