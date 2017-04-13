//
//  JFGObjCache.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGObjCache.h"
#import <MJExtension/MJExtension.h>

@implementation JFGObjCache


+(void)saveObjs:(NSArray *)objList toPath:(NSString *)path
{
    NSMutableArray *arrList = [[NSMutableArray alloc]init];
    
    for (id obj in objList) {
        
        if ([obj isKindOfClass:[NSObject class]]) {
            
            NSObject *_obj = obj;
            //NSObject转NSDictionary
            NSDictionary *objDict = _obj.mj_keyValues;
            [arrList addObject:objDict];
    
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    
    [arrList writeToFile:path atomically:NO];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//    });
    
    
}

+(NSArray *)achieveClass:(Class)_class byPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return nil;
    }
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:path];
    
    NSMutableArray *resultArr = [[_class class] mj_objectArrayWithKeyValuesArray:arr];
    
    return resultArr;
}

@end
