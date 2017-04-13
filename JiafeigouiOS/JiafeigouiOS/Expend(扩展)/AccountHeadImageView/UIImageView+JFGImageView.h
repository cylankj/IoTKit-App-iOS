//
//  UIImageView+JFGAccountHeadImageView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (JFGImageView)

- (void)jfg_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

-(void)jfg_setImageWithAccount:(NSString *)account photoVersion:(NSInteger)version completed:(SDWebImageCompletionBlock)completedBlock;

-(void)jfg_setImageWithAccount:(NSString *)account placeholderImage:(UIImage *)image refreshCached:(BOOL)refresh completed:(SDWebImageCompletionBlock)completedBlock;

@end
