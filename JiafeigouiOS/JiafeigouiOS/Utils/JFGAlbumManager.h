//
//  JFGAlbumManager.h
//  JiafeigouiOS
//
//  Created by yl on 2016/12/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


typedef void (^JFGAlbumSaveHandler)(UIImage *image, NSError *error);


@interface JFGAlbumManager : NSObject

+ (instancetype)sharedManager;

/**
 * @brief 将图片写入相册,使用ALAssetLibrary
 *
 * @param  image    需要写入的图片
 * @param  album    相册名称，如果相册不存在，则新建相册,如果nil，则创建“加菲狗”相册
 * @param  completionHandler 回调
 */
+(void)jfgWriteImage:(UIImage *)image toPhotosAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler;

- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler;

@end

@interface ALAssetsLibrary (STAssetsLibrary)

- (void)writeImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler;

@end
