//
//  UIImageView+JFGAccountHeadImageView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UIImageView+JFGImageView.h"
#import "CommonMethod.h"
#import "JfgConfig.h"
#import "FLLog.h"
#import "LoginManager.h"

@implementation UIImageView (JFGImageView)


- (void)jfg_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self jfg_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (cacheType == SDImageCacheTypeDisk || cacheType == SDImageCacheTypeMemory) {
            //NSLog(@"%@",imageURL);
            
        }
        
        if (error) {
            //NSLog(@"error:%@ imageUrl:%@",error,imageURL);
            NSString *hostUrl = [NSString stringWithFormat:@"%@://%@", imageURL.scheme, imageURL.host];
            hostUrl = [NSString stringWithFormat:@"%@%@",hostUrl,[imageURL path]];
            NSString *errorMsg = [NSString stringWithFormat:@"imageLoadingFailed:error:%@ url:%@",error.userInfo.description,hostUrl];
            [JFGSDK appendStringToLogFile:errorMsg];
            FLLog(@"error:%@ imageUrl:%@",error,imageURL);
        }
        
    }];
}

- (void)jfg_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options completed:completedBlock];
}

-(void)jfg_setImageWithAccount:(NSString *)account placeholderImage:(UIImage *)image refreshCached:(BOOL)refresh completed:(SDWebImageCompletionBlock)completedBlock
{
    NSString *imageUrl = [CommonMethod getCloudHeadImageForAccount:account];
    NSURL* url = [NSURL URLWithString:imageUrl];

    //NSLog(@"headImageUrl:%@",imageUrl);
    if (refresh) {
       [self jfg_setImageWithURL:url placeholderImage:image options:SDWebImageRefreshCached progress:nil completed:completedBlock];
    }else{
       [self jfg_setImageWithURL:url placeholderImage:image options:0 progress:nil completed:completedBlock];
    }
}

-(void)jfg_setImageWithAccount:(NSString *)account photoVersion:(NSInteger)version completed:(SDWebImageCompletionBlock)completedBlock
{
    NSString *imageUrl = [CommonMethod getCloudHeadImageForAccount:account];
    NSURL* url = [NSURL URLWithString:imageUrl];

    if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline || [LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
         [self jfg_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_defaultHead"] options:0 progress:nil completed:completedBlock];
        
    }else{
        [self jfg_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_defaultHead"] options:SDWebImageRefreshCached progress:nil completed:completedBlock];
    }
    
    
    //NSInteger oldVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:JFGAccountHeadImageVersion] integerValue];
    
   
    
//    if (oldVersion != version) {
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:version] forKey:JFGAccountHeadImageVersion];
//        
//       
//        
//    }else{
//        
//        [self jfg_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_defaultHead"] options:0 progress:nil completed:completedBlock];
//        
//    }
    
}

@end
