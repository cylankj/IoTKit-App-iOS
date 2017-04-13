//
//  JFGAlbumManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGAlbumManager.h"
#import "JfgLanguage.h"
#import "JFGEquipmentAuthority.h"

@interface JFGAlbumManager()
@property(nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation JFGAlbumManager

static JFGAlbumManager *_sharedManager;
+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}



- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+(void)jfgWriteImage:(UIImage *)image toPhotosAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler
{
    NSString *titleName;
    if ([JfgLanguage languageType] == 0) {
        titleName = @"加菲狗";
    }else{
        titleName = @"Clever Dog";
    }
    
    if (album == nil || [album isEqualToString:@""]) {
         [[JFGAlbumManager sharedManager] saveImage:image toAlbum:titleName completionHandler:completionHandler];
    }else{
         [[JFGAlbumManager sharedManager] saveImage:image toAlbum:album completionHandler:completionHandler];
    }
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler {
    
    
    if (![JFGEquipmentAuthority canPhotoPermission]) {
        return;
    }
    
    [self.assetsLibrary writeImage:image
                           toAlbum:album
                 completionHandler:^(UIImage *image, NSError *error) {
                     if (completionHandler) {
                         completionHandler(image, error);
                     }
                     /// 注意，这里每次都置空是因为期间如果操作相册了，下次保存之前希望能取到最新状态。
                     self.assetsLibrary = nil;
                 }];
}



@end

@implementation ALAssetsLibrary (STAssetsLibrary)

- (void)writeImage:(UIImage *)image toAlbum:(NSString *)album completionHandler:(JFGAlbumSaveHandler)completionHandler {
    [self writeImageToSavedPhotosAlbum:image.CGImage
                           orientation:(ALAssetOrientation)image.imageOrientation
                       completionBlock:^(NSURL *assetURL, NSError *error) {
                           if (error) {
                               if (completionHandler) {
                                   completionHandler(image, error);
                               }
                           } else {
                               [self addAssetURL:assetURL
                                         toAlbum:album
                               completionHandler:^(NSError *error) {
                                   if (completionHandler) {
                                       completionHandler(image, error);
                                   }
                               }];
                           }
                       }];
}

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)album completionHandler:(ALAssetsLibraryAccessFailureBlock)completionHandler {
    void (^assetForURLBlock)(NSURL *, ALAssetsGroup *) = ^(NSURL *URL, ALAssetsGroup *group) {
        [self assetForURL:assetURL
              resultBlock:^(ALAsset *asset) {
                  [group addAsset:asset];
                  completionHandler(nil);
              }
             failureBlock:^(NSError *error) { completionHandler(error); }];
    };
    __block ALAssetsGroup *group;
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *_group, BOOL *stop) {
                            if ([album isEqualToString:[_group valueForProperty:ALAssetsGroupPropertyName]]) {
                                group = _group;
                            }
                            if (!_group) {
                                /// 循环结束
                                if (group) {
                                    assetForURLBlock(assetURL, group);
                                } else {
                                    [self addAssetsGroupAlbumWithName:album
                                                          resultBlock:^(ALAssetsGroup *group) { assetForURLBlock(assetURL, group); }
                                                         failureBlock:completionHandler];
                                }
                            }
                        }
                      failureBlock:completionHandler];
}

@end
