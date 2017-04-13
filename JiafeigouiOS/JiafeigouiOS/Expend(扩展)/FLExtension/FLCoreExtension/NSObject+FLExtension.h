//
//  NSObject+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (FLExtension)

/**
 *delay时间后在主线程执行某些操作
 */
- (id)bk_performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay;
+ (id)bk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/**
 *delay时间后在后台线程执行某些操作
 */
- (id)bk_performBlockInBackground:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay;
+ (id)bk_performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
