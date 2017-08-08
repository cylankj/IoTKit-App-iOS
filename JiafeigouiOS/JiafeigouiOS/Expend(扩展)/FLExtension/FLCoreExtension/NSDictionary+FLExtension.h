//
//  NSDictionary+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//
#import <Foundation/Foundation.h>

///----------------------------------
///  @name 字典与JSON之间常用扩展
///----------------------------------
@interface NSDictionary (FLExtension)

-(NSData*)data;

/**
 *字典转json
 */
- (NSString *)dictionaryToJson;

/**
 *字典转json
 */
+ (NSString *)dictionaryToJson:(NSDictionary *)dictionary;

/*
 * json 字符串 转 字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


@end

///----------------------------------
///  @name 安全操作字典
///----------------------------------

@interface NSMutableDictionary (FLExtension)

- (void)safeSetObject:(id)anObject
               forKey:(id<NSCopying>)aKey;

- (void)safeRemoveObjectForKey:(id)aKey;

@end
