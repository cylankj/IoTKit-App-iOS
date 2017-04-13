//
//  NSArray+FLExtension.m
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "NSArray+FLExtension.h"

@implementation NSArray (FLExtension)

- (id)safeObjectAtIndex:(NSUInteger)index {
    if ( index >= self.count ){
        return nil;
    }
    return [self objectAtIndex:index];
}

@end


@implementation NSMutableArray (FLExtension)

- (void)safeAddObject:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}

-(bool)safeInsertObject:(id)anObject atIndex:(NSUInteger)index {
    if ( index >= self.count && index != 0) {
        return NO;
    }
    
    if (!anObject) {
        return NO;
    }
    
    [self insertObject:anObject atIndex:index];
    
    return YES;
}

-(bool)safeRemoveObjectAtIndex:(NSUInteger)index {
    if ( index >= self.count ) {
        return NO;
    }
    [self removeObjectAtIndex:index];
    return YES;
    
}

-(bool)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if ( index >= self.count ) {
        return NO;
    }
    [self replaceObjectAtIndex:index withObject:anObject];
    return YES;
}

+ (NSMutableArray *)sortArrayByKey:(NSString *)key array:(NSMutableArray *)array ascending:(BOOL)ascending
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [tempArray removeAllObjects];
    [tempArray addObjectsFromArray:array];
    
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:brandDescriptor, nil];
    NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
    [tempArray removeAllObjects];
    tempArray = (NSMutableArray *)sortedArray;
    [array removeAllObjects];
    [array addObjectsFromArray:tempArray];
    
    return array;
}

@end
