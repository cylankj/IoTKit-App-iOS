//
//  SDWebImageCacheHelper.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SDWebImageCacheHelper : NSObject

//通过链接获取图片本地缓存地址
+(NSString *)sdwebImageLocalPathForUrl:(NSString *)url;

#pragma mark- oss链接相关
//处理后的oss路径（配合SDWebImage使用）
+(NSString *)sdwebCacheForTempPathForFileName:(NSString *)fileName;

//存储在oss的文件，通过wonder判断文件是否在客户端本地有缓存
+(BOOL)diskImageExistsForFileName:(NSString *)fileName;

//通过wonder获取已经缓存本地文件路径
+(NSString *)sdwebCachePathForFileName:(NSString *)fileName;

//通过wonder获取已经缓存的图片
+(UIImage *)sdwebImageCacheForFileName:(NSString *)fileName;

@end
