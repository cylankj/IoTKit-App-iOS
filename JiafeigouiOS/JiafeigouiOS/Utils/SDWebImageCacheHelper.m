//
//  SDWebImageCacheHelper.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "SDWebImageCacheHelper.h"
#import <SDWebImageManager.h>
#import <SDImageCache.h>

@implementation SDWebImageCacheHelper

+(NSString *)sdwebCacheForTempPathForFileName:(NSString *)fileName
{
    NSMutableString *_filePath = [[NSMutableString alloc]initWithString:fileName];
    if (_filePath.length>0 && ![[_filePath substringToIndex:1] isEqualToString:@"/"]) {
        [_filePath insertString:@"/" atIndex:0];
    }
    NSString * path = [NSString stringWithFormat:@"https://jiafeigou-test.oss-cn-hangzhou.aliyuncs.com:443%@",_filePath];
    return path;
}

+(BOOL)diskImageExistsForFileName:(NSString *)fileName
{
    NSString * path = [[self class] sdwebCacheForTempPathForFileName:fileName];
    BOOL isExit = [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:path]];
    return isExit;
}

+(NSString *)sdwebCachePathForFileName:(NSString *)fileName
{
    NSString * path = [[self class] sdwebCacheForTempPathForFileName:fileName];
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:path]];
    NSString *localPath = [[SDImageCache sharedImageCache] defaultCachePathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return localPath;
    }else{
        return [localPath stringByDeletingPathExtension];
    }
}

+(NSString *)sdwebImageLocalPathForUrl:(NSString *)url
{
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
    NSString *localPath = [[SDImageCache sharedImageCache] defaultCachePathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return localPath;
    }else{
        return [localPath stringByDeletingPathExtension];
    }
}

+(UIImage *)sdwebImageCacheForFileName:(NSString *)fileName
{
    NSString * path = [[self class] sdwebCacheForTempPathForFileName:fileName];
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:path]];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    return image;
}



@end
