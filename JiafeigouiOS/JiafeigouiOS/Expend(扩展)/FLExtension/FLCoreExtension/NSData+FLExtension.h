//
//  NSData+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

///----------------------------------
///  @name 二进制数据扩展操作
///----------------------------------

#import <Foundation/Foundation.h>

@interface NSData (FLExtension)

/**  md5加密  */
- (NSData *)MD5;

- (NSString *)MD5String;

- (NSString *)UTF8String;


//base64加密
- (NSString *)base64EncodedString;

+ (NSData *)dataFromBase64String:(NSString *)base64String;

- (id)initWithBase64String:(NSString *)base64String;



@end
