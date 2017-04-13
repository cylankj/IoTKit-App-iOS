//
//  NSArray+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FLExtension)

- (id)safeObjectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray(FLExtension)

///----------------------------------
///  @name 安全操作
///----------------------------------

-(void)safeAddObject:(id)anObject;

-(bool)safeInsertObject:(id)anObject
                atIndex:(NSUInteger)index;

-(bool)safeRemoveObjectAtIndex:(NSUInteger)index;

-(bool)safeReplaceObjectAtIndex:(NSUInteger)index
                     withObject:(id)anObject;

/*!
 *  排序
 */
+ (NSMutableArray *)sortArrayByKey:(NSString *)key
                             array:(NSMutableArray *)array
                         ascending:(BOOL)ascending;

@end
