//
//  JfgLanguage.h
//  JiafeigouiOS
//
//  Language Hanle class
//
//
//  Created by lirenguang on 16/5/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_LANGUAGE [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0]


typedef NS_ENUM(NSUInteger, LANGUAGE_TYPE){
    LANGUAGE_TYPE_CHINESE = 0,
    LANGUAGE_TYPE_ENGLISH,
    LANGUAGE_TYPE_RUSSIAN, // 俄语
    LANGUAGE_TYPE_PORTUGUESE, // 葡萄牙语
    LANGUAGE_TYPE_SPANISH, //西班牙语
    LANGUAGE_TYPE_JANPANESE = 5,  // 日语
    LANGUAGE_TYPE_FRENCH, // 法语
    LANGUAGE_TYPE_GERMAN, // 德语
    LANGUAGE_TYPE_ITALIAN, // 意大利、
    LANGUAGE_TYPE_TURKISH, // 土耳其
    LANGUAGE_TYPE_CH_TRADITIONAL = 10, // 繁体中文
    LANGUAGE_TYPE_VI_CN,     // 越南
    LANGUAGE_TYPE_id_ID,    // 印度尼西亚
};

@interface JfgLanguage : NSObject

/**
 *  语言类型
 *
 *  @return 语言类型
 */
+(NSInteger)languageType;

/**
 *  语言名字
 *  时间格式化 可能需要用到
 *
 *  @return 语言名字
 */
+(NSString *)languageName;

/**
 *  根据系统语言 返回 语言图片 名称
 *
 *  @param NSString 图片名称
 *
 *  @return 字符串  带后缀的图片名称
 */
+ (NSString *) getLanPicNameWithPicName:(NSString *)picName;

/**
 *  根据系统语言 返回 文字
 *
 *  @param keyString
 *
 *  @return Value
 */
+ (NSString *)getLanTextStrByKey:(NSString *)keyString;
@end
